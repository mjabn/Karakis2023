# Karakis2023

Last updated: 06.08.2022
--------------
Files
--------------
* Function files 
1. control_expresion_r_g (Analyzes control images and outputs an average control expression for red and green expression intensities; used to subtract background)
2. pixal_comparing_r_g (Same as the control_expression_r_g function but used for experimental conditions)
3. pixals (Same function as in control_expression_r_g; this function is called in pixal_comparing_r_g.m file)
4. process_r_g (Main image processing function to process raw image into quantitative data)
----------------
* Script file
1. markerintensity_r_g_6_8_vk (main script file to run the code)
----------------

*Instructions: 
- Keep all 5 files in same location
- Only change markerintensity_r_g_6_8_vk file 
Lines 18-21 of “markerintensity”  are the only ones you should change

- When using Matlab, file location is very important
- Use “Copy address as text” and paste the file location into the appropriate line in the script file.
- All experimental images need to be under the same umbrella folder and the control images in a separate umbrella folder.
- This code reads TIFF files only
