class BankAccountsController < ApplicationController
  def create
  	begin
	  	member = params[:member]
	  	token = User.bank_token(member[:country], member[:acct_num], member[:rout_num])

		  bank_account = User.new_member(current_user, current_user.stripe_account_id, token.id, member[:percent].to_f, member)

		  if !bank_account.nil?
		  	redirect_to request.referrer
		  	flash[:notice] = "You Added #{member[:name].titleize} To Your Team"
		  	return
		  else
		  	redirect_to request.referrer
		  	flash[:error] = "You Need To Adjust The Percentages"
		  	return
		  end

	  rescue => e
	  	redirect_to request.referrer
	  	flash[:error] = "#{e}"
	  	return
	  end
  end

  def destroy
  	member = TeamMember.find_by(uuid: params[:id])
  	name = member.name

  	begin
	  	User.delete_member(current_user, current_user.stripe_account_id, member)
	  	flash[:notice] = "You Deleted #{name.titleize} From Your Team"
	  	redirect_to request.referrer
	  	return
	  rescue => e
	  	redirect_to request.referrer
	  	flash[:error] = "#{e}"
	  	return
	  end
  end
end
