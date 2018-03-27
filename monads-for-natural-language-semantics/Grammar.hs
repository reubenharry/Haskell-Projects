--basic semantic composition with simply typed lambda calculus
--a simple model is provided, using the simpsons
--the grammar is a shallow embedding into Haskell	
import Data.List
import Control.Monad

--the domain
dom = simpsons
data Entity = Bart | Lisa | Homer | Maggie | Marge deriving (Eq)
type Sentence = Bool
simpsons = [Bart, Lisa, Homer, Maggie, Marge]

--one place predicates
parent :: Entity -> Sentence
parent = (`elem` [Homer,Marge])
child :: Entity -> Sentence
child = (`elem` [Lisa,Bart, Maggie])

--a verb: also a one place predicate
ran :: Entity -> Sentence
ran = (`elem` [Bart, Homer, Marge])

--an adjective
hungry :: ((Entity -> Sentence) -> (Entity -> Sentence))
hungry = liftM2 (&&) hungry' where hungry' = (`elem` [Bart, Maggie])

--transitive verbs: two place predicates
loves :: Entity -> Entity -> Sentence
loves = curry (`elem` (fmap switch [(Homer,Lisa),(Maggie,Homer), (Lisa,Lisa),(Marge,Marge),(Bart,Bart)])) where switch (x,y) = (y,x)
teases :: (Entity -> Entity -> Sentence)
teases = curry (`elem` (fmap switch [(Bart,Bart), (Lisa,Homer), (Bart,Lisa), (Maggie,Marge)])) where switch (x,y) = (y,x)

--scope takers
everyone :: (Entity -> Sentence) -> Sentence
everyone f = all (==True) $ fmap f dom
someone = some (`elem` simpsons)
every :: (Entity -> Sentence) -> (Entity -> Sentence) -> Sentence
every x f = all (==True) $ fmap f $ filter x dom
some :: (Entity -> Sentence) -> (Entity -> Sentence) -> Sentence
some x f = any (==True) $ fmap f $ filter x dom
no :: (Entity -> Sentence) -> (Entity -> Sentence) -> Sentence
no x f = all (==False) $ fmap f $ filter x dom

main = print ((every child) (loves Bart))

-- --basic semantic composition with simply typed lambda calculus
-- --a simple model is provided, using the simpsons
-- --the grammar is a shallow embedding into Haskell	

-- module Grammar where

-- import Data.List
-- import Control.Monad

-- --the domain
-- dom = simpsons
-- simpsons = ["Bart", "Lisa", "Homer", "Maggie","Marge"]

-- --one place predicates
-- parent :: String -> Bool
-- parent = (`elem` ["Homer","Marge"])
-- child :: String -> Bool
-- child = (`elem` ["Lisa","Bart", "Maggie"])

-- --a verb: also a one place predicate
-- ran :: String -> Bool
-- ran = (`elem` ["Bart", "Homer", "Marge"])

-- --an adjective
-- hungry :: ((String -> Bool) -> (String -> Bool))
-- hungry = liftM2 (&&) hungry' where hungry' = (`elem` ["Bart", "Maggie"])

-- --transitive verbs: two place predicates
-- loves :: String -> String -> Bool
-- loves = curry (`elem` (fmap switch [("Homer","Lisa"),("Maggie","Homer"), ("Lisa","Lisa"),("Marge","Marge"),("Bart","Bart")])) where switch (x,y) = (y,x)
-- --[("Homer","Homer"),("Homer","Lisa"),("Marge","Bart"), ("Homer", "Maggie"),("Lisa", "Maggie"),("Lisa", "Marge"),("Maggie", "Homer"),("Marge", "Homer"), (("Bart", "Homer"))]
-- --[("Homer","Maggie"),("Lisa","Bart"), ("Homer","Lisa"),("Homer","Marge"),("Homer","Homer"),("Lisa","Homer"),("Maggie","Homer"),("Bart","Marge")]
-- teases :: (String -> String -> Bool)
-- teases = curry (`elem` (fmap switch [("Bart","Bart"), ("Lisa","Homer"), ("Bart","Lisa"), ("Maggie","Marge")])) where switch (x,y) = (y,x)

-- --scope takers
-- everyone :: (String -> Bool) -> Bool
-- everyone f = all (==True) $ fmap f dom
-- someone = some (`elem` simpsons)
-- every :: (String -> Bool) -> (String -> Bool) -> Bool
-- every x f = all (==True) $ fmap f $ filter x dom
-- some :: (String -> Bool) -> (String -> Bool) -> Bool
-- some x f = any (==True) $ fmap f $ filter x dom
-- no :: (String -> Bool) -> (String -> Bool) -> Bool
-- no x f = all (==False) $ fmap f $ filter x dom