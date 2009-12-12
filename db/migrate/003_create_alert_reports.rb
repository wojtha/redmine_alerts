class CreateAlertReports < ActiveRecord::Migration

  #CREATE TABLE `alert_reports` (
  #  `id` INT(11) NOT NULL AUTO_INCREMENT,
  #  `alert_id` INT(11) NOT NULL,
  #  `entity_id` INT(11) NOT NULL,
  #  `project_id` INT(11) DEFAULT NULL,
  #  `text` TEXT COLLATE utf8_czech_ci,
  #  `archived` TINYINT(1) DEFAULT '0',
  #  `emailed` TINYINT(1) DEFAULT '0',
  #  `created_on` DATETIME DEFAULT NULL,
  #  PRIMARY KEY (`id`)
  #)

  def self.up
    create_table :alert_reports do |t|
      t.column :alert_id, :integer, :null => false
      t.column :entity_id, :integer, :null => false
      t.column :project_id, :integer, :null => false
      t.column :text, :text
      t.column :archived, :boolean, :default => 0
      t.column :emailed, :boolean, :default => 0
      t.column :created_on, :timestamp
    end
  end

  def self.down
    drop_table :alert_reports
  end
end
