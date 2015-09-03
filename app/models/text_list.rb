class TextList < ActiveRecord::Base
  belongs_to :user
  def self.import(file, user)
  	CSV.foreach(file.path, headers: true) do |row|
  		debugger
	  	user.text_lists.find_or_create_by(phone_number: row['phone_number'])
	  end
  end
end
