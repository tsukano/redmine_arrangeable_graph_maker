module GraphMakerHelper
  def fiscal_year_now(date_time)
    if date_time.month <= 3
      return date_time.year - 1
    else
      return date_time.year
    end
  end
end
