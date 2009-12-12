# redMine - project management software
# Copyright (C) 2009  Vojtech Kusy
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

require "mailer"

class AlertsMailer < Mailer

  def alert_reports(user, reports)
    set_language_if_valid user.language
    recipients user.mail
    subject "Alert Reports #{reports.size}"
    body :reports => reports,
         :reports_url => url_for(:controller => 'alert_reports', :action => 'index')
  end

  def self.send_reports
    reports_by_user = AlertReport.all_to_send().group_by(&:author)
    reports_by_user.each do |user, reports|
      deliver_alert_reports(user, reports) unless user.nil?
      reports.each { |r| r.sent! }
    end
  end
end