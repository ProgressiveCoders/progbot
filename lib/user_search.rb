class UserSearch
  def initialize(params)
    @params = params.fetch(:text).split(/\s*,\s*/).map{|w| "%#{w}%"}
  end

  def call
    User.
      select(:id, :email, :slack_username, :slack_userid).
      where(optin: true).
      joins(:skills).
      where("skills.name ILIKE ANY(ARRAY[?])", @params).distinct
  end
end
