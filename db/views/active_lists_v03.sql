SELECT lists.id, lists.name, lists.created_at, lists.completed, lists.type, lists.refreshed, lists.owner_id,
       users_lists.id as users_list_id, users_lists.user_id as user_id, users_lists.has_accepted as has_accepted,
       users_lists.prev_id as prev_id, users_lists.next_id as next_id,
       lists.list_item_configuration_id as list_item_configuration_id
FROM lists
INNER JOIN users_lists
        ON lists.id = users_lists.list_id
WHERE lists.archived_at IS NULL
ORDER BY lists.created_at DESC;
