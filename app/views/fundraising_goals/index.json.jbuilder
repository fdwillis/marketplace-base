json.array!(@fundraising_goals) do |fundraising_goal|
  json.extract! fundraising_goal, :id
  json.url fundraising_goal_url(fundraising_goal, format: :json)
end
