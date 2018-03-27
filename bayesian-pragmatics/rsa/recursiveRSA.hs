-- attempt to perform category theoretic proof that rsa can be embedded in recursive language generation

-- todo:

	-- do the length 2 case to build intuition

import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Control.Monad.Extra

type Utterance = String
type World = Int
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double World
-- type Speaker = [Char] -> Int -> Dist Double Utterance

--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional


correct types:

	s0 :: MonadDist m => (w,[Char]) -> m Char

	hatify :: MonadDist m => ((w,[a]) -> m a) -> ((w,a) -> m [a])

	abstract hatify:

		MonadDist m => (f [a] -> m a) -> (f a -> m [a])




--WRONG
hatify :: MonadDist m => ([b] -> m a) -> (b -> m [a])
hatify f x = liftM2 (:) (f [x]) (fmap repeat (f [x]))

	-- f [x] : ((f [x]) >>= (\x -> hatify f x)) 

pragmatify :: MonadDist m => (b -> m a) -> (b -> m a)
pragmatify = fmap rsa

rsa :: MonadDist m => m a -> m a
rsa = undefined

neuralModel :: MonadDist m => [Char] -> m Char
neuralModel cap = do
	-- a <- if w==1 then bernoulli 0.6 else bernoulli 0.4
	a <- if (head cap)=='0' then bernoulli 0.3 else bernoulli 0.1
	return (if a then '0' else '1')


truePosterior, approximatePosterior :: MonadDist m => ([b] -> m a) -> b -> m [a]
truePosterior = pragmatify . hatify
approximatePosterior = hatify . pragmatify






-- pragmatify . hatify == hatify . pragmatify

-- example case:

-- 	aa : 0.1
-- 	ab ...
-- 	ba
-- 	bb

	


-- hatify $ fmap pragmatify x == 

s0 cap = do
		-- a <- if w==1 then bernoulli 0.6 else bernoulli 0.4
		a <- if (head cap)=='0' then bernoulli 0.3 else bernoulli 0.1
		return (if a then '0' else '1')
		-- ++[if a then "0" else "1"]
		-- (if length cap > 2 then Nothing else Just ((if a then cap++['0'] else cap++['1'])))

-- unrolled_s0 = iterateMaybeM s0

-- l0 (cap,cap)

-- l0 w u = do
-- 	w' <- [1,2,3]
-- 	factor $ realToFrac $ mass (s0 w' u) u
-- 	return w'

-- s n w = do
-- 	u <- s (n-1) w
-- 	let utility = mass (l (n-1) u) w :: Double
-- 	factor $ realToFrac utility
-- 	return u

-- l :: Listener
-- l 0 u = do
-- 	all <- if u=="all" then bernoulli 0.9 else bernoulli 0.2
-- 	output <- if all then return 10 else uniformDraw [1..9]
-- 	return output
-- l n u = do
--     w <- l (n-1) u
--     factor $ realToFrac $ (mass (s (n-1) w) u :: Double)
--     return w


