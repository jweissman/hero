module Hero
  class Component
    attr_reader :props, :state

    def initialize(*children, **props)
      @children = children
      @props = props
      @state = {}
    end

    def apply(**new_state)
      @state = @state.merge(new_state)
      true
    end

    def show(*children, **props)
      props = props.merge(@props) if @props.is_a?(Hash)
      render(*children, **props)
    end

    class << self
      # emulate procs if called with []
      def assemble_and_render(*children, **props)
        new.show(*children,**props)
      end
      alias_method :[], :assemble_and_render
    end
  end
end
