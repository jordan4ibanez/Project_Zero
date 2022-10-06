module engine.models;

import raylib;
import std.stdio;

/// This is a container class for models
public class ModelContainer {
    /// Texture cache
    private GameTexture[string] textureCache;
    /// Model cache
    private GameModel[string] modelCache;


    void uploadModel(string name, string texturePath, string modelPath) {
        modelCache[name] = new GameModel(this, texturePath, modelPath);
    }

    GameModel getModel(string name) {
        if (name in modelCache) {
            return this.modelCache[name];
        } else {
            throw new Exception("Tried to get a nonexistent model! " ~ name ~ " is not an uploaded model!");
        }
    }

    private Texture uploadTexture(string texturePath) {
        if (texturePath in this.textureCache) {
            return this.textureCache[texturePath].texture;
        } else {
            GameTexture tempTexture = new GameTexture(texturePath);
            this.textureCache[texturePath] = tempTexture;
            return tempTexture.texture;
        }
    }
}

/// Wrapper around Texture
public class GameTexture {
    Texture texture;
    this(string texturePath) {
        texture = LoadTexture(texturePath.ptr);
    }
    ~this() {
        UnloadTexture(texture);
    }
}


/// This is an actual model. Wrapper around Model & ModelAnimation
public class GameModel {

    Model model;
    ModelAnimation* modelAnimation;
    uint animationCount;

    this(ModelContainer container, string texturePath, string modelPath) {
        Texture tempTexture = container.uploadTexture(texturePath);
        this.model = LoadModel(modelPath.ptr);
        this.model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tempTexture;
        this.modelAnimation = LoadModelAnimations(modelPath.ptr, &this.animationCount);
    }

    ~this() {
        UnloadModelAnimation(*this.modelAnimation);
        UnloadModel(this.model);
    }
}
