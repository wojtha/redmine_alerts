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

class AlertReportsController < ApplicationController
  unloadable
  layout 'base'

  before_filter :authorize, :set_current_controller
  after_filter :unset_current_controller

  def index
    @reports = AlertReport.all(:conditions => ["alert_reports.archived <> 1 AND alerts.author_id = ?", User.current.id], :include => [:alert])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def list_archived
    @reports = AlertReport.all(:conditions => ["alert_reports.archived = 1 AND alerts.author_id = ?", User.current.id], :include => [:alert])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def archive
    @report = AlertReport.find(params[:id])
    @report.archived = 1

    if @report.save
      flash[:notice] = 'Report was archived.'
      redirect_back_or_default :action => :index
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def unarchive
    @report = AlertReport.find(params[:id])
    @report.archived = 0

    if @report.save
      flash[:notice] = 'Report was unarchived.'
      redirect_back_or_default :action => :list_archived
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # =============== PRIVATE METHODS ==================

  private

  # Authorize the user for the requested action
  # overrides ApplicationController.authorize
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.alerts_allowed?
    allowed ? true : deny_access
  end

  def set_current_controller
    Thread.current[:_current_controller] = controller_name.to_sym
  end

  def unset_current_controller
    Thread.current[:_current_controller] = nil
  end

end
