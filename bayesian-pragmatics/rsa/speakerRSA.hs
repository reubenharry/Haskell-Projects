{-# LANGUAGE RankNTypes, TypeFamilies, FlexibleContexts, AllowAmbiguousTypes, ImpredicativeTypes #-}

import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Text.Parsec
-- import BayesUtils

--first we declare our types
type Utterance = String
type World = Char
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Utterance -> Dist Double Char
type Speaker = Char -> Dist Double Utterance

--the possible utterances and worlds: both are distributions
utterances = uniformD ["bus","double decker bus"]
worlds = uniformD ['0','1']

--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional
meaning :: Utterance -> World -> Bool
meaning "bus" _ = True
meaning "double decker bus" '0' = True
meaning "double decker bus" '1'  = False


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
s0,s1 :: Speaker
s0 w = do
  u <- utterances
  condition $ meaning u w
  return u

l0 :: Listener
l0 u = do
  w <- worlds
  let utility = mass (s0 w) u :: Double
  factor $ realToFrac utility
  return w

s1 w = do
    u <- utterances
    factor $ realToFrac $ (mass (l0 u) w :: Double)
    return u


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

--util
