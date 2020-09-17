#==============================================================================
# BOT
#==============================================================================
extends Area2D

var center = Vector2()
var radius = 10
var color = ColorN("red")
var location = Vector2(300, 300)
var speed = 0		# Set in the code
var direction = 0	# Ditto
var velocity = Vector2(0, 0) 	# Derived from speed and direction
var facing   		# Not used yet. Animal always faces current direction

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
