package main

N_MESH_VERTICES :: 8
mesh_vertices : [N_MESH_VERTICES]vec3_t = {
    {-1, -1, -1}, // 1
    {-1,  1, -1}, // 2
    { 1,  1, -1}, // 3
    { 1, -1, -1}, // 4
    { 1,  1,  1}, // 5
    { 1, -1,  1}, // 6
    {-1,  1,  1}, // 7
    {-1, -1,  1}, // 8
}

N_MESH_FACES :: (6 * 2)
mesh_faces : [N_MESH_FACES]face_t = {
    // front
    {1, 2, 3},
    {1, 3, 4},
    // right
    {4, 3, 5},
    {4, 5, 6},
    // back
    {6, 5, 7},
    {6, 7, 8},
    // left
    {8, 7, 5},
    {8, 2, 1},
    // top
    {2, 7, 5},
    {2, 5, 3},
    // bottom
    {6, 8, 1},
    {6, 1, 4},
}