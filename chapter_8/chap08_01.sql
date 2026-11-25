SELECT user_identity.email, event_time, action_name
FROM   system.access.audit
WHERE  action_name = 'getTable'
AND    request_params['full_name_arg'] = 'curated.sales.dim_customer'
AND    event_date >= current_date() - INTERVAL 30 DAYS;
