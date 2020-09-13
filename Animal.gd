#==============================================================================
# ANIMAL
#==============================================================================
class_name Animal
extends Area2D


func _QUALITIES(): #-----------------------------------------------------------
	# Things that are true of all instances and do not change.
	pass

var own_class_name = "Animal" # Animals can't ask for other Animals' class name.
var screen_size
var max_speed = 3.5
var min_speed = .25
var max_acceleration = .5
var max_rotation = PI/2
var starvation = 100000000   # No starvation yet
var max_munch_time = 25   # No. frames it takes to eat (later, will vary)


func _STATE(): #---------------------------------------------------------------
	# Things that vary with both instance and time. (Move to state object?)
	pass
	
var speed = 0
var direction = 0
var velocity   # Derived from speed and direction
var facing   # Not used yet. Animal always faces current direction
var eating = false
var hunger = 0
var munch_time = 0


func _ready():
	screen_size  = get_viewport_rect().size
	# BUG ---- THIS COLLISION EXCEPTION DOESN'T WORK <<<<<<<<<<<<<<<<<<<<<<<
	# add_collision_exception_with(self)
	change_speed(rand_range(min_speed, max_speed))
	change_direction(rand_range(0, 2*PI))


func _process(delta):
	# Scan for visible objects
	# (Move this down into VisibleRange object.)
	# TODO: This will be convered into signals that trigger reactions,
	#	using the same logic as collisions do. 
#	var visible_objects = $VisibleRange.scan_for_objects()

	# Look around for objects in view
	
	# Update bodily states
	hunger += 1
	if hunger > starvation:
		queue_free()
	if eating:
		if munch_time >= max_munch_time:
			stop_eating()
		else:
			munch_time += 1
			return   # If still eating, don't move.

	# Throw some random changes into the movement.
	if rand_range(1, 100) < 2:
		change_speed(null)
	if rand_range(1, 100) < 2:
		change_direction(null)
		
	# Make it so.	
	move_forward(delta)
		

#------------------------------------------------------------------------------	
# SIGNALS
#------------------------------------------------------------------------------
func _______________________SIGNALS():
	pass

# This signal is not triggering properly.
# It appears rarely and says it saw the  
func _on_VisibleRange_area_entered(area):
	print("I see a ", area.name)


#------------------------------------------------------------------------------	
# REACTIONS
#------------------------------------------------------------------------------
func _______________________REACTIONS():
	pass

func react_to_a_plant(collision):
	# Insert a hunger condition. Don't stop if pretty full. If hit, go around.
	start_eating(collision)


func react_to_an_animal(collision):
	change_speed(max_speed/3)
	pass

	
func react_to_a_thing(collision):
#	print("  ----  I hit something...")
	pass


#------------------------------------------------------------------------------	
# MOVEMENT
#------------------------------------------------------------------------------
func _______________________MOVEMENT():
	pass

func move_forward(delta):
	wrap_on_the_boundaries()  # Before or after collision?
##	var collision = move_and_collide(velocity, delta)
#	if collision:
#		var collider = collision.collider
#		if collider is KinematicBody2D: # Avoid self-reference
#			react_to_an_animal(collision)
#		elif collider is Plant: # All other types use the class directly.
#			react_to_a_plant(collision)
#		else:
#			react_to_a_thing(collision)
	

func change_speed(new_speed):
	if new_speed == null:
		speed += rand_range(-max_acceleration, max_acceleration)
	else:
		speed = new_speed # Entirely new speed
	speed = clamp(speed, min_speed, max_speed)
	update_the_velocity()
	

func change_direction(requested_direction):
	var new_direction
	if requested_direction == null:
		var direction_change = rand_range(-max_rotation, max_rotation)
		new_direction = direction + direction_change
	else:
		new_direction = requested_direction

	# Keep the direction within range of (0, 2*PI) -- do with modulo?
	if new_direction <= 0:
		new_direction += 2*PI
	elif new_direction >= 2*PI:
		new_direction -= 2*PI
		
	direction = new_direction   # Okay. we accept the new direction
	update_the_velocity()
	$AnimalSprite.rotation = direction


func update_the_velocity():
	velocity = Vector2(0, -1) * speed # (a unit vector in the zero direction)
	velocity = velocity.rotated(direction)


# This is strictly temporary. The terrain (sea water) will take care of this. 
func wrap_on_the_boundaries():
	if position.x <= 0:
		position.x = screen_size.x
	elif position.x >= screen_size.x:
		position.x = 0
	if position.y <= 0:
		position.y = screen_size.y
	elif position.y >= screen_size.y:
		position.y = 0
		

#------------------------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------------------------
func _______________________FUNCTIONS():
	pass
	
func start_eating(collision):
#	var collider
#	var location
	eating = true
	munch_time = 0
	var collider = collision.collider
	var location = collider.position
	
	# Set direction of motion and have sprite look that way. 
	# TODO -- Turn this into a call to change_direction.
	$AnimalSprite.look_at(location)
	$AnimalSprite.rotate(PI/2)
	
	
func stop_eating():
	eating = false
	hunger = 0   # Always gets his fill
	speed = max_speed/2
	change_direction(null)

#------------------------------------------------------------------------------
# TASKS
#------------------------------------------------------------------------------
func _______________________TASKS():
	pass

"""
---- STATUS
Movement mostly sorted out now. Speed and direction are primitives, and
velocity is derived from them. Sprite always faces the direction in which
the Animal is moving.

---- ISSUES
If min_speed is zero, some bugs freeze. Due to zeroing the velocity?

---- DONE
[x] Animal has a velocity vector and moves based on that.
[x] TEMP: Animal position wraps around at boundaries
[x] TEMP: Animal angle of motion changes randomly from time to time.
[x] Orientation of sprite matches current Animal direction
[x] Animal varies its speed within specified bounds
[x] Animal collides with plants as well as animals
[x] Animal looks toward a plant when it collides with it.
[x] Start Animal in random direction & random speed
[x] Initialize velocity directly on speed and direction
[x] Animal gets nutrition and will starve if it doesn't.

---- DOING
==== PROJECT: Install the vision system
[o] STATUS: 
	Unable to screen out the Animal's own by via Exception list.
		For now, I just detect the object & then discard it if it's Self. 
		It is doing that fine now & still recognizing *other* Animals
	I currently have a Collision2D object, SightCircle, handling detection
		Can I move the detection up into Animal itself? 
		  
[o] Figure out the right kind of object to handle events in this area
[x] Add a round collision object to Animal with radius = vision length
[o] Use a signal to alert the Animal of an entry into the field
	At the moment, I'm using a method to ask for all the contacts.
	Next step is to switch to a signal. 
[] Eliminate all hits that lie outside the animal's cone of vision

[] LATER: Convert to a triangular collision shape. Simpler & faster. 
	 

---- TODO
[] Animals ignore plants if they aren't very hungry
	-- If they hit them, they treat them like an inert object & turn away 
[] Constrain rotation using modulo & not 4 lines of code.
[] Convert start_eating() to use change_direction() for better encapsulation
	Every time I try to do this, it blows up one me. I'm missing something. 
[] Animal reflects off barriers

"""

