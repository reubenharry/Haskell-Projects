OH: maybe the point is just that the speaker wants to cause the listener to induce a prior about what reasonable prices
are

so my original idea was that speaker just wants to get listener into their state of surprisal: this means speaker needs
model of listener prior (i.e. common knowledge)

OK, so now i'm thinking that the idea is that the speaker can have deontic distributions over what world should be, 
and over what should be said, and that they can try to convey these too.



l0: normal: p(w|u)
s1: just tries to convey surprisal: how surprising they found it to learn the denotation of their utterance:
  p(u|w,s), s :: Double
l1: tries to infer world 
  this is nice, because the l1 has to recover world from surprisal: so worldstate is embedded in social meaning

  alt: s1: tries to convey world: p(u|w) : how is surprisal involved? 
    suppose the speaker says: n=1000: if we have a prior on the speaker's prior, then we can calculate their surprisal

      l1: tries to infer world and surprisal: this means that l1 needs a model of the s1's world prior:
          and then calculates how much their info gain would have surprised the speaker: not joint inf i don't think:
            formally, they infer a world, and then calculate the surprisal on the speaker's prior
        so: l1 :: p(w,s|u), contains: mean/variance of a binomial of hypothesized speaker world prior

      s2: p(u|w,s): if i say huge number for u, then the l1 should infer that the speaker is very surprised

      l2: p(w,s|u): joint inference



  OK: can we generalize to a utility inference? the tricky part is to choose the space of utility functions:
    but apart from that, the structure here is good for doing general second order models


  what i need to get this running:
    code for surprisal 
    prior over means over binomial: if not discrete, then no exact inference, so then i need mcmc


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
type World = (Int,Int)
type Surprisal = Double
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double World
type Speaker = Integer -> World -> Dist Double Utterance

--the possible utterances and worlds: both are distributions
utterances = uniformDraw [1..10]
worlds = uniformDraw [1..10]

--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion

meaning = (==)


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
l0 :: Utterance -> Dist Double World
l0 u = do
    --samples a world uniformly from the possible worlds
    w <- worlds
    --does a condition on the truth of the utterance in the sampled world
    factor $ meaning u w
    return w

l1 :: Utterance -> Dist Double (World,Surprisal)
l1 u = do
    w <- worlds
    v <- ...
    factor $ realToFrac $ (mass (s n w) u :: Double)
    return w

s1 :: WorldVariance -> World -> Dist Double Utterance
s1 w = do
  u <- binomial 10 WorldVariance
  let utility = mass (l0 u) w :: Double
  factor $ realToFrac utility
  return u


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

--util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x


