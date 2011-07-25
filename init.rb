require 'redmine'

Redmine::Plugin.register :redmine_arrangeable_graph_maker do
  name 'Redmine Arrangeable Graph Maker plugin'
  author 'Ryuma Tsukano'
  description 'チケットを集計したグラフを表示するためのプラグイン'
  version '0.0.1'
  url 'http://www.ibs.inte.co.jp'
  author_url 'http://www.ibs.inte.co.jp'


  project_module :arrangeable_graph_maker do
    permission :view_graph, :graph_maker => :index 
  end

  menu :project_menu,
       :graph,
       { :controller => 'graph_maker', 
         :action => 'index' },
       :caption => 'グラフ',
       :after => :activity,
       :param => :project_id


end
