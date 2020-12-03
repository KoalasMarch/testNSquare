class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.text :message
      t.text :address1
      t.text :sub_district
      t.text :district
      t.text :province
      t.text :zip_code

      t.timestamps
    end
  end
end
