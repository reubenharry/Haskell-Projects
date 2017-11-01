-- quds: models: burnouts use urban things to index subset of urban things: an s2 can do this successfully
  -- eg: let's say men use in more: when i use in, being a woman, i index not man but something else:
    -- this means man can't be basis: has to be construct:
    -- maybe try gay as a complex thing, and then subtype with qud

  -- hard to convince someone you don't belong to category man; so indexing "woman" strongly suggests qud

--city and rough, but i'm rural and want to index rough:
  -- so i can say "in", even though naturally, only city speakers say it
    -- prior that i'm rural is very high, but rough uncertain



{-# LANGUAGE RankNTypes, TypeFamilies, FlexibleContexts, AllowAmbiguousTypes, ImpredicativeTypes #-}

import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Text.Parsec
import Data.List
import Data.Function
-- import BayesUtils

--first we declare our types
type Listener = Integer -> Utterance -> Dist Double World
type Speaker = Integer -> World -> Dist Double Utterance
type FromCity = Bool
type Tough = Bool
type Utterance = String
type World = (FromCity,Tough)

--the possible utterances and worlds: both are distributions
worlds = do
  a <- bernoulli 0.1
  b <- bernoulli 0.5
  return (a,b)

aspects = bernoulli 0.5
--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion
vernacular :: MonadBayes d => World -> d String
vernacular w = do
    let (w1,w2) = w
    -- fromCity <- if w1 then bernoulli 0.8 else bernoulli 0.001
    -- tough <- if w2 then bernoulli 0.6 else bernoulli 0.3
    -- noise <- bernoulli 0.001
    if (w1 && w2) then return "in" else return "ing" 
--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
-- s :: Speaker
s0 w aspect = vernacular w

--we want q to represent the intent of the speaker: it biases the world in some direction
s1 w aspect = do
  -- u <- s0 w aspect
  u <- uniformDraw ["in","ing"]
  let utility = mass (fmap (aspect) (l1 u) ) (aspect w) :: Double
  factor $ realToFrac utility
  return u

s2 w = do
  aspect <- aspects
  -- u <- s0 w aspect
  u <- uniformDraw ["in","ing"]
  let utility = mass (fmap fst (l2 u)) w :: Double
  factor $ realToFrac utility
  return u 

-- l 1 u = do
--     --samples a world uniformly from the possible worlds
--     w <- worlds
--     --does a condition on the truth of the utterance in the sampled world
--     factor $ mass (s 0 w) u
--     return w
l1_a u = do
    a <- aspects  
    let aspect = if a then fst else snd
    w <- worlds
    let speaker_out = s0 w aspect
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return a

l1 u = do
    a <- aspects  
    let aspect = if a then fst else snd
    w <- worlds
    let speaker_out = s0 w aspect
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return w

l2 u = do
    w <- worlds
    a <- aspects  
    let aspect = if a then fst else snd
    let speaker_out = s1 w aspect
    factor $ realToFrac $ (mass (speaker_out) u :: Double)
    return (w,if a then "first" else "second")


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- -- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate
-- --util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

