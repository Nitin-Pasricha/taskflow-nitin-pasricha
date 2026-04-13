# frozen_string_literal: true

class TasksController < AuthenticatedController
  include TaskPayload
  include FilterValidation

  before_action :set_project_for_nested, only: %i[index create]
  before_action :set_task_for_update, only: :update
  before_action :set_task_for_destroy, only: :destroy

  def index
    if params[:status].present? && Task.statuses.values.exclude?(params[:status])
      render_invalid_filter(:status)
      return
    end
    if params[:assignee].present? && !valid_uuid?(params[:assignee])
      render_invalid_filter(:assignee)
      return
    end

    tasks = @project.tasks.order(:created_at)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(assignee_id: params[:assignee]) if params[:assignee].present?
    render json: { tasks: tasks.map { |t| task_payload(t) } }
  end

  def create
    task = @project.tasks.build(task_params)
    task.creator = current_user
    if task.save
      render json: task_payload(task), status: :created
    else
      render_validation_failed(task)
    end
  end

  def update
    if @task.update(task_update_params)
      render json: task_payload(@task)
    else
      render_validation_failed(@task)
    end
  end

  def destroy
    return render_forbidden unless task_deletable_by_current_user?(@task)

    @task.destroy
    head :no_content
  end

  private

  def set_project_for_nested
    return unless uuid_path_param_valid?(params[:project_id], :project_id)

    @project = Project.find_by(id: params[:project_id])
    return render_not_found if @project.nil?
    return render_forbidden unless @project.accessible_to?(current_user)
  end

  def set_task_for_update
    return unless uuid_path_param_valid?(params[:id], :id)

    @task = Task.find_by(id: params[:id])
    return render_not_found if @task.nil?
    return render_forbidden unless @task.project.accessible_to?(current_user)
  end

  def set_task_for_destroy
    return unless uuid_path_param_valid?(params[:id], :id)

    @task = Task.find_by(id: params[:id])
    return render_not_found if @task.nil?
  end

  def task_deletable_by_current_user?(task)
    task.project.owner_id == current_user.id || task.creator_id == current_user.id
  end

  def task_params
    params.permit(:title, :description, :status, :priority, :assignee_id, :due_date)
  end

  def task_update_params
    params.permit(:title, :description, :status, :priority, :assignee_id, :due_date)
  end
end
