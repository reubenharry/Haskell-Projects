{-# LANGUAGE FlexibleContexts #-}


module WriterTGrammar where

import Control.Monad.Trans.Writer hiding (writer)
import Grammar
import Control.Monad.Cont
import Control.Monad.Trans.Cont
import Control.Monad.Identity
import Control.Monad.Trans.State
import Control.Monad.Trans.List
import Control.Monad.Trans.Except
import StateTGrammar
--import ListTGrammar
import Control.Monad.State
import Control.Monad.Writer
import ListTGrammar

type W a = WriterT [Bool] (ListT (StateT [String] (ListT Identity))) a
lowerW = lowerL . runWriterT

aW :: (String -> Bool) -> W String
aW = lift . lift . aS 
commaW :: MonadWriter [Bool] m => (String -> Bool) -> String -> m String
commaW x y  = writer (y, [x y])


--a child loves Homer, a parent
ex1W :: W Bool
ex1W = do
  y <- return "Bart"
  x <- commaW parent "Homer"
  return $ teases x y

--notW = 

--they love lisa, a child
--ex2W = do
--  x <- theyW
--  y <- commaW child "Lisa"
--  return $ loves y x

----interaction of writer with focus
----BART, a child, ran
--ex4W = do
--  x <- lift $ lift bartS
--  y <- commaW child x
--  return $ ran y
--ex4bW = do
--  x <- lift $ lift parentS
--  y <- commaW x "Bart"
--  return $ ran y
--ex4cW = do
--  x <- lift $ lift bartS
--  y <- commaW child "Homer"
--  return $ loves x y
----bart loves homer, a PARENT
--ex5W = do
--  x <- parentPW
--  z <- commaW x "Homer"
--  return $ (loves z "Bart")
--ex5bW = do
--  x <- lift $ lift bartS
--  let z = \f -> (loves f x)
--  y <- commaW z "Homer"
--  return $ (loves y "Lisa")
----interaction of writer with state:
----bart loves homer, who a parent loves
--ex7W = do
--  x <- aW parent
--  let z = \f -> (loves f) x
--  y <- commaW z "Homer"
--  return $ (loves y "Bart")

----bart, who a parent loves, ran
--ex7bW = do
--  x <- aW parent
--  let z = \f -> (teases f) x
--  y <- commaW z "Bart"
--  --w <- theyW
--  return $ ran y
----state,writer,focus:
---- a PARENT loves Homer, a PARENT
--ex6W = do
--  x <- parentPW
--  y <- aW x
--  z <- commaW x "Homer"
--  return $  (loves z) y

----nested: bart, whom maggie, a child, teases, ran.
--ex8W = do
--  x <- commaW child "Maggie"
--  let z = \f -> (teases f) x
--  y <- commaW z "Bart"
--  --w <- theyW
--  return $ ran y


