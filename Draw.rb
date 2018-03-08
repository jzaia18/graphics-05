require './MatrixUtils.rb'

module Draw

  # Plot a point on GRID (from top left)
  def self.plot(x, y, r: $RC, g: $GC, b: $BC)
    return if x < 0 || y < 0 || x >= $RESOLUTION || y >= $RESOLUTION
    $GRID[y.to_i][x.to_i] = [r.floor, g.floor, b.floor]
  end
  # Plot a point on GRID (from bottom left)
  def self.plot_bot(x, y, r: $RC, g: $GC, b: $BC)
    plot(x, $RESOLUTION - y, r: r, g: g, b: b)
  end

  # Define a line by 2 points
  def self.line(x0, y0, x1, y1, r: $RC, g: $GC, b: $BC)
    # x0 is always left of x1
    return line(x1, y1, x0, y0, r: r, g: g, b: b) if x1 < x0

    #init vars
    dy = y1-y0
    dx = x1-x0
    x = x0
    y = y0
    d = -1 * dx

    ## Begin actual algorithm:
    if dy <= 0 #if the line is in octants I or II
      if dy.abs <= dx #octant I
        puts "Drawing line in Octant I" if $DEBUGGING
        while x <= x1
          plot(x, y, r: r, g: g, b: b)
          if d > 0
            y-=1
            d-=2*dx
          end
          x+=1
          d-=2*dy
        end

      else #octant II
        puts "Drawing line in Octant II" if $DEBUGGING
        while y >= y1
          plot(x, y, r: r, g: g, b: b)
          if d > 0
            x+=1
            d+=2*dy
          end
          y-=1
          d+=2*dx
        end
      end

    else #if the line is in octants VII or VIII

      if dy >= dx #octant VII
        puts "Drawing line in Octant VII" if $DEBUGGING
        while y <= y1
          plot(x, y, r: r, g: g, b: b)
          if d > 0
            x+=1
            d-=2*dy
          end
          y+=1
          d+=2*dx
        end

      else #octant VIII
        puts "Drawing line in Octant VIII" if $DEBUGGING
        while x <= x1
          plot(x, y, r: r, g: g, b: b)
          if d > 0
            y+=1
            d-=2*dx
          end
          x+=1
          d+=2*dy
        end
      end
    end
  end

  # Helper for add_edge
  def self.add_point(x, y, z)
    $EDGE_MAT.add_col([x, y, z, 1])
  end

  # Add an edge to the global edge matrix
  def self.add_edge(x0, y0, z0, x1, y1, z1)
    add_point(x0, y0, z0)
    add_point(x1, y1, z1)
  end

  # Draw the pixels in the matrix and clean it out
  def self.push_edge_matrix(edgemat: $EDGE_MAT)
    i = 0
    while i < edgemat.cols
      coord0 = edgemat.get_col(i)
      coord1 = edgemat.get_col(i + 1)
      line(coord0[0].to_i, coord0[1].to_i, coord1[0].to_i, coord1[1].to_i)
      i+=2
    end
    #edgemat.reset(4,0)
  end

end
