# Preface
When I started learning haskell I was immediately overwhelmed. I dived heads first into using it for an actual work project and I discovered that most real world libraries used language extensions available only in GHC. That let me down a bit at first, after all, who wants to use a language so lacking that you need extensions specific to one vendor in order to actually use it, right?

Well, I got back on my horse and decided to learn about all this extensions and I deduced there were 3 hot topics in the Haskell community which apparently addressed the same kind of problems: GADT's, TypeFamilies and Functional Dependencies. Trying to look up for resources to learn about them I could only find articles describing what they were, and teaching how to use them. But none of them actually explained how we came to need them! So I decided to write this tutorial, using a friendly example, to try and explain why we need Type Families.

# Ok let's do this.

Have you heard about Pokemon? They are these wonderful creatures that inhabit the Pokemon world. You could say they're like animals, with extraordinary abilities. All Pokemon have a type, and their abilities depend on their type. For example, Pokemon of the Fire type can breathe fire, while Pokemon of the Water type can shoot water beams.

Pokemon are owned by people, and their special abilities may be put to good use on productive endeavors, but some people just put their Pokemon to fight with other people's Pokemon. These people call themselves Pokemon Trainers. All of this may sound borderline animal cruelty at first, but it's quite fun and everybody seems to be OK with it, including Pokemon. Bear in mind people in the Pokemon world also seem to be OK with 10 year olds leaving home to risk their lives in order to become the very best Pokemon trainer, like no one ever was.

We're going to use Haskell to represent a restricted (and somewhat altered, with pardon from the fans) portion of the Pokemon world, such that:

* Pokemon have a type, in our case restricted to **Fire**, **Water** or **Grass**.
* There are 3 Pokemon of each type: Charmander, Charmeleon and Charizard are Fire type. Squirtle, Wartortle and Blastoise are Water type. And finally, Bulbasaur, Ivysaur and Venusaur are Grass type.
* Each type has its own distinctive abilities, called moves: Water types perform Water moves, Fire types perform Fire moves, and Grass types perform Grass moves.
* When battling: Fire Pokemon always beat Grass Pokemon, Grass Pokemon always beat Water Pokemon, and Water Pokemon always beat Fire Pokemon.
* We never battle 2 pokemon of the same type, ever, because we wouldn't be able to decide who the winner is anyways.
* Other people can add their own pokemon in other modules.
* The typechecker helps us enforcing this rules strictly.

# First Attempt
Initially, we're going to try to implement these rules without using Type Clases and Type families.

We start with some types for our Pokemon and their distinctive moves, we keep them separate because that's going to help us know which moves go with which pokemon types. And for that purpose, we define the functions for each pokemon to pick their move.

``` haskell
data Fire = Charmander | Charmeleon | Charizard deriving Show -- These are actual Pokemon names
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show -- These are actual Pokemon moves
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = VineWhip deriving Show

pickFireMove :: Fire -> FireMove
pickFireMove Charmander = Ember
pickFireMove Charmeleon = FlameThrower
pickFireMove Charizard = FireBlast

pickWaterMove :: Water -> WaterMove
pickWaterMove Squirtle = Bubble
pickWaterMove _ = WaterGun

pickGrassMove :: Grass -> GrassMove
pickGrassMove _ = VineWhip
```

So far so good, the type checker will make sure we can only create the right pokemon and they can only use the special abilities that go with their type.

Now we should make them battle. Our battles visual representation will show each pokemon with the move they used and the winner, like this:

``` haskell active
printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

main :: IO ()
main =
  printBattle "Water Pokemon" "Water Attack" "Fire Pokemon" "Fire Attack" "Water Pokemon"
```

Displaying the move is just for showing, we will decide the winner based on the pokemon type regardless of the move they used. Here's an example of a function to fight between Water and Fire types.
``` haskell
battleWaterVsFire :: Water -> Fire -> IO ()
battleWaterVsFire water fire = do
  printBattle (show water) moveOne (show fire) moveTwo (show water)
 where
  moveOne = show $ pickWaterMove water
  moveTwo = show $ pickFireMove fire

battleFireVsWater = flip battleWaterVsFire -- Same as above, but with flipped arguments
```

