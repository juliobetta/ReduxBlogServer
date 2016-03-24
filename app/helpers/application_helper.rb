module ApplicationHelper
  def auth_token_alert
    content_tag(:div, class: 'alert alert-warning') do
      "Requires authentication token to be sent in Authorization header.
      <br>Example: Authorization Bearer your_access_token".html_safe
    end.html_safe
  end
end
