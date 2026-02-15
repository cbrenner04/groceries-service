# Agent Instructions for groceries-service

This document provides guidelines and commands for AI agents operating in this repository.

## Commands

### Environment Setup
- `bundle install` - Install Ruby dependencies.
- `bin/setup` - Initial project setup.

### Development & Database
- `rails server` - Start the development API server.
- `rails db:migrate` - Run database migrations.
- `rails db:rollback` - Rollback last migration.
- `rails db:seed` - Seed the database.
- `rails db:migrate:status` - Check migration status.

### Testing (RSpec)
- `bundle exec rspec` - Run all tests.
- `bundle exec rspec <path_to_spec>` - Run a specific spec file.
- `bundle exec rspec <path_to_spec>:<line_number>` - Run a single test at the specified line.
- `bundle exec rspec spec/integration` - Run integration tests.

### Linting & Security
- `bundle exec rubocop` - Run RuboCop linting.
- `bundle exec rubocop -a` - Auto-fix safe linting issues.
- `brakeman` - Run security analysis.
- `bundle audit` - Check for vulnerable dependencies.

## Tech Stack
- **Ruby:** 3.4.8 (as per `Gemfile`)
- **Rails:** 8.1.x (as per `Gemfile`)
- **Database:** PostgreSQL with Scenic for database views.
- **Auth:** Devise, Devise Token Auth, and Devise Invitable.
- **Monitoring:** Sentry (error tracking), New Relic (APM).

## Code Style Guidelines

### General Ruby/Rails
- **Indentation:** 2 spaces.
- **Naming:** `snake_case` for methods and variables; `CamelCase` for classes and modules.
- **Frozen String Literals:** Always include `# frozen_string_literal: true` at the top of every Ruby file.
- **Compact Definitions:** Use compact style for nested classes/modules (e.g., `class Api::V2::ResourceController`).
- **Line Length:** Maximum 120 characters (enforced by RuboCop).
- **Strings:** Prefer double quotes (`"string"`).

### API & Controllers
- **Versioning:** Use `v2` for all new functionality.
- **Parameters:** Use `params.expect(key: [:attr1, :attr2])` for strong parameters (Rails 8+ pattern).
- **Error Handling:** Use `rescue ActiveRecord::RecordInvalid => e` and return `render json: e.record.errors, status: :unprocessable_content`.
- **Status Codes:** Use descriptive status symbols like `:unprocessable_content`, `:created`, `:no_content`, `:not_found`, `:forbidden`.

### Models
- **Schema Information:** Keep the `annotate` gem style comments at the top of models.
- **Validations:** Always include necessary validations.
- **Associations:** Use `dependent: :destroy` for owner associations.
- **Scopes:** Use lambdas for scopes (e.g., `scope :active, -> { where(active: true) }`).

### Services
- **Pattern:** Use class methods for service logic when a stateful instance isn't needed.
- **Location:** Place business logic in `app/services/`.

### Database Views (Scenic)
- Database views are managed via the `scenic` gem.
- SQL definitions are in `db/views/`.
- Use migrations to version views.

## Testing Standards
- **Framework:** RSpec.
- **Factories:** Use `FactoryBot` (factories in `spec/factories/`).
- **Database:** `database_cleaner` is used for isolation.
- **Coverage:** `simplecov` reports coverage in `coverage/`.

## Important Patterns

### Controller Example (Rails 8)
```ruby
class Api::V2::ListsController < ProtectedRouteController
  def create
    @list = ListsService.build_new_list(create_params, current_user)
    if @list.save
      render json: @list, status: :created
    else
      render json: @list.errors, status: :unprocessable_content
    end
  end

  private

  def create_params
    params.expect(list: [:name, :list_item_configuration_id])
  end
end
```

### Service Example
```ruby
class ListsService
  class << self
    def build_new_list(params, user)
      # ... logic ...
    end
  end
end
```

## Code Review Checklist
- RuboCop compliance.
- RSpec tests written for new functionality.
- Strong parameters used (`params.expect`).
- Proper HTTP status codes.
- Database migrations are safe and backward compatible.
- API versioning used appropriately (v2 for new work).
- Security: Brakeman and bundle audit pass.

## Guardrails
- **No Direct Migrations:** Do not run migrations directly unless specifically asked. Suggest the migration content instead.
- **API Consistency:** Ensure JSON responses are consistent with existing patterns in `ListsService`.
- **Auth:** Always ensure routes are protected via `ProtectedRouteController` or appropriate `before_action` if they require authentication.
