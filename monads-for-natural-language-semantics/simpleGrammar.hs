--basic semantic composition with simply typed lambda calculus
--a simple model is provided, using the Simpsons, taken from Chris Potts' Stanford 130A
-- run the code using the button above, and then try out your own expressions in the box the the right

--the domain:
domain = [Bart, Lisa, Homer, Maggie, Marge]

-- the atomic types: E(ntity) and S(entence)
data Entity = Bart | Lisa | Homer | Maggie | Marge deriving (Eq,Show)
-- types of nouns, intransitive verbs (IV), transitive verbs (TV) etc
-- straight from Montague's Proper Treatment of Quantification
type Sentence = Bool
type Noun = Entity -> Sentence
type IV = Entity -> Sentence
type TV = Entity -> IV
type Determiner = Noun-> IV -> Sentence

--one place predicates
-- what follows "::" is the type
parent :: Noun
parent = characteristicFunc  [Homer,Marge]
child :: Noun
child = characteristicFunc [Lisa,Bart, Maggie]

--a verb: also a one place predicate
ran :: IV
ran = characteristicFunc [Bart, Homer, Marge]

--an adjective: important to think about the type here
hungry :: Noun -> Noun
hungry f x = if x `elem` [Bart, Maggie] && (f x) then True else False

--transitive verbs: two place predicates
-- unsurprisingly disfunctional family
loves :: TV
loves x y = if (x,y) `elem` [(Homer,Lisa),(Maggie,Homer), (Lisa,Lisa),(Marge,Marge),(Bart,Bart)] then True else False

--scope takers
every :: Determiner
every x f = subset (characteristicSet x) (characteristicSet f)
some :: Determiner
some x f = (intersection (characteristicSet x) (characteristicSet f)) /= []


-- exercises
no :: Determiner
-- left for the reader to complete
no x f = undefined
everyone :: (Entity -> Sentence) -> Sentence
-- left for reader also
everyone x = undefined
-- qs:
-- what would be the types of: quickly, not, and?


-- helper functions, so that the code mirrors the 130A notes. There are more succinct ways to implement a semantic grammar in Haskell, but they require a bit more theoretical baggage.
-- if you're curious what on earth is going on in these lines of code, feel free to ask, but otherwise take my word that they do what their names suggest
subset a b = all (==True) $ fmap (`elem` b) a
intersection a b = filter  (`elem` b) a
characteristicSet f = filter f domain 
-- this one is worth thinking about (clue: google ``currying''')
characteristicFunc x = (`elem` x)


main = do
  print ("Bart ran",ran Bart)
  print ("some hungry child loves Bart",((some (hungry child)) (loves Bart)))
  print()
  print("Try typing your own semantic expressions in this box below:")
  