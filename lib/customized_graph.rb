class CustomizedGraph

  def initialize(title, size, gruff_class)
    @gruff = gruff_class.new size
    @gruff.title = title
    @gruff.font = "/usr/share/fonts/japanese/TrueType/sazanami-gothic.ttf"
    @gruff.theme_37signals
  end

  def push_data(group, value)
    @gruff.data(group, value)
  end

  def push_label(label)
    @gruff.labels.store(@gruff.labels.size, label)
  end

  def blob
    return @gruff.to_blob()
  end

end
