class NotificationsController < ApplicationController
  unloadable

  def index
  
    if !params[:project_id] then return end
    
    @project_identifier = params[:project_id]
    @project = Project.find(params[:project_id])
    
    # Find all the entries that belong to the selected project
    @notifications = NotificationSetting.find(:all, :conditions => {:project_id => @project[:id]})
    
    result = NotificationSetting.get_trackers_and_columns @project
    
    @trackers = result[:trackers]
    @columns = result[:columns]
    @custom_columns = result[:custom_columns]
    @custom_columns_use = result[:custom_columns_use]
    @state = result[:state]
    
  end


  def edit
  
    if !params[:project_id] then return end
    
    @project = Project.find(params[:project_id])
    
    if request.post?
      
      deleted_no = NotificationSetting.delete_all( ["project_id=?", @project[:id]] )
      
      notifications = params[:notification]
      save_ok = 0
      save_fail = 0
      
      if notifications then
        notifications.each_key do |tracker|
          notifications[tracker].each_key do |field|
            new_notification = NotificationSetting.create(:project_id => @project[:id], :tracker_id => tracker.to_i, :field => field)
            if new_notification.save
              save_ok += 1
            else
              save_fail += 1
            end
          end
        end
      else
        # Dummy entry, so that there will be no notifications for this project
        # (if there is no entry for one project, notifications will always be sent!)
        new_notification = NotificationSetting.create(:project_id => @project[:id], :tracker_id => 0, :field => 'nonexistent_field')
        new_notification.save
      end
      
      if save_fail > 0 then
        flash[:notice] = "Errors occured while saving the settings."
      else
        flash[:notice] = l(:notice_successful_update)
      end
      
      redirect_to :action => 'index', :project_id => @project[:id]
      
    end
  end

end
