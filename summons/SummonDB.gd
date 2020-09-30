extends Node

const SUMMON_PATH = "res://summons/"
const WALL_PATH = "res://summons/walls/"
const WALL = "res://summons/walls/wall.tscn"

const WALLS = {
	"clay wall": {
		"image" : "clay-wall",
		"tags" : ["earth", "water"],
		"health" : 3,
	},
	}

func get_summon(summon_id, section):
	if summon_id in section:
		return section[summon_id]

func wall_setup(summon_id):
	var summon = load(WALL).instance()
	summon.set_meta("id", summon_id)
	summon.set_texture(load(WALL_PATH + get_summon(summon_id, WALLS)["image"] + ".png"))
	summon.health = get_summon(summon_id, WALLS)["health"]
	summon.tags = get_summon(summon_id, WALLS)["tags"]
	return summon
