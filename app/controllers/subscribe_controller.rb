class SubscribeController < ApplicationController
before_filter :authenticate_user!

  def update
    plan = Stripe::Plan.retrieve(params[:id])

    if current_user.stripe_plan_id?  

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      subscription = customer.subscriptions.retrieve(current_user.stripe_plan_id)
      
      subscription.plan = plan.id
      subscription.save

      current_user.update_attributes(stripe_plan_name: plan.name)
      redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"

    elsif current_user.card?

      customer = Stripe::Customer.retrieve(current_user.stripe_id)
      subscription = customer.subscriptions.create(plan: plan)

      current_user.update_attributes(stripe_plan_id: subscription.id , stripe_plan_name: plan.name, role: 'merchant')
      redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"

    elsif !current_user.card?

      @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      card_number = @crypt.encrypt_and_sign(params[:user][:card_number])
      exp_month = params[:user][:exp_month]
      exp_year = params[:user][:exp_year]
      cvc_number = params[:user][:cvc_number]
      username = params[:user][:username]


      token = Stripe::Token.create(
        :card => {
          :number => @crypt.decrypt_and_verify(card_number),
          :exp_month => exp_month.to_i,
          :exp_year => exp_year.to_i,
          :cvc => cvc_number
        },
      )
      customer = Stripe::Customer.create(
        email: current_user.email,
        source: token.id,
        plan: plan.id,
        description: 'Windows Of Worlds'
      )


      current_user.update_attributes(username: username, card_number:card_number, exp_year: exp_year, exp_month: exp_month, cvc_number: cvc_number, 
                                     stripe_plan_id: customer.subscriptions.data[0].id , stripe_plan_name: customer.subscriptions.data[0].plan.name, 
                                     role: 'merchant')
      redirect_to root_path, notice: "You Joined Plan #{plan.name.titleize}"

    else
      redirect_to edit_user_registration_path
      flash[:error] = "Please Add A Credit Card"
    end
  end
end














