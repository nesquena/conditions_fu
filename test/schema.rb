ActiveRecord::Schema.define(:version => 1) do
	
	create_table :people do |t|
    t.string :first_name, :last_name, :occupation
    t.integer :age, :phone, :favorite_number
  end
  
end