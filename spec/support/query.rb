class QueryElement # < Struct.new(:element)
  attr_reader :sym, :children, :props
  def initialize(sym,*children,**props)
    @sym = sym
    @children = children
    @props = props
  end

  def method_missing(sym, *args, &blk)
    if @props.key?(sym) then @props[sym] else super end
  end
end

class Query
  def initialize(elements)
    @elements = elements
  end

  def find(id)
    id_matches = matcher_for(:id)[id]
    match = @elements.detect { |element| id_matches[*element] }
    if match
      QueryElement.new(*match)
    end
  end

  def matcher_for(key)
    lambda do |value|
      puts "-- value = #{value}"
      lambda do |elem, *children, **attrs|
        attrs[key] == value
      end
    end
  end
end
