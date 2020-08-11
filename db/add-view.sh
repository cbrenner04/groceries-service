#!/bin/bash

# rails default schema setup does not play well with views
# I often need to rerun the view creation
# this is especially true in CI

psql -h localhost -p 5432 -U $PGUSER -d groceries_service_test -c "DROP VIEW IF EXISTS active_lists;\
CREATE VIEW active_lists AS\
  SELECT lists.id, lists.name, lists.created_at, lists.completed,\
        lists.type, lists.refreshed, lists.owner_id,\
        users_lists.id as users_list_id, users_lists.user_id as user_id,\
        users_lists.has_accepted as has_accepted\
  FROM lists\
  INNER JOIN users_lists\
          ON lists.id = users_lists.list_id\
  WHERE lists.archived_at IS NULL\
  ORDER BY lists.created_at DESC;"
