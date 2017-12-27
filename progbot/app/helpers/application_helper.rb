require 'skill'
require 'user'

module ApplicationHelper
  def queryUsers(skillsList)
    skillIds = Skill.where(name: skillsList).to_a
    return User.
      where(optin: true).
      joins(:skills).
      where(skills: { :id => skillIds })
  end

  def queryUsersForProject(project)
    skills = project.skills
    return User.
      where(optin: true).
      joins(:skills).
      where(skills: { :id => skills })
  end
end
