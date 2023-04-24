extends Control

signal close_lootpanel

var map_name
var loot_count
var loot_dic = {}
var current_chest

func _ready():
	map_name = "Grassland01" #link this to external variable in future
	get_parent().connect("open_chest", self, "OpenChest")
	
func OpenChest(chest):
	current_chest = get_parent().get_parent().get_node(chest)
	if current_chest.looted == false:
		DetermineLootCount()
		LootSelector()
		PopulatePanel()
	if current_chest.looted == true: #populates the contents of the previously generated items
		loot_dic = current_chest.contents
		PopulatePanel()

func DetermineLootCount():
	var ItemCountMin = ImportData.LootData[map_name].ItemCountMin # Gets the min amount of loot
	var ItemCountMax = ImportData.LootData[map_name].ItemCountMax # Gets the max amount of loot
	randomize() # randomizes the seed so it's truly random
	loot_count = randi() % ((int(ItemCountMax) - int(ItemCountMin)) + 1) + int(ItemCountMin)
	print(loot_count) # TODO: REMOVE THIS
	
func LootSelector():
	for _i in range(1, loot_count + 1):
		randomize()
		var loot_selector = randi() % 100 + 1
		var counter = 1 # Sets the counter to 1, see below
		while loot_selector >= 0:
			# Item (1) Chance, references our LootData collumn Item1Chance
			if loot_selector <= ImportData.LootData[map_name]["Item" + str(counter) + "Chance"]:
				var loot = [] # If the loot selector rolls the Item1Chance collumn's rate, it will add to loot list
				loot.append(ImportData.LootData[map_name]["Item" + str(counter) + "Name"])
				randomize()
				loot.append((int(rand_range(float(ImportData.LootData[map_name]["Item" + str(counter) + "MinQ"]), float(ImportData.LootData[map_name]["Item" + str(counter) + "MaxQ"])))))
				loot_dic[loot_dic.size() + 1] = loot # takes current size of dictionary and adds a key value +1
				break
			else: # when loot selector !<= first item, it subtracts first item from total and re rolls to item 2
				loot_selector = loot_selector - ImportData.LootData[map_name]["Item" + str(counter) + "Chance"]
				counter = counter + 1 # this turns the roll chance into item 2
	print(loot_dic) # TODO: REMOVE THIS
		
func PopulatePanel(): 
	var counter = 1 # var counter = end result of LootSelector()
	print(counter) # TODO: REMOVE THIS -- error handling to confirm correct function
	for i in get_tree().get_nodes_in_group("LootPanelSlots"): # Iterates through each node in group "LootPanelSlots"
		
		if loot_dic.has(counter):
			get_node(str(i.get_path()) + "/ItemName").set_text(loot_dic[counter][0]) # Building node path to the "ItemName" of the loot slot
			var icon = "res://Art/Items/" + str(loot_dic[counter][0]) + ".png" # Combines //Art/ assets with icon
			get_node(str(i.get_path()) + "/LootIcon/LootButton").set_normal_texture(load(icon))
			if loot_dic[counter][1] > 1: # if the quantity is over 1, add item count label
				get_node(str(i.get_path()) + "/LootIcon/LootButton/Label").set_text(str(loot_dic[counter][1]))
		counter = counter + 1


func _on_Close_pressed():
	current_chest.looted = true
	current_chest.contents = loot_dic
	emit_signal("close_lootpanel")
	print(ImportData.inven_data.Gold) # TODO: REMOVE THIS
	pass # Replace with function body.


func _on_LootButton_pressed(lootpanelslot): # Determines which loot slot was pressed
	var slot_checker_start # First slot within every category, 101, 201, etc
	var slot_checker_max # Max amount of slots in each category
		
	if loot_dic.has(lootpanelslot): # If the slot is poulated
		var looted_item_name = loot_dic[lootpanelslot][0]
		if looted_item_name == "Gold": # If the slot selected is Gold
			ImportData.inven_data.Gold = ImportData.inven_data.Gold + loot_dic[lootpanelslot][1] # Add gold to inventory data
			loot_dic.erase(lootpanelslot) # Removes the item from the loot box
			var loot_slot_root = "Border/Background/MainNodes/Lootslots/VBoxContainer/Loot" + str(lootpanelslot)
			get_node(loot_slot_root + "/LootIcon/LootButton").set_normal_texture(null) # Removes the image
			get_node(loot_slot_root + "/LootIcon/LootButton/Label").set_text("") # Removes the item counter
			get_node(loot_slot_root + "/ItemName").set_text("") # Removes the item name
		else:
			match ImportData.ItemData[looted_item_name].ItemType:
				"Weapons":
					slot_checker_start = 101
					slot_checker_max = 115
				"Armor":
					slot_checker_start = 201
					slot_checker_max = 215
				"Crafting":
					slot_checker_start = 301
					slot_checker_max = 315
				"Consumables":
					slot_checker_start = 401
					slot_checker_max = 415
				"Misc":
					slot_checker_start = 501
					slot_checker_max = 515
			while slot_checker_start <= slot_checker_max + 1:
				if slot_checker_start > slot_checker_max:
					# Checks if inventory is full
					print("Your inventory is full")
					# TODO: Replace with functional popup
					break
				elif ImportData.inven_data.has(str(slot_checker_start)):
					slot_checker_start = slot_checker_start + 1
					
				else:
					ImportData.inven_data[str(slot_checker_start)] = loot_dic[lootpanelslot]
					loot_dic.erase(lootpanelslot) # Removes the item from the loot panel
					var loot_slot_root = "Border/Background/MainNodes/Lootslots/VBoxContainer/Loot" + str(lootpanelslot)
					get_node(loot_slot_root + "/LootIcon/LootButton").set_normal_texture(null) # Removes the image
					get_node(loot_slot_root + "/LootIcon/LootButton/Label").set_text("") # Removes the item counter
					get_node(loot_slot_root + "/ItemName").set_text("") # Removes the item name
					print(ImportData.inven_data)
					return
	else:
		return

# Runs a click on each filled item slot from _on_LootButton_pressed function
func _on_LootAll_pressed(): 
	for lootpanelslot in range (1, 7):
		_on_LootButton_pressed(lootpanelslot)
	_on_Close_pressed()
