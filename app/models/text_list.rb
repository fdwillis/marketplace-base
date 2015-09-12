class TextList < ActiveRecord::Base
  belongs_to :user
  
  protected

    def self.import(file, user)
      CSV.foreach(file.path, headers: true) do |row|
        row.delete_if {|k, v| v.nil?}
        possibles = (row['phone_number'] || row['phone_numbers'] || row['phone number']|| row['phone numbers'])
        if possibles.present? && (possibles).gsub(/[^0-9]/i, '').length >= 10
          user.text_lists.find_or_create_by(phone_number: (possibles))
        end
      end
    end
end
