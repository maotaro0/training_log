namespace :guests do
  desc "Remove expired guest accounts and their records"
  task cleanup: :environment do
    GuestAccount.cleanup!
  end
end
