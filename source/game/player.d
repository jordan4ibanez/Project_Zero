module game.player;

import raylib;
import std.stdio;

import engine.world;
import engine.keyboard;
import engine.camera;
import engine.models;
import engine.mouse;

import game.game;

/*

Every frame besides the head pitch is 1-60

head:
90 is the 0 so subtract by 90 or something
0 to 180 : pitch

0 - stand pitch

Play this animation in reverse when standing back up
1 - stand to crouch animation

2 - crouch pitch

torso:
0  - stand idle animation
1  - walk
2  - run

Hold the last frame (60) when complete
3  - aiming

4  - cycle-gun
5  - toggle-safety

Play this in reverse when a player isn't holding right click anymore
6  - into-fighting
7  - punch

Loop frames 15-45 for continued animation
8  - craft

Loop frames 15-45 for continued animation
9  - eat

Play this animation in reverse when standing back up
10 - stand-to-crouch

11 - crouch idle animation
12 - crouch-walk

Hold the last frame (60) when complete
13 - crouch-aiming

14 - crouch-cycle-gun
15 - crouch-toggle-safety

Play this in reverse when a player isn't holding right click anymore
16 - crouch-into-fighting
17 - crouch-punch

Loop frames 15-45 for continued animation
18 - crouch-craft

Loop frames 15-45 for continued animation
19 - crouch-eat


legs:
Lock this to frame 1 so it doesn't do anything, animation looks strange
0 - stand idle animation

1 - walk
2 - run

Play this animation in reverse when standing back up
3 - stand-to-crouch

4 - crouch-walk

*/

public class Animation {
    immutable int key;
    immutable int start;
    immutable int end;
    immutable bool loops;
    immutable int loopStart;
    immutable int loopEnd;
    immutable float frameSpeed;

    this(int start, int end, float frameSpeed, int keyCounter, bool loops) {
        this.key       = keyCounter;
        this.start     = start;
        this.end       = end;
        this.loops     = loops;
        this.loopStart = start;
        this.loopEnd   = end;
        this.frameSpeed = 1.0 / frameSpeed;
    }

    /// Animation that loops inside the start and end
    this(int start, int end, int loopStart, int loopEnd, float frameSpeed, int keyCounter) {
        this.key       = keyCounter;
        this.start     = start;
        this.end       = end;
        this.loops     = true;
        this.loopStart = loopStart;
        this.loopEnd   = loopEnd;
        this.frameSpeed = 1.0 / frameSpeed;
    }
}

public class AnimationContainer {
    private int keyCounter = 0;
    private Animation[string] animations;
    
    void addAnimation(string name, int start, int end, int loopStart, int loopEnd, float frameSpeed) {
        if (name !in animations) {
            animations[name] = new Animation(start, end, loopStart, loopEnd, frameSpeed, keyCounter);
            keyCounter++;
        } else {
            throw new Exception(name ~ " is a duplicate in animations!");
        }
    }
    void addAnimation(string name, int start, int end, float frameSpeed, bool loops) {
        if (name !in animations) {
            animations[name] = new Animation(start, end, frameSpeed, keyCounter, loops);
            keyCounter++;
        } else {
            throw new Exception(name ~ " is a duplicate in animations!");
        }
    }

    // Get an animation pointer
    Animation getAnimation(string name) {
        if (name in animations) {
            return animations[name];
        }
        throw new Exception("Tried to get null animation! " ~ name ~ " is not a registered animation!");
    }
}

public class Player {

    private Game game;

    private Entity entity;

    private GameModel head;
    private GameModel torso;
    private GameModel legs;

    private immutable float eyeHeightStand = 1.45;
    private immutable float modelYAdjust = 0.06;

    private immutable float physicsEngineDelta;
    private immutable Vector3 movementSpeed;

    private bool wasOnGround = false;

    private bool crouched;
    private bool walk;
    private bool run;
    private bool cyclingGun;
    private bool togglingSafety;
    private bool fighting;
    private bool punching;
    private bool crafting;
    private bool eating;

