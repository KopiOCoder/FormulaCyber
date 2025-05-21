extends Control


const LEADERBOARD_PATH := "user://leaderboard.json"

# Load the leaderboard from file
func load_leaderboard() -> Array:
	if not FileAccess.file_exists(LEADERBOARD_PATH):
		return []

	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
	var data := file.get_as_text()
	file.close()

	var result = JSON.parse_string(data)
	if result is Array:
		# Sort by descending score
		result.sort_custom(func(a, b): return b["score"] - a["score"])
		return result
	return []

# Save a new score to the leaderboard
func save_score(name: String, score: int) -> void:
	var leaderboard = load_leaderboard()
	leaderboard.append({ "name": name.strip_edges().substr(0, 3).to_upper(), "score": score })

	# Sort and keep only top 100
	leaderboard.sort_custom(func(a, b): return b["score"] - a["score"])
	if leaderboard.size() > 100:
		leaderboard = leaderboard.slice(0, 100)

	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(leaderboard))
		file.close()

	
