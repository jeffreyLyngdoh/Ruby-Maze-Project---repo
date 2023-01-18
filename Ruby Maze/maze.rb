#!/usr/local/bin/ruby

# ########################################
# CMSC 330 - Project 1
# ########################################

#-----------------------------------------------------------
# FUNCTION DECLARATIONS
#-----------------------------------------------------------

# write your own functions here

#-----------------------------------------------------------
# the following is a parser that reads in a simpler version
# of the maze files.  Use it to get started writing the rest
# of the assignment.  You can feel free to move or modify 
# this function however you like in working on your assignment.
#This is a new comment 

def read_and_print_simple_file(file)
  line = file.gets
  if line == nil then return end

  # read 1st line, must be maze header
  sz, sx, sy, ex, ey = line.split(/\s/)
  puts "header spec: size=#{sz}, start=(#{sx},#{sy}), end=(#{ex},#{ey})"

  # read additional lines
  while line = file.gets do

    # begins with "path", must be path specification
    if line[0...4] == "path"
      p, name, x, y, ds = line.split(/\s/)
      puts "path spec: #{name} starts at (#{x},#{y}) with dirs #{ds}"

    # otherwise must be cell specification (since maze spec must be valid)
    else
      x, y, ds, w = line.split(/\s/,4)
      puts "cell spec: coordinates (#{x},#{y}) with dirs #{ds}"
      ws = w.split(/\s/)
      ws.each {|w| puts "  weight #{w}"}
    end
  end


  


end

#----------------------------------
def main(command, fileName)
  maze_file = open(fileName)

  maze = createMaze(maze_file)
 
  # perform command
  case command
  when "open"

     maze.openCells

  when "print"

    maze.printMaze


  when "distance"
  
      maze.distance
  
  when "paths"

     maze.sortPath

  when "solve"

    maze.solvable


  when "bridge"

    maze.countingBridges



  when "sortcells"

    maze.sortingCells

  else
    fail "Invalid command"
  end
end


def createMaze(file)
 
  line = file.gets
  if line != nil

    sz, sx, sy, ex, ey = line.split(/\s/)

    result = Maze.new(sz.to_i, sx.to_i, sy.to_i, ex.to_i, ey.to_i)

    line = file.gets

    while line

      if line[0...4] == "path"

        p, name, x, y, ds = line.split(/\s/)

        if ds != nil
          result.addPath(x.to_i, y.to_i,name,ds )
        end

      else
        x, y, ds, w = line.split(/\s/,4)

        ws = ""
        if w != nil
          ws = w.split(/\s/)
        end

        result.createCell(x.to_i, y.to_i,"normal", ds, ws)

        if ds.length == 4
          result.openCells += 1
        end
        

      end



      line = file.gets
 
    end





  end

  result

end




class Maze

  attr_accessor :start
  attr_accessor :end
  attr_accessor :openCells
  attr_accessor :grid
  attr_accessor :path
  attr_accessor :leastCost


  def initialize(size, sx, sy, ex, ey)

    @start = []
    @start.push(sx)
    @start.push(sy)

    @end = []
    @end.push(ex)
    @end.push(ey)
    
    @openCells = 0

    @grid = Array.new(size){Array.new(size)}
    @path = []
    @sortestPath = []

    @solvable = false


  end

  def createCell(x,y,status, dir, weight)
  
    entry = Cell.new(x,y,status,dir)
    
    entry.updateDirections(weight)

    grid[x][y] = entry
      
  end

  def addPath(x, y, name, dir)

    entry = Path.new(x,y,dir,name)

    @path.push(entry)  

  end


  def countingBridges()
  
    total = 0

    for i in 0 ... @grid.size

      for j in 0 ... @grid.size

        if j + 2 < @grid.size

          if grid[i][j].down.key?("open") && grid[i][j + 1].down.key?("open")
            
            total += 1

          end
           
        end

        if i + 2 < @grid.size

          if grid[i][j].right.key?("open") && grid[i + 1][j].right.key?("open") 

            total += 1

          end

        end



      end
    end


   total
  
  end

  def sortingCells

  openings = {}  
  result = []

  openings[0] = []
  openings[1] = []
  openings[2] = []
  openings[3] = []
  openings[4] = []

  for x in 0 ... @grid.size

    for y in 0 ... @grid.size
    
      open = @grid[x][y].openings

      openings[open].push(@grid[x][y].printCoordinates)
    
    end


  end

  for i in 0 ... 5

    if openings[i].length != 0

      string = i.to_s

      for entry in openings[i] 
        
        string = string + "," + entry
        
      end

      result.push(string)

    end
    

  end

  result


