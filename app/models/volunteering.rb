class Volunteering < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :project

  audited associated_with: :project
  audited associated_with: :user
  has_associated_audits

  aasm :column => 'state' do
    state :potential, initial: true
    state :signed_up
    state :invited
    state :active
    state :resigned
    state :removed
    state :former
    
    event :apply do
        transitions from: [:potential, :former], to: :signed_up
    end
    
    event :recruit do
        transitions from: [:potential, :former], to: :invited
    end

    event :confirm do
        transitions from: [:signed_up, :invited], to: :active

        transitions from: [:resigned, :removed], to: :former
    end
  end

end