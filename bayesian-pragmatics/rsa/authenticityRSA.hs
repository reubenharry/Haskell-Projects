--alternative approach: lifted rationality: more rational means less authentic:

  -- rationality is measure of how much s1 cares about being strategic: so low rationality means more authentic


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
speakers = uniformDraw [0,1]
desiderata = uniformDraw [[0,1],[1,0],[1,1],[0,0]]

--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion
vernacular :: Fractional a => World -> Utterance -> a
vernacular [0,0] "in" = 0.7
vernacular [0,1] "in" = 0.1 
vernacular [1,0] "in" = 0.0001
vernacular [1,1] "in" = 0.999
vernacular [0,0] "ing" = 0.3
vernacular [0,1] "ing" = 0.5
vernacular [1,0] "ing" = 0.67
vernacular [1,1] "ing" = 0.897
-- w u = if (w!!0) == 0 then (if u == "in" then 0.99 else 0.001) else (if u == "in" then 0.7 else 0.041)

--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
-- s :: Speaker
s0 w d = do
    --samples an utterance uniformly from the possible utterances
    u <- utterances
    --does a condition on the truth of the utterance in the sampled world
    factor $ vernacular w u
    return u

--we want q to represent the intent of the speaker: it biases the world in some direction
s1 w d = do
  u <- s0 w d
  let utility = mass (l1 u) d :: Double
  factor $ realToFrac utility
  return u

s2 w d = do
  u <- s0 w d
  let utility = mass (l2 u) d :: Double
  factor $ realToFrac utility
  return u  

-- l 1 u = do
--     --samples a world uniformly from the possible worlds
--     w <- worlds
--     --does a condition on the truth of the utterance in the sampled world
--     factor $ mass (s 0 w) u
--     return w
l1 u = do
    w <- worlds
    d <- desiderata
    let speaker_out = s0 w d
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return w

-- l2 
l2 :: [Char] -> Dist Double [Int]
l2 u = do
    w <- worlds
    speaker <- speakers
    d <- desiderata
    let speaker' = [s0,s1] !! speaker
    let speaker_out = speaker' w d
    factor $ realToFrac $ (mass (speaker_out) u :: Double)
    return w


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- -- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

-- --util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

