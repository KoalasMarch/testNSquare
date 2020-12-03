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
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
