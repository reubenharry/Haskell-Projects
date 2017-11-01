
w  = [1,1,5]
--we simply need to express the asymmetry here: how many functions to bool: ah so the monic precomposition thingy?
--i.e. f w[0]=True, f w[1]=False : this means that map Bool -> World doesn't preserve as much information:
	--so if listener is trying to find most informative Bool -> World, then that f is bad


agent w = do
	i <- [0,1,2]
	return i

