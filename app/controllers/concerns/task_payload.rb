# frozen_string_literal: true

module TaskPayload
  extend ActiveSupport::Concern

  private

  def task_payload(task)
    {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      project_id: task.project_id,
      assignee_id: task.assignee_id,
      creator_id: task.creator_id,
      due_date: task.due_date&.iso8601,
      created_at: task.created_at.iso8601(3),
      updated_at: task.updated_at.iso8601(3)
    }
  end
end
