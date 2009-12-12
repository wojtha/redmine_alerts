# Alerts - A plugin for redMine - project management software
# Copyright (C) 2009 Vojtech Kusy
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class Alert < ActiveRecord::Base
  has_and_belongs_to_many :projects
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :category, :class_name => 'AlertCategory', :foreign_key => 'category_id'

  attr_accessor :rule

  validates_presence_of :model, :category_id, :author
  # skip validation of projects if all_projects is checked
  validates_presence_of :project_ids, :unless => :apply_to_all_projects?
  validates_numericality_of :delta, :allow_nil => true, :message => "Delta must be a number!"

  #def after_initialize
  #  @alert_attributes = {}
  #end

  def before_create
    self.author = User.current
  end

  def apply_to_all_projects?
    self.all_projects == 1
  end

  def generate_reports()
    rule.generate_reports(self)
  end

  def description
    rule.render_description(self)
  end

  protected

  # ActiveRecord callback
  def after_find
    self.rule = AlertRule.get_rule(rule_name)
  end

  # ===== CLASS METHODS =====

  def self.generate_reports_all
    Alert.all.each { |a| a.generate_reports() }
  end
end
