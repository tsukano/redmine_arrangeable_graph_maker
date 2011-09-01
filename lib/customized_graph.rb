class CustomizedGraph

  GRAPH_CONFIG = YAML.load_file(File.dirname(__FILE__) + '/../config/config.yml')

  def initialize(title, size, gruff_class)
    @gruff = gruff_class.new size
    @gruff.title = title
    @gruff.font = GRAPH_CONFIG["graph_font_path"] 
    
    @gruff.theme = {
      :colors => [ "#EC5050",
                   "#73B373",
                   "#6D53EE",
                   "#EB7A55",
                   "#9467C3",
                   "#5FBCED",
                   "#E863AE",
                   "#EBAE46",
                   "#B8954D",
                   "#B84D4E"],
      :marker_color => "#D8DDEA",
      :background_colors => %w[#FFFFFF #D8E4E4],
      :font_color => "#345B9A"}

    case gruff_class.to_s
    when 'Gruff::Pie'
      @gruff.zero_degree = -90
    end

  end

  def push_data(group, value)
    @gruff.data(group, value)
  end

  def push_label(label)
    @gruff.labels.store(@gruff.labels.size, label)
  end

  def set_labels_from_array(label_array)
    label_array.each { |label| push_label(label) }
  end

  def blob
    
    case @gruff.maximum_value
    when 1..2
      @gruff.marker_count = @gruff.maximum_value
    end

    return @gruff.to_blob()
  end
end
