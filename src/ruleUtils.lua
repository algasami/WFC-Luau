local t = require(script.Parent.typing)

local ruleUtils = {}

function pInbound(tilemap: t.tilemap, x: number, y: number)
	return 1 <= x and x <= tilemap.width and 1 <= y and y <= tilemap.height
end

function pAddRules_unsafe(tilemap: t.tilemap, tox: number, toy: number, orientation: t.tileOrientation): t.rule
	local rule: t.rule = {
		next = tilemap.data[toy][tox],
		orientation = orientation,
	}
	return rule
end

function pAddRules(tilemap: t.tilemap, coord: t.coord2): { [t.tileOrientation]: t.rule }
	local pack: { [t.tileOrientation]: t.rule } = {}
	local x = coord.x
	local y = coord.y
	-- right
	if pInbound(tilemap, x + 1, y) then
		pack["RIGHT"] = pAddRules_unsafe(tilemap, x + 1, y, "RIGHT")
	end
	-- left
	if pInbound(tilemap, x - 1, y) then
		pack["LEFT"] = pAddRules_unsafe(tilemap, x - 1, y, "LEFT")
	end
	-- up
	if pInbound(tilemap, x, y - 1) then
		pack["UP"] = pAddRules_unsafe(tilemap, x, y - 1, "UP")
	end
	-- down
	if pInbound(tilemap, x, y + 1) then
		pack["DOWN"] = pAddRules_unsafe(tilemap, x, y + 1, "DOWN")
	end
	return pack
end

function pFindDupRule(arr: { t.rule }, rule: t.rule): boolean
	for _, value in pairs(arr) do
		if value.next == rule.next and value.orientation == rule.orientation then
			return true
		end
	end
	return false
end

function ruleUtils.tilemapFromModel(mapmodel: Model)
	local tilemap: t.tilemap = {
		data = {},
		width = 0,
		height = 0,
	}
	local tileSize = mapmodel:GetChildren()[1]["base"].Size
	local origin = mapmodel:GetChildren()[1]["base"].Position

	for _, v in pairs(mapmodel:GetChildren()) do
		if v:GetAttribute("start") then
			tileSize = v["base"].Size
			origin = v["base"].Position
		end
	end

	local y = 0
	local x = 0
	while true do
		y += 1
		tilemap.data[y] = {}
		while true do
			x += 1
			local pos = origin + (y - 1) * Vector3.new(0, 0, tileSize.Z) + (x - 1) * Vector3.new(tileSize.X, 0, 0)
			local foundtile = nil
			for _, model in pairs(mapmodel:GetChildren()) do
				if (model["base"].Position - pos).Magnitude < 0.1 then
					foundtile = model
					break
				end
			end
			if foundtile == nil then
				tilemap.width = math.max(tilemap.width, x - 1)
				break
			end
			tilemap.data[y][x] = foundtile.Name
		end
		if x <= 1 then
			tilemap.height = y - 1
			break
		end
		x = 0
	end
	return tilemap
end

function ruleUtils.new(tilemap: t.tilemap, universalIdentifiers: { t.tileIdentifier })
	local ruleset: t.ruleset = {
		data = {},
		identifiers = {},
		universalIdentifiers = universalIdentifiers,
	}
	for y = 1, tilemap.height, 1 do
		for x = 1, tilemap.width, 1 do
			local thisIdentifier = tilemap.data[y][x]
			if table.find(ruleset.identifiers, thisIdentifier) == nil then
				table.insert(ruleset.identifiers, thisIdentifier)
			end
			local thisRule = pAddRules(tilemap, { x = x, y = y })
			if ruleset.data[thisIdentifier] == nil then
				ruleset.data[thisIdentifier] = {
					RIGHT = {},
					LEFT = {},
					UP = {},
					DOWN = {},
				}
			end
			if thisRule["RIGHT"] and not pFindDupRule(ruleset.data[thisIdentifier]["RIGHT"], thisRule["RIGHT"]) then
				table.insert(ruleset.data[thisIdentifier]["RIGHT"], thisRule["RIGHT"])
			end
			if thisRule["LEFT"] and not pFindDupRule(ruleset.data[thisIdentifier]["LEFT"], thisRule["LEFT"]) then
				table.insert(ruleset.data[thisIdentifier]["LEFT"], thisRule["LEFT"])
			end
			if thisRule["UP"] and not pFindDupRule(ruleset.data[thisIdentifier]["UP"], thisRule["UP"]) then
				table.insert(ruleset.data[thisIdentifier]["UP"], thisRule["UP"])
			end
			if thisRule["DOWN"] and not pFindDupRule(ruleset.data[thisIdentifier]["DOWN"], thisRule["DOWN"]) then
				table.insert(ruleset.data[thisIdentifier]["DOWN"], thisRule["DOWN"])
			end
		end
	end
	return ruleset
end

return ruleUtils
