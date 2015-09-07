class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
    if current_user.account_approved && !current_user.roles.nil? || current_user.admin? 
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


        @column = column_chart(year_data, "Donations This Year", Date::MONTHNAMES.slice(1..12))
        @colum = column_chart(week_data, "Donations This Week", Date::DAYNAMES)
        #Chart

      #Donation pie Chart
        #chart
        group_by = ["donation_type", "day_of_week"]
        group_by.each_with_index do |query, i|
          if i == 0
            @pie = pie_chart(User.donation_pie(current_user.id, query), query, "Donation By Type")
          else
            @pe = pie_chart(User.donation_pie(current_user.id, query), query, "Donation By Day Of Week")
          end
        end

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
        @area = area_chart(data)
      @bar = bar_chart
      @funnel = funnel_chart

    else
      redirect_to plans_path
      flash[:error] = "You dont have permission to access reports. You must signup"
      return
    end
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
               :name=> "Donation Types",
               :data=> data.map{|d| [d[group].capitalize, d["result"]]})
      f.title(text: title.titleize)
    end
  end

  def area_chart(data)
    
    LazyHighCharts::HighChart.new('graph') do |f|
      f.colors([ '#434348', '#7CB5EC','#90ED7D'])
      f.chart(type: 'area')
      f.title(text: "Donation Revenue This Month")
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
  
  def bar_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Population vs GDP For 5 Big Countries [2009]")
      f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])

      f.series(:name => "GDP in Bill", :yAxis => 0, :data => [100, 90, 100, 100, 100])
      f.series(:name => "Pop in Mill", :yAxis => 0, :data => [110, 100, 95, 99, 97])

      f.yAxis(title: {:text => "View Count"} )

      f.chart(type: "bar")
    end
  end

  def funnel_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.chart(type: 'funnel', marginRight: 100)
      f.title(text: "Conversion/Campaign/Sales Funnel", x: -50)
      f.series({
            name: 'Unique users',
            data: [
                ['Visits',   15654],
                ['Downloads',       4064],
                ['Requested Price List', 1987],
                ['Invoice sent',    976],
                ['Finalized',    946]
            ]
        })
      f.plotOptions(
        series:{
          dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b> ({point.y:,.0f})',
                    softConnector: false
                },
                neckWidth: '30%',
                neckHeight: '25%'
          })
    end
  end
end