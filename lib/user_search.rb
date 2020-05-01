class UserSearch
  def initialize(params)
    @params = params.fetch(:text).split(/\s*,\s*/).map{|w| "%#{w}%"}
  end

  def call
    User.
      select(:id, :secure_token).
      where(optin: true).
      joins(:skills).
      where("skills.name ILIKE ANY(ARRAY[?])", @params).distinct
  end
end
