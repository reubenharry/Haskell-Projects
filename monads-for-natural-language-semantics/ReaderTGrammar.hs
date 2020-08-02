-- add the reader monad to model intensionality: the idea is that the sentence takes scope over the model, so
-- we can make statements like: [in all models, P], e.g. "It must be the case that Lisa laughed"

{-# LANGUAGE FlexibleContexts #-}

module ReaderTGrammar where


import Control.Monad.Trans.Reader
import Control.Monad.Trans.Writer
import Control.Monad.Trans.Cont
import Control.Monad.Trans.State hiding (put,get,state)
import Control.Monad.Trans.List 
import Control.Monad.Trans.Except
import Grammar
import Control.Monad.Cont
import Control.Monad.Identity
import Data.List
import Data.Map
import WriterTGrammar
import Prelude hiding (log)
import Control.Monad.Writer
import ListTGrammar
import StateTGrammar
import WriterTGrammar
import ExceptTGrammar
import Control.Monad.State

type R a = ReaderT Int (ExceptT String (WriterT [Bool] (ListT (StateT [String] ((ListT Identity)))))) a

basicMust :: R Bool -> M Bool
basicMust x = fmap (all (== True)) $ sequence $ fmap (runReaderT x) [1,2,3,4,5,6]

lowerR = lowerM . flip runReaderT (0 :: Int)

lisaR :: R String
lisaR = ReaderT lisaR'
lisaR' :: Int -> M String
lisaR' 1 = return "Bart"
lisaR' 2 = return "Homer"
lisaR' _ = return "Lisa"
--childR :: String -> R String
--childR = ReaderT . childR'
--childR' :: String -> Int -> M Bool
--childR' "Bart" 1 = return True
--childR' "Bart" 2 = return False
--childR' _ = return "False"

ex1R :: R Bool
ex1R = do
  x <- lisaR
  return $ ran x

--g and s: someone is running. they might be Lisa.
ex10R :: R Bool
ex10R = do
  y <- aR (`elem` simpsons)
  return $ ran y
ex11R :: R Bool
ex11R = might [1,2,3] $ do
  y <- theyR
  x <- lisaR
  return $ x == y
ex12R :: R Bool
ex12R = might [1,2,3] $ do
  y <- theyR
  return $ "Lisa" == y

--belief in its two scopes
ex2R :: R Bool
ex2R = believes (ex1R) "Homer"
ex3R :: R Bool
ex3R = do
  x <- lisaR 
  believes (return $ ran x) "Homer"

--reader and focus: things are still a bit unclear here
ex4aR = do
  x <- bartR
  return $ ran x
ex4bR :: R Bool
ex4bR = do
  x <- bartR
  believes (return $ ran x) "Homer"
ex4cR :: R Bool
ex4cR = do
  x <- bartR
  believes (ex4aR) "Homer"

--reader and state:
--a parent ran. they believe lisa ran.
ex5aR = do
  x <- aR parent
  return $ ran x
ex5bR = do
  x <- theyR
  believes (ex1R) x
--homer believes a parent ran
ex6R = believes (ex5aR) "Homer"

--reader and writer
--Homer believes Lisa, a parent, ran

ex7aR = do
  x <- lisaR
  y <- commaW parent x
  return $ ran y
ex7R = do
  believes (ex7aR) "Homer"
 
--except and reader: presupposition holes
--homer believes lisa stopped running
ex8aR = do
  x <- lisaR
  stoppedRunningR x
ex8bR = do
  x <- lisaR
  believes (stoppedRunningR x) "Homer"
ex8cR = do
  believes (ex8aR) "Homer"


ex9aR = do
  x <- lisaR
  y <- return "Homer"
  return (x == y ) 


ex9R = believes ((return "Bart") >>= (\a -> (lisaR >>= (\b -> return  (a == b))))) "Homer"

ex9bR = do
  x <- return "Bart"
  y <- lisaR 
  believes (return (x == y)) "Homer"

foo x = do
  y <- lisaR
  return $ x == y

ex9cR = do
  y <- return "Bart" 
  believes (lisaR >>= (\x -> return $ x == y)) "Homer"



stoppedRunningR = lift . stoppedRunning

aR :: (String -> Bool) -> R String
aR = lift . lift . lift . lift . aS
theyR :: R String
theyR = lift $ lift $ lift $ lift $ theyS

bartR :: R String
bartR = lift $ lift $ lift $ lift $ bartS

--the belief worlds of each entity
believes' "Homer" = [1,2]
believes' _ = [0]

believes :: R Bool -> String -> R Bool
believes b x = lift $ fmap (all (==True)) $ sequence $ fmap (runReaderT b) (believes' x)


must :: [Int] -> R Bool -> R Bool
must i w = lift $ fmap (all (==True)) $ sequence $ fmap (runReaderT w) i

might :: [Int] -> R Bool -> R Bool
might i w = lift $ fmap (any (==True)) $ sequence $ fmap (runReaderT w) i

--john must run
--john might run
--john might RUN
--a woman walks in. jane might love her.
--john, a simpson, might walk in.
--john might be the king of france.
--everyone might run
--someone must know everyone.
--john could be taller than he is.


