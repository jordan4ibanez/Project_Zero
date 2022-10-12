module engine.models;

import raylib;
import std.stdio;
import std.string: toStringz;

/// This is a container class for models
public class ModelContainer {
    /// Model cache
    private GameModel[string] modelCache;


    void cleanUp() {
        foreach (GameModel model; modelCache) {
            model.destroy();
        }
    }

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
}


/// This is an actual model. Wrapper around Model & ModelAnimation
public class GameModel {

    Model model;
    Texture texture;
    ModelAnimation* modelAnimation;
    uint animationCount;

    this(ModelContainer container, string modelPath, string texturePath) {
        texture = LoadTexture(toStringz(texturePath));
        this.model = LoadModel(toStringz(modelPath));
        this.model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;
        this.modelAnimation = LoadModelAnimations(toStringz(modelPath), &this.animationCount);
        /// Models are not automatically attached to bones, update to safe point
        if (this.animationCount > 0) {
            this.updateAnimation(0,0);
        }
    }

    ~this() {
        UnloadModel(this.model);
        UnloadModelAnimation(*this.modelAnimation);
        UnloadTexture(this.texture);
    }
    /// Easier to handle wrapper
    void updateAnimation(int animation, int frame) {
        UpdateModelAnimation(this.model,  this.modelAnimation[animation], frame);
    }
}
