extends Control

signal close_inventory
signal open_inventory

func _ready():
	$BookBackground/VBoxContainer/MainElements/Tabs/GoldCounter.set_text(str(ImportData.inven_data.Gold))
	LoadInventory()

func LoadInventory():
	for i in get_tree().get_nodes_in_group("InventorySlots"):
		var node_name = str(i.get_name()) # Retrieves int of node name "101, 102, 103..."
		if ImportData.inven_data.has(node_name): # If the node exists
			var inventory_slots_to_fill = str(get_path_to(i))
			get_node(inventory_slots_to_fill + "/ItemName").set_text(ImportData.inven_data[node_name][0])
			var icon = "res://Art/Items/" + ImportData.inven_data[node_name][0] + ".png"
			get_node(inventory_slots_to_fill + "/ItemBackground/ItemButton").set_normal_texture(load(icon))
			if ImportData.inven_data[node_name][1] > 1: # If the quantity is larger than one (stackable)
				get_node(inventory_slots_to_fill + "/ItemBackground/ItemButton/Label").set_text(str(ImportData.inven_data[node_name][1]))


func _on_ExitButton_pressed():
	emit_signal("close_inventory")

func _on_InventoryOpen_pressed():
	emit_signal("open_inventory")
