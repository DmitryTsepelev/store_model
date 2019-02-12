source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "sqlite3", "~> 1.3.6"

local_gemfile = File.join(__dir__, "Gemfile.local")

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
else
  gem "activerecord", "~> 5.0"
end
