-- {-# LANGUAGE RankNTypes, TypeFamilies, FlexibleContexts, AllowAmbiguousTypes, ImpredicativeTypes #-}

-- import Numeric.LogDomain
-- import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
-- import Control.Monad.Bayes.Enumerator
-- import Text.Parsec

-- module BayesUtils (uniformDraw) where 

uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x