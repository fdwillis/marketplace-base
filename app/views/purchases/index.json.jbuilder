json.array!(@purchases) do |purchase|
  json.extract! purchase, :id
  json.url purchase_url(purchase, format: :json)
end
