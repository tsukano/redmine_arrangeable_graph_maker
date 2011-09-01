class LongGraph

  def initialize(project_id, project_trackers, year)
    @project_id = project_id
    @start_date = DateTime.new(year.to_i, 4)

    @project_trackers = project_trackers

    @count_each_tracker = Hash.new
    @project_trackers.each do |tracker| 
      @count_each_tracker.store tracker, Array.new
    end

  end

  def count
    12.times do |num| 
      issue_counts = Issue.count(:group => "tracker_id",
                                 :conditions => [ "project_id = ? and " +
                                                  "created_on >= ? and " +
                                                  "created_on < ?",
                                                  @project_id,
                                                  @start_date + num.months,
                                                  @start_date + (num + 1).months ])

      @project_trackers.each do |tracker|
        count = issue_counts[tracker.id]
        if count == nil
          @count_each_tracker[tracker].push 0
        else
          @count_each_tracker[tracker].push count
        end
      end
    end
    return @count_each_tracker
  end
end
