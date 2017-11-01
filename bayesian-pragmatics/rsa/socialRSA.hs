-- quds: models: burnouts use urban things to index subset of urban things: an s2 can do this successfully
-- vineyarders use vineyard language (hypercorrectly: OOH could also be modelled via a speaker model of vineyarders that
--   is not historically accurate) to mark their stance: this explains why they use it more than expected

-- upper middle class try to maximize social capital
--   DO second two BY: they have value dist over worlds. they use actual world to get s0, and value dist for utility: 
--     listener tries to 

-- authenticity: speakers try to sound authentic: i.e. to pertain to a perceived norm


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
type World = [Int]
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double World
type Speaker = Integer -> World -> Dist Double Utterance

--the possible utterances and worlds: both are distributions
utterances = uniformDraw ["in","ing"]
worlds = uniformDraw [[0,1],[1,0],[1,1],[0,0]]
desiderata = uniformDraw [[0,1],[1,0],[1,1],[0,0]]
aspects = uniformDraw [0,1]
speakers = uniformDraw [0,1]
--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion
vernacular :: Fractional a => World -> Utterance -> a
vernacular w u = if (w!!0) == 0 then (if u == "in" then 0.99 else 0.001) else 0.1

--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
-- s :: Speaker
s0 w desideratum aspect = do
    --samples an utterance uniformly from the possible utterances
    u <- utterances
    --does a condition on the truth of the utterance in the sampled world
    factor $ vernacular w u
    return u

--we want q to represent the intent of the speaker: it biases the world in some direction
s1 w desideratum aspect = do
  u <- s0 w desideratum aspect
  let utility = mass (fmap (!! aspect) (l1 u) ) ((!! aspect) desideratum) :: Double
  factor $ realToFrac utility
  return u

-- s2 w q = do
--   u <- s0 w
--   let utility = mass (l2 u) q :: Double
--   factor $ realToFrac utility
--   return u  

-- l 1 u = do
--     --samples a world uniformly from the possible worlds
--     w <- worlds
--     --does a condition on the truth of the utterance in the sampled world
--     factor $ mass (s 0 w) u
--     return w
l1 u = do
    desideratum <- desiderata
    aspect <- aspects  
    w <- worlds
    let speaker_out = s0 w desideratum aspect
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return w

l2 u = do
    w <- worlds
    desideratum <- desiderata
    aspect <- aspects
    speaker <- speakers
    let speaker' = [s0,s1] !! speaker
    let speaker_out = speaker' w desideratum aspect
    factor $ realToFrac $ (mass (speaker_out) u :: Double)
    return (aspect)


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- -- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

-- --util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

