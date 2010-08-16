# Checks whether any DEFAULT fields were changed that need notification
# CUSTOM fields are checked in issue_hooks.rb


module Notification
  module IssuePatch
    
    def self.included(base) # :nodoc:

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      # Using Rails callbacks
      before_save :is_notification_necessary
      end
    end

    # Instance methods that will be added to the existing class "Issue"
    module InstanceMethods
    
      # Set a global variable Thread.current[:send_notification_email] depending on whether 
      # a notification is necessary or not. The function which sends the emails
      # can then check the value of this variable to find out whether notification
      # is necessary.
      def is_notification_necessary
      
        # Get the settings
        notifications = NotificationSetting.find(:all, :conditions => {:project_id => self.project_id, :tracker_id => self.tracker_id})
        
        # Default behavior if there are no notification settings available
        if notifications.length == 0
          Thread.current[:is_issue_change] = true
          Thread.current[:send_notification_email] = true
          return
        end
      
        notification_array = []
        notifications.each do |n|
          notification_array << n.field
        end
        
        changed_array = []
        @changed_attributes.each_key do |n|
          changed_array << n
        end
        
        critical_fields = notification_array & changed_array
        
        Thread.current[:is_issue_change] = true
        if critical_fields.length > 0
          Thread.current[:send_notification_email] = true
        end
        
        # The method must return true. Otherwise, the save action would abort.
        true
      end
    end 
  end
end