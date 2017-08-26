{-# LANGUAGE TupleSections #-}

import Data.Map as M hiding (filter)
import Control.Monad.Identity
import Control.Monad.Trans.State
import Control.Monad.Trans.Reader
import Control.Applicative

--The Type of Atomic Propositions
data Prop = P | Q | R deriving (Ord, Eq, Show)

--The Type of a Proposition in the Logic
data Expr a = Atom a | Not (Expr a) | And (Expr a) (Expr a) | Box (Expr a) | PA a

--The Set of Possible Worlds
type Dom = [Map Prop Bool]
--The Type of an Assignment Function (maps are like python dictionaries)
type Model = M.Map Prop Bool
--The Type of an Accessibility Relation
type Acc = Model -> Model -> Bool
--The Interpretation Triple
type Interp = (Dom, (Model, Acc))


--the domain
dom = do
  x <- [True,False]
  y <- [True,False]
  z <- [True,False]
  return $ fromList [(P,x),(Q,y),(R,z)]

--example model  
model = fromList [(P,True),(Q,False),(R,True)]
--example accessibility relation
acc x y = (M.lookup P y) == (M.lookup P x) --epistemic knowledge of only P
--acc = const (`elem` dom) -- the loosest accessibility relation
interp = (dom, (model,acc))

--non-monadic mapping from syntax to semantics: doesn't do Box
eval :: Model -> Expr Prop -> Maybe Bool
eval m x = case x of 
  (Atom y) -> M.lookup y (m)
  (Not y) -> fmap not $ eval m y
  (And y z) -> liftA2 (&&) (eval m y) (eval m z)

--reader applicative for modal logic
eval' :: Expr Prop -> ReaderT Interp Maybe Bool
eval' x = case x of 
  (Atom y) -> (ReaderT (\m' -> eval ((fst . snd) m') x))
  (Not y) -> fmap not $ eval' y
  (And y z) -> liftA2 (&&) (eval' y) (eval' z)
  (Box x) -> ReaderT (\m' -> fmap (all (==True)) $ sequence $ fmap (flip eval x) (filter (acc model) dom))


--state monad for dymanic modal logic
eval'' :: Expr Prop -> StateT Interp Maybe Bool
eval'' x = case x of 
  (Atom y) -> (StateT (\m' -> fmap (,m') (eval ((fst . snd) m') x)))
  (Not y) -> fmap not $ eval'' y
  (And y z) -> liftA2 (&&) (eval'' y) (eval'' z)
  (Box x) -> StateT (\m' -> fmap (,m') (fmap (all (==True)) $ sequence $ fmap (flip eval x) (filter (acc model) dom)))
  (PA x) -> (StateT (\m' -> fmap (,(fst m',((adjust (const True) x ((fst . snd) m')),snd $ snd m'))) (eval (adjust (const True) x ((fst . snd) m')) (Atom x))))


--an example of a tautology. and as expected, Box(taut) = Just True
taut = Not (And (Atom P) (Not $ Atom P))
test2 = runReaderT (eval' (Box taut)) interp

--another example
eg = And (Atom P) (Not $ Atom Q)
test = runReaderT (eval' eg) interp

--another example
eg2 = And (PA Q) (And (Atom P) (Atom Q))
eg3 = And (And (Atom P) (Atom Q)) (PA Q)
eg4 = And (PA Q) (Box $ Atom P)

--eg5: unclear meaning
--eg5 = And (Box (PA Q)) (Atom Q))

test3 x = fmap fst $ runStateT (eval'' (x)) interp

