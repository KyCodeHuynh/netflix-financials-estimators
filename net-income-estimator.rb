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
  # NOTE: These numbers come from our report (which is not presently public)
  # Format: { cost => percent_probability_of_cost }
  ADMIN_COSTS = 1_514_647.83
  RESEARCH_DEV_COSTS = 800_469.24

  CONTENT_COSTS_DISTRIBUTION = { 6e9 => 30, 6.75e9 => 40, 7e9 => 30 }
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

  def self.netflix_projected_net_income(debug: false)
    content_costs    = sample(CONTENT_COSTS_DISTRIBUTION)
    bandwidth_costs  = sample(BANDWIDTH_COSTS_DISTRIBUTION)
    other_costs      = ADMIN_COSTS + RESEARCH_DEV_COSTS
    total_costs      = content_costs + bandwidth_costs + other_costs

    revenue          = NetflixRevenueEstimator::netflix_projected_revenue
    pretax_profit    = revenue - total_costs
    net_income       = pretax_profit * (1 - TAX_RATE)

    if debug
      puts "Content Costs (content): $#{NetflixRevenueEstimator::separate(content_costs)}"
      puts "Bandwidth Costs (bandwidth): $#{NetflixRevenueEstimator::separate(bandwidth_costs)}"
      puts "Total Costs: $ #{NetflixRevenueEstimator::separate(total_costs)}"
      puts "Revenue: $#{NetflixRevenueEstimator::separate(revenue)}"
      puts "Net Income: $#{NetflixRevenueEstimator::separate(net_income)}"
    end

    net_income
  end

  def self.simulate(iterations:)
    # No denial-of-service, please
    return if iterations < 0 || iterations > 100_000

    results = []
    iterations.times do
      results << netflix_projected_net_income(debug: false)
    end

    average     = results.mean
    median      = results.median
    mode        = results.mode
    std_dev     = results.standard_deviation

    puts "SIMULATION RESULTS"
    puts "For #{NetflixRevenueEstimator::separate(iterations)} samples, we have:"
    puts "Average net income: $#{NetflixRevenueEstimator::separate(average)}"
    puts "Median net income: $#{NetflixRevenueEstimator::separate(median)}"
    puts "Mode net income: $#{NetflixRevenueEstimator::separate(mode)}"
    puts "Standard deviation of the above: $#{NetflixRevenueEstimator::separate(std_dev)}"
  end
end

if $PROGRAM_NAME == __FILE__
  NetflixNetIncomeEstimator::simulate(iterations: 10_000)
end
