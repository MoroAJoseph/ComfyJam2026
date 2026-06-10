class_name InventoryService extends RefCounted

static func get_total_count(items: Array[BlockItemData]) -> int:
	return items.reduce(func(acc, item): return acc + item.stack_count, 0)

static func get_total_value(items: Array[BlockItemData]) -> int:
	return items.reduce(func(acc, item): return acc + item.total_value, 0)

static func can_add(inventory: InventoryData, item_to_add: BlockItemData) -> bool:
	if get_total_count(inventory.items) >= inventory.capacity:
		return false
	
	# Check if any stack can accommodate the remainder
	var fits_in_stack = inventory.items.any(func(i): 
		return i.type == item_to_add.type and i.stack_count < i.max_stack
	)
	
	return fits_in_stack or (get_total_count(inventory.items) + item_to_add.stack_count <= inventory.capacity)

static func add_item(inventory: InventoryData, item_to_add: BlockItemData) -> bool:
	var initial_count = get_total_count(inventory.items)
	
	# Stack into existing
	for item in inventory.items:
		if item.type == item_to_add.type and item.stack_count < item.max_stack:
			var space = item.max_stack - item.stack_count
			var amount = min(space, item_to_add.stack_count)
			item.stack_count += amount
			item_to_add.stack_count -= amount
			if item_to_add.stack_count <= 0: break

	# Add new stacks
	while item_to_add.stack_count > 0:
		if get_total_count(inventory.items) >= inventory.capacity:
			break
			
		var amount = min(item_to_add.stack_count, item_to_add.max_stack)
		inventory.items.append(BlockItemData.new(item_to_add.type, amount))
		item_to_add.stack_count -= amount

	return get_total_count(inventory.items) > initial_count
