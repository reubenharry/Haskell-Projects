{-# LANGUAGE TemplateHaskell #-}
import Lens.Micro
import Lens.Micro.TH

data Atom = Atom { _element :: String, _point :: Point } deriving Show

data Point = Point { _x :: Double, _y :: Double } deriving Show


-- point :: Lens' Atom Point
-- point = lens _point (\atom newPoint -> atom { _point = newPoint })

makeLenses ''Atom
makeLenses ''Point

-- x :: Lens' Point Double
-- x = lens _x (\point newX -> point { _x = newX })


-- element :: Lens' Atom String
-- element = lens _element (\atom newElement -> atom { _element = newElement })

-- point :: Lens' Atom Point
-- point = lens _point (\atom newPoint -> atom { _point = newPoint })



p = Point {_x = 1.0, _y = 2.0}

a = Atom { _element = "foo" , _point = p }

main :: IO ()
main = do
	let k = over (point . x) (+1) a
	print $ _element a
	print k