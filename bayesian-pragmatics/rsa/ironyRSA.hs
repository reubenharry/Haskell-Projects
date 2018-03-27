--  irony as countersignalling: one is ironic in situations where one wants listener to infer that shared world is so
-- obviously foo that one can describe it as blah and still know

-- 	in other words, combine qud model with common ground model
-- listener models for irony: ``well that was normal'': we want the listener to be put in the position they would be put in if that was actually normal: they then feel incongruence which makes them realize it's not:
-- 	in other words, speaker tries to maximize listener dissonance
-- incorporate possibility in sarcasm model that s1 is not cooperative: flip a coin and speaker may lie


import Numeric.LogDomain
import Control.Monad (liftM2,replicateM)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Data.List
import Data.Function


bgivena,agivenb :: Bool -> Dist Double Bool
bgivena a = if a then bernoulli 0.0 else bernoulli 0.5
agivenb b = if b then bernoulli 0.5 else bernoulli 0.5 

joint1 = do
	x <- a
	y <- bgivena x
	return (x,y)

joint2 = do
	x <- b
	y <- agivenb x
	return (x,y)



a,b :: Dist Double Bool
a = bernoulli 0.5
b = bernoulli 0.5

c :: Dist Double Bool
c = do
	x <- a
	y <- b
	return (x && y)

--  whether the talk is good
data World = Great | OK | Terrible deriving (Eq,Ord,Show)
	-- OldMoney | NewMoney | Poor
type Utterance = World

type WorldPriorParams = [Double]

worlds = [Terrible,OK,Great]
utterances = worlds

world_to_num w
  |w==Terrible = 0
  |w==OK = 0.45
  |w==Great = 0.9

l0 :: WorldPriorParams -> Utterance -> Dist Double World
l0 cat u = do
	w <- categorical $ zip worlds cat

	factor $ toLogDomain $ abs((world_to_num w)-(world_to_num u))
	return w

s1 :: WorldPriorParams -> World -> Dist Double Utterance
s1 cat w = do
	u <- uniformD utterances
	factor $ toLogDomain $ mass (l0 cat u) w
	return u

l1 :: Utterance -> Dist Double (WorldPriorParams,World)
l1 u = do
	-- cat <- replicateM 3 (uniformD [0.1,0.9])
	lps <- ps_prior
	sps <- ps_prior
	w <- categorical $ zip worlds lps	
	-- w <- l0 cat u
	factor $ toLogDomain $ mass (s1 sps w) u
	-- factor $ realToFrac $ mass (categorical $ zip worlds sps) w
	return (lps,w)

s2 :: WorldPriorParams -> Dist Double Utterance
s2 sps = do
	u <- uniformD utterances
	-- s1 sps w
	factor $ toLogDomain $ mass (fmap fst (l1 u)) (sps)
	return u 


l2 :: Utterance -> Dist Double (WorldPriorParams,World)
l2 u = do
	-- cat <- replicateM 3 (uniformD [0.1,0.9])
	-- lps <- ps_prior
	sps <- ps_prior
	w <- categorical $ zip worlds sps
	
	-- w <- l0 cat u
	factor $ toLogDomain $ mass (s2 sps) u
	return (sps,w)

ps_prior = uniformD [[0.9,0.09,0.01],[0.99,0.09,0.01]]

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate

