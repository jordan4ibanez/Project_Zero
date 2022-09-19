module open_al;


import bindbc.openal;
import std.stdio;
import stb_vorbis;
import std.conv: to;
import raylib;
import std.uuid;

/**
 *This is utilizing OpenAL Soft for maximum compatibility.
 */

public class SoundEngine {

    /// Is the actual OpenAL existence
    private void* context;
    private void* device;
    private string deviceName;
    private bool debugging = false;

    /// Holds the cache of loaded sounds
    private VorbisCache[string] soundCache;

    /// Holds all variable data, positions, etc
    SoundListener listener;
    private SoundBuffer[UUID] buffers;
    private SoundSource[UUID] sources;


    this() {
        
        ALSupport returnedError;
        
        version(Windows) {
            returnedError = loadOpenAL("libs/soft_oal.dll");
        } else {
            // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
            returnedError = loadOpenAL();
        }

        if(returnedError != ALSupport.al11) {

            if(returnedError == ALSupport.noLibrary) {
                // GLFW shared library failed to load
                throw new Exception("FAILED TO LOAD OPENAL! LIBRARY IS NOT INSTALLED!");
            }
            else if(returnedError == ALSupport.badLibrary) {
                // One or more symbols failed to load.
                throw new Exception("BAD OPENAL LIBRARY INSTALLED! DO YOU HAVE OPENAL 1.1+?");
            }
        }

        device = alcOpenDevice(cast(const(char)*)null);

        deviceName = to!string(alcGetString(device, ALC_DEVICE_SPECIFIER));

        // Blank devices aren't allowed, this is a software api
        if (deviceName == null) {
            throw new Exception("OPENAL NULL DEVICE!");
        }

        writeln("the AL device pointer: ", device);
        writeln("the AL device name: ", deviceName);
    

        ALCint[] attributes = [
            ALC_MAJOR_VERSION, 1,
            ALC_MINOR_VERSION, 1,
            0,                 0
        ];

        // Attempt to get a context
        if (device != null) {
            context = alcCreateContext(device,attributes.ptr);
        } else {
            // Something went horribly wrong
            throw new Exception("Null OpenAL device!");
        }

        alcMakeContextCurrent(context);

        // Generate buffers
        alGetError();

        this.debugOpenAL();

        this.listener = new SoundListener(Vector3(0,0,0));

        writeln("OpenAL initialized successfully!");
    }

    ~this() {

        this.cleanUpAll();

        alcMakeContextCurrent(null);
        alcDestroyContext(context);
        alcCloseDevice(device);

        writeln("OpenAL has successfully closed");
    }

    void enableDebugging() {
        this.debugging = true;
    }

    void playSound(string fileName) {

        UUID uuid = randomUUID();

        SoundBuffer thisBuffer = new SoundBuffer(this, fileName);
        SoundSource thisSource = new SoundSource(this, false, false);

        thisSource.setBuffer(thisBuffer.getID());
        thisSource.play();

        this.buffers[uuid] = thisBuffer;
        this.sources[uuid] = thisSource;

    }




    /// Begin the OpenAL internal handling

    private void cleanSoundsNotPlaying() {
        UUID[] cleanQueue;
        foreach (pair; this.sources.byKeyValue()) {
            UUID key = pair.key;
            SoundSource value = pair.value;
            if (!value.isPlaying()) {
                cleanQueue ~= key;
            }
        }
        foreach (UUID key; cleanQueue) {
            this.sources[key].cleanUp(this);
            this.buffers[key].cleanUp(this);
            this.sources.remove(key);
            this.buffers.remove(key);
        }
    }

    private void cleanUpAll() {
        UUID[] cleanQueue = this.sources.keys;
        foreach (UUID key; cleanQueue) {
            this.sources[key].cleanUp(this);
            this.buffers[key].cleanUp(this);
            this.sources.remove(key);
            this.buffers.remove(key);            
        }
    }

    private bool isDebugging() {
        return this.debugging;
    }

    private bool containsVorbisCache(string fileName) {
        return (fileName in this.soundCache) !is null;
    }

    private void cacheVorbis(VorbisCache newCache, string fileName) {
        this.soundCache[fileName] = newCache;
    }

    private class VorbisCache {
        short[] pcm;
        int pcmLength = 0;
        ubyte channels = 0;
        int sampleRate = 0;
        this(
            short[] pcm,
            int pcmLength,
            ubyte channels,
            int sampleRate
        ) {
            this.pcm = pcm;
            this.pcmLength = pcmLength;
            this.channels = channels;
            this.sampleRate = sampleRate;
        }
    }

    private class SoundBuffer {

        private ALuint id = 0;

        ALuint getID() {
            return this.id;
        }

