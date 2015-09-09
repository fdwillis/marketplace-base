class ReportsController < ApplicationController
  before_filter :authenticate_user!
  include ActionView::Helpers::NumberHelper
  def index
    if (current_user.account_approved? && !current_user.roles.nil?) || current_user.admin? 
      if current_user.admin?
        @monthly_income = (Stripe::Customer.all.data.map(&:subscriptions).map(&:data).flatten.map(&:plan).map(&:amount).sum.to_f / 100)
      else
        User.decrypt_and_verify(current_user.merchant_secret_key)
        @monthly_income = (Stripe::Customer.all.data.map(&:subscriptions).map(&:data).flatten.map(&:plan).map(&:amount).sum.to_f / 100)
      end
      #Donation column Chart
        #Data
        year_data = [
          {
            'name' => "Total Donations",
            'data' => User.donation_revenue(current_user.id, "this_year", "monthly")
          }, 
          {
            'name' => "Web Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_year", "monthly", "donate_by", "web")
          }, 
          {
            "name" => "Text Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_year", "monthly", "donate_by", "text")
          },
        ]
        week_data = [
          {
            'name' => "Total Donations",
            'data' => User.donation_revenue(current_user.id, "this_week", "daily")
          }, 
          {
            'name' => "Web Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_week", "daily", "donate_by", "web")
          }, 
          {
            "name" => "Text Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_week", "daily", "donate_by", "text")
          },
        ]

        
        @column = column_chart(year_data, "Donations This Year #{number_to_currency(year_data[0]['data'].map{|d| d['value']}.sum, precision: 2)}", Date::MONTHNAMES.slice(1..12))
        @colum = column_chart(week_data, "Donations This Week #{number_to_currency(week_data[0]['data'].map{|d| d['value']}.sum, precision: 2)}", Date::DAYNAMES)
        #Chart

      #Donation pie Chart
        pie_type_data = [
          {
            'data' => User.donation_pie(current_user.id, "donation_type")
          }
        ]

        pie_day_data = [
          {
            'data' => User.donation_pie(current_user.id, "day_of_week")
            }
        ]
        pie_city_data = [
          {
            'data' => User.donation_pie(current_user.id, "customer_current_city")
            }
        ]
        @pie_type = pie_chart(pie_type_data, 'donation_type', "Donations By Type")
        @pie_week = pie_chart(pie_day_data, 'day_of_week', "Donations By Day")
        @pie_city = pie_chart(pie_city_data, 'customer_current_city', "Donations By City")

      # Donation area chart  
        data = [
          {
            'name' => "All Donations",
            'data' => User.donation_revenue(current_user.id, "this_month", "daily")
          },
          {
            'name' => "Web Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_month", "daily", "donate_by", "web")
          }, 
          {
            "name" => "Text Donations",
            'data' => User.donation_rev_by_type(current_user.id, "this_month", "daily", "donate_by", "text")
          },
        ]
        @area = area_chart(data, "Donation Revenue This Month #{number_to_currency(data[0]['data'].map{|d| d['value']}.sum, precision: 2)}")


      # @bar = bar_chart
      # @funnel = funnel_chart

    else
      redirect_to plans_path
      flash[:error] = "You dont have permission to access reports. You must signup"
      return
    end
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
  end

private

  def column_chart(data, title, timeframe)
    LazyHighCharts::HighChart.new('graph') do |f|
      f.colors([ '#434348', '#7CB5EC','#90ED7D'])
      f.title(:text => title)
      f.xAxis(:categories => timeframe)
      f.series(:name => data[0]['name'], :yAxis => 0, :data => data[0]['data'].map{|d| d['value'] })
      f.series(:name => data[1]['name'], :yAxis => 0, :data => data[1]['data'].map{|d| d['value'] })
      f.series(:name => data[2]['name'], :yAxis => 0, :data => data[2]['data'].map{|d| d['value'] })
      f.yAxis(title: {:text => "Dollars"} )
      f.legend(enabled: true)
      f.chart(type: "column")
      f.tooltip(shared: true)
    end
  end

  def pie_chart(data, group, title)
    LazyHighCharts::HighChart.new('pie') do |f|
      f.chart(
        {
          :defaultSeriesType=>"pie", 
          
        }
      )
      f.series(:type=> 'pie',
                name: "Percent",
               :data=> data[0]['data'].map{|d| [d[group], (d['result'] / data[0]['data'].map{|d| d['result']}.sum.to_f * 100).to_i]})
      f.title(text: title)
      f.plotOptions(
        pie: {
          dataLabels: {
            enabled: true,
          }, 
          showInLegend: true,
          allowPointSelect: true,
          cursor: 'pointer',
        }
      )
      f.legend(layout: "horizontal")
    end
  end

  def area_chart(data, title)
    
    LazyHighCharts::HighChart.new('graph') do |f|
      
      f.colors([ '#434348', '#7CB5EC','#90ED7D'])
      f.chart(type: 'area')
      f.title(text: title)
      f.series(
        name: data[0]['name'],
        data: data[0]['data'].map{|d| d['value']}
      )
      f.series(
        name: data[1]['name'],
        data: data[1]['data'].map{|d| d['value']}
      )
      f.series(
        name: data[2]['name'],
        data: data[2]['data'].map{|d| d['value']}
      )
      f.yAxis(title: {text: "Dollars"})
      f.xAxis(type: 'datetime', categories: data[0]['data'].map{|d| d['timeframe']['start'].to_date.strftime("%d")})
      f.tooltip(shared: true)
      f.legend(enabled: true)
      f.plotOptions(
        series:{
          fillOpacity: 0.8
        }
      )
    end
  end
  
  # def bar_chart
  #   LazyHighCharts::HighChart.new('graph') do |f|
  #     f.title(:text => "Population vs GDP For 5 Big Countries [2009]")
  #     f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])

  #     f.series(:name => "GDP in Bill", :yAxis => 0, :data => [100, 90, 100, 100, 100])
  #     f.series(:name => "Pop in Mill", :yAxis => 0, :data => [110, 100, 95, 99, 97])

  #     f.yAxis(title: {:text => "View Count"} )

  #     f.chart(type: "bar")
  #   end
  # end

  # def funnel_chart
  #   LazyHighCharts::HighChart.new('graph') do |f|
  #     f.chart(type: 'funnel', marginRight: 100)
  #     f.title(text: "Conversion/Campaign/Sales Funnel", x: -50)
  #     f.series({
  #           name: 'Unique users',
  #           data: [
  #               ['Visits',   15654],
  #               ['Downloads',       4064],
  #               ['Requested Price List', 1987],
  #               ['Invoice sent',    976],
  #               ['Finalized',    946]
  #           ]
  #       })
  #     f.plotOptions(
  #       series:{
  #         dataLabels: {
  #           enabled: true,
  #           format: '<b>{point.name}</b> ({point.y:,.0f})',
  #           softConnector: false
  #         },
  #         neckWidth: '30%',
  #         neckHeight: '25%'
  #         })
  #   end
  # end
end