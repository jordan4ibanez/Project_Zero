module keyboard;

import raylib;
import game;

public class Keyboard {

    private Game game;

    /// All possible assignments, for now. Soon to be a hashmap?
    private bool forward          = false;
    private bool left             = false;
    private bool back             = false;
    private bool right            = false;
    private bool jump             = false;
    private bool run              = false;
    private bool crouch           = false;
    private bool prone            = false;
    private bool activate         = false;
    private bool leanRight        = false;
    private bool leanLeft         = false;
    private bool toggleFullScreen = false;

    private int forwardAssignment          = KeyboardKey.KEY_W;
    private int leftAssignment             = KeyboardKey.KEY_A;
    private int backAssignment             = KeyboardKey.KEY_S;
    private int rightAssignment            = KeyboardKey.KEY_D;
    private int jumpAssignment             = KeyboardKey.KEY_SPACE;
    private int runAssignment              = KeyboardKey.KEY_LEFT_SHIFT;
    private int crouchAssignment           = KeyboardKey.KEY_C;
    private int proneAssignment            = KeyboardKey.KEY_X;
    private int activateAssignment         = KeyboardKey.KEY_F;
    private int leanRightAssignment        = KeyboardKey.KEY_E;
    private int leanLeftAssignment         = KeyboardKey.KEY_Q;
    private int toggleFullScreenAssignment = KeyboardKey.KEY_F11;

    this(Game game) {
        this.game = game;
    }

    void update() {
        this.forward          = IsKeyDown(this.forwardAssignment);
        this.left             = IsKeyDown(this.leftAssignment);
        this.back             = IsKeyDown(this.backAssignment);
        this.right            = IsKeyDown(this.rightAssignment);
        this.jump             = IsKeyDown(this.jumpAssignment);
        this.run              = IsKeyDown(this.runAssignment);
        this.crouch           = IsKeyDown(this.crouchAssignment);
        this.prone            = IsKeyDown(this.proneAssignment);
        this.activate         = IsKeyDown(this.activateAssignment);
        this.leanRight        = IsKeyDown(this.leanRightAssignment);
        this.leanLeft         = IsKeyDown(this.leanLeftAssignment);
        this.toggleFullScreen = IsKeyDown(this.toggleFullScreenAssignment);
    }

    bool getForward() {
        return this.forward;
    }
    
    bool getLeft() {
        return this.left;
    }
    
    bool getBack() {
        return this.back;
    }
    
    bool getRight() {
        return this.right;
    }
    
    bool getJump() {
        return this.jump;
    }
    
    bool getRun() {
        return this.run;
    }
    
    bool getCrouch() {
        return this.crouch;
    }
    
    bool getProne() {
        return this.prone;
    }
    
    bool getActivate() {
        return this.activate;
    }
    
    bool getLeanRight() {
        return this.leanRight;
    }
    
    bool getLeanLeft() {
        return this.leanLeft;
    }

    bool getToggleFullScreen() {
        return this.toggleFullScreen;
    }
}