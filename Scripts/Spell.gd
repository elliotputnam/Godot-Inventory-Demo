extends RigidBody

var shoot = false

const DAMAGE = 50
const SPEED = 8
var life_time = .2

func _ready():
	set_as_toplevel(true)
	
func _physics_process(_delta):
	if shoot:	
		pass
		apply_impulse(transform.basis.z, -transform.basis.z * SPEED) 

func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= DAMAGE
		queue_free()
	else:
		queue_free() 

func SelfDestruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()
