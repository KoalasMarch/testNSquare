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

  validate :seperate_message, on: [:create, :update]

  ADDRESS_DB = JSON.parse( Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/earthchie/jquery.Thailand.js/master/jquery.Thailand.js/database/raw_database/raw_database.json")))

  def get_codes
    User::ADDRESS_DB.map{|x| x["zipcode"]}.uniq
  end

  def seperate_message
    @message = self.message
    self.get_codes.each do |code|
      if @message.include?(code.to_s)
        @provinces = User::ADDRESS_DB.select{|x| x["zipcode"] == code}
        self.zip_code = code
        self.province = @provinces.first["province"]
        @amphoe_name = @provinces.map{|x| x["amphoe"]}.uniq
        @amphoe_name.each do |amp|
          if @message.include?(amp)
            self.district = amp
            @amphoes = @provinces.select{|x| x["amphoe"] == amp}
            @sub_district_name = @amphoes.map{|x| x["district"]}.uniq
            @sub_district_name.each do |sub|
              if @message.include?(sub)
                self.sub_district = sub
                self.save
                self.generate_csv
              end
            end
          end
        end
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
