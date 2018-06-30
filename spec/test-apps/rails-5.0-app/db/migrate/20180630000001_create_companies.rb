class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :name, index: true
      t.string :addr1
      t.string :addr2
      t.string :city, index: true
      t.string :state, index: true
      t.string :zip
      t.string :phone

      t.timestamps null: false
    end
  end
end
