json.array!(@requests) do |request|
  json.extract! request, :id, :state, :visit
  json.url request_url(request, format: :json)
end
