#==============================================================================
# TOUCH
#==============================================================================
# Detects entities and identifies them & Sends an "I feel" message to Animal

class_name Touch
extends Area2D

func _ready():
	monitorable = false # Don't let detection areas detecting each other.


func _on_Touch_area_entered(area):
	var parent = get_parent()
	if area.name != parent.name:
		# (parent.name, " touches ", area.name)
		parent.respond_to_touch(area)

	
