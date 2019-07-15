class_name LootTable

class Pool:
	var entries = []
	var total_weight = 0
	
	func _init(entries):
		self.entries = entries
		for entry in entries: total_weight += entry.weight
	
	func execute():
		var weight_choice = randi() % total_weight
		for entry in entries:
			if weight_choice < entry.weight: return entry
			weight_choice -= entry.weight

class PoolEntry:
	var item
	var weight
	var count
	
	func _init(item, weight, count):
		self.item = item
		self.weight = int(weight)
		self.count = int(count)
	
var id
var pools = []

func _init(id, pools):
	self.id = id
	self.pools = pools

func execute():
	var results = {}
	for pool in pools:
		var pool_result = pool.execute()
		if pool_result.item: results[pool_result.item] = pool_result.count
	return results