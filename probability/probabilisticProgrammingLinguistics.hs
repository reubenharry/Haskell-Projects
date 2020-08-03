-- the vanilla Rational Speech Acts model, via probablistic programming
-- no dsl needed in Haskell - just use a probability monad

import Control.Monad (when)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Sampler
import Control.Monad.Bayes.Weighted
import Control.Monad.Bayes.Traced.Basic
import Control.Monad.Bayes.Enumerator

-- state type
type State = Int
-- utterance type
type Utterance = String

-- state space
states :: [State]
states = [1..3]

-- utterance space
utterances :: [Utterance]
utterances = ["1","2","3"]

-- the standard "at least" semantics. i.e. "1" is compatible with any integer greater or equal to 1
semantics :: Utterance -> State -> Bool
semantics = (<=) . read

-- literal listener: hears "1" and exclude no states
l0 :: MonadInfer m => Utterance -> m State
l0 u = do
  s <- uniformD states
  condition $ semantics u s
  return s

-- informative speaker: prefers informative utterances
s1 :: MonadInfer m => State -> m Utterance
s1 s = do
  u <- uniformD utterances
  factor $ realToFrac $ mass (l0 u) s
  return u

-- hears "1" and prefers 1 as a state: this corresponds to a scalar implicature.
l1 :: MonadInfer m => Utterance -> m State
l1 u = do
  s <- uniformD states
  factor $ realToFrac $ mass (s1 s) u 
  return s

main = do
  print $ enumerate $ l1 "1"
  let nsamples = 1001
  samples <- sampleIOfixed $ prior $ mh nsamples (l1 "1")
  print $ (/(fromIntegral nsamples)) $ sum $ map fromIntegral $ samples