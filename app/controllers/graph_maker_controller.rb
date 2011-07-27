class GraphMakerController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize, :only => :index

  menu_item :graph

  def index

  end
  
  def get_graph

    gruff = Gruff::Net.new 500
    gruff.title = "トラッカーサマリー結果"
    gruff.font = "/usr/share/fonts/japanese/TrueType/sazanami-gothic.ttf"
    gruff.theme_37signals

    trackers = @project.trackers

    
    count_each_tracker = Hash.new

    [false, true].each do |is_closed_status|

      trackers.each do |tracker|
        count_issue = Issue.count(:first,
                                  :include => :status,
                                  :conditions => 
                                    ["issues.project_id = ? AND " +
                                     "issues.tracker_id = ? AND " +
                                     "issue_statuses.is_closed = ?",
                                      @project.id, 
                                      tracker.id,
                                      is_closed_status])

        if count_each_tracker.keys.include? is_closed_status
          count_each_tracker[is_closed_status].push count_issue
        else
          count_each_tracker[is_closed_status] = [count_issue]
        end
      end
    end

    gruff.data('完了', count_each_tracker[true])
    gruff.data('未完了', count_each_tracker[false])

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
