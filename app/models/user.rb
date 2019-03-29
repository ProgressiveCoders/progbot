
class User < ApplicationRecord
  attr_accessor :tech_skill_names, :non_tech_skill_names
  belongs_to :referer, class_name: "User", optional: true
  has_and_belongs_to_many :tech_skills, -> { where tech: true }, class_name: "Skill"
  has_and_belongs_to_many :non_tech_skills, -> { where tech: false }, class_name: "Skill"

  validates_presence_of :name, :email, :slack_username, :location, :hear_about_us, :join_reason
  validates_acceptance_of :read_code_of_conduct

  has_many :volunteerings
  has_many :active_volunteerings, -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :projects, through: :active_volunteerings, source: 'user'

  # after_create :send_slack_notification

  devise :omniauthable, omniauth_providers: [:slack]

  audited
  has_associated_audits

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = Devise.friendly_token[0,20]
    end
  end

  def projects
    Project.where 'lead_ids @> ARRAY[?]', self.id
  end

  def update_existing_user(user_info)
    if !self.slack_userid || self.slack_userid != user_info['id']
      self.slack_userid = user_info['id']
      self.slack_username = user_info['profile']['display_name']
    end
    if !self.email != user_info['profile']['email']
      self.email = user_info['profile']['email']
    end
    if self.is_approved != true && self.slack_userid != nil
      self.is_approved = true
    end
    if self.slack_username != user_info['profile']['display_name'] || self.slack_username == ""
      if user_info['profile']['display_name'] != ""
        self.slack_username = user_info['profile']['display_name']
      elsif self.slack_username !=  user_info['profile']['real_name']
        self.slack_username = user_info['profile']['real_name']
      end
    end
    if self.name == nil || self.name != user_info['profile']['real_name']
      self.name = user_info['profile']['real_name']
    end
  end


  def tech_skill_names=(skill_names)
    self.tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end

  def non_tech_skill_names=(skill_names)
    self.non_tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end


  # def send_slack_notification
  #   SlackBot.post_to_recruitment(self)
  # end
end
