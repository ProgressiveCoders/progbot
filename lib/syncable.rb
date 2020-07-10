module Syncable

  def push_changes_to_airtable
    class_name = self.class.name
    all_airtable_objects = "Airtable#{class_name}".constantize.all

    airtable_object = self.airtable_id.present? && all_airtable_objects.detect{|x| x.id == self.airtable_id}.present? ? all_airtable_objects.detect{|x| x.id == self.airtable_id} : "Airtable#{class_name}".constantize.new({})

    class_name.constantize.matching_airtable_attributes.each do |airtable_name, progbot_name|
      airtable_object[airtable_name] = self.send(progbot_name)
      end

    #this has something to do with airtable api weirdness with boolean - i believe values can only ever be true not false
    class_name.constantize.matching_airtable_boolean_attributes.each do |airtable_name, progbot_name|
      if self.send(progbot_name)
        airtable_object[airtable_name] = true
      end
    end

    yield(airtable_object) if block_given?

    airtable_object.save(typecast: true)
    self.airtable_id = airtable_object.id

  end


  def cast_string_to_boolean(string)
    ActiveModel::Type::Boolean.new.cast(string)
  end

  
end