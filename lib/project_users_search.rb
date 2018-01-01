class ProjectUsersSearch
  def initialize(params)
    @project = params.fetch(:project)
  end

  def call
    skills = @project.skills
    # remove users already involved with the project
    affiliated_users = @project.volunteers.to_a
    affiliated_users.push(@project.lead)

    User.
      where(optin: true).
      where.not(id: affiliated_users).
      joins(:skills).
      where(skills: { :id => skills }).
      distinct
  end
end
