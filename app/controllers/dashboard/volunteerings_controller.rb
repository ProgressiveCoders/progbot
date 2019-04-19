require 'pry'
class Dashboard::VolunteeringsController < Dashboard::BaseController
    inherit_resources

    def index
      @volunteerings = collection.select {|v| v.valid?}
    end

    private

    def begin_of_association_chain
        current_user
    end

end