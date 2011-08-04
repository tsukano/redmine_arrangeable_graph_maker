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
               :graph_maker => [:index, 
                                :get_graph, 
                                :get_trend_graph, 
                                :show_trend,
                                :get_long_graph,
                                :show_long] 
  end

  menu :project_menu, 
       :long_graph, 
       { :controller => 'graph_maker', 
         :action => 'show_long' }, 
       :caption => '長期遷移G', 
       :after => :activity, 
       :param => :project_id

  menu :project_menu, 
       :trend_graph, 
       { :controller => 'graph_maker', 
         :action => 'show_trend' }, 
       :caption => '傾向分析G', 
       :after => :activity, 
       :param => :project_id

end

