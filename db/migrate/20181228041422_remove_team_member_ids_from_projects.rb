class RemoveTeamMemberIdsFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :team_member_ids
  end
end
