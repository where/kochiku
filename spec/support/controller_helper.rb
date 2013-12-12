module ControllerHelper
  def json_response
    ActiveSupport::JSON.decode response.body
  end
end
