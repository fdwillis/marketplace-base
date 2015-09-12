class TextList < ActiveRecord::Base
  belongs_to :user
  
  protected

    def self.import(file, user)
      numbers = []
      CSV.foreach(file.path, headers: true) do |row|
        row.delete_if {|k, v| v.nil?}
        debugger
        possibles = (row['phone_number'] || row['phone_numbers'] || row['phone number']|| row['phone numbers'])
        if possibles.present? && (possibles).gsub(/[^0-9]/i, '').length >= 10
          numbers << user.text_lists.find_or_create_by(phone_number: (possibles))
        end
      end
      user.text_lists.where(phone_number: nil).destroy_all
      numbers.delete_if{|c| c.phone_number == nil}
      numbers
    end
end
