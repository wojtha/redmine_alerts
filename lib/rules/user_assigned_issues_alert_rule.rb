class UserAssignedIssuesAlertRule < AlertRule::Base

  # Initialize class variables
  self.entity = 'User'
  self.description = 'Watch for number of issues assigned to user'
  self.units = 'issues'

  # See AlertRule::Base.query
  def query(alert)
    number = alert.delta.respond_to?(:to_i) ? alert.delta.to_i : 0

    User.find_by_sql("SELECT users.*, COUNT(#{Issue.table_name}.assigned_to_id) AS user_issues_count FROM #{Issue.table_name}
      INNER JOIN #{User.table_name} ON #{Issue.table_name}.assigned_to_id = #{User.table_name}.id
      INNER JOIN #{IssueStatus.table_name} ON #{IssueStatus.table_name}.id = #{Issue.table_name}.status_id
      WHERE #{IssueStatus.table_name}.is_closed = 0
      GROUP BY #{Issue.table_name}.assigned_to_id
      HAVING user_issues_count >= #{number};")
  end

  def render_description(alert)
    delta = alert.delta ? alert.delta.to_i : 0
    "Watch for more than #{delta} of issues assigned to user"
  end

  def render_report(alert, user)
    number = alert.delta.respond_to?(:to_i) ? alert.delta.to_i : 0
    user_link = "<a href=\"#{url_for(:controller => 'users', :action => 'show', :id => user.id)}\">#{h(user.login)}</a>"
    "Uživatel #{user.firstname} #{user.lastname} (#{user_link}) překročil #{number} otevřených úkolů."
  end

end