{-# LANGUAGE FlexibleContexts, MultiParamTypeClasses, NoImplicitPrelude, TypeFamilies #-}

module Pokemon where

import Text.Printf               (printf)
import Data.Yaml                 (decodeFile)
import Prelude                   (IO, Show, String, ($), (.), (>>=), id, maybe, return, show, undefined)

class (Show a, Show (Move a)) => Pokemon a where
  data Move a :: *

  pickMove :: a -> Move a

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
  data Move Grass = WineWhip deriving Show

  pickMove _ = WineWhip

data Electric = Pikachu deriving Show
instance Pokemon Electric where
  data Move Electric = ThunderShock deriving Show

  pickMove _ = ThunderShock

class (Show (Winner x y), Pokemon x, Pokemon y) => Battle x y where
  type Winner x y :: *

  winner :: x -> y -> (Winner x y)

  battle :: x -> y -> IO ()
  battle x y = printBattle (show x) (show . pickMove $ x) (show y) (show . pickMove $ y) (show $ winner x y)

instance Battle Water Fire where
  type Winner Water Fire = Water

  winner x y = x

instance Battle Fire Water where
  type Winner Fire Water = Water

  winner x y = y

instance Battle Grass Water where
  type Winner Grass Water = Grass

  winner x y = x

instance Battle Water Grass where
  type Winner Water Grass = Grass

  winner x y = y

instance Battle Fire Grass where
  type Winner Fire Grass = Fire

  winner x y = x

instance Battle Grass Fire where
  type Winner Grass Fire = Fire

  winner x y = y

instance Battle Fire Electric where
  type Winner Fire Electric = Fire

  winner x y = x

instance Battle Electric Fire where
  type Winner Electric Fire = Fire

  winner x y = y

instance Battle Electric Water where
  type Winner Electric Water = Electric

  winner x y = x

instance Battle Water Electric where
  type Winner Water Electric = Electric

  winner x y = y

instance Battle Electric Grass where
  type Winner Electric Grass = Electric

  winner x y = x

instance Battle Grass Electric where
  type Winner Grass Electric = Electric

  winner x y = y

getBattleTemplate :: IO String
getBattleTemplate = decodeFile "template.yaml" >>= return . maybe undefined id

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle x xm y ym w = do
  t <- getBattleTemplate
  printf t x xm y ym w
