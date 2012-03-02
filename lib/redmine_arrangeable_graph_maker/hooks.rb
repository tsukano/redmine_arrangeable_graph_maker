module RedmineArrangeableGraphMaker
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_planning_bottom,
              :partial => 'hooks/redmine_arrangeable_graph_maker/view_issues_sidebar_planning_bottom'
  end
end

