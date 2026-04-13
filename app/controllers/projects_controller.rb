# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  include TaskPayload
  include FilterValidation

  before_action :set_project, only: %i[show update destroy]

  def index
    projects = Project.accessible_to(current_user).order(:created_at)
    render json: { projects: projects.map { |p| project_payload(p) } }
  end

  def show
    render json: project_payload(@project, include_tasks: true)
  end

  def create
    project = current_user.projects.build(project_params)
    if project.save
      render json: project_payload(project), status: :created
    else
      render_validation_failed(project)
    end
  end

  def update
    if @project.update(project_params)
      render json: project_payload(@project)
    else
      render_validation_failed(@project)
    end
  end

  def destroy
    @project.destroy
    head :no_content
  end

  private

  def set_project
    return unless uuid_path_param_valid?(params[:id], :id)

    @project = Project.includes(:tasks).find_by(id: params[:id])
    return render_not_found if @project.nil?

    if action_name == "show"
      return render_forbidden unless @project.accessible_to?(current_user)
    elsif @project.owner_id != current_user.id
      return render_forbidden
    end
  end

  def project_params
    params.permit(:name, :description)
  end

  def project_payload(project, include_tasks: false)
    data = {
      id: project.id,
      name: project.name,
      description: project.description,
      owner_id: project.owner_id,
      created_at: project.created_at.iso8601(3)
    }
    data[:tasks] = project.tasks.order(:created_at).map { |t| task_payload(t) } if include_tasks
    data
  end
end
