module ConditionsFu
  module Base
    # overriden sanitization in order to highjack the way that the condition string is formed
    # the attribute_condition method needs to have the attribute query object in order to
    # determine which operator to apply for the condition
    # alias_method_chain :sanitize_sql_hash_for_conditions, :attribute_queries
    def sanitize_sql_hash_for_conditions_with_attribute_queries(attrs, table_name = quoted_table_name)
      condition_join_string = attrs.delete(:connect) || ' AND ' # ' OR ' or ' AND '
      attrs = expand_hash_conditions_for_aggregates(attrs)
      # view_statement("[sanitize] initial attrs", attrs)

      conditions = attrs.map do |attr, value|
        unless value.is_a?(Hash)
          attr_string = attr.to_s

          # Extract table name from qualified attribute names.
          if attr_string.include?('.')
            table_name, attr_string = attr_string.split('.', 2)
            table_name = connection.quote_table_name(table_name)
          end

          # Here is the where the difference occurs: attribute_condition_for_query takes in the attr object
          # table_name.`quoted_attribute_name` [result of attribute_condition_for_query]
          attribute_condition_for_query("#{table_name}.#{connection.quote_column_name(attr_string)}", attr, value)
        else
          sanitize_sql_hash_for_conditions(value, connection.quote_table_name(attr.to_s))
        end
      end.join(condition_join_string)

      # view_statement("[sanitize] conditions", conditions)
      # view_statement("[sanitize] attrs values", attrs.values)
      final_result = replace_bind_variables(conditions, expand_range_bind_variables(attrs.values))
      # view_statement("[sanitize] final result", final_result)
    end

    # returns the operator and value portion of the query string for a given condition (i.e "= ?")
    # the actual operator is determined by the attribute_query type ( i.e :name.gt => '>' )
    def attribute_condition_for_query(column, attribute_query, value)
      # immediately return to regularly scheduled programming if the attribute is a plain old symbol
      return attribute_condition(column, value) unless attribute_query.kind_of?(AttributeCondition)
      return "MATCH(#{column}) AGAINST(? IN BOOLEAN MODE)" if attribute_query.condition_operator == :match

      # in the case that the attribute is actually a query object, determine the query type
      op = case attribute_query.condition_operator # (i.e :gt, :lt, :like, :eql)
        when :eql     then "= ?"
        when :lt      then "< ?"
        when :lte     then "<= ?"
        when :gt      then "> ?"
        when :gte     then ">= ?"
        when :like    then "LIKE ?"
        when :in      then "IN (?)"
        when :not     then "NOT IN (?)"
        when :regexp  then "REGEXP ?"
      end
      "#{column} #{op}"
    end

    # similar Model.all which is an alias for Model.find(:all), except concatenates conditions with "OR" instead of "AND"
    # Model.any(:conditions => { :name.like => "%Na%", :age.gt > 30 }) # => `name` LIKE "%Na" OR `age` > 30
    def any(*args)
      options = args.extract_options! # extract the options off the end
      options[:conditions][:connect] = ' OR ' if options[:conditions] # set the condition_join condition
      args << options # add options back on the end
      find(:all, *args)
    end

    def view_statement(title, expression)
      puts "--------->#{title}<----------"
      puts expression.kind_of?(String) ? "==== #{expression} ======"  : "==== #{expression.inspect} ======"
      puts "\n"
      expression
    end
  end

  # define symbol methods for each possible condition qualifier
  module SymbolQueryExtensions
    [ :eql, :lt, :gt, :gte, :lte, :in, :like, :not, :match, :regexp ].each do |query_operator|
      define_method(query_operator) do
        AttributeCondition.new(self, query_operator)
      end
    end
  end

  # An attribute condition simply contains an attribute name as well as a condition operator
  class AttributeCondition
    # attr_name : String => the attribute that will be used in the condition (i.e :name, :age, ...)
    # operator  : Symbol => the operator which will be used for comparison (i.e :gt, :lt, :like, :eql, ...)
    attr_accessor :attribute_name, :condition_operator

    def initialize(attribute_name, condition_operator)
      @attribute_name, @condition_operator = attribute_name, condition_operator
    end

    # returns just the attribute name for simplicity
    def to_s
      @attribute_name.to_s
    end

    # returns the attribute name as a symbol
    def to_sym
      @attribute_name.to_sym
    end

    # redefines comparison for attribute condition objects if the attribute name and operator are the same
    def <=>(other)
      [self.condition_operator.to_s, self.attribute_name.to_s] <=> [other.condition_operator.to_s, other.attribute_name.to_s]
    end

    # redefines equality within the ruby objects based on the new comparison operator
    def ==(other)
      (self <=> other) == 0
    end

    def eql?(other)
      self.hash == other.hash
    end

    def hash
      ["AttributeCondition", self.condition_operator.to_s, self.attribute_name.to_s].hash
    end
  end
end

require 'activerecord'

Symbol.send(:include, ConditionsFu::SymbolQueryExtensions)

# extend activerecord with the condition methods
ActiveRecord::Base.send(:extend, ConditionsFu::Base)

# override sanitize_sql_hash_for_conditions
module ::ActiveRecord
  class Base
    class << self
       # use the sanitize_sql_hash_for_conditions_with_attribute_queries
       alias_method_chain :sanitize_sql_hash_for_conditions, :attribute_queries
    end
  end
end
