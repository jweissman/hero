module Hero
  # engine compose documents and route clicks back to components...
  class Engine
    attr_reader :root
    def initialize(klass:, composer_provider:, viewport_dimensions: [640,480])
      @root = klass.new
      @frame = Frame[0,0,*viewport_dimensions]
      @composer = composer_provider.new(frame: @frame)
    end

    def click(position:)
      clicked = show.reverse.detect do |sym, **attrs|
        attrs[:frame].contains?(position: position) && \
          attrs.has_key?(:on_click)
      end
      handle_click(*clicked) if clicked
    end

    def handle_click(sym, **attrs)
      return false unless attrs.has_key?(:on_click)
      on_click = attrs[:on_click]
      on_click.call
      true
    end

    def show(**props)
      @composer.resolve(*@root.show(**props))
    end
  end
end