Now we mix it all together, define the remaining battle functions and we have a program!
``` haskell active
data Fire = Charmander | Charmeleon | Charizard deriving Show
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = VineWhip deriving Show

pickFireMove :: Fire -> FireMove
pickFireMove Charmander = Ember
pickFireMove Charmeleon = FlameThrower
pickFireMove Charizard = FireBlast

pickWaterMove :: Water -> WaterMove
pickWaterMove Squirtle = Bubble
pickWaterMove _ = WaterGun

pickGrassMove :: Grass -> GrassMove
pickGrassMove _ = VineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

-- show The battle functions
battleWaterVsFire :: Water -> Fire -> IO ()
battleWaterVsFire water fire = do
  printBattle (show water) moveOne (show fire) moveTwo (show water)
 where
  moveOne = show $ pickWaterMove water
  moveTwo = show $ pickFireMove fire

battleFireVsWater = flip battleWaterVsFire

battleGrassVsWater :: Grass -> Water -> IO ()
battleGrassVsWater grass water = do
  printBattle (show grass) moveOne (show water) moveTwo (show grass)
 where
  moveOne = show $ pickGrassMove grass
  moveTwo = show $ pickWaterMove water

battleWaterVsGrass = flip battleGrassVsWater

battleFireVsGrass :: Fire -> Grass -> IO ()
battleFireVsGrass fire grass = do
  printBattle (show fire) moveOne (show grass) moveTwo (show fire)
 where
  moveOne = show $ pickFireMove fire
  moveTwo = show $ pickGrassMove grass

battleGrassVsFire = flip battleFireVsGrass

main :: IO ()
main = do
  battleWaterVsFire Squirtle Charmander
  battleFireVsWater Charmeleon Wartortle
  battleGrassVsWater Bulbasaur Blastoise 
  battleWaterVsGrass Wartortle Ivysaur
  battleFireVsGrass Charmeleon Ivysaur
  battleGrassVsFire Venusaur Charizard
-- /show
```

# Introducing Type Classes

Oh my, that was repetitive: Imagine someone adding an Electric type pokemon like Pikachu into the mix, they would need to define their own battleElectricVs(Grass|Fire|Water) functions.
There are some patterns emerging here, which we may formalize to help people gain a better understanding of what pokemon are and help them create new ones.

Here's what we've learned:

* Pokemon use function to pick their move.
* Battles decide a winner and print a description of the battle.
  
We will define some type classes to formalize those, and while we're at it we will also address the funky naming scheme where each function includes the types it operates on.

At this point, I assume you're familiar with traditional type classes, if not, go ahead and read this chapter of the ["Learn You a Haskell for Great Good Book"](http://learnyouahaskell.com/types-and-typeclasses#typeclasses-101)

## The Pokemon Type Class

The Pokemon Type Class will represent the knowledge that pokemon pick their move. It lets us define pickMove to be overloaded, so that the same function can operate on different types for which the Type Class has been defined.

Contrary to 'vanilla' Type Classes, our Pokemon class will need to know about 2 types: The type of pokemon and the type of move to use, since the later will depend on the former. We need to enable a language extension in order to pass these 2 paramters to our Type Class: MultiParamTypeClasses.

Also notice we had to add constraints such that the pokemon type and move types are also 'showable'.

Here's the definition, along with some instances for the existing types of pokemon.
``` haskell active
{-# LANGUAGE MultiParamTypeClasses #-}
data Fire = Charmander | Charmeleon | Charizard deriving Show
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = VineWhip deriving Show

-- show
class (Show pokemon, Show move) => Pokemon pokemon move where
  pickMove :: pokemon -> move

instance Pokemon Fire FireMove where
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

instance Pokemon Water WaterMove where
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

instance Pokemon Grass GrassMove where
  pickMove _ = VineWhip

main :: IO ()
main = do
  print (pickMove Charmander :: FireMove)
  print (pickMove Blastoise :: WaterMove)
  print (pickMove Bulbasaur :: GrassMove)
-- show /
```

Notice how things start to get hairy: Since the Pokemon type and the Move type are handled as separate parameters in the Type Class, calling *pickMove* and just passing in a Charmander makes the type checker lookup an instance of the Pokemon Type Class which looks like *Pokemon Fire a*. Which we don't have, **so it fails**.

Try calling *pickMove* above without the type signatures, and look at the error that comes up.

By saying that we want *pickMove* to produce a FireMove we give the typechecker all the information it needs to decide to use the *Pokemon Fire FireMove* instance.

## The Battle type class

We already have pokemon who can pick their moves, now we need an abstraction that represents pokemon can fight each other, to replace the battle\*Vs\* family of functions.

So next we will be defining another MultiParamTypeClass, which will constrain it's arguments to also be Pokemon, which is already a MultiParamTypeClass. We will also define the instances for each type of battle we want to support.

