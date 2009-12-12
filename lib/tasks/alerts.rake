# redMine - project management software
# Copyright (C) 2009  Vojtech Kusy
# Based on Whining Plugin by Emmanuel Bretelle
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

namespace :redmine do
  namespace :alerts do

    desc "Generate alert reports"
    task :generate_reports  => :environment do
      # task :generate_alerts => :environment do
      # With this ^^^ I was getting Stack Level Too Deep Error
      # Solution found here:
      # http://fowlduck.tumblr.com/post/111607258/ar-sendmail-stack-level-too-deep
      puts "Generating alert reports..."
      Alert.generate_reports_all
    end

    desc "Send reports"
    task :send_reports => :environment do
      puts "Sendning alert reports..."
      require 'alerts_mailer'
      AlertsMailer.send_reports
    end

    desc "Purge old reports"
    task :purge_reports => :environment do
      puts "Purging alert reports..."
      days_before = Setting["plugin_redmine_alerts"]['purge_archive_interval'].to_i
      AlertReport.purge!(days_before)
    end

    desc "Do daily tasks at once: Generate, send new alert reports, after that it purge the old ones"
    task :daily_maintenance => [
      :generate_reports, #1
      :send_reports,     #2
      :purge_reports]    #3

  end
end
