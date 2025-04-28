# Code Style Guidelines for Rails Applications

## Project Overview
This document defines the coding standards and style guidelines for Ruby on Rails applications to ensure consistency, maintainability, and best practices across the codebase.

### Technical Stack
- Framework: Ruby on Rails
- Database: PostgreSQL
- Key Dependencies:
  - devise: Authentication
  - pundit: Authorization
  - rspec: Testing
  - sidekiq: Background jobs
  - redis: Caching
  - rubocop: Code linting

## Style Guide Sections

### 1. File Organization
Directory Structure:
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

File Naming Conventions:
- Use snake_case for file names
- Suffix controller files with `_controller.rb`
- Suffix model files with `.rb`
- Suffix view files with `.html.erb` or `.html.haml`
- Suffix service files with `_service.rb`
- Suffix job files with `_job.rb`

### 2. Code Formatting
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

### 3. Naming Conventions
- Classes and Modules: PascalCase (e.g., `UserController`)
- Methods and Variables: snake_case (e.g., `find_user_by_email`)
- Constants: SCREAMING_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- Private methods: snake_case (e.g., `_generate_token`)
- Database tables: plural snake_case (e.g., `users`)
- Model names: singular PascalCase (e.g., `User`)

### 4. Ruby Guidelines
Type Annotations:
- Use YARD documentation for complex methods
- Document method parameters and return types
- Use descriptive variable names

Error Handling:
```ruby
def process_payment
  begin
    PaymentProcessor.new(amount: @amount).process
  rescue PaymentError => e
    Rails.logger.error("Payment failed: #{e.message}")
    raise PaymentProcessingError, "Unable to process payment"
  end
end
```

### 5. Rails Guidelines
Controller Structure:
```ruby
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    authorize @user
  end
end
```

Model Structure:
```ruby
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  def publish!
    update!(published: true, published_at: Time.current)
  end
end
```

### 6. Documentation Standards
Class Documentation:
```ruby
# Handles user authentication and authorization.
#
# This service provides methods for user authentication,
# password management, and session handling.
class AuthenticationService
  # Implementation
end
```

Method Documentation:
```ruby
# Creates a new user with the given attributes.
#
# @param attributes [Hash] User attributes
# @return [User] The created user
# @raise [ValidationError] If the user is invalid
def create_user(attributes)
  # Implementation
end
```

### 7. Testing Standards
Test File Organization:
- Place tests in `spec/` directory
- Mirror the app/ directory structure
- Name test files with `_spec.rb` suffix

Test Structure:
```ruby
RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe '#full_name' do
    it 'returns the full name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

### 8. Performance Guidelines
Database:
- Use proper indexes
- Implement eager loading
- Use counter caches
- Optimize queries
- Use database constraints

Caching:
- Implement fragment caching
- Use Russian Doll caching
- Cache expensive computations
- Use Redis for caching

### 9. Security Guidelines
Authentication:
- Use Devise for authentication
- Implement proper password policies
- Use secure session management
- Implement rate limiting

Authorization:
- Use Pundit for authorization
- Implement role-based access control
- Validate all user inputs
- Sanitize output

### 10. Development Workflow
Git Workflow:
- Use feature branches
- Follow conventional commits
- Require PR reviews
- Maintain clean commit history

Branch Naming:
- feature/feature-name
- bugfix/bug-description
- hotfix/issue-description
- release/version-number

Commit Messages:
```
feat: add user authentication
fix: resolve password reset issue
docs: update API documentation
style: format code according to guidelines
```

## Enforcement and Tools

### Linting and Formatting
Gemfile:
```ruby
group :development, :test do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-performance', require: false
end
```

Rubocop Configuration:
```yaml
AllCops:
  TargetRubyVersion: 3.2
  Exclude:
    - 'db/**/*'
    - 'config/**/*'
    - 'script/**/*'
    - 'bin/**/*'
    - 'vendor/**/*'

Style/Documentation:
  Enabled: false

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/routes.rb'
```

### IDE Configuration
VS Code Settings:
```json
{
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

## Best Practices

### 1. Code Quality
- Follow SOLID principles
- Keep methods focused and small
- Use meaningful variable names
- Handle errors appropriately
- Write self-documenting code

### 2. Performance
- Optimize database queries
- Implement proper caching
- Use background jobs
- Optimize asset loading
- Monitor performance metrics

### 3. Maintainability
- Write clear documentation
- Use consistent patterns
- Keep dependencies updated
- Follow DRY principles
- Implement proper error handling

### 4. Collaboration
- Write clear commit messages
- Document breaking changes
- Review code thoroughly
- Share knowledge
- Maintain clean codebase 