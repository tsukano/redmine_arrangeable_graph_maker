class AdvancedIssue

  DEFAULT_FIRST_INTERVAL = '5'
  INTERVALS      = { '5' => [5, 15, 30, 60, 360, 1440] }
  COUNT_EACH_INTERVAL = lambda do 
                          Array.new(
                            INTERVALS[DEFAULT_FIRST_INTERVAL].size + 1, 
                            0
                          ) #size <<+1>> is for more than
                        end

  def self.counts_completion_time(project_id, intervals)
    closed_statuses = IssueStatus.find_all_by_is_closed(true)
    closed_journals = Journal.find(:all,
                                   :include => [:issue, :details],
                                   :conditions => 
                                     [ "issues.project_id = ? and " +
                                       "journal_details.prop_key = 'status_id' and " +
                                       "journal_details.value IN ( ? ) and " +
                                       "journals.created_on between ? and ? ",
                                       project_id,
                                       closed_statuses,
                                       AdvancedDate.first_day_in_this_month,
                                       AdvancedDate.last_day_in_this_month] )
    completion_times = calculate_completion_times(closed_journals)
    count_each_interval = get_count_each_interval(completion_times, intervals)
    return count_each_interval
  end

  def self.intervals(first_interval)
    return INTERVALS[first_interval]
  end

  private

  def self.calculate_completion_times(journals)
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

  def self.get_count_each_interval(completion_times, intervals)
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
