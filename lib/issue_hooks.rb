# Finds out whether any CUSTOM fields that require notification have changed
# Default fields are checked in issue_patch.rb


class IssueHook < Redmine::Hook::ViewListener

  # :controller_issues_new_before_save, { :params => params, :issue => @issue }
  def controller_issues_new_before_save(context={})
    issue_before_save context
  end
  
  
  # :controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => @time_entry, :journal => journal}
  def controller_issues_edit_before_save(context={})
    issue_before_save context
  end
  
  
  # Finds out, whether any CUSTOM FIELDS have a changed value and sets the
  # flags Thread.current[:send_notification_email] and Thread.current[:is_issue_change]
  # to true if any of the changed values are configured to generate a notification.
  # This method is always called before an issue is saved, no matter whether
  # the issue is new or already existent.
  def issue_before_save context
    
    params = context[:params]
    issue = context[:issue]
    
    if params[:issue] then
    
      project_id = issue[:project_id]
      tracker_id = issue[:tracker_id]
      issue_id = issue[:id]
      
      # Old values (before changes)
      old_values = {}
      custom_old = CustomValue.find(:all, :conditions => {:customized_id => issue_id, :customized_type => 'Issue'})
      custom_old.each do |c|
        old_values[c.custom_field_id] = c.value
      end
      
      # New values (after changes)
      new_values = {}
      if params[:issue][:custom_field_values] then
        params[:issue][:custom_field_values].each_key do |k|
          new_values[k.to_i] = params[:issue][:custom_field_values][k]
        end
      end
      
      # Compare old and new values
      changed_array = []
      new_values.each_key do |k|
        if !old_values[k]
          changed_array << 'custom_field_' + k.to_s
        else
          if old_values[k] != new_values[k]
            changed_array << 'custom_field_' + k.to_s
          end
        end
      end
     
      
      # Read notification settings from DB
      notifications = NotificationSetting.find(:all, :conditions => {:project_id => project_id, :tracker_id => tracker_id})
      
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
      
      critical_fields = notification_array & changed_array

      Thread.current[:is_issue_change] = true
      if critical_fields.length > 0
        Thread.current[:send_notification_email] = true
      end
        
    end
    
  end
  
end