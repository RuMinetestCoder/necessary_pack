# cuboids_lib

API for working with cubes.

## API

* **cuboids_lib.get_cube**(*pos1, pos2*) - get counted cube '{x_min, x_max, y_min, y_max, z_min, z_max}'
* **cuboids_lib.contains**(*cube, pos*) - return true if pos in cuboid
* **cuboids_lib.get_width**(*cube*) - return number
* **cuboids_lib.get_height**(*cube*) - return number
* **cuboids_lib.get_depth**(*cube*) - return number
* **cuboids_lib.get_volume**(*cube*) - return number
* **cuboids_lib.get_nodes**(*cube*) - return array "{'x' = .., 'y' = .., 'z' = ..}"
