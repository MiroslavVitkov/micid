{-# OPTIONS_GHC -Wall #-}


-- This module uses cabal package 'sdl2',
-- instead of the legacy sdl1(Graphics.UI.SDL) bindings.
--
-- Further dependant package is 'wave'.


module Main where


import qualified Control.Concurrent as C
import qualified Control.Monad as M
import qualified Data.Vector.Storable.Mutable as V
import qualified Data.Set as S
import Foreign.ForeignPtr as P

import qualified SDL
import qualified SDL.Audio as A

import qualified Codec.Audio.Wave as W

import qualified System.IO as IO


type MicCb f = A.AudioFormat f -> V.IOVector f -> IO ()


--micCb :: IO.Handle -> MicCb f
--micCb _ _ (V.MVector size ptr) = print "kur"  --IO.hPutBuf h (p ptr size) size
--  where p ptr size = V.unsafeFromForeignPtr0 ptr size


--micSpec :: OpenDeviceCallback st -> A.OpenDeviceSpec
--micSpec :: MicCb f -> A.OpenDeviceSpec
--micSpec c = A.OpenDeviceSpec {A.openDeviceFreq = A.Mandate 48000
--                             ,A.openDeviceFormat = A.Mandate A.Unsigned16BitNativeAudio
--                             ,A.openDeviceChannels = A.Mandate A.Mono
--                             ,A.openDeviceSamples = 4096
--                             ,A.openDeviceCallback = c
--                             ,A.openDeviceUsage = A.ForCapture
--                             ,A.openDeviceName = Nothing}


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
--  let mic = micSpec (micCb h)
  let mic = A.OpenDeviceSpec {A.openDeviceFreq = A.Mandate 48000
                             ,A.openDeviceFormat = A.Mandate A.Unsigned16BitNativeAudio
                             ,A.openDeviceChannels = A.Mandate A.Mono
                             ,A.openDeviceSamples = 4096
                             ,A.openDeviceCallback = \_ (V.MVector size ptr) -> P.withForeignPtr ptr (\p -> IO.hPutBuf h p size)
                             ,A.openDeviceUsage = A.ForCapture
                             ,A.openDeviceName = Nothing}
  (dev, _) <- A.openAudioDevice mic
  A.setAudioDevicePlaybackState dev A.Play
--  _ <- M.forever (C.threadDelay maxBound)
  _ <- C.threadDelay 1000000
  return ()


main :: IO ()
main =  W.writeWaveFile "mic.rec" waveSpec record
