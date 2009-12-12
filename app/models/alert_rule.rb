# Alerts - a plugin for redMine - project management software
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

require 'singleton'

module AlertRule

  @@registered_classes = []
  @@rules_by_model = {}
  @@rules = nil
  @@watchable_entities = []

  class << self

    # Register rule class
    def register_rule(klass)
      # TODO: Mandatory nanme of the class "#{short_name}AlertRule"
      raise "Rule #{klass} must include Singleton module." unless klass.included_modules.include?(Singleton)
      @@registered_classes << klass
      @@watchable_entities << klass.entity unless @@watchable_entities.include? klass.entity
      clear_rules_instances
    end

    # Returns rule instance
    def get_rule(short_name)
      Object.const_get("#{short_name}AlertRule").instance
    end

    # Retuens collection of rule instances
    def get_rules_for(entity)
      entity_class = entity.is_a? String ? entity : entity.class;
      @@rules_by_model[entity_class] ||= rules.select {|rule| rule.short_name == entity_class }
    end

    # Returns all registered instances
    def rules
      @@rules ||= @@registered_classes.collect {|rule_class| rule_class.instance}
    end

    # Returns all registered entities which can be watched
    def watchable_entities
      @@watchable_entities
    end

    private

    def clear_rules_instances
      @@rules = nil
      @@rules_by_model = {}
    end

    alias :all :rules

  end

  # AlertRule::Base
  class Base
    include Singleton, ActionController::UrlWriter

    # ===== CLASS METHODS =====

    class << self

      attr_accessor :entity, :description, :units
      private :entity=, :description=, :units=

      # Registers to the AlertRule
      def inherited(child)
        AlertRule.register_rule(child)
        super
      end

      # Default to creating links using only the path.  Subclasses can
      # change this default as needed
      def default_url_options
        {:only_path => true }
      end

    end

    # ===== INSTANCE METHODS =====

    def short_name
      class_name = self.class.to_s
      class_name.sub('AlertRule', '')
    end

    def entity
      self.class.entity
    end

    def description
      self.class.description
    end

    def units
      self.class.units
    end

    # Make query using settings from +alert+ object
    # returns collection
    def query(alert)
    raise "Abstract #{self.class}.query() method must be overriden!"
    end

    def render_description(alert, entity)
    raise "Abstract #{self.class}.description() method must be overriden!"
    end

    def render_report(alert, entity)
    raise "Abstract #{self.class}.render_report() method must be overriden!"
    end

    def generate_reports(alert)
      results = self.query(alert)
      RAILS_DEFAULT_LOGGER.info "Found #{results.length} alert results"
      for result in results
        report = AlertReport.new(
          :entity_id => result.id,
          :alert_id => alert.id,
          :project_id => result.project_id,
          :text => self.render_report(alert, result)
        )
        report.save unless report.already_reported?
      end
    end

    private

    def h(string)
      CGI.escapeHTML(string)
    end

    alias :name :short_name

  end

end
