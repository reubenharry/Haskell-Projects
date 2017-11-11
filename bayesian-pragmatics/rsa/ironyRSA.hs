--  irony as countersignalling: one is ironic in situations where one wants listener to infer that shared world is so
-- obviously foo that one can describe it as blah and still know

-- AHA: so intercept can sort of be thought of as whether the speaker is cray or not: but then speaker can use this
-- and PRETEND to be cray, knowing that listener will ignore this
-- however, this strategic use of noise (figuratively speaker) allows for next speaker to say opposite of truth, so long
-- as it's sufficiently unlikely, since then the listener will assume cray:
	-- the utility is that the speaker then gets listener to infer that the world must be 



import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Data.List
import Data.Function


type Utterance = String

--  whether the talk is good
type World = Double

-- cond dist params for how good speaker thinks talk is, given that it's foo good
type Speaker_Intercept = Double
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances


s0 :: World -> Speaker_Intercept -> Dist Double Utterance
l0 :: World -> Utterance -> Dist Double Speaker_Intercept
-- picks the utterance that puts the l0 in her intercept
s1 :: World -> Speaker_Intercept -> Dist Double Utterance
--  picks the world that the speaker would have said
l1 :: Utterance -> Dist Double (World,Speaker_Intercept)
s2 :: World -> Speaker_Intercept -> Dist Double Utterance

-- we need to following tradeoff for some s: the less variance we have about the world,
--  the more variance we have about the utterance
s0 w s = do
	-- world <- bernoulli w
	-- let out = if world then 1 else 0
	-- return (out * s)
	bool <- bernoulli (w * s)
	return (if bool then "good" else "bad")

-- should infer what speaker is like
l0 w u = do 
	s <- uniformD [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
	factor $ realToFrac $ mass (s0 w s) u
	return s

-- acts strategically: given bad talk and bad opinion, will try to convey opinion
-- 
s1 w s = do
	u <- s0 ws
	factor $ realToFrac $ mass (l0 w u) s
	return u


-- if they hear talk was good, and they suspect that talk was actually bad, then
-- one explanation is that talk was bad and the speaker's intercept changes this
-- surely only requires s0 but ok: so basically hierarchical knowledge overrules s1
l1 u = do
	w <- categorical [(0.1,0.8),(0.7,0.2)] 
	-- uniformD [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
	s <- uniformD [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
	factor $ realToFrac $ mass (s1 w s) u
	return (w,s)

-- enter s2: she wants to lower variance on world distribution, and also to communicate stance:
	-- since world is already well known, she knows that 
s2 w s = do
	u <- uniformD ["good","bad"]
	factor $ realToFrac $ mass (l1 u) (w,s)
	return u


--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional

-- range = [1..10]
-- --mutually recursive definitions of pragmatic speaker and listener
-- --n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 



-- s0: says things if true, given common knowledge, which is: world state
-- l0: hears things given common knowledge

-- s1: says thing 



-- s0 :: Speaker
-- s0 w = do
-- 	all <- bernoulli (1.0-(1.0/w))
-- 	return (if all then "all" else "some")

-- s1 d w = do
-- 	u <- s0 w
-- 	disemble <- bernoulli d
-- 	let world = if disemble then w+1 else w
-- 	let utility = mass (l0 u) world
-- 	factor $ realToFrac utility
-- 	return u

-- s2 :: World -> Dist Double (Utterance,Double)
-- s2 w = do
-- 	d <- uniformD [0.1,0.9]
-- 	u <- s1 d w
-- 	disemble <- bernoulli d
-- 	let world = if disemble then w+1 else w
-- 	let utility = mass (l1 d u) world
-- 	factor $ realToFrac utility
-- 	return (u,d)

-- l0 :: Listener
-- l0 u = do
-- 	all <- if u=="all" then bernoulli 0.9 else bernoulli 0.2
-- 	output <- if all then return 10 else uniformD range
-- 	return output

-- l1 d u = do
-- 	w <- l0 u
-- 	disemble <- bernoulli d
-- 	let utt = if disemble then "all" else u
-- 	let utility = mass (s0 w) utt
-- 	factor $ realToFrac utility
-- 	return w


-- -- l1_alt d u = do
-- -- 	w <- l0 u
-- -- 	disemble <- bernoulli d
-- -- 	let utt = if disemble then switch utt else utt
-- -- 	let utility = mass (s0 w) utt
-- -- 	factor $ realToFrac utility
-- -- 	return utility

-- switch "all" = "some"
-- switch "some" = "all"

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate


-- -- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- -- main = print . take 5 . fmap (\n -> (mass (l n "some") 10, mass (s n 10) "some")) $ [0..]
-- -- > [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]


