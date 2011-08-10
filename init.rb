require 'redmine'
require 'gruff'
Redmine::Plugin.register :redmine_arrangeable_graph_maker do
  name 'Redmine Arrangeable Graph Maker plugin'
  author 'Ryuma Tsukano'
  description 'チケットを集計したグラフを表示するためのプラグイン'
  version '0.0.1'
  url 'http://www.ibs.inte.co.jp'
  author_url 'http://www.ibs.inte.co.jp'


  project_module :arrangeable_graph_maker do
    permission :view_graph, 
               :graph_maker => [:get_graph, 
                                :get_trend_graph, 
                                :show_trend,
                                :get_long_graph,
                                :show_long, 
                                :get_monthly_graph,
                                :show_completion,
                                :get_completion_graph]
  end

  menu :project_menu, 
       :long_graph, 
       { :controller => 'graph_maker', 
         :action => 'show_long' }, 
       :after => :activity, 
       :param => :project_id

  menu :project_menu,
       :completion_graph,
       { :controller => 'graph_maker',
         :action => 'show_completion'},
       :after => :activity,
       :param => :project_id

  menu :project_menu, 
       :trend_graph, 
       { :controller => 'graph_maker', 
         :action => 'show_trend' }, 
       :after => :activity, 
       :param => :project_id


end

