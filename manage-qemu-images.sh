#!/bin/bash
# Script to manage QEMU images for Oblivion Desktop testing

set -e

IMAGE_NAME="debian13-trixie-docker.qcow2"
DEFAULT_SIZE="10G"

show_help() {
    echo "QEMU Image Management Script for Oblivion Desktop"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create [size]          Create a new QCOW2 image (default: ${DEFAULT_SIZE})"
    echo "  list                   List available QCOW2 images"
    echo "  info <image>           Show information about an image"
    echo "  resize <image> <size>  Resize an image (+size to expand)"
    echo "  backup <image>         Create a backup of an image"
    echo "  clean                  Remove unused images"
    echo "  help                   Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 create              # Create default image"
    echo "  $0 create 20G          # Create 20GB image"
    echo "  $0 info $IMAGE_NAME    # Show image info"
    echo "  $0 resize $IMAGE_NAME +5G  # Expand image by 5GB"
}

check_qemu() {
    if ! command -v qemu-img &> /dev/null; then
        echo "Error: qemu-img not found. Please install QEMU."
        exit 1
    fi
}

create_image() {
    local size="${1:-$DEFAULT_SIZE}"

    if [ -f "$IMAGE_NAME" ]; then
        echo "Image $IMAGE_NAME already exists. Use a different name or remove it first."
        exit 1
    fi

    echo "Creating QCOW2 image: $IMAGE_NAME ($size)"
    qemu-img create -f qcow2 "$IMAGE_NAME" "$size"

    echo "Image created successfully."
    echo "To install Debian: sudo ./create-qemu-image.sh"
}

list_images() {
    echo "Available QCOW2 images:"
    echo "======================"

    for img in *.qcow2; do
        if [ -f "$img" ]; then
            local size=$(qemu-img info "$img" | grep "virtual size" | cut -d: -f2 | tr -d ' ')
            local format=$(qemu-img info "$img" | grep "file format" | cut -d: -f2 | tr -d ' ')
            echo "  $img - $size - $format"
        fi
    done

    if [ "$(ls *.qcow2 2>/dev/null | wc -l)" -eq 0 ]; then
        echo "  No QCOW2 images found."
    fi
}

show_info() {
    local image="$1"

    if [ ! -f "$image" ]; then
        echo "Error: Image $image not found."
        exit 1
    fi

    echo "Image information: $image"
    echo "========================="
    qemu-img info "$image"
}

resize_image() {
    local image="$1"
    local size="$2"

    if [ ! -f "$image" ]; then
        echo "Error: Image $image not found."
        exit 1
    fi

    echo "Resizing $image to $size..."
    qemu-img resize "$image" "$size"
    echo "Image resized successfully."
}

backup_image() {
    local image="$1"
    local backup="${image}.backup.$(date +%Y%m%d_%H%M%S)"

    if [ ! -f "$image" ]; then
        echo "Error: Image $image not found."
        exit 1
    fi

    echo "Creating backup: $backup"
    cp "$image" "$backup"
    echo "Backup created successfully."
}

clean_images() {
    echo "This will remove all QCOW2 images. Are you sure? (y/N)"
    read -r confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "Removing all QCOW2 images..."
        rm -f *.qcow2
        echo "Images removed."
    else
        echo "Operation cancelled."
    fi
}

# Main script
check_qemu

case "${1:-help}" in
    create)
        create_image "$2"
        ;;
    list)
        list_images
        ;;
    info)
        if [ -z "$2" ]; then
            echo "Error: Please specify an image name."
            exit 1
        fi
        show_info "$2"
        ;;
    resize)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Please specify image and size."
            echo "Usage: $0 resize <image> <size>"
            exit 1
        fi
        resize_image "$2" "$3"
        ;;
    backup)
        if [ -z "$2" ]; then
            echo "Error: Please specify an image name."
            exit 1
        fi
        backup_image "$2"
        ;;
    clean)
        clean_images
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac