#!/bin/bash

# Function to print informational messages
function info {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

# Function to print error messages
function error {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# Function to print success messages
function success {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

# Check if necessary files exist
if [[ ! -f "resources.rc" ]]; then
    error "File resources.rc not found!"
    exit 1
fi

if [[ ! -f "resource.h" ]]; then
    error "File resource.h not found!"
    exit 1
fi

if [[ ! -f "TheRedRose.c" ]]; then
    error "File TheRedRose.c not found!"
    exit 1
fi

if [[ ! -f "icon.ico" ]]; then
    error "File icon.ico not found!"
    exit 1
fi

# Compile resources.rc into resources.o
info "Compiling resources.rc into resources.o..."
x86_64-w64-mingw32-windres resources.rc resources.o
if [[ $? -ne 0 ]]; then
    error "Compilation of resources.rc failed!"
    exit 1
fi
success "Compilation of resources.rc completed successfully."

# Compile the main program and link the resource file
info "Compiling the main program with resources.o..."
x86_64-w64-mingw32-gcc -o TheRedRose.exe TheRedRose.c resources.o -mwindows
if [[ $? -ne 0 ]]; then
    error "Compilation of the main program failed!"
    exit 1
fi
info "Compilation of the main program completed successfully."

# Completion message
success "Compilation finished. The executable has been created as TheRedRose.exe"
