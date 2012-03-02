class CompletionGraph

  DEFAULT_FIRST_INTERVAL = '5'
  INTERVALS = { 1  => [ 1,  2,  3,  5,  30,   60],
                2  => [ 2,  4, 10, 30,  60,  360],
                3  => [ 3,  5, 15, 45, 120,  360],
                5  => [ 5, 15, 30, 60, 360, 1440],
                10 => [10, 30, 60,120, 720, 1440],
                30 => [30, 60,120,360, 720, 1440],
                360 =>[360,720,1440,2880,4320,10080],
                1440=>[1440,2880,4320,7200,10080,20160],
                4320=>[4320,7200,10080,20160,30240,43200]}
  COUNT_EACH_INTERVAL = lambda do 
                          Array.new(
                            INTERVALS[DEFAULT_FIRST_INTERVAL.to_i].size + 1, 
                            0
                          ) #size <<+1>> is for more than
                        end

  def initialize(project_id)
    @project_id = project_id
  end

  def count(intervals, target_month)
    closed_statuses = IssueStatus.find_all_by_is_closed(true)
    closed_journals = Journal.find(:all,
                                   :include => [:issue, :details],
                                   :conditions => 
                                     [ "issues.project_id = ? and " +
                                       "journal_details.prop_key = 'status_id' and " +
                                       "journal_details.value IN ( ? ) and " +
                                       "journals.created_on >= ? and " +
                                       "journals.created_on < ? ",
                                       @project_id,
                                       closed_statuses,
                                       target_month,
                                       target_month + 1.month] )
    completion_times = calculate_completion_times(closed_journals)
    count_each_interval = get_count_each_interval(completion_times, intervals)
    return count_each_interval
  end

  def self.intervals(first_interval)
    return INTERVALS[first_interval.to_i]
  end

  private

  def calculate_completion_times(journals)
    completion_times = Hash.new
    journals.each do |journal|
      issue = journal.issue
      if issue.closed?
        completion_time = journal.created_on - issue.created_on
        if completion_times[issue.id] == nil || 
          completion_times[issue.id] < completion_time
          completion_times.store(issue.id, 
                                 completion_time)
        end
      end
    end
    return completion_times.values
  end

  def get_count_each_interval(completion_times, intervals)
    count_each_interval = COUNT_EACH_INTERVAL.call
    completion_times.each do |completion_time|
      intervals.each_with_index do |interval, interval_index|
        # less than
        if completion_time <= (interval * 60)
          count_each_interval[interval_index] += 1
          break
        # more than
        elsif interval_index == intervals.size - 1
          count_each_interval[interval_index + 1] += 1
        end
      end
    end
    return count_each_interval
  end



end
