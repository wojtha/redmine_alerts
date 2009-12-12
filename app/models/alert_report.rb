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

class AlertReport < ActiveRecord::Base
  include AlertReportsHelper

  belongs_to :alert, :include => [:author, :category]
  belongs_to :project

  attr_reader :rule

  validates_uniqueness_of :id, :scope => [:alert_id, :entity_id]

  def already_reported?
    self.class.is_reported(alert_id, entity_id)
  end

  def reported_object
    object_class = Object.const_get(alert.model)
    object_class.find(entity_id)
  end

  def reported_project
    Project.find(project_id)
  end

  def text
    @rule.render_report(alert, reported_object)
  end

  def author
    alert.author
  end

  def sent!
    self.emailed = 1
    self.save
  end

  protected

  # ActiveRecord callback
  def after_find
    @rule = AlertRule.get_rule(alert.rule_name)
  end

  # ==================== CLASS METHODS ========================

  def self.is_reported(alr_id, obj_id)
    AlertReport.all(:conditions => { :alert_id => alr_id, :entity_id => obj_id }).length > 0 ? true : false
  end

  def self.all_to_send
    AlertReport.all(:conditions => ["alert_reports.archived <> 1 AND alert_reports.emailed <> 1"], :include => [:alert])
  end

  def self.purge!(interval)
    reports_to_delete = AlertReport.all(:conditions => ['archived = 1 AND created_on >= ?', interval.days.ago])
    reports_to_delete.each { |report| report.delete }
  end

end
