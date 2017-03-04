\begin{code}
-- main = print (validate 353463462526)
main = print (hanoi 3 "a" "b" "c")


-- Assignment 1 - credit card validation
toDigits 0 = []
toDigits n = toDigits (n `div` 10 ) ++ [n `mod` 10]

reverseList [] = []
reverseList (x:xs) = reverseList xs ++ [x]

toDigitsRev n = reverseList (toDigits n)

foo1 [] = []
foo1 (x:[]) =  [x]
foo1 (o:e:l) = o : 2*e : doubleEveryOther l
doubleEveryOther (x) = foo1 (reverseList x)

sumDigits [] = 0
sumDigits (d:l)
  | d < 10 = d + sumDigits l
  | otherwise = sumDigits (toDigits d) + sumDigits l

checksum n = sumDigits( doubleEveryOther (toDigits n))
validate n
  | checksum n `mod` 10 == 0 = True
  | otherwise = False 


-- Assignment 2 - towers of hanoi
-- a - initial peg
-- b - final peg
-- c - temporary storage
type Peg = String
type Move = (Peg, Peg)
hanoi :: Integer -> Peg -> Peg -> Peg -> [Move] 
-- hanoi n a b c = (a, b)
hanoi 0 a b c = []
hanoi n a b c = hanoi (n-1) a c b  ++ [(a,b)] ++ hanoi (n-1) c b a


\end{code}
