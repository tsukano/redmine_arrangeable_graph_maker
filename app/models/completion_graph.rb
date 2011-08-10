class AdvancedIssue

  INTERVALS = { 5 => [5, 15, 30, 60, 360, 1440] }

  attr_reader :intervals
  attr_reader :count_each_interval
 
  def initialize(first_interval)
    @intervals =  INTERVALS[first_interval]
    @count_each_interval = Array.new(6,0)

  end

  def find_counts

    closed_statuses = IssueStatus.find_all_is_closed(true)

    closed_journals = Journal.find(:all,
                                   :include => [:issue, :details],
                                   :conditions => 
                                     [ "issues.project_id = ? and " +
                                       "journal_details.prop_key = 'status_id' and " +
                                       "journal_details.value IN ( ? ) and " +
                                       "journals.created_on between ? and ? ",
                                       @project.id,
                                       closed_statuses,
                                       AdvancedDate.first_day_in_this_month,
                                       AdvancedDate.last_day_in_this_month] )

    calculate_count_each_interval(closed_journals)


=begin
    intervals_index = 0
    completion_minutes.sort.each_with_index do |minute, minutes_index|

      (intervals_index..@count_each_interval.size - 1).times do |index|
        if minute <= @intervals[interval_index]
          @count_each_interval[interval_index] += 1
        elsif interval_index + 1 < @count_each_interval.size
          next
        elsif interval_index + 1 == @count_each_interval.size
          
      end

    end



=begin


    edited_issues = Issue.find(:all,
                               :include    => [:journals, :status],
                               :conditions => [ "issues.project_id = ? and " + 
                                                "issue_statuses.is_closed = true and " +
                                                "journals.created_on between ? and ? ",
                                                @project.id,
                                                AdvancedDate.first_day_in_this_month,
                                                AdvancedDate.last_day_in_this_month] )

    edited_issues.each do |issue|
      issue.journals.reverse.each do |journal|
        journal.detail
      end
    end

=end

  end

  private
  def calculate_count_each_interval(journals)
    journals.each do |journal|
      issue = journal.issue
      if issue.closed?
        completion_interval_minute = (journal.created_on - issue.created_on) * 24 * 60
        set_count_each_interval(completion_interval_minute)
      end
    end
  end

  def set_count_each_interval(minute)
    @intervals.each_with_index do |interval, interval_index|
      if( minute <= interval ||
          interval_index == @count_each_interval.size - 1 )
        @count_each_interval[interval_index] += 1
        break
      end
    end
  end

end
