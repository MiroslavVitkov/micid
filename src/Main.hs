{-# OPTIONS_GHC -Wall #-}

module Main where


import qualified Control.Concurrent as C
import qualified Control.Monad as M
import qualified Data.Vector.Storable.Mutable as V
import qualified Graphics.UI.SDL as SDL
--import qualified Graphics.UI.SDL.Audio as A
import qualified SDL.Audio as A


audioCb :: A.AudioFormat sampleType -> V.IOVector sampleType -> IO ()
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
  SDL.init[ SDL.InitAudio ]  -- do we need this?
  (dev, _) <- A.openAudioDevice spec
  A.setAudioDevicePlaybackState dev A.Play
  _ <- M.forever (C.threadDelay maxBound)
  return ()


-- apg-get install libghc-sdl-*
-- cabal install sdl2
