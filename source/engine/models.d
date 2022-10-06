module engine.models;

import raylib;
import std.stdio;
import std.string: toStringz;

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
        texture = LoadTexture(toStringz(texturePath));
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

    this(ModelContainer container, string modelPath, string texturePath) {
        Texture tempTexture = container.uploadTexture(texturePath);
        this.model = LoadModel(toStringz(modelPath));
        this.model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tempTexture;
        this.modelAnimation = LoadModelAnimations(toStringz(modelPath), &this.animationCount);
        /// Models are not automatically attached to bones, update to safe point
        if (this.animationCount > 0) {
            this.updateAnimation(0,0);
        }
    }

    ~this() {
        UnloadModelAnimation(*this.modelAnimation);
        UnloadModel(this.model);
    }
    /// Easier to handle wrapper
    void updateAnimation(int animation, int frame) {
        UpdateModelAnimation(this.model,  this.modelAnimation[animation], frame);
    }
}
