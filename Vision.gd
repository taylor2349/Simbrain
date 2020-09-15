#==============================================================================
# VISION
#==============================================================================
# Detects entities and identifies them. 
# Sends an "I see" message to Animal
class_name Vision
extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Vision is ready.")

func _on_Vision_area_entered(area):
	print("I see!")
	
