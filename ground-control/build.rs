use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rustc-link-lib=static=fusion");

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    let fusion_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("src/Fusion");

    // Generate the bindings
    let mut builder = bindgen::Builder::default()
        .header(fusion_path.join("Fusion.h").to_string_lossy())
        .blocklist_var("FP_.*")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .wrap_static_fns(true)
        .wrap_static_fns_path(out_path.join("extern.c"))
        .use_core();

    if let Ok(path) = env::var("FUSION_IMU_INCLUDE_PATH") {
        builder = builder.clang_arg(format!("-I{}", path));
    }

    let bindings = builder.generate().expect("Unable to generate bindings");
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Failed to write bindings");

    // Compile the C library
    cc::Build::new()
        .files(&[
            fusion_path.join("FusionAhrs.c"),
            fusion_path.join("FusionCompass.c"),
            fusion_path.join("FusionOffset.c"),
            out_path.join("extern.c"),
        ])
        .compile("fusion");
}