#!/usr/bin/python

from sdl2 import *
from ctypes import c_char, cast
import wave
import numpy as np
import signal
import sys

SAMPLE_RATE = 48000
NUM_CHANNELS = 1
WRITER = wave.open( "rec.wav", "w" )
WRITER.setnchannels( NUM_CHANNELS )
WRITER.setsampwidth( 1 )
WRITER.setframerate( SAMPLE_RATE )

def cleanup( a, b ):
    WRITER.close()

ret = SDL_Init( SDL_INIT_AUDIO )
assert( ret == 0 )

def audio_callback( userdata, buff_p, len ):
    a = np.fromiter( buff_p, dtype=np.uint8, count=len )
    WRITER.writeframes( a )

audio_callback_ = SDL_AudioCallback( audio_callback )
obtained = SDL_AudioSpec( SAMPLE_RATE, AUDIO_U8, NUM_CHANNELS, 4096 )
desired = SDL_AudioSpec( freq = SAMPLE_RATE, aformat = AUDIO_U8, channels = NUM_CHANNELS, samples = 4096, callback = audio_callback_, userdata = None )
dev = SDL_OpenAudioDevice( None, True, desired, desired, SDL_AUDIO_ALLOW_ANY_CHANGE )
assert( dev != 0 )

SDL_PauseAudioDevice( dev, 0 )

signal.signal( signal.SIGABRT, cleanup )
signal.signal( signal.SIGINT, cleanup )
signal.signal( signal.SIGTERM, cleanup )
signal.pause()

def main():
    pass

if __name__ == "__main__":
    main()
