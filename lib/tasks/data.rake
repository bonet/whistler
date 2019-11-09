namespace :data do
  desc 'Create Rewards'
  task :create_rewards => :environment do
    Reward.create(reward_type: 'free_coffee', name: 'Free Coffee')
    Reward.create(reward_type: 'cash_rebate', name: 'Cash Rebate')
    Reward.create(reward_type: 'free_movie_tickets', name: 'Free Movie Tickets')
    Reward.create(reward_type: 'airport_lounge_access', name: 'Airport Lounge Access')
  end
end
