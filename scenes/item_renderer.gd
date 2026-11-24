extends Node2D

@export var sprite_sheet : Texture2D
var sprite_instance : RID
var rs = RenderingServer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	sprite_instance = rs.canvas_item_create()
	rs.canvas_item_set_default_texture_filter(sprite_instance, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	rs.canvas_item_set_parent(sprite_instance, get_canvas_item())
	var trans = Transform2D(0, Vector2.ZERO)
	rs.canvas_item_set_transform(sprite_instance, trans)
	

# TODO make one sprite instance for each item so transforms are unique
func create_item_render():
	pass
# TODO
func delete_item_render():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rs.canvas_item_clear(sprite_instance)
	for belt_id in GameFactoryManager.active_belts.ids:
		# For all belts with items...
		if !GameFactoryManager.belt_store.occupied.contains(belt_id):
			continue
		
		var flattened_idx = GameFactoryManager.belt_network.tile_from_belt_id[belt_id]
		@warning_ignore("integer_division")
		var belt_pos : Vector2 = Vector2(flattened_idx % GameFactoryManager.MAP_WIDTH, flattened_idx / GameFactoryManager.MAP_WIDTH)
		var direction = GameFactoryManager.belt_store.directions[belt_id]
		match direction:
			GameFactoryManager.belt_network.Direction.UP:
				belt_pos.y += 1.0/2.0
			GameFactoryManager.belt_network.Direction.DOWN:
				belt_pos.y -= 1.0/2.0
			GameFactoryManager.belt_network.Direction.RIGHT:
				belt_pos.x -= 1.0/2.0
			GameFactoryManager.belt_network.Direction.LEFT:
				belt_pos.x += 1.0/2.0
		for idx in range(0, GameFactoryManager.MAX_ITEMS_PER_BELT):
			for item_idx in GameFactoryManager.belt_store.get_item_index(belt_id, idx):
				if (GameFactoryManager.belt_store.item_types[item_idx] == -1):
					continue
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
				rs.canvas_item_add_texture_rect(sprite_instance, Rect2(belt_pos.x * 64 + offset.x * 64, belt_pos.y * 64 + offset.y * 64, 64, 64), sprite_sheet)
