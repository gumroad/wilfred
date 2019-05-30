# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :check_client_api_key

  VALID_SORT_DIRECTIONS = Hash.new("asc").merge(
    "asc" => "asc",
    "desc" => "desc"
  )

  def check_client_api_key
    return if Figaro.env.client_api_key == request.headers["HTTP_API_KEY"]
    render json: { error: "unauthorized" }, status: :unauthorized
  end
end
