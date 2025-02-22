# Alex's Dotfiles
As of now there is only a script for dynamic waybar background for single apps, but there will be more stuff coming!

## Dynamic background for Waybar
SO, to use this thing you will basically need only waybar installed, but if you want to use a script to create a color for a specific app you will also need `grim` for screenshot and `magick` for color exctraction.

#### The way this works:
1. There is a polling of a workspace check, if you have only one app opened - script gets the app's class, title, and floating options.
2. Then the script checks the `CLASSES_FILE` and `TITLES_FILE` for predefined color variable.
   - This files can be located where you want, they are not generated.
   - The format of a color for `CLASSES_FILE`: `@define-color $class rgba($r, $g, $b, $opacity);`
   - The format of a color for `TITLES_FILE`: `@define-color $class_$custom_title rgba($r, $g, $b, $opacity);`
   - Colors can be added automatically only to a `CLASSES_FILE` via `set_new_single_app_bg.sh`, which basically makes a screenshot, exctracts the top middle pixel, and adds a color with opacity 1.0 and the class of the active window to the file.
   - Title of the active app is processed into a string of words divided by | and then checked via `grep` if there is a $class + $title match for any of the words.
3. After that the script generates a color with a format described in `COLOR_LINE` and values from `CLASSES_FILE` OR `TITLES_COLOR`.
4. At the end script replaces the color in `COLOR_FILE` with a static name that is then used in Waybar's `style.css` file as a variable.
   - The `COLOR_FILE` has to be imported into `style.css`: ![image](https://github.com/user-attachments/assets/7168e338-089f-476a-a0f6-c2706eade895)

   - Example of use: ![image](https://github.com/user-attachments/assets/a1b76136-7d8d-43ae-a776-6fde2e365ae1)

6. It is also important to "touch" the `style.css` so that waybar only updates the style.
