#!/usr/bin/env ruby
# Run from a normal terminal: ruby bin/test-local.rb --setup
require "rbconfig"
require "fileutils"
require "open3"
require "json"
require "time"
require "uri"

unknown = ARGV - %w[--setup --dry-run --help]
abort "Unknown options: #{unknown.join(' ')}" unless unknown.empty?
if ARGV.include?("--help")
  puts "Usage: ruby bin/test-local.rb [--setup] [--dry-run]"
  puts "--setup installs RubyInstaller build tools on Windows and locked bundle dependencies."
  puts "Chrome must already be installed for browser tests."
  puts "Optional LOCAL_TEST_DATABASE_URL: PostgreSQL on localhost, database name ending in _test."
  exit
end

root = File.expand_path("..", __dir__)
expected_ruby = File.read(File.join(root, ".ruby-version")).strip
abort "Ruby #{expected_ruby} is required; running #{RUBY_VERSION}." unless RUBY_VERSION == expected_ruby
windows = Gem.win_platform?
ruby_bin = File.dirname(RbConfig.ruby)
bundle = [RbConfig.ruby, File.join(ruby_bin, "bundle")]
env = {
  "PATH" => [ruby_bin, ENV["PATH"]].join(File::PATH_SEPARATOR),
  "RAILS_ENV" => "test", "RACK_ENV" => "test", "BASIC_AUTH_ENABLED" => "false",
  "DATABASE_URL" => nil, "RAILS_MASTER_KEY" => nil, "SECRET_KEY_BASE" => nil,
  "SECRET_KEY_BASE_DUMMY" => nil,
  "BUNDLE_GEMFILE" => File.join(root, "Gemfile"),
  "BUNDLE_APP_CONFIG" => File.join(root, "tmp", "local-bundle-config"),
  "BUNDLE_PATH" => File.join(root, "tmp", "local-bundle"),
  "BUNDLE_USER_HOME" => File.join(root, "tmp", "local-bundle-config"),
  "BUNDLE_WITHOUT" => "", "BUNDLE_FROZEN" => "true"
}

steps = []
if ARGV.include?("--setup")
  ridk = File.join(ruby_bin, "ridk.cmd")
  abort "RubyInstaller ridk.cmd was not found." if windows && !File.file?(ridk)
  steps << ["Build tools", [ridk, "install", "3"], {}] if windows
  steps << ["Install dependencies", bundle + ["install"], {}]
end
steps += [
  ["Dependency check", bundle + ["check"], {}],
  ["Prepare SQLite test database", bundle + %w[exec rails db:prepare], {}],
  ["All Rails tests (SQLite)", bundle + %w[exec rails test], {}],
  ["All browser tests", bundle + %w[exec rails test:system], {}]
]

postgres_url = ENV["LOCAL_TEST_DATABASE_URL"]
if postgres_url && !postgres_url.empty?
  uri = URI.parse(postgres_url)
  unless %w[postgres postgresql].include?(uri.scheme) &&
      %w[localhost 127.0.0.1 [::1] ::1].include?(uri.host) &&
      uri.path.match?(%r{\A/[a-zA-Z0-9_]+_test\z})
    abort "LOCAL_TEST_DATABASE_URL must use a local PostgreSQL database named *_test."
  end
  steps << ["All Rails tests (PostgreSQL)", bundle + %w[exec rails db:prepare test], { "DATABASE_URL" => postgres_url }]
end
steps << ["Production asset compilation", bundle + %w[exec rails assets:precompile],
          { "RAILS_ENV" => "production", "RACK_ENV" => "production", "SECRET_KEY_BASE_DUMMY" => "1" }]

if ARGV.include?("--dry-run")
  steps.each { |name, command, _| puts "#{name}: #{command.join(' ')}" }
  puts "PostgreSQL: not selected (set LOCAL_TEST_DATABASE_URL to include it)." unless postgres_url && !postgres_url.empty?
  exit
end

result_dir = File.join(root, "tmp", "local-test-results", Time.now.strftime("%Y%m%d-%H%M%S-#{Process.pid}"))
FileUtils.mkdir_p(result_dir)
results = []
passed = true
begin
  File.open(File.join(result_dir, "run.log"), "w") do |log|
    steps.each do |name, command, overrides|
      puts "\n=== #{name} ==="
      log.puts "\n=== #{name} ==="
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = nil
      Open3.popen2e(env.merge(overrides), *command, chdir: root) do |stdin, output, waiter|
        stdin.close
        output.each_line { |line| print line; log.write(line); log.flush }
        status = waiter.value
      end
      results << { name: name, exit_code: status.exitstatus, seconds: (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(2) }
      unless status.success?
        passed = false
        break # Later checks are not reported as passed if setup or a test failed.
      end
    end
  end
rescue StandardError => error
  passed = false
  warn "Runner error: #{error.class}: #{error.message}"
  results << { name: "Runner", error: "#{error.class}: #{error.message}" }
ensure
  summary = { success: passed, ruby: RUBY_VERSION, results: results,
              not_run: steps.drop(results.count).map(&:first),
              postgres: postgres_url && !postgres_url.empty? ? "selected" : "not selected" }
  File.write(File.join(result_dir, "summary.json"), JSON.pretty_generate(summary))
  puts "\n#{passed ? 'PASS' : 'NOT PASSED'} - results: #{result_dir}"
end
exit(passed ? 0 : 1)
