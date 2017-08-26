
module IdentityGrammar where

import Control.Monad
import Control.Monad.Identity
import Control.Monad.Trans.List
import Grammar

type I a = Identity a

lowerI = runIdentity

ranI :: String -> Identity Bool
ranI = parentI

lovesI :: String -> String -> Identity Bool
lovesI x y = return $ loves x y

childI :: String -> Identity Bool
childI = return . (`elem` ["Lisa","Bart", "Maggie"])

parentI :: String -> Identity Bool
parentI = return . (`elem` ["Homer","Marge"])

lisaI :: Identity String
lisaI = return "Lisa"

ex1I :: I Bool
ex1I = do
  x <- return "Homer"
  y <- lisaI
  lovesI y x
