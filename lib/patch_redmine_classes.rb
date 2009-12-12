# Patches Redmine's projects dynamically. Adds a relationship
module AlertsProjectPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :alerts
    end

  end

  module ClassMethods
  end

  module InstanceMethods
  end

end

# Patches Redmine's Users dynamically.
# Adds relationships for accessing assigned and authored todos.
module AlertsUserPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      has_many :alerts, :class_name => 'Alert', :foreign_key => 'author_id', :order => 'created_on'

      #define a method to get the todos belonging to this user by UNIONing the above two collections
      def my_alerts
        self.alerts
      end

    end

  end

  module ClassMethods
  end

  module InstanceMethods
    def alerts_allowed?
      # Admin users are authorized for anything else
      return true if admin?
      User.current.allowed_to?({:controller => :alerts, :action => :edit}, nil, :global => true)
    end
  end
end

module RedefineConstantPatch

  # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)

     # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end

  module ClassMethods
    # http://pivotallabs.com/users/brian/blog/articles/218-redefining-constants
    def redefine_const(name, value)
      __send__(:remove_const, name) if const_defined?(name)
      const_set(name, value)
    end
  end

end