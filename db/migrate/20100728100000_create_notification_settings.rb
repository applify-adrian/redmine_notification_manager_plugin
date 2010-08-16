class CreateNotificationSettings < ActiveRecord::Migration

  def self.up
    create_table :notification_settings do |t|

      t.column :project_id, :integer, :null => false

      t.column :tracker_id, :integer, :null => false

      t.column :field, :string, :null => false

    end
  end

  def self.down
    drop_table :notification_settings
  end
end
