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
      # Stub User.count to return 5 without creating real users
      allow(User).to receive(:count).and_return(5)
      expect(User.count).to eq(5)
    end
  end

  # ============================================================
  # SECTION 2: STUBBING METHODS
  # ============================================================
  # Stubbing = Replace a method's return value with something else
  # Use when you want to control what a method returns
  # ============================================================

  describe "Stubbing Methods" do
    it "stubs a method with allow() on a double" do
      # Create a double (fake object)
      fake_user = double("User", name: "Dave")

      # Stub a NEW method that doesn't exist
      allow(fake_user).to receive(:greeting).and_return("Hello, Dave!")

      expect(fake_user.greeting).to eq("Hello, Dave!")
      expect(fake_user.name).to eq("Dave")  # Original method still works
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
      fake_user = double("User", name: "Eve")
      call_count = 0

      allow(fake_user).to receive(:visit_count) do
        call_count += 1
        call_count
      end

      expect(fake_user.visit_count).to eq(1)
      expect(fake_user.visit_count).to eq(2)
      expect(fake_user.visit_count).to eq(3)
    end

    it "stubs a class method" do
      # Stub User.count to return 5 without creating real users
      allow(User).to receive(:count).and_return(5)
      expect(User.count).to eq(5)
    end

    it "stubs a real User method (partial double)" do
      user = User.create!(name: "Frank")

      # Stub the name method to return something else
      allow(user).to receive(:name).and_return("Frankie")

      expect(user.name).to eq("Frankie")
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
      fake_user = double("User", name: "Grace")
      allow(fake_user).to receive(:greet)

      fake_user.greet

      expect(fake_user).to have_received(:greet)
    end

    it "expects a message with specific arguments" do
      notifier = double("Notifier")
      allow(notifier).to receive(:send_email).and_return(true)

      notifier.send_email("test@example.com", "Hello!")

      expect(notifier).to have_received(:send_email).with("test@example.com", "Hello!")
    end

    it "expects a message to be called once by default" do
      calculator = double("Calculator")
      allow(calculator).to receive(:add).and_return(5)

      calculator.add(2, 3)

      expect(calculator).to have_received(:add).with(2, 3).once
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
      user = User.create!(name: "Henry")

      # Stub just the name method, keep id real
      allow(user).to receive(:name).and_return("Henrietta")

      expect(user.id).to be > 0        # Real method still works
      expect(user.name).to eq("Henrietta")  # Stubbed
    end

    it "spies on a real object to verify method was called" do
      user = User.create!(name: "Ivy")

      # First stub the method so we can spy on it
      allow(user).to receive(:name).and_call_original

      user.name  # Call the real method

      expect(user).to have_received(:name)
    end

    it "stubs and spies together with a double" do
      fake_user = double("User", id: 1, name: "Jack")

      fake_user.name  # Call a method

      expect(fake_user).to have_received(:name)
      expect(fake_user.name).to eq("Jack")
    end
  end

  # ============================================================
  # SECTION 5: SHARED EXAMPLES FOR REUSABLE MOCKS
  # ============================================================

  describe "Shared Examples for Common Behaviors" do
    # Define a shared example set
    shared_examples "a valid user" do
      it "can be persisted with a name" do
        user = User.create!(name: "Shared User")
        expect(user.id).to be > 0
      end
    end

    # Use the shared example
    describe User do
      it_behaves_like "a valid user"
    end

    # Shared examples can also test shared behaviors
    shared_examples "a creatable record" do |model_class|
      it "can be created" do
        # Each call creates a fresh instance
        record = model_class.new
        expect(record).to be_a(model_class)
      end
    end

    describe Post do
      it_behaves_like "a creatable record", Post
    end
  end

  # ============================================================
  # SECTION 6: REAL-WORLD EXAMPLE - SERVICE OBJECT MOCKING
  # ============================================================

  describe "Real-World Example: Mocking External Service" do
    it "tests with a mocked notification service" do
      # Simulate a notification service that would normally send emails
      fake_email_service = double("EmailService")

      # Setup: expect this method to be called, and return success
      expect(fake_email_service).to receive(:send_welcome_email)
        .with(kind_of(String))
        .and_return(true)

      # Act: Simulate using the service
      user_email = "newuser@example.com"
      result = fake_email_service.send_welcome_email(user_email)

      # Assert
      expect(result).to be true
    end

    it "captures calls for later verification" do
      notifications = []

      # Create a double that captures calls
      notifier = double("Notifier")
      allow(notifier).to receive(:notify) do |user, message|
        notifications << { user: user, message: message }
        true
      end

      # Act: Send some notifications
      notifier.notify("Alice", "Welcome!")
      notifier.notify("Bob", "How are you?")

      # Assert: Verify what was captured
      expect(notifications.length).to eq(2)
      expect(notifications).to include({ user: "Alice", message: "Welcome!" })
      expect(notifications).to include({ user: "Bob", message: "How are you?" })
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
  # SECTION 8: LET AND LET! WITH MOCKING
  # ============================================================

  describe "Using let() with Mocks" do
    let(:mock_calculator) do
      double("Calculator",
             add: 10,
             subtract: 2,
             multiply: 20
            )
    end

    it "creates the mock once per test" do
      expect(mock_calculator.add(5, 5)).to eq(10)
    end

    it "creates a fresh mock for each test" do
      expect(mock_calculator.multiply(4, 5)).to eq(20)
    end
  end

  # ============================================================
  # SECTION 9: ANY_INSTANCE_DOUBLE
  # ============================================================

  describe "Stubbing All Instances of a Class" do
    it "stubs a method on any instance using a double" do
      # For methods that don't exist, use doubles instead
      fake_users = [
        double("User", id: 1, name: "Admin1", role: "admin"),
        double("User", id: 2, name: "Admin2", role: "admin")
      ]

      allow(User).to receive(:where).and_return(fake_users)

      users = User.where(role: "admin")
      expect(users.map(&:role)).to eq(["admin", "admin"])
    end

    it "stubs specific instances differently" do
      user1 = User.create!(name: "User1")
      user2 = User.create!(name: "User2")

      # Stub name method (which exists on User)
      allow(user1).to receive(:name).and_return("Alice (Admin)")
      allow(user2).to receive(:name).and_return("Bob (Regular)")

      expect(user1.name).to eq("Alice (Admin)")
      expect(user2.name).to eq("Bob (Regular)")
    end
  end

  # ============================================================
  # SECTION 10: COMMON PITFALLS
  # ============================================================

  describe "Common Pitfalls to Avoid" do
    it "WARNING: Use double() for non-existent methods" do
      # instance_double will FAIL if the method doesn't exist on the class
      # DO THIS: Use double() for methods that don't exist
      fake_user = double("User", fake_method: "value")
      expect(fake_user.fake_method).to eq("value")
    end

    it "WARNING: Don't stub private methods - design for testability" do
      # Good: Test the public interface
      user = User.create!(name: "Test")
      expect(user.name).to eq("Test")
    end

    it "TIP: Use and_call_original to spy on real methods" do
      user = User.create!(name: "Spy")

      allow(user).to receive(:name).and_call_original

      expect(user.name).to eq("Spy")
      expect(user).to have_received(:name)
    end
  end
end
