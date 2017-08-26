import json
import random

# 		P: someone doesn't have a red shirt
# 		Q: someone isn't a woman
# 		R: someone is standing
# 		S: there are exactly two men
# 		G: The bucket is full.

# 		worlds:
# 			P nand Q: w1: everyone has a red shirt. w2: everyone is a woman.
# 			P nand S: w1: everyone has a red shirt, there are two men. w2: 1 man w/red shirt, two women 
# 			Q nand S: w1: 
# 			G nand P: w1: everyone has a red shirt, bucket is full, w2: someone doesn't have red shirt, bucket is less full
# 			G nand Q: sim to above
# 			G nand S: sim to above

# 		fillers:
# 			successful ones: to prove participant is complying
# 			randomized


# randomization: the order of the sentences should be randomized. The order of the worlds should also be randomized.

#and now loads more sentences

# assert(P), assert(Q)
# 	assert(P,R), presup(Q)R
# 	assert(P,R), neg(presup(Q)negR)
# 	scalar(P), presup(Q)R
# 	scalar(P), neg(presup(Q)negR)
# 	presup(P)R, assert(Q)R
#   presup(P)R, scalar(Q)
# 	neg(presup(P)negR), assert(Q)R
#   neg(presup(P)negR), scalar(Q)

# 	presup(P) vs presup(Q)
# 	neg(presup(P)) vs neg(presup(Q))
# 	presup(P) vs neg(presup(Q))
# 	neg(presup(P)) vs presup(Q)

# 	presup(Q), G: 
# 	presup(P), G: 

# q = exists x, male(x)

# assert(q) = There's a man.
# scalar(q) = some of the people is a woman


# \item maxpresup : All of the women are standing.
# \item bucket : The bucket is full.


typeDict = {
# ps
  "There is someone not wearing a red shirt and standing." : "assert(p)",
  "Some of the people are wearing red shirts." : "scalar(p)" ,
  "The person without a red shirt is standing." : "presup(p)" ,
  "The person without a red shirt isn't sitting." : "negpresup(p)",

  "There is a man standing." : "assert(q)" ,
  "Some of the people are women." : "scalar(q)",
  "The man is standing." :  "presup(q)",
  "The man isn't sitting." : "negpresup(q)" ,

  
  "There are exactly two people wearing hats and they are standing." : "assert(r)",
  "There is one person without a hat who is standing." : "scalar(r)",
  "Both people wearing hats are standing." : "presup(r)",
  "Both of the people wearing hats are not sitting." : "negpresup(r)",

  "The bucket is full." : "bucket",

  "All of the women are standing." : "maxpresup"
}

print('\n'.join(['\item '+typeDict[x]+' : '+str(x) for x in typeDict]))

ps = ["There is someone not wearing a red shirt and standing.","Some of the people are wearing red shirts.","The person without a red shirt is standing.","The person without a red shirt isn't sitting."]
qs = ["There is a man standing.","Some of the people are women.", "The man is standing.", "The man isn't sitting." ]
rs = ["There are exactly two people wearing hats and they are standing.","There is one person without a hat who is standing.","Both people wearing hats are standing.","Both of the people wearing hats are not sitting."]
b = "The bucket is full."
# for max presup
m = "All of the women are standing."

type_check = [typeDict[x] for x in ps+qs+rs+[b]+[m]]
print(type_check)
pqWorlds = ([{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : random.choice([0.99])}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}}
                      }])
qrWorlds = ([{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'no hat' },
                              {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat' : 'hat'},
                              {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat' : 'hat' }
                            ], 
                        'bucket' : {'size' : random.choice([0.99])}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : random.choice(['red','green', 'blue']),'standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}}
                      }])

rpWorlds = ([{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': random.choice(['male','female']), 'color' : 'red','standing' : 'standing','hat': 'hat'},
                              {'gender' : random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                              {'gender' : random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                            ], 
                        'bucket' : {'size' : random.choice([0.99])}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : random.choice(['male','female']), 'color' : 'green','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : random.choice(['male','female']), 'color' : 'red','standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}}
                      } ] )                

# print(pqWorlds)



bpWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

brWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': 'hat'},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

bqWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                              {'gender' : 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

mpWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'red','standing' : 'standing','hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'green','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

mrWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': 'hat'},
                              {'gender' : 'male', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'},
                          {'gender' : 'male', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'},
                          {'gender' : 'male', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

mqWorlds = [{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': random.choice(['hat','hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])},
                              {'gender' : 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : size}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])}
                        ], 
                        'bucket' : {'size' : 0.99}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','hat'])}
                        ], 
                        'bucket' : {'size' : 0.1}}
                      }
                      for size in [0.2,0.7,0.99]
                      ]

fillers = ([{'world1' : 
                      {
                        'people' : 
                            [
                              {'gender': 'female', 'color' : 'green','standing' : 'standing','hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                              {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                            ], 
                        'bucket' : {'size' : random.choice([0.99])}}, 
                   
                   'world2' : 
                      {'people' : 
                        [
                          {'gender': 'male', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': random.choice(['hat','no hat'])}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}},
                   

                   'world3': 
                      {'people' : 
                        [
                          {'gender': 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'hat'},
                          {'gender' : 'female', 'color' : 'red','standing' : 'standing', 'hat': 'no hat'}
                        ], 
                        'bucket' : {'size' : random.choice([0.99])}}
                      }])



items = [  

		{
		 	'worlds' : 

                  pqWorlds,
        
        
        	'utterances' : ([p,q])}
        	for p in ps for q in qs]+[{
		 	'worlds' : 

                  qrWorlds,
        
        
        	'utterances' : ([q,r])}
        	for q in qs for r in rs
        	]+[{
		 	'worlds' : 

                  rpWorlds,
        
        
        	'utterances' : ([r,p])}
        	for p in ps for r in rs
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([b,x])}
        	for x in ps for y in bpWorlds
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([b,x])}
        	for x in qs for y in bqWorlds
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([b,x])}
        	for x in rs for y in brWorlds
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([m,x])}
        	for x in ps for y in mpWorlds
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([m,x])}
        	for x in qs for y in mqWorlds
        	]+[{
		 	'worlds' : 

                  [y],
        
        
        	'utterances' : ([m,x])}
        	for x in rs for y in mrWorlds
        	]+[{
		 	'worlds' : 

                  fillers,
        
        
        	'utterances' : ([rs[x],ps[x]])}
        	for x in [0,1]
        	]+[{
		 	'worlds' : 

                  fillers,
        
        
        	'utterances' : ([qs[x],ps[x]])}
        	for x in [0,1]
        	]+[{
		 	'worlds' : 

                  fillers,
        
        
        	'utterances' : ([rs[x],qs[x]])}
        	for x in [0,1]
        	]
	 	
		

		# for p in ps for q in qs for r in rs]

# print((items))
# items = [item for sublist in items for item in sublist]
# items = [  
	

# 	for x in items]


# worlds = [
# 		 {
# 		 	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["Someone is standing and not wearing a red shirt.", "Someone is male and is standing."] },

         
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.7}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["Someone is standing and not wearing a red shirt.", "The man is standing."] },

        
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["Someone is standing and not wearing a red shirt.", "It is not the case that the man is sitting."] },

#         {	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.7}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["Some of the people are wearing red shirts.", "It is not the case that the man is sitting."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt is standing.", "Some of the people are female."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt isn't sitting.", "Someone is male and is standing."] },          
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt isn't sitting.", "Some of the people are female."] },
#         {  	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.1}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt is standing.", "The man is standing."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt isn't sitting.", "The man is standing."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt is standing.", "It is not the case that the man is sitting."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.7}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}}
#                       },
        
        
#         	'utterances' : ["The person without a red shirt isn't sitting.", "The man is standing."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "Everyone is standing."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "Some of the people are women."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.9}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "Some of the people are women."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.5}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] },
#         {
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.3}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] }, 
#         {	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.7}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] },

#         	{	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.8}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] },

#         	{	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.9}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] },

#         	{	
#         	'worlds' : 

#                   {'world1' : 
#                       {
#                         'people' : 
#                             [
#                               {'gender': 'female', 'color' : 'green'},
#                               {'gender' : 'female', 'color' : 'red'},
#                               {'gender' : 'female', 'color' : 'red'}
#                             ], 
#                         'bucket' : {'size' : 0.99}}, 
                   
#                    'world2' : 
#                       {'people' : 
#                         [
#                           {'gender': 'male', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.99}},
                   

#                    'world3': 
#                       {'people' : 
#                         [
#                           {'gender': 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'},
#                           {'gender' : 'female', 'color' : 'red'}
#                         ], 
#                         'bucket' : {'size' : 0.1}}
#                       },
        
        
#         	'utterances' : ["The bucket is full.", "The man is standing."] },






# 	]


a = map(json.dumps,items)

# print(a)

f = open('jsoncode.json','w')
for x in a:
	f.write(x + '\n')
f.close()