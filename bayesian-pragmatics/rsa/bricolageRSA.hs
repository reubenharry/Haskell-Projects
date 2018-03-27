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


-- fromCity and Tough are correlated: 
  -- if you're from city, vernacluar model says you're more likely to be tough 
--the possible utterances and world_prior: both are distributions
world_prior = do
  fromCity <- bernoulli 0.1
  tough <- if fromCity then bernoulli 0.7 else bernoulli 0.2
  return (fromCity,tough)

aspects = bernoulli 0.5
--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion
vernacular :: MonadBayes d => World -> d String
vernacular w = do
    let (w1,w2) = w
    -- fromCity <- if w1 then bernoulli 0.8 else bernoulli 0.001
    -- tough <- if w2 then bernoulli 0.6 else bernoulli 0.3
    -- noise <- bernoulli 0.001
    if (w1&&w2) then return "in" else return "ing" 
--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
-- s :: Speaker
s0 w aspect = vernacular w

--we want q to represent the intent of the speaker: it biases the world in some direction
s1 w aspect = do
  -- u <- s0 w aspect
  u <- uniformD ["in","ing"]
  let utility = mass (fmap (aspect) (l0 u) ) (aspect w) :: Double
  factor $ realToFrac utility
  return u

s2 w = do
  aspect <- aspects
  -- u <- s0 w aspect
  u <- uniformD ["in","ing"]
  let utility = mass (fmap fst (l1 u)) w :: Double
  factor $ realToFrac utility
  return u 

-- l 1 u = do
--     --samples a world uniformly from the possible world_prior
--     w <- world_prior
--     --does a condition on the truth of the utterance in the sampled world
--     factor $ mass (s 0 w) u
--     return w
l0_a u = do
    a <- aspects  
    let aspect = if a then fst else snd
    w <- world_prior
    let speaker_out = s0 w aspect
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return a

l0 u = do
    a <- aspects  
    let aspect = if a then fst else snd
    w <- world_prior
    let speaker_out = s0 w aspect
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return w

l1 u = do
    w <- world_prior
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


