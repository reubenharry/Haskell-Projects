{-# LANGUAGE FlexibleContexts #-}

module StateTGrammar where

import Control.Monad.Identity
import Control.Monad.Trans.State hiding (put, state, get)
import Control.Monad.Trans.List
import Control.Applicative hiding (some)
import Control.Monad.Trans.Class
import Grammar
import Control.Monad.State

type S a = (StateT [String] (ListT (Identity))) a

aS :: (String -> Bool) -> S String
aS x = StateT $ \s -> ListT $ Identity $ fmap (\y -> (y, y:s)) (filter x simpsons)

--introduces the string as a referent
triangle :: MonadState [String] m => String -> m String
triangle x = do
  put [x]
  return x


lowerS = runIdentity . runListT . flip runStateT []

parentS :: MonadState [String] m => m ((String -> Bool))
parentS = return parent

bartS :: MonadState [String] m => m String
bartS = triangle "Bart"

theyS :: S String
theyS = StateT $ \s -> (ListT . Identity) $ fmap (\x -> (x,s)) s

ifS :: S Bool -> S Bool -> S Bool
ifS x y = do
  x' <- x
  y' <- notS y
  notS $ return $ x' || y'

everyS y x = notS $ do
  z <- aS y
  notS $ x z
  
notS :: S Bool -> S Bool
notS m = StateT $ \s -> ListT $ Identity $ return $ (not $ any (==True) [(True,[s']) `elem` (runStateT m s) | s' <- simpsons], s)


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

ex12S = ifS ex11S ex11bS

ex22S = notS ex2S


ex13S = (everyS child) (return . ran)

