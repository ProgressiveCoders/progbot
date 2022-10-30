
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

  # validates_presence_of :name, :email, :location, :hear_about_us, :join_reason
  # validates_acceptance_of :read_code_of_conduct

  has_many :volunteerings, dependent: :destroy
  has_many :active_volunteerings, -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :projects, through: :active_volunteerings, source: 'user'

  before_save :push_changes_to_airtable, unless: :skip_push_to_airtable

  # after_create :send_slack_notification, unless: :skip_slack_notification

  devise :omniauthable, omniauth_providers: [:slack]

  audited
  has_associated_audits

  ransacker :by_flagged, { formatter: proc { |string|
  data = self.flagged_designated(string).map(&:id)
  data = data.present? ? data : nil }, callable:
  proc { |parent|
  parent.table[:id]}}

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = Devise.friendly_token[0,20]
    end
  end

  def self.matching_airtable_attributes
    {
      # ENV["AIRTABLE_USER_NAME_COLUMN"] => :name,
      "Contact E-Mail" => :email,
      # "Join Reason" => :join_reason,
      # "Overview" => :overview,
      # "Location" => :location,
      # "Phone" => :phone,
      # "Hear About Us" => :hear_about_us,
      # "Verification URLs" => :verification_urls,
      # "Gender Pronouns" => :gender_pronouns,
      # "Additional Info" => :additional_info,
      ENV["AIRTABLE_TECH_SKILLS_COLUMN"] => :tech_skill_names,
      ENV["AIRTABLE_NON_TECH_SKILLS_COLUMN"] => :non_tech_skill_names
    }
  end

  def self.matching_airtable_boolean_attributes 
    {
      # "Anonymous" => :anonymous,
      # "Read Manifesto" => :read_manifesto,
      # "Read Code of Conduct" => :read_code_of_conduct,
      # "Optin" => :optin,
      # "Is Approved" => :is_approved
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
    # if self.name == nil || self.name != user_info['profile']['real_name']
    #   self.name = user_info['profile']['real_name']
    # end
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

  # def send_slack_notification
  #   SlackBot.send_message({
  #     channel: "#recruitment",
  #     attachments: [
  #       pretext: 'New User Signup',
  #       title: "A New User Has Signed Up: #{self.name}:::#{self.email}",
  #       title_link: admin_user_url(self, :only_path => false),
  #     ]
  #   })
  # end

  def has_slack?
    self.slack_userid.present? || self.slack_username.present?
  end

  def get_slack_details
    if self.has_slack?
      if self.slack_userid.blank?
        self.get_slack_userid
      elsif self.slack_username.blank?
        self.get_slack_username
      end
    else
      nil
    end
  end

  def admin_label
    if self.slack_username
      self.slack_username
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

  def sync_with_airtable(airtable_user
    # , airtable_table
  )
    self.skip_push_to_airtable = true

    if self.new_record?
      self.skip_slack_notification = true
    end

    if airtable_user[ENV['AIRTABLE_TECH_SKILLS_COLUMN']].blank?
      self.tech_skill_ids = []
    else
      self.tech_skill_ids = Skill.match_with_airtable(airtable_skills: airtable_user[ENV['AIRTABLE_TECH_SKILLS_COLUMN']], tech: true)
    end

    if airtable_user[ENV['AIRTABLE_NON_TECH_SKILLS_COLUMN']].blank?
      self.non_tech_skill_ids = []
    else
      self.non_tech_skill_ids = Skill.match_with_airtable(airtable_skills: airtable_user[ENV['AIRTABLE_NON_TECH_SKILLS_COLUMN']], tech: false)
    end

    self.assign_attributes({
      # name: airtable_user["Name"],
      email: airtable_user["Contact E-Mail"],
      slack_username: airtable_user["Member Handle"],
      slack_userid: airtable_user["slack_id"],
      # optin: airtable_user["Optin"]
      # join_reason: airtable_user["Join Reason"],
      # overview: airtable_user["Overview"],
      # location: airtable_user["Location"],
      # phone: airtable_user["Phone"],
      # hear_about_us: airtable_user["Hear About Us"],
      # verification_urls: airtable_user["Verification URLs"],
      # gender_pronouns: airtable_user["Gender Pronouns"],
      # additional_info: airtable_user["Additional Info"],
      # anonymous: airtable_user["Anonymous"],
      # read_manifesto: airtable_user["Read Manifesto"],
      # read_code_of_conduct: airtable_user["Read Code of Conduct"]
    })

      self.is_approved = true

      if self.email.blank?
        if self.has_slack?
          self.get_email_from_slack
        end
      end

      if self.slack_userid.blank? && self.slack_username.present?
        self.get_slack_userid
      elsif self.slack_userid.present? && self.slack_username.blank?
        self.get_slack_username
      end

    # elsif airtable_table == "admin"
    #   self.assign_attributes({
    #     name: airtable_user["Name"],
    #     read_code_of_conduct: airtable_user["Read Code of Conduct"],
    #     anonymous: airtable_user["I prefer to remain anonymous."],
    #     welcome_email_sent: airtable_user["Welcome E-mail Sent"],
    #     attended_onboarding: airtable_user["Attended Onboarding"],
    #     slack_invite_sent: airtable_user["Slack invite sent?"],
    #     requested_additional_verification: airtable_user["Requested additional verification"],
    #     decline_membership: airtable_user["Declime Membership"],
    #     irs_email_sent: airtable_user["IRS Email Sent"],
    #     internal_notes: airtable_user["Internal Notes"],
    #     contributor: airtable_user["Contributor?"],
    #     email: airtable_user["Contact E-Mail"],
    #     verification_urls: airtable_user["Verification URLs"],
    #     hear_about_us: airtable_user["How did you hear about us?"],
    #     referrer_name: airtable_user["Name of ProgCode member who referred you."],
    #     skills_and_experience: airtable_user["Skills and Relevant Experience (Tech or Non-Tech)"],
    #     join_reason: airtable_user["Bio"],
    #     phone: airtable_user["Phone"],
    #     optin: airtable_user["Opt In to Anonymized Member Directory"],
    #     location: airtable_user["Location"],
    #     read_manifesto: airtable_user["Read Manifesto"]
    #   })

    #   if self.decline_membership
    #     self.is_approved = false
    #   elsif self.welcome_email_sent
    #     self.is_approved = true
    #   end

    # end

    if self.email.present? || self.slack_userid.present?
      all_airtable_users = AirtableUser.all 
      # airtable_table == 'admin' ? AirtableUserFromAdmin.all :

      matches = all_airtable_users.select {|u| (self.email.present? && u["Contact E-Mail"] == self.email) || (self.slack_userid.present? && u["slack_id"] == self.slack_userid)}
      if matches.length > 1
        self.flags << "This user appears more than once in Airtable"
      end
      if self.email.present? && User.where.not(id: self.id).where(email: self.email).present?
        self.flags << "This user's email was left blank because there is already another user in the database with the email address #{self.email}. Please reconcile this issue manually in airtable and progbot"
        self.email = nil
      end
    end

    self.flags.uniq!
    self.save(:validate => false)

    self.skip_push_to_airtable = false
  end

  def get_email_from_slack
    if self.has_slack?
      slack_user = SlackHelpers.lookup_by_slack_id(self.slack_userid || self.get_slack_userid)
      self.email = slack_user.try(:email)
    end
    self.email  
  end

  def get_slack_userid
    if self.email.present?
      slack_user = SlackHelpers.lookup_by_email(self.email.downcase)
    elsif self.slack_username.present?
      slack_user = SlackHelpers.lookup_by_slack_username(self.slack_username.downcase)
    end
    unless slack_user.blank?
      self.slack_userid = slack_user.id
    end
    self.slack_userid
  end

  def get_slack_username
    unless self.slack_userid.blank?
      slack_user = SlackHelpers.lookup_by_slack_id(self.slack_userid)
      unless slack_user.blank?
        self.slack_username = slack_user.display_name
      end
    end
    self.slack_username
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
