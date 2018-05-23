-- Atempts to a find a word in a spoken sentance.


module Main where


import Data.Vector as V

import qualified DSP.Correlation as C  -- dsp


array = V.generate 10 (\i -> (1.0 / (fromIntegral i), (1.0 / fromIntegral i)))


main :: IO ()
--main = print $ C.rxy_u array array 0
main = print $ V.generate 10 (\i -> (1.0 / (fromIntegral (i+1)), (1.0 / fromIntegral (i+1))))