end


  def sortPath

    costs = []

    paths = {}

    result = []

    for entry in @path

      if entry.isValid(@grid)
        paths[entry.name] = entry.cost

        costs.push(entry.cost)
      end
        
    end

    costs = costs.sort

    @leastCost = costs[0]

    for entry in costs

      for path in paths.keys
    
        if paths[path] == entry

          string = "%10.4f" % entry.to_s

          string = string + " " + path

          result.push(string)

        end
        
      end
    
    end



    if result.length == 0

      "none"
      
    else

      result

    end
  end


  def printMaze()

    pathCells = self.smallestPath

    result = ""

    bottem = "+"


    for x in 0 ... @grid.size

      line = []

      for y in 0 ... @grid.size

        line.push(@grid[y][x])


      end

      bottem += "-+"

      result += floorEdge(line) + "\n"
      result +=  wallEdges(line, pathCells) + "\n"
      

    end
    
    result += bottem

  end

  def wallEdges(line, path)

    string = ""

    start = @grid[@start[0]][@start[1]] 
    finish = @grid[@end[0]][@end[1]] 


    for entry in line

      if entry.left.key?("closed")

        string += "|"

      else 
        string += " "

      end
            
       if entry == start

        if path.include?(entry)

          string += "S"
        else
           string += "s"
        end

       elsif entry == finish
         
        if path.include?(entry)
          string += "E"
        else
          string += "e"
        end
        
       elsif path.include?(entry)

        string += "*"

       else

        string += " "

       end


    end

    string += "|"
    
    string

  end

  def floorEdge(line)

  string = "+"

    for entry in line

      if entry.y == 0

        string += "-+"

      else 

        if entry.up.key?("open")
          string += " +"

        else
          string += "-+"
        end

      end

    end

    string

  end



  def smallestPath()

    result = []

    if self.sortPath != "none"

      path = nil

      for entry in @path

        if entry.cost == @leastCost

          path = entry

        end

      end

      x = path.x
      y = path.y

      result.push(@grid[x][y])

      for i in 0 ... path.path.length

        char = path.path[i]

        if char == "r"

          x += 1
          
        elsif char == "l"

          x -= 1
          
        elsif char == "u"

          y -= 1

        elsif char == "d"

          y += 1

        else

          puts "not a direction"

        end

        result.push(@grid[x][y])


      end

    end


    result

  end
   
def solvable()

  start = @grid[@start[0]][@start[1]] 
  
  finish = @grid[@end[0]][@end[1]]


  if finish.openings == 0 || start.openings == 0
    
    false

  else
      
    processd = []

    visit = []

    solve(start, processd, visit, finish)
    
  end

end



def solve(cell, processd, visit, target)

  if cell == target
    true
  else

    processd.push(cell)

    direction = cell.dir.split("")

    for char in direction

      x = cell.x
      y = cell.y

      if char == "r"
        
        if !processd.include?(@grid[x+1][y])

          visit.push(@grid[x+1][y])

        end


      elsif char == "l"

        if !processd.include?(@grid[x-1][y])

          visit.push(@grid[x-1][y])

        end

      elsif char == "d"

        if !processd.include?(@grid[x][y+1])

          visit.push(@grid[x-1][y+1])

        end

      elsif char == "u"

        if !processd.include?(@grid[x][y-1])

          visit.push(@grid[x-1][y-1])

        end

      end
        
    end

    if (visit.length == 0)
      false
    else
      
      nextCell = visit[0]

      visit.delete(nextCell)

      solve(nextCell, processd, visit, target)


    end




  end

