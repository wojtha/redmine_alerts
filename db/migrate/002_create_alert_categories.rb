class CreateAlertCategories < ActiveRecord::Migration

#CREATE TABLE `alert_categories` (
#  `id` INT(11) NOT NULL AUTO_INCREMENT,
#  `name` VARCHAR(255) COLLATE utf8_czech_ci DEFAULT NULL,
#  `color` VARCHAR(6) COLLATE utf8_czech_ci DEFAULT NULL,
#  PRIMARY KEY (`id`)
#)

  def self.up
    create_table :alert_categories do |t|
      t.column :name, :string, :default => ""
      t.column :color, :string, :limit => 6, :default => ""
    end

    AlertCategory.create :name => "Alert", :color => "FF0000"
    AlertCategory.create :name => "Warning", :color => "FF8C00"
    AlertCategory.create :name => "Notice", :color => "3399CC"
  end

  def self.down
    drop_table :alert_categories
  end
end
