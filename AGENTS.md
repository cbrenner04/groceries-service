# AGENTS.md — groceries-service

---

# 🚨 Repository Operating Rules (MANDATORY)

These rules extend the root AGENTS.md and must be followed.

## Priority Order
1. Active Spec (if present)
2. Root AGENTS.md
3. This file

## Core Rules
- You MUST follow the active spec exactly
- Do NOT expand or reinterpret scope
- Do NOT read additional files unless required by the spec
- Do NOT refactor unrelated code
- Do NOT introduce new abstractions unless explicitly required

---

## Execution Modes

### PLAN MODE
- Identify exact files within this repository
- Do NOT modify files
- Call out:
  - API changes
  - Database changes
  - Cross-repo impacts

### PATCH MODE
- Modify ONLY files listed in the spec
- Execute steps exactly as written
- Do NOT add, remove, or reorder steps
- If a step is unclear: STOP and ask (do not infer)

---

## 📄 Spec Integration

- All non-trivial work must be driven by a spec in `/specs/`
- This repository executes ONLY its portion of the spec
- Ignore spec steps for other repositories unless instructed

### File Scope Enforcement
- Only modify files explicitly listed in the spec
- If additional files seem required:
  - STOP
  - ASK before proceeding

---

## 🔒 Change Boundaries

- Do NOT modify:
  - Unrelated models, controllers, or services
  - Existing API response shapes
  - Authentication behavior
- Do NOT rename or move files unless specified
- Do NOT update tests unless required by the spec

---

## 🧱 Database & Migration Rules (CRITICAL)

- Do NOT run migrations
- Do NOT generate migrations unless explicitly instructed
- If schema changes are required:
  - Propose migration in PLAN MODE only

### Safety Requirements
- Migrations must be backward compatible
- Avoid destructive changes (drops, renames) unless explicitly approved
- Consider existing data at all times

---

## 🌐 API Contract Rules (CRITICAL)

- Do NOT change request/response shapes
- Do NOT remove or rename fields
- Do NOT change status codes

If a contract change is required:
- STOP
- Call it out in PLAN MODE
- Wait for approval

---

## 🔐 Auth & Security Rules

- Do NOT bypass authentication
- Protected routes must use `ProtectedRouteController` or equivalent
- Do NOT expose sensitive data in JSON responses

---

## Commands

### Environment Setup
```bash
bundle install
bin/setup
```

### Development & Database

```bash
rails server
rails db:migrate
rails db:rollback
rails db:seed
rails db:migrate:status
```

### Testing (RSpec)

```bash
bundle exec rspec
bundle exec rspec <path_to_spec>
bundle exec rspec <path_to_spec>:<line_number>
bundle exec rspec spec/integration
```

### Linting & Security

```bash
bundle exec rubocop
bundle exec rubocop -a
brakeman
bundle audit
```

---

## Required After Changes (PATCH MODE)

```bash
bundle exec rubocop && bundle exec rspec
```

* Do NOT run additional commands unless specified in the spec

---

## Tech Stack

* Ruby 3.4.8
* Rails 8.1.x
* PostgreSQL + Scenic (views)
* Devise + Devise Token Auth + Devise Invitable
* Sentry, New Relic

---

## Code Style

### General Ruby/Rails

* 2-space indentation
* `snake_case` (methods/vars), `CamelCase` (classes/modules)
* `# frozen_string_literal: true` required
* Max line length: 120
* Prefer double quotes

### Controllers

* Use `v2` namespace for new functionality
* Strong params: `params.expect(...)`
* Error handling:

  ```ruby
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_content
  ```

### Models

* Keep schema annotations
* Include validations
* Use `dependent: :destroy` where appropriate
* Use lambda scopes

### Services

* Located in `app/services/`
* Prefer class methods for stateless logic

### Database Views

* Managed via Scenic
* SQL in `db/views/`
* Versioned via migrations

---

## Testing

### Rules

* Only modify or add tests if required by the spec
* Do NOT expand test scope
* Do NOT rewrite tests to match unintended behavior

### Standards

* RSpec
* FactoryBot
* database_cleaner
* simplecov (coverage in `coverage/`)

---

## Important Patterns

### Controller Example

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
      # ...
    end
  end
end
```

---

## Code Review Checklist

* RuboCop passes
* RSpec tests added where required
* Strong params used
* Correct HTTP status codes
* No unintended API changes
* No unsafe migrations
* Auth properly enforced

---

## Do NOT

* Run database migrations
* Modify API contracts without approval
* Introduce breaking changes
* Bypass authentication
* Commit changes unless instructed
