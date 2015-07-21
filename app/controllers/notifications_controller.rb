class NotificationsController < ApplicationController::Base
  protect_from_forgery :except => :create

  def create
    render nothing: true
    # do stuff
    status 200
  end
end
