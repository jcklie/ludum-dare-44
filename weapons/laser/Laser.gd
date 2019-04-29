extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/laser/LaserProjectile.tscn")
	MaxFireDelay = .2
	Velocity = 800
	Damage = 10
	MaxBullets = 3