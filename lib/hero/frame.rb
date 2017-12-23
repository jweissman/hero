module Hero
  class Frame < Struct.new(:x0,:y0,:x1,:y1)
    def width;  x1-x0 end
    def height; y1-y0 end
    def area;   width * height end

    def size(direction:)
      if direction == :vertical
        height
      elsif direction == :horizontal
        width
      else
        raise 'Frame#size direction must be :vertical or :horizontal'
      end
    end

    def subdivide(n, direction: :vertical)
      if direction == :vertical
        subdivide_vertically(n)
      elsif direction == :horizontal
        subdivide_horizontally(n)
      else
        raise 'Frame#subdivide direction must be :vertical or :horizontal'
      end
    end

    def contains?(position:)
      (x,y) = *position
      x0 <= x && x <= x1 &&
        y0 <= y && y <= y1
    end

    def slice(n0,n1,direction:)
      if direction == :vertical
        Frame[x0,n0,x1,n1]
      elsif direction == :horizontal
        Frame[n0,y0,n1,y1]
      else
        raise "Frame#slice direction must be :vertical or :horizontal"
      end
    end

    def inspect
      "Frame[#{x0},#{y0},#{x1},#{y1}]"
    end
    alias_method :to_s, :inspect

    protected

    def subdivide_vertically(n)
      slice_height = height / n
      n.times.map do |slice_index|
        Frame[
          x0, y0 + (slice_index * slice_height),
          x1, y0 + (slice_index+1) * slice_height
        ]
      end
    end

    def subdivide_horizontally(n)
      slice_width = width / n
      n.times.map do |slice_index|
        Frame[
          x0 + (slice_index * slice_width), y0,
          x0 + (slice_index+1) * slice_width, y1
        ]
      end
    end
  end
end