class AddProgcodeGithubProjectLink < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :progcode_github_project_link, :string
    add_column :projects, :mission_aligned, :boolean
    add_column :projects, :flagged, :string, array: true, default: []

  end
end
