

json.errors [@error_object] do |object|
  json.key       'request'
  json.message   object.message
  json.status    response.status

  unless Rails.env.production? 
    if object.respond_to?(:backtrace)
      json.backtrace((@error_object.backtrace || [])[0...20])
    end
  end

end