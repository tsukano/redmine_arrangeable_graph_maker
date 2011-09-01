class AdvancedIssue

#  include CompletionGraph
  def initialize(graph_data)
    @graph_data = graph_data
  end

  def count(*arg)
    @graph_data.count(*arg)
  end

end
