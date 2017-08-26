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
type Listener = Integer -> Utterance -> Dist Double Char
type Speaker = Integer -> Char -> Dist Double Utterance

--the possible utterances and worlds: both are distributions
utterances = uniformDraw ["blue","square"]
worlds = uniformDraw ['0','1']

--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional
meaning :: Fractional a => Utterance -> World -> a
meaning "blue" _ = realToFrac 1.0
meaning "square" '0' = realToFrac 1.0
meaning "square" '1'  = realToFrac 0.0


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
s :: Speaker
s 0 w = utterances
s n w = do
  u <- s (n-1) w
  let utility = mass (l (n-1) u) w :: Double
  factor $ realToFrac utility
  return u

l :: Listener
l 0 u = do
    --samples a world uniformly from the possible worlds
    w <- worlds
    --does a condition on the truth of the utterance in the sampled world
    factor $ meaning u w
    return w
l n u = do
    w <- worlds
    factor $ realToFrac $ (mass (s n w) u :: Double)
    return w


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

--util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

