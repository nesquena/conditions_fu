require 'conditions_fu'
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
    
