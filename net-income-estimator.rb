#!usr/bin/env ruby

# Netflix 2017 Net Income Estimator
# Ky-Cuong L. Huynh
# 7 December 2017

# Gem for stats on Enumerables: https://github.com/thirtysixthspan/descriptive_statistics
require 'descriptive_statistics'
# Our 2017 revenue estimator
require './revenue-estimator'

# Top-down breakdown of how we get net income:
#
# Net Income = pretax profit * (1 - tax rate)
# Pretax profit = revenue - total costs - depreciation
# Total costs = variable costs + fixed costs
# Variable costs = cost/subscriber * number of subscribers
# Revenues = subscriber sold * price/subscriber (for 1 time period)
# Subscribers = prediction from historical data

module NetflixNetIncomeEstimator

  # Format: { cost => percent_probability_of_cost }
  CONTENT_COSTS_DISTRIBUTION = { 5e9 => 70, 6e9 => 20, 6.5e9 => 10 }
  BANDWIDTH_COSTS_DISTRIBUTION = { 21_069_900 => 15, 23_879_220 => 15, 25_986_210 => 30, 29_497_860 => 40 }

  TAX_RATE = 0.34

  # Probability distribution sampling helper, from https://stackoverflow.com/questions/19261061/picking-a-random-option-where-each-option-has-a-different-probability-of-being
  # LICENSING: StackOverflow snippets are under a Creative Commons license: https://stackoverflow.com/help/licensing
  # AUTHOR CREDIT: https://stackoverflow.com/users/1827631/hirolau
  # CHANGE NOTICE: renamed method and argument
  def self.sample(distribution)
    current, max = 0, distribution.values.inject(:+)
    random_value = rand(max) + 1
    distribution.each do |key,val|
       current += val
       return key if random_value <= current
    end
  end

  def self.netflix_projected_2017_net_income(debug: false)

    fixed_costs    = sample(CONTENT_COSTS_DISTRIBUTION)
    variable_costs = sample(BANDWIDTH_COSTS_DISTRIBUTION)
    total_costs    = fixed_costs + variable_costs
    revenue        = NetflixRevenueEstimator::netflix_projected_2017_revenue

    pretax_profit  = revenue - total_costs
    net_income     = pretax_profit * (1 - TAX_RATE)

    if debug
      puts "Fixed Costs (content): $#{NetflixRevenueEstimator::separate(fixed_costs)}"
      puts "Variable Costs (bandwidth): $#{NetflixRevenueEstimator::separate(variable_costs)}"
      puts "Total Costs: $ #{NetflixRevenueEstimator::separate(total_costs)}"
      puts "Revenue: $#{NetflixRevenueEstimator::separate(revenue)}"
      puts "Net Income: $#{NetflixRevenueEstimator::separate(net_income)}"
    end

    net_income
  end

  def self.simulate(iterations:)
    # No denial-of-service, please
    return if iterations < 0 || iterations > 100_000

    iterations.times do
      netflix_projected_2017_net_income(debug: true)
    end

    # TODO: stats on results
  end
end

if $PROGRAM_NAME == __FILE__
  NetflixNetIncomeEstimator::simulate(iterations: 1000)
end
