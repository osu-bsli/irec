const vec2 verts[3] = vec2[3](
    vec2(0.0, 1.0),
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0)
);
const vec4 colors[3] = vec4[3](
    vec4(1.0, 0.0, 0.0, 1.0),
    vec4(0.0, 1.0, 0.0, 1.0),
    vec4(0.0, 0.0, 1.0, 1.0)
);
out vec4 v_color;
uniform float u_angle;
uniform mat4 u_transform;
void main() {
    v_color = colors[gl_VertexID];
    gl_Position = vec4(verts[gl_VertexID], 0.0, 1.0);
    gl_Position *= u_transform;
}