--presupposition failure: we use the Except monad to model when a presupposition fails, as in: "The current king of 
  -- France is bald": we don't want either this or its negation to be true of false. We want an error to be thrown.


module ExceptTGrammar where

import Grammar
import Control.Monad
import Control.Monad.Trans.Except
import Control.Monad.Trans.List
import Control.Monad.Trans.State
import Control.Monad.Trans.Writer
import Control.Monad.Trans.Class
import Control.Monad.Identity
import StateTGrammar
import ListTGrammar
import WriterTGrammar

type M a = ExceptT String (WriterT [Bool] (ListT (StateT [String] ((ListT Identity))))) a

lowerM = lowerW . runExceptT

--Bart stopped running
ex1M :: M Bool
ex1M = do
  x <- return "Bart"
  stoppedRunning x

--interaction with focus
--BART stopped running
ex2M :: M Bool
ex2M = do
  x <- lift $ lift bartL
  stoppedRunning x

--interaction with writer:
--Bart, a child, stopped running.
ex3M :: M Bool
ex3M = do
  x <- commaW child "Lisa"
  stoppedRunning x

--Bart loves Homer, who loves both simpsons 
ex8M :: M Bool
ex8M = do
  x <- bothM (`elem` simpsons)
  let z = \f -> x (loves f)
  y <- commaW z "Bart"
  return $ (ran "Bart")

ex8bM :: M Bool
ex8bM = do
  y <- commaW (`elem` simpsons) "Homer"
  x <- bothM child
  return $ x (loves y)

--interaction with state: note: can't yet do full interaction, cause it needs continuations
--A child stopped running.
ex4M :: M Bool
ex4M = do
  x <- aM child
  return $ loves "Homer" x
ex5M :: M Bool
ex5M = do
  x <- theyM
  stoppedRunning x
--exb5M :: M Bool
--ex5bM = do
--  x <- aM child
--  stoppedRunning x

--both children ran
ex6M :: M Bool
ex6M = do
  x <- bothM child
  return $ x ran

--both PARENTs saw themselves, a child
ex7M :: M Bool
ex7M = do
  x <- return parent
  y <- aM x
  w <- theyM
  z <- commaW child w
  return $ loves z y



--all effects at once
ex9M = do
  w <- theyM
  x <- return parent
  z <- commaW x w
  stoppedLoving z z

ex10M = do
  x <- (husbandOf "Marge")
  stoppedLoving "Bart" x

--lifted focused parent

theyM :: M String
theyM = lift $ lift $ lift theyS
aM :: (String -> Bool) -> M String
aM = (lift . lift . lift) . aS


bothM :: (String -> Bool) -> M ((String -> Bool) -> Bool)
bothM x = mapExceptT (fmap (>>= foo)) ((return $ every x) :: M ((String -> Bool) -> Bool)) where foo y = if ((length $ filter x simpsons) /= 2) then Left "fail" else Right y

stoppedRunning :: Monad m => String -> ExceptT String m Bool
stoppedRunning x = if ran x then ExceptT $ return $ Right $ stoppedRunning' x else ExceptT $ return $ Left ("presupposition failure: " ++ x ++ " never ran")
stoppedLoving :: Monad m => String -> String -> ExceptT String m Bool
stoppedLoving x y = if loves x y then ExceptT $ return $ Right $ stoppedLoving' x y else ExceptT $ return $ Left ("presupposition failure: " ++ y ++ " never loved " ++ x) 

stoppedRunning' = (`elem` ["Marge","Maggie"])
stoppedLoving' = curry (`elem` (fmap switch [("Lisa","Bart"), ("Bart", "Bart"),("Maggie", "Bart"),("Maggie", "Homer"),("Marge", "Homer")])) where switch (x,y) = (y,x)


stopped :: Monad m => (String -> String -> Bool) -> String -> String -> ExceptT String m Bool
stopped z x y = if z x y then ExceptT $ return $ Right $ parent x else ExceptT $ return $ Left "presup failure" 

husbandOf :: String -> M String
husbandOf "Marge" = ExceptT $ return $ Right "Homer"
husbandOf _ = ExceptT $ return $ Left "They don't have a husband."
