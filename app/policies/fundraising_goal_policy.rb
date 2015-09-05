class FundraisingGoalPolicy < ApplicationPolicy
  def index?
    true
  end
  def create?
    user.present? && (record.user == user || user.admin? || (user.account_approved? && user.roles.map(&:title).include?('donations')))
  end

  def new?
    create?
  end
end