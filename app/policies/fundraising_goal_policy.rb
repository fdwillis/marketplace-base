class FundraisingGoalPolicy < ApplicationPolicy
  def index?
    true
  end
  def create?
    user.present? && (record.user == user || user.admin? || user.merchant? ) && (record.user == user || user.admin? || user.merchant_ready?)
  end

  def new?
    create?
  end
end