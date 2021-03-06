module FunSet where

-- import Test.QuickCheck

type Set a = a -> Bool

-- instance Arbitrary Set where
--   arbitrary = do i <- choose (0, 10000)
--                  return (singleton i)

newEmpty :: Set a
newEmpty = \_ -> False

-- *FunSet> newEmpty []
-- False
-- *FunSet> newEmpty 1
-- False

add :: Eq a => Set a -> a -> Set a
add s e = \i -> (e == i) || contains s i

-- *FunSet> ((add newEmpty 1) 1)
-- True
-- *FunSet> ((add newEmpty 1) 2)
-- False

contains :: Set a -> a -> Bool
contains s e = s e

-- *FunSet> contains newEmpty 1
-- False
-- *FunSet> contains (add newEmpty 1) 1
-- True
-- *FunSet> contains (add newEmpty 1) 2
-- False

singleton :: Eq a => a -> Set a
singleton a = \e -> (a == e)

-- *FunSet> contains (singleton 1) 1
-- True
-- *FunSet> contains (singleton 1) 3
-- False

union :: Set a -> Set a -> Set a
union a b = \e -> a e || b e

-- *FunSet> (union (singleton 1) (singleton 2)) 1
-- True
-- *FunSet> (union (singleton 1) (singleton 2)) 2
-- True
-- *FunSet> (union (singleton 1) (singleton 2)) 3
-- False

intersect :: Set a -> Set a -> Set a
intersect a b = \e -> a e && b e

-- *FunSet> (intersect (union (singleton 1) (singleton 2)) (singleton 1)) 2
-- False
-- *FunSet> (intersect (union (singleton 1) (singleton 2)) (singleton 1)) 1
-- True

diff :: Set a -> Set a -> Set a
diff a b = \e -> a e && not (b e)

-- *FunSet> (diff (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3))) 1
-- False
-- *FunSet> (diff (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3))) 2
-- True
-- *FunSet> (diff (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3))) 3
-- False

filter' :: (a -> Bool) -> Set a -> Set a
--filter' p s = \e -> p e && s e
filter' = intersect

-- *FunSet> (filter' (== 2) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 3
-- False
-- *FunSet> (filter' (== 3) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 3
-- True
-- *FunSet> (filter' (>= 1) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 3
-- True
-- *FunSet> (filter' (>= 1) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 1
-- True
-- *FunSet> (filter' (>= 1) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 2
-- True
-- *FunSet> (filter' (>= 1) (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 10
-- False

remove :: Eq a => a -> Set a -> Set a
remove e s = \i -> (diff s (singleton e)) i

-- *FunSet> (remove 1 (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 1
-- False
-- *FunSet> (remove 1 (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 2
-- True
-- *FunSet> (remove 1 (union (union (singleton 1) (singleton 2)) (union (singleton 1) (singleton 3)))) 3
-- True

set :: Eq a => [a] -> Set a
set [] = newEmpty
set (x:xs) = add (set xs) x

-- *FunSet> map (set [1,2,3]) [0..4]
-- [False,True,True,True,False]

-- is there any element in Set a that satisfies the predicate (a -> Bool)
exists' :: (Enum a, Num a, Ord a) => Set a -> (a -> Bool) -> Bool
exists' s p = or $ map ( \x -> contains s x && p x ) [-1000..1000]

-- *FunSet> exists' (set [1..3]) (== 1)
-- True
-- *FunSet> exists' (set [1..3]) (== 0)
-- False

map' :: (Enum a, Num a, Ord a, Eq a, Eq b) => (a -> b) -> Set a -> Set b
map' f s = \y -> exists' s (\x -> f x == y)

-- *FunSet> map (set [1,2,3]) [0..4]
-- [False,True,True,True,False]
-- *FunSet> map (map' (+1) (set [1,2,3])) [0..4]
-- [False,False,True,True,True]

-- checks if all Set a elements satisfy (a -> Bool) predicate
all' :: (Enum a, Num a, Ord a) => Set a -> (a -> Bool)-> Bool
all' s p = and $ map p (filter s [-1000..1000])

-- *FunSet> all' (set [1..3]) (<= 4)
-- True
-- *FunSet> all' (set [1..3]) (<= 3)
-- True
-- *FunSet> all' (set [1..3]) (<= 2)
-- False
