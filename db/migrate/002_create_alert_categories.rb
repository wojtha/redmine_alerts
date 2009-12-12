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

    AlertCategory.create :name => "Varování"
    AlertCategory.create :name => "Poplach"
  end

  def self.down
    drop_table :alert_categories
  end
end