        this(SoundEngine engine, string fileName) {

            // Hold this data in an associative array
            // After the first call, the game can pull data out of it instead of from disk

            // Can load out of RAM
            if (engine.containsVorbisCache(fileName)) {
                VorbisCache cacheSound = soundCache[fileName];
                // Get a buffer ID
                alGenBuffers(1, &this.id);
                alBufferData(
                    this.id,
                    cacheSound.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16,
                    cast(const(void)*)cacheSound.pcm,
                    cacheSound.pcmLength,
                    cacheSound.sampleRate
                );
                if (engine.isDebugging()) {
                    writeln("Loaded ", fileName, " from cache!");
                }

            } else { // Load from disk and cache for next use
                VorbisDecoder vorbisHandler = VorbisDecoder(fileName);
                int streamLength = vorbisHandler.streamLengthInSamples();
                short[] pcm = new short[streamLength];
                int pcmLength = cast(int)(pcm.length * short.sizeof);
                ubyte channels = vorbisHandler.chans();
                int sampleRate = vorbisHandler.sampleRate();

                vorbisHandler.getSamplesShortInterleaved(channels, pcm.ptr, streamLength);
                // Get a buffer ID
                alGenBuffers(1, &this.id);
                alBufferData(
                    this.id,
                    channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16,
                    cast(const(void)*)pcm,
                    pcmLength,
                    sampleRate
                );
                // Make sure nothing dumb is happening
                // debugOpenAL();

                if (engine.isDebugging()) {
                    writeln("caching ", fileName, "!");
                }

                engine.cacheVorbis(new VorbisCache(pcm,pcmLength,channels,sampleRate), fileName);
            }
            
            if (engine.isDebugging()) {
                writeln("My sound buffer ID is: ", this.id);
            }
        }


        void cleanUp(SoundEngine engine) {
            alDeleteBuffers(1, &this.id);
            if (engine.isDebugging()) {
                writeln("cleaned up albuffer ", this.id);
            }
        }
    }

    private class SoundSource {
        private ALuint id = 0;
        private ALuint buffer = 0;

        this(SoundEngine engine, bool loop, bool relative) {
            alGenSources(1, &this.id);
            alSourcei(this.id,AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
            alSourcei(this.id, AL_SOURCE_RELATIVE, relative ? AL_TRUE : AL_FALSE);
            if (engine.isDebugging()) {
                writeln("My sound source ID is: ", this.id);
            }
        }

        void cleanUp(SoundEngine engine) {
            alDeleteSources(1, &this.id);       
            if (engine.isDebugging()) {
                writeln("cleaned up sound source: ", this.id);
            }
        }

        ALuint getID() {
            return this.id;
        }

        bool isPlaying() {
            ALint value;
            alGetSourcei(this.id, AL_SOURCE_STATE, &value);
            return value == AL_PLAYING;
        }

        void pause() {
            alSourcePause(this.id);
        }

        void play() {
            alSourcePlay(this.id);
        }

        void setBuffer(ALuint bufferID) {
            stop();
            alSourcei(this.id, AL_BUFFER, bufferID);
            this.buffer = bufferID;
        }

        ALuint getBuffer() {
            return this.buffer;
        }

        void setPosition(Vector3 newPosition) {
            alSource3f(
                this.id,
                AL_POSITION,
                newPosition.x,
                newPosition.y,
                newPosition.z
            );
        }

        void setPitch(float pitch) {
            alSourcef(this.id, AL_PITCH, pitch);
        }

        void stop() {
            alSourceStop(this.id);
        }
    }

    // There can only be one listener or else weird things will happen
    private class SoundListener {
        this(Vector3 position) {
            alListener3f(AL_POSITION, position.x, position.y, position.z);
            alListener3f(AL_VELOCITY,0.0,0.0,0.0);
        }

        void setSpeed(Vector3 speed){
            alListener3f(AL_VELOCITY, speed.x, speed.y, speed.z);
        }

        void setPosition(Vector3 newPosition){
            alListener3f(AL_POSITION, newPosition.x, newPosition.y, newPosition.z);
        }

        void setOrientation(Vector3 at, Vector3 up) {
            float[6] data = [
                at.x,
                at.y,
                at.z,
                up.x,
                up.y,
                up.z
            ];
            alListenerfv(AL_ORIENTATION, data.ptr);
        }
    }

    private void debugOpenAL() {
        int error = alGetError();

        if (!error == AL_NO_ERROR) {

            writeln("OpenAL error! Error number: ", error);

            switch (error) {
                case ALC_INVALID_DEVICE: {
                    throw new Exception("AL_INVALID_DEVICE");
                }
                case ALC_INVALID_CONTEXT: {
                    throw new Exception("AL_INVALID_CONTEXT");
                }
                case AL_INVALID_VALUE:{
                    throw new Exception("AL_INVALID_VALUE");
                }
                case AL_OUT_OF_MEMORY: {
                    throw new Exception("AL_OUT_OF_MEMORY");
                }                
                default:
                    throw new Exception("Unknown error code");
            }            
        }
    }
}