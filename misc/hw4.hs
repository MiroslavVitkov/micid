{-# OPTIONS_GHC -Wall #-}

module Main where

-- Assignment 1
fun1' :: [Integer] -> Integer
fun1' = foldr (\a b -> (a-2)*b) 1 . filter even

fun2' :: Integer -> Integer
fun2' = sum . takeWhile(>1) . iterate f
          where f x = if even x then x `div` 2 else 3*x+1


-- Assignment 2
data Tree a = Leaf
            | Node Integer (Tree a) a (Tree a)
  deriving (Show, Eq)

foldTree :: [a] -> Tree a
foldTree = --use forldr, generate balanced tree from list of values

main = print (fun2' 5)
