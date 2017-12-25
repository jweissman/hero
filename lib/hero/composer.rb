module Hero
  class Composer
    def initialize(frame:)
      @frame = frame
    end

    def resolve(sym, *children, **props)
      @padding = props.delete(:padding) { 0 }
      send(sym, *children, **props)
    end

    protected
    def resolve_children(children, frame:, direction: :vertical)
      children_frame = frame.pad(@padding)
      child_frames = *distribute_frames(children,
                                        frame: children_frame,
                                        direction: direction)

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
      distributed = divider.split
      distributed
    end

    # private
    # attr_reader :frame
  end
end
