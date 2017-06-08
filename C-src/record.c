#include <SDL2/SDL.h>
#include <signal.h>

#include <assert.h>
#include <stdio.h>
#include <stdint.h>


// Refer to http://soundg_file.sapp.org/doc/WaveFormat/
struct WavHeader
{
    uint32_t chunk_id;
    uint32_t chunk_size;
    uint32_t format;

    uint32_t subchunk_1_id;
    uint32_t subchunk_1_size;
    uint16_t audio_format;
    uint16_t num_channels;
    uint32_t sample_rate;
    uint32_t byte_rate;
    uint16_t block_align;
    uint16_t bits_per_sample;

    uint32_t subchunk_2_id;
    uint32_t subchunk_2_size;
};


static const uint32_t g_sample_rate = 48000;  // 48kHz
static const uint32_t g_bytes_per_sample = 1;  // uint8_t, not being taken into account inside main()
static const uint32_t  g_num_channels = 1;  // mono
static const char* g_file_name = "mic.wav";
static FILE * g_file = NULL;


// Convert little-endian numbers to big-endian or vice versa.
uint32_t swap32( uint32_t in )
{
    const uint8_t *  p = (uint8_t*)&in;
    const uint32_t ret = (p[3]<<0) | (p[2]<<8) | (p[1]<<16) | (p[0]<<24);
    return ret;
}


struct WavHeader create_wav_header( size_t data_len_bytes )
{
    struct WavHeader h;
    static_assert( sizeof(struct WavHeader) == 44, "Wrong .wav header structure." );

    h.chunk_id = swap32(0x52494646);  // ascii RIFF
    h.chunk_size = 36 + data_len_bytes;
    h.format = swap32(0x57415645);  // ascii "WAVE"

    h.subchunk_1_id = swap32(0x666d7420);  // acii "fmt "
    h.subchunk_1_size = 16;  // constant or PCM
    h.audio_format = 1;  // uncompressed
    h.num_channels = g_num_channels;  // mono

    h.sample_rate = g_sample_rate;
    h.bits_per_sample = 8 * g_bytes_per_sample;
    h.byte_rate = h.sample_rate * h.num_channels * (h.bits_per_sample/8);
    h.block_align = h.num_channels * (h.bits_per_sample/8);

    h.subchunk_2_id = swap32(0x64617461);  // acii for 'data'
    h.subchunk_2_size = data_len_bytes;

    return h;
}


void audio_callback( void * userdata, Uint8 * stream, int len )
{
    (void)userdata;
    assert( g_file );

    const size_t written = fwrite( stream, 1, len, g_file );
    assert( len >= 0 );
    assert( written == (size_t)len );
}


void signal_handler( int signal )
{
    (void)signal;
    assert( g_file );

    const size_t len = ftell( g_file );
    const struct WavHeader header = create_wav_header( len );

    {
        const int ret = fseek( g_file, 0, SEEK_SET );
        assert( ret == 0 );
    }

    {
        // Overwrite the default header.
        const size_t ret = fwrite( &header, 1, sizeof(header), g_file );
        assert( ret == sizeof(header) );
    }

    exit( 0 );
}


int main()
{
    printf( "Recording, use ctrl+c to finaize %s.\n", g_file_name );

    // Terminate the program via ctrl + c.
    signal( SIGABRT, signal_handler );
    signal( SIGINT, signal_handler );
    signal( SIGTERM, signal_handler );

    g_file = fopen( g_file_name, "w" );
    assert( g_file );

    // Exploit the fact that the header is constant in size.
    // We will come back and correct those values bofere exiting.
    const struct WavHeader dummy_header = create_wav_header( 0 );
    const size_t written = fwrite( &dummy_header, 1, sizeof(dummy_header), g_file );
    assert( written == sizeof(dummy_header) );

    if( SDL_Init( SDL_INIT_AUDIO ) < 0 )
    {
        printf( "SDL_Init() failed: %s\n", SDL_GetError() );
    }

    SDL_AudioSpec obtained;
    const SDL_AudioSpec desired = { .freq = g_sample_rate, .format = AUDIO_U8, .channels = g_num_channels, .samples = 4096, .callback = audio_callback, .userdata = NULL };
    const SDL_AudioDeviceID dev = SDL_OpenAudioDevice( NULL, 1, &desired, &obtained, SDL_AUDIO_ALLOW_ANY_CHANGE );
    if( dev == 0 )
    {
        printf( "SDL_OpenAudioDevice() failed: %s\n", SDL_GetError() );
    }

    SDL_PauseAudioDevice(dev, 0);

    // Wait for an interrupt signal.
    while(1);

    return 0;
}

