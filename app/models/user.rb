# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  address1     :text
#  district     :text
#  message      :text
#  province     :text
#  sub_district :text
#  zip_code     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class User < ApplicationRecord
  require "CSV"

  def seperate_message
    self.message.split(" ")

  end

  def generate_csv
    CSV.open("customerAddress.csv", "a+") do |csv|
      if csv.count == 0
        csv << ["Message", "Address1", "Sub-district", "District", "Province", "Zip code"]
      end
      csv << [self.message, self.address1,  self.sub_district, self.district, self.province, self.zip_code]
    end
  end
end
