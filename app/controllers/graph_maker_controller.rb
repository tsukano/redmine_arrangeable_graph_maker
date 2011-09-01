class GraphMakerController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize, 
                :only => [:select_view,
                          :show_long, 
                          :show_trend,
                          :show_customize,
                          :show_completion]
  menu_item :long_graph, :only => :show_long
  menu_item :trend_graph, :only => :show_trend
  menu_item :completion_graph, :only => :show_completion
  menu_item :customize_graph, :only => :show_customize

  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
=begin
  def select_view
    if params['graph']
      case params['graph']['mode']
      when 'trend'
        redirect_to :action => :show_trend, :project_id => params[:project_id]
      when 'completion'
        redirect_to :action => :show_completion
      end
    else
    redirect_to :action => :show_trend, :project_id => params[:project_id]
    end

  end
=end  
  def show_customize
    @queries = Query.find_all_by_project_id(@project.id)
    @group_labels = @queries.map do |query|
      if query.group_by =~ /cf_(\d+)/
        CustomField.find($1).name
      else
        I18n.t('field_' + query.group_by)
      end
    end
  end

  def show_long

  end

  def show_trend
  end

  def show_completion

    @first_interval = params[:first_interval]
    @first_interval ||= CompletionGraph::DEFAULT_FIRST_INTERVAL 

    advanced_issue = AdvancedIssue.new(CompletionGraph.new(@project.id))
    
    intervals = CompletionGraph.intervals(@first_interval)
    @counts = advanced_issue.count(intervals)

    @labels = Array.new
    @table_labels = Array.new
    intervals.each do |interval|
      @labels.push(AdvancedDate.get_formatted_time(interval, :less_than, true))
      @table_labels.push(AdvancedDate.get_formatted_time(interval, :less_than))
    end
    @labels.push(AdvancedDate.get_formatted_time(intervals.last, :more_than, true))
    @table_labels.push(AdvancedDate.get_formatted_time(intervals.last, :more_than))

    @all_labels = Hash.new
    CompletionGraph::INTERVALS.keys.sort.each do |key|
      @all_labels[key] = Array.new
      CompletionGraph::INTERVALS[key].each do |interval|
        display_time = AdvancedDate.get_formatted_time(interval, :less_than)
        @all_labels[key].push display_time
      end
      display_time = AdvancedDate.get_formatted_time(CompletionGraph::INTERVALS[key].last, :more_than)
      @all_labels[key].push display_time
    end

  end

  def get_completion_graph
    counts = params[:counts].map { |count_str| count_str.to_i }
    labels = params[:labels]

    graph = CustomizedGraph.new("完了時間毎のチケット件数", 600, Gruff::Bar)
    graph.push_data("#{DateTime.now.month}月度", counts)

    graph.set_labels_from_array(labels)

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end


  def get_trend_graph
    graph = CustomizedGraph.new(I18n.t("graph_title.trend_#{params[:each_by]}"),
                                600, 
                                "Gruff::#{params[:graph_variation]}".constantize)

    trend_graph = AdvancedIssue.new(TrendGraph.new(@project.id, 
                                                   params[:each_by]))
    count_each_time = trend_graph.count

    graph.push_data("直近1ヶ月分 ", 
                    count_each_time)
    count_each_time.size.times do |num|
      case params[:each_by]
      when 'day'
        label = (num + 1).to_s
      when 'wday'
        label = I18n.t("graph_items.wday_#{num}")
      when 'hour'
        label = num.to_s
      end
      graph.push_label(label)
    end

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  def get_long_graph
    long_graph = AdvancedIssue.new(LongGraph.new(@project.id,
                                                 @project.trackers,
                                                 params[:year]))
    graph = CustomizedGraph.new("#{params[:year]}年度のチケット件数", 
                                600, 
                                Gruff::Line)

    count_each_tracker = long_graph.count

    @project.trackers.each do |tracker|
      graph.push_data(tracker.name, 
                      count_each_tracker[tracker])
    end

    april = DateTime.new(DateTime.now.year, 4)
    12.times do |num|
      graph.push_label((april + num.month).month.to_s + "月")
    end

    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  def get_customize_graph
    retrieve_query
    @issue_count_by_group = @query.issue_count_by_group

    graph = CustomizedGraph.new(@query.name,
                                600, 
                                Gruff::Pie)

    @issue_count_by_group.each do |group, count|
      group_name = group.to_s.size == 0 ? 'None' : group.to_s
      graph.push_data(group_name, count)
    end
    
    send_data(graph.blob,
              :type => 'image/png', 
              :disposition => 'inline')

  end

  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
