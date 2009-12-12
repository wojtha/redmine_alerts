class CreateAlerts < ActiveRecord::Migration

#CREATE TABLE `alerts` (
#  `id` INT(11) NOT NULL AUTO_INCREMENT,
#  `category_id` INT(11) DEFAULT NULL,
#  `field` VARCHAR(255) COLLATE utf8_czech_ci DEFAULT NULL,
#  `rule_name` VARCHAR(255) COLLATE utf8_czech_ci DEFAULT NULL,
#  `delta` INT(11) DEFAULT NULL,
#  `author_id` INT(11) DEFAULT NULL,
#  `all_projects` INT(11) DEFAULT NULL,
#  `created_on` DATETIME DEFAULT NULL,
#  `updated_on` DATETIME DEFAULT NULL,
#  PRIMARY KEY (`id`)
#)

  def self.up
    create_table :alerts do |t|
      t.column :category_id, :integer, :null => false
      t.column :model, :string, :limit => 64, :null => false
      t.column :rule_name, :string, :limit => 64, :null => false
      t.column :author_id, :integer, :null => false
      t.column :delta, :integer, :default => 0
      t.column :all_projects, :boolean, :default => 0
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end
  end

  def self.down
    drop_table :alerts
  end
end