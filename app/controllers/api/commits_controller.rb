# frozen_string_literal: true

class Api::CommitsController < ApiController
  before_action :fetch_repo

  def index
    commits = @repo.commits.limit(50).reorder(id: VALID_SORT_DIRECTIONS[params[:sort_direction]])
    commits = commits.unverified if params[:filter] == "unverified"
    commits = commits.verified if params[:filter] == "verified"
    render json: { status: "success", commits: commits }
  end

  private

    def fetch_repo
      @repo = Repo.find(params[:repo_id])
    end
end
