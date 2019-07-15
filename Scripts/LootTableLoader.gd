extends Node

export(String, FILE, "*.json") var loot_tables_path
var loot_tables = {}

func execute_loot_table(table):
	var loot_table = loot_tables.get(table)
	if not loot_table: return null
	return loot_table.execute()

func _ready(): _generate_loot_tables()

func _generate_loot_tables():
	var file = File.new()
	file.open(loot_tables_path, File.READ)
	var parse = JSON.parse(file.get_as_text())
	var parsed_loot_tables = parse_json(file.get_as_text())
	for table in parsed_loot_tables:
		loot_tables[table] = _generate_table(table, parsed_loot_tables[table])

func _generate_table(table_id, table_data):
	var pools = []
	for pool_data in table_data: pools.push_back(_generate_pool(pool_data))
	return LootTable.new(table_id, pools)

func _generate_pool(pool_data):
	var entries = []
	for entry_data in pool_data:
		var weight = 1 if not "weight" in entry_data else entry_data.weight
		var count = 1 if not "count" in entry_data else entry_data.count
		entries.push_back(LootTable.PoolEntry.new(entry_data.get("item"), weight, count))
	return LootTable.Pool.new(entries)