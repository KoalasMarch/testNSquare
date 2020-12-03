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
  require 'CSV'
  require 'net/http'
  require 'uri'

  after_create :seperate_message

  ADDRESS_DB = JSON.parse( Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/earthchie/jquery.Thailand.js/master/jquery.Thailand.js/database/raw_database/raw_database.json")))

  def get_codes
    User::ADDRESS_DB.map{|x| x["zipcode"]}.uniq
  end

  def seperate_message
    find_zip_code
    find_province
    find_district
    find_sub_district
    self.save

    generate_csv
  end

  def find_zip_code
    self.get_codes.each do |code|
      if self.message.include?(code.to_s)
        self.zip_code = code
      end
    end
  end

  def find_province
    provinces = User::ADDRESS_DB.select{|x| x["zipcode"] == self.zip_code.to_i}
    self.province = provinces.first["province"]
  end

  def find_district
    districts = User::ADDRESS_DB.select{|x| x["province"] == self.province}
    districts.map{|x| x["amphoe"]}.each do |district|
      check = district.include?("เมือง") ? "เมือง" : district
      if self.message.include?(check)
        self.district = district
      end
    end
  end

  def find_sub_district
    sub_districts = User::ADDRESS_DB.select{|x| x["amphoe"] == self.district}
    sub_districts.map{|x| x["district"]}.each do |sub|
      if self.message.include?(sub)
        self.sub_district = sub
      end
    end
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
