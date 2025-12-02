user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.name = "Demo User"
  u.points_balance = 1000
end

Reward.find_or_create_by!(name: "Coffee Mug") do |r|
  r.cost_in_points = 200
  r.inventory      = 10
  r.category       = :merchandise
end

Reward.find_or_create_by!(name: "Gift Card") do |r|
  r.cost_in_points = 500
  r.inventory      = 5
  r.category       = :gift_card
end

Reward.find_or_create_by!(name: "T-Shirt") do |r|
  r.cost_in_points = 300
  r.inventory      = 0 # to show out of stock
  r.category       = :merchandise
end
