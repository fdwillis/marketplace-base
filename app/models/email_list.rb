class EmailList < ActiveRecord::Base
  belongs_to :user

  protected
  
    def self.import(file, user)
      emails = []
      CSV.foreach(file.path, headers: true) do |row|
        possibles = row["email"] || row["emails"]
        row.delete_if {|k, v| v.nil?}
        if (possibles).present? && (possibles).include?("@") 
          emails << user.email_lists.find_or_create_by(email: (possibles))
        end
      end
      user.email_lists.where(email: nil).destroy_all
      emails.delete_if{|c| c.email == nil}
      emails
    end
end
