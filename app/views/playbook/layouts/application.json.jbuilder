content = yield
content = ::Playbook::JsonResult.new(content)

json.request  api_request_params
json.response content

json.jsonp!(params[:callback]) if jsonp_enabled? && jsonp?