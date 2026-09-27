#!/usr/bin/env bash

# エラーが発生したら処理を停止する
set -o errexit

# Gemをインストールする
bundle install

# 本番環境用のCSS・JavaScriptなどを準備する
bundle exec rails assets:precompile

# 不要になった古いアセットを削除する
bundle exec rails assets:clean

# Render無料枠ではPre-deploy Commandを使えないため、
# ビルド時にデータベースのテーブルを作成・更新する
bundle exec rails db:migrate