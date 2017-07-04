{-# OPTIONS_GHC -Wall #-}


-- This module uses cabal package 'sdl2',
-- instead of the legacy sdl1(Graphics.UI.SDL) bindings.


module Main where


import qualified Control.Concurrent as C
import qualified Control.Monad as M
import qualified Data.Vector.Storable.Mutable as V

import qualified SDL
import qualified SDL.Audio as A


audioCb :: A.AudioFormat f -> V.IOVector f -> IO ()
audioCb _ _ = print "foo"

spec :: A.OpenDeviceSpec
spec = A.OpenDeviceSpec {A.openDeviceFreq = A.Mandate 48000
                        ,A.openDeviceFormat = A.Mandate A.Unsigned16BitNativeAudio
                        ,A.openDeviceChannels = A.Mandate A.Mono
                        ,A.openDeviceSamples = 4096
                        ,A.openDeviceCallback = audioCb
                        ,A.openDeviceUsage = A.ForCapture
                        ,A.openDeviceName = Nothing}

main :: IO ()
main = do
  SDL.initialize [SDL.InitAudio]
  (dev, _) <- A.openAudioDevice spec
  A.setAudioDevicePlaybackState dev A.Play
  _ <- M.forever (C.threadDelay maxBound)
  return ()
