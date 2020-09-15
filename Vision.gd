#==============================================================================
# VISION
#==============================================================================
# Detects entities and identifies them. 
# Sends an "I see" message up to owning Animal
class_name Vision
extends Area2D

func _ready():
	monitorable = false # Sensory areas aren't real objects


func _on_Vision_area_entered(area):
	var parent = get_parent()
	if area.name != parent.name:
		print(parent.name, " sees ", area.name)
		parent.respond_to_vision(area)
	
