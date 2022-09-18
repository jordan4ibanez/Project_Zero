module lua;

import bindbc.lua;
import std.stdio;

void load_lua() {

    LuaSupport returnedVersion;

    version(Windows) {
        returnedVersion = loadLua("lib/lua54.dll");
    } else {
        // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
        returnedVersion = loadLua();
    }

    // Yeah this is literally just taken from the readme
    if(returnedVersion != luaSupport) {
        // Handle error. For most use cases, its reasonable to use the the error handling API in
        // bindbc-loader to retrieve error messages for logging and then abort. If necessary, it's
        // possible to determine the root cause via the return value:

        if(returnedVersion == luaSupport.noLibrary) {
            writeln("Lua shared library failed to load!");
        } else if(luaSupport.badLibrary) {
            writeln("One or more symbols failed to load. The likely cause is that the",
            "shared library is a version different from the one the app was",
            "configured to load");
        }
    }
}