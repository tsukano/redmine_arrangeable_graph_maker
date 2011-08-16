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
      h = (minute / 60.0).round(1)
      return i18n_format.call(h, :hour)
    else
      d = (minute / 60.0 / 24.0 ).round(1)
      return i18n_format.call(d, :day)
    end
  end
end
