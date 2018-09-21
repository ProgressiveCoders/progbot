module ActiveAdmin
  class Scope

    attr_reader :scope_method, :id, :scope_block, :display_if_block, :show_count, :default_block

    # Create a Scope
    #
    # Examples:
    #
    #   Scope.new(:published)
    #   # => Scope with name 'Published' and scope method :published
    #
    #   Scope.new('Published', :public)
    #   # => Scope with name 'Published' and scope method :public
    #
    #   Scope.new 'Published', :public, if: proc { current_admin_user.can? :manage, resource_class } do |articles|
    #     articles.where published: true
    #   end
    #   # => Scope with name 'Published' and scope method :public, optionally displaying the scope per the :if block
    #
    #   Scope.new('Published') { |articles| articles.where(published: true) }
    #   # => Scope with name 'Published' using a block to scope
    #
    #   Scope.new ->{Date.today.strftime '%A'}, :published_today
    #   # => Scope with dynamic title using the :published_today scope method
    #
    def initialize(name, method = nil, options = {}, &block)
      @name, @scope_method = name, method.try(:to_sym)

      if name.is_a? Proc
        raise "A string/symbol is required as the second argument if your label is a proc." unless method
        @id = ActiveAdmin::Dependency.rails.parameterize method.to_s
      else
        @scope_method ||= name.to_sym
        @id = ActiveAdmin::Dependency.rails.parameterize name.to_s
      end

      @scope_method               = nil        if @scope_method == :all
      @scope_method, @scope_block = nil, block if block_given?

      @localizer        = options[:localizer]
      @show_count       = options.fetch(:show_count, true)
      @display_if_block = options[:if]      || proc{ true }
      @default_block    = options[:default] || proc{ false }
    end

    def name
      case @name
      when String then @name
      when Symbol then @localizer ? @localizer.t(@name, scope: 'scopes') : @name.to_s.titleize
      else @name
      end
    end

  end
end
