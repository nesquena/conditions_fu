require File.dirname(__FILE__) + "/test_helper.rb"
require File.dirname(__FILE__) + "/../init.rb"

class Person < ActiveRecord::Base

end

class ConditionsFuTest < Test::Unit::TestCase
  load_all_fixtures

  def setup
    @nathan  =  Person.find(1)
    @bob     =  Person.find(2)
    @joan    =  Person.find(3)
    @tom     =  Person.find(4)
    @nathan2 =  Person.find(5)
  end

  # conditions_fu attribute condition tests

  def test_two_attribute_conditions_with_same_attribute_and_operator_are_equal
    # tests that two attribute conditions that have the same operator are equal
    condition_a = :first_name.eql
    condition_b = :first_name.eql
    assert_equal condition_a, condition_b
  end

  def test_two_attribute_conditions_with_same_attribute_and_different_operator_are_not_equal
    # tests that two attribute conditions that have a different operator are not equal
    condition_a = :first_name.eql
    condition_b = :first_name.in
    assert_not_equal condition_a, condition_b
  end

  def test_two_attribute_conditions_with_different_attribute_and_same_operator_are_not_equal
    # tests that two attribute conditions that have a different operator are not equal
    condition_a = :first_name.eql
    condition_b = :last_name.eql
    assert_not_equal condition_a, condition_b
  end

  def test_two_attribute_conditions_with_same_attribute_and_operator_are_equal_in_hash
    condition_hash_a = { :conditions => { :first_name.eql => "matt" } }
    condition_hash_b = { :conditions => { :first_name.eql => "matt" } }
    assert_equal condition_hash_a, condition_hash_b
  end
  
  def test_two_attribute_conditions_with_same_attribute_and_different_operator_are_not_equal_in_hash
    condition_hash_a = { :conditions => { :first_name.eql => "matt" } }
    condition_hash_b = { :conditions => { :first_name.like => "matt" } }
    assert_not_equal condition_hash_a, condition_hash_b
  end

  # conditions_fu plugin tests

  def test_equal_operator_should_work
    assert_equal [@bob], Person.all(:conditions => { :first_name.eql => "Bob" })
    assert_equal @bob, Person.first(:conditions => { :first_name.eql => "Bob" })
    assert_equal [@nathan, @tom], Person.all(:conditions => { :occupation.eql => "Student" })
    assert_equal [@bob, @tom],  Person.all(:conditions => { :favorite_number.eql => 34 })
    assert_equal [@nathan],  Person.all(:conditions => { :first_name.eql => "Nathan", :last_name.eql => "Esquenazi" })
    assert_equal @nathan,  Person.first(:conditions => { :first_name.eql => "Nathan", :last_name.eql => "Esquenazi" })
    assert_equal [@nathan, @bob, @nathan2], Person.any(:conditions => { :last_name.eql => "Villa", :first_name.eql => "Nathan" })
  end

  def test_like_should_work
    assert_equal [@nathan], Person.all(:conditions => { :first_name.like => "Na%", :last_name.like => "%squ%" })
    assert_equal [@nathan, @nathan2], Person.all(:conditions => { :first_name.like => "Nathan" })
    assert_equal @nathan, Person.first(:conditions => { :first_name.like => "Nathan" })
    assert_equal [@nathan, @nathan2], Person.all(:conditions => { :first_name.like => "Nat%" })
    assert_equal [@nathan, @bob, @joan, @tom], Person.all(:conditions => { :occupation.like => "%t%" })
    assert_equal [], Person.all(:conditions => { :first_name.like => "Nat" })
    assert_equal [@nathan, @bob, @nathan2], Person.any(:conditions => { :last_name.like => "%Vil%", :first_name.like => "%Nat%" })
  end

  def test_less_than_should_work
    assert_equal [@nathan], Person.all(:conditions => { :age.lt => 23 })
    assert_equal [@nathan, @tom], Person.all(:conditions => { :age.lt => 30 })
    assert_equal [@joan], Person.all(:conditions => { :favorite_number.lt => 25 })
    assert_equal @joan, Person.first(:conditions => { :favorite_number.lt => 25 })
    assert_equal [@nathan, @joan], Person.any(:conditions => { :age.lt => 22, :age.gte => 56 })
  end

  def test_less_equal_than_should_work
    assert_equal [@nathan], Person.all(:conditions => { :age.lte => 23 })
    assert_equal [@nathan, @tom], Person.all(:conditions => { :age.lte => 30 })
    assert_equal [@joan], Person.all(:conditions => { :favorite_number.lte => 25 })
    assert_equal @joan, Person.first(:conditions => { :favorite_number.lte => 25 })
    assert_equal [@nathan], Person.all(:conditions => { :age.lte => 21, :first_name => "Nathan" })
    assert_equal [@nathan, @joan], Person.any(:conditions => { :age.lte => 21, :age.gte => 56 })
  end

  def test_greater_than_should_work
    assert_equal [@joan, @nathan2], Person.all(:conditions => { :age.gt => 50 })
    assert_equal [@bob], Person.all(:conditions => { :age.gt => 30, :age.lt => 40 })
    assert_equal @bob, Person.first(:conditions => { :age.gt => 30, :age.lt => 40 })
    assert_equal [@nathan2], Person.all(:conditions => { :favorite_number.gt => 500})
  end

  def test_greater_equal_than_should_work
    assert_equal [@joan, @nathan2], Person.all(:conditions => { :age.gte => 50 })
    assert_equal [@bob], Person.all(:conditions => { :age.gte => 30, :age.lt => 40 })
    assert_equal [@nathan2], Person.all(:conditions => { :favorite_number.gte => 500})
    assert_equal [@joan, @nathan2], Person.all(:conditions => { :age.gte => 54 })
    assert_equal [@nathan], Person.all(:conditions => { :age.gte => 21, :age.lte => 21 })
  end

  def test_in_should_work
    assert_equal [@nathan, @joan, @nathan2], Person.all(:conditions => { :first_name.in => ["Nathan", "Joan"] })
    assert_equal [@bob, @joan, @tom], Person.all(:conditions => { :favorite_number.in => [34, 23] })
    assert_equal [@nathan, @tom], Person.all(:conditions => { :occupation.in => ["Student"] })
    assert_equal @nathan, Person.first(:conditions => { :occupation.in => ["Student"] })
    assert_equal [@nathan, @bob, @tom], Person.any(:conditions => { :occupation.in => ["Student"], :age.in => [38] })
  end

  def test_not_in_should_work
    assert_equal [@nathan, @nathan2], Person.all(:conditions => { :first_name.not => ["Tom", "Joan", "Bob"] })
    assert_equal [@bob, @tom], Person.all(:conditions => { :age.not => [21, 56, 54] })
    assert_equal @bob, Person.first(:conditions => { :age.not => [21, 56, 54] })
    assert_equal [@bob, @joan, @tom, @nathan2], Person.any(:conditions => { :age.not => [21, 56, 54], :age.not => [21] })
  end

  # regression tests (make sure the plugin doesn't destroy the existing find options)

  def test_simple_expectations
    # Sanity Check
    assert_equal 5, Person.all.size
    assert_equal "Esquenazi", Person.find(1).last_name
    assert_equal "Tom", Person.find(4).first_name
  end

  def test_old_string_queries_work
    # test that the old activerecord queries still work
    assert_equal [@nathan, @nathan2], Person.all(:conditions => { :first_name => "Nathan" })
    assert_equal @nathan, Person.first(:conditions => { :first_name => "Nathan" })
    assert_equal [@nathan, @nathan2], Person.find(:all, :conditions => { :first_name => "Nathan" })
    assert_equal [@nathan], Person.find(:all, :conditions => { :first_name => "Nathan", :last_name => "Esquenazi" })
    assert_equal @nathan, Person.find(:first, :conditions => { :first_name => "Nathan", :last_name => "Esquenazi" })
    assert_equal [@bob], Person.find(:all, :conditions => { :occupation => "Contractor", :first_name => "Bob" })
  end

  def test_old_range_queries_work
    assert_equal [@bob], Person.all(:conditions => { :age => 37..39 })
    assert_equal [@bob, @tom], Person.all(:conditions => { :favorite_number => 33..35 })
  end

  def test_old_array_queries_work
    assert_equal [@nathan, @bob, @tom, @nathan2], Person.all(:conditions => { :first_name => ['Nathan', 'Bob', 'Tom'] })
    assert_equal [@bob, @tom], Person.all(:conditions => { :age => [24, 38] })
  end
end
