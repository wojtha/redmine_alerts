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

class AlertsController < ApplicationController
  unloadable
  layout 'base'

  before_filter :authorize
  before_filter :find_alert, :only => [:show, :edit, :update, :destroy]
  before_filter :find_user_projects, :only => [:new, :create, :edit, :update]

  before_filter :set_current_controller
  after_filter :unset_current_controller

  # GET /alerts
  def index
    @alerts = Alert.all
  end

  def list
    # @user = User.current
    @alerts = Alert.find(:all, :conditions => { :author => User.current.id })
  end

  # GET /alerts/1
  def show
  end

  # GET /alerts/new
  def new
    @user = User.current
    @alert = Alert.new(:author => @user)
  end

  # GET /alerts/1/edit
  def edit
    @user = User.current
  end

  # POST /alerts
  def create
    # Prevents NoMethodError in Alerts#create ActionView
    # We need to define here same instance variables as in the Alerts#new
    @user_projects = User.current.projects

    # sanitize empty checkboxes
    params[:alert][:project_ids] ||= []

    @alert = Alert.new(params[:alert])
    @alert.author = User.current

    alert_rule = AlertRule.get_rule(params[:alert][:rule_name])
    @alert.model = alert_rule.entity

    if @alert.save
      flash[:notice] = 'Alert was successfully created.'
      redirect_to(@alert)
    else
      render :action => "new"
    end
  end

  # PUT /alerts/1
  def update
    # Prevents NoMethodError in Alerts#update ActionView
    # We need to define here same instance variables as in the Alerts#edit
    @user_projects = User.current.projects

    # sanitize empty checkboxes
    params[:alert][:project_ids] ||= []

    alert_rule = AlertRule.get_rule(params[:alert][:rule_name])
    @alert.model = alert_rule.entity

    if @alert.update_attributes(params[:alert])
      flash[:notice] = 'Alert was successfully updated.'
      redirect_to(@alert)
    else
      render :action => "edit"
    end
  end

  # DELETE /alerts/1
  def destroy
    @alert.destroy
    redirect_to(alerts_url)
  end


  # =============== PRIVATE METHODS ==================

  private

  # Authorize the user for the requested action
  # overrides ApplicationController.authorize
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, nil, :global => true)
    allowed ? true : deny_access
  end

  def find_alert
    @alert = Alert.find(params[:id], :include => [:projects, :author, :category])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_user_projects
    @user_projects = User.current.projects
  rescue ActiveRecord::RecordNotFound
    render_404
  end


  def set_current_controller
    logger.info "CONTROLLER #{self.controller_name} was set"
    Thread.current[:_current_controller] = controller_name.to_sym
  end

  def unset_current_controller
    logger.info "CONTROLLER: #{controller_name} was unset"
    Thread.current[:_current_controller] = nil
  end


end
