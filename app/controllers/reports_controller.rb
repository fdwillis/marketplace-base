class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
    if current_user.account_approved && !current_user.roles.nil? || current_user.admin? 
      #Donation Revenue Chart
        #Data
        timeframe = ["this_year", "this_week"]
        timeframe.each_with_index do |time, i|
          if i == 0
            @column = column_chart(User.donation_revenue(current_user.id, time), Date::MONTHNAMES.slice(1..12), "Donations This Year")
          else
            @colum = column_chart(User.donation_revenue(current_user.id, time), Date::DAYNAMES, "Donations This Week")
          end
        end
        #Chart

      #Donation type comparison Chart
        #chart
        group_by = ["donation_type", "day_of_week"]
        group_by.each_with_index do |query, i|
          if i == 0
            @pie = pie_chart(User.donation_pie(current_user.id, query), query, "Donation By Type")
          else
            @pe = pie_chart(User.donation_pie(current_user.id, query), query, "Donation By Day Of Week")
          end
        end

      @bar = bar_chart
      @area = area_chart
      @funnel = funnel_chart

    else
      redirect_to plans_path
      flash[:error] = "You dont have permission to access reports. You must signup"
      return
    end
  end

private

  def column_chart(data, timeframe, title)
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => title.titleize)
      f.xAxis(:categories => timeframe)
      f.series(:name => "Revenue", :yAxis => 0, :data => data.map{|d| d["value"]})
      f.yAxis(title: {:text => "Dollars"} )
      f.legend(enabled: false)
      f.chart(type: "column")
      f.tooltip(enabled: true)
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

  def area_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.chart(type: 'area')
      f.title(text: "Home Page Views This Week")
      f.series(name: "Bye",data: [
                ['Visits',   700],
                ['Downloads',       900],
            ])
      f.series(name: "Hi",data: [
                ['Visits',   900],
                ['Downloads',       700],
            ])
      f.series(name: "hi",data: [
                ['Visits',   700],
                ['Downloads', 200],
            ])
      f.yAxis(title: {text: "View Count"})
      f.xAxis(type: 'datetime', categories: @d)
      f.tooltip(shared: true)
      f.legend(enabled: true)
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