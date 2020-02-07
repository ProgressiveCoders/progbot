module Artifact
  class BaseController < ApplicationController

    before_filter :deny_access_if_unauthorized, only: [:upload_spreadsheet, :import_data]

    before_action :set_resource, only: [:edit, :update, :show, :destroy, :new]

    before_action :get_colloquialism, only: [:index, :upload_spreadsheet, :import_data]

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    respond_to :html, :json

    helper_method :resource_name
    helper_method :plural_resource_variable
    helper_method :user_ids_who_can_import
    helper_method :artifact_types_that_can_import

    def index
      @per_page = params[:per_page] || 25
      @page = params[:page] || 1
      params[:query] = '' if params[:query] == 'Search'
      @projects = current_user.projects.map{|p| p.ProjectID}
      @total = 0

      if params[:artifacts] != 'my_artifacts'
        resources = resource_class.where("\"ArtifactID\" ilike ?","%#{params[:query]}%")
        @total = resources.count
        @total_pages = @total / @per_page.to_i + 1
        page_of_resources = resources.order('"ArtifactID"').page(params[:page]).per(@per_page)
        instance_variable_set(plural_resource_variable, page_of_resources)
      else
        resources = resource_class.where("\"ArtifactID\" ilike ? and \"EditorIDN\" = ?","%#{params[:query]}%",current_user.editor_id)
        @total = resources.count
        @total_pages = @total / @per_page.to_i + 1
        page_of_resources = resources.order('"ArtifactID"').page(params[:page]).per(@per_page)
        instance_variable_set(plural_resource_variable, page_of_resources)
      end
      respond_with(instance_variable_get(plural_resource_variable))
    end

    def create
      set_resource(resource_class.new(resource_params))
      get_resource.EditorIDN = current_user.editor_id
      get_instance_variables
      anchor = (params[:active_tag] != nil and params[:active_tag] != '') ? params[:active_tag].gsub('#','') : ''

      if get_resource.save
        activity = Activity.create(:user => current_user, :controller => params[:controller].gsub("artifact/",""), :action => params[:action], :object_id => get_resource.id, :activity => "Created #{get_resource.ArtifactID}")

        respond_to do |format|
          format.html { redirect_to send("edit_#{resource_name}_path", get_resource, anchor: anchor), notice: "#{resource_name.titleize} was successfully created" }
          format.json { render json: get_resource, status: :created, location: get_resource }
        end
      
      else
        puts " ==========================#{get_resource.errors}"
        respond_to do |format|
          format.html { render 'new', notice: 'problems' }
          format.json { render json: get_resource.errors, status: :unprocessable_entity }
        end
      end
    end

    def new
      if params[:context_sample] != nil
        gca = GenerateContextArtifact.create(:ContextSampleID => params[:context_sample], :ArtifactID => '0')
        get_resource.generate_context_artifact = gca
      end
      get_instance_variables
      yield(get_resource) if block_given?
      respond_with(get_resource)
    end

    def show
      respond_with(get_resource)
    end

    def edit
      yield(get_resource) if block_given?
      get_instance_variables
    end

    def update
      get_resource.EditorID = current_user.editor_id
      get_instance_variables
      anchor = (params[:active_tag] != nil and params[:active_tag] != '') ? params[:active_tag].gsub('#','') : ''

      if get_resource.update(resource_params)
        activity = Activity.create(:user => current_user, :controller => params[:controller].gsub("artifact/",""), :action => params[:action], :object_id => get_resource.id, :activity => "Updated #{get_resource.ArtifactID}")

        respond_to do |format|
          format.html { redirect_to send("edit_#{resource_name}_path", get_resource, anchor: anchor), notice: "#{resource_name.titleize} was successfully updated" }
          format.json { head :no_content }
        end
      
      else
        puts " ==========================#{get_resource.errors}"
        respond_to do |format|
          format.html { render 'edit', notice: 'problems' }
          format.json { render json: get_resource.errors, status: :unprocessable_entity }
        end
      end
    end

    def duplicate
      orig = resource_class.find(params[:id])
      gca = GenerateContextArtifact.new
      gca.ArtifactID = '0'
      gca.context_sample = orig.context_sample
      gca.save

      instance_variable_set(resource_variable, resource_class.new)
      get_resource.Quantity = orig.Quantity
      get_resource.generate_context_artifact = gca
      get_resource.GenerateContextArtifactID = get_resource.generate_context_artifact.id
      get_resource.EditorIDN = current_user.editor_id
      get_resource.ArtifactID = ' - '

      get_instance_variables

      yield(get_resource, orig) if block_given?

      render :new
    end

    def destroy
      activity = Activity.create(:user => current_user, :controller => params[:controller].gsub("artifact/",""), :action => params[:action], :object_id => get_resource.id, :activity => "Deleted #{get_resource.ArtifactID}")
      get_resource.destroy

      respond_to do |format|
        format.js { render :text => 'success'}
        format.html { redirect_to send("#{controller_name}_path") }
        format.json { head :no_content }
      end
    end

    def artifact_ids
      resources = resource_class.select('"ArtifactID"','"GenerateContextArtifactID"').where(['"ArtifactID" ilike ?',"%#{params[:q]}%"]).limit(10).order('"ArtifactID"')
      instance_variable_set(plural_resource_variable, resources)
      respond_to do |format|
        format.json { render json: instance_variable_get(plural_resource_variable)}
      end
    end

    def upload_spreadsheet
      if Rails.cache.read("artifacts")
        Rails.cache.delete("artifacts")
      end
      #right now only implemented for bones and gen_artifacts
    end

    def import_data
      sheet = SpreadsheetHelpers.open_file(params[:file])
      if sheet
        @attributes = "GlobalConstant::Import::#{resource_name.upcase}_ATTRIBUTES".constantize
        @artifacts = []
        header = sheet.row(1)
        @errors = []
        (2..sheet.last_row).each do |index|
          row = Hash[[header, sheet.row(index)].transpose]
          normalized_context_sample_id = row['ContextSampleID'].gsub('--', '-;')
          if !ContextSample.exists?(:ContextSampleID => normalized_context_sample_id)
            @errors << "Row #{index}: There is no Context Sample with a ContextSampleID of #{normalized_context_sample_id}"
          elsif !row['EditorIDN'].present?
            @errors << "Row #{index} is missing an EditorIDN"
          elsif !User.exists?(:id => row['EditorIDN'])
            @errors << "For 'EditorIDN', there is no User with an ID of #{row['EditorIDN'].to_i}"
          else
            gca = GenerateContextArtifact.new(:ContextSampleID => normalized_context_sample_id, :ArtifactID => '0')

            artifact = resource_class.new(:EditorIDN => row['EditorIDN'], :Quantity => row['Quantity'].present? ? row['Quantity'].to_i : nil)

            artifact.generate_context_artifact = gca

            yield(row, artifact, index) if block_given?

            artifact.validate

            if !artifact.valid?
              @errors << "Row #{index}: #{artifact.errors.full_messages.to_sentence}"
            else
              @artifacts << artifact
            end
          end
        end

        if @errors.any?
          render "artifact/base/import_errors"
        else
          @title = get_title
          @artifacts.each do |artifact|
            
          end
          Rails.cache.write("artifacts", @artifacts)
          render "artifact/base/confirmation"
        end
      else
        render "artifact/base/session_expired"
      end
    end

    def bulk_create
      @artifacts = Rails.cache.read("artifacts")
      if @artifacts
        @artifacts.each do |artifact|
          gca = artifact.generate_context_artifact
          gca.save!
          artifact.id = gca.id
          artifact.save!
        end

        Rails.cache.delete("artifacts")
        @attributes = ["ArtifactID", "GenerateContextArtifactID"] + "GlobalConstant::Import::#{resource_name.upcase}_ATTRIBUTES".constantize - ["ContextSampleID"]
        @title = get_title

        render "artifact/base/bulk_create"
      else
        render "artifact/base/session_expired"
      end
    end

    protected

    def not_found
      render json: {message: 'Not found'}, status: :not_found
    end

    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    def set_resource(resource=nil)
      if params[:id]
        resource ||= resource_class.find(params[:id])
        instance_variable_set(resource_variable, resource)
      else
        resource ||= resource_class.new
        instance_variable_set(resource_variable, resource)
      end
    end

    def plural_resource_variable
      "@#{resource_name.pluralize}"
    end

    def resource_variable
      "@#{resource_name}"
    end

    def get_resource
      instance_variable_get(resource_variable)
    end

    def get_title
      if resource_name == 'gen_artifact'
        @title = 'general artifact'
      elsif resource_name == 'bone'
        @title = 'faunal'
      elsif resource_name == 'ceramic' && params[:scope] == 'coarse_earthenware'
        @title = 'ceramic (coarse earthenware)'
      else
        @colloquialism = resource_name.gsub("_", " ")
      end
    end

    def get_colloquialism
      if resource_name == 'gen_artifact'
        @colloquialism = 'general artifact'
      elsif resource_name == 'bone'
        @colloquialism = 'faunal'
      else
        @colloquialism = resource_name.gsub("_", " ")
      end
    end

    def get_database_level
      if controller_name == 'ceramics'
        if params[:scope] == 'coarse_earthenware' || get_resource.is_coarse_earthenware?
          get_resource.context_sample.project.send('coarse_earthenwares_level')
        else
          get_resource.context_sample.project.send("#{controller_name}_level")
        end
      else
        get_resource.context_sample.project.send("#{controller_name}_level")
      end
    end

    def get_instance_variables
      @gen_objects = GenObject.limit(100).order(:ObjectID)
      @colloquialism = get_colloquialism
      @title = get_title
      if get_resource.context_sample != nil
        context_sample = get_resource.context_sample
        @in_context = resource_class.joins(:context_sample).where("\"tblContextSample\".\"ContextSampleID\" = ?", context_sample.ContextSampleID).order('"ArtifactID"')
        database_level = get_database_level 
        @level = ["Gold", "Silver", "Bronze"].include?(database_level) ? database_level : "Gold"
        @image_subtype = classify_image_subtype
        image_subtypes = ImageSubtype.where(:ImageSubtype => @image_subtype).map {|i| i.ImageSubtypeID}
        @project_id = context_sample.project.ProjectID
        @project_name = context_sample.project.project_name
        @context_sample_id = context_sample.ContextSampleID
        @images = Image.joins(:projects).where('"ImageSubtypeID" in (?) and "tblProject"."ProjectID" = ?', image_subtypes, @project_id).limit(100).order('"DateAdded" desc')
      else
        @in_context = []
        @level = nil
        @project_id = nil
        @project_name = nil
        @context_sample_id = nil
      end
    end

    def classify_image_subtype
      if resource_name == 'gen_artifact'
        'All Other Artifacts'
      elsif resource_name == 'tobacco_pipe'
        'Tobacco Pipes'
      elsif resource_name == 'utensil'
        'Utensils'
      elsif resource_name == 'bone'
        'Faunal'
      elsif resource_name == 'lithic'
        'Lithics'
      else
        resource_name.classify
      end
    end

    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    def user_ids_who_can_import
      constants::USER_IDS_WHO_CAN_IMPORT
    end

    def artifact_types_that_can_import
      constants::ARTIFACT_TYPES_THAT_CAN_IMPORT
    end

    private

    def constants
      GlobalConstant::Import
    end
  
    def deny_access_if_unauthorized
      redirect_to send("#{controller_name}_path") unless artifact_types_that_can_import.include?(controller_name) && user_ids_who_can_import.include?(current_user.id)
    end

  end


end