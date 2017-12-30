class AddTechFlagToSkills < ActiveRecord::Migration[5.1]
  def down
    remove_column :skills, :tech
  end

  def up
    add_column :skills, :tech, :boolean, default: true
    nonTechSkills = ["Activist", "Business Development", "Campaign Experience", "Canvassing", "Community Engagement", "Community Fundraising", "Community Organizing", "Creative Design", "Creative Writing", "Crisis Management", "Customer Service", "Education/Teaching",
    "Elected Official", "Event Planning", "Fundraising", "Graphic Design", "Human Resources", "Journalist", "Legal", "Logistics", "Magical Powers", "Marketing", "Non-Profit Experience", "Non-Profit Management", "Phone-Banking", "Political Operative", "Poll-Worker",
    "Poverty/Homelessness", "Product Management", "Project Management", "Public Relations", "Researcher", "Social Media Expert", "Volunteer Coordinating", "Volunteer Organizing", "Well Connected", "Editor", "Writer", "Executive Leadership - Non-Profit", "Executive
    Leadership - Private Sector", "Organization Building"]

    Skill.reset_column_information
    nonTechSkills.each do |skill|
      Skill.where(name: skill).each {|sk| sk.update_attribute :tech, false}
    end
  end
end
