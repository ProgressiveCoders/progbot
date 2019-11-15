# module Zapier
#   class Place < Zapier::Base
#     def call_operation
#       HTTParty.post(ZAP_NEW_SPACE, body: params)
#     end

#     def params
#       { 
#         space_name: resource.name,
#         space_owner: resource.user.email,
#         location: resource.full_address
#       }
#     end
#   end
# end
# example

# class Place < ApplicationRecord
#   belongs_to :user
#   validates :name, :full_address, presence: true
#   after_save :place_to_zapier if Rails.env.production?
  
#   def place_to_zapier
#     Zapier::Place.new(self).post_to_zapier
#   end
# end