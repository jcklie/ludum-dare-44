extends StaticBody2D

var health = 100
	
func damage(damage):
	health -= damage

	if health <= 0:
		queue_free()