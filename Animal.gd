#==============================================================================
# ANIMAL
#==============================================================================
class_name Animal
extends Area2D


func properties(): #-----------------------------------------------------------
	pass

# Class properties
var is_class = "Animal" # Animals can't ask for other Animals' class name.
var screen_size
var max_speed = 150
var min_speed = 20
var max_acceleration = 30
var max_rotation = PI/2
var starvation = 100000000   # No starvation yet
var max_munch_time = 40   # No. frames it takes to eat (later, will vary)

# Instance Properties	
var speed = 0		# Set in the code
var direction = 0	# Ditto
var velocity   		# Derived from speed and direction
var facing   		# Not used yet. Animal always faces current direction
var eating = false
var hunger = 0
var munch_time = 0

func _ready():
	screen_size  = get_viewport_rect().size
	change_speed(rand_range(min_speed * 2, max_speed))
	change_direction(rand_range(0, 2*PI))


func _process(delta):
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
	if rand_range(1, 100) < 3:
		change_speed(null)
	if rand_range(1, 100) < 1:
		change_direction(null)
		
	# Make it so.	
	move_forward(delta)
		

#------------------------------------------------------------------------------	
# SIGNALS
#------------------------------------------------------------------------------
func _______________________SIGNALS():
	pass

# Bodily contact
func _on_Animal_area_entered(area):
	pass
#	print(self.name, " hits ", area.name)

# Touch contact (based on signal in Touch)
func respond_to_touch(entity):
	if entity.is_class == "Plant":
		touching_a_plant(entity)
	elif entity.is_class == "Animal":
		touching_an_animal(entity)

# Visual contact (based on signal from Vision)
func respond_to_vision(entity):
	if entity.is_class == "Plant":
		seeing_a_plant(entity)
	elif entity.is_class == "Animal":
		seeing_an_animal(entity)

#------------------------------------------------------------------------------	
# REACTIONS
#------------------------------------------------------------------------------
func _______________________REACTIONS():
	pass

func touching_a_plant(plant):
	# TODO: Eat only if hungry. If run into plant, go around.
	change_direction(get_angle_to(plant.position) + PI/2)
	change_speed(min_speed)
	start_eating(plant)


func touching_an_animal(entity):
	# TODO: Make sure the animal isn't detecting itself.
	if self.name != entity.name:
		change_speed(max_speed)
		change_direction(null)

	
func seeing_a_plant(plant):
	# This is first-sighting only. Have to start tracking it now.
	# TODO: Why do I have to add PI/2 to get the correct angle???
	var aim_for = get_angle_to(plant.position)
	aim_for += PI/2  # TEMP
	change_direction(aim_for)
	change_speed(max_speed)


func seeing_an_animal(animal):
	# This is first-sighting only. Have to start tracking it now.
	# For now, just slow down and angle off in a new direction. 
	#print("           Avoiding that animal.")
	change_direction(null)
	change_speed(min_speed)


#------------------------------------------------------------------------------	
# MOVEMENT
#------------------------------------------------------------------------------
func _______________________MOVEMENT():
	pass

func move_forward(delta):
	update_the_velocity()
	position += velocity * delta
	wrap_on_the_boundaries()
	

func change_speed(new_speed):
	if new_speed == null: # null = accelerate or decelerate 
		speed += rand_range(-max_acceleration, max_acceleration)
	else:
		speed = new_speed # value = set a new speed
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
	## TODO: Get rid of this direct access 
	$AnimalSprite.rotation = direction


func update_the_velocity():
	velocity = Vector2(0, -1) * speed # (a unit vector in the zero direction)
	velocity = velocity.rotated(direction)


# Code is strictly temporary. The terrain (sea water) will take care of this. 
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
	
func start_eating(entity):
	eating = true
	munch_time = 0
	var plant_location = entity.position
#	change_direction(plant_location.get_angle())
#	Set direction of motion and have sprite look that way. 
	# TODO -- Turn this into a call to change_direction.
#	$AnimalSprite.look_at(location)
#	$AnimalSprite.rotate(PI/4) # No longer need this?
	

func stop_eating():
	eating = false
	hunger = 0   # Always gets his fill
	change_speed(null)
	change_direction(null)

#------------------------------------------------------------------------------
# TASKS
#------------------------------------------------------------------------------
func _______________________TASKS():
	pass

"""
STATUS -----------------------------------------------------------------------
Movement mostly sorted out now. Speed and direction are primitives, and
velocity is derived from them. Sprite always faces the direction in which
the Animal is moving.

ISSUES -----------------------------------------------------------------------
[] If min_speed is zero, some bugs freeze. Due to zeroing the velocity?
[] Should I include delta in: position += velocity * delta? 
[] BUG: Animals overshoot when they collide with something. They go over it. 
	>> Its outer shape is colliding with plants. (?)
	>> The problem increases with speed.
	>> I have to stop all motion at the moment of contact. 
	>> AHA! I need to send a signal from touch to Animal, not call a funciton.
		Function waits until the next _process cycle. The signal is immediate.

DONE -------------------------------------------------------------------------
--- PROJECT: BASIC MOVEMENT
[x] Animal has a velocity vector and moves based on that.
[x] TEMP: Animal position wraps around at boundaries
[x] TEMP: Animal angle of motion changes randomly from time to time.
[x] Orientation of sprite matches current Animal direction
[x] Animal varies its speed within specified bounds
[x] Animal looks toward a plant when it collides with it.
[x] Start Animal in random direction & random speed
[x] Initialize velocity directly on speed and direction
[x] Animal gets nutrition and will starve if it doesn't.
[x] Figure out the right kind of object to handle events in this area
[x] Recover lost code up to the point of adding vision

--- PROJECT: Installing the vision system
[x] Add a second collision area to Animal for vision
[x] Add a round collision object to Animal with radius = vision length
[x] Use a signal to alert the Animal of an entry into the field


DOING ------------------------------------------------------------------------
[] Have senses send messages to Animal rather than calling functions. 
	We neeed this to get immediate responses. 
[] Convert vision detection zones to triangular shapes. 
	 

TODO -------------------------------------------------------------------------
[] Fix the direction system so I don't have to PI/2 each time. 
[] Animals ignore plants if they aren't very hungry
	-- If they hit them, they treat them like an inert object & turn away 
[] Constrain rotation using modulo & not 4 lines of code.
[] Convert start_eating() to use change_direction() for better encapsulation
	Every time I try to do this, it blows up one me. I'm missing something. 
[] Animal reflects off barriers

"""
