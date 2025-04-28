# Cursor AI Rules for Rails Applications

## Project Overview
This document defines the rules and guidelines for Cursor AI when working with Ruby on Rails applications deployed on AWS Lambda using Lamby. These rules ensure consistent, maintainable, and secure code generation.

## Project Context
This document defines the rules and guidelines for Cursor AI when working with Rails applications in a serverless environment, ensuring best practices and consistent code generation.

### Technical Stack
- Framework: Ruby on Rails
- Serverless Platform: AWS Lambda (via Lamby)
- Database: PostgreSQL
- Key Dependencies:
  - devise: Authentication
  - pundit: Authorization
  - rspec: Testing
  - lambdakiq: Background jobs with SQS
  - redis: Caching
  - rubocop: Code linting

## Code Generation Rules

### 1. Project Structure
Follow these directory and file organization rules:
```
app/
├── assets/          # Static assets
├── channels/        # Action Cable channels
├── controllers/     # Controllers
├── jobs/           # Active Job classes
├── mailers/        # Mailer classes
├── models/         # Models
├── services/       # Service objects
├── uploaders/      # CarrierWave uploaders
└── views/          # View templates
├── config/         # Configuration files
├── db/             # Database migrations
├── lib/            # Library code
├── spec/           # RSpec tests
└── test/           # Test files
```

File Naming Rules:
- Use snake_case for file names
- Suffix controller files with `_controller.rb`
- Suffix model files with `.rb`
- Suffix view files with `.html.erb` or `.html.haml`
- Suffix service files with `_service.rb`
- Suffix job files with `_job.rb`

Import Order:
1. Standard library imports
2. Third-party gem imports
3. Local application imports

### 2. Code Style
Adhere to these formatting rules:
- Use 2 spaces for indentation
- Maximum line length: 80 characters
- Use single quotes for strings unless interpolation is needed
- Use parentheses for method calls with arguments
- Use trailing commas in multi-line collections
- One blank line between methods
- Two blank lines between classes

Example:
```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_one :profile

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end
```

### 3. Component Guidelines
When generating components:
- Use service objects for complex business logic
- Implement proper error handling with begin-rescue blocks
- Use concerns for shared functionality
- Keep controllers thin
- Use form objects for complex forms
- Implement proper validation
- Use callbacks judiciously

Example:
```ruby
class UserRegistrationService
  def initialize(user_params)
    @user_params = user_params
  end

  def call
    begin
      user = User.new(@user_params)
      user.save!
      UserMailer.welcome(user).deliver_later
      user
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("User registration failed: #{e.message}")
      raise RegistrationError, "Unable to register user"
    end
  end
end
```

### 4. Type System
For Ruby implementation:
- Use YARD documentation for complex methods
- Document method parameters and return types
- Use descriptive variable names
- Use proper type checking
- Implement proper validation
- Use strong parameters
- Document complex data structures

Example:
```ruby
# @param user_params [Hash] User attributes
# @return [User] The created user
# @raise [RegistrationError] If registration fails
def create_user(user_params)
  # Implementation
end
```

### 5. API Integration
When working with APIs:
- Store API keys in environment variables
- Use secure storage for sensitive data
- Implement proper error handling
- Validate all user inputs
- Use proper HTTP status codes
- Document API endpoints
- Implement proper caching

Example:
```ruby
class PaymentService
  def initialize
    @api_key = ENV['PAYMENT_API_KEY']
    raise "PAYMENT_API_KEY not found" unless @api_key
  end

  def process_payment(amount)
    # Implementation
  end
end
```

### 6. State Management
For managing application state:
- Use proper database transactions
- Implement proper locking mechanisms
- Use Lambdakiq for background jobs with SQS
- Implement proper caching
- Use proper session management
- Document state changes
- Optimize database queries

Example:
```ruby
class OrderProcessor
  def process_order(order)
    ActiveRecord::Base.transaction do
      order.lock!
      # Process order
    end
  end
end

# Background job example with Lambdakiq
class ProcessOrderJob < ApplicationJob
  queue_as ENV['JOBS_QUEUE_NAME']

  def perform(order_id)
    order = Order.find(order_id)
    OrderProcessor.new.process_order(order)
  end
end
```

### 7. Testing Requirements
Generate tests following these rules:
- Place tests in `spec/` directory
- Mirror the app/ directory structure
- Name test files with `_spec.rb` suffix
- Write comprehensive unit tests
- Test error scenarios
- Maintain test coverage
- Document test cases
- Test Lambdakiq jobs with proper SQS queue configuration

Example:
```ruby
RSpec.describe ProcessOrderJob, type: :job do
  let(:order) { create(:order) }

  describe '#perform' do
    it 'processes the order' do
      expect_any_instance_of(OrderProcessor).to receive(:process_order).with(order)
      described_class.perform_now(order.id)
    end

    it 'handles errors gracefully' do
      allow_any_instance_of(OrderProcessor).to receive(:process_order).and_raise(StandardError)
      expect { described_class.perform_now(order.id) }.to raise_error(StandardError)
    end
  end
end
```

### 8. Security Guidelines
Enforce security practices:
- Store API keys in environment variables
- Use secure storage for sensitive data
- Implement proper error handling
- Validate all user inputs
- Use Devise for authentication
- Use Pundit for authorization
- Implement proper CSRF protection
- Use secure session management

### 9. Performance Rules
Optimize for performance:
- Use proper database indexes
- Implement eager loading
- Use counter caches
- Optimize database queries
- Implement proper caching
- Use Lambdakiq for background jobs with proper SQS configuration
- Optimize asset loading
- Monitor performance metrics with CloudWatch
- Configure proper Lambda memory and timeout settings
- Use proper SQS batch sizes and visibility timeouts

Example:
```ruby
# Configure Lambdakiq for optimal performance
config.lambdakiq.max_retries = 3
config.lambdakiq.metrics_namespace = 'MyApp'
config.lambdakiq.metrics_logger = Rails.logger

# Job-specific configuration
class ProcessOrderJob < ApplicationJob
  lambdakiq_options retry: 2
  queue_as ENV['JOBS_QUEUE_NAME']
end
```

### 10. Documentation
Generate documentation that:
- Is clear and concise
- Includes proper YARD documentation
- Provides usage examples
- Documents edge cases
- Explains complex logic
- Includes type information
- Follows documentation standards

Example:
```ruby
# Handles user authentication and authorization.
#
# This service provides methods for user authentication,
# password management, and session handling.
class AuthenticationService
  # Implementation
end
```

## Best Practices

### 1. Code Quality
- Write self-documenting code
- Keep methods focused and small
- Use meaningful variable names
- Handle errors appropriately
- Follow SOLID principles
- Write maintainable code

### 2. Performance
- Optimize database queries
- Implement proper caching
- Use background jobs
- Optimize asset loading
- Monitor performance metrics
- Follow performance best practices

### 3. Security
- Store API keys in environment variables
- Use secure storage for sensitive data
- Implement proper error handling
- Validate all user inputs
- Use Devise for authentication
- Use Pundit for authorization
- Implement proper CSRF protection
- Use secure session management 