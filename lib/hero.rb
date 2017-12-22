require 'ostruct'

require 'hero/version'
require 'hero/frame'
require 'hero/component'
require 'hero/engine'

module Hero
  def self.render_component(klass_or_fn, *children, **props)
    case klass_or_fn
    when Class then
      puts "--- render a class..."
      render_class(klass_or_fn, *children, **props)
      # raise 'class render not impl'
      # the_model = klass_or_fn.new
    when Proc then
      puts "--- render a proc..."
      render_proc(klass_or_fn, *children, **props)
    else
      raise 'render has to take either class or function...'
    end
  end

  def self.render_class(klass, *children, **props)
    model = klass.new
    model.render(*children, **props)
    # raise 'Hero#render_class not impl'
  end

  def self.render_proc(the_proc, *children, **props)
    if props.any?
      the_proc.call(*children, **props) # + [*children]
    else
      raise 'hmmm render proc w/o props not impl?'
    end
  end

  class Composer
    def initialize(frame:)
      @frame = frame
    end

    def resolve(sym, *children, **props)
      puts "---> Composer.resolve #{sym} children=#{children} props=#{props}"
      send(sym, *children, **props)
    end

    protected
    def resolve_children(children, frame: @frame)
      child_frames = *frame.subdivide_vertically(children.length)
      children.zip(child_frames).flat_map do |(child,child_frame)|
        child_resolver = self.class.new(frame: child_frame)
        child_resolver.resolve(*child)
      end
    end
  end

  # wrapper around a component that interfaces with composer...?
  # class Wrapper
  #   def initialize(component)
  #   end
  # end
end
