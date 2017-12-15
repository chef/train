# encoding: utf-8

module Train::Platforms
  class Platform
    include Train::Platforms::Common
    attr_accessor :backend, :condition, :families, :family_hierarchy, :name_updated, :platform

    def initialize(name, condition = {})
      @name = name
      @condition = condition
      @families = {}
      @family_hierarchy = []
      @platform = {}
      @detect = nil
      @title = name.to_s.capitalize
      clean_name

      # add itself to the platform list
      Train::Platforms.list[name] = self
    end

    def direct_families
      @families.collect { |k, _v| k.name }
    end

    def name
      # Override here incase a updated name was set
      # during the detect logic
      @clean_name
    end

    def clean_name
      name = (@platform[:name] || @name)
      # This is a history of name change being used upstream in inspec
      if name =~ /[A-Z ]/
        @name_updated = [name]
        name = name.downcase.tr(' ', '_')
        @name_updated << name
      end
      @clean_name = name
    end

    # This is for backwords compatability with
    # the current inspec os resource.
    def[](name)
      if respond_to?(name)
        send(name)
      else
        'unknown'
      end
    end

    def title(title = nil)
      return @title if title.nil?
      @title = title
      self
    end

    def to_hash
      @platform
    end

    # Add generic family? and platform methods to an existing platform
    #
    # This is done later to add any custom
    # families/properties that were created
    def add_platform_methods
      # Clean name up and add in any detect overrides
      clean_name

      # Add in family methods
      family_list = Train::Platforms.families
      family_list.each_value do |k|
        next if respond_to?(k.name + '?')
        define_singleton_method(k.name + '?') do
          family_hierarchy.include?(k.name)
        end
      end

      # Helper methods for direct platform info
      @platform.each_key do |m|
        next if respond_to?(m)
        define_singleton_method(m) do
          @platform[m]
        end
      end

      # Create method for name if its not already true
      m = name + '?'
      return if respond_to?(m)
      define_singleton_method(m) do
        true
      end
    end
  end
end
