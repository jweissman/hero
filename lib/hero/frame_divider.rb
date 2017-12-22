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
      n = 0
      children.map do |child|
        if specifies_size?(child)
          child_size = specified_size(child)
          n += child_size
          frame.slice(n-child_size, n, direction: direction)
        else
          n += unspecified_child_share
          frame.slice(n-unspecified_child_share, n, direction: direction)
        end
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

    def children_with_specified_share
      @children_with_specified_share ||= children.select(&method(:specifies_size?))
      # do |child|
      #   specifies_size?(child) #, direction: direction)
      # end
    end

    def total_specified_children_share
      children_with_specified_share.
        map(&method(:specified_size)).
        inject(&:+)
    end

    def size_specification_predicate
      @size_specifier_predicate ||= ->(_name, *children, **props) { props.has_key?(direction_word) }
    end

    def size_specification_accessor #(direction)
      @size_specifier_accessor ||= ->(_name, *children, **props) { props[direction_word] }
    end

    def specifies_size?(element) #, direction: direct)
      predicate = size_specification_predicate #(direction)
      predicate.call(*element)
    end

    def specified_size(element) #, direction:)
      accessor = size_specification_accessor #(direction)
      accessor.call(*element)
    end

    def direction_word
      direction == :vertical ? :height : :width
    end
  end
end
