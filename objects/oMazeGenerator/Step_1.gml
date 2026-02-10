if (!initializeGridElements) {
	for (var row = 0; row < mapHeight; row++) {
		for (var col = 0; col < mapWidth; col++) {
			
            var elementX = x_offset + (col * gridSize);
            var elementY = y_offset + (row * gridSize);
			
			if (tileMap[col][row].hasPellet()) {
				instance_create_layer(elementX, elementY, "GameElements", oDot);
			}
			else if (tileMap[col][row].isEnergizer()) {
				instance_create_layer(elementX, elementY, "GameElements", oPowerPill);			
			}		
			else if (tileMap[col][row].isPacman()) {
				instance_create_layer(elementX, elementY, "GameElements", oPacman);			
			}
		}
	}

	initializeGridElements = true;
}

