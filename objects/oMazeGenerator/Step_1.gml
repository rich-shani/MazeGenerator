if (!initializeGridElements) {

	// setup Ghosts
	var elementX = x_offset + (12 * gridSize);
	var elementY = y_offset + (11 * gridSize);
			
	instance_create_layer(elementX, elementY, "GameElements", oBlinky);		

	for (var row = 0; row < mapHeight; row++) {
		for (var col = 0; col < mapWidth; col++) {
			
            elementX = x_offset + (col * gridSize);
            elementY = y_offset + (row * gridSize);
	
			if (tileMap[col][row].isWall()) {
				instance_create_layer(elementX, elementY, "GameElements", Wall);
			}
			else if (tileMap[col][row].hasPellet()) {
				instance_create_layer(elementX, elementY, "GameElements", oDot);
			}
			else if (tileMap[col][row].isEnergizer()) {
				instance_create_layer(elementX, elementY, "GameElements", oPowerPill);			
			}	
			else if (tileMap[col][row].isTunnel()) {
				instance_create_layer(elementX, elementY, "GameElements", Slow);		
			}
			else if (tileMap[col][row].isPacman()) {
				instance_create_layer(elementX, elementY, "GameElements", oPacman);			
			}
		}
	}


	
	initializeGridElements = true;
}

