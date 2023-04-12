void main() {
    float t = v_tex_coord.x;
    gl_FragColor = mix(vec4(0.01, 0.01, 0.01, 0.0), vec4(0.188, 0.275, 0.306, 1.0), t);
}

