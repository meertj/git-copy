#![allow(unused)]

use clap::Parser;
use std::process::Command;
use std::path::Path;

// TODO figure out how to actually flag things
// TODO integration tests with some test directory
// TODO maybe unit test, if necessary
// TODO improve --help


/// Search for a pattern in a file and display the lines that contain it.
#[derive(Parser)]
struct Cli {
    // ALL paths relative to cwd
    original: std::path::PathBuf, // Alt flag -o
    final_directory: std::path::PathBuf // Might give alternative flag -n
}

fn main() {
    let args = Cli::parse();

    // Locate original file/directory
    if !(args.original.exists()) {
        println!("Directory not found");
    }

    // Locate new file/directory
    if !(args.final_directory.exists()) {
        println!("Directory not found");
    }

    // Create temp directory
    Command::new("mkdir")
        .arg("/tmp/git-migrate-patches")
        .spawn()
        .expect("mkdir command failed to start");

    // // Export patches
    // Command::new("export")
    //     .arg("target_patches=".to_owned() + &args.original.as_path().display().to_string())
    //     .spawn()
    //     .expect("Export patches failed to start");

    // Save off patches
    let target_patches = args.original.as_path().display().to_string();
    let patch_string = "/tmp/git-migrate-patches $(git log ".to_owned() + &target_patches + "|grep ^commit|tail -1|awk '{print $2}')^..HEAD " + &target_patches;
    Command::new("git")
        .arg("format-patch")
        .arg("-o")
        .arg(patch_string)
        .spawn();

    // cd to destination directory
    Command::new("cd")
        .arg(&args.final_directory.as_path().display().to_string())
        .spawn();

    // Apply patches for a "parallel" directory
    Command::new("git")
        .arg("am")
        .arg("/tmp/git-migrate-patches")
        .spawn();

    // Clean up temp directory
    Command::new("rm")
        .arg("-rf")
        .arg("/tmp/git-migrate-patches")
        .spawn()
        .expect("rm -rf command failed to start");
}