``` haskell active
{-# LANGUAGE MultiParamTypeClasses #-}
data Fire = Charmander | Charmeleon | Charizard deriving Show
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = VineWhip deriving Show

class (Show pokemon, Show move) => Pokemon pokemon move where
  pickMove :: pokemon -> move

instance Pokemon Fire FireMove where
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

instance Pokemon Water WaterMove where
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

instance Pokemon Grass GrassMove where
  pickMove _ = VineWhip
  
printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"
  
-- show The battle Type Class
class (Pokemon pokemon move, Pokemon foe foeMove) => Battle pokemon move foe foeMove where
  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
   where
    move = pickMove pokemon
    foeMove = pickMove foe

instance Battle Water WaterMove Fire FireMove

main :: IO ()
main = do
  battle Squirtle Charmander
-- show /
```

When we run the snippet above we get an error, the Type Checker is telling us that in order to battle a Squirtle and a Charmander we need to have an instance of our Battle typeclass that works like "Battle Water move0 Fire foeMove0".

This brings us back to the issue we faced just a moment ago, when we defined the Pokemon MultiParameterTypeClass. In that case we solved it by giving a signature to the *pickMove* call.

Since the return type for battle is *IO ()* we're not as lucky this time.

A quick and extremely awful fix to this problem is making battle return the moves used, so that we can add a type signature whenever we call 'battle' to help the typechecker decide the instances used, so we will do that, for now :)

I'll go ahead and define *battle* to return an IO (move, foeMove). I'll also define all the remaining instances to end up with the same functionality we had on the first iteration, only that now everything should be a bit more formalized.

``` haskell active
{-# LANGUAGE MultiParamTypeClasses #-}
import Data.Tuple (swap)
data Fire = Charmander | Charmeleon | Charizard deriving Show
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = VineWhip deriving Show

class (Show pokemon, Show move) => Pokemon pokemon move where
  pickMove :: pokemon -> move

instance Pokemon Fire FireMove where
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

instance Pokemon Water WaterMove where
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

instance Pokemon Grass GrassMove where
  pickMove _ = VineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

-- show Our Battle Type Class, yuck
class (Pokemon pokemon move, Pokemon foe foeMove)
  => Battle pokemon move foe foeMove where
  battle :: pokemon -> foe -> IO (move, foeMove)
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
    return (move, foeMove)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
  
instance Battle Water WaterMove Fire FireMove
instance Battle Fire FireMove Water WaterMove where
  battle a b = fmap swap $ flip battle a b

instance Battle Grass GrassMove Water WaterMove
instance Battle Water WaterMove Grass GrassMove where
  battle a b = fmap swap $ flip battle a b
  
instance Battle Fire FireMove Grass GrassMove
instance Battle Grass GrassMove Fire FireMove where
  battle a b = fmap swap $ flip battle a b

main :: IO ()
main = do
  battle Squirtle Charmander :: IO (WaterMove, FireMove)
  battle Charmeleon Wartortle :: IO (FireMove, WaterMove)
  battle Bulbasaur Blastoise :: IO (GrassMove, WaterMove)
  battle Wartortle Ivysaur :: IO (WaterMove, GrassMove)
  battle Charmeleon Ivysaur :: IO (FireMove, GrassMove)
  battle Venusaur Charizard :: IO (GrassMove, FireMove)
  putStrLn "Done Fighting"
-- show /
```

# Introducing Type Families, finally!
So, our program so far kinda sucks. We have to carry around all these type signatures, and we even had to change the inner behaviour of one of our fuctions (battle) just so that we could use a type signature to help the compiler. I would go as far as to say that the current iteration of this program, while more formal and less repetitive, it's not such a big improvement after all the new uglyness we introduced.

But we can track down the uglyness to our Pokemon Type Class declaration. It has the type of pokemon and the type of move as two separate class variables: The typechecker doesn't know there is a relation between the pokemon type and the moves it can use. It will even allow us to define Pokemon instances where Water pokemon perform Fire moves! That's not right, but you could, go back and try creating an instance for Pokemon Fire WaterMove.

That's where type families come into play: They let us tell the typechecker that Fire type pokemon go with FireMove moves and so on.

## The Pokemon type class using type families.
In order to use Type Families we will need to enable the TypeFamilies extension.
Once we do, our Pokemon type class looks as following:

