# aversion

Aversion makes your Ruby objects versionable. It also makes them immutable, so
the only way to obtain transformed copies is to explicitly mutate state in
`#transform` calls, which will return the modified copy, leaving the original
intact.

You can also compute the difference between two versions, expressed as an array
of transformations, and apply it onto an arbitrary object.

## Installation

Add this line to your application's Gemfile:

    gem 'aversion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aversion

## Usage

```ruby
class Person
  include Aversion

  def initialize(hunger)
    @hunger = hunger
  end

  def eat
    transform do
      @hunger -= 5
    end
  end
end

# Objects are immutable. Calls to mutate state will return new modified
# copies (thanks to #transform):
john       = Person.new
new_john   = john.eat
newer_john = new_john.eat

# You can roll back to a previous state:
new_john_again = newer_john.rollback

# Calculate deltas between objects, and replay the differences to get to the
# desired state:
difference = newer_john - john
newer_john_again = john.replay(difference)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Who's this

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice](http://twitter.com/txustice) on twitter (where you
should probably follow me!).
