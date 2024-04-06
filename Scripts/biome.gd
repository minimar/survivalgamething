extends Area2D
class_name biome
#The name of the biome in snake case
@export var biomeName: String
#The biome collision shape
@export var biomeShape: CollisionPolygon2D
#The corresponding enemySpawns file
@export_file("*EnemySpawns.gd") var enemySpawns

#The actual polygon as vector2 points
var biomePolygon: PackedVector2Array
# Called when the node enters the scene tree for the first time.
func _ready():
	#Gets the polygon
	biomePolygon = biomeShape.polygon


#Sends a signal when the player enters the biome
signal playerEnteredBiome
func _on_player_entered(body):
	if body is Player:
		playerEnteredBiome.emit(biomeName)
