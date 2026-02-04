#!/bin/sh

# GPU Cache Cleaner Script
# Clears various GPU caches that can cause performance degradation over time

echo "Cleaning GPU caches..."

# Clear Mesa shader cache
if [ -d "/tmp/mesa_shader_cache" ]; then
    echo "Clearing Mesa shader cache..."
    rm -rf /tmp/mesa_shader_cache/*
fi

# Clear general GL shader cache
if [ -d "/tmp" ]; then
    echo "Clearing GL shader cache..."
    find /tmp -name "*gl_shader*" -type f -delete 2>/dev/null
fi

# Clear AMD GPU specific caches if they exist
if [ -d "$HOME/.cache/mesa" ]; then
    echo "Clearing Mesa cache directory..."
    rm -rf $HOME/.cache/mesa/*
fi

echo "GPU cache cleanup complete!"
echo "You may want to restart your game to ensure optimal performance."