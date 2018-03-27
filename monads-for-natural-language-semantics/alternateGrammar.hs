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
parent :: [Entity]
parent = [Homer,Marge]
child :: [Entity]
child = [Lisa,Bart, Maggie]

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