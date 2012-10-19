require "aversion/version"

# Public: Aversion makes your Ruby objects versionable. It also makes them
# immutable, so the only way to obtain transformed copies is to explicitly
# mutate state in #transform calls, which will return the modified copy, leaving
# the original intact.
#
# Examples
#
#   class Person
#     include Aversion
#
#     def initialize(hunger)
#       @hunger = hunger
#     end
#
#     def eat
#       transform do
#         @hunger -= 5
#       end
#     end
#   end
#
#   # Objects are immutable. Calls to mutate state will return new modified
#   # copies (thanks to #transform):
#   john       = Person.new
#   new_john   = john.eat
#   newer_john = new_john.eat
#
#   # You can roll back to a previous state:
#   new_john_again = newer_john.rollback
#
#   # Calculate deltas between objects, and replay the differences to get to the
#   # desired state:
#   difference = newer_john - john
#   newer_john_again = john.replay(difference)
#
module Aversion
  # Public: When we include Aversion, we override .new with an immutable
  # constructor and provide a .new_mutable version.
  def self.included(base)
    base.class_eval do
      # Public: Initializes an immutable instance.
      def self.new(*args)
        new_mutable(*args).freeze
      end

      # Public: Initializes a mutable instance.
      def self.new_mutable(*args)
        allocate.tap do |instance|
          instance.send :initialize, *args
          instance.instance_eval do
            @transformations = []
            @initial_args    = args
          end
        end
      end
    end
  end

  # Public: Returns a mutable version of the object, in case anyone needs it. We
  # do need it internally to perform transformations.
  def mutable
    self.class.new_mutable(*@initial_args).tap do |mutable|
      instance_variables.each do |ivar|
        mutable.instance_variable_set(ivar, instance_variable_get(ivar))
        mutable.instance_variable_set(:@transformations, @transformations.dup)
      end
    end
  end

  # Public: The only way to transform state.
  #
  # Returns a new, immutable copy with the transformation applied.
  def transform(&block)
    mutable.tap do |new_instance|
      new_instance.replay([block.dup])
    end.freeze
  end

  # Public: Rolls back to a previous version of the state.
  #
  # Returns a new, immutable copy with the previous state.
  def rollback
    self.class.new_mutable(*@initial_args).tap do |instance|
      instance.replay(history[0..-2])
    end.freeze
  end

  # Public: Replays an array of transformations (procs).
  #
  # transformations - the Array of Procs to apply.
  #
  # Returns a new, immutable copy with those transformations applied.
  def replay(transformations)
    (frozen? ? mutable : self).tap do |object|
      transformations.each do |transformation|
        object.history << transformation
        object.instance_eval(&transformation)
      end
    end.freeze
  end

  # Internal: Returns the history of this object.
  def history
    @transformations
  end

  # Internal: Sets the history of this object to a specific array fo
  # transformations.
  def history=(transformations)
    @transformations = transformations
  end

  # Public: Returns the difference between two versioned objects, which is an
  # array of the transformations one lacks from the other.
  def -(other)
    younger, older = [history, other.history].sort { |a,b| a.length <=> b.length }
    difference     = (older.length - younger.length) - 1
    older[difference..-1]
  end

  # Public: Returns whether two versionable objects are equal.
  def ==(other)
    history == other.history
  end
end
