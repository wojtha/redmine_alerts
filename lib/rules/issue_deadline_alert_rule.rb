class IssueDeadlineAlertRule < AlertRule::Base

  # Initialize class variables
  self.entity = 'Issue'
  self.description = 'Watch for issue overdue'
  self.units = 'days'

  # See AlertRule::Base.query
  def query(alert)
    issue_date = Date.today + alert.delta.to_int

    cond = ARCondition.new
    cond << ["#{IssueStatus.table_name}.is_closed = ?", false]
    cond << ["#{Issue.table_name}.due_date <= ?", issue_date.to_s]
    cond << ["#{Issue.table_name}.project_id IN (?)", alert.project_ids] unless alert.apply_to_all_projects?
    Issue.find(:all,
      :include => [:status, :assigned_to, :project],
      :conditions => cond.conditions
    )
  end

  def render_description(alert)
    delta = alert.delta.respond_to?(:to_i) ? 0 : alert.delta.to_i
    description << if delta < 0
      " #{delta.abs} dní před"
    elsif delta > 0
      " #{delta} dní po"
    else
      ""
    end
  end

  def render_report(alert, issue)
    delta = alert.delta.respond_to?(:to_i) ? 0 : alert.delta.to_i
    issue_link = "<a href=\"#{url_for(:controller => 'issues', :action => 'show', :id => issue.id)}\">#{h(issue.subject)}</a>"

    if delta < 0
      "Úkol #{issue_link} je #{delta.abs} dní před termínem dokončení."
    elsif delta > 0
      "Úkol #{issue_link} je #{delta} dní po termínu dokončení.".sub('%delta%', delta.to_s)
    else
      "Úkol #{issue_link} překročil termín dokončení."
    end
  end

end