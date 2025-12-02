class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string  :name,          null: false
      t.integer :cost_in_points, null: false
      t.integer :inventory,      null: false, default: 0
      t.integer :category,       null: false, default: 0
      t.timestamps
    end
  end
end
