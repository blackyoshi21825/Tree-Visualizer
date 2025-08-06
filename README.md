# 🔥 Fire Tree Visualizer

A cool terminal script that displays directory trees with a fire theme!

## Features
- 🔥 Fire-themed colors and emojis
- 📁 Beautiful tree structure visualization
- 🌍 Cross-platform (Mac, Linux, Windows)
- 🎨 Color-coded file types with unique emojis
- 📊 File size display and folder statistics
- 🔧 Sorting options for better organization

## Usage

### Mac/Linux:
```bash
chmod +x fire-tree.sh
./fire-tree.sh [directory]
```

### Windows:
```cmd
fire-tree.bat [directory]
```

### Examples:
```bash
# Show current directory
./fire-tree.sh

# Show specific directory
./fire-tree.sh /path/to/folder

# Show file sizes
./fire-tree.sh --size

# Show folder counts (files, directories)
./fire-tree.sh --count

# Sort files by size
./fire-tree.sh --sort size

# Combine options
./fire-tree.sh --size --count /path/to/folder
```

## Options
- `--size` - Display file sizes in B/K/M format
- `--count` - Show folder contents count (files, dirs)
- `--sort size` - Sort files by size (largest first)

## Requirements
- **Mac/Linux**: Bash shell
- **Windows**: Git Bash or WSL
