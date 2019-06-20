### Requirements

- Ruby
- Rails
- GitHub app for Oauth and webhook setup
- Slack app for Oauth and chat messages

### Setup

There are a few environment variables that must be set in `config/application.yml` for the app to work. These are as follows:

- `SECRET_KEY_BASE` (Your Rails Secret key for verifying the integrity of signed cookies)
- `GH_APP_ID` (the id of your GitHub application)
- `GH_APP_SECRET` (the secret of your GitHub application)
- `SLACK_APP_ID` (the id of your Slack application)
- `SLACK_APP_SECRET` (the secret of your Slack application)
- `SLACK_SIGNING_SECRET` (slacks signing secret, used to verify requests coming from slack)
- `SLACK_ROOM` (the Slack channel you want deploy notifications to show up in)
- `PRODUCTION_HOST` (e.g. https://wilfred.com)
- `DEVELOPMENT_HOST` (e.g. http://local.host:3000)
- `DEPLOY_SCRIPT_USERNAME`
- `DEPLOY_SCRIPT_PASSWORD`

The last two will come from a deploy script that you must create to alert Wilfred when a commit has been deployed to staging, like so:

```
#!/usr/bin/env ruby

require "net/http"
require "json"

commits = `git log --format="%H" staging -n 50`.strip.split("\n")

uri = URI("https://#{HOST}/webhook/deploy_script")

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "application/json"
  request.basic_auth DEPLOY_SCRIPT_USERNAME, DEPLOY_SCRIPT_PASSWORD
  request.body = { commits: commits, status: "succeeded" }.to_json

  response = http.request(request)
  puts "Response #{response.code} #{response.message}: #{response.body}"
end
```

### Running

To run the server locally:

- `bundle`
- `rake db:setup`
- `rails s`

To run tests:

- `rake db:test:prepare`
- `rake test`

### Deploying

Deploys happen automatically on pushes to `master` using Heroku.
