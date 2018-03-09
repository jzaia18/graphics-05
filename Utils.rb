include Math

module Utils

  def self.create_grid()## Create board
    board = Array.new($RESOLUTION)
    for i in (0...$RESOLUTION)
      board[i] = Array.new($RESOLUTION)
      for j in (0...$RESOLUTION)
        board[i][j] = $BACKGROUND_COLOR
      end
    end
    return board
  end


  ## Write GRID to OUTFILE
  def self.write_out(file: $OUTFILE, edgemat: $EDGE_MAT)
    extension = file[0...file.index('.')] + file[file.index('.')..-1] #filename with any extension
    file[file.index('.')..-1] = '.ppm'
    $GRID = create_grid()
    Draw.push_edge_matrix(edgemat: edgemat)
    outfile = File.open(file, 'w')
    outfile.puts "P3 #$RESOLUTION #$RESOLUTION 255" #Header in 1 line

    #Write PPM data
    for row in $GRID
      for pixel in row
        for rgb in pixel
          outfile.print rgb
          outfile.print ' '
        end
        outfile.print '   '
      end
      outfile.puts ''
    end
    outfile.close()

    #Convert filetype
    puts %x[convert #{file} #{extension}]
  end

  def self.display(tempfile: $TEMPFILE)
    write_out(file: tempfile)
    puts %x[display #{tempfile}]
    puts %x[rm #{tempfile}]
    $GRID = create_grid() #IAM THE PROBLEM (MAYBE)
  end

  def self.apply_transformations(edge_mat: $EDGE_MAT, tran_mat: $TRAN_MAT)
    MatrixUtils.multiply(tran_mat, edge_mat)
  end

  def self.parse_file(filename: $INFILE)
    file = File.new(filename, "r")
    while (line = file.gets)
      line = line.chomp #Kill trailing newline
      puts "Executing command: \"" + line + '"'
      case line
      when "line"
        args = file.gets.chomp.split(" ")
        for i in (0...6); args[i] = args[i].to_f end
        Draw.add_edge(args[0], args[1], args[2], args[3], args[4], args[5])
      when "circle"
        args = file.gets.chomp.split(" ")
        for i in (0...4); args[i] = args[i].to_f end
        Draw.circle(args[0], args[1], args[2], args[3])
      when "hermite"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        Draw.hermite(args[0], args[1], args[2], args[3])
      when "bezier"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        Draw.bezier(args[0], args[1], args[2], args[3])

      when "ident"
        $TRAN_MAT = MatrixUtils.identity(4)
      when "scale"
        args = file.gets.chomp.split(" ")
        for i in (0...3); args[i] = args[i].to_f end
        scale = MatrixUtils.dilation(args[0], args[1], args[2])
        MatrixUtils.multiply(scale, $TRAN_MAT)
      when "move"
        args = file.gets.chomp.split(" ")
        for i in (0...3); args[i] = args[i].to_f end
        move = MatrixUtils.translation(args[0], args[1], args[2])
        MatrixUtils.multiply(move, $TRAN_MAT)
      when "rotate"
        args = file.gets.chomp.split(" ")
        rotate = MatrixUtils.rotation(args[0], args[1].to_f)
        MatrixUtils.multiply(rotate, $TRAN_MAT)
      when "apply"
        apply_transformations()
      when "display"
        display();
      when "save"
        arg = file.gets.chomp
        write_out(file: arg)
      when "quit"
        exit 0
      else
        puts "ERROR: Unrecognized command \"" + line + '"'
      end
    end
    file.close
  end

end
