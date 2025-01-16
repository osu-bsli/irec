use std::process::ExitCode;
use mavlink_bindgen;

fn main() -> ExitCode {
    let definitions_dir = "src/mavlink_definitions/";
    let out_dir = "src/mavlink_generated/";
    let result = match mavlink_bindgen::generate(definitions_dir, out_dir) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{e}");
            return ExitCode::FAILURE;
        }
    };
    mavlink_bindgen::emit_cargo_build_messages(&result);

    ExitCode::SUCCESS
}