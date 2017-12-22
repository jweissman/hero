module Hero
  class Frame < Struct.new(:x0,:y0,:x1,:y1)
    def width;  x1-x0 end
    def height; y1-y0 end
    def area;   width * height end

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

    def contains?(position:)
      (x,y) = *position
      x0 < x && x <= x1 &&
        y0 < y && y <= y1
    end

    def inspect
      "Frame[#{x0},#{y0},#{x1},#{y1}]"
    end
    alias_method :to_s, :inspect
  end
end
