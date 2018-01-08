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
  Skill.create!(name: skill, tech: true)
end

nonTechSkills = ["Activist", "Business Development", "Campaign Experience", "Canvassing", "Community Engagement", "Community Fundraising", "Community Organizing", "Creative Design", "Creative Writing", "Crisis Management", "Customer Service", "Education/Teaching",
"Elected Official", "Event Planning", "Fundraising", "Graphic Design", "Human Resources", "Journalist", "Legal", "Logistics", "Magical Powers", "Marketing", "Non-Profit Experience", "Non-Profit Management", "Phone-Banking", "Political Operative", "Poll-Worker",
"Poverty/Homelessness", "Product Management", "Project Management", "Public Relations", "Researcher", "Social Media Expert", "Volunteer Coordinating", "Volunteer Organizing", "Well Connected", "Editor", "Writer", "Executive Leadership - Non-Profit", "Executive
Leadership - Private Sector", "Organization Building"]

nonTechSkills.each do |skill|
  Skill.create!(name: skill, tech: false)
end

techSkillCategories = [".NET", "ASP.NET", "AWS", "Agile", "Angular.js", "Aphrodite",
    "Apollo", "Aurelia", "Azure", "Babel", "Backbone", "Bootstrap", "C", "C#", "C++",
    "C3", "CSS", "Census Data", "Clojure", "Coffee Script", "Connect", "D3" "Django",
    "Docker", "Droid", "ES-Lint", "ES6", "ETL", "ElasticSearch", "Elixir", "Ember.js",
    "Enzyme", "Express", "Firebase", "Flask", "Forestry.io", "Git", "Go", "GraphQL",
    "HTML", "Hadoop", "Haskell", "Heroku", "IPFS", "Jasmine", "Java", "Javascript",
    "Jekyll", "Kuberneti", "Lua", "MERN", "Materialize", "Minilog", "Minitest", "MobX",
    "Mongo DB", "MySQL", "NationBuilder", "Netlify", "Node Foreman", "Node", "Node.js",
    "Nodemon", "Not Sure Yet", "OSDI", "Objective-C", "Om", "PHP", "Phoenix", "PostgreSQL",
    "Postgres", "Puppet", "Python", "QL", "Qgis", "R", "RSpec", "Radium", "Rails",
    "React Native", "React-router", "React.js", "Redis", "Redux", "Rollbar", "Ruby",
    "Rust", "S3", "SASS", "SPA", "SQL", "SQLte", "Scala", "Shell", "Spring", "Swift",
    "Tableau", "To Be Determined", "Twilio", "Webpak", "WordPress", "iOS", "jQuery",
    "js/Electron"]

techSkillCategories.each do |category|
    SkillCategory.create!(name: category, tech_stack: true)
end

needsCategories = [ "API Dev", "Algorithm", "Alpha Testers", "Back End",
  "Beta Testers", "CMS", "Client Referrals",
 "Coders", "Community Outreach", "Copy Writers", "Data Expert",
 "Data Visualization", "Design", "End Users", "Fiscal Sponsor", "Front End",
 "Funding", "Graphic Designer", "Legal", "MVP", "Map", "Marketing",
 "Navigation", "Open Source Consult", "Organizing Experience", "Payment
 Processing", "Project Management Consult", "Proof Of Concept" "Qa Testing",
 "SEO Optimization", "Social Media", "UI", "UX", "Web Dev",
 "Web Developer", "WordPress"]

 needsCategories.each do |category|
     SkillCategory.create!(name: category, tech_stack: false)
 end
