#!usr/bin/env ruby

# Netflix 2017 Net Income Estimator
# Ky-Cuong L. Huynh
# 6 December 2017

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

TAX_RATE = 0.34
content_costs = [6e9, 6.5e9, 7e9]
bandwidth_costs = []
projected_revenue = NetflixRevenueEstimator::netflix_projected_2017_revenue

module NetflixNetIncomeEstimator
  def self.netflix_projected_2017_net_income(debug: false)
  end

  def self.simulate(iterations)
    # Call netflix_projected_2017_net_income 10,000 times
    # TODO: stats on results
  end
end

if $PROGRAM_NAME == __FILE__
  NetflixNetIncomeEstimator::netflix_projected_2017_net_income(debug: true)
end
