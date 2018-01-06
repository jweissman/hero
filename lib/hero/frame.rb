module Hero
  class Frame < Struct.new(:x0,:y0,:x1,:y1)
    def width;  x1-x0 end
    def height; y1-y0 end
    def area;   width * height end

    # where is the center of a rectangle?
    def center
      # bad: [ (x1 - x0) / 2, (y1 - y0) / 2 ]
      # good:
      #   [
      #     x0 + ((x1-x0)/2),
      #     y0 + ((y1-y0)/2)
      #   ]
      [ x0 + ((x1-x0)/2), y0 + ((y1-y0)/2) ]
    end

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

    def slice(*ns,direction:)
      unless [ :horizontal, :vertical ].include?(direction)
        raise "Frame#slice direction must be :vertical or :horizontal"
      end
      slice!(*ns, direction: direction)
    end

    def pad(padding)
      Frame[
        x0+padding, y0+padding,
        x1-padding, y1-padding
      ]
    end

    def inspect
      "Frame[#{x0},#{y0},#{x1},#{y1}]"
    end
    alias_method :to_s, :inspect

    protected

    # slice without checking validity of direction
    def slice!(*ns,direction:)
      zero = direction == :vertical ? y0 : x0
      points = [
        zero,
        *ns,
        (zero + size(direction: direction))
      ]

      if direction == :vertical
        slice_vertically(points)
      else
        slice_horizontally(points)
      end
    end

    def slice_vertically(points)
      points.drop(1).zip(points).map do |(n,n_prime)|
        Frame[x0,n_prime,x1,n]
      end
    end

    def slice_horizontally(points)
      points.drop(1).zip(points).map do |(n,n_prime)|
        Frame[n_prime,y0,n,y1]
      end
    end

    def subdivide_vertically(n)
      return [self] if n == 0
      slice_height = height / n
      (n-1).times.map do |slice_index|
        Frame[
          x0, y0 + (slice_index * slice_height),
          x1, y0 + (slice_index+1) * slice_height
        ]
      end + [Frame[x0, y0+(n-1)*slice_height, x1, y1]]
    end

    def subdivide_horizontally(n)
      return [self] if n == 0
      slice_width = width / n
      (n-1).times.map do |slice_index|
        Frame[
          x0 + (slice_index * slice_width), y0,
          x0 + (slice_index+1) * slice_width, y1
        ]
      end + [Frame[x0+(n-1)*slice_width, y0, x1, y1]]
    end
  end
end
