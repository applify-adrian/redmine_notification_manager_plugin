require 'redmine'
require 'dispatcher'

require 'issue_patch'
require 'action_mailer_base_extensions'

Dispatcher.to_prepare do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include? Notification::IssuePatch
    Issue.send(:include, Notification::IssuePatch)
  end
end

require_dependency 'issue_hooks'

Redmine::Plugin.register :redmine_stealth do

  name        'Notification Manager'
  author      'Adrian Herzog, Applify'
  description 'Enables users to configure Redmine email notifications ' +
              'for their actions'
  version     '0.1.0'
  
  permission :notifications, {:notifications => [:index, :edit]}, :public => true
  menu :project_menu, :notifications, { :controller => 'notifications', :action => 'index' }, :caption => 'Notifications', :after => :settings, :param => :project_id

end