end

  def distance

    start = @grid[@start[0]][@start[1]] 


    result = {start => 0}

    result = findPath(start,[],[],result)

    convert = {}

    for entry in result.keys

      distance = result[entry]

      cell = entry

      if convert.key?(distance) == false
      
        convert[distance] = []
      
      end

       convert[distance].push(cell.printCoordinates)


    end

    string = ""

    val = convert.keys.max

    for i in 0 ... (val + 1)
    
      string += i.to_s

      arr = convert[i].sort

      for entry in arr
      
        string += ","

        string += entry
      
      end

      if i < val

        string += "\n"

      end
    
    end
      
    string

      
  end


  def findPath(cell, processd, visit, result)

    processd.push(cell)
    
    direction = cell.dir.split("")

    for char in direction

      x = cell.x
      y = cell.y

     if char == "r" 

      x += 1
       
     elsif char == "l"

      x -= 1
       
     elsif char == "u"

      y -= 1
       
     elsif char == "d"

      y+=1

     end

     work = @grid[x][y]

     if result.key?(work) == false

      result[work] = (result[cell] + 1)

     else

      if result[work] > (result[cell] + 1)

        result[work] = (result[cell] + 1)

      end
    

     end


     if !processd.include?(work)
      
      visit.push(work)

      
    end


    end

    if visit.length == 0

      result

    else

      nextCell = visit[0]

      visit.delete(nextCell)

      findPath(nextCell, processd, visit, result)


      

      
    end

    

  end

end


class Cell

  attr_accessor :x
  attr_accessor :y
  attr_accessor :openings
  attr_accessor :status
  attr_accessor :left
  attr_accessor :right
  attr_accessor :up
  attr_accessor :down
  attr_accessor :dir

  def initialize(x, y, status, dir)

    @x = x
    @y = y

    @status = status
    @dir = dir

    @openings = dir.length
    
    @left = {"closed" => 0.0}
    @right = {"closed" => 0.0}
    @up = {"closed" => 0.0}
    @down = {"closed" => 0.0}

  end

  def printCoordinates()
    
    "(" + @x.to_s + "," + @y.to_s + ")"

  end

  def updateDirections(values)
    
    

    if @dir != nil
      
      for i in 0 ... @dir.length
        updateDirection(@dir[i], values[i].to_f)
      end

      
    end
    
  end

  def updateDirection(char, val)
  
    if char == 'r'

      @right = {"open" => val}

    elsif char == 'l'
      @left = {"open" => val}

    elsif char == 'u'
      @up = {"open" => val}

    elsif char == 'd'
      @down = {"open" => val}

    else 
      puts "Lamo that's not a direction, eiter that or I just failed =("
    end
  
  end



end




class Path

  attr_accessor :name
  attr_accessor :cost
  attr_accessor :x
  attr_accessor :y
  attr_accessor :path


  def initialize(x,y,path, name)

    @x = x
    @y = y
    @path = path
    @name = name
    @valid = false
    @cost = 0.0
  
    
  end

  def isValid(grid)
    
    x = @x
    y = @y

    cell = grid[x][y]


    result = true

     for i in 0 ... @path.length 

      if @path[i] == 'r'
        

        if cell.right.key?("open")

          @cost += cell.right["open"]
          

          x += 1

          cell = grid[x][y]
        else

          result = false

          break;
        end


      elsif @path[i] == 'l'


        if cell.left.key?("open")

          @cost += cell.left["open"]

          x -= 1

          cell = grid[x][y]

        else

          result = false

          break;

      
    
        end

      elsif @path[i] == 'u'


        if cell.up.key?("open")

          @cost += cell.up["open"]

          
          y -= 1

          cell = grid[x][y]

        else
          result = false

          break;


        end


      elsif @path[i] == 'd'


        if cell.down.key?("open")
          @cost += cell.down["open"]

          y += 1
          cell = grid[x][y]
        else 
          result = false

          break;
          
        end


      else

        puts "I don't know how I got here"
        
      end

     end


    result
  
  end


end