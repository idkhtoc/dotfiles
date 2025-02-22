#!/bin/bash

# Define the paths for the Waybar CSS and Pywal color files
CLASSES_FILE="$HOME/.cache/wal/colors-waybar-classes.css"
TEMP_SCRSHOT="$HOME/.cache/wal/single_window_screenshot.png"

save_color() {
    color=$1
    class=$2

    read r g b < <(echo $color | awk -F'[(,)]' '{print $2, $3, $4}')

    rgba="rgba($r, $g, $b, 1.0)"

    if grep -q $class "$CLASSES_FILE"; then
        # If the class exists, update the color
        sed -i "s/^@define-color $class .*/@define-color $class $rgba;/" "$CLASSES_FILE"

        echo "Updated! Window: $class, Color: $rgba"
    else
        # If the class doesn't exist, add a new line with the color
        echo "@define-color $class $rgba;" >> "$CLASSES_FILE"

        echo "Added! Window: $class, Color: $rgba"
    fi
}

toggle_opacity() {
    value=$1

    hyprctl dispatch setprop active opaque $value > /dev/null 2>&1
}

# Function to take a screenshot of the active window and exctract color from it
generate_color() {
    toggle_opacity true

    # Take a screenshot of the active window
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$TEMP_SCRSHOT"

    # Get a color from the top middle pixel from the created screenshot
    color=$(magick $TEMP_SCRSHOT -format "%[pixel:p{$(identify -format "%w" $TEMP_SCRSHOT)/2,0}]\n" info:)

    # Remove the temporary screenshot
    rm "$TEMP_SCRSHOT"

    toggle_opacity false

    # Return the dominant color
    echo $color
}

get_window_class() {
    class=$(hyprctl activewindow -j | jq -r .class)

    echo $class
}

# Function to check if there is only one window open
get_window_count() {
    workspace_id=$(hyprctl activeworkspace -j | jq -r .id)

    window_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $workspace_id and .floating == false)] | length")

    echo "$window_count"
}

main() {
    window_count=$(get_window_count) 

    # If there is only one window, change color
    if [ $window_count -eq 1 ]; then
        # Extract color from the current application
        class=$(get_window_class)

        color=$(generate_color)

        save_color $color $class
    fi
}

main
