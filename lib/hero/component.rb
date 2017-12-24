module Hero
  class Component
    attr_reader :props, :state
    def initialize(*children, **props)
      @children = children
      @props = props
      @state = {}
    end

    def apply(**new_state)
      # raise 'Component#apply is not impl'
      @state = @state.merge(new_state)
      # trigger re-render..?
      true
    end

    class << self
      def assemble_and_render(*children, **props)
        new.render(*children,**props)
      end
      alias_method :[], :assemble_and_render # emulate procs?
    end
  end
end
