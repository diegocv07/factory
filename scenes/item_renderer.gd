extends Node2D

@export var sprite_sheet: CompressedTexture2D = preload("res://assets/Items.png")
const TILE_SIZE: int = 64
#var sprite_instance : RID
var rs = RenderingServer
var timer = 1
var _sprite_instances : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#sprite_instance = rs.canvas_item_create()
	#rs.canvas_item_set_default_texture_filter(sprite_instance, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	#rs.canvas_item_set_parent(sprite_instance, get_canvas_item())
	#var trans = Transform2D(0, Vector2.ZERO)
	#rs.canvas_item_set_transform(sprite_instance, trans)
	

func create_item_render(item_id: int, pos: Vector2i, texture: Texture2D = sprite_sheet):
	var new_sprite_instance = rs.canvas_item_create()
	rs.canvas_item_set_default_texture_filter(new_sprite_instance, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	rs.canvas_item_set_parent(new_sprite_instance, get_canvas_item())
	
	var trans = Transform2D(0, pos * TILE_SIZE)
	rs.canvas_item_set_transform(new_sprite_instance, trans)
	rs.canvas_item_add_texture_rect(new_sprite_instance, Rect2(0, 0, TILE_SIZE, TILE_SIZE), texture)
	
	_sprite_instances.get_or_add(item_id, new_sprite_instance)
	print("create item render with id = " + str(item_id))
	
func delete_item_render(item_id: int):
	var instance_id = _sprite_instances.get(item_id)
	if instance_id == null:
		return
	rs.canvas_item_clear(instance_id)
	rs.free_rid(instance_id)
	_sprite_instances.erase(item_id)
	
func tileIndexToVector(tile_idx: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(tile_idx % GameFactoryManager.MAP_WIDTH, tile_idx / GameFactoryManager.MAP_WIDTH)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#rs.canvas_item_clear(sprite_instance)
	for belt_id in GameFactoryManager.belt_store.occupied.ids:
	
		var belt_pos: Vector2i = tileIndexToVector(GameFactoryManager.belt_store.grid_indices[belt_id])
		var direction = GameFactoryManager.belt_store.directions[belt_id]
		
		for item_slot in range(GameFactoryManager.belt_store.MAX_ITEMS_PER_BELT):
			var item_idx = GameFactoryManager.belt_store.get_item_index(belt_id, item_slot)
			if (GameFactoryManager.belt_store.item_types[item_idx] == GameFactoryManager.belt_store.EMPTY):
				continue
				
			var sprite_instance = _sprite_instances.get(GameFactoryManager.belt_store.item_ids[item_idx])
			assert(sprite_instance != null)
				
			var item_pos = GameFactoryManager.belt_store.item_positions[item_idx]
			var offset = Vector2.ZERO
			match direction:
				GameFactoryManager.belt_network.Direction.UP:
					offset.y -= item_pos
				GameFactoryManager.belt_network.Direction.DOWN:
					offset.y += item_pos
				GameFactoryManager.belt_network.Direction.RIGHT:
					offset.x += item_pos
				GameFactoryManager.belt_network.Direction.LEFT:
					offset.x -= item_pos 
					
			#rs.canvas_item_add_texture_rect(sprite_instance, Rect2(belt_pos.x * 64 + offset.x * 64, belt_pos.y * 64 + offset.y * 64, 64, 64), sprite_sheet)
			
			var trans = Transform2D(0, Vector2(belt_pos.x * 64 + offset.x * 64.0, belt_pos.y * 64 + offset.y * 64.0))
			rs.canvas_item_set_transform(sprite_instance, trans)
