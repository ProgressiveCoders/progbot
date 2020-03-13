
class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  include UserConstants

  attr_accessor :tech_skill_names, :non_tech_skill_names, :skip_slack_notification
  belongs_to :referer, class_name: "User", optional: true
  has_and_belongs_to_many :tech_skills, -> { where tech: true }, class_name: "Skill"
  has_and_belongs_to_many :non_tech_skills, -> { where tech: false }, class_name: "Skill"

  has_and_belongs_to_many :skills

  validates_presence_of :name, :email, :location, :hear_about_us, :join_reason
  validates_acceptance_of :read_code_of_conduct

  has_many :volunteerings, dependent: :destroy
  has_many :active_volunteerings, -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :projects, through: :active_volunteerings, source: 'user'

  after_create :send_slack_notification, unless: :skip_slack_notification

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

  def relevant_volunteerings
    self.volunteerings.select { |v| v.relevant? }
  end

  def send_slack_notification
    SlackBot.send_message({
      channel: "#recruitment",
      attachments: [
        pretext: 'New User Signup',
        title: "A New User Has Signed Up: #{self.name}:::#{self.email}",
        title_link: admin_user_url(self, :only_path => false),
      ]
    })
  end

  def admin_label
    if self.slack_username
      self.slack_username
    elsif self.name
      self.name
    elsif self.slack_userid
      self.slack_userid
    end
  end

  def anonymized_handle
    if self.slack_username
      self.slack_username
    else
      self.id.to_s
    end
  end

  def airtable_twin
    if self.airtable_id.present?
      AirtableUser.all(filter: "{Record ID} = #{self.airtable_id}").first
    end
  end

  def sync_with_airtable(airtable_user)
    if self.new_record?
      self.skip_slack_notification = true
    end

    tech_skills = Skill.where(name: airtable_user["Tech Skills"], tech: true)
    non_tech_skills = Skill.where(name: airtable_user["Non-Tech Skills and Specialties"], tech: false)
    self.assign_attributes(
      tech_skills: tech_skills,
      non_tech_skills: non_tech_skills, name: airtable_user["Name"],
      email: airtable_user["Contact E-Mail"],
      slack_username: airtable_user["Member Handle"],
      optin: true, is_approved: true
    )
    self.save(:validate => false)
    self.get_slack_userid
  end

  def get_slack_userid
    unless self.email.blank? || self.slack_userid.present?
      slack_user = SlackHelpers.lookup_by_email(self.email.downcase)
      unless slack_user.blank?
        self.slack_userid = slack_user.id
        self.save(:validate => false)
      end
    end
  end

end
