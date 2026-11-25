SELECT
  date_trunc('WEEK', event_time)       AS usage_week,
  service_name,
  COUNT(DISTINCT user_identity.email)  AS active_users,
  COUNT(*)                             AS events
FROM system.access.audit
WHERE event_time >= current_date() - INTERVAL 90 DAYS
  AND ((service_name = 'dashboards' AND action_name = 'getPublishedDashboard')
    OR (service_name = 'aibiGenie'
        AND action_name IN ('genieStartConversationMessage', 'genieCreateConversationMessage')))
GROUP BY ALL
ORDER BY usage_week, service_name;
