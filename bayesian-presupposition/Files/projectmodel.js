//generates a distribution on worlds. note that everyone is standing. changing this made the model very computationally intensive.
var worldMaker = function() {
  var people = map(function(x){ return {'color' : uniformDraw(['red','green']),'gender' : flip() ? 'female' : 'male','hat' : flip() ? 'hat' : 'no hat','standing' : 'standing'} }, [1,1,1])
  var out = {'bucket' : {'size' : uniformDraw([0.99])}, 'people' : people, }
  return out
}

//''parses'' the utterance into logical form, and supplies alternative propositions too, all in one array
var logForm = function(utt){
  utt=="There is a man standing."?
    [{'utt':"all of the people are women.",'flag':'neg'},
      {'utt':"all of the people are women.",'flag':'pos'},
      {'utt':"someone is standing.",'flag':'pos'},    
    ]:
  utt=="There is someone not wearing a red shirt and standing."||utt=="Someone is not wearing a red shirt and is standing."?
    [{'utt':"all of the people have red shirts.",'flag':'neg'},
    {'utt':"some of the people have red shirts.",'flag':'neg'},
    {'utt':"all of the people have red shirts.",'flag':'pos'},
    {'utt':"someone is standing.",'flag':'pos'},
    ]:

  utt=="There are exactly two people wearing hats and they are standing."?
    [{'utt':"there are exactly two people wearing hats.",'flag':'pos'},
    {'utt':"there are exactly two people wearing hats.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'}]:


  utt=="Some of the people are wearing red shirts."?
    [{'utt':"some of the people have red shirts.",'flag':'pos'},
    {'utt':"all of the people have red shirts.",'flag':'pos'},
    {'utt':"some of the people have red shirts.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'}]:


  utt=="Some of the people are women."?
    [{'utt':"some of the people are women.",'flag':'pos'},
    {'utt':"all of the people are women.",'flag':'pos'},
    {'utt':"some of the people are women.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'},
    ]:

  utt=="There is one person without a hat who is standing."||utt=="There is a person without a hat who is standing."?
    [{'utt':"someone is not wearing a hat.",'flag':'pos'},
    {'utt':"someone is not wearing a hat.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'}]:


  utt=="The man is standing."?
    [{'utt':"the man is standing.",'flag':'pos'},
    {'utt':"the man is standing.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'},
    ]:

  utt=="The person without a red shirt is standing."||utt=="The person not wearing a red shirt is standing."?
    [{'utt':"the person not wearing a red shirt is standing.",'flag':'pos'},
    {'utt':"the person not wearing a red shirt is standing.",'flag':'neg'},
    {'utt':"the man is standing.",'flag':'pos'},]:

  utt=="Both people wearing hats are standing."?
    [{'utt':"both people wearing hats are standing.",'flag':'pos'},
    {'utt':"both people wearing hats are standing.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'}]:


  utt=="The man isn't sitting."||utt=="It is not the case that the man is sitting."?
    [
    {'utt':"the man is sitting.",'flag':'neg'},
    {'utt':"the man is sitting.",'flag':'pos'},
    {'utt':"someone is standing.",'flag':'pos'}
    ]:

  utt=="The person without a red shirt isn't sitting."||utt=="It is not the case that the person not wearing a red shirt is sitting."?
    [{'utt':"the person not wearing a red shirt is sitting.",'flag':'neg'},
    {'utt':"the person not wearing a red shirt is sitting.",'flag':'pos'},
    {'utt':"someone is not wearing a hat.",'flag':'pos'},]:

  utt=="Both of the people wearing hats are not sitting."||utt=='It is not the case that both of the people wearing red shirts are sitting.'?
    [{'utt':"both people wearing hats are sitting.",'flag':'neg'},
    {'utt':"both people wearing hats are sitting.",'flag':'pos'},
    {'utt':"someone is standing.",'flag':'pos'}]:

    //residual item
  utt=='The person wearing a red shirt is standing.'?[
      {'utt':"some of the people have red shirts.",'flag':'pos'},
      {'utt':"someone is standing.",'flag':'pos'}    
    ]:

  utt=="The bucket is full."?
    [{'utt':"the bucket is full.",'flag':'pos'},
    {'utt':"someone is standing.",'flag':'pos'}]:


  utt=="All of the women are standing."?
    [{'utt': "all of the women are standing.",'flag': 'pos'},
    {'utt': "all of the women are standing.",'flag': 'neg'},
    {'utt': "both of the people are women",'flag': 'pos'},
    {'utt': "some of the people are women",'flag': 'pos'},
    {'utt':"someone is standing.",'flag':'pos'}]:

  utt=="Someone is standing."?
  [{'utt':"someone is standing.",'flag':'pos'}]:

  utt=="There is a man with a red shirt."?
      [
    {'utt':"there is a man with a red shirt.",'flag':'pos'},
    {'utt':"there is a man with a red shirt.",'flag':'neg'},
    {'utt':"someone is standing.",'flag':'pos'},
    ]:

  utt=="The man has a red shirt."?
    [
    {'utt':"the man has a red shirt.",'flag':'pos'},
      {'utt':"the man has a red shirt.",'flag':'neg'},
      {'utt':"someone is standing.",'flag':'pos'} 
    ]:

  null

}

// effectively a continuized negation, that passes on failure
var not = function(fun){
  return function(w) {
    var out = fun(w)
    if (fun(w) == 'presup') {return 'presup'}
    return Math.abs(1 - (fun(w)))
  }
}

//note that standing is treated as a tautology
var meaning = function(u) {

    var m = function(utt) {
    return function(world,theta) {

        var some = function(fun){
          return (sum(map(function(x){fun(world['people'][x])},[0,1,2])) > 0)
        }

        var all = function(fun){
          return (product(map(function(x){fun(world['people'][x])},[0,1,2])) > 0)
        }

        var isRed = function(x){
          return (x['color'] == 'red')?1:0
        }

        var isMale = function(x){
          return (x['gender'] == 'male')?1:0
        }

        var hasHat = function(x){
          return (x['hat'] == 'hat')?1:0
        }

        var isStanding = function(x){
          return (x['standing'] == 'standing')?1:0
        }        

      return utt=="the man has a red shirt."?
        some(isMale)?
          (some(function(x){isMale(x)&&isRed(x)})?1:0):
            'presup':


      utt=="some of the people are women."? 
        some((function(x){!isMale(x)})):
      
      utt=="there is a man with a red shirt."? 
        some((function(x){(isMale(x))&&(isRed(x))})):
      

      utt=="some of the people have red shirts."? 
        some(isRed):
       
      utt=="all of the people have red shirts."? 
        all(isRed):
      
      utt=="all of the people are women."? 
        all((function(x){!isMale(x)})):
      
      utt=="the man is standing."?
        some(isMale) ? 1 :
        'presup' :
      
      utt=="the man is sitting."?
        some(isMale) ? 0 :
        'presup' :
      
      utt=="the person not wearing a red shirt is standing."?
        some((function(x){!isRed(x)})) ? 1 :
        'presup' :

      utt=="the person not wearing a red shirt is sitting."?
        some((function(x){!isRed(x)})) ? 0 :
        'presup' :

      utt=="someone is standing."?
        some(isStanding):

      utt=="both people wearing hats are standing."?
        sum(map(function(x){world['people'][x]['hat'] == 'hat' ? 1 : 0 },[0,1,2])) == 2 ? 1 :
        'presup' :
      
      utt=="both people wearing hats are sitting."?
        sum(map(function(x){world['people'][x]['hat'] == 'hat' ? 1 : 0 },[0,1,2])) == 2 ? 0 :
        'presup' :
      
      utt=="there are exactly two people wearing hats."?
        sum(map(function(x){world['people'][x]['hat'] == 'hat' ? 1 : 0 },[0,1,2])) == 2 ? 1 :
        0 :
      
      utt=="someone is not wearing a hat."?
        sum(map(function(x){world['people'][x]['hat'] == 'hat' ? 1 : 0 },[0,1,2])) < 3 ? 1 :
        0 :
      
      utt=="all people wearing hats are standing."?
        true ? 1 :
        0 :
      
      utt=="the bucket is full."?
        (world['bucket']['size'] <= theta)?0: world['bucket']['size'] - theta :
      
      utt=="both of the women are standing."?
        sum(map(function(x){world['people'][x]['gender'] == 'female' ? 1 : 0 },[0,1,2])) == 2 ? 1 :
        'presup' :
      
      utt=="all of the women are standing."?
        sum(map(function(x){world['people'][x]['gender'] == 'female' ? 1 : 0 },[0,1,2])) > 1 ? 1 :
        'presup' :
      
      utt=="both of the women are standing."?
        sum(map(function(x){world['people'][x]['gender'] == 'female' ? 1 : 0 },[0,1,2])) == 2 ? 1 :
        'presup' :
          1
      }}

    if (u['flag'] == 'neg') {return not(m(u['utt']))}
    else {return m(u['utt'])}
  }

//ignores bucket fullness
var qudPeople = function(w){
  return w['people']
}

var rationality = 0.9

//an rsa model with soft factors for the literal listener: this was not used in the experiment
var rsa = function(utts,pWorlds) {
  Infer({method: 'enumerate',samples: 100},function(){

  var literalListener = cache(function(utterance,theta) {
      Infer(
        {method: 'enumerate'},
        function(){
          var world = worldMaker()
          var m = meaning(utterance)(world,theta)
          if (m == 'presup') {return qudPeople(world)}
          //note that the log of m isn't taken
          factor(m)
          return qudPeople(world)
        })
    })
  var speaker = cache(function(world,utt,theta) {
      Infer(
        {method: 'enumerate'},
        function(){
          var utterance = uniformDraw(logForm(utt))
          var L = literalListener(utterance,theta)
          factor(rationality * L.score(world))
          return utterance
        })
    })
  var listener = function(utterances) {

          var theta = flip()?0.8:0.2
          var world = qudPeople(worldMaker())
          condition(_.isEqual(world,qudPeople(pWorlds[0])) || _.isEqual(world,qudPeople(pWorlds[1])) || _.isEqual(world,qudPeople(pWorlds[2])))
        
          map(function(utterance) {
          var S = speaker(world,utterance,theta)
          factor(rationality * S.score(logForm(utterance)[0]))
        }, utterances)

        return world
        
    }

    return listener(utts)
})}



//accessibility relation: probabilistic
var acc = function(world) {Infer({method : 'enumerate'},function(){
  var sw = function(st){
    if (st=='red') {return  (flip(.01) ? 'green' : 'red')}
    if (st=='green') {return  (flip(.01) ? 'red' : 'green')}
    if (st=='female') {return  (flip(.02) ? 'male' : 'female')}
    if (st=='male') {return  (flip(.02) ? 'female' : 'male')}
    if (st=='hat') {return  (flip(.02) ? 'no hat' : 'hat')}
    if (st=='no hat') {return  (flip(.02) ? 'hat' : 'no hat')}
    if (st=='standing') {return  (flip(.02) ? 'sitting' : 'standing')}
    if (st=='sitting') {return  (flip(.02) ? 'standing' : 'sitting')}
  }

//currently unused
  var bucketChange = function(b){
    if (b == .99) {return flip() ? 0.9 : b}
    if (b > .9) {return flip() ? b-1 : b}
    if (b <= .1) {return flip() ? b+1 : b}
      else {return flip()?b+1:b-1}
  }
  var out =   {
                        'bucket' : {'size' : 0.99},
                        'people' : 
                            [
                              {'color' : sw(world['people'][0]['color']),'gender': sw(world['people'][0]['gender']),'hat' : sw(world['people'][0]['hat']),'standing' : 'standing'},
                              {'color' : sw(world['people'][1]['color']),'gender' : sw(world['people'][1]['gender']),'hat' : sw(world['people'][1]['hat']),'standing' : 'standing'},
                              {'color' : sw(world['people'][2]['color']),'gender' : sw(world['people'][2]['gender']),'hat' : sw(world['people'][2]['hat']),'standing' : 'standing'}
                            ]
                            // [
                            //   {'color' : sw(world['people'][0]['color']),'gender': sw(world['people'][0]['gender']),'hat' : sw(world['people'][0]['hat']),'standing' : sw(world['people'][0]['standing'])},
                            //   {'color' : sw(world['people'][1]['color']),'gender' : sw(world['people'][1]['gender']),'hat' : sw(world['people'][1]['hat']),'standing' : sw(world['people'][1]['standing'])},
                            //   {'color' : sw(world['people'][2]['color']),'gender' : sw(world['people'][2]['gender']),'hat' : sw(world['people'][2]['hat']),'standing' : sw(world['people'][2]['standing'])}
                            // ]

                      }
  return out
})}


//the model used in the experiment: intensional RSA with presupposition failure
var rsaInt = function(utts,pWorlds) {
  Infer({method: 'enumerate',samples: 100},function(){


  var literalListener = cache(function(utterance) {
      Infer(
        {method: 'enumerate',samples: 100},
        function(){
          var world = worldMaker()
          var m = meaning(utterance)(world,0.5)
          if (m == 'presup') {return qudPeople(world)}
          factor(Math.log(m))
          return qudPeople(world)

        })
    })
  var speaker = cache(function(world,utt) {
      Infer(
        {method: 'enumerate',samples: 100},
        function(){
          var utterance = uniformDraw(logForm(utt))
          var L = literalListener(utterance)

          factor(rationality * L.score(world))
          return utterance
        })
    })


  var listener = function(utterances) {

          var world = worldMaker()
          var d = qudPeople(sample(acc(world)))
          condition(_.isEqual(qudPeople(world),qudPeople(pWorlds[0])) || _.isEqual(qudPeople(world),qudPeople(pWorlds[1])) || _.isEqual(qudPeople(world),qudPeople(pWorlds[2])))
          
          map(function(utterance) {
          var S = speaker(d,utterance)
          factor(rationality * S.score(logForm(utterance)[0]))
        }, utterances)

        return qudPeople(world)
        
    }

    return listener(utts)
})}


//data munging
var possWorlds = function(world){ 
  if (Array.isArray(world['worlds'])) {
    var out = 
    [
    world['worlds'][0]['world1'],
    world['worlds'][0]['world2'],
    world['worlds'][0]['world3'],
    ]
    return out
    }
  else 
      {
      var out =
        [world['worlds']['world1'],
      world['worlds']['world2'],
      world['worlds']['world3']]
      return out
    }

}

//output munging
var getData = function(world,model) {
  var ws = possWorlds(world)
  var out = model(world['utterances'],ws,null)
  var values = map(function(x){Math.exp(out.score(qudPeople(x)))},ws)
  return JSON.stringify([world,values])
}


var data = json.read('data.json').slice(180,240);

var main = map(function(x){return getData(x,rsaInt)},data)
main
// data[0]

// var utters = ["There is a man with a red shirt."]
// rsaInt(utters, possWorlds(data[0]))