    private bool wasCrouched;
    private bool wasWalk;
    private bool wasRun;
    private bool wasCyclingGun;
    private bool wasTogglingSafety;
    private bool wasFighting;
    private bool wasPunching;
    private bool wasCrafting;
    private bool wasEating;

    private bool playReversed;
    private bool lockedInAnimation;

    //______________________________________
    /// Animation fields, too much data     |
    //______________________________________|
    private int   headAnimation    = 0;   //|
    private int   headFrame        = 0;   //|
    private float headAccumulator  = 0.0; //|
    private float headFrameSpeed   = 0.0; //|
    private Animation currentHeadAnimation = null;
    private static AnimationContainer headAnimations;
    //--------------------------------------|
    private int torsoAnimation     = 0;  // |
    private int torsoFrame         = 0;  // |
    private float torsoAccumulator = 0.0;// |
    private float torsoFrameSpeed  = 0.0;// |
    private Animation currentTorsoAnimation = null;
    private static AnimationContainer torsoAnimations;
    //--------------------------------------|
    private int legsAnimation      = 0;  // |
    private int legsFrame          = 0;  // |
    private float legsAccumulator  = 0.0;// |
    private float legsFrameSpeed   = 0.0;// |
    private Animation currentLegsAnimation = null;
    private static AnimationContainer legsAnimations;
    //--------------------------------------|

    this(Game game, Vector3 position, GameModel head, GameModel torso, GameModel legs) {
        this.game = game;

        this.entity = new Entity(position, Vector2(0.51,1.8),Vector3(0,0,0), true);

        game.world.addEntity(this.entity);

        this.physicsEngineDelta = game.world.getLockedTick();
        this.movementSpeed = Vector3(
            this.physicsEngineDelta / 4.0,
            this.physicsEngineDelta / 4.0,
            this.physicsEngineDelta / 4.0
        );

        this.head  = head;
        this.torso = torso;
        this.legs  = legs;

        headAnimations  = new AnimationContainer();
        torsoAnimations = new AnimationContainer();
        legsAnimations  = new AnimationContainer();

        // Animations use a "-" to designate you're calling an animation
        // Longer ones have inner loop frames

        // Head animations
        headAnimations.addAnimation("stand-pitch",     1, 180, 0.0,  false);
        headAnimations.addAnimation("stand-to-crouch", 1, 60,  60.0, false);
        headAnimations.addAnimation("crouch-pitch",    1, 180, 0.0 , false);

        // Torso animations
        torsoAnimations.addAnimation("stand",                1, 60, 60.0, true);
        torsoAnimations.addAnimation("walk",                 1, 60, 60.0, true);
        torsoAnimations.addAnimation("run",                  1, 60, 60.0, true);
        torsoAnimations.addAnimation("aiming",               1, 60, 60.0, false);
        torsoAnimations.addAnimation("cycle-gun",            1, 60, 60.0, false);
        torsoAnimations.addAnimation("toggle-safety",        1, 60, 60.0, false);
        torsoAnimations.addAnimation("into-fighting",        1, 60, 60.0, false);
        torsoAnimations.addAnimation("punch",                1, 60, 60.0, false);
        torsoAnimations.addAnimation("craft",                1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("eat",                  1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("stand-to-crouch",      1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch",               1, 60, 60.0, true);
        torsoAnimations.addAnimation("crouch-walk",          1, 60, 60.0, true);
        torsoAnimations.addAnimation("crouch-aim",           1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-cycle-gun",     1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-toggle-safety", 1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-into-fighting", 1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-punch",         1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-craft",         1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("crouch-eat",           1, 60, 15, 45, 60.0);
        currentTorsoAnimation = torsoAnimations.getAnimation("stand");

        // Legs animations
        legsAnimations.addAnimation("stand",           1, 60, 60.0, true);
        legsAnimations.addAnimation("walk",            1, 60, 60.0, true);
        legsAnimations.addAnimation("run",             1, 60, 60.0, true);
        legsAnimations.addAnimation("stand-to-crouch", 1, 60, 60.0, false);
        legsAnimations.addAnimation("crouch-walk",     1, 60, 60.0, true);
        currentLegsAnimation = legsAnimations.getAnimation("stand");

    }

    void update() {
        this.intakeControls();
        this.animate();
    }

    void intakeControls() {

        wasCrouched       = crouched;
        wasWalk           = walk;
        wasRun            = run;
        wasCyclingGun     = cyclingGun;
        wasTogglingSafety = togglingSafety;
        wasFighting       = fighting;
        wasPunching       = punching;
        wasCrafting       = crafting;
        wasEating         = eating;

        Keyboard keyboard = game.keyboard;
        Mouse mouse = game.mouse;

        if (mouse.getRightClick()) {
            fighting = true;
        }


        // Physics engine stuff is locked out until update

        if (!game.world.didTick()) {
            return;
        }
        // Don't allow player to control in mid air
        if (!this.entity.wasOnTheGround()) {
            return;
        }
        // We're talking to the next engine steps here so it gets kinda weird
        this.entity.appliedForce = false;

        
        GameCamera camera3d = game.camera3d;

        bool changed = false;

        Vector3 addingVelocity = Vector3(0,0,0);

        if (keyboard.getForward()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getBack()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getRight()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getLeft()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getJump()) {
            changed = true;
            addingVelocity = Vector3Add(addingVelocity, Vector3(0,0.25,0));
            writeln("jumped");
        } else if (keyboard.getRun()) {
            // Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            // velocity = Vector3Add(velocity, direction);
        }

        if (changed) {
            this.entity.addVelocity(addingVelocity);
            this.entity.appliedForce = true;
            walk = true;
        } else {
            walk = false;
        }
    }

    private void setHeadAnimation(string name) {
        currentHeadAnimation = headAnimations.getAnimation(name);
        headFrame = 0;
    }
    private void setTorsoAnimation(string name) {
        currentTorsoAnimation = torsoAnimations.getAnimation(name);
        torsoFrame = 0;
    }
    private void setLegsAnimation(string name) {
        currentLegsAnimation = legsAnimations.getAnimation(name);
        legsFrame = 0;
    }

    /// This is going to be ridig, and complicated, unfortunately
    private void animate() {
        immutable float delta = game.timeKeeper.getDelta();

        /// handle legs
        if (run) {
            if (walk && !wasWalk) {
                setLegsAnimation("run");
            } else if (!walk && wasWalk) {
                setLegsAnimation("stand");
            }
        } else {
            if (walk && !wasWalk) {
                setLegsAnimation("walk");
            } else if (!walk && wasWalk) {
                setLegsAnimation("stand");
            }
        }

        legsAccumulator += delta;
        if (legsAccumulator > currentLegsAnimation.frameSpeed) {
            legsFrame++;
            if (legsFrame >= currentLegsAnimation.end) {
                legsFrame = currentLegsAnimation.start;
            }
            legsAccumulator -= currentLegsAnimation.frameSpeed;
            legs.updateAnimation(currentLegsAnimation.key, legsFrame);
        }

    }

    Vector3 getPosition() {
        return this.entity.getCollisionBoxPosition();
    }

    Vector3 getModelPosition() {
        Vector3 modelPosition = this.entity.getCollisionBoxPosition();
        modelPosition.y += modelYAdjust;
        return modelPosition;
    }

    float getEyeHeightStand() {
        return this.eyeHeightStand;
    }

    void render() {
        float yaw = (game.camera3d.getLookRotation().y * -RAD2DEG) - 90.0;

        /*
        DrawModelEx(
            head.model,     // Model
            getModelPosition(),// Position  
            Vector3(0,1,0), // Rotation Axis
            yaw,          // Rotation angle
            Vector3(1,1,1), // Scale
            Colors.WHITE    // Tint
        );
        */

        DrawModelEx(
            torso.model,     // Model
            getModelPosition(),// Position  
            Vector3(0,1,0), // Rotation Axis
            yaw,          // Rotation angle
            Vector3(1,1,1), // Scale
            Colors.WHITE    // Tint
        );

        DrawModelEx(
            legs.model,     // Model
            getModelPosition(),// Position  
            Vector3(0,1,0), // Rotation Axis
            yaw,          // Rotation angle
            Vector3(1,1,1), // Scale
            Colors.WHITE    // Tint
        );
    }
}