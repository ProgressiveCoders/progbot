
class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  include UserConstants
  include Syncable

  has_secure_token :secure_token

  attr_accessor :tech_skill_names, :non_tech_skill_names, :skip_slack_notification, :skip_push_to_airtable
  belongs_to :referer, class_name: "User", optional: true
  has_and_belongs_to_many :tech_skills, -> { where tech: true }, class_name: "Skill"
  has_and_belongs_to_many :non_tech_skills, -> { where tech: false }, class_name: "Skill"

  has_and_belongs_to_many :skills

  validates_presence_of :name, :email, :location, :hear_about_us, :join_reason
  validates_acceptance_of :read_code_of_conduct

  has_many :volunteerings, dependent: :destroy
  has_many :active_volunteerings, -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :projects, through: :active_volunteerings, source: 'user'

  before_save :push_changes_to_airtable, unless: :skip_push_to_airtable

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

  def self.matching_airtable_attributes
    {
      "Name" => :name,
      "Contact E-Mail" => :email,
      "Join Reason" => :join_reason,
      "Overview" => :overview,
      "Location" => :location,
      "Phone" => :phone,
      "Hear About Us" => :hear_about_us,
      "Verification URLs" => :verification_urls,
      "Gender Pronouns" => :gender_pronouns,
      "Additional Info" => :additional_info,
      "Tech Skills" => :tech_skill_names,
      "Non-Tech Skills and Specialties" => :non_tech_skill_names
    }
  end

  def self.matching_airtable_boolean_attributes 
    {
      "Anonymous" => :anonymous,
      "Read Manifesto" => :read_manifesto,
      "Read Code of Conduct" => :read_code_of_conduct,
      "Optin" => :optin,
      "Is Approved" => :is_approved
    }  
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

  def tech_skill_names
    if self.tech_skills.blank?
      []
    else
      self.tech_skills.map{ |skill| skill.name }
    end
  end


  def tech_skill_names=(skill_names)
    self.tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end

  def non_tech_skill_names
    if self.non_tech_skills.blank?
      []
    else
      self.non_tech_skills.map{ |skill| skill.name }
    end
  end

  def non_tech_skill_names=(skill_names)
    self.non_tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end

  def skill_names_for_display
    self.skills.pluck(:name).sort.join(", ")
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
      AirtableUser.all.detect{|x| x["Record ID"] == self.airtable_id}
    end
  end

  def sync_with_airtable(airtable_user)
    self.skip_push_to_airtable = true

    if self.new_record?
      self.skip_slack_notification = true
    end

    if airtable_user["Tech Skills"].blank?
      self.tech_skill_ids = []
    else
      self.tech_skill_ids = Skill.match_with_airtable(airtable_skills: airtable_user["Tech Skills"], tech: true)
    end

    if airtable_user["Non-Tech Skills and Specialties"].blank?
      self.non_tech_skill_ids = []
    else
      self.non_tech_skill_ids = Skill.match_with_airtable(airtable_skills: airtable_user["Non-Tech Skills and Specialties"], tech: false)
    end


    self.assign_attributes({
      name: airtable_user["Name"],
      email: airtable_user["Contact E-Mail"],
      slack_username: airtable_user["Member Handle"],
      slack_userid: airtable_user["slack_id"],
      optin: airtable_user["Optin"]
    })

    self.is_approved = true

    if self.slack_userid.blank? && self.slack_username.present?
      self.get_slack_userid
    elsif self.slack_userid.present? && self.slack_username.blank?
      self.get_slack_username
    end

    self.save(:validate => false)

    self.skip_push_to_airtable = false
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

  def get_slack_username
    unless self.slack_userid.blank?
      slack_user = SlackHelpers.lookup_by_slack_id(self.slack_userid)
      unless slack_user.blank?
        self.slack_username = slack_user.display_name
        self.save(:validate => false)
      end
    end
  end

  def push_changes_to_airtable

    super do |airtable_user|
      if self.slack_userid.present?
        airtable_user["slack_id"] = self.slack_userid
      end

      if self.slack_username.present?
        airtable_user["Member Handle"] = self.slack_username
      end
    end

  end

end
