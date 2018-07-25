json.array!(@receivables) do |receivable|
  json.extract! receivable, :id
  json.url contract_receivable_url(@contract, receivable, format: :json)
end
