#!usr/bin/env ruby

# Netflix 2017 Revenue Estimator
# Ky-Cuong L. Huynh
# 6 December 2017

# NOTE: These numbers come from our report (which is not presently public)
# Revenue is computed as (number of subscribers for that month) * (average revenue/subscriber)
# Then, we sum these up across 12 months, where the number of subscribers increases per month
module NetflixRevenueEstimator
  # 2017 is estimated to start with 82.57 million subscribers
  NUM_SUBSCRIBERS_START_2017 = 82.57e6
  # 1.036 million new subscribers per month
  NUM_NEW_SUBSCRIBERS_PER_MONTH = 1.036e6
  # $10/subscriber on average
  REVENUE_PER_SUBSCRIBER = 10

  # Clean number output helper, from: https://stackoverflow.com/questions/6458990/how-to-format-a-number-1000-as-1-000
  # LICENSING: StackOverflow snippets are under a Creative Commons license: https://stackoverflow.com/help/licensing
  # AUTHOR CREDIT: https://stackoverflow.com/users/256970/cary-swoveland
  # CHANGE NOTICE: variables are renamed below for clarity; separator default changed to a comma
  def self.separate(number, separator: ',')
    m = number
    str = ''
    loop do
      m,r = m.divmod(1000)
      return str.insert(0,"#{r}") if m.zero?
      str.insert(0,"#{separator}#{"%03d" % r}")
    end
  end

  def self.num_subscribers_by_month(start:, step:, months: 12)
    num_current_subscribers = start
    results = [num_current_subscribers]

    (2..months).each do
      results << num_current_subscribers += NUM_NEW_SUBSCRIBERS_PER_MONTH
    end

    results
  end

  def self.netflix_projected_2017_revenue(debug: false)
    # Remaining months' revenue
    num_current_subscribers = NUM_SUBSCRIBERS_START_2017
    # Cumulative sum, initialized with January's revenue
    total_revenue_2017 = NUM_SUBSCRIBERS_START_2017 * REVENUE_PER_SUBSCRIBER

    monthly_subscriber_count = num_subscribers_by_month(start: NUM_SUBSCRIBERS_START_2017, step: NUM_NEW_SUBSCRIBERS_PER_MONTH)

    if debug
      monthly_subscriber_count.each_with_index do |count, index|
        puts "For Month #{index + 1}: #{separate(count)} * $10 = $#{separate(count * REVENUE_PER_SUBSCRIBER)}"
      end
    end

    monthly_revenues = monthly_subscriber_count.map { |count| count * REVENUE_PER_SUBSCRIBER }
    total_revenue_2017 = monthly_revenues.reduce(:+)

    if debug
      puts "Total estimated Netflix revenue for 2017: $#{separate(total_revenue_2017)}"
    end

    total_revenue_2017
  end
end

NetflixRevenueEstimator::netflix_projected_2017_revenue(debug: true) if $PROGRAM_NAME == __FILE__