```haskell
class (Show a, Show (Move a)) => Pokemon a where
  data Move a :: *
  pickMove :: a -> Move a
```

We declare our Pokemon Type Class to have an argument, and an associated Move type. Move becomes a 'type function', returning the type of move to be used. This means that instead of 'FireMove' we will now have 'Move Fire', instead of 'WaterMove' we can have 'Move Water' and so on.

Notice how the constraint looks similar to the previous one, only that instead of 'Show move' we use 'Show (Move a))'. We need to enable yet another extension to be able to do this: FlexibleContexts.

Then, Haskell provides this nice sintax sugar so that we can define the actual associated data type constructors right where we define our instances.

Let's redefine all of our data types, our pokemon type class and all the required instances using Type Families:

``` haskell active
{-# LANGUAGE TypeFamilies, FlexibleContexts #-}
class (Show pokemon, Show (Move pokemon)) => Pokemon pokemon where
  data Move pokemon :: *
  pickMove :: pokemon -> Move pokemon

data Fire = Charmander | Charmeleon | Charizard deriving Show
instance Pokemon Fire where
  data Move Fire = Ember | FlameThrower | FireBlast deriving Show
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

data Water = Squirtle | Wartortle | Blastoise deriving Show
instance Pokemon Water where
  data Move Water = Bubble | WaterGun deriving Show
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
instance Pokemon Grass where
  data Move Grass = VineWhip deriving Show
  pickMove _ = VineWhip

main :: IO ()
main = do
  print $ pickMove Squirtle
  print $ pickMove Charmander
  print $ pickMove Ivysaur
```

That's pretty neat, right? We don't have to put any type signatures for pickMove to work! But don't scroll up just yet: Wait to see the full program on this third iteration and compare it to the second iteration for the full effect.

## The new Battle type class

So, now that we don't need those verbose type signatures, we can revert that ugly hack we introduced and go back to a version of our 'battle' function that just returns IO (). 

``` haskell
class (Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
```

Also, notice how Battle does not need to know about moves anymore, it's back to just battling pokemon pretty much like the naive implementation in our first iteration.

Let me go ahead again and define all the remaining instances for battle and give you the full program in it's third iteration:
```haskell active
{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, FlexibleContexts #-}
class (Show pokemon, Show (Move pokemon)) => Pokemon pokemon where
  data Move pokemon :: *
  pickMove :: pokemon -> Move pokemon

data Fire = Charmander | Charmeleon | Charizard deriving Show
instance Pokemon Fire where
  data Move Fire = Ember | FlameThrower | FireBlast deriving Show
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

data Water = Squirtle | Wartortle | Blastoise deriving Show
instance Pokemon Water where
  data Move Water = Bubble | WaterGun deriving Show
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
instance Pokemon Grass where
  data Move Grass = VineWhip deriving Show
  pickMove _ = VineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

class (Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
   where
    foeMove = pickMove foe
    move = pickMove pokemon

instance Battle Water Fire
instance Battle Fire Water where
  battle = flip battle

instance Battle Grass Water
instance Battle Water Grass where
  battle = flip battle

instance Battle Fire Grass
instance Battle Grass Fire where
  battle = flip battle
    
main :: IO ()
main = do
  battle Squirtle Charmander
  battle Charmeleon Wartortle
  battle Bulbasaur Blastoise
  battle Wartortle Ivysaur
  battle Charmeleon Ivysaur
  battle Venusaur Charizard
```
So that's it. Our program finally looks decent, we've improved it to the point were now we type check more, repeat less and have a clean API to offer to other developers.

Cool! We're done here! Hope you liked it!

Ok ok, I get it, you're having fun and you can't believe it's over so soon, besides you've looked at your browser's scroll bar and it still shows there's a bit more page to look at below.

So, let's add a feature to our Pokemon world:

We're currently defining Battle instances for the Water and Fire types as 'Battle Water Fire', and then we define 'Battle Water Fire' to be the same as the previous one with flipped arguments.
The first pokemon passed to battle is always the winner, and the output is always as follows:

```
-- Winner Pokemon move
-- Loser Pokemon move
-- Winner pokemon Wins.
```

Even when the instance has the loser first, the first line of output is always the winner's attack.

But let's change that and make it possible for Battle instances to decide who's the winner of the match, so that in some cases the output of the battle ends up being:

```
-- Loser Pokemon move
-- Winner Pokemon move
-- Winner pokemon Wins
```

## Associated Type Synonyms

