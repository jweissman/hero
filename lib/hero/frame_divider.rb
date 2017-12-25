module Hero
  class FrameDivider
    attr_reader :children, :frame, :direction

    def initialize(children:, frame:, direction: :vertical)
      @children = children
      @frame = frame
      @direction = direction
    end

    def split
      if children_with_specified_share.any?
        split_with_specifications
      else
        frame.subdivide(children.length, direction: direction)
      end
    end

    protected
    def split_with_specifications
      children_sizes = children.map(&method(:child_size))
      pts = children.count.times.map do |ndx|
        origin + children_sizes[0..ndx].inject(&:+)
      end
      frame.slice(*pts, direction: direction)
    end

    def child_size(child)
      if specifies_size?(child)
        specified_size(child)
      else
        unspecified_child_share
      end
    end

    private

    def remaining_unspecified_size
      total_size - total_specified_children_share
    end

    def unspecified_child_share
      if unspecified_children.any?
        remaining_unspecified_size / unspecified_children.count
      else
        0
      end
    end

    def unspecified_children
      children - children_with_specified_share
    end

    def total_size
      frame.size(direction: direction)
    end

    def origin
      if direction == :vertical
        frame.y0
      elsif direction == :horizontal
        frame.x0
      end
      # frame.origin(direction: direction)
    end

    def children_with_specified_share
      @children_with_specified_share ||= children.select(&method(:specifies_size?))
    end

    def total_specified_children_share
      children_with_specified_share.
        map(&method(:specified_size)).
        inject(&:+)
    end

    def size_specification_predicate
      @size_specifier_predicate ||= ->(_name, *children, **props) {
        props.has_key?(direction_word)
      }
    end

    def size_specification_accessor
      @size_specifier_accessor ||= ->(_name, *children, **props) {
        props[direction_word] # || children.any? { |child| specifies_size?(child) }
      }
    end

    def specifies_size?(element)
      predicate = size_specification_predicate
      predicate.call(*element)
    end

    def specified_size(element)
      accessor = size_specification_accessor
      accessor.call(*element)
    end

    def direction_word
      direction == :vertical ? :height : :width
    end
  end
end
