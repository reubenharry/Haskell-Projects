-- we now introduce another side-effect, corresponding to the Writer monad. This is for conventional implicatures:
-- an example: "Homer, a parent, ate a burger": the important phenomenon is that negating this sentence does
-- not negate that Homer is a parent. We can model this, as in ex2W

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

ex2W :: W Bool
ex2W = do
  sentence <- ex1W
  return $ not sentence


