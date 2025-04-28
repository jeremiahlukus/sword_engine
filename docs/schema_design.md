# Bible Explorer - Schema Design Document

## Overview
This document outlines the database schema design for the Bible Explorer application, detailing the data models, relationships, and storage strategies used throughout the application.

## Database Architecture

### PostgreSQL Database
The application uses PostgreSQL as its primary database for storing user data and cached Bible content.

#### Core Models

##### User
```ruby
class User < ApplicationRecord
  # Devise authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :bookmarks
  has_many :notes
  has_many :reading_history_entries

  # Fields
  string :email, null: false
  string :encrypted_password, null: false
  string :name
  string :preferred_bible_version
  jsonb :settings, default: {}
  datetime :last_login_at
  datetime :created_at
  datetime :updated_at

  # Indexes
  add_index :email, unique: true
  add_index :created_at
end
```

##### Bookmark
```ruby
class Bookmark < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :bible_reference

  # Fields
  string :title
  string :description
  string :color
  datetime :created_at
  datetime :updated_at

  # Indexes
  add_index :user_id
  add_index :bible_reference_id
  add_index :created_at
end
```

##### Note
```ruby
class Note < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :bible_reference

  # Fields
  text :content
  string :title
  string :tags, array: true
  datetime :created_at
  datetime :updated_at

  # Indexes
  add_index :user_id
  add_index :bible_reference_id
  add_index :created_at
  add_index :tags, using: 'gin'
end
```

##### BibleReference
```ruby
class BibleReference < ApplicationRecord
  # Fields
  string :book
  integer :chapter
  integer :verse
  string :version
  text :content
  jsonb :metadata
  datetime :created_at
  datetime :updated_at

  # Indexes
  add_index [:book, :chapter, :verse, :version], unique: true
  add_index :created_at
end
```

##### ReadingHistory
```ruby
class ReadingHistory < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :bible_reference

  # Fields
  integer :duration_seconds
  datetime :read_at
  datetime :created_at
  datetime :updated_at

  # Indexes
  add_index :user_id
  add_index :bible_reference_id
  add_index :read_at
end
```

### Redis Cache
Redis is used for caching Bible content and improving performance.

#### Cache Keys
```ruby
# Bible content cache
"bible:content:#{version}:#{book}:#{chapter}:#{verse}"
"bible:book:#{version}:#{book}"
"bible:chapter:#{version}:#{book}:#{chapter}"

# User preferences cache
"user:preferences:#{user_id}"
"user:recent_books:#{user_id}"
```

### SWORD Engine Integration
The SWORD Engine runs in a Docker container and provides the primary Bible content.

#### API Endpoints
```ruby
# Bible content endpoints
GET /api/v1/bible/books
GET /api/v1/bible/books/:book/chapters
GET /api/v1/bible/books/:book/chapters/:chapter/verses
GET /api/v1/bible/books/:book/chapters/:chapter/verses/:verse

# Search endpoints
GET /api/v1/bible/search
GET /api/v1/bible/advanced_search
```

## Relationships

### One-to-Many Relationships
- User → Bookmarks
- User → Notes
- User → ReadingHistory
- BibleReference → Bookmarks
- BibleReference → Notes
- BibleReference → ReadingHistory

### Many-to-Many Relationships
- Notes ↔ Tags (through array column)

## Indexes

### PostgreSQL Indexes
```sql
-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Bookmark indexes
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_bible_reference_id ON bookmarks(bible_reference_id);
CREATE INDEX idx_bookmarks_created_at ON bookmarks(created_at);

-- Note indexes
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_bible_reference_id ON notes(bible_reference_id);
CREATE INDEX idx_notes_created_at ON notes(created_at);
CREATE INDEX idx_notes_tags ON notes USING GIN(tags);

-- BibleReference indexes
CREATE UNIQUE INDEX idx_bible_references_unique ON bible_references(book, chapter, verse, version);
CREATE INDEX idx_bible_references_created_at ON bible_references(created_at);

-- ReadingHistory indexes
CREATE INDEX idx_reading_history_user_id ON reading_history(user_id);
CREATE INDEX idx_reading_history_bible_reference_id ON reading_history(bible_reference_id);
CREATE INDEX idx_reading_history_read_at ON reading_history(read_at);
```

## Data Synchronization

### Cache Strategy
1. Check Redis cache first
2. If not found, query SWORD Engine
3. Cache results in Redis
4. Store frequently accessed content in PostgreSQL

### Cache Rules
```ruby
# Cache configuration
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  namespace: 'bible_explorer',
  expires_in: 1.day
}

# Cache keys
CACHE_KEYS = {
  bible_content: 'bible:content:%{version}:%{book}:%{chapter}:%{verse}',
  bible_book: 'bible:book:%{version}:%{book}',
  bible_chapter: 'bible:chapter:%{version}:%{book}:%{chapter}'
}
```

## Performance Considerations

### Indexing Strategy
- Compound indexes for common queries
- Partial indexes for frequently accessed data
- Regular index maintenance

### Caching Strategy
- Redis for Bible content
- PostgreSQL for user data
- Cache invalidation rules

### Query Optimization
- Pagination for large result sets
- Eager loading for associations
- Batch operations for bulk updates

## Security Considerations

### Data Protection
- Encryption at rest
- Secure transmission
- Access control
- Data validation

### Privacy
- User data isolation
- Access controls
- Data retention policies
- GDPR compliance

## Backup and Recovery

### Backup Strategy
- Regular database backups
- Redis persistence
- Versioned backups
- Recovery testing

### Disaster Recovery
- Point-in-time recovery
- Data integrity checks
- Recovery procedures
- Testing schedule

## Monitoring and Maintenance

### Health Checks
- Database connectivity
- Cache status
- Index health
- Query performance

### Maintenance Tasks
- Regular index optimization
- Cache cleanup
- Performance monitoring
- Security audits 