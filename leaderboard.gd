extends Control



const LEADERBOARD_PATH := "user://leaderboard.json"

func load_leaderboard() -> Array:
	if not FileAccess.file_exists(LEADERBOARD_PATH):
		return []

	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
	if file == null:
		return []

	var data := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(data)
	if typeof(parsed) == TYPE_ARRAY:
		var leaderboard = parsed
		leaderboard.sort_custom(func(a, b): return b["score"] - a["score"])
		return leaderboard
	else:
		print("Failed to parse leaderboard or invalid format.")
		return []


func save_score(name: String, score: int) -> void:
	var leaderboard = load_leaderboard()
	var clean_name = name.strip_edges().substr(0, 3).to_upper()
	leaderboard.append({ "name": clean_name, "score": score })
	leaderboard.sort_custom(func(a, b): return b["score"] - a["score"])


	if leaderboard.size() > 10:
		leaderboard = leaderboard.slice(0, 10)

	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open leaderboard file for writing")
		return

	file.store_string(JSON.stringify(leaderboard, "\t"))
	file.close()

func _sort_desc(a, b) -> int:
	return b["score"] - a["score"]
