class EmailList < ActiveRecord::Base
  belongs_to :user

  protected
  
    def self.import(file, user)
      CSV.foreach(file.path, headers: true) do |row|
        possibles = row["email"] || row["emails"]
        row.delete_if {|k, v| v.nil?}
        if (possibles).present? && (possibles).include?("@") 
          user.email_lists.find_or_create_by(email: (possibles))
        end
      end
    end
end
