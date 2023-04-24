extends CanvasLayer

signal open_chest(chest)
signal open_inventory
signal save_inventory

var main_ui_control = "None"
var chest

func _ready():
	for i in get_tree().get_nodes_in_group("LootChests"):
		i.connect("in_loot_range", self, "_on_LootChest_in_loot_range")
		i.connect("out_loot_range", self, "_on_LootChest_out_loot_range")
	connect("save_inventory", ImportData, "on_SaveInventory")

func _on_LootChest_in_loot_range(chest_name):
	chest = chest_name
	var loot_texture = load("res://Art/Items/leatherpouch.png")
	get_node("MapSceneControls/Main_UI_Control/Main_UI_Icon").set_texture(loot_texture)
	main_ui_control = "loot"

func _on_LootChest_out_loot_range():
	get_node("MapSceneControls/Main_UI_Control/Main_UI_Icon").texture = null
	main_ui_control = "None"
	
func _on_Main_UI_Control_pressed():
	if main_ui_control == "loot":
		var lootpanel = load("res://Scenes/LootPanel.tscn").instance()
		add_child(lootpanel)
		get_parent().get_node("Player").mouseMode = 0
		emit_signal("open_chest", chest)
		get_node("LootPanel").connect("close_lootpanel", self, "_on_CloseLootPanel")
		
	elif main_ui_control == "None":
		pass
		
func _on_CloseLootPanel():
	get_node("LootPanel").queue_free()
	get_parent().get_node("Player").mouseMode = 1
	emit_signal("save_inventory")
	
func _on_InvenPressed():
	var inventoryPanel = load("res://Scenes/Inventory.tscn").instance()
	add_child(inventoryPanel)
	emit_signal("open_inventory")
	get_parent().get_node("Player").mouseMode = 0
	get_node("Inventory").connect("close_inventory", self, "_on_InvenClose")

func _on_InvenClose():
	get_node("Inventory").queue_free()
	get_parent().get_node("Player").mouseMode = 1
	get_parent().get_node("Player").invenOpen = false
	emit_signal("save_inventory")
