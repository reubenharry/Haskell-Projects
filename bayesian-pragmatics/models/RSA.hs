{-# LANGUAGE RankNTypes, TypeFamilies, FlexibleContexts, AllowAmbiguousTypes, ImpredicativeTypes #-}

import Numeric.LogDomain
import Control.Monad (liftM2)
import Control.Monad.Bayes.Class
import Control.Monad.Bayes.Simple
import Control.Monad.Bayes.Enumerator
import Text.Parsec
-- import BayesUtils

--first we declare our types
type Utterance = String
type World = Char
--speakers are conditional distributions over utterances given worlds
-- type Speaker = forall d. (MonadBayes d) => World -> d Utterance
--listeners are conditional distributions over worlds given utterances
type Listener = Integer -> Utterance -> Dist Double Char
type Speaker = Integer -> Char -> Dist Double Utterance

--the possible utterances and worlds
utterances = ["blue","square"]
worlds = ['0','1'..]

--now we declare a semantics, i.e. an interpretation function (which is a functor from syntax to semantics)
--this one is as simple as possible. not even compositional
meaning :: Fractional a => Utterance -> World -> a
meaning "blue" _ = realToFrac 1.0
meaning "square" '0' = realToFrac 1.0
meaning "square" '1'  = realToFrac 0.0




s :: Speaker
l :: Listener


--mutually recursive definitions of pragmatic speaker and listener
--n is the number of levels of recursion. (l 2) models (s 2) who models (l 1) who models (s 1) who... 
s 0 w = uniformDraw utterances
s n w = do
  u <- s (n-1) w
  let utility = mass (l (n-1) u) w :: Double
  factor $ realToFrac utility
  return u

l 0 u = do
    --samples a world uniformly from the possible worlds
    w <- uniformDraw worlds
    --does a condition on the truth of the utterance in the sampled world
    factor $ meaning u w
    return w
l n u = do
    w <- uniformDraw worlds
    factor $ realToFrac $ (mass (s n w) u :: Double)
    return w


-- prints out the first 5 listener depth probabilities of being in '1' on hearing 'blue'
main = print . take 5 . fmap (\n -> mass (l n "blue") '1') $ [0..]


uniformDraw :: (MonadBayes d) => [a] -> d a
uniformDraw [a] = return a
uniformDraw x = do
  p <- bernoulli $ (1.0/(fromIntegral $ length x))
  if p then return  (head x) else uniformDraw $ tail x

-- s1 :: (MonadBayes d) => Char -> d String
-- s1 w = do
--   u <- uniformDraw ["blue","square"]
--   -- u <- uniformDraw ["square",]
--   let m = realToFrac $ score w $ normalize $ enumerate $ l0 u
--   factor m
--   -- condition (w == w')
--   return u
--
-- l1 :: (MonadBayes d) => String -> d Char
-- l1 u = do
--   w <- uniformDraw ['0','1']
--   let m = realToFrac $ score u $ normalize $ enumerate $ s1 w
--   factor m
--   -- u' <- s1 w
--   -- condition (u == u')
--   return w

-- s0 :: (MonadBayes d) => Char -> MaybeT d String
-- s0 x = do
--     p <- bernoulli 0.33
--     let a = if p then "blue" else "square"
--     b <- uniformDraw ["blue"]
--     if x == '0' then lift $ return a else lift $ return b
--
-- l0 :: (MonadBayes d) => String -> MaybeT d Char
-- l0 u = do
--     w <- uniformDraw ['0','1']
--     -- let m = realToFrac $ score u $ normalize $ enumerate $ s0M w
--     let m = normalize $ enumerate $ runMaybeT $ s0M w
--     factor $ m
--     return w
--
-- s1 :: (MonadBayes d) => Char -> d String
-- s1 w = do
--   u <- uniformDraw ["blue","square"]
--   -- u <- uniformDraw ["square",]
--   let m = realToFrac $ score w $ normalize $ enumerate $ l0 u
--   factor m
--   -- condition (w == w')
--   return u
--
-- l1 :: (MonadBayes d) => String -> d Char
-- l1 u = do
--   w <- uniformDraw ['0','1']
--   let m = realToFrac $ score u $ normalize $ enumerate $ s1 w
--   factor m
--   -- u' <- s1 w
--   -- condition (u == u')
--   return w

-- score :: (Eq a1, Num a,Fractional a) => a1 -> [(a1, a)] -> a
-- score n dist = ((\x -> if null x then 0 else head x) $ fmap snd $ filter (\x -> fst x == n) dist) / 100
--
-- -- idea: utterance is of type StateT w Dist Bool, i.e. w -> Dist(Bool, w)
--
-- type U = MonadBayes d => StateT (Model) (WriterT [Bool] (MaybeT d)) Bool
--
--
-- -- ok, here's the underlying problem: we don't want both the proposition and the listener to be using separate monads: that's not fun
-- -- why am i doing this this way? ah, to make the dist monad play with the others
-- -- ok so i want a proposition to be of type :: u -> Dist OtherStuff Bool , i.e. M Bool
-- -- basic rsa: a proposition is a (reader bool)
--
-- -- ideal model:
--
-- -- M :: Reader w $ g -> M Bool
--
--
-- u :: U
-- u = do
--     y <- get
--     condition (y == model)
--     -- y <- worldMaker 3
--     let ciS = [(gender . (!!0) . unModel) y == Female, (gender . (!!1) . unModel) y == Male]
--     condition (all (==True) ciS)
--     lift $ tell ciS
--     -- lift $ listen $ worldMaker 3
--     let fail = (hat . (!!0) . unModel) y == False
--     when fail $ lift $ lift $ exceptToMaybeT $ throwE "oops"
--     let m = ((gender . (!!0) . unModel) y == Female)
--     factor (if ((gender . (!!0) . unModel) y == Female) then 0.5 else 0.3)
--     put y
--     return m
--
-- u' :: U
-- u' = do
--     x <- get
--     y <- worldMaker 3
--     lift $ tell [(gender . (!!0) . unModel) y == Male,(gender . (!!1) . unModel) y == Male]
--     -- lift $ listen $ worldMaker 3
--     let fail = (hat . (!!0) . unModel) y == True
--     when fail $ lift $ lift $ exceptToMaybeT $ throwE "oops"
--     let m = (x == y)
--     factor (if x == y then 0.5 else 0.3)
--     put  x
--     return m
--
-- -- the listener should be doing nothing but drawing a world and doing inference
--
-- l0 u = normalize $ enumerate $ do
--     w <- worldMaker 3
--     runMaybeT $ runWriterT $ runStateT u w
--     -- out' <- out
--     -- let y = (fmap . fmap) (fst) out
--     -- condition y
--     -- return out
--
-- -- s0 u w = uniformDraw [u,u']
--
-- interp "one" = u
-- interp "two" = u'
--
-- -- s1 :: MonadBayes d => Model -> d String
-- s1 w = do
--     u <- uniformDraw ["one","two"]
--     let m = realToFrac $ score w $ l0 (interp u)
--     -- let ci = fmap (!!1) w
--     factor m
--     -- factor (ci == (Just [True,True]))
--     return u
--
-- --intended architecture:
--
-- --first: work out if you can get maybe to percolate all the way up
--
-- --a semantics which is fully monadic. then the m a (including dist) gets unpacked by the prag: do with the reader trick, since you got that working.
-- --clean up first.
--
-- -- The type of listener: Utterance -> Dist (Maybe Model) = MonadDist d => StateT Utterance $ d (Maybe Model) = m Model
-- -- the type of a speaker: m Utterance
--
-- -- type World = [Person,Person,Person]
-- -- data Model = Model {hat :: Hat, }
--
-- -- gram :: ParsecT [Char] () (StateT [String] (ListT (Identity))) (Bool)
-- -- gram = do
-- --   y <- many $ ( upper <|> lower)
-- --   let subj = s y
-- --   space
-- --   x <- many $ ( upper <|> lower)
-- --   let veep = vp x
-- --   lift $ veep <*> subj
-- --   --return x
-- --   --lift $ man (show x) (as :: String)
-- -- main = (print . lowerS) $ runParserT  gram () "gram" "Bart ran"
-- -- import Control.Monad.Reader.Class
--
-- --eventual: listener and speaker are interlocking monads
--
-- --for now: data type for world, logform=parser, meanings: simple lambda calc, worldMaker, accessibility relation
--
-- --import Grammar
-- -- ans = (enumerate ((==(3 :: Int)) `fmap` dice_soft))
--
-- -- normalize x = uncurry zip $ fmap norm $ unzip x
-- -- norm x = fmap (\y -> y * (100 / (sum x))) z where z = x
-- -- norm = sum
-- --plan: you need a dynamic semantics, where prop is of type: m (bool) for monadstate s m and s is of type monaddist Model
--
-- --simpler : props take a model: i.e. they're modal: ok, good touch probably
-- type Domain = [String]
-- data Model = Model { unModel :: [Person]} deriving (Ord,Eq,Show)
-- -- unModel (Model m) = m
--
-- data Gender = Male | Female deriving (Ord,Eq,Show)
-- data Color = Red | Blue | Green deriving (Ord,Eq,Show)
--
-- data Person = Person { hat :: Bool
--   , gender :: Gender
--   , shirtColor :: Color
-- } deriving (Ord,Eq,Show)
--
-- model = Model ([Person False Female Red,Person True Female Red, Person True Male Red])
--
--
-- -- interp :: (Monad m, MonadTrans t, MonadDist (t (ReaderT Model m))) =>  [Char] -> t (ReaderT Model m) Bool
-- -- meaning :: Monad m => [Char] -> ReaderT Model m Bool
-- -- meaning "some of the people are women" =   ReaderT $ (return . (any ((==Female) . gender) . (unModel)))
-- -- meaning "all of the people are women" = return True
-- --     -- ReaderT $ (return . (all ((==Female) . gender) . (unModel)))
-- -- meaning "" = (return False)
-- meaning :: Monad m => [Char] -> ReaderT Model m Bool
-- meaning "some of the people are women" = ReaderT $ (return . (any ((==Female) . gender) . (unModel)))
-- meaning "all of the people are women" = ReaderT $ (return . (all ((==Female) . gender) . (unModel)))
--     -- ReaderT $ (return . (all ((==Female) . gender) . (unModel)))
-- meaning "" = ReaderT $ (return . const True)
-- -- interp "foo" =
--
--     -- do
--     -- x <- bernoulli 0.5
--     -- lift $ ReaderT $ (return . (const (x) . (unModel)))
--
-- type Listener = forall d. MonadBayes d => String -> d Model
-- type Speaker = forall d. MonadBayes d => Model -> d String
-- successes = filter ((/= 0.0) . snd)
--
-- worldMaker :: MonadDist m => Int -> m Model
-- worldMaker n = fmap Model $ sequence $ take n $ repeat person
-- -- worldMaker :: MonadDist m => m Model
-- -- worldMaker n = Model $ take n $ repeat person
--
-- person :: MonadDist m => m Person
-- person = do
--   z <- uniformDraw([True,False])
--   x <- uniformDraw([Male,Female])
--   y <- uniformDraw([Red,Blue,Green])
--   return $ Person z x y
--
-- -- s0 :: (MonadBayes d) => Char -> d String
-- -- s0 w = do
-- --     return
--
-- -- l0 :: (MonadBayes d) => String -> d Model
-- -- l0 u = do
-- --     w <- worldMaker 3
-- --     -- let m = realToFrac $ score u $ normalize $ enumerate $ s0 w
-- --     let m = runIdentity $ runReaderT (meaning u) w
-- --     -- factor m
-- --     condition m
-- --     return w
--
-- -- s1 :: (MonadBayes d) => Model -> d String
-- -- s1 w = do
-- --   u <- uniformDraw ["some of the people are women","all of the people are women",""]
-- --   -- u <- uniformDraw ["square",]
-- --   let m = realToFrac $ score w $ normalize $ enumerate $ l0 u
-- --   factor m
-- --   -- condition (w == w')
-- --   return u
--
-- -- l1 :: (MonadBayes d) => String -> d [Gender]
-- -- l1 u = do
-- --   w <- worldMaker 3
-- --   let m = realToFrac $ score u $ normalize $ enumerate $ s1 w
-- --   -- u' <- s1 w
-- --   factor m
-- --   -- condition (u==u')
-- --   -- return m
-- --   -- u' <- s1 w
-- --   -- condition (u == u')
-- --   return $ qudGender w
--
-- qudGender = fmap (\(Person x y z) -> y) . unModel
--
-- -- babe :: m [String]
-- -- babe = traceMH (100 :: Int) $ (s1 model :: MonadBayes d => d String)
-- -- out = normalize $ enumerate $ (l0 "some of the people are women")
-- -- out2 = normalize $ enumerate $ (s1 model)
-- -- out3 = normalize $ enumerate $ (l1 "some of the people are women")
--
-- --
-- -- l1' :: (MonadBayes d) => String -> d Char
-- -- l1' u = do
-- --   w <- uniformDraw ['0','1']
-- --   let m = realToFrac $ score u $ normalize $ enumerate $ s1' w
-- --   factor m
-- --   -- u' <- s1 w
-- --   -- condition (u == u')
-- --   return w
--
-- -- c = normalize $ enumerate $ (s0' '1')
-- -- a = normalize $ enumerate $ (l1' "square")
-- -- -- b = normalize $ enumerate $ (s1' '0')
-- --   -- return $ Model [Person z x y, Person z x y]
--
-- -- -- instance MonadBayes m => MonadBayes (MaybeT m) where
-- -- --   factor = lift . factor
--
-- -- -- litList :: forall d. MonadBayes d => String -> d Model
-- -- -- litList :: forall d. MonadBayes d => String -> (ReaderT Model) (MaybeT d) [Gender]
-- -- -- -- litList :: forall d. MonadBayes d => String -> Model -> d Model
-- -- -- litList u = do
-- -- --   w <- ask
-- -- --   -- condition (runIdentity $ runReaderT (interp u) w)
-- -- --   m <- interp u
-- -- --   condition m
-- -- --   return $ fmap (\(Person x y z) -> y) $ unModel w
--
-- -- -- -- speaker :: forall d. MonadBayes d => Model -> MaybeT (ReaderT Model d) String
-- -- -- -- speaker w = do
-- -- -- --   u <- uniformDraw ["some of the people are women","all of the people are women"]
-- -- -- --   w' <- litList u
-- -- -- --   condition (w' == (qudGender w) )
-- -- -- --   return u
--
-- -- -- qudGender = fmap (\(Person x y z) -> y) . unModel
--
-- -- -- -- pragList :: forall d. MonadBayes d => String -> MaybeT (ReaderT Model d) [Gender]
-- -- -- -- pragList u = do
-- -- -- --   w <- worldMaker
-- -- -- --   u' <- (speaker w)
-- -- -- --   condition (u' == u)
-- -- -- --   return $ fmap (\(Person x y z) -> y) $ unModel
--
-- -- -- --main = print $ runReader interp model
-- -- -- display :: Show a => [(a, Double)] -> IO ()
-- -- -- display = mapM_ print . normalize
--
-- -- -- -- main = display $ enumerate $ do
-- -- -- --   x <- worldMaker
-- -- -- --   runMaybeT $ (flip runReaderT x) $ litList "some of the people are women"
-- -- --   -- speaker model
-- -- --   -- pragList "Some of the people are women"
--
--
-- -- -- -- litList' :: forall d. MonadBayes d => String -> MaybeT d Model
-- -- -- -- -- litList :: forall d. MonadBayes d => String -> Model -> d Model
-- -- -- -- litList' u = do
-- -- -- --   w <- worldMaker
-- -- -- --   m <- runReaderT (interp u) w
--
-- -- -- --   -- check <- bernoulli 0.9
-- -- -- --   -- let msharp = if check then m else not m
-- -- -- --   -- condition msharp
--
-- -- -- --   condition (m)
--
-- -- -- --   -- return $ fmap (\(Person x y z) -> y) $ unModel w
-- -- -- --   return w
--
-- -- -- -- speaker' :: forall d. MonadBayes d => Model -> MaybeT d String
-- -- -- -- speaker' w = do
-- -- -- --   -- u <- uniformDraw ["some of the people are women","all of the people are women"]
-- -- -- --   u <- uniformDraw ["all of the people are women","","some of the people are women"]
-- -- -- --   let m = fmap (toLogDomain $ realToFrac $ score w $ normalize $ enumerate)  (runMaybeT $ litList' u)
-- -- -- --   -- factor m
--
--
-- -- -- --   -- w' <- litList' u
-- -- -- --   -- condition (w' == w )
-- -- -- --   return $ u
--
-- -- -- -- -- pragList' :: forall d. MonadBayes d => String -> MaybeT d [Gender]
-- -- -- -- -- pragList' u = do
-- -- -- -- --   w <- worldMaker
-- -- -- -- --   u' <- (speaker' w)
-- -- -- -- --   condition (u' == u)
-- -- -- -- --   return $ qudGender w
--
-- -- -- -- main = do
-- -- -- --     display $ normalize $ enumerate $ runMaybeT $ (litList' "some of the people are women")
-- -- -- --     display $ normalize $ enumerate $ runMaybeT $ (speaker' model)
--
--
-- -- -- --[bluesquare, bluecircle, greencircle]
--
-- -- -- interp' "blue" = uniformDraw ['0','1']
-- -- -- interp' "square" = uniformDraw ['0']
--
-- -- -- simpleLit :: (MonadBayes d) => String -> d Char
-- -- -- simpleLit u = do
-- -- --     w <- uniformDraw ['0','1']
-- -- --     m <- interp' u
-- -- --     condition (m == w)
-- -- --     return w
-- -- -- -- CustomReal m ~ Double
-- -- -- simpleSpeaker :: (MonadBayes d) => Char -> d String
-- -- -- simpleSpeaker w' = do
-- -- --   u <- uniformDraw ["blue","square"]
-- -- --   let m = realToFrac $ score w' $ normalize $ enumerate $ simpleLit u
-- -- --   -- factor $ toLogDomain $ (fromIntegral (w ::  Double) :: CustomReal )
-- -- --   factor (toLogDomain $ fromRational m)
--
-- -- --   -- w <- simpleLit u
-- -- --   -- condition (w' == w)
-- -- --   return u
--
-- -- -- simplePrag :: MonadBayes d => String -> d Char
-- -- -- simplePrag u = do
-- -- --     w <- uniformDraw ['0','1']
-- -- --     let m = realToFrac $ score u $ normalize $ enumerate $ simpleSpeaker w
-- -- --     factor (toLogDomain $ fromRational m)
--
-- -- --     -- u' <- simpleSpeaker w
-- -- --     -- condition (u == u')
-- -- --     return w
--
-- -- --simple case:
-- --     --do: speaker0 and listener1
--
--
--
-- -- get maybe working:
--
--

--
--
-- -- :: (MonadDist d,CustomReal m ~ Double) => a -> d a -> Double
--
-- --convert into better form of number, and order
-- --stoppedRunning :: Reader Model (String -> Bool)
-- --stoppedRunning = ReaderT $ \x -> (\y -> (y `elem` (fst x)))
--
-- --m = enumerate $ lit (1)
-- --MonadReader Model m -> m
--
--
--
--
-- -- worldMaker' = do
-- --   p  <- [uniformDraw [Blue,Green,Red]
-- --   take 3 $ repeat $ p
--
-- -- acc :: MonadDist w => World -> w World
-- -- acc = map
--
--
--
-- -- meaning :: MonadDist m => [Char] -> m (ReaderT Model Identity Bool)
-- -- meaning x
-- --   | x == "Some of the people are women." = do x <- bernoulli 0.3; if x then return $ interp else return $ interp2
--   -- | x == "Bart stopped running." = return $ interp2
--
--
--
-- -- worldMaker :: MonadDist m => ((MaybeT) m) Model
-- -- worldMaker = do
-- --   x <-  uniformDraw $ filterM (const [True,False]) $ domain
-- --   y <-  uniformDraw $ filterM (const [True,False]) $ domain
-- --   fail <- bernoulli 0.1
-- --   -- when fail $ exceptToMaybeT Model $ throwE "oops"
-- --   -- if fail then return Nothing else
-- --   return (Model ([x,y],domain))
--
--
-- -- meaning2 :: MonadBayes m => String -> (ReaderT Model m) (Bool)
-- -- meaning2 str = do
-- --   w <- ask
-- --   let out = runIdentity $ runReaderT interp w
-- --   -- y <- interp3
-- --   condition (out)
-- --   return out
--
-- -- meaning3 :: MonadBayes m => String -> (StateT Model m) (Bool)
-- -- meaning3 str = do
-- --   w <- get
-- --   -- y <- interp3
-- --   let m = "Bart" `elem` ((head . fst . unModel) w)
-- --   condition (m)
-- --   put w
-- --   return m
--
-- -- meaning4 :: MonadDist m => [Char] -> (MaybeT m) (ReaderT Model Identity Bool)
-- -- meaning4 x
-- --   | x == "Homer stopped running." = do x <- bernoulli 0.3; when x $ exceptToMaybeT $ throwE ""; return interp
-- --   | x == "Bart stopped running." = return $ interp2
--
-- --rigid designators implemented with return
-- -- homer :: MonadReader Model m => m String
-- -- homer = return "Homer"
--
-- -- bart :: MonadReader Model m => m String
-- -- bart = return "Bart"
--
--
-- -- ran' :: Model -> String -> Bool
-- -- ran' m str = str `elem` ((!! 1) $ fst $ unModel m)
-- -- ran :: MonadReader Model m => m (String -> Bool)
-- -- ran = reader ran'
--
-- -- stoppedRunning' :: Model -> String -> Bool
-- -- stoppedRunning' m str = str `elem` (head $ fst $ unModel m)
-- -- stoppedRunning :: MonadReader Model m => m (String -> Bool)
-- -- stoppedRunning = reader stoppedRunning'
--
--
--
-- -- interp3 :: MonadDist m => (ReaderT Model m) (Bool)
-- -- interp3 =  do
-- --   x <- stoppedRunning
-- --   y <- bart
-- --   return $ x y

