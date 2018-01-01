class ProjectSearch
  def initialize(params)
    @params = params.fetch(:text).split(/\s*,\s*/)
  end

  def call
    Project.
      joins(:skills).
      where("skills.name ILIKE ANY(ARRAY[?])", @params).distinct
  end
end
