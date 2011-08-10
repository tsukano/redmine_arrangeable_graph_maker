class GraphMakerController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize, :only => [:show_long, 
                                      :show_trend,
                                      :show_completion]
  menu_item :long_graph, :only => :show_long
  menu_item :trend_graph, :only => :show_trend
  menu_item :completion_graph, :only => :show_completion

  def show_long

  end

  def show_trend
    @queries = Query.find_all_by_project_id(@project.id)
  end

  def show_completion

  end

  def get_completion_graph

    first_interval = params[:first_interval]
    if first_interval.nil? || first_interval.empty?
      first_interval = AdvancedIssue::DEFAULT_FIRST_INTERVAL 
    end

    intervals = AdvancedIssue.intervals(first_interval)
    counts = AdvancedIssue.counts_completion_time(@project.id,
                                                  intervals)

    graph = CustomizedGraph.new("チケット完了までの時間", 600, Gruff::Bar)
    graph.push_data("#{DateTime.now.month}月度チケット件数", counts)
    intervals.each do |interval|
      graph.push_label(AdvancedDate.get_formatted_time(interval, :less_than))
    end
    graph.push_label(AdvancedDate.get_formatted_time(intervals.last, :more_than))

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end


  def get_monthly_graph
    created_issues = Issue.find(:all,
                                :select => :created_on,
                                :order => "created_on ASC",
                                :conditions => [ "project_id = ? and " +
                                                 "created_on > ? ",
                                                 @project.id,
                                                 DateTime.now - 1.months])


    count_each_hour = Array.new(24,0)
    created_issues.each do |issue|
      count_each_hour[issue.created_on.hour] += 1
    end

    graph = CustomizedGraph.new("時間帯別のチケット件数", 600, Gruff::Line)
    graph.push_data("作成日並び", count_each_hour)
    (0..23).each do |hour| graph.push_label(hour.to_s) end

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  def get_long_graph
    year = 2011
    start_date = DateTime.new(year, 4)

    project_trackers = @project.trackers
    count_each_tracker = Hash.new
    project_trackers.each { |tracker| count_each_tracker.store tracker, Array.new }

    graph = CustomizedGraph.new("月毎のチケット件数", 
                                600, 
                                "Gruff::#{params[:graph_variation]}".constantize)


    12.times do |num| 
      graph.push_label((start_date + num.months).month.to_s + "月")
      issue_counts = Issue.count(:group => "tracker_id",
                                 :conditions => [ "project_id = ? and " +
                                                  "created_on >= ? and " +
                                                  "created_on < ?",
                                                  @project.id,
                                                  start_date + num.months,
                                                  start_date + (num + 1).months ])

      project_trackers.each do |tracker|
        count = issue_counts[tracker.id]
        if count == nil
          count_each_tracker[tracker].push 0
        else
          count_each_tracker[tracker].push count
        end
      end
    end

    project_trackers.each do |tracker|
      graph.push_data(tracker.name, count_each_tracker[tracker])
    end

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  def get_trend_graph
    query = Query.find_by_id(params[:query_id])
    group = query.group_by
    graph = CustomizedGraph.new("#{query.name}(#{group}毎のticket件数)", 600, Gruff::Pie)
=begin
    tracker = 10 # shogai
    group = "priority" # session[:query][:id]/ group_by no grouping retrieve_query 74
=end
    group_class = group == "status" ? "IssueStatus" : group.classify
    item_names = group_class.constantize.all.collect{|item| [item.id, item.name] }
    item_names = Hash[item_names]
    issue_counts = Issue.count(:group      => "#{group}_id",
                               :conditions => { :project_id => @project.id })
    issue_counts.each do |count|
      group_name = item_names[count[0]]
      count = count[1]
      graph.push_data(group_name, count)
    end
    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  def get_graph

    gruff = Gruff::Net.new 500
    gruff.title = "トラッカーサマリー結果"
    gruff.font = "/usr/share/fonts/japanese/TrueType/sazanami-gothic.ttf"
    gruff.theme_37signals

    trackers = @project.trackers

    
    count_each_tracker = Hash.new

    [false, true, :all].each do |is_closed_status|

      trackers.each do |tracker|
        count_issue = Issue.count(:first,
                                  :include => :status,
                                  :conditions => 
                                    ["issues.project_id = ? AND " +
                                     "issues.tracker_id = ? AND " +
                                     "issue_statuses.is_closed IN (?)",
                                      @project.id, 
                                      tracker.id,
                                      is_closed_status == :all ? [true, false] :
                                                                 is_closed_status])

        if count_each_tracker.keys.include? is_closed_status
          count_each_tracker[is_closed_status].push count_issue
        else
          count_each_tracker[is_closed_status] = [count_issue]
        end
      end
    end

    gruff.data("完了   #{count_each_tracker[true]}", count_each_tracker[true])
    gruff.data("未完了 #{count_each_tracker[false]} ", count_each_tracker[false])
    gruff.data("全て   #{count_each_tracker[:all]} ", count_each_tracker[:all])

    trackers.each_with_index do |tracker, i|
      gruff.labels.store(i, tracker.name)
    end


#NG
=begin
    @project.trackers.each_with_index do |tracker, i|
    
      count_issue_not_completed = Issue.count(:first,
                                              :include => :status,
                                              :conditions => 
                                                ["issues.project_id = ? AND " +
                                                 "issues.tracker_id = ? AND " +
                                                 "issue_statuses.is_closed = true",
                                                  @project.id, tracker.id])

      count_issue_completed = Issue.count(:first,
                                          :include => :status,
                                          :conditions => 
                                          ["issues.project_id = ? AND " +
                                           "issues.tracker_id = ? AND " +
                                           "issue_statuses.is_closed = false",
                                            @project.id, tracker.id])

      gruff.data(tracker.name, 
                 [ count_issue_not_completed, 
                   count_issue_completed ])

      gruff.labels.store(i, 
    end
=end
=begin
    tracker = @project.trackers[0]

    count_issue_not_completed = Issue.count(:first,
                                            :include => :status,
                                            :conditions => 
                                              ["issues.project_id = ? AND " +
                                               "issues.tracker_id = ? AND " +
                                               "issue_statuses.is_closed = true",
                                                @project.id, tracker.id])

    count_issue_completed = Issue.count(:first,
                                        :include => :status,
                                        :conditions => 
                                        ["issues.project_id = ? AND " +
                                         "issues.tracker_id = ? AND " +
                                         "issue_statuses.is_closed = false",
                                          @project.id, tracker.id])


    gruff = Gruff::Pie.new 500
    gruff.title = "#{tracker.name}サマリー結果"
    gruff.font = "/usr/share/fonts/japanese/TrueType/sazanami-gothic.ttf"
    gruff.theme_37signals

    gruff.data('未完了', [count_issue_not_completed ])
    gruff.data('完了', [count_issue_completed ])
=end

    send_data(gruff.to_blob('jpg'), 
              :type => 'image/jpg',
              :disposition => 'inline')

  end

  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
