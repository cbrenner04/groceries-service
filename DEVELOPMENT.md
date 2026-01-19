# Backend Development Guidelines

This document outlines the development standards, patterns, and guardrails for the Ruby on Rails API application.

## Technology Stack

- **Framework:** Ruby on Rails 8.0.1+
- **Ruby Version:** 3.4.4
- **Database:** PostgreSQL
- **Authentication:** Devise + Devise Token Auth
- **Testing:** RSpec with FactoryBot
- **Code Quality:** RuboCop, Brakeman, Bundler Audit
- **Monitoring:** Sentry, New Relic

## Code Style & Patterns

### Ruby/Rails Conventions

- Follow Rails conventions for file naming and structure
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Use frozen_string_literal: true at the top of files
- Use proper indentation (2 spaces)

### API Structure

- Use API versioning (v1, v2 namespaces)
- Use Devise for authentication
- Use Devise Token Auth for API authentication
- Use Devise Invitable for user invitations

### Route Patterns

- Use nested resources for related data
- Use lambda functions for reusable route blocks
- Use proper HTTP verbs (GET, POST, PATCH, DELETE)
- Use collection and member routes appropriately

### Controller Patterns

- Use strong parameters for data validation
- Use proper HTTP status codes
- Use JSON responses for API endpoints
- Use concerns for shared functionality

## Testing Standards

### RSpec Configuration

- Use RSpec for all testing
- Use FactoryBot for test data
- Use DatabaseCleaner for test isolation
- Use SimpleCov for coverage reporting

### Test Structure

```text
spec/
├── controllers/           # Controller specs
├── models/               # Model specs
├── services/             # Service specs
├── factories/            # FactoryBot factories
└── support/              # Test helpers and configuration
```

### Test Patterns

- Use descriptive context and describe blocks
- Use proper setup and teardown
- Use shared examples for common patterns
- Use proper mocking and stubbing
- Use database transactions for test isolation

## Code Quality

### RuboCop Configuration

- Use RuboCop for code linting
- Use RuboCop-Rails for Rails-specific rules
- Use RuboCop-RSpec for RSpec-specific rules
- Use RuboCop-FactoryBot for FactoryBot rules
- Use RuboCop-Performance for performance rules

### Security

- Use Brakeman for security analysis
- Use Bundler Audit for dependency security
- Use secure_headers gem for security headers
- Use proper parameter validation

## Database

### Migrations

- Use PostgreSQL as database
- Use Scenic for database views
- Use proper foreign key constraints
- Use timestamps on all tables
- Use proper indexes for performance

### Models

- Use proper associations
- Use validations
- Use callbacks appropriately
- Use scopes for common queries
- Use proper naming conventions

### Database Views

- Use Scenic gem for managing database views
- Keep views in `db/views/` directory
- Version views appropriately
- Document view purposes and dependencies

## API Design

### Versioning

- Use namespace-based versioning (v1, v2)
- v1 for stable endpoints
- v2 for new features and breaking changes
- Maintain backward compatibility when possible

### Response Format

- Use consistent JSON response format
- Use proper HTTP status codes
- Include error messages in consistent format
- Use proper content types

### Authentication

- Use Devise Token Auth for API authentication
- Include proper headers in responses
- Handle token refresh appropriately
- Use proper authorization checks

## Development Workflow

### Scripts

```bash
bundle install               # Install dependencies
rails server                 # Start development server
rspec                        # Run tests
rubocop                      # Run code linting
brakeman                     # Run security analysis
bundle audit                 # Check for vulnerable dependencies
```

### Environment Setup

- Use proper environment variables
- Use database configuration for different environments
- Use proper logging configuration
- Use proper error handling

## Important Notes & Gotchas

- API versioning: use v2 endpoints for all new work
- Use Devise Token Auth for API authentication
- Database migrations must be backward compatible
- Use proper HTTP status codes in API responses
- Use strong parameters for all user input
- Use proper error handling and logging

## Code Review Checklist

- [ ] RuboCop compliance
- [ ] RSpec tests written
- [ ] Strong parameters used
- [ ] Proper HTTP status codes
- [ ] Database migrations are safe
- [ ] API versioning used appropriately
- [ ] Security considerations addressed
- [ ] Performance considerations addressed

## Common Patterns

### Controller Pattern

```ruby
class Api::V2::ResourceController < ApplicationController
  def index
    resources = Resource.all
    render json: resources
  end

  def create
    resource = Resource.new(resource_params)
    if resource.save
      render json: resource, status: :created
    else
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end
  end

  private

  def resource_params
    params.require(:resource).permit(:attribute1, :attribute2)
  end
end
```

### Model Pattern

```ruby
class Resource < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :items, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :description, length: { maximum: 500 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :normalize_name

  private

  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
```

### Service Pattern

```ruby
class ResourceService
  def initialize(user)
    @user = user
  end

  def create_resource(params)
    resource = @user.resources.build(params)
    if resource.save
      { success: true, resource: resource }
    else
      { success: false, errors: resource.errors }
    end
  end

  private

  attr_reader :user
end
```

### Factory Pattern

```ruby
FactoryBot.define do
  factory :resource do
    sequence(:name) { |n| "Resource #{n}" }
    description { "A test resource" }
    association :user
  end
end
```

This document should be updated as the backend codebase evolves and new patterns emerge.
