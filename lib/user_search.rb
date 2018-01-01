class UserSearch
  def initialize(params)
    @params = params.fetch(:text).split(/\s*,\s*/)
  end

  def call
    User.
      where(optin: true).
      joins(:skills).
      where("skills.name ILIKE ANY(ARRAY[?])", @params).distinct
  end
end
