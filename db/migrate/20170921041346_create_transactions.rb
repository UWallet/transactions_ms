class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.integer :useridgiving
      t.integer :useridreceiving
      t.float :amount
      t.string :state

      t.timestamps
    end
  end
end
