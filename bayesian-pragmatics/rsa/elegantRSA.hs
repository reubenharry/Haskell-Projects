import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator

type Utterance = String
type World = Int
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double World
type Speaker = Integer -> World -> Dist Double Utterance



--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
s :: Speaker
s 0 w = do
	all <- if w==10 then bernoulli 0.9 else bernoulli 0.1
	return (if all then "all" else "some")
s n w = do
	u <- s (n-1) w
	let utility = mass (l (n-1) u) w :: Double
	factor $ realToFrac utility
	return u

l :: Listener
l 0 u = do
	all <- if u=="all" then bernoulli 0.9 else bernoulli 0.2
	output <- if all then return 10 else uniformDraw [1..9]
	return output
l n u = do
    w <- l (n-1) u
    factor $ realToFrac $ (mass (s (n-1) w) u :: Double)
    return w


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
main = print . take 5 . fmap (\n -> (mass (l n "some") 10, mass (s n 10) "some")) $ [0..]
-- > [0.5,0.7499999999999999,0.8999999999999999,0.9878048780487805,0.999847607436757]

uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

