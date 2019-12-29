json.hook_user do |json|
  json.partial! 'hook_users/hook_user', user: current_hook_user
end