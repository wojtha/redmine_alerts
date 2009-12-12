class IssueTimeTrackerAlertRule < AlertRule::Base

  # Initialize class variables
  self.entity = 'Issue'
  self.description = 'Watch for issue time overdue'
  self.units = 'hours'

  # See AlertRule::Base.query
  def query(alert)
    TimeEntry.find_by_sql("SELECT issues.*, SUM(time_entries.hours) AS hours_sum FROM issues
      INNER JOIN time_entries ON issues.id = time_entries.issue_id
      INNER JOIN issue_statuses ON issue_statuses.id = issues.status_id
      WHERE issue_statuses.is_closed = 0
      GROUP BY time_entries.issue_id
      HAVING hours_sum >= issues.estimated_hours;")
#    cond = ARCondition.new
#    cond << ["#{IssueStatus.table_name}.is_closed = ?", false]
#    cond << ["#{Issue.table_name}.project_id IN (?)", alert.project_ids] unless alert.apply_to_all_projects?
#    Issue.find(:all,
#      :include => [:status, :time_entries, :assigned_to, :project],
#      :conditions => cond.conditions
#      :group => "#{IssueStatus.table_name}.date(created_at)", :having => ["created_at > ?", 1.month.ago]
#    )
  end

  def render_description(alert)
    delta = alert.delta.respond_to?(:to_i) ? alert.delta.to_i : 0
    description << if delta < 0
      " #{delta.abs} hodin před"
    elsif delta > 0
      " #{delta} hodin po"
    else
      ""
    end
  end

  def render_report(alert, issue)
    delta = alert.delta.respond_to?(:to_i) ? alert.delta.to_i : 0
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