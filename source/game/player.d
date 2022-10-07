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
        this.start     = start - 1;
        this.end       = end - 1;
        this.loops     = loops;
        this.loopStart = start - 1;
        this.loopEnd   = end - 1;
        this.frameSpeed = 1.0 / frameSpeed;
    }

    /// Animation that loops inside the start and end
    this(int start, int end, int loopStart, int loopEnd, float frameSpeed, int keyCounter) {
        this.key       = keyCounter;
        this.start     = start - 1;
        this.end       = end - 1;
        this.loops     = true;
        this.loopStart = loopStart - 1;
        this.loopEnd   = loopEnd - 1;
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

    private immutable float eyeHeightStand = 1.35;
    private immutable float eyeHeightCrouch = 0.65;
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

    

    private bool headLockedInAnimation;
    private bool headWasLockedInAnimation;
    private bool playHeadReversed;

    private bool torsoLockedInAnimation;
    private bool torsoWasLockedInAnimation;
    private bool playTorsoReversed;

    private bool legsLockedInAnimation;
    private bool legsWasLockedInAnimation;
    private bool playLegsReversed;

    //______________________________________
    /// Animation fields, too much data     |
    //______________________________________|
    private int   headAnimation    = 0;   //|
    private int   headFrame        = 0;   //|
    private float headAccumulator  = 0.0; //|
    private float headFrameSpeed   = 0.0; //|
    private Animation currentHeadAnimation = null;
    private static AnimationContainer headAnimations;
    private string currentHeadAnimationName;
    //--------------------------------------|
    private int torsoAnimation     = 0;  // |
    private int torsoFrame         = 0;  // |
    private float torsoAccumulator = 0.0;// |
    private float torsoFrameSpeed  = 0.0;// |
    private Animation currentTorsoAnimation = null;
    private static AnimationContainer torsoAnimations;
    private string currentTorsoAnimationName;
    //--------------------------------------|
    private int legsAnimation      = 0;  // |
    private int legsFrame          = 0;  // |
    private float legsAccumulator  = 0.0;// |
    private float legsFrameSpeed   = 0.0;// |
    private Animation currentLegsAnimation = null;
    private static AnimationContainer legsAnimations;
    private string currentLegsAnimationName;
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

        float punchSpeed = 160.0;

        // Head animations
        headAnimations.addAnimation("stand-pitch",     1, 180, 0.0,  false);
        headAnimations.addAnimation("stand-to-crouch", 1, 60,  120.0, false);
        headAnimations.addAnimation("crouch-pitch",    1, 180, 0.0 , false);

        // Torso animations
        torsoAnimations.addAnimation("stand",                1, 60, 60.0, true);
        torsoAnimations.addAnimation("walk",                 1, 60, 60.0, true);
        torsoAnimations.addAnimation("run",                  1, 60, 60.0, true);
        torsoAnimations.addAnimation("aiming",               1, 60, 60.0, false);
        torsoAnimations.addAnimation("cycle-gun",            1, 60, 60.0, false);
        torsoAnimations.addAnimation("toggle-safety",        1, 60, 60.0, false);
        torsoAnimations.addAnimation("into-fighting",        1, 60, punchSpeed, false);
        torsoAnimations.addAnimation("punch",                1, 60, punchSpeed, false);
        torsoAnimations.addAnimation("craft",                1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("eat",                  1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("stand-to-crouch",      1, 60, 120.0, false);

        torsoAnimations.addAnimation("crouch",               1, 60, 60.0, true);
        torsoAnimations.addAnimation("crouch-walk",          1, 60, 60.0, true);
        torsoAnimations.addAnimation("crouch-aim",           1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-cycle-gun",     1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-toggle-safety", 1, 60, 60.0, false);
        torsoAnimations.addAnimation("crouch-into-fighting", 1, 60, punchSpeed, false);
        torsoAnimations.addAnimation("crouch-punch",         1, 60, punchSpeed, false);
        torsoAnimations.addAnimation("crouch-craft",         1, 60, 15, 45, 60.0);
        torsoAnimations.addAnimation("crouch-eat",           1, 60, 15, 45, 60.0);
        currentTorsoAnimation = torsoAnimations.getAnimation("stand");

        // Legs animations
        legsAnimations.addAnimation("stand",           1, 60, 60.0, true);
        legsAnimations.addAnimation("walk",            1, 60, 60.0, true);
        legsAnimations.addAnimation("run",             1, 60, 60.0, true);
        legsAnimations.addAnimation("stand-to-crouch", 1, 60, 120.0, false);
        legsAnimations.addAnimation("crouch",          1, 60, 60.0, false);
        legsAnimations.addAnimation("crouch-walk",     1, 60, 30.0, true);
        currentLegsAnimation = legsAnimations.getAnimation("stand");

    }

    void update() {
        this.intakeControls();
        this.animate();
    }

    void resetAllFlags() {
        walk = false;
        run = false;
        cyclingGun = false;
        togglingSafety = false;
        fighting = false;
        punching = false;
        crafting = false;
        eating = false;
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

        if (legsLockedInAnimation){
            this.entity.appliedForce = false;
            resetAllFlags();
            return;            
        }

        Keyboard keyboard = game.keyboard;

        if (keyboard.getCrouch()) {
            this.entity.appliedForce = false;
            crouched = !crouched;
            resetAllFlags();
            return;
        }

        Mouse mouse = game.mouse;

        if (!torsoLockedInAnimation) {
            if (mouse.getRightClick()) {
                fighting = !fighting;
            } else {
                punching = fighting && mouse.getLeftClick();
            }
        }

        run = keyboard.getRun();


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

        if (run && !crouched) {
            entity.maxSpeed = 0.04;
        } else if (crouched) {
            entity.maxSpeed = 0.01;
        } else {
            entity.maxSpeed = 0.02;
        }
        GameCamera camera3d = game.camera3d;

        bool changed = false;

        Vector3 addingVelocity = Vector3(0,0,0);

        if (keyboard.getForward()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        } else if (keyboard.getBack()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getRight()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        } else if (keyboard.getLeft()) {
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

    private void setHeadAnimation(string name, bool reversed, bool ignore) {
        if (!ignore && currentHeadAnimationName == name) {
            return;
        }
        currentHeadAnimation = headAnimations.getAnimation(name);
        if (reversed) {
            headFrame = currentHeadAnimation.end;
        } else {
            headFrame = currentHeadAnimation.start;
        }
        playHeadReversed = reversed;
        headAccumulator = 0.0;

        currentHeadAnimationName = name;
    }
    private void setTorsoAnimation(string name, bool reversed, bool ignore) {
        if (!ignore && currentTorsoAnimationName == name) {
            return;
        }
        currentTorsoAnimation = torsoAnimations.getAnimation(name);
        if (reversed) {
            torsoFrame = currentTorsoAnimation.end;
        } else {
            torsoFrame = currentTorsoAnimation.start;
        }
        playTorsoReversed = reversed;
        torsoAccumulator = 0.0;

        currentTorsoAnimationName = name;
    }
    private void setLegsAnimation(string name, bool reversed, bool ignore) {
        if (!ignore && currentLegsAnimationName == name) {
            return;
        }
        currentLegsAnimation = legsAnimations.getAnimation(name);
        if (reversed) {
            legsFrame = currentLegsAnimation.end;
        } else {
            legsFrame = currentLegsAnimation.start;
        }
        playLegsReversed = reversed;
        legsAccumulator = 0.0;

        currentLegsAnimationName = name;
    }

    /// This is going to be rigid, and complicated, unfortunately
    private void animate() {
        if (!legsLockedInAnimation) {

            if (crouched) {

                if (!wasCrouched) {
                    setLegsAnimation("stand-to-crouch", false, true);
                    legsLockedInAnimation = true;
                } else if (walk) {
                    setLegsAnimation("crouch-walk", false, false);
                }

            } else if (!crouched) {
                if (wasCrouched) {
                    setLegsAnimation("stand-to-crouch", true, true);
                    legsLockedInAnimation = true;
                } else if (!walk && !run) {
                    setLegsAnimation("stand", false, false);
                } else if (walk && !run) {
                    setLegsAnimation("walk", false, false);
                } else if (walk && run) {
                    setLegsAnimation("run", false, false);
                }

            }
        }


        
        /*
        if (!legsLockedInAnimation) {

            /// handle legs

            if (crouched) {
                // stand to crouch
                if (!wasCrouched) {
                    setLegsAnimation("stand-to-crouch", false);
                    legsLockedInAnimation = true;
                } else if (walk && !wasWalk) {
                    setLegsAnimation("crouch-walk", false);
                } else if (!walk && wasWalk) {
                    setLegsAnimation("crouch", false);
                }
            // crouched to stand 
            } else if (wasCrouched) {
                setLegsAnimation("stand-to-crouch", true);
                legsLockedInAnimation = true;
            } else {
                // standing
                if (legsWasLockedInAnimation) {
                    setLegsAnimation("stand", false);
                }
                
                if (run) {
                    if (run && !wasRun) {
                        setLegsAnimation("run", false);
                    } else if (!run && wasRun) {
                        setLegsAnimation("stand", false);
                    }
                } else {
                    if (walk && !wasWalk) {
                        setLegsAnimation("walk", false);
                    } else if (!walk && wasWalk) {
                        setLegsAnimation("stand", false);
                    }
                }
            }
        }        

        if (!torsoLockedInAnimation) {
            // handle torso

            if (crouched) {
                // stand to crouch
                if (!wasCrouched) {
                    setTorsoAnimation("stand-to-crouch", false);
                    torsoLockedInAnimation = true;
                } else if (fighting) {
                    if (!wasFighting) {
                        setTorsoAnimation("crouch-into-fighting", false);
                        torsoLockedInAnimation = true;
                    } else if (punching && !wasPunching) {
                        setTorsoAnimation("crouch-punch", false);
                        torsoLockedInAnimation = true;
                    }
                } else if (!fighting && wasFighting) {
                    setTorsoAnimation("crouch-into-fighting", true);
                    torsoLockedInAnimation = true;
                } else if (walk && !wasWalk) {
                    setTorsoAnimation("crouch-walk", false);
                } else if (!walk && wasWalk) {
                    setTorsoAnimation("crouch", false);
                }
            // crouched to stand 
            } else if (wasCrouched) {
                setTorsoAnimation("stand-to-crouch", true);
                torsoLockedInAnimation = true;
            } else {
                // standing
                if (torsoWasLockedInAnimation && !fighting) {
                    if (walk) {
                        setTorsoAnimation("stand", false);
                    }
                }
                if (fighting) {
                    if (!wasFighting) {
                        setTorsoAnimation("into-fighting", false);
                        torsoLockedInAnimation = true;
                    } else if (punching && !wasPunching) {
                        setTorsoAnimation("punch", false);
                        torsoLockedInAnimation = true;
                    }
                } else if (!fighting && wasFighting) {
                    setTorsoAnimation("into-fighting", true);
                    torsoLockedInAnimation = true;
                } else {
                    if (run) {
                        if (run && !wasRun) {
                            setTorsoAnimation("run", false);
                        } else if (!run && wasRun) {
                            setTorsoAnimation("stand", false);
                        }
                    } else {
                        if (walk && !wasWalk) {
                            setTorsoAnimation("walk", false);
                        } else if (!walk && wasWalk) {
                            setTorsoAnimation("stand", false);
                        }
                    }
                }
            }
        }
        */

        headWasLockedInAnimation  = headLockedInAnimation;
        torsoWasLockedInAnimation = torsoLockedInAnimation;
        legsWasLockedInAnimation  = legsLockedInAnimation;

        immutable float delta = game.timeKeeper.getDelta();

        processAnimation(currentTorsoAnimation, torsoFrame, torsoAccumulator, torso, delta, torsoLockedInAnimation, playTorsoReversed);
        processAnimation(currentLegsAnimation, legsFrame, legsAccumulator, legs, delta, legsLockedInAnimation, playLegsReversed);
        
    }

    void processAnimation(Animation currentAnimation, ref int frame, ref float accumulator, GameModel model, immutable float delta, ref bool animationLock, bool playReversed) {

        if (currentAnimation.loops ||
            (!currentAnimation.loops && frame < currentAnimation.end) ||
            (playReversed && !currentAnimation.loops && frame > currentAnimation.start)) {
            accumulator += delta;
        }

        if (accumulator > currentAnimation.frameSpeed) {
            if (playReversed) {
                if (frame > 0) {
                    frame--;
                }
                if (frame <= currentAnimation.start) {
                    if (currentAnimation.loops) {
                        frame = currentAnimation.end;
                    } else if (animationLock) {
                        animationLock = false;
                    }
                }
            } else {
                frame++;
                if (frame >= currentAnimation.end) {
                    if (currentAnimation.loops) {
                        frame = currentAnimation.start;
                    } else if (animationLock) {
                        animationLock = false;
                    }
                }
            }
            accumulator -= currentAnimation.frameSpeed;
            model.updateAnimation(currentAnimation.key, frame);
        }
    }

    bool isCrouching() {
        return this.crouched;
    }

    int getCrouchFrame() {
        return legsFrame;
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

    float getEyeHeightCrouch() {
        return this.eyeHeightCrouch;
    }

    void render() {
        float yaw = (game.camera3d.getLookRotation().y * -RAD2DEG) - 90.0;

        /*
        setHeadAnimation("crouch-pitch", true);
        UpdateModelAnimation(head.model, head.modelAnimation[2], 90);
        
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