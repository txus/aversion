require 'test_helper'

class Person
  include Aversion
  attr_reader :age, :hunger

  def initialize(age)
    @age   = age
    @hunger = 100
  end

  def eat
    transform do
      @hunger -= 5
    end
  end
end

describe Aversion do
  let(:person) { Person.new(20) }

  describe 'immutability' do
    it 'makes objects immutable' do
      person.frozen?.must_equal true
    end

    it 'allows for constructing mutable copies' do
      Person.new_mutable(20).frozen?.must_equal false
    end

    it 'exposes a mutable version of the object' do
      person.mutable.frozen?.must_equal false
      person.age.must_equal 20
    end
  end

  describe '#transform' do
    it 'returns a new, modified instance' do
      new_person = person.eat
      new_person.hunger.must_equal 95
    end

    it 'preserves the original object' do
      person.eat
      person.hunger.must_equal 100
    end
  end

  describe '#rollback' do
    it 'rolls back to a previous state' do
      new_person = person.eat
      new_person.rollback.must_equal person
    end
  end

  describe 'calculating and applying deltas' do
    let(:new_person)        { person.eat }
    let(:newer_person)      { new_person.eat }
    let(:even_newer_person) { newer_person.eat }

    let(:difference) { even_newer_person - new_person }

    describe '#difference' do
      it 'returns an array of deltas (transformations)' do
        difference.length.must_equal 2
      end
    end

    describe '#replay' do
      it 'returns an array of deltas (transformations)' do
        new_person.replay(difference).must_equal even_newer_person
      end
    end
  end
end
