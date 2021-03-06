class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy, :accept, :decline]

  skip_authorization_check only: [:index, :show]

  # GET /organizations
  def index
    @organizations = Organization.accepted_organizations
  end

  # GET /organizations/1
  def show
  end

  # GET /organizations/new
  def new
    authorize! :create, :organization
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
    authorize! :edit, @organization
  end

  # POST /organizations
  def create
    authorize! :create, :organization
    @organization = Organization.init(organization_params, current_user)

    if !@organization.errors.any?
      redirect_to @organization, notice: 'Organization was successfully requested.'
    else
      render :new
    end
  end

  # PATCH/PUT /organizations/1
  def update
    authorize! :edit, @organization
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /organizations/1
  def destroy
    authorize! :destroy, @organization
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully destroyed.'
  end

  def list_requests
    authorize! :view, :organization_requests
    @requested_organizations = Organization.pending_organizations
  end

  def accept
    authorize! :accept, :organization_requests
    if @organization.acceptance_pending
      @organization.acceptance_pending = false
      @organization.accepted_at = DateTime.now
      @organization.save
      redirect_to list_requests_organizations_path, notice: 'Organization request was successfully accepted.'
    else
      redirect_to organizations_path
    end
  end

  def decline
    authorize! :decline, :organization_requests
    if @organization.acceptance_pending
      @organization.delete
      redirect_to list_requests_organizations_path, notice: 'Organization request was successfully rejected.'
    else
      redirect_to organizations_path
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find_by_slug(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def organization_params
    params.require(:organization).permit(:name, :information, :slug)
  end
end
