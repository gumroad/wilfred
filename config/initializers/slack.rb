## Put slack configuration 

# configures signing secret for slack, used for verify incoming request from slack
Slack::Events.configure do |config|
    config.signing_secret = Figaro.env.SLACK_SIGNING_SECRET
end
