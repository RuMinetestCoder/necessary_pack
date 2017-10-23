cuboids_lib = {}

function cuboids_lib.get_cube(pos1, pos2)
    local result = {}
    if pos2.x > pos1.x then
        result.x_min = pos1.x
        result.x_max = pos2.x
    else
        result.x_min = pos2.x
        result.x_max = pos1.x
    end
    if pos2.y > pos1.y then
        result.y_min = pos1.y
        result.y_max = pos2.y
    else
        result.y_min = pos2.y
        result.y_max = pos1.y
    end
    if pos2.z > pos1.z then
        result.z_min = pos1.z
        result.z_max = pos2.z
    else
        result.z_min = pos2.z
        result.z_max = pos1.z
    end
    return result
end

function cuboids_lib.contains(cube, pos)
    return (pos.x >= cube.x_min and pos.x <= cube.x_max and pos.y >= cube.y_min and
            pos.y <= cube.y_max and pos.z >= cube.z_min and pos.z <= cube.z_max)
end

function cuboids_lib.get_width(cube)
    return cube.x_max - cube.x_min + 1
end

function cuboids_lib.get_height(cube)
    return cube.z_max - cube.z_min + 1
end

function cuboids_lib.get_depth(cube)
    return cube.y_max - cube.y_min + 1
end

function cuboids_lib.get_volume(cube)
    return cuboids_lib.get_width(cube) * cuboids_lib.get_height(cube) * cuboids_lib.get_depth(cube)
end

function cuboids_lib.get_nodes(cube)
    local result = {}
    for x = cube.x_min, cube.x_max do
        for y = cube.y_min, cube.y_max do
            for z = cube.z_min, cube.z_max do
                local xyz = minetest.parse_json(tostring('{"x":%d,"y":%d,"z":%d}'):format(tostring(x), tostring(y), tostring(z)))
                table.insert(result, xyz)
            end
        end
    end
    return result
end
