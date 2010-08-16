class NotificationSetting < ActiveRecord::Base

  belongs_to :project
  
  def self.get_trackers_and_columns project
    
    state = []
    
    # Get the default column names
    columns = Issue.column_names
    
    default_columns = {}
    columns.each do |s|
      default_columns[s.to_sym] = :checkbox
    end

    
    # Get all the trackers that are active in the current project
    trackers = Tracker.find_by_sql("SELECT trackers.* 
      FROM projects_trackers INNER JOIN trackers 
          ON projects_trackers.tracker_id = trackers.id 
      WHERE project_id = " + project[:id].to_s + "
      ORDER BY position ASC")
    
    trackers.each do |t|
      state[t.id] = default_columns.dup
    end

    
    # Get all custom columns
    custom_columns = CustomField.find(:all, :conditions => { :type => 'IssueCustomField'}, :order => 'position ASC')
    
    # Get the custom columns use
    custom_fields = CustomField.find_by_sql("SELECT id, type, position, tracker_id  
      FROM custom_fields INNER JOIN custom_fields_trackers
      ON custom_fields.id = custom_fields_trackers.custom_field_id
      WHERE custom_fields.type = 'IssueCustomField'
      ORDER BY id ASC")
    
    # We need to know, which tracker has which custom fields
    custom_columns_use = []
    custom_fields.each do |col|
      custom_columns_use[col.tracker_id.to_i] ||= []         # Create array, if not exists
      custom_columns_use[col.tracker_id.to_i][col.id] = true # Add custom field id to tracker
      
      if state[col.tracker_id.to_i]
        state[col.tracker_id.to_i][('custom_field_' + col.id.to_s).to_sym] = :checkbox
      end
    end
    
    # Get the currently selected values
    currently_selected = NotificationSetting.find(:all, :conditions => {:project_id => project[:id]})
    if currently_selected.length == 0 then
      # Mark all fields as checked (default behaviour)
      state.each_index do |t|
        if state[t] then
          state[t].each_key do |c|
            state[t][c] = :checked
          end
        end
      end
    else
      # Mark the checked fields, according to the database
      if currently_selected.length > 0 then
        currently_selected.each do |row|
          if state[row.tracker_id.to_i]
            state[row.tracker_id.to_i][row.field.to_sym] = :checked
          end
        end
      end
    end
      
    {:trackers => trackers, :columns => columns, :custom_columns => custom_columns, \
      :custom_columns_use => custom_columns_use, :state => state}
  end
  
end
