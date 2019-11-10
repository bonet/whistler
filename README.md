# Loyalty program exercise

Deployment steps:
- bundle install
- rake db:migrate
- rake db:seed (to create Rewards)


To run in console:
- run 'rails console'
- can follow the following test flow listed in: spec/services/point_reward_manager_service_spec.rb
  i.e. create User -> create OrderTransactions -> issue points -> issue rewards


To test:
- rake db:test:prepare
- rspec


Objects:
- User: owner of points and rewards
- OrderTransaction: paid proof of purchase. Its amount determines how many Point quantity a user will get (ideally named Transaction, but it conflicts with Rails internal naming. Should have better naming)
- Point: a single Point object issued per transaction (has 'quantity' attributes, which was the Point's quantity that was issued based on transaction amount). Point model is inherited by LocalPoint or InternationalPoint objects
- Reward: X amount of Points / etc can be converted to a Reward. There are many types of Reward


Flow:
- To issue points to user, client can call PointRewardManagerService#issue_point(transaction, type: local/international)
- To issue rewards to user, client can call PointRewardManager#issue_reward


Assumption:
- Point is unique per each transaction. Cannot combine 2 or more transactions to create a Point object
- Reward conversion rule can be based by Point or other aspects. It's not strictly related to Points
- Transactions less than $100 would not generate a Point object
- Thus we also need a Transaction object. Some Reward conversion rule are based on Transaction
- Points expire 1 year after its issuance


-----
Service: PointRewardManagerService
- this is the Service that issues point or reward to users

-----
Model: User
- has_many :order_transactions
- has_many :points
- has_many :user_rewards
- has_many :rewards, through: :user_rewards

attr:
- id
- name
- birthday
- etc
- loyalty_tier (standard / gold / platinum)


-----
Model: OrderTransaction
- belongs_to :user
- has_one :point

attr:
- id
- amount
- user_id


-----
Model: Point
- belongs_to :order_transaction
- belongs_to :user

attr:
- id
- type (local / international) --> using STI
- order_transaction_id
- user_id
- transaction_amount
- quantity
- label
- expire_at
- expired (boolean)

-----
Model: Reward
- has_many :user_rewards
- has_many :users, through: :user_rewards

attr:
- id
- reward_type (free_coffee / cash_rebate / free_movie_ticket)
- name

-----
Model: UserReward
- belongs_to :user
- belongs_to :reward

attr:
- user_id
- reward_id




# Loyalty program practical example

At it's most basic, the platform offers clients the ability to issue loyalty points to their end users.
End users use their points to claim/purchase rewards offered by the client.

## Points

**Level 1**

1. For every $100 the end user spends they receive 10 points

**Level 2**

1. If the end user spends any amount of money in a foreign country they receive 2x the standard points

## Issuing rewards

**Level 1**

1. If the end user accumulates 100 points in one calendar month they are given a Free Coffee reward

**Level 2**

1. A Free Coffee reward is given to all users during their birthday month
2. A 5% Cash Rebate reward is given to all users who have 10 or more transactions that have an amount > $100
3. A Free Movie Tickets reward is given to new users when their spending is > $1000 within 60 days of their first transaction

## Loyalty tiers

**Level 1**

1. A standard tier customer is an end user who accumulates 0 points
2. A gold tier customer is an end user who accumelates 1000 points
3. A platinum tier customer is an end user who accumulates 5000 points

**Level 2**

1. Points expire every year
2. Loyalty tiers are calcualted on the highest points in the last 2 cycles
2. Give 4x Airport Lounge Access Reward when a user becomes a gold tier customer
3. Every calendar quarterly give 100 bonus points for any user spending greater than $2000 in that quarter

## Evaluation

Your code will be evaluated more on the quality than on completing the scope.
Our production environment is a high volume environment, we are required to maintain data integrity and performance throughout.
Please provide appropriate tests.
