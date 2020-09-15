#==============================================================================
# ANIMAL
#==============================================================================
class_name Animal
extends Area2D


func _QUALITIES(): #-----------------------------------------------------------
	# Things that are true of all instances and do not change.
	pass

var is_class = "Animal" # Animals can't ask for other Animals' class name.
var type = "Animal"
var screen_size
var max_speed = 150
var min_speed = 20
var max_acceleration = 30
var max_rotation = PI/3
var starvation = 100000000   # No starvation yet
var max_munch_time = 40   # No. frames it takes to eat (later, will vary)


func _STATE(): #---------------------------------------------------------------
	# Things that vary with both instance and time. (Move to state object?)
	pass
	
var speed = 0		# Set in the code
var direction = 0	# Ditto
var velocity   		# Derived from speed and direction
var facing   # Not used yet. Animal always faces current direction
var eating = false
var hunger = 0
var munch_time = 0


func _ready():
	screen_size  = get_viewport_rect().size
	change_speed(max_speed/2)
#	change_speed(rand_range(min_speed, max_speed))
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

#func _on_Touch_area_entered(area):
#	print("I'm touched.") 
#	pass # Replace with function body.

func respond_to_touch(entity):
	print("Touching ", entity.name)
	if entity.is_class == "Plant":
		react_to_a_plant(entity)
	elif entity.is_class == "Animal":
		react_to_an_animal(entity)

#------------------------------------------------------------------------------	
# REACTIONS
#------------------------------------------------------------------------------
func _______________________REACTIONS():
	pass

func react_to_a_plant(entity):
	# TODO: Eat only if hungry. If run into plant, go around.
	start_eating(entity)


func react_to_an_animal(entity):
	print(">>>>>>> I hit an animal!")
	change_speed(min_speed * 2)
	change_direction(null)

	
func react_to_a_thing(entity):
	print("  ----  I hit something...")


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
	
func start_eating(entity):
	eating = true
	munch_time = 0
	var location = entity.position
	
	# Set direction of motion and have sprite look that way. 
	# TODO -- Turn this into a call to change_direction.
	$AnimalSprite.look_at(location)
	$AnimalSprite.rotate(PI/2)
	print("Chowing down.")
	
	
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
[] If min_speed is zero, some bugs freeze. Due to zeroing the velocity?
[] Should I include delta in: position += velocity * delta? 
[] BUG: Animals overshoot when they collide with something. The go over it. 
	>> Its outer shape is colliding with plants. 
	>> How do I get it to respond differently to different collision shapes?


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
[x] Recover lost code up to the point of adding vision
[x] Add a second collision area to Animal for vision
[] BUG: Doesn't recognize other animals. Filtering out based on *their* shapes.
	That is, they hit the body and ignore the touch report. 
	Arghhh!

==== PROJECT: Install the vision system
[o] STATUS: 
	Unable to screen out the Animal's own by via Exception list.
		For now, I just detect the object & then discard it if it's Self. 
		It is doing that fine now & still recognizing *other* Animals
	I currently have a Collision2D object, SightCircle, handling detection
		Can I move the detection up into Animal itself? 
		  
[x] Figure out the right kind of object to handle events in this area
[] Add a round collision object to Animal with radius = vision length
[] Use a signal to alert the Animal of an entry into the field
	At the moment, I'm using a method to ask for all the contacts.
	Next step is to switch to a signal. 
[] Eliminate all hits that lie outside the animal's cone of vision

	 

---- TODO
[] LATER: Convert to a triangular collision shape. Simpler & faster. 
[] Animals ignore plants if they aren't very hungry
	-- If they hit them, they treat them like an inert object & turn away 
[] Constrain rotation using modulo & not 4 lines of code.
[] Convert start_eating() to use change_direction() for better encapsulation
	Every time I try to do this, it blows up one me. I'm missing something. 
[] Animal reflects off barriers

"""
