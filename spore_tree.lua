--------------------------------------------------
-- Spore Tree

-- Teal
-- raining spores
-- Max trunk height 	5
-- depth 2-3

-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

minetest.register_node("dfcaverns:spore_tree", {
	description = S("Spore Tree"),
	tiles = {"dfcaverns_spore_tree_top.png", "dfcaverns_spore_tree_top.png", "dfcaverns_spore_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node,
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, {name="air"})
		minetest.spawn_tree(pos, dfcaverns.spore_tree_model)
	end,
	
})

minetest.register_node("dfcaverns:spore_tree_frond", {
	description = S("Spore Tree Frond"),
	waving = 1,
	tiles = {"dfcaverns_spore_tree.png"},
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	walkable = false,
	climbable = true,
	
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			{-0.0625, -0.0625, -0.5, 0.0625, 0.0625, 0.5},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("dfcaverns:spore_tree_pod", {
	description = S("Spore Tree Fruiting Body"),
	waving = 1,
	tiles = {"dfcaverns_spore_tree.png"},
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	walkable = false,
	climbable = true,
	
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, 
			{-0.0625, -0.0625, -0.5, 0.0625, 0.0625, 0.5}, 
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625}, 
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		}
	},
	
	drop = {
		max_items = 1,
		items = {
			{
				items = {'dfcaverns:spore_tree_sapling'},
				rarity = 10,
			},
			{
				items = {'dfcaverns:spore_tree_frond'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})


minetest.register_node("dfcaverns:spore_tree_sapling", {
	description = S("Spore Tree Spawn"),
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"dfcaverns_spore_tree_sapling.png"},
	inventory_image = "dfcaverns_spore_tree_sapling.png",
	wield_image = "dfcaverns_spore_tree_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1, light_sensitive_fungus = 11},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(dfcaverns.config.spore_tree_min_growth_delay,dfcaverns.config.spore_tree_max_growth_delay))
	end,
	
	on_timer = function(pos)
		minetest.set_node(pos, {name="air"})
		dfcaverns.spawn_spore_tree(pos)
	end,
})

--fcaverns.spore_tree_def={
--	axiom="TTdddA",
--	rules_a="[&&&Tdd&&FF][&&&++++Tdd&&FF][&&&----Tdd&&FF]",
--	rules_d="T",
--	trunk="dfcaverns:spore_tree",
--	leaves="dfcaverns:spore_tree_frond",
--	leaves2="dfcaverns:spore_tree_pod",
--	leaves2_chance=30,
--	angle=30,
--	iterations=2,
--	random_level=0,
--	trunk_type="single",
--	thin_branches=true,
--}

local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_spore_pod = minetest.get_content_id("dfcaverns:spore_tree_pod")
local c_tree = minetest.get_content_id("dfcaverns:spore_tree")
local c_spore_frond = minetest.get_content_id("dfcaverns:spore_tree_frond")

dfcaverns.spawn_spore_tree_vm = function(vi, data, area, height, size, iters, has_fruiting_bodies)
	if height == nil then height = math.random(3,6) end
	if size == nil then size = 2 end
	if iters == nil then iters = 10 end
	if has_fruiting_bodies == nil then has_fruiting_bodies = math.random() < 0.5 end

	local pos = area:position(vi)
	local x, y, z = pos.x, pos.y, pos.z
	
	local has_fruiting_bodies = true

	-- Trunk
	data[area:index(x, y, z)] = c_tree -- Force-place lowest trunk node to replace sapling
	for yy = y + 1, y + height - 1 do
		local vi = area:index(x, yy, z)
		local node_id = data[vi]
		if node_id == c_air or node_id == c_ignore or node_id == c_spore_frond then
			data[vi] = c_tree
		end
	end

	-- Force leaves near the trunk
	for z_dist = -1, 1 do
	for y_dist = -size, 1 do
		local vi = area:index(x - 1, y + height + y_dist, z + z_dist)
		for x_dist = -1, 1 do
			if data[vi] == c_air or data[vi] == c_ignore then
				if has_fruiting_bodies and math.random() < 0.3 then
					data[vi] = c_spore_pod
				else
					data[vi] = c_spore_frond
				end
			end
			vi = vi + 1
		end
	end
	end

	-- Randomly add fronds in 2x2x2 clusters.
	for i = 1, iters do
		local clust_x = x + math.random(-size, size - 1)
		local clust_y = y + height + math.random(-size, 0)
		local clust_z = z + math.random(-size, size - 1)

		for xi = 0, 1 do
			for yi = 0, 1 do
				for zi = 0, 1 do
					local vi = area:index(clust_x + xi, clust_y + yi, clust_z + zi)
					if data[vi] == c_air or data[vi] == c_ignore then
						if has_fruiting_bodies and math.random() < 0.3 then
							data[vi] = c_spore_pod
						else
							data[vi] = c_spore_frond
						end
					end
				end
			end
		end
	end
end

dfcaverns.spawn_spore_tree = function(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local height = math.random(4, 5)

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = x - 2, y = y, z = z - 2},
		{x = x + 2, y = y + height + 1, z = z + 2}
	)
	local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	dfcaverns.spawn_spore_tree_vm(area:indexp(pos), data, area)

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end


minetest.register_abm{
	label = "spore tree raining spores",
	nodenames = {"dfcaverns:spore_tree_pod"},
	interval = 1,
	chance = 30,
	catch_up = false,
	action = function(pos)
		minetest.add_particle({
			pos = pos,
			velocity = {x=math.random() * 0.2 - 0.1, y=-1, z=math.random() * 0.2 - 0.1},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 3,
			size = 10,
			collisiondetection = false,
			vertical = false,
			texture = "farming_wheat_seed.png",
		})
		
	end,
}
