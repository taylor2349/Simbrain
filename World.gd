#==============================================================================
# WORLD
#==============================================================================
class_name SimWorld # May not need this
extends Node2D

var plant = preload("res://Plant.tscn")
var animal = preload("res://Animal.tscn")
var thing = preload("res://Thing.tscn")

var plant_count = 10
var animal_count = 5
var thing_count = 0
var screen_size
var screen_inset = 10
var location = Vector2()

func _ready():
	randomize()
	OS.center_window()
	screen_size  = get_viewport_rect().size
	create_the_world()
	# Set up signals here in ff format.
	# get_node("name").connect"signal", self, function) 

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

#func _process(_delta):
#	pass

#------------------------------------------------------------------------------
# CREATION
#------------------------------------------------------------------------------
func _______________________CREATION():
	pass

func create_the_world():
	create_the_map()
	create_the_things()
#	create_the_plants()
	create_the_animals()

func create_the_map():
	# Load the terrain matrix into memory (as a resource?)
	# Later, this may be a algorithmic generation
	# Paint the map using the WorldMaker scene
	pass

func create_the_things():
	# Things are all the non-living entities 
	pass
	
#func create_the_plants():
#	# TODO: Each Plant type can grow only in certain terrains 
#	var edge = screen_inset
#	for _i in range(plant_count):
#		var new_plant = plant.instance()
#		new_plant.position = pick_a_random_location()
#		add_child(new_plant)
#		update()
		
func create_the_animals():
	# TODO: Each Animal type can be "born" only in certain terrains
	var edge = screen_inset
	for _i in range(animal_count):
		var new_animal = animal.instance()
		new_animal.position = pick_a_random_location()
		add_child(new_animal)
		update()

func pick_a_random_location():
	var a_location = Vector2()
	a_location.x = rand_range(screen_inset, screen_size.x - screen_inset)
	a_location.y = rand_range(screen_inset, screen_size.y - screen_inset)
	return a_location

#------------------------------------------------------------------------------
# SIGNAL CALLBACKS
#------------------------------------------------------------------------------
func _______________________CALLBACKS():
	pass

#------------------------------------------------------------------------------
# TASKS
#------------------------------------------------------------------------------
"""
	
DONE:
	[x] Add the plants here, from the World, using Plant class to create them.
	[x] Move the create methods to create_the_world().
	[x] Extract common location logic

DOING:

DO:
	[] Create a Map scene and create a single instance of it. 
	[] Load the map's defining matrix from a resource file.
	[] Paint the map on the screen, smoothing the b if feasible. 
"""

