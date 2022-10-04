module engine.window;

import raylib;
import std.string: toStringz;
import std.stdio;
import std.conv: to;

import game;

/// Wrapper object for Raylib window
public class Window {

    private Game game;

    private int width = 0;
    private int height = 0;

    private string title = "D Raylib Zombie Game 0.0.0";

    private bool fullScreen = false;

    private bool updateWithFPS = true;

    this(Game game, int width, int height/*, int targetFPS*/) {

        this.game = game;
        
        this.width = width;
        this.height = height;

        SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);

        InitWindow(this.width,this.height, this.convertTitle());

        // SetTargetFPS(targetFPS);
    }

    ~this() {
        CloseWindow();
    }

    void toggleFullScreen() {
        if (fullScreen) {
            ToggleFullscreen();
            SetWindowSize(this.width, this.height);
        } else {
            int currentMonitor = GetCurrentMonitor();
            SetWindowSize(GetMonitorWidth(currentMonitor),GetMonitorHeight(currentMonitor));
            ToggleFullscreen();
        }
        fullScreen = !fullScreen;
    }

    void update() {
        if (!fullScreen) {
            if (IsWindowResized()) {
                this.width = GetRenderWidth();
                this.height = GetRenderHeight();

                writeln("Window was resized to: ", this.width, ", ", this.height);
            }

            if (updateWithFPS) {
                SetWindowTitle(this.convertTitleWithFPS());
            }
        }

    }

    bool shouldClose() {
        return WindowShouldClose();
    }

    private const(char)* convertTitleWithFPS(){
        return toStringz(this.title ~ " | FPS: " ~ to!string(GetFPS()));
    }


    private const(char)* convertTitle(){
        return toStringz(this.title);
    }
}