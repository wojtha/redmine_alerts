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

module AlertsHelper

  def collection_user_projects_select
    User.current.projects.collect {|p| [p.name, p.id] }
  end

  def collection_alert_categories_select
    AlertCategory.all.collect {|c| [c.name, c.id] }
  end

  def collection_models_select
    { 'Project' => 'project', 'Milestone' => 'milestone' ,'Task' => 'issue' }
  end

  def collection_fields_select
    { 'Deadline' => 'deadline', 'Expected Time' => 'expected_time', 'Budget' => 'budget' }
  end

  def collection_alert_rules_select
    AlertRule.all.collect {|r| ["#{r.description} [#{r.units}]", r.name] }
  end

  # CustomField::FIELD_FORMAT
  # "string" => { :name => :label_string, :order => 1 },
  # "text"   => { :name => :label_text, :order => 2 },
  # "int"    => { :name => :label_integer, :order => 3 },
  # "float"  => { :name => :label_float, :order => 4 },
  # "list"   => { :name => :label_list, :order => 5 },
  # "date"   => { :name => :label_date, :order => 6 },
  # "bool"   => { :name => :label_boolean, :order => 7 }

end
