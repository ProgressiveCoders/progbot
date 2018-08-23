# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' },  { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke',  movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

techSkills = [".NET", "Agile", "Android", "Angular.js", "Aphrodite", "API", "Apollo", "App Development", "ASP.NET", "Aurelia", "AWS", "Azure", "Babel", "Back-End", "Backbone",  "Block-Chain Tech", "Bootstrap", "C", "C#", "C++", "C3", "Census Data", "Clojure", "Coffee Script", "Computer Hardware","Connect", "CSS", "D3", "Data Analyst", "Data Migration", "Data Science", "Dev Ops", "Django", "Docker", "Docker Compose", "Droid", "Drupal", "E-Mail", "ElasticSearch", "Elixir", "Ember.js", "Enzyme", "ES-lint", "ES6", "ETL", "Express", "Firebase", "Flask", "Forestry.io", "Front-End","Full-Stack", "Git", "Go", "GraphQL", "Hacker", "Hadoop", "Haskell", "Heroku", "HTML", "HTML5", "Information Architecture","iOS", "IPFS", "Jasmine", "Java", "Javascript", "Jekyll", "jQuery", "js/Electron", "Kuberneti", "Lua", "Machine Learning", "Materialize", "MERN", "Minilog", "Minitest", "Mobile Dev", "MobX", "Mongo DB", "MySQL", "NationBuilder", "Netlify", "Network Admin", "Node.js", "Node Foreman", "Nodemon", "Not Sure Yet", "Objective-C", "OM", "Oracle12c", "OSDI", "Phoenix", "PHP", "Pollster", "PostgreSQL", "Puppet", "Python", "Qgis", "QL", "R", "Radium", "React-router", "React.js", "React Native", "Redis", "Redux", "Rollbar", "RSpec", "Ruby", "Ruby on Rails", "Rust", "S3", "SASS", "Scala", "Shell", "Signal", "Sinatra", "SMS", "Social Media Management", "Spa", "Spring", "SQL", "SQLite", "Swift", "Tableau", "Tech Support", "To Be Determined", "Twilio", "Web Apps", "Web Design", "Web Infrastructure", "Web Scraping", "Webpak", "Wordpress", "Wordpress Multi-Site", "xamarin"]

techSkills.each do |skill|
  Skill.create!(name: skill, tech: true)
end

nonTechSkills = ["Activist", "Business Development", "Campaign Experience", "Canvassing", "Community Engagement", "Community Fundraising", "Community Organizing", "Creative Design", "Creative Writing", "Crisis Management", "Customer Service", "Education/Teaching",
"Elected Official", "Event Planning", "Fundraising", "Graphic Design", "Human Resources", "Journalist", "Legal", "Logistics", "Magical Powers", "Marketing", "Non-Profit Experience", "Non-Profit Management", "Phone-Banking", "Political Operative", "Poll-Worker",
"Poverty/Homelessness", "Product Management", "Project Management", "Public Relations", "Researcher", "Social Media Expert", "Volunteer Coordinating", "Volunteer Organizing", "Well Connected", "Editor", "Writer", "Executive Leadership - Non-Profit", "Executive
Leadership - Private Sector", "Organization Building"]

nonTechSkills.each do |skill|
  Skill.create!(name: skill, tech: false)
end
