require 'skill'
require 'user'

module ApplicationHelper
  def self.queryUsers(skillsList)
    skillIds = Skill.where(name: skillsList).to_a
    return User.
      where(optin: true).
      joins(:skills).
      where(skills: { :id => skillIds })
  end

  def self.queryUsersForProject(project)
    skills = project.skills.to_a
    # remove users already involved with the project
    affiliated_users = project.volunteers.to_a
    affiliated_users.push(project.lead)
    return User.
      where(optin: true).
      where.not(id: affiliated_users)
      joins(:skills).
      where(skills: { :id => skills })
  end
end
