require "minitest/autorun"
require_relative "maze.rb"

$MAZE1 = "maze1"
$MAZE2 = "maze2"



puts main("open", $MAZE1)
puts main("print", $MAZE1)
puts main("distance", $MAZE1)
puts main("solve", $MAZE1)

puts main("paths", $MAZE2);
