module Hero
  class Composer
    def initialize(frame:)
      @frame = frame
    end

    def resolve(sym, *children, **props)
      # puts "---> Composer.resolve #{sym} children=#{children} props=#{props}"
      send(sym, *children, **props)
    end

    protected
    def resolve_children(children, frame: @frame, direction: :vertical)
      child_frames = *distribute_frames(children, frame: frame, direction: direction)
      children.zip(child_frames).flat_map do |(child,child_frame)|
        child_resolver = self.class.new(frame: child_frame)
        child_resolver.resolve(*child)
      end
    end


    def distribute_frames(children, frame:, direction:)
      divider = FrameDivider.new(
        children: children,
        frame: frame,
        direction: direction
      )
      divider.split
    end
  end
end
