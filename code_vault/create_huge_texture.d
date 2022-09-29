module code_vault.create_huge_texture;

/// Create a massive image as the ground texture
        /*
        TrueColorImage originTexture = loadImageFromFile("textures/grass.png").getAsTrueColorImage();

        int size = 128;

        TrueColorImage newTexture = new TrueColorImage(originTexture.width() * size, originTexture.height() * size);


        int originWidth = originTexture.width();
        int originHeight = originTexture.height();
        for (int x = 0; x < size; x++) {
            writeln(x);
            for (int z = 0; z < size; z++) {

                for (int i = 0; i < originWidth; i++) {
                    for (int w = 0; w < originHeight; w++) {
                        newTexture.setPixel(
                            (x * originWidth) + i,
                            (z * originHeight) + w, 
                            originTexture.getPixel(i, w)
                        );
                    }
                }

            }
        }

        writeImageToPngFile("textures/ground.png", newTexture);
        */