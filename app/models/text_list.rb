class TextList < ActiveRecord::Base
  belongs_to :user
  
  protected

    def self.import(file, user)
    	CSV.foreach(file.path, headers: true) do |row|
        user.text_lists.find_or_create_by(phone_number: (row['phone_number'] || row['phone_numbers'] || row['phone number']|| row['phone numbers']))
      end
      user.text_lists.where(phone_number: nil).destroy_all
    end
end
