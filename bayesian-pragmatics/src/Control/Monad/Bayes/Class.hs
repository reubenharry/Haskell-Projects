{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances,FlexibleContexts,TupleSections #-}

{-|
Module      : Control.Monad.Bayes.Class
Description : Types for probabilistic modelling
Copyright   : (c) Adam Scibior, 2016
License     : MIT
Maintainer  : ams240@cam.ac.uk
Stability   : experimental
Portability : GHC

-}

{-# LANGUAGE
  GADTs
 #-}


module Control.Monad.Bayes.Class (
  module Statistics.Distribution.Polymorphic.Class,
  HasCustomReal,
  CustomReal,
  Sampleable,
  sample,
  Conditionable,
  factor,
  condition,
  observe
) where

import Control.Monad.Trans.Class
import Control.Monad.Trans.Identity
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.State
import Control.Monad.Trans.Writer
import Control.Monad.Trans.Reader
import Control.Monad.Trans.RWS hiding (tell)
import Control.Monad.Trans.List
import Control.Monad.Trans.Cont

import qualified Numeric.LogDomain as Log
import Statistics.Distribution.Polymorphic.Class

-- | The type used to represent real numbers in a given probabilistic program.
-- In most cases this is just `Double`, but
-- it is abstracted mostly to support Automatic Differentiation.
class (Floating (CustomReal m), Ord (CustomReal m)) => HasCustomReal m where
  type CustomReal (m :: * -> *)

-- | Type class asserting that a particular distibution can be sampled in structures of given type.
class Distribution d => Sampleable d m where
  sample :: d -> m (Domain d)

-- | Probabilistic program types that allow conditioning.
-- Both soft and hard conditions are allowed.
class HasCustomReal m => Conditionable m where

    -- | Conditioning with an arbitrary factor, as found in factor graphs.
    -- Bear in mind that some inference algorithms may require `factor`s to be
    -- non-negative to work correctly.
    factor :: Log.LogDomain (CustomReal m) -> m ()

    -- | Hard conditioning on an arbitrary predicate.
    --
    -- > condition b = factor (if b then 1 else 0)
    condition :: Bool -> m ()
    condition b = factor $ if b then 1 else 0

    -- | Soft conditioning on a noisy value.
    --
    -- > observe d x = factor (pdf d x)
    observe :: (Density d, RealNum d ~ CustomReal m) => d -> Domain d -> m ()
    observe d x = factor (pdf d x)

----------------------------------------------------------------------------
-- Instances that lift probabilistic effects to standard tranformers.

instance HasCustomReal m => HasCustomReal (IdentityT m) where
  type CustomReal (IdentityT m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (IdentityT m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (IdentityT m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (MaybeT m) where
  type CustomReal (MaybeT m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (MaybeT m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (MaybeT m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (ReaderT r m) where
  type CustomReal (ReaderT r m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (ReaderT r m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (ReaderT r m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (WriterT w m) where
  type CustomReal (WriterT w m) = CustomReal m

instance (Sampleable d m, Monad m, Monoid w) => Sampleable d (WriterT w m) where
  sample = lift . sample

instance (Conditionable m, Monad m, Monoid w) => Conditionable (WriterT w m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (StateT s m) where
  type CustomReal (StateT s m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (StateT s m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (StateT s m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (RWST r w s m) where
  type CustomReal (RWST r w s m) = CustomReal m

instance (Sampleable d m, Monad m, Monoid w) => Sampleable d (RWST r w s m) where
  sample = lift . sample

instance (Conditionable m, Monad m, Monoid w) => Conditionable (RWST r w s m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (ListT m) where
  type CustomReal (ListT m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (ListT m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (ListT m) where
  factor = lift . factor


instance HasCustomReal m => HasCustomReal (ContT r m) where
  type CustomReal (ContT r m) = CustomReal m

instance (Sampleable d m, Monad m) => Sampleable d (ContT r m) where
  sample = lift . sample

instance (Conditionable m, Monad m) => Conditionable (ContT r m) where
  factor = lift . factor
