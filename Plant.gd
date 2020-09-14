#==============================================================================
# PLANT
#==============================================================================
class_name Plant
extends Area2D

var is_class = "Plant"
var center = Vector2()
var radius = 7
var color = ColorN("forest green")
var inset = 10

func _ready():
	pass

func _process(_delta):
	pass

func _draw(): # Subtypes override this function
	draw_circle(center, radius, color)


#------------------------------------------------------------------------------
# TASKS
#------------------------------------------------------------------------------
"""
---- DONE

---- DOING

---- DO

"""
