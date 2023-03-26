class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  private

  def not_found
    render json: {}, status: :not_found
  end
end
