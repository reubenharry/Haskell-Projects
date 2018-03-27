--  irony as countersignalling: one is ironic in situations where one wants listener to infer that shared world is so
-- obviously foo that one can describe it as blah and still know

-- AHA: so intercept can sort of be thought of as whether the speaker is cray or not: but then speaker can use this
-- and PRETEND to be cray, knowing that listener will ignore this
-- however, this strategic use of noise (figuratively speaker) allows for next speaker to say opposite of truth, so long
-- as it's sufficiently unlikely, since then the listener will assume cray:
	-- the utility is that the speaker then gets listener to infer that the world must be 



import Numeric.LogDomain
import Control.Monad (liftM2,replicateM)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Data.List
import Data.Function




--  whether the talk is good
data World = Int
	-- OldMoney | NewMoney | Poor
type Utterance = World

-- cond dist params for how good speaker thinks talk is, given that it's foo good
-- type Speaker_Intercept = Double
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances

-- s0 :: [Double] -> World 

-- so we first need to set up the following s0:

-- 	if you're a 1, you signal that
-- 	if you're a 2, you signal that
-- 	if you're a 3, you signal that
l0 :: [Double] -> Int -> Dist Double Int
l0 cat u = do
	w <- categorical $ zip [1,2,3] cat
	factor $ realToFrac $ if w==u then 0.9 else 0.1
	return w
s1 :: [Double] -> Int -> Dist Double Int
s1 cat w = do
	u <- uniformD [1,2,3]
	factor $ realToFrac $ mass (l0 cat u) w
	return u
l1 :: Int -> Dist Double ([Double],Int)
l1 u = do
	-- cat <- replicateM 3 (uniformD [0.1,0.9])
	cat <- uniformD [[0.8,0.1,0.1],[0.85,0.05,0.1]]
	-- w <- categorical $ zip [1,2,3] [0.7,0.2,0.1]
	w <- categorical (zip [1,2,3] cat)
	-- mass (s1 cat w) u
	factor $ realToFrac $ mass (s1 cat w) u
	-- return (mass (s1 cat w) u)
	return (cat,w)

-- s2 :: [Double] -> Int -> Dist Double Int
-- s2 cat w = do
-- 	u <- s1 cat w
-- 	factor $ realToFrac $ mass (l1 u) (cat,w)
-- 	return u
-- s0 (a:b:c:d:e:f:g:h:i:[]) w = do 
-- 	let joint_dist = categorical [((1,1),a),((1,2),b),((1,3),c),((2,1),d),((2,2),e),((2,3),f),((3,1),g),((3,2),h),((3,3),i)]
-- 	(w',u) <- joint_dist
-- 	factor $ realToFrac $ mass joint_dist (w,u)
-- 	return u

-- l0 (a:b:c:d:e:f:g:h:i:[]) u = do 
-- 	let joint_dist = categorical [((1,1),a),((1,2),b),((1,3),c),((2,1),d),((2,2),e),((2,3),f),((3,1),g),((3,2),h),((3,3),i)]
-- 	(w,u') <- joint_dist
-- 	factor $ realToFrac $ mass joint_dist (w,u)
-- 	return w


-- s1 cat w = do
-- 	u <- s0 cat w
-- 	factor $ realToFrac $ mass (l0 cat u) w
-- 	return u

-- s0 binomial_param w = do 
-- 	let joint_dist = binomial 2 binomial_param
-- 	(u,w') <- joint_dist
-- 	factor $ realToFrac $ mass joint_dist (u,w)
-- 	return u

-- l0 binomial_param u = do 
-- 	let joint_dist = binomial 2 binomial_param
-- 	(u',w) <- joint_dist
-- 	factor $ realToFrac $ mass joint_dist (u,w)
-- 	return u

-- s1 cat w = do
-- 	u <- s0 cat w
-- 	factor $ realToFrac $ mass (l0 cat u) w
-- 	return u

-- s0 binomial_param = binomial 2 binomial_param
-- l0 binomial_param u = binomial 2 binomial_param
-- 	-- w <- binomial binomial_param
-- 	-- factor $ realToFrac $ mass (s0 binomial_param) u

-- s1 binomial_param w = do
-- 	u <- s0 binomial_param
-- 	factor $ realToFrac $ mass (l0 binomial_param u) w
-- 	return u


-- l1 u = do
-- 	binomial_param <- uniformD [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
-- 	w <- l0 binomial_param u
-- 	factor $ realToFrac $ mass (s1 binomial_param w) u
-- 	return (binomial_param,w)
-- s2 binomial_param w = do

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate


-- -- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- -- main = print . take 5 . fmap (\n -> (mass (l n "some") 10, mass (s n 10) "some")) $ [0..]
-- -- > [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]


