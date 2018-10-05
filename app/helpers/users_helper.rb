
module UsersHelper
  
  def format_skills(skills = @tech_skills)

    skills.map { |skill| {"id": skill.id, "value": skill.name } }
  end
end
