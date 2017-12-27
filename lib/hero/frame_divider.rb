module Hero
  class FrameDivider
    attr_reader :children, :frame, :direction

    def initialize(children:, frame:, direction: :vertical)
      @children = children
      @frame = frame
      @direction = direction
    end

    def split
      if children_with_specified_share.any? || children.any? { |child| partially_specifies_size?(child) }
        split_with_specifications
      else
        frame.subdivide(children.length, direction: direction)
      end
    end

    protected
    def split_with_specifications
      children_sizes = assemble_children_sizes

      pts = Array.new(children.count-1) do |ndx|
        origin + children_sizes[0..ndx].inject(&:+)
      end

      frame.slice(*pts, direction: direction)
    end

    def assemble_children_sizes
      children_sizes = []

      # size exactly specified children
      children.each.with_index do |child, ndx|
        if specifies_size?(child)
          children_sizes[ndx] = specified_size(child)
        end
      end

      # size partially specified children
      sizing_pass!(
        children_sizes,
        condition: ->(child) { !specifies_size?(child) && partially_specifies_size?(child) },
        size_provider: ->(child, default) { [ partially_specified_size(child), default ].max }
      )

      # now hit totally unspecified children with default val
      sizing_pass!(
        children_sizes,
        condition: ->(child) { !specifies_size?(child) && !partially_specifies_size?(child) },
        size_provider: ->(child, default) { default }
      )

      return children_sizes
    end

    # alters sizes_list
    def sizing_pass!(sizes_list, condition:, size_provider:)
      total_share = sizes_list.compact.inject(&:+) || 0
      total_count = sizes_list.compact.count || 0
      if total_count < children.count
        default_share = (total_size - total_share) / (children.count - total_count)
        children.each.with_index do |child,ndx|
          if condition[child]
            sizes_list[ndx] = size_provider[child, default_share]
          end
        end
      end
      true
    end

    private

    def total_size
      frame.size(direction: direction)
    end

    def origin
      if direction == :vertical
        frame.y0
      elsif direction == :horizontal
        frame.x0
      end
    end

    def children_with_specified_share
      children.select(&method(:specifies_size?))
    end

    def total_specified_children_share
      children_with_specified_share
        .map { |child| specified_size(child) }
        .inject(&:+) || 0
    end

    def specifies_size?(element)
      predicate = size_specification_predicate
      predicate.call(*element)
    end

    def specified_size(element)
      accessor = size_specification_accessor
      accessor.call(*element)
    end

    def partially_specifies_size?(element)
      predicate = partial_size_specification_predicate
      predicate.call(*element)
    end

    def partially_specified_size(element)
      accessor = partial_size_specification_accessor
      accessor.call(*element)
    end

    def direction_word
      direction == :vertical ? :height : :width
    end

    def size_specification_predicate
      lambda do |_name, *children, **props|
        props.key?(direction_word)
      end
    end

    def size_specification_accessor
      lambda do |_name, *children, **props|
        if props.key?(direction_word)
          props[direction_word]
        end
      end
    end

    def partial_size_specification_predicate
      lambda do |_name, *children, **props|
        !props.key?(direction_word) && \
          children.any? { |child|
          specifies_size?(child) ||
            partially_specifies_size?(child)
        }
      end
    end

    def partial_size_specification_accessor
      @parial_size_specifier_accessor ||= lambda do |_name, *children, **props|
        # do we need a new frame divider for the children here
        child_sizes = children
          .map { |child| specified_size(child) || partially_specified_size(child) }
          .compact

        other_direction = props.delete(:direction) { :vertical }
        if direction == other_direction
          child_sizes.inject(&:+)
        else
          child_sizes.max
        end
      end
    end
  end
end
