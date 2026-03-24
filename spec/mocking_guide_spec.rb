# spec/mocking_guide_spec.rb
# ============================================================
# RSPEC MOCKING & STUBBING GUIDE
# ============================================================
# This file teaches you different mocking techniques in RSpec
# Run with: bundle exec rspec spec/mocking_guide_spec.rb
# ============================================================

require 'rails_helper'

RSpec.describe "RSpec Mocking & Stubbing Tutorial" do

  # ============================================================
  # SECTION 1: TEST DOUBLES
  # ============================================================
  # A "double" is a fake object that stands in for a real object.
  # Use when you don't need the real object or it would be slow/complex.
  # ============================================================

  describe "Test Doubles" do
    it "creates a simple double (fake object)" do
      # Double is like a "skeleton" object - no real methods
      fake_user = double("User")

      # You can set up methods on it
      allow(fake_user).to receive(:name).and_return("Alice")
      allow(fake_user).to receive(:email).and_return("alice@example.com")

      expect(fake_user.name).to eq("Alice")
      expect(fake_user.email).to eq("alice@example.com")
    end

    it "creates a double with predefined methods" do
      # Use hash syntax to define methods upfront
      fake_user = double("User",
                         name: "Bob",
                         email: "bob@example.com"
                        )

      expect(fake_user.name).to eq("Bob")
      expect(fake_user.email).to eq("bob@example.com")
    end

    it "creates a record double (checks methods exist on real class)" do
      # instance_double verifies the double has methods that match the real class
      # This is SAFER than double - it will fail if you use wrong method names
      fake_user = instance_double(User, name: "Charlie", id: 1)

      expect(fake_user.name).to eq("Charlie")
      expect(fake_user.id).to eq(1)
    end

    it "creates a class double (stubs class methods)" do
      # class_double verifies against the actual class methods
      fake_class = class_double("User", count: 42).as_stubbed_const

      expect(User).to receive(:count).and_return(42)
      expect(User.count).to eq(42)
    end
  end

  # ============================================================
  # SECTION 2: STUBBING METHODS
  # ============================================================
  # Stubbing = Replace a method's return value with something else
  # Use when you want to control what a method returns
  # ============================================================

  describe "Stubbing Methods" do
    it "stubs a method with allow()" do
      # allow(obj).to receive(:method).and_return(value)
      # This temporarily replaces the method's return value

      user = User.new(name: "Dave")

      allow(user).to receive(:greeting).and_return("Hello, Dave!")

      expect(user.greeting).to eq("Hello, Dave!")
      # Note: greeting doesn't exist on User, but we stubbed it
    end

    it "stubs a method to return different values on consecutive calls" do
      counter = double("Counter")

      # First call returns 1, second call returns 2, etc.
      allow(counter).to receive(:next).and_return(1, 2, 3)

      expect(counter.next).to eq(1)
      expect(counter.next).to eq(2)
      expect(counter.next).to eq(3)
    end

    it "stubs with a block/lambda for dynamic returns" do
      fake_user = double("User")
      call_count = 0

      allow(fake_user).to receive(:id) do
        call_count += 1
        call_count
      end

      expect(fake_user.id).to eq(1)
      expect(fake_user.id).to eq(2)
      expect(fake_user.id).to eq(3)
    end

    it "stubs a class method" do
      # Stub User.count to return 5 without creating real users
      allow(User).to receive(:count).and_return(5)

      expect(User.count).to eq(5)
    end

    it "stubs association methods" do
      # Create a real user but stub its posts association
      user = User.create!(name: "Eve")
      fake_post = double("Post", title: "Fake Post", body: "Fake Body")

      allow(user).to receive(:posts).and_return([fake_post])

      expect(user.posts.first.title).to eq("Fake Post")
      expect(user.posts.count).to eq(1)
    end
  end

  # ============================================================
  # SECTION 3: MESSAGE EXPECTATIONS (MOCKS)
  # ============================================================
  # Mocks = Expect that a method IS called during the test
  # Use when you need to verify interactions happened
  # ============================================================

  describe "Message Expectations (Mocks)" do
    it "expects a message to be received" do
      # expect(obj).to receive(:method) = "This MUST be called"
      user = User.new(name: "Frank")

      expect(user).to receive(:name)
      expect(user).to receive(:to_s)

      user.name
      user.to_s
    end

    it "expects a message with specific arguments" do
      notifier = double("Notifier")

      expect(notifier).to receive(:send_email).with("test@example.com", "Hello!")

      notifier.send_email("test@example.com", "Hello!")
    end

    it "expects a message to be called once by default" do
      calculator = double("Calculator")
      allow(calculator).to receive(:add).and_return(5)

      calculator.add(2, 3)

      # This would FAIL:
      # calculator.add(2, 3)  # Called twice, expected once
    end

    it "expects a message to be called a specific number of times" do
      counter = double("Counter")
      allow(counter).to receive(:increment).and_return(1)

      counter.increment
      counter.increment
      counter.increment

      expect(counter).to have_received(:increment).exactly(3).times
    end

    it "expects a message at least once" do
      logger = double("Logger")
      allow(logger).to receive(:log).and_return(nil)

      5.times { logger.log("message") }

      expect(logger).to have_received(:log).at_least(:once)
    end
  end

  # ============================================================
  # SECTION 4: PARTIAL DOUBLING (SPYING ON REAL OBJECTS)
  # ============================================================
  # Partial doubles stub specific methods while keeping others real
  # ============================================================

  describe "Partial Doubles (Spies on Real Objects)" do
    it "stubs a method on a real object while keeping others real" do
      user = User.create!(name: "Grace")

      # Stub just the email method, keep name real
      allow(user).to receive(:email).and_return("grace@example.com")

      expect(user.name).to eq("Grace")   # Real method
      expect(user.email).to eq("grace@example.com")  # Stubbed
    end

    it "spies on a real object to verify method was called" do
      user = User.create!(name: "Henry")

      user.name  # Call the real method

      expect(user).to have_received(:name)  # Verify it was called
    end

    it "stubs and spies together" do
      user = User.create!(name: "Ivy")

      allow(user).to receive(:greeting).and_return("Hi!")

      user.greeting  # Call stubbed method
      user.name      # Call real method

      expect(user).to have_received(:greeting)
      expect(user).to have_received(:name)
    end
  end

  # ============================================================
  # SECTION 5: SHARED EXAMPLES FOR REUSABLE MOCKS
  # ============================================================

  describe "Shared Examples for Common Mocks" do
    # Define a shared example set
    shared_examples "a likeable object" do
      let(:liker) { User.create!(name: "Liker") }

      it "can be liked by a user" do
        expect(subject.likes).to be_a(ActiveRecord::Associations::CollectionProxy)
      end

      it "creates a like association" do
        like = subject.likes.create!(user: liker)
        expect(like.user).to eq(liker)
      end
    end

    # Use the shared example for Post
    describe Post do
      let(:user) { User.create!(name: "Post Owner") }
      subject { user.posts.create!(title: "Test", body: "Body") }

      it_behaves_like "a likeable object"
    end

    # Use the shared example for Comment
    describe Comment do
      let(:user) { User.create!(name: "Commenter") }
      let(:post) { user.posts.create!(title: "Post", body: "Body") }
      subject { post.comments.create!(body: "Nice!", user: user) }

      it_behaves_like "a likeable object"
    end
  end

  # ============================================================
  # SECTION 6: REAL-WORLD EXAMPLE - SERVICE OBJECT MOCKING
  # ============================================================

  describe "Real-World Example: Mocking External Service" do
    # Let's create a fake email service for testing
    it "tests with a mocked email service" do
      # Simulating what you'd do with a real email service
      fake_email_service = double("EmailService")

      # Setup expectations
      expect(fake_email_service).to receive(:send_welcome_email)
        .with(kind_of(User))
        .and_return(true)

      # Simulate using the service
      user = User.create!(name: "New User")
      result = fake_email_service.send_welcome_email(user)

      expect(result).to be true
    end

    it "tests with a mocked notification system" do
      notifications = []

      # Stub a method that would normally have side effects
      allow_any_instance_of(User).to receive(:notify) do |user, message|
        notifications << { user: user.name, message: message }
      end

      user = User.create!(name: "Test")

      # This would normally send a notification, but we're capturing it
      user.notify("Welcome!")

      expect(notifications).to include({ user: "Test", message: "Welcome!" })
    end
  end

  # ============================================================
  # SECTION 7: MOCKING DATABASE QUERIES
  # ============================================================

  describe "Mocking Database Queries" do
    it "stubs ActiveRecord queries for speed" do
      # Instead of creating 100 users, we stub the query
      allow(User).to receive(:where).and_return([])

      # This won't hit the database
      result = User.where(name: "NonExistent")

      expect(result).to eq([])
    end

    it "stubs find queries" do
      fake_user = double("User", id: 999, name: "Found User")

      allow(User).to receive(:find).with(999).and_return(fake_user)

      user = User.find(999)
      expect(user.name).to eq("Found User")
    end

    it "stubs all() to return fake collection" do
      fake_users = [
        double("User", id: 1, name: "Alice"),
        double("User", id: 2, name: "Bob")
      ]

      allow(User).to receive(:all).and_return(fake_users)

      users = User.all
      expect(users.map(&:name)).to eq(["Alice", "Bob"])
    end
  end

  # ============================================================
  # SECTION 8: COMMON PITFALLS
  # ============================================================

  describe "Common Pitfalls to Avoid" do
    it "WARNING: instance_double will fail if method doesn't exist" do
      # This will FAIL because greeting doesn't exist on User
      # Uncomment to see the error:
      # fake_user = instance_double(User, greeting: "Hello")

      # DO THIS instead - use double for non-existent methods
      fake_user = double("User", greeting: "Hello")

      expect(fake_user.greeting).to eq("Hello")
    end

    it "WARNING: Don't stub private methods - design for testability" do
      # Bad: stubbing internal implementation
      # allow(subject).to receive(:send_internal_email)

      # Good: Test the public interface
      user = User.create!(name: "Test")
      expect(user).to be_valid
    end
  end
end
