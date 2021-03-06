class CausesController < ApplicationController
  load_and_authorize_resource

  def create
    params[:cause][:user_ids] ||= []
		@cause = Cause.new(params[:cause])
    if @cause.save
      user=current_user
      @cause.users << user
      # Handle a successful save.
      flash[:success] = "New Cause has been created"
      redirect_to causes_url
    else
      render 'new'
    end  
	end

  def create_admin
    params[:cause][:user_ids] ||= []
    @cause = Cause.new(params[:cause])
    if @cause.save
      # Handle a successful save.
      flash[:success] = "New Cause has been created"
      redirect_to causes_admin_url
    else
      render 'new_admin'
    end  
  end

  def new
		@cause = Cause.new
    @cause.type = "Single"
  end

  def new_admin
    @cause = Cause.new
  end

  def edit
  	@cause = Cause.find(params[:id])
  end

  def edit_admin
    @cause = Cause.find(params[:id])
  end

  def update
  	@cause = Cause.find(params[:id])
    @cause.updated_by = current_user
  	if @cause.update_attributes(params[:cause])
    		# Handle a successful update.
      	flash[:success] = "Cause updated"
    		redirect_to causes_url
  	else
			render 'edit'
		end
	end

  def update_admin
    @cause = Cause.find(params[:id])
    @cause.updated_by = current_user
    if @cause.update_attributes(params[:cause])
        # Handle a successful update.
        flash[:success] = "Cause updated"
        redirect_to causes_admin_url
    else
      render 'edit_admin'
    end
  end

  def index
    @user = current_user
  	@causes = @user.causes.where(type:"Single").order('name asc').paginate(page: params[:page])
  end

  def index_admin
    @causes = Cause.order('name asc').paginate(page: params[:page])
  end

  def destroy
    Cause.find(params[:id]).destroy
    flash[:success] = "Cause deleted"
    redirect_to causes_url
	end

  def destroy_admin
    Cause.find(params[:id]).destroy
    flash[:success] = "Cause deleted"
    redirect_to causes_admin_url
  end

end
