# README

Progbot is a user and project management system for Progressive Coders. Users will be able to register for the site, which will flag admins to review their applications and approve them for site features.
Multiple access levels will be supported, and backup capability to Airtable will enable continued operation if no developers are available.

TO CONTRIBUTE
Clone this repo locally. Run "bundle install" to install the dependencies. Run "rake db:migrate" to install the databases and "rake db:seed" to seed them with test data. Start the server by running "rails s"

The following is a summary of the project goals, intended function, and concerns. To view the more detailed Project Overview, you can find it pinned to the top of the #progbot channel in https://progcode.slack.com

GOALS
Enable site admins to manage users and projects as easily as they do now with airtable.
Present the same skillset for user skills and project needs, and allow registered users to modify these skills.
Save an audit trail with all edits done, whether through the user screens or the admin interface - this is important for tax and legal reasons.
Provide a backup means of administering users, possibly backing up to the original Airtable databases, in case there is a site problem and no developers available to fix it.

SPECIFICATIONS

Workflow
Sign up… /Onboarding
Sign up processed by superadmin
Slack OmniAuth workflow: User signs in with slack
Project manager will enter a project, or edit their existing project
PM will search for users who match the skills
PM will contact users and gauge their suitability
Users will search for projects matching their interests
Will contact PM, who will again gauge suitability
Prog Code Board members will audit use of the app, and read over audit trails, and intervene if necessary

OBSTACLES AND RESTRICTIONS
It is crucial that there be backup developers available in case of life events for the existing team.
All devs should feel free to add issues, test on staging, contribute code to the project or review other devs’ code

INDIVIDUAL TASKS TO COMPLETE
Set up an official Heroku account for the real app
Switch the Slack ‘bot over to the official app
Adapt existing Heroku as dev/staging area
Ensure there is good unit test coverage
Backup database to Airtable
UX design and flow
Create a work queue for board members
Attach screenshots and forms to the Github Issue (create one if it’s not there)

