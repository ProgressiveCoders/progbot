require 'users'

module ApplicationHelper
  def queryUsers(skillsList)
    skillIds = Skills.where(name: skillsList)
    return Users.where(skills: skillIds)
  end
end
