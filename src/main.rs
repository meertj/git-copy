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
    original: std::string::String, // Alt flag -o
    final_directory: std::string::String, // Might give alternative flag -n
    file:  std::string::String
}

fn main() {
    let args = Cli::parse();

    let original_path = std::path::PathBuf::from(&args.original);
    let final_path = std::path::PathBuf::from(&args.final_directory);
    let original_file_path = std::path::PathBuf::from(args.original.clone() + &args.file);

    // Locate original directory
    if !(original_path.exists()) {
        println!("Original directory not found");
    }

    // Locate original file
    if !(original_file_path.exists()) {
        println!("File not found");
    }

    // Locate new directory
    if !(final_path.exists()) {
        println!("Final directory not found");
    }

    // Apply patches for a "parallel" directory
    let result = Command::new("sh")
        .arg("git_copy_helper.sh")
        .arg(args.original)// Arg 1
        .arg(args.final_directory)// Arg 2
        .arg(args.file)// Arg 3
        .output();
    println!("result {:?}", &result);
}
