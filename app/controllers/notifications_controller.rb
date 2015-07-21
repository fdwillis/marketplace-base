class NotificationsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    render status: :ok
    @update = params[:msg][:checkpoints]
    Purchase.create(tag: @update['tag'], message: @update['message'], checkpoint_time: @update['checkpoint_time'])
    render nothing: true
  end
end
