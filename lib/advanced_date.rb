class AdvancedDate

  def self.first_day_in_this_month
    DateTime.new(DateTime.now.year, DateTime.now.month, 1)
  end

  def self.last_day_in_this_month
    self.first_day_in_this_month + 1.months - 1.days
  end

  def self.get_formatted_time(minute, less_or_more_than)

    i18n_format = lambda do |time, format|
      time.to_s + 
      I18n.t("graph_items.#{format.to_s}") +
      I18n.t("graph_items.#{less_or_more_than}")
    end
    case minute
    when 0..59
      return i18n_format.call(minute, :minute)
    when 60..(60 * 24 - 1)
      return i18n_format.call(minute / 60, :hour)
    else
      return i18n_format.call(minute / 60 / 24, :day)
    end
  end
end
