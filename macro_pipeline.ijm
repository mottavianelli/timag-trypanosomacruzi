//open("/home/ander/Documents/materias/timag/proyecto/estimación_0/Image1.jpg");
selectWindow("Image1.jpg");
run("Duplicate...", "title=reference");
// paso a blanco y negro, ecualizo histograma y duplico las imágenes
selectWindow("Image1.jpg");
run("8-bit");
run("Enhance Contrast...", "saturated=0.3 equalize");
run("Duplicate...", "title=nucleos_muertos");
run("Duplicate...", "title=nucleos_vivos");
selectWindow("nucleos_muertos");
selectWindow("nucleos_vivos");
run("Duplicate...", "title=citoplasma");
run("Duplicate...", "title=parasitos");
run("Duplicate...", "title=membrana");

// para cada imagen aplico thresholds en los niveles de gris correspondientes a la parte de la célula ([0;30] núcleos muertos, etc.)
/////// núcleos muertos 
selectWindow("nucleos_muertos");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(0, 30);
setOption("BlackBackground", false);
run("Convert to Mask");
// luego aplico morfología matemática para quitar ruido
run("Gray Morphology", "radius=10 type=circle operator=open");
run("Gray Morphology", "radius=3 type=circle operator=dilate");
run("Watershed");
// con el plugin analyze particles cuento las componentes conexas
run("Analyze Particles...", "  show=Outlines display clear");
//saveAs("Results", "C:/Users/pc/Documents/Fing/Timag/proyecto/jpeg/nucleos_muertos_count.csv");

///////// núcleos vivos
selectWindow("nucleos_vivos");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(30, 70);
run("Convert to Mask");
//run("Gray Morphology", "radius=5 type=circle operator=close");
run("Gray Morphology", "radius=8 type=circle operator=open");
run("Gray Morphology", "radius=3 type=circle operator=dilate");
//run("Watershed");
run("Analyze Particles...", "  show=Outlines display clear");
//saveAs("Results", "C:/Users/pc/Documents/Fing/Timag/proyecto/jpeg/nucleos_vivos_count.csv");

///////// citoplasma
selectWindow("citoplasma");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(60, 160);
run("Convert to Mask");
run("Gray Morphology", "radius=3 type=circle operator=erode");
run("Gray Morphology", "radius=9 type=circle operator=close");
run("Gray Morphology", "radius=1 type=circle operator=erode");
//run("Gray Morphology", "radius=10 type=circle operator=open");
//run("Shape Filter", "area=50-Infinity area_convex_hull=0-Infinity perimeter=0-Infinity perimeter_convex_hull=0-Infinity feret_diameter=0-Infinity min._feret_diameter=0-Infinity max._inscr._circle_diameter=0-Infinity area_eq._circle_diameter=0-Infinity long_side_min._bounding_rect.=0-Infinity short_side_min._bounding_rect.=0-Infinity aspect_ratio=1-Infinity area_to_perimeter_ratio=0-Infinity circularity=0-Infinity elongation=0-1 convexity=0-1 solidity=0-1 num._of_holes=0-Infinity thinnes_ratio=0-1 contour_temperatur=0-1 orientation=0-180 fractal_box_dimension=0-2 option->box-sizes=2,3,4,6,8,12,16,32,64 add_to_manager draw_holes fill_results_table exclude_on_edges");


//////// membrana
selectWindow("membrana");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(152, 255);
run("Convert to Mask");
run("Gray Morphology", "radius=3 type=circle operator=dilate");
run("Gray Morphology", "radius=9 type=circle operator=open");
//run("Invert");
//run("Gray Morphology", "radius=5 type=circle operator=close");
//run("Gray Morphology", "radius=10 type=circle operator=open");

///// parásitos, para esta tomo el mismo threshold que para núcleos vivos y luego filtro según el área de las componentes conexas, y también por la posición, que no solo pertenezcan al citoplasma
selectWindow("parasitos");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(30, 70);
run("Convert to Mask");
run("Invert");
run("Shape Filter", "area=5-70 area_convex_hull=0-Infinity perimeter=0-Infinity perimeter_convex_hull=0-Infinity feret_diameter=0-Infinity min._feret_diameter=0-Infinity max._inscr._circle_diameter=0-Infinity area_eq._circle_diameter=0-Infinity long_side_min._bounding_rect.=0-Infinity short_side_min._bounding_rect.=0-Infinity aspect_ratio=1-Infinity area_to_perimeter_ratio=0-Infinity circularity=0-Infinity elongation=0-1 convexity=0-1 solidity=0-1 num._of_holes=0-Infinity thinnes_ratio=0-1 contour_temperatur=0-1 orientation=0-180 fractal_box_dimension=0-2 option->box-sizes=2,3,4,6,8,12,16,32,64 add_to_manager draw_holes fill_results_table exclude_on_edges");

// acá empiezo las operaciones lógicas
imageCalculator("AND create", "parasitos","citoplasma");
selectWindow("membrana");
run("Invert");
imageCalculator("AND create","Result of parasitos", "membrana");
selectWindow("nucleos_muertos");
run("Invert");
imageCalculator("AND create", "Result of Result of parasitos","nucleos_muertos");	
selectWindow("nucleos_vivos");
run("Invert");
imageCalculator("AND create", "Result of Result of Result of parasitos","nucleos_vivos");
run("Analyze Particles...", "  show=Outlines display clear");


selectWindow("nucleos_vivos");
saveAs("Jpeg", "C:/Users/pc/Documents/Fing/Timag/proyecto/nucleos_vivos.jpg");
run("Duplicate...", " ");
run("Green");
run("Invert");
imageCalculator("OR create", "reference","nucleos_vivos-1");
selectWindow("Result of reference");


selectWindow("nucleos_muertos");
saveAs("Jpeg", "C:/Users/pc/Documents/Fing/Timag/proyecto/nucleos_muertos.jpg");
run("Duplicate...", " ");
run("Red");
run("Invert");
imageCalculator("OR create", "reference","nucleos_muertos-1");
//imageCalculator("OR create", "Result of reference","nucleos_muertos-1");

selectWindow("citoplasma");
saveAs("Jpeg", "C:/Users/pc/Documents/Fing/Timag/proyecto/citoplasma.jpg");
run("Duplicate...", " ");
run("Yellow");
imageCalculator("OR create", "reference","citoplasma-1");

selectWindow("Result of Result of Result of Result of parasitos");
saveAs("Jpeg", "C:/Users/pc/Documents/Fing/Timag/proyecto/parasitos.jpg");
run("Duplicate...", " ");
run("Red");
imageCalculator("OR create", "reference","Result of Result of Result of Result of parasitos-1");


