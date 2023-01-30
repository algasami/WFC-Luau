export type tileIdentifier = string
export type tileOrientation = "RIGHT" | "LEFT" | "UP" | "DOWN"

export type rule = {
	next: tileIdentifier,
	orientation: tileOrientation,
}

export type coord2 = {
	x: number,
	y: number,
}

export type ruleset = {
	data: { [tileIdentifier]: { [tileOrientation]: { rule } } },
	identifiers: { tileIdentifier },
	universalIdentifiers: { tileIdentifier },
}
export type tilemap = {
	data: { { tileIdentifier } },
	width: number,
	height: number,
}

return {}
