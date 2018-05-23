{-# OPTIONS_GHC -Wall #-}


module Main where

class C a where
  foo :: a -> Int


class D a where
  baz :: a -> Int


bar :: (C a, D a) => a -> Int
bar = baz
zxc = baz


main :: IO ()
main = print "go"
