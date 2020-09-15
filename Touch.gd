#==============================================================================
# TOUCH
#==============================================================================
# Detects entities and identifies them. 
# Sends an "I feel" message to Animal
class_name Touch
extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Touch_area_entered(area):
	# First, rule out any 
	# The ff. must include all areas I create around the Animal
	# TODO: Screen more precisely. Skip any his if these detection 
	# areas belong to the animal doing the detection. 
	# print("The owneris...", owner)
	
	if area.name != "Vision" and area.name != "Touch":
		get_parent().respond_to_touch(area)

	
