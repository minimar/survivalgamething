extends Area2D
class_name biome
@export var biomeName: String
@export var biomeShape: CollisionPolygon2D
@export var enemySpawns: Dictionary
var biomePolygon: PackedVector2Array
# Called when the node enters the scene tree for the first time.
func _ready():
	biomePolygon = biomeShape.polygon

signal playerEnteredBiome
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_player_entered(body):
	if body is Player:
		playerEnteredBiome.emit(biomeName)
