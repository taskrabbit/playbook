content = JSON.parse(yield)

json.request  api_request_params
json.response content

json.jsonp!(params[:callback]) if jsonp_enabled? && jsonp?