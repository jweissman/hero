module Hero
  # engine should build virtual doc, route clicks to component instances...
  class Engine
    attr_reader :root
    def initialize(klass:, composer_provider:, viewport_dimensions: [640,480])
      @root = klass.new
      @frame = Frame[0,0,*viewport_dimensions]
      @composer = composer_provider.new(frame: @frame)
    end

    def click(position:)
      shown = show
      clicked = shown.reverse.detect do |sym, **attrs|
        attrs[:frame].contains?(position: position)
      end
      handle_click(*clicked) if clicked
    end

    def handle_click(sym, **attrs)
      puts "=== GOT CLICK ON #{sym} WITH attrs = #{attrs}"
      return false unless attrs.has_key?(:on_click)
      on_click = attrs[:on_click] #.delete(:on_click)
      on_click.call
      true
    end

    def show
      # @root.render
      @composer.resolve(*@root.render)
    end
  end
end
