#!/bin/bash
#
# This build script, prepare a local dev environment
# this steps are described in .github/workflows/tests.yml
#
set -euo pipefail

echo "# Install dependencies"
time npm install
time bundle check || bundle install --path vendor/bundle
time pip3 install -r requirements.txt

echo "# Unit tests"
time ruby -e "Dir.glob('rb/test/*.rb').each { |f| require File.expand_path(f) }"
time ruby rb/bin/validate rb/schema/authors.yml "content/_authors/*.md"
time ruby rb/bin/validate rb/schema/startups.yml "content/_startups/*.md"

echo "# htmlproofer / jsonlint"
time bundle exec htmlproofer ./_site --assume-extension --check-html --disable-external --empty-alt-ignore --check-img-http
time bundle exec jsonlint _site/api/v*/*.json

echo "# yamllint"
time ci/check_yaml_front_matter_metadata.py content/_startups/*.md
time ci/check_yaml_front_matter_metadata.py content/_authors/*.md

echo "# check beta startups and members details"
time ci/check_beta_startups_members_details.py
