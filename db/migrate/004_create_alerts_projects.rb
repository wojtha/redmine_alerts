class CreateAlertsProjects < ActiveRecord::Migration

#CREATE TABLE `alerts_projects` (
#  `alert_id` INT(11) UNSIGNED NOT NULL,
#  `project_id` INT(11) UNSIGNED NOT NULL,
#  PRIMARY KEY (`alert_id`,`project_id`)
#)

  def self.up
    create_table :alerts_projects, :id => :false do |t|
      t.column :alert_id, :integer
      t.column :project_id, :integer
    end

    add_index(:alerts_projects, [:alert_id, :project_id], :unique => true)
  end

  def self.down
    drop_table :alerts_projects
  end
end