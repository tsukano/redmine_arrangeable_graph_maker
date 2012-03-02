class AdvancedDate

  def self.first_day_in_this_month
    DateTime.new(DateTime.now.year, DateTime.now.month, 1)
  end

  def self.last_day_in_this_month
    self.first_day_in_this_month + 1.months - 1.days
  end

  def self.get_formatted_time(minute, less_or_more_than, easy_mode = false)

    if easy_mode
      i18n_format = lambda do |time, format|
        if less_or_more_than == :more_than
          I18n.t("graph_items.others")
        else
          time.to_s +
          I18n.t("graph_items.#{format.to_s}")
        end
      end
    else
      i18n_format = lambda do |time, format|
        time.to_s + 
        I18n.t("graph_items.#{format.to_s}") +
        I18n.t("graph_items.#{less_or_more_than}")
      end
    end
    case minute
    when 0..59
      return i18n_format.call(minute, :min)
    when 60..(60 * 24 - 1)
      hour = minute / 60
      return i18n_format.call(hour, :hour)
    else
      day = minute / 60 / 24 
      return i18n_format.call(day, :day)
    end
  end

  def self.months_up_to_now(date_from)
    date_to = self.first_day_in_this_month
    date_from = DateTime.new(date_from.year, date_from.month, 1)
    months = Array.new([DateTime.now - 1.month + 1.day])

    while ((date_to -= 1.month) >= date_from)
      months.push date_to
    end 
    return months
  end
end
