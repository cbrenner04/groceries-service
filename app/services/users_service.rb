# frozen_string_literal: true

# service object for Users
module UsersService
  # NOTE: find_by_sql (which is what these queries are being used for) returns the attributes in the select statement
  #       as attributes of the model. This is not actually the model's record so you will not be able to save, update,
  #       etc on these records like a normal model record. These are good for gets but will need to be manipulated to
  #       behave like active record model records

  # TODO: remove after migrations are complete for DND
  # :nocov:
  def completed_accepted_lists_query__old__(user_id)
    "#{accepted_lists_query__old__(user_id)} AND completed = true"
  end
  # :nocov:

  def completed_accepted_lists_query(user_id)
    "#{accepted_lists_query(user_id)} AND completed = true"
  end

  # TODO: remove after migrations are complete for DND
  # :nocov:
  def limited_completed_accepted_lists_query__old__(user_id)
    "#{completed_accepted_lists_query__old__(user_id)} LIMIT 10"
  end
  # :nocov:

  def limited_completed_accepted_lists_query(user_id)
    "#{completed_accepted_lists_query(user_id)} LIMIT 10"
  end

  # TODO: remove after migrations are complete for DND
  # :nocov:
  def not_completed_accepted_lists_query__old__(user_id)
    "#{accepted_lists_query__old__(user_id)} AND completed = false"
  end
  # :nocov:

  def not_completed_accepted_lists_query(user_id)
    "#{accepted_lists_query(user_id)} AND completed = false"
  end

  # TODO: remove after migrations are complete for DND
  # :nocov:
  def pending_lists_query__old__(user_id)
    <<-SQL.squish
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted, user_id, users_list_id, created_at
      FROM active_lists
      WHERE user_id = '#{user_id}'
      AND has_accepted IS NULL
    SQL
  end
  # :nocov:

  def pending_lists_query(user_id)
    <<-SQL.squish
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted, user_id, users_list_id, created_at,
             prev_id, next_id
      FROM active_lists
      WHERE user_id = '#{user_id}'
      AND has_accepted IS NULL
    SQL
  end

  # rubocop:disable Metrics/MethodLength
  def write_lists_query(user_id)
    <<-SQL.squish
      SELECT "active_lists"."id", "active_lists"."name", "active_lists"."completed", "active_lists"."type",
             "active_lists"."refreshed", "active_lists"."owner_id", "active_lists"."has_accepted",
             "active_lists"."user_id", "active_lists"."users_list_id", "active_lists"."created_at"
      FROM "active_lists"
      INNER JOIN "users_lists"
              ON "active_lists"."users_list_id" = "users_lists"."id"
      WHERE "active_lists"."user_id" = '#{user_id}'
      AND "active_lists"."has_accepted" = true
      AND "users_lists"."permissions" = 'write'
      AND "active_lists"."completed" = false
    SQL
  end

  # Find users where they have been shared on the same lists as current user
  # Filter out users that are already shared on the supplied list
  def related_users_query(user_id, list_id)
    <<-SQL.squish
      SELECT DISTINCT "users"."email", "users"."id"
      FROM "users"
      INNER JOIN "users_lists"
              ON "users"."id" = "users_lists"."user_id"
      WHERE "users_lists"."list_id" IN (
        SELECT "lists"."id"
        FROM "lists"
        INNER JOIN "users_lists"
                ON "lists"."id" = "users_lists"."list_id"
        WHERE "users_lists"."user_id" = '#{user_id}'
      )
      AND NOT "users"."id" IN (
        SELECT "users_lists"."user_id"
        FROM "users_lists"
        WHERE "users_lists"."list_id" = '#{list_id}'
      );
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  private

  # TODO: remove after migrations are complete for DND
  # :nocov:
  def accepted_lists_query__old__(user_id)
    <<-SQL.squish
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted, user_id, users_list_id, created_at
      FROM active_lists
      WHERE user_id = '#{user_id}'
      AND has_accepted = true
    SQL
  end
  # :nocov:

  def accepted_lists_query(user_id)
    <<-SQL.squish
      SELECT id, name, completed, type, refreshed, owner_id, has_accepted,
             user_id, users_list_id, created_at, prev_id, next_id
      FROM active_lists
      WHERE user_id = '#{user_id}'
      AND has_accepted = true
    SQL
  end
end
