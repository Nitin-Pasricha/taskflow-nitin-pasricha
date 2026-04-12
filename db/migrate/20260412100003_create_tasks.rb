# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "todo"
      t.string :priority, null: false, default: "low"
      t.references :project, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :assignee, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.references :creator, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.date :due_date

      t.timestamps
    end

    add_index :tasks, %i[project_id status]
    add_index :tasks, %i[project_id assignee_id]
  end
end
