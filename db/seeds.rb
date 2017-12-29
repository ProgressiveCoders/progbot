# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' },  { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke',  movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

techSkills = [".NET", "Angular", "API", "App Development", "AWS", "Back-End", "Block-Chain Tech", "C", "C#", "C++", "Clojure", "Computer Hardware", "CSS", "Data Analyst", "Data Migration", "Data Science", "Dev Ops", "Django", "Docker", "Droid", "Drupal", "E-Mail",
"Elixir", "Ember", "Front-End", "Full-Stack", "Go", "Hacker", "Haskell", "Heroku", "Information Architecture", "iOS", "Java", "JavaScript", "jQuery", "Kuberneti", "Machine Learning", "Mobile Dev", "Mongo DB", "My SQL", "Network Admin", "Node.JS", "Objective-C",
"Oracle12c", "Phoenix", "PHP", "Pollster", "Python", "Rails", "React", "Ruby", "Rust", "Social Media Management", "SQLite", "Swift", "Tech Support", "Web Apps", "Web Design", "Web Development", "Web Infrastructure", "Web Scraping", "Windows", "Wordpress"]

techSkills.each do |skill|
  Skill.create!(name: skill)
end

nonTechSkills = ["Activist", "Business Development", "Campaign Experience", "Canvassing", "Community Engagement", "Community Fundraising", "Community Organizing", "Creative Design", "Creative Writing", "Crisis Management", "Customer Service", "Education/Teaching",
"Elected Official", "Event Planning", "Fundraising", "Graphic Design", "Human Resources", "Journalist", "Legal", "Logistics", "Magical Powers", "Marketing", "Non-Profit Experience", "Non-Profit Management", "Phone-Banking", "Political Operative", "Poll-Worker",
"Poverty/Homelessness", "Product Management", "Project Management", "Public Relations", "Researcher", "Social Media Expert", "Volunteer Coordinating", "Volunteer Organizing", "Well Connected", "Editor", "Writer", "Executive Leadership - Non-Profit", "Executive
Leadership - Private Sector", "Organization Building"]

nonTechSkills.each do |skill|
  Skill.create!(name: skill)
end
