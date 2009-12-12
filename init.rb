require 'redmine'

# ===== LOAD PATCHES =====
require 'dispatcher'
#require_dependency 'user'
#require_dependency 'project'
#require_dependency 'my_controller'

# Filename of ApplicationController differs among Rails versions less and greater than v2.3
begin
  # Rails >= 2.3 (Redmine 0.9)
  require 'application_controller'
rescue LoadError
  # Rails < 2.3 (Redmine 0.8.x)
  # Quick and dirty fix for 0.8.7 (make sure that session_store.rb gets loaded before ApplicationController)
  session_store = "#{RAILS_ROOT}/config/initializers/session_store.rb"
  if File.exist?(session_store)
    require session_store
  end
  require 'application'
end

# This file loads some associations into the core redmine classes, like associations to alerts
require_dependency 'patch_redmine_classes'

# Monkeypatching - Runtime patches for the redMine core
Dispatcher.to_prepare do
  # Add module to User and Project
  User.__send__(:include, AlertsUserPatch)
  Project.__send__(:include, AlertsProjectPatch)

  # Patch My Page
  MyController.__send__(:include, RedefineConstantPatch)

  # Inject new block to freezed MyController::BLOCKS constant
  new_blocks = MyController::BLOCKS.dup
  new_blocks.merge!('alertreports' => 'My Alert Reports' , 'muhehe' => 'Muhehe')
  new_blocks.freeze
  MyController.redefine_const(:BLOCKS, new_blocks)
end

# ==== REGISTER MODULE ====
# Register plugin to the redMine application
Redmine::Plugin.register :redmine_alerts do
  name 'Redmine Alerts plugin'
  author 'Vojtěch Kusý'
  description 'This is The Alert plugin for Redmine'
  version '0.1.0'

  settings :default => {'purge_archive_interval' => 30}, :partial => 'settings/settings'

  # This permission has to be explicitly given
  project_module :alerts_module do
    permission :manage_alerts, {
      :alerts => [:show, :index, :edit, :update, :new, :create, :destroy],
      :alert_reports => [:show, :index, :list_archived, :archive, :unarchive],
    }
  end

  # Place menu items
  check_alerts_controller = Proc.new do
    # Fixing "return can't jump across threads" error in Ruby
    # You probably have a __return__ statement inside the Proc object, which should be __next__ instead
    # http://perfectionlabstips.wordpress.com/2009/02/13/fixing-return-cant-jump-across-threads-error-in-ruby/
    User.current.alerts_allowed? && ! Thread.current[:_current_controller].nil? && [:alerts, :alert_reports].include?(Thread.current[:_current_controller])
  end
  menu :top_menu, :alert_reports, { :controller => 'alert_reports', :action => 'index' }, :caption => :title_my_alerts, :if => Proc.new { User.current.alerts_allowed? }
  menu :application_menu, :alert_reports, { :controller => 'alert_reports', :action => 'index' }, :caption => :title_my_reports, :if => check_alerts_controller
  menu :application_menu, :alerts, { :controller => 'alerts', :action => 'index' }, :caption => :title_my_alerts,  :if => check_alerts_controller
end

# ==== LOAD ALERT RULES
# Scan through all application paths for /lib/rules directory and load all *.rb files
ActiveSupport::Dependencies.load_paths.select{|lp| lp =~ /\/lib/}.each do |path|
  Dir["#{path}/rules/*.rb"].each do |filename|
    require "rules/#{File.basename(filename)}"
  end
end

#['issue_deadline_alert_rule.rb',
#'issue_time_tracker_alert_rule.rb',
#'user_assigned_issues_alert_rule.rb'].each { |filename| require "rules/#{filename}" }

# ==== DEVELOPMENT ENVIRONMENT RELOAD FIX
# Reload plugin when we are in development mode
# See http://www.spacevatican.org/2008/5/28/reload-me-reload-me-not
#
# Dependencies.load_once_paths.grep /alert/
# => ["C:/Dev/work_rails/redmine-0.8/vendor/plugins/redmine_alerts/app/controllers",
#     "C:/Dev/work_rails/redmine-0.8/vendor/plugins/redmine_alerts/app/helpers",
#     "C:/Dev/work_rails/redmine-0.8/vendor/plugins/redmine_alerts/app/models",
#     "C:/Dev/work_rails/redmine-0.8/vendor/plugins/redmine_alerts/lib"]
#
if (Rails.env == "development") then
  for subpath in ['/app/controllers', '/app/helpers', '/app/models', '/lib']
    ActiveSupport::Dependencies.load_once_paths.delete(File.expand_path(File.dirname(__FILE__)) + subpath)
  end
end

