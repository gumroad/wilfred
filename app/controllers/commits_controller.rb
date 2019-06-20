# frozen_string_literal: true

class CommitsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :fetch_commit, except: [:index, :verify_from_slack]

  PAST_COMMIT_COUNT = 25

  def index
    return redirect_to onboarding_url if current_user.incomplete?
    return redirect_to user_slack_omniauth_authorize_path if current_user.slack_username.nil?
    prepare_commits
  end

  def remind
    slack_message = "This is a friendly reminder from <@%s> to <%s|verify your commit>, %s (%s), on staging." % [current_user.slack_username, 
                    Rails.application.routes.url_helpers.root_url, @commit.formatted_sha1, @commit.message]

    @commit.notify_user_to_verify(current_user, slack_message)
    prepare_commits
    render_json_success_response
  end

  def verify
    @commit.update_attributes(state: "verified")
    prepare_commits
    current_user.notify_to_deploy if @unchecked_commits.empty? && @failed_commits.empty?
    render_json_success_response
  end

  def verify_from_slack
    slack_payload = JSON.parse(params["payload"])
    is_verified_request = Slack::Events::Request.new(request).verify!

    callback_message = slack_payload["callback_id"].split(":")
    current_user = User.find_by(slack_username: slack_payload["user"]["id"])

    if(callback_message[0] == "verify_commit_from_slack" && is_verified_request) 
      commit_id = callback_message[1]
      @commit = Commit.find(commit_id)

      @commit.update_attributes(state: "verified")
      prepare_commits(user: current_user)
      current_user.notify_to_deploy if @unchecked_commits.empty? && @failed_commits.empty?

      slack_message = "The commit: %s (%s) was verified by <@%s>" % [@commit.formatted_sha1, 
                      @commit.message, current_user.slack_username]

      render_json_for_slack slack_message, type: :public, replace: true
    else
      render_json_for_slack "Sorry verification failed, please try again."
    end
  end

  def fail
    @commit.update_attributes(state: "failed")
    prepare_commits
    render_json_success_response
  end

  private

    def fetch_commit
      @commit = Commit.find(params[:id])
    end

    def prepare_commits(user: :use_default)
      if(user == :use_default)
         user = current_user
      end

      @past_commits = user.repo.commits.verified.limit(PAST_COMMIT_COUNT).all
      @failed_commits = user.repo.commits.failed
      @unchecked_commits = user.repo.commits.unchecked
    end

    def render_json_for_slack(message, type: :private, replace: false) 
      if(type == :public)
        response_type = "in_channel"
      else
        response_type = "ephemeral"
      end

      render json: { 
        response_type: response_type,
        replace_original: replace,
        text: message
     }
    end

    def render_json_success_response
      render json: {
        success: true,
        html: render_to_string(partial: "commit_content",
                               locals: {
                                  past_commits: @past_commits,
                                  failed_commits: @failed_commits,
                                  unchecked_commits: @unchecked_commits,
                                }
        ) }
    end
end
