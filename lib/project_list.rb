class ProjectList
  def initialize(params)
  end

  def call
    Project.all
  end
end
