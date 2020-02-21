{-# LANGUAGE GeneralizedNewtypeDeriving #-}


module ContTGrammar where

import Grammar
import ListTGrammar
import StateTGrammar
import WriterTGrammar
import ExceptTGrammar
import ReaderTGrammar

import Control.Monad.Trans.Reader
import Control.Monad.Trans.Writer hiding (tell, writer, listen)
import Control.Monad.Trans.Cont
import Control.Monad.Trans.State hiding (put)
import Control.Monad.Trans.List 
import Control.Monad.Trans.Except
import Control.Monad.Cont
import Control.Monad.Identity
import Data.List
import Prelude hiding (log)
import Control.Monad.Writer
import Control.Monad.State

type C a = ContT Bool (ReaderT Int (ExceptT String (WriterT [Bool] (ListT (StateT [String] ((ListT Identity))))))) a


lowerC = lowerR . flip runContT (return :: Bool -> R Bool)

--charlow's reset which is a retract of the continuation, to limit its scope at the main clause level
reset = ContT . ((>>=) :: R a -> (a -> R b ) -> R b) . flip runContT return


ex1C = do
  x <- everyC child
  return $ loves x "Bart"

-- ex1bC = do
--   x <- everyC' parent
--   return $ loves x "Bart"

-- ex1cC = notC' $ do
--   x <- aC child
--   return $ loves x "Bart"

ex2aC = do
  x <- everyC parent
  y <- someC child
  return $ loves y x
ex2bC = do
  y <- someC child
  x <- everyC parent
  return $ loves y x

--interaction with focus
--every parent loves BART: 
ex3C = do
  x <- bartC
  y <- everyC parent
  return $ loves x y
ex3bC = do
  y <- everyC parent
  x <- bartC
  return $ loves x y

ex4C = do
  z <- parentS
  y <- everyC z
  x <- someC child
  return $ loves x y

--interaction with state
--a parent walked in and she laughed.

-- ex5C = do
--   x <- notC "Maggie"
--   return $ ran x

ex6aC = do
  x <- aC child
  return $ ran x
ex6bC = do
  x <- theyC
  return $ (teases "Bart") x
ex6cC = andC ex6aC ex6bC




ex7C :: C Bool
ex7C = do
  y <- lift $ commaW child "Homer"
  return $ ran y

ex8C = do
  x <- everyC (`elem` simpsons)
  y <- lift $ commaW ran x
  return $ parent y

ex9aC = do
  y <- someC child
  x <- everyC parent
  return $ loves x y

ex9cC = do
  x <- someC child
  return $ ran x

commaW' :: (String -> W Bool) -> String -> W String
commaW' x y = do
  z <- x y
  writer (y, [z])



theyC :: C String
theyC = (lift . lift . lift . lift . lift) theyS


bartC :: C String
bartC = lift . lift . lift .lift $ bartL


aC :: (String -> Bool) -> C String
aC = (lift) . aR

foobar = lift $ aR (`elem` simpsons)

test :: C Bool
test = do
  x <- everyC (`elem` simpsons)
  y <- foobar
  return $ loves y x


someC :: (String -> Bool) -> C String
someC = ContT . some' where some' y x = fmap (any (==True)) $ sequence $ fmap x (filter y simpsons)

everyC :: (String -> Bool) -> C String
everyC = ContT . some' where some' y x = fmap (all (==True)) $ sequence $ fmap x (filter y simpsons)


--needs lifting
-- everyC' :: (String -> Bool) -> C String
-- everyC' = ContT . everyC''

-- everyC'' y x = notC' $ do
--   z <- aR y
--   notC' $ x z


notC :: a -> C a
notC x = ContT $ \y -> fmap not $ y x  

andC x y = do
  x' <- x
  y' <- y
  andC' x' y'

andC' :: a -> a -> C a
andC' a b = ContT $ (\y -> fmap (all (==True)) $ sequence $ fmap y [a, b])



