{-# LANGUAGE TypeFamilies #-}

{-|
Module      : Statistics.Distribution.Polymorphic.Normal
Description : Univariate normal distribution
Copyright   : (c) Adam Scibior, 2017
License     : MIT
Maintainer  : ams240@cam.ac.uk
Stability   : experimental
Portability : GHC

-}

module Statistics.Distribution.Polymorphic.Normal (
  Normal,
  mean,
  stddev,
  variance,
  precision,
  normalDist
) where

import Numeric.LogDomain hiding (beta, gamma)
import Statistics.Distribution.Polymorphic.Class

-- | Normal distribution.
data Normal r = Normal r r

-- | Mean value.
mean :: Normal r -> r
mean (Normal m _) = m

-- | Standard deviation.
stddev :: Normal r -> r
stddev (Normal _ s) = s

-- | Variance.
variance :: Num r => Normal r -> r
variance d = let s = stddev d in s * s

-- | Precision.
precision :: Fractional r => Normal r -> r
precision d = recip (variance d)

-- | Create a normal distribution checking its parameters.
normalDist :: (Ord r, Floating r) => r -> r -> Normal r
normalDist mu sigma
  | sigma <= 0 = error "Normal was given non-positive standard deviation"
  | otherwise  = Normal mu sigma

-- | PDF of a normal distribution parameterized by mean and stddev.
normalPdf :: (Ord a, Floating a) => a -> a -> a -> LogDomain a
normalPdf mu sigma x
  | sigma <= 0 = error "PDF: non-positive standard deviation in Normal"
  | otherwise  = fromLog $ (-0.5 * log (2 * pi * sq sigma)) +
                ((- sq (x - mu)) / (2 * sq sigma))
                  where
                    sq y = y ^ (2 :: Int)

instance Distribution (Normal r) where
  type Domain (Normal r) = r
  type RealNum (Normal r) = r

instance (Ord r, Floating r) => Parametric (Normal r) where
  type Param (Normal r) = (r,r)
  param (Normal m s) = (m,s)
  distFromParam = uncurry normalDist

instance (Ord r, Floating r) => Density (Normal r) where
  pdf (Normal m s) = normalPdf m s
