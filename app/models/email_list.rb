class EmailList < ActiveRecord::Base
  belongs_to :user
  protected

    def self.import(file, user)
      CSV.foreach(file.path, headers: true) do |row|
        user.email_lists.find_or_create_by(email: (row['email'] || row['emails']))
      end
      user.email_lists.where(email: nil).destroy_all
    end
end
