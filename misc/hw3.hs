{-# OPTIONS_GHC -Wall #-}

module Golf where

import Data.List as D

-- Assignment 1
every :: [a] -> Int -> [a]
every xs n = case drop (n-1) xs of
              (y:ys) -> y : every ys n
              [] -> []

skips :: [a] -> [[a]]
skips [] = [[]]
skips l = map (every l) [1..(length l)]

-- Assignment 2
localM :: Integer -> Integer -> Integer -> [Integer]
localM a b c = if (b > a) && (b > c) then [b] else []

localMaxima :: [Integer] -> [Integer]
localMaxima (a:b:c:l) = (localM a b c) ++ localMaxima ([b] ++ [c] ++ l)
localMaxima _ = []

-- Assignment 3
stars :: [Int] -> Int -> String
stars l n = concatMap f l
              where f e = if e == n then "*" else ""

calcRow :: [Int] -> Int -> String
calcRow l n = show n ++ "=" ++ stars l n

allRows :: [Int] -> [String]
allRows l = map (calcRow l) [0..9]

histogram :: [Int] -> String
histogram l = D.concatMap f (D.transpose (allRows l))
                where f s = s ++ "\n"
