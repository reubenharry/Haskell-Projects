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




