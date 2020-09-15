#==============================================================================
# TOUCH
#==============================================================================
# Detects entities and identifies them. 
# Sends an "I feel" message to Animal
class_name Touch
extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Touch is ready.")

func _on_Touch_area_entered(area):
	print("I'm touched.")

	
