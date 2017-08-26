{-# LANGUAGE FlexibleContexts #-}

----we stack state and list both onto the stack: we do both at the same time because their functionality corresponds jointly to dynamic semantics
----note that our monad is no longer commutative: there are currently some serious implementation errors with state here

----problem: it is only the case that a parent loves BART

----interaction of alternative list and dref list: focus on HE presumably requires that focus depends on dref. but focus on a PERSON presumably requires the opposite.

module StateTGrammar where

import Control.Monad.Identity
import Control.Monad.Trans.State hiding (put, state, get)
import Control.Monad.Trans.List
import Control.Applicative hiding (some)
--import ListT

import Control.Monad.Trans.Class
import Grammar
import Control.Monad.State
--import Control.Monad.List

type S a = (StateT [String] (ListT (Identity))) a


--notS has to contain dref introduction:
--It is not the case that a woman saw Bart. 
--why can't this bind the other way?? see charlow
--but note: it is not the case that bart ran. He laughed
--it is not the case that a child laughed. they ...: child creates plural dref, but ``a'' doesn't
--notS :: S Bool -> S Bool


--aS :: (String -> Bool) -> S ((String -> Bool) -> Bool)
-- aS x = fmap (const $ some x) $ StateT $ \s -> ListT $ Identity $ fmap (\y -> (True, y:s)) (filter x simpsons)
--notS :: S Bool -> S Bool
--notS x = 


aS :: (String -> Bool) -> S String
aS x = StateT $ \s -> ListT $ Identity $ fmap (\y -> (y, y:s)) (filter x simpsons)

--introduces the string as a dref
triangle :: MonadState [String] m => String -> m String
triangle x = do
  put [x]
  return x
-- every x = do


lowerS = runIdentity . runListT . flip runStateT []

--onlyS :: S a -> S a
--he RAN: [[Jim ran, Matt ran], [Jim laughed, Matt laughed]]:
--transpose: [[jim ran, jim laughed], [matt ran, matt laughed]
--output: [[True,False]]
--he only HIT BILL: works the same
--only(HE hit bill): [[John hit bill, Mark hit bill],[Jim hit bill, Matt hit bill]]: he : john, mark. f john: jeremy, james, jim. f mark: mitt
      --[[john h, mark h], [jeremy h, mitt h], [john h, mark h],[john h, mark h]]
  --oh dear, looks like nondet has to be on the outside, no?
  --what about the other half of state?
    --a parent LAUGHS
    --a PARENT laughs: seems like this requires the current order:
      --i.e. [[(a parent laughs,[Homer]), (a parent laughs,[Marge])],[(a child laughs, [Bart]),(a child laughs, [Lisa])]]
  --why can't list be outside state?
--onlyS = 

parentS :: MonadState [String] m => m ((String -> Bool))
parentS = return parent
  --lift parentL

bartS :: MonadState [String] m => m String
bartS = triangle "Bart"

theyS :: S String
theyS = StateT $ \s -> (ListT . Identity) $ fmap (\x -> (x,s)) s

ex1S = do
  y <- aS parent
  return $ ran y

ex1aS = notS ex1S

ex2S = do
  x <- theyS
  return $ (=="Homer") x


--A parent loves themselves
ex3S = do
  y <- aS parent
  x <- theyS
  return $ loves x y

--interaction with focus
--note that binding order matters, but doesn't make a semantic difference
ex4S = do
  x <- bartS
  y <- aS parent
  return $ (loves x) y

ex4bS = do
  y <- aS parent
  x <- bartS
  return $ (loves x) y

ex4cS = some parent (loves "Bart")

ex5S = do
  x <- bartS
  y <- aS parent
  return $ (loves x) y

----a PARENT loves Bart
ex6S = do
  x <- parentS
  y <- aS x
  return $ (loves "Bart") y

--a PARENT loves BART
ex7S = do
  x <- parentS
  z <- aS x
  y <- bartS
  return $ (loves y) z

ex8aS = do
  x <- aS parent
  return $ ran x
ex8bS = do
  y <-theyS
  x <- bartS
  return $ loves x y

ex9S = do
  y <- parentS
  x <- aS y
  return $ ran x

ex10S = do
  y <- bartS
  x <- aS child
  return $ (loves y) x

ex11S = do
  y <- aS parent
  x <- aS child
  return $ loves x y

ex11bS = do
  x <- theyS
  return $ x == "Homer" 
--todo: add focused THEY:


--module StateTGrammar where

--import Control.Monad.Identity
--import Control.Monad.Trans.State
--import Control.Monad.Trans.List
--import Control.Monad.Trans.Class
--import Grammar
--import ListTGrammar

--type S a = (StateT [String] (ListT (ListT Identity))) a


----notS has to contain dref introduction:
----It is not the case that a woman saw Bart. 
----why can't this bind the other way?? see charlow
----but note: it is not the case that bart ran. He laughed
----it is not the case that a child laughed. they ...: child creates plural dref, but ``a'' doesn't
--everyoneS :: S String
--everyoneS = mapStateT notS $ do
--  x <- aS (`elem` simpsons)
--  notS $ return x

ex12S = ifS ex11S ex11bS

ex22S = notS ex2S

ifS :: S Bool -> S Bool -> S Bool
ifS x y = do
  x' <- x
  y' <- notS y
  notS $ return $ x' || y'

--notS :: S Bool -> S Bool
--notS y = a $ do 
--  x <- return not
--  z <- y
--  return $ x z
--a  =  mapStateT $ fmap comb

--everyS :: (String -> Bool) -> (String -> Bool) -> S String
everyS y x = notS $ do
  z <- aS y
  notS $ x z

ex13S = (everyS child) (return . ran)

--ex14S = do
--  --everyS (liftA2 (&&) parent (\x -> loves ))
--  every

b :: Bool -> S Bool 
b a = StateT (\s -> ListT $ Identity $ [(not a,s)] )

--notS x = do
--  x' <- x
--  put []
--  b x'


--foo = not $ any (==True) [(True,s') `elem` (runStateT m s) | s' <- simpsons]

notS :: S Bool -> S Bool
notS m = StateT $ \s -> ListT $ Identity $ return $ (not $ any (==True) [(True,[s']) `elem` (runStateT m s) | s' <- simpsons], s)
--notS' 
--aS :: (String -> Bool) -> S ((String -> Bool) -> Bool)
--aS x = fmap (const $ some x) $ StateT $ \s -> ListT $ ListT $ Identity $ (\z -> [z]) $ fmap (\y -> (True, y:s)) (filter x simpsons)


--lowerS = runIdentity . runListT . runListT . flip runStateT []

----onlyS :: S a -> S a
----he RAN: [[Jim ran, Matt ran], [Jim laughed, Matt laughed]]:
----transpose: [[jim ran, jim laughed], [matt ran, matt laughed]
----output: [[True,False]]
----he only HIT BILL: works the same
----only(HE hit bill): [[John hit bill, Mark hit bill],[Jim hit bill, Matt hit bill]]: he : john, mark. f john: jeremy, james, jim. f mark: mitt
--      --[[john h, mark h], [jeremy h, mitt h], [john h, mark h],[john h, mark h]]
--  --oh dear, looks like nondet has to be on the outside, no?
--  --what about the other half of state?
--    --a parent LAUGHS
--    --a PARENT laughs: seems like this requires the current order:
--      --i.e. [[(a parent laughs,[Homer]), (a parent laughs,[Marge])],[(a child laughs, [Bart]),(a child laughs, [Lisa])]]
--  --why can't list be outside state?
----onlyS = 

--parentS :: S (String -> Bool)
--parentS = lift . lift $ parentL

--bartS :: S String
--bartS = lift $ lift bartL

--theyS :: S String
--theyS = StateT $ \s -> (ListT . ListT . Identity) $ fmap (\y -> [y]) $ fmap (\x -> (x,s)) s

--ex1S = do
--  y <- aS child
--  return $ y ran

--ex2S = do
--  x <- theyS
--  return $ ran x


----A parent loves themselves
--ex3S = do
--  y <- aS parent
--  x <- theyS
--  return $ y $ loves x

----interaction with focus
----note that binding order matters, but doesn't make a semantic difference
--ex4S = do
--  x <- bartS
--  y <- aS parent
--  return $ y (loves x)

--ex4bS = do
--  y <- aS parent
--  x <- bartS
--  return $ y (loves x)

--ex4cS = some parent (loves "Bart")

--ex5S = do
--  x <- bartS
--  y <- aS parent
--  return $ y (loves x)

------a PARENT loves Bart
--ex6S = do
--  x <- parentS
--  y <- aS x
--  return $ y (loves "Bart")

----a PARENT loves BART
--ex7S = do
--  x <- parentS
--  z <- aS x
--  y <- bartS
--  return $ z (loves y)

--ex8aS = do
--  x <- aS parent
--  return $ x ran
--ex8bS = do
--  y <-theyS
--  x <- bartS
--  return $ loves x y

--ex9S = do
--  y <- parentS
--  x <- aS y
--  return $ x ran

--ex10S = do
--  y <- bartS
--  x <- aS child
--  return $ x (loves y)

----todo: add focused THEY:
