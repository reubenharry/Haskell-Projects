--vineyard case is tricky: the situation must be that if a vineyarder didn't desire to show their stance, they wouldn't
  -- be as likely to choose foo: this means foo must go against their s0


-- upper middle class try to maximize social capital
--   DO second two BY: they have value dist over worlds. they use actual world to get s0, and value dist for utility: 
--     listener tries to 

--let's try to encode that people have strong priors on gender, but weaker on class, and then also add authenticity layers
--how to encode that women are percieved as less authentic?

--maybe second variable should be: relaxed vs not relaxed

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
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double World
type Speaker = Integer -> World -> Dist Double Utterance
type SocialClass = Bool
type Gender = Bool
type Utterance = String
type World = (SocialClass,Gender)

--the possible utterances and worlds: both are distributions
-- utterances = uniformDraw ["in","ing"]
worlds = do
  a <- bernoulli 0.5
  b <- bernoulli 0.9
  return (a,b)
desiderata = do 
  a <- bernoulli 0.8
  b <- bernoulli 0.6
  return (a,b)
--instead of having a denotational semantics, we have a speaker model s0 at the base of the recursion


-- vernacular :: Fractional a => World -> Utterance -> a
-- vernacular [0,0] "in" = 0.7
-- vernacular [0,1] "in" = 0.1 
-- vernacular [1,0] "in" = 0.0001
-- vernacular [1,1] "in" = 0.999
-- vernacular [0,0] "ing" = 0.3
-- vernacular [0,1] "ing" = 0.5
-- vernacular [1,0] "ing" = 0.67
-- vernacular [1,1] "ing" = 0.897

vernacular :: MonadBayes d => World -> d String
vernacular w = do
    let (w1,w2) = w
    a <- if w1 then bernoulli 0.9 else bernoulli 0.1
    -- male <- if w2 then bernoulli 0.5 else bernoulli 0.5
    if a then return "ing" else return "in" 

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate


-- s0 w = do
--     --samples an utterance uniformly from the possible utterances
--     u <- utterances
--     --does a condition on the truth of the utterance in the sampled world
--     factor $ vernacular w u
--     return u 

s0 = vernacular

--we want q to represent the intent of the speaker: it biases the world in some direction
s1 w desideratum = do
  u <- s0 w
  let utility = mass (l1 u) desideratum :: Double
  factor $ realToFrac utility
  return u

s2 w d = do
  u <- s0 w
  let utility = mass (l2 u) (w,d) :: Double
  factor $ realToFrac utility
  return u  


l1 u = do
    w <- worlds
    let speaker_out = s0 w
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return w

l2 u = do
    desideratum <- desiderata
    w <- worlds
    let speaker_out = s1 w desideratum
    factor $ realToFrac $ (mass speaker_out u :: Double)
    return (w,desideratum)

l3 u = do
    w <- worlds
    d <- desiderata
    factor $ realToFrac $ mass (s2 w d) u
    return (w,d)
-- s2

reveal = sortBy (flip compare `on` (snd)) . enumerate

main = print $ reveal $ l3 "in"
-- l3
-- THESE ARE IM

-- l2 u = do
--     w <- worlds
--     desideratum <- desiderata
--     speaker <- speakers
--     let speaker' = [s0,s1] !! speaker
--     let speaker_out = speaker' w desideratum
--     factor $ realToFrac $ (mass (speaker_out) u :: Double)
--     return (aspect)


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]
-- -- [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

-- --util
uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

