class AlertCategoriesController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_category, :only => [:edit, :update, :destroy]
  before_filter :find_all_categories, :only => [:index]

  def index
  end

  def new
    @category = AlertCategory.new
  end

  def create
    @category = AlertCategory.new(params[:alert_category])

    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end

  def edit
  end

  def update
    logger.info params.inspect
    if @category.is_builtin?
      flash[:notice] = 'Built-in class can\'t be updated.'
      redirect_to :action => 'index'
    elsif @category.update_attributes(params[:alert_category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end

  def destroy
    unless @category.is_builtin?
      flash[:notice] = 'Built-in class can\'t be deleted.'
      redirect_to :action => 'index'
    end
  end

  # =============== PRIVATE METHODS ==================

  private

  def find_category
    @category = AlertCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_all_categories
    @categories = AlertCategory.all
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
