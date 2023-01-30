local t = require(script.Parent.typing)
local mapUtils = {}

function pRandomChoose(arr: { t.tileIdentifier })
	return arr[math.random(1, #arr)]
end

local laskTick = tick()
function pValidInsert(
	ruleset: t.ruleset,
	current: t.tileIdentifier?,
	orientation: t.tileOrientation
): { t.tileIdentifier }
	if current == nil or ruleset.data[current] == nil then
		return ruleset.identifiers
	end
	local ids: { t.tileIdentifier } = {}
	for _, rule in pairs(ruleset.data[current][orientation]) do
		table.insert(ids, rule.next)
	end
	return ids
end

function pAddToValidCount(validCount: { [t.tileIdentifier]: number }, list: { t.tileIdentifier })
	for _, id in pairs(list) do
		validCount[id] += 1
	end
end

function mapUtils.generateTile(
	map: t.tilemap,
	ruleset: t.ruleset,
	coord: t.coord2,
	callback: ((t.coord2, tile: t.tileIdentifier) -> nil),
	retry: number?,
	traversed: { t.coord2 }?,
	doself: boolean?
)
	local x = coord.x
	local y = coord.y

	if traversed == nil then
		traversed = {} :: { t.coord2 }
	else
		for _, v in pairs(traversed) do
			if v.x == x and v.y == y and not doself then
				return traversed
			end
		end
	end
	table.insert(traversed, { x = x, y = y })
	if map.data[y] == nil then
		map.data[y] = {}
	end
	if map.data[y][x] ~= nil and retry == nil and table.find(ruleset.universalIdentifiers, map.data[y][x]) == nil then
		return
	end
	local validCount: { [t.tileIdentifier]: number } = {}
	local validInsertion: { t.tileIdentifier } = {}
	for _, name in pairs(ruleset.identifiers) do
		validCount[name] = 0
	end
	-- from the right (to left)
	task.desynchronize()
	pAddToValidCount(validCount, pValidInsert(ruleset, map.data[y][x + 1], "LEFT"))
	-- from the left (to right)
	pAddToValidCount(validCount, pValidInsert(ruleset, map.data[y][x - 1], "RIGHT"))
	-- from the up (to down)
	if map.data[y - 1] then
		pAddToValidCount(validCount, pValidInsert(ruleset, map.data[y - 1][x], "DOWN"))
	else
		pAddToValidCount(validCount, ruleset.identifiers)
	end
	-- from the down (to up)
	if map.data[y + 1] then
		pAddToValidCount(validCount, pValidInsert(ruleset, map.data[y + 1][x], "UP"))
	else
		pAddToValidCount(validCount, ruleset.identifiers)
	end
	task.synchronize()

	for id, count in pairs(validCount) do
		if count == 4 then
			table.insert(validInsertion, id)
		end
	end

	if #validInsertion == 0 or (#validInsertion == 1 and retry ~= nil) then
		if retry == nil or retry < 3 then
			retry = retry or 0
			retry += 1
			if tick() - laskTick > 1 then
				laskTick = tick()
				task.wait()
			end
			-- TODO: Entropy-based sorting
			mapUtils.generateTile(map, ruleset, { x = x + 1, y = y }, callback, retry, traversed)
			mapUtils.generateTile(map, ruleset, { x = x - 1, y = y }, callback, retry, traversed)
			mapUtils.generateTile(map, ruleset, { x = x, y = y + 1 }, callback, retry, traversed)
			mapUtils.generateTile(map, ruleset, { x = x, y = y - 1 }, callback, retry, traversed)

			return mapUtils.generateTile(map, ruleset, { x = x, y = y }, callback, retry, traversed, true)
		elseif #validInsertion == 0 then -- if validInsertion is 0 then it will choose a random tile from the universalIdentifiers (entropy = 0)
			map.data[y][x] = pRandomChoose(ruleset.universalIdentifiers)
			callback({ x = x, y = y }, map.data[y][x])
			return traversed
		end -- if validInsertion is over 0 then it will simply give up and choose a random tile from the validInsertion
	end
	map.data[y][x] = pRandomChoose(validInsertion)
	callback({ x = x, y = y }, map.data[y][x])

	return traversed
end

return mapUtils
