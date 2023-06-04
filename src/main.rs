#![allow(unused)]

use clap::Parser;
use std::process::Command;
use std::path::Path;
use shutil::pipe;
use regex::Regex;

// TODO figure out how to actually flag things
// TODO integration tests with some test directory
// TODO maybe unit test, if necessary
// TODO improve --help


/// Search for a pattern in a file and display the lines that contain it.
#[derive(Parser)]
struct Cli {
    // ALL paths relative to cwd
    original: std::path::PathBuf, // Alt flag -o
    final_directory: std::path::PathBuf, // Might give alternative flag -n
    file: std::path::PathBuf
}

fn main() {
    let args = Cli::parse();

    // Locate original file/directory
    if !(args.original.exists()) {
        println!("Original directory not found");
    }

    // Locate new file/directory
    if !(args.final_directory.exists()) {
        println!("Final directory not found");
    }

    // Temp directory
    let temp_directory = std::env::temp_dir().join("/git-migrate-patches");
    println!("temp dir = {:?}", temp_directory);


    // Create temp directory
    let result = Command::new("mkdir")
        .arg(temp_directory.clone())
        .output();


    // Set current dir to original dir
    std::env::set_current_dir(args.original.as_path().display().to_string());


    // Get git commits
    let git_log_result = Command::new("git")
        .arg("log")
        .output()
        .unwrap();
    let stdout = String::from_utf8(git_log_result.stdout).unwrap();


    let re = Regex::new(r"(?:commit\s)([0-9a-fA-F]+)(.*)").unwrap();
    let mat = re.captures(&stdout).unwrap();
    println!("result {:?}", &mat[1]);


    // Save off patches
    let target_patches = args.original.as_path().display().to_string();
    let patch_string = temp_directory.as_path().display().to_string() + " "
                              + &mat[1] + "^..HEAD "
                              + &args.file.as_path().display().to_string();
    let result = Command::new("git")
        // .current_dir(target_patches.clone())
        .arg("format-patch")
        .arg("-o")
        .arg(patch_string)
        .output();
    println!("result {:?}", &result);


    // Verify that the changes are in the temp dir
    let result = Command::new("ls")
        .current_dir(temp_directory.clone())
        .arg("-llrth")
        .output();
    println!("result {:?}", &result);


    // Set current dir to final dir
    std::env::set_current_dir(args.final_directory.as_path().display().to_string());


    // Apply patches for a "parallel" directory
    let result = Command::new("git")
        .arg("am")
        .arg(temp_directory.clone())
        .output();
    println!("result {:?}", &result);


    // Clean up temp directory
    let result = Command::new("rm")
        .arg("-rf")
        .arg(temp_directory.clone())
        .output();
    println!("result {:?}", &result);
}
