require 'redmine'
require 'gruff'
require 'yaml'

require_dependency "redmine_arrangeable_graph_maker/hooks"
Redmine::Plugin.register :redmine_arrangeable_graph_maker do
  name 'Redmine Arrangeable Graph Maker plugin'
  author 'Ryuma Tsukano'
  description 'チケットを集計したグラフを表示するためのプラグイン'
  version '0.0.1'
  url 'http://www.ibs.inte.co.jp'
  author_url 'http://www.ibs.inte.co.jp'


  project_module :arrangeable_graph_maker do
    permission :view_graph, 
               :graph_maker => [:get_trend_graph, 
                                :get_customize_graph,
                                :get_long_graph,
                                :get_completion_graph,
                                :show_long, 
                                :show_trend,
                                :show_customize,
                                :show_completion]
  end

#  menu :project_menu, 
#       :long_graph, 
#       { :controller => 'graph_maker', 
#         :action => 'show_long' }, 
#       :after => :calendar, 
#       :param => :project_id
#
#  menu :project_menu,
#       :completion_graph,
#       { :controller => 'graph_maker',
#         :action => 'show_completion'},
#       :after => :calendar,
#       :param => :project_id
#
#  menu :project_menu,
#       :customize_graph,
#       { :controller => 'graph_maker',
#         :action => 'show_customize'},
#       :after => :calendar,
#       :param => :project_id
#
#  menu :project_menu, 
#       :trend_graph, 
#       { :controller => 'graph_maker', 
#         :action => 'show_trend' }, 
#       :after => :calendar, 
#       :param => :project_id

end

