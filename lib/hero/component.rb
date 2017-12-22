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
      @state = @state.merge(new_state) #.merge(@state) # ?
      # trigger re-render..?
      true
    end
  end
end