When deciding to return Either of two things, you would regularly return an 'Either a b', but that's runtime, and we want the typechecker to make sure than when a Fire and a Water battle, the Water is always the winner.

So we define a new function in Battle called 'winner', which will receive the 2 contendants in the same order as they were passed to the *battle* function, and will decide who's the winner.

But returning either of the input pokemon yields a complication in the 'winner' function, have a look for yourself:

``` haskell
class (Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show pokemon)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
  
  winner :: pokemon -> foe -> ??? -- Is it 'pokemon' or 'foe'?
  
instance Battle Water Fire where
  winner :: Water -> Fire -> Water -- Water is the first type variable of the type class, namely: pokemon
  winner water _ = water

instance Battle Fire Water
  winner :: Fire -> Water -> Water -- Water is the second type variable of the type class, namely: foe
  winner _ water = water
```

See, for 'Battle Water Fire' instances the return type of 'winner' will be the same as the 'pokemon' type variable mentioned in the Type Class, while for 'Battle Fire Water' it's going to be 'foe'

Fortunately, type families also include support for associated type synonyms: On the Battle Type Class we define that we're going to have a "Winner pokemon foo" type, and it's up to instances to decide which type that would be.

We use 'type' and not 'data' because it'll be an alias to either 'pokemon' or 'foe'.

'Winner' alone is a type function with kind signature \* -> \* -> \*, which will receive both 'pokemon' and 'foo' and return which one to use.

We also define a default implementation for Winner, which chooses 'pokemon' when given 'pokemon' and 'foo'. 

``` haskell 
class (Show (Winner pokemon foe), Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  type Winner pokemon foe :: * -- this is the associated type 
  type Winner pokemon foe = pokemon -- this is the default implementation

  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show winner)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
    winner = pickWinner pokemon foe
  
  pickWinner :: pokemon -> foe -> (Winner pokemon foe)
```

So here it is, the final pokemon program where sometimes the foe wins the battle:
``` haskell active
{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, FlexibleContexts #-}
class (Show pokemon, Show (Move pokemon)) => Pokemon pokemon where
  data Move pokemon :: *
  pickMove :: pokemon -> Move pokemon

data Fire = Charmander | Charmeleon | Charizard deriving Show
instance Pokemon Fire where
  data Move Fire = Ember | FlameThrower | FireBlast deriving Show
  pickMove Charmander = Ember
  pickMove Charmeleon = FlameThrower
  pickMove Charizard = FireBlast

data Water = Squirtle | Wartortle | Blastoise deriving Show
instance Pokemon Water where
  data Move Water = Bubble | WaterGun deriving Show
  pickMove Squirtle = Bubble
  pickMove _ = WaterGun

data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show
instance Pokemon Grass where
  data Move Grass = VineWhip deriving Show
  pickMove _ = VineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle pokemonOne moveOne pokemonTwo moveTwo winner = do
  putStrLn $ pokemonOne ++ " used " ++ moveOne
  putStrLn $ pokemonTwo ++ " used " ++ moveTwo
  putStrLn $ "Winner is: " ++ winner ++ "\n"

class (Show (Winner pokemon foe), Pokemon pokemon, Pokemon foe) => Battle pokemon foe where
  type Winner pokemon foe :: *
  type Winner pokemon foe = pokemon

  battle :: pokemon -> foe -> IO ()
  battle pokemon foe = do
    printBattle (show pokemon) (show move) (show foe) (show foeMove) (show winner)
   where
    foeMove = pickMove foe
    move = pickMove pokemon
    winner = pickWinner pokemon foe
  
  pickWinner :: pokemon -> foe -> (Winner pokemon foe)

instance Battle Water Fire where
  pickWinner pokemon foe = pokemon

instance Battle Fire Water where
  type Winner Fire Water = Water
  pickWinner = flip pickWinner

instance Battle Grass Water where
  pickWinner pokemon foe = pokemon

instance Battle Water Grass where
  type Winner Water Grass = Grass
  pickWinner = flip pickWinner

instance Battle Fire Grass where
  pickWinner pokemon foe = pokemon

instance Battle Grass Fire where
  type Winner Grass Fire = Fire
  pickWinner = flip pickWinner
    
main :: IO ()
main = do
  battle Squirtle Charmander
  battle Charmeleon Wartortle
  battle Bulbasaur Blastoise
  battle Wartortle Ivysaur
  battle Charmeleon Ivysaur
  battle Venusaur Charizard
```

That's it, hope it clicked! Try adding your own Electric Pokemon at the end of the interactive snippet above!
