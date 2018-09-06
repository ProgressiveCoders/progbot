module ProjectConstants
  extend ActiveSupport::Concern

  included do
    OSS_LICENSE_TYPE = [
      "Affero", "Apache 2.0", "GNU AGPL", "GNU GPL v2", "GNU GPL v3", 
      "MIT License", "Not Open Source", "TBD", "cc0 1.0"
    ]
    
    BUSINESS_MODEL = [
      "Ad supported", "Consulting", "Fiscal Sponsor", "Grants", "Institutional Donations", 
      "License", "Looking for Funding", "Microdonations ", "Non-identifiable Data Sales", 
      "None", "Other", "Percentage of fundraising", "SaaS", "Self-Funded", "Subscription", 
      "Voluntary Contributions", "Volunteer", "White Label", "Zero overhead"
    ]
    
    VALUES_SCREENING = [
      "Nonpartisan", "Only progressives", "Open to everyone", 
      "Open to everyone; if TOS violated, users removed", 
      "Open to progressives; if TOS violated, users removed"
    ]

    ORG_STRUCTURE = [
      "Cooperative", "Federated", "Flat Structure", "Grassroots", "None", 
      "Other", "Sociocratic", "To Be Determined", "Traditional"
    ]
    
    LEGAL_STRUCTURE = [
      "501c3", "501c4", "Aktiebolag (AB) [Sweden]", "C Corp", "LLC", 
      "Looking at Non-Profit", "None", "Other", "PAC", "S Corp"
    ]
    
    STATUSES = [
      "Closed", "Closed Testing (Alpha)", "Conceptual Phase", "In Development", 
      "Live!", "MVP", "On Hold", "Open Testing (Alpha/Beta)", "Recruiting", "Working Prototype"
    ]
    
    NEEDS_CATEGORIES = [
      "API Dev", "Algorithm", "Alpha Testers", "Back End", "Beta Testers", "CMS", 
      "Campaign Finance Expert", "Client Referrals", "Coders", "Community Outreach", 
      "Content Creators", "Copy Writers", "Data Analyst", "Data Expert", "Data Visualization", 
      "Database", "Design", "Dev Community", "Electoral Campaign Experience", "End Users", 
      "Fiscal Sponsor", "Front End", "Funding", "Graphic Designer", "Legal", "MVP", "Map", 
      "Marketing", "Mobile Dev", "Navigation", "Node", "Open Source Consult", 
      "Organizing Experience", "Payment Processing", "Political Science Background", 
      "Product Manager", "Project Management Consult", "Qa Testing", "React Native", 
      "SEO Optimization", "Social Media", "Solutions Architect", "Systems Architect", 
      "Taxonomy", "Tech Lead", "To Be Determined", "UI", "UX", "Web Dev", "Web Developer", "WordPress"
    ]
    
    PROJECT_APPLICATIONS = [
      "API", "Activism", "Android", "App Dev", "Auto Dialer", "CTA", "Civic Engagement", 
      "Communication", "Contact Your Rep", "Data Platform", "Database", "Donations Platform", 
      "Education", "Environment", "Event", "File Sharing", "Foodsource Map", "Fundraising", 
      "GOTV", "Help for Homeless", "Independent Media", "Information", "Labor Organizing", 
      "Media", "Medical Care Locator", "Mobile App", "OSS", "Peer to Peer", "Phonebank", 
      "Power Dialer", "Predictive Dialer", "Preview Dialer", "Product Development Method", 
      "Resource Locator", "Science", "Social", "Social Good", "Tech", "Telephony", "Texting", 
      "User Stories", "Voting", "Web App", "Web Dev"
    ]
    
  end
end