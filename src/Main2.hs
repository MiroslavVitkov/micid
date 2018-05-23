{-# OPTIONS_GHC -Wall #-}


-- This module uses cabal package 'sdl2',
-- instead of the legacy sdl1(Graphics.UI.SDL) bindings.


module Main where


import qualified Control.Concurrent as C
import qualified Control.Monad as M
import qualified Data.Vector.Storable.Mutable as V
import qualified Data.Set as S

import qualified SDL
import qualified SDL.Audio as A

import qualified Codec.Audio.Wave as W

import qualified System.IO as IO


audioCb :: A.AudioFormat f -> V.IOVector f -> IO ()
audioCb _ _ = print "foo"

micSpec :: A.OpenDeviceSpec
micSpec = A.OpenDeviceSpec {A.openDeviceFreq = A.Mandate 48000
                           ,A.openDeviceFormat = A.Mandate A.Unsigned16BitNativeAudio
                           ,A.openDeviceChannels = A.Mandate A.Mono
                           ,A.openDeviceSamples = 4096
                           ,A.openDeviceCallback = audioCb
                           ,A.openDeviceUsage = A.ForCapture
                           ,A.openDeviceName = Nothing}

type SS = S.Set W.SpeakerPosition

waveSpec :: W.Wave
waveSpec = W.Wave {W.waveFileFormat = W.WaveVanilla
                  , W.waveSampleRate = 48000
                  , W.waveSampleFormat = W.SampleFormatPcmInt 16
                  , W.waveChannelMask = S.singleton W.SpeakerFrontCenter
                  , W.waveDataOffset = 0
                  , W.waveDataSize = 0
                  , W.waveSamplesTotal = 0
                  , W.waveOtherChunks = []}


record :: IO.Handle -> IO ()
record h = do
  SDL.initialize [SDL.InitAudio]
  (dev, _) <- A.openAudioDevice micSpec
  A.setAudioDevicePlaybackState dev A.Play
  _ <- M.forever (C.threadDelay maxBound)
  return ()

main :: IO ()
main =  W.writeWaveFile "mic.rec" waveSpec record
