-- todo: code to calculate mutual information and show that 

-- BREAKTHROUGH: double base case rsa is necessary here: l1 infers a p(u,w) where
		-- u==w is highly weighted, by performing inference over both s0 and l0 jointly

	--  the natural language world is full of much more complex iconicities, which can be accessed by deep 
		--  learning: full isomorphism not possible between the types, because they aren't isomorphic:

			--  there's a thing we can do where we create a simple isomorphism between subspaces:
				--  this is art



	--  ah yes, the hope is to show that over the course of a large set of data, a listener (/speaker)
	-- will infer a joint distribution p(u,w) with low mutual information
		-- such that one could believe that p(w) and p(u) capture all there is to say

	-- or: the hope is to show that factoring by u==w does practically nothing to p(u,w) and thus
		--  that p(u,w) is not inferred at all, but rather exists absolutely

import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Control.Monad.Bayes.Inference
import Control.Monad
import Data.List
import Data.Function

type Utterance = Bool
type World = Bool
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
-- type Listener = (Integer) -> Utterance -> Dist Double World
-- type Speaker = Integer -> World -> Dist Double Utterance


-- s0 :: (Real a, NumSpec a) => (a, a) -> Bool -> Dist a Bool
-- l0 :: (Real a, NumSpec a) => (a, a) -> Bool -> Dist a Bool
--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
-- rewrite using applicative
-- construct_joint tup = do
-- 	x <- bernoulli $ fst tup
-- 	y <- bernoulli $ snd tup
-- 	return (x,y)

-- s0 :: Speaker
-- l0 :: Listener
-- list_to_four_tuple l = (x:y:z)

s 0 (a:b:c:d:[]) w = do
	-- let (a,b,c,d) = joint
	-- j' <- if j then bernoulli 0.9 else bernoulli 0.1 
	-- [(True,True),(True,False)] else uniformD [(False,True),(False,False)]
	-- let joint_dist = if j then uniformD [(True,True),(False,False)] else uniformD [(False,True),(True,False)]
	let joint_dist = categorical [((True,True),a),((True,False),b),((False,True),c),((False,False),d)]

	(u,w') <- joint_dist
	-- let joint_dist = construct_joint joint 
	-- u <- bernoulli 0.6
	-- w' <- bernoulli 0.7
	factor $ realToFrac $ mass joint_dist (u,w)
	return u

s n j w = do
	u <- s (n-1) j w
	factor $ realToFrac $ mass (l (n-1) j u) w
	return u

l 0 (a:b:c:d:[]) u = do
	-- let joint_dist = construct_joint joint 
	-- (u',w) <- joint_dist
	-- j' <- if j then bernoulli 0.9 else bernoulli 0.1 
	-- [(True,True),(True,False)] else uniformD [(False,True),(False,False)]
	-- let joint_dist = if j then uniformD [(True,True),(False,False)] else uniformD [(False,True),(True,False)]
	let joint_dist = categorical [((True,True),a),((True,False),b),((False,True),c),((False,False),d)]
	(u',w) <- joint_dist
	factor $ realToFrac $ mass joint_dist (u,w)
	return w

l n j u = do
	w <- l (n-1) j u
	factor $ realToFrac $ mass (s (n-1) j w) u
	return w

-- s1 w = do
-- 	joint <- replicateM 4 (uniformD [0.1,0.9])
-- 	u <- uniformD [True,False]
-- 	-- s0 joint w
-- 	factor $ realToFrac $ mass (l0 joint u) w
-- 	return joint

-- can we write general arrow form such that dual comes for free?:
	-- 

joint_prior = do
	x <- bernoulli 0.45
	return (if x then [0.4,0.1,0.1,0.4] else [0.35,0.15,0.15,0.35])
	-- uniformD [[0.35,0.15,0.15,0.35],[0.4,0.1,0.1,0.4]] 
-- [[0.3,0.5,0.1,0.1],[0.5,0.3,0.1,0.1],[0.4,0.4,0.1,0.1],[0.4,0.4,0.15,0.05],[0.1,0.1,0.4,0.4]]
-- [0.35,0.15,0.15,0.35]
-- joint_prior = replicateM 4 (uniformD [0.1,0.9])

s_final n w = do
	-- joint <- uniformD [True,False]
	-- joint <- categorical [(True,0.5),(False,0.5)]
	-- let joint_dist = if j then uniformD [(True,True),(False,False)] else uniformD [(False,True),(False,True)]
	-- let joint_dist = if joint then uniformD [(True,True),(False,False)] else uniformD [(False,True),(True,False)]
	joint <- joint_prior
	-- replicateM 4 (uniformD [0.1,0.9])
	-- let (a:b:c:d:[]) = joint
	-- let joint_dist = categorical [((True,True),a),((True,False),b),((False,True),c),((False,False),d)]
	-- (u',w') <- joint_dist
	-- w <- uniformD [True,False]
	u <- (s n) joint w
	factor $ realToFrac $ (mass ((l n) joint u) w :: Double)
	return (joint,u)

l_final n u = do
	-- joint <- uniformD [True,False]
	-- joint <- categorical [(True,0.5),(False,0.5)]
	-- let joint_dist = if j then uniformD [(True,True),(False,False)] else uniformD [(False,True),(False,True)]
	-- let joint_dist = if joint then uniformD [(True,True),(False,False)] else uniformD [(False,True),(True,False)]
	joint <- joint_prior
	-- let (a:b:c:d:[]) = joint
	-- let joint_dist = categorical [((True,True),a),((True,False),b),((False,True),c),((False,False),d)]
	-- (u',w') <- joint_dist
	-- w <- uniformD [True,False]
	w <- (l n) joint u
	factor $ realToFrac $ (mass ((s n) joint w) u :: Double)
	return (joint,w)

display :: (Ord a, NumSpec a1, Real a1) => Dist a1 a -> [(a, a1)]
display = sortBy (flip compare `on` (snd)) . enumerate

-- calculate_mutual_info d1 = let en = enumerate d1 in fmap (\x -> (snd x) / ((mass (marg 0 d1) (fst (fst x)))*(mass (marg 1 d1) (snd (fst x))))  ) en

-- lift_to_joint (a:b:c:d:[]) = categorical [((True,True),a),((True,False),b),((False,True),c),((False,False),d)]

-- -- enum_to_probs = fmap snd

-- full l = Data.List.sum $ zipWith (*) (fmap snd $ enumerate $ lift_to_joint l) (fmap log $ calculate_mutual_info $ lift_to_joint l)

-- marg 0 x = do 
-- 	(a,b) <- x
-- 	return a
-- marg 1 x = do 
-- 	(a,b) <- x
-- 	return b
-- 	(x,y) <- d1
-- 	return (x/(x*y),y/(x*y))

-- s n w = do
-- 	u <- s (n-1) w
-- 	let utility = mass (l (n-1) u) w :: Double
-- 	factor $ realToFrac utility
-- 	return u

-- l :: Listener
-- l 0 u = do
-- 	all <- if u=="all" then bernoulli 0.9 else bernoulli 0.2
-- 	output <- if all then return 10 else uniformD [1..9]
-- 	return output
-- l n u = do
--     w <- l (n-1) u
--     factor $ realToFrac $ (mass (s (n-1) w) u :: Double)
--     return w


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
-- main = print . take 5 . fmap (\n -> (mass (l n "some") 10, mass (s n 10) "some")) $ [0..]
-- > [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]


