class Volunteering < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :project

  validates :project, presence: true
  validates :user, presence: true

  validates_uniqueness_of :user_id, :scope => :project_id, :message => "User can only volunteer once per project"

  audited associated_with: :project
  audited associated_with: :user

  attr_accessor :event

  # after_save :send_slack_notification

  aasm :column => 'state' do
    state :potential, initial: true
    state :signed_up
    state :invited
    state :active
    state :former
    
    event :set_active do
      transitions from: [:potential, :signed_up, :invited, :resigned, :removed, :former], to: :active, guard: :application_override?
    end

    event :set_former do
      transitions from: [:active, :signed_up, :invited, :active, :resigned, :removed], to: :former, guard: :application_override?
    end
    
    event :apply do
        transitions from: [:potential, :former], to: :signed_up, guard: :user_is_not_lead?
    end
    
    event :recruit do
        transitions from: [:potential, :former], to: :invited, guard: :user_is_lead?
    end

    event :withdraw do
      transitions from: [:signed_up, :invited], to: :potential, guard: :user_can_withdraw?
    end

    event :confirm, guard: :user_can_confirm? do
        transitions from: [:signed_up, :invited], to: :active
    end

    event :leave do
      transitions from: :active, to: :former, guard: :user_is_volunteer?
    end

    event :remove do
      transitions from: :active, to: :former, guard: :user_is_lead?
    end

  end

  def application_override?(key)
    key == ENV['AASM_OVERRIDE']
  end

  def user_is_not_lead?(user)
    !self.project.leads.include?(user) and user.is_a? User
  end

  def user_is_lead?(user)
    self.project.leads.include?(user)
  end

  def user_is_volunteer?(user)
    user == self.user
  end

  def user_can_withdraw?(user)
    if self.signed_up?
      user_is_volunteer?(user)
    elsif self.invited?
      user_is_lead?(user)
    end
  end

  def user_can_confirm?(user)
    if self.signed_up?
      user_is_lead?(user)
    elsif self.invited?
      user_is_volunteer?(user)
    end
  end

  def self.get_volunteering_id(project, user)
    volunteering = Volunteering.find_by(:project_id => project.id, :user_id => user.id)

    volunteering.id
  end

  def relevant?
    ['signed_up', 'invited', 'active'].include?(self.state)
  end

  def send_slack_notification
    SlackBot.send_to_channel(self)
  end


end