{-# OPTIONS_GHC -Wall #-}

module Main where

import Log as L

-- Skip 'n' words and interpret the next one as a number.
wordsToNum :: String -> Int -> Int
wordsToNum s n = read ((words s) !! n)

-- Return the tail of a string.
dropWords :: String -> Int -> String
dropWords s n = unwords ( drop n (words s))

-- Convert a line from the sample log into an object of type L.LogMessage.
parseMessage :: String -> L.LogMessage
parseMessage [] = L.Unknown ""
parseMessage p@(x:_) = case x of
                        'E' -> L.LogMessage (L.Error (wordsToNum p 1)) (wordsToNum p 2) (dropWords p 3)
                        'W' -> L.LogMessage L.Warning                  (wordsToNum p 1) (dropWords p 2)
                        'I' -> L.LogMessage L.Info                     (wordsToNum p 1) (dropWords p 2) 
                        _   -> L.Unknown p

-- Parse a whole logfile.
parse :: String -> [LogMessage]
parse s = map parseMessage (lines s)

-- Insert a L.LogMessage into a sorted L.MessageTree.
insert :: L.LogMessage -> L.MessageTree -> L.MessageTree
insert (L.Unknown _) t = t
insert m (L.Leaf) = L.Node Leaf m Leaf
insert m@(L.LogMessage _ ts1 _)
       (L.Node lhs (L.LogMessage _ ts2 _) rhs) 
         = case ts1 > ts2 of
             True -> insert m rhs
             _    -> insert m lhs
insert _ _ = L.Leaf  -- error, what do we do now?


-- Construct tree sorted by timestamp.
build :: [L.LogMessage] -> L.MessageTree
build [] = L.Leaf
build (m:l) = insert m (build l) 

-- Flatten the tree into a sorted list.
inOrder :: L.MessageTree -> [L.LogMessage]
inOrder (L.Leaf) = []
inOrder (L.Node lhs m rhs) = inOrder lhs ++ [m] ++ inOrder rhs

-- Sort by increasing timestamp.
sort :: [L.LogMessage] -> [L.LogMessage]
sort l = inOrder (build l)

-- Remove massages, that are not error with severity >= 50.
filterList :: [L.LogMessage] -> [L.LogMessage]
filterList [] = []
filterList (m@(L.LogMessage (Error e) _ _):l) = case e >= 50 of
                                                  True -> [m] ++ filterList l
                                                  _    -> filterList l 
filterList (_:l) = filterList l

toString :: [L.LogMessage] -> [String]
toString [] = []
toString (m:l) = [show m] ++ toString l

-- Extracts Error messages with severity >= 50 from an _unsorted_ list.
whatWentWrong :: [L.LogMessage] -> [String]
whatWentWrong [] = []
whatWentWrong l = toString (filterList (sort l))

main :: IO()
main = do
         print (parseMessage "E 2 562 help help")
         print (parseMessage "I 29 la la la")
         print (parseMessage "This is not in the right format")

         _ <- L.testParse parse 10 "./sample.log" 

         a <- L.testWhatWentWrong parse whatWentWrong "./sample.log"
         print (unlines a)
