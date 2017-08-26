--ListT used to model focus. The trick is that the head of the list can be thought of as a true value, and its order is always preserved, so
--we get a pointed set monad for free.
--note that an applicative would be just fine here, but we choose a monad.

--module ListTGrammar where

--import Control.Monad.Identity
--import Control.Monad.Trans.State
--import Control.Monad.Trans.List
--import Control.Monad.Trans.Class
--import Grammar
--import IdentityGrammar

--type L a = (ListT Identity) a
--lowerL = lowerI . runListT

--bartL = ListT $ Identity ["Bart","Lisa","Homer"]
--lisaL = ListT $ Identity ["Lisa","Marge"]
--parentL = ListT $ Identity [parent,child]

--lovesL = \x -> \y -> ListT $ Identity [loves x y, not $ loves x y]

--ranL = \x -> ListT $ Identity [ran x, not $ ran x]

--onlyL :: L Bool -> L Bool
--onlyL = (ListT . Identity . (\x -> [x]) . all (==False) . tail . runIdentity . runListT)

--only :: [Bool] -> [Bool]
--only = (\x -> [x]) . all (==False) . tail

--onlyS :: S Bool -> Bool ? : 
--                           a man walked in. HE laughed.
--                           a man walked in. A woman did too. HE laughed.

--                              here it seems as if the focus alternatives are automatically the discourse referents: but maybe this is for the alternative decision process.

--                           with failure:

--                              only the present king of FRANCE walked in.
--                                [m a] -> m [a]: so you sequence and then map only in
--                              only the present king of SPAIN walked in.
--                                I think this should also fail.


--                            clara believes only JOHN is guilty:

--                            everyone only likes someone

--                            only JOHN, a writer, likes cereal. : [(john likes cereal,is a writer),(james likes cereal,is a writer)]

--                            john, who is only a writer...

--                            scope: john only likes someone: 

--                            recursion for the scope issue? 


--only jane and mary won: INTERESTING

--ListT used to model focus. The trick is that the head of the list can be thought of as a true value, and its order is always preserved, so
--we get a pointed list monad for free.

module ListTGrammar where


import Control.Monad.Identity
import Control.Monad.Trans.State
import Control.Monad.Trans.List

import Control.Monad.Trans.Reader
import Control.Monad.Trans.Writer

import Control.Monad.Trans.Class

import Grammar
import IdentityGrammar
import StateTGrammar

type L a = ListT (StateT [String] (ListT Identity)) a
lowerL = lowerS . runListT

--focused value for Bart
bartL :: L String
bartL = mapListT (fmap $ const ["Bart","Lisa"]) $ return ()

--focused value for parent
parentL :: L (String -> Bool)
parentL = mapListT (fmap $ const [parent, child]) $ return ()

--lifted existential quantifier
aL :: (String -> Bool) -> L String
aL = lift . aS

friend :: String -> String 
friend "Bart" = "Lisa"
friend "Lisa" = "Bart"
friend _ = "Homer"

--only :: L Bool -> Bool
--only = sequence . lowerL 

--add alternatives
--foc :: [a] -> L a -> L a
--foc x = mapListT (fmap ((++) x)) $ x

--a parent likes BART
ex1L = do
  y <- aL parent
  x <- bartL
  return $ (loves x) y

--BART loves his friend
--what value/type do we want for triangle bartL? \s -> [(["Bart","Lisa"],)]: nope. alternative: \s -> [ [("Bart","Bart")],[("Lisa","Lisa")] ]
ex2L = do
  x <- (bartL :: L String)
  --y <- lift theyS
  --let z = friend y
  --return $ loves z x
  return $ ran x
--ex2L :: L Bool
--ex2L = do
--  x <- bartL
--  onlyP $ return $ ran x

----NOTE: this order is the one where we consider the dref created by each focus alternative: doesn't seem to empirically be existent. e.g. BART loves a parent. They (the parent
----lisa loves), runs.
--ex3L = do
--  x <- bartL
--  y <- aL parent
--  return $ (loves x) y

----a PARENT loves Bart: this doesn't give the right thing empirically
--ex4L = do
--  x <- parentL
--  y <- aL x
--  return $ (loves "Bart") y



----insane
--ex8P = do
--  x <- parentL
--  y <- bartL
--  z <- aL x
--  return $ (loves y) z

----ex9P = do
----  x <- parentL
----  z <- aP x
----  x' <- parentL
----  z' <- aP x
----  return $ (loves z z')




----lowerD x = (flip runContT return) (x :: F Bool)


----bartF' :: F String
----bartF' = lift $ (ExceptT . ListT . Identity) $ [Right "Homer", Right "Homer"]

----bartE :: E String
----bartE = (ExceptT . ListT . Identity) $ fmap Right $ ["Homer","Bart"]

----bartF :: D String
------bartF = return "Bart"
----bartF = lift $ (ListT . ExceptT . Identity . Right) ["Homer","Homer","Homer"]

----stoppedRunning :: String -> D Bool
----stoppedRunning x = lift $ stoppedRunning' x

----stoppedRunning' :: String -> C Bool
----stoppedRunning' x = if not $ ran x then (ListT . ExceptT . Identity . Left) "presup failure" else return $ child x

----stoppedRunning'' :: String -> E Bool
----stoppedRunning'' x = if not $ ran x then (ExceptT . ListT . Identity) [Left "presup"] else return $ child x

----stoppedRunningF :: String -> F Bool
----stoppedRunningF x = lift $ stoppedRunning'' x

----exL = do
----  --x <- bartF
----  --y <- contOnly x
----  --return $ ran y
----  --return $ loves "Lisa" x
----  x <- bartF'
----  --y <- onlyF x
----  return $ ran x

--onlyP = mapListT (fmap only)

--only = (\x -> [x]) . all (==False) . tail






--ex1L = do
--  x <- bartL
--  ranL x
  
--ex2L = do
--  x <- parentL
--  return $ x "Bart"

--ex3L = do
--  x <- bartL
--  y <- parentL
--  return $ (some y) $ loves x

--ex4L = onlyL $ do
--  x <- bartL
--  return $ ran x

--ex5L = do
--  x <- bartL
--  y <- lisaL
--  lovesL x y