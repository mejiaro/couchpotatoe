json.array!(@manage_subjects) do |manage_subject|
  json.extract! manage_subject, :id
  json.url manage_subject_url(manage_subject, format: :json)
end
