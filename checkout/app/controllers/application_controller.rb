# frozen_string_literal: true

# Base Application Controller from which all must inherit
class ApplicationController < ActionController::API
  rescue_from ApiErrors::ValidationError, with: :handle_validation_error

  private

  def handle_validation_error(error)
    render json: { error: error.message }, status: :bad_request
  end
end
