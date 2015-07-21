class NotificationsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    render status: :ok
  end
end
