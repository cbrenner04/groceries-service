# frozen_string_literal: true

# service object for Users
module UsersService
  def completed_accepted_lists_query(user_id)
    "#{accepted_lists_query(user_id)} AND completed = true"
  end

  def limited_completed_accepted_lists_query(user_id)
    "#{completed_accepted_lists_query(user_id)} LIMIT 10"
  end

  def not_completed_accepted_lists_query(user_id)
    "#{accepted_lists_query(user_id)} AND completed = false"
  end

  def pending_lists_query(user_id)
    <<-SQL
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted,
             user_id, users_list_id, created_at
      FROM active_lists
      WHERE user_id = #{user_id}
      AND has_accepted IS NULL
    SQL
  end

  def write_lists_query(_user_id)
    <<-SQL
      SELECT "active_lists"."id", "active_lists"."name",
             "active_lists"."completed", "active_lists"."type",
             "active_lists"."refreshed", "active_lists"."owner_id",
             "active_lists"."has_accepted", "active_lists"."user_id",
             "active_lists"."users_list_id", "active_lists"."created_at"
      FROM "active_lists"
      INNER JOIN "users_lists"
              ON "active_lists"."users_list_id" = "users_lists"."id"
      WHERE "active_lists"."user_id" = 1
      AND "active_lists"."has_accepted" = true
      AND "users_lists"."permissions" = 'write'
      AND "active_lists"."completed" = false
    SQL
  end

  # Find users where they have been shared on the same lists as current user
  # Filter out users that are already shared on the supplied list
  def related_users_query(user_id, list_id)
    <<-SQL
      SELECT DISTINCT "users"."email", "users"."id"
      FROM "users"
      INNER JOIN "users_lists"
              ON "users"."id" = "users_lists"."user_id"
      WHERE "users_lists"."list_id" IN (
        SELECT "lists"."id"
        FROM "lists"
        INNER JOIN "users_lists"
                ON "lists"."id" = "users_lists"."list_id"
        WHERE "users_lists"."user_id" = #{user_id}
      )
      AND NOT "users"."id" IN (
        SELECT "users_lists"."user_id"
        FROM "users_lists"
        WHERE "users_lists"."list_id" = #{list_id}
      );
    SQL
  end

  private

  def accepted_lists_query(user_id)
    <<-SQL
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted,
             user_id, users_list_id, created_at
      FROM active_lists
      WHERE user_id = #{user_id}
      AND has_accepted = true
    SQL
  end
end
