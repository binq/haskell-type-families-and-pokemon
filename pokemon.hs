{-# LANGUAGE FlexibleContexts, MultiParamTypeClasses, TypeFamilies #-}

module Pokemon where

import Text.Printf (printf)
import Data.List   (intercalate)
import Data.Tuple  (swap)

class (Show a, Show (Move a)) => Pokemon a where
  data Move pokemon :: *
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

class (Pokemon x, Pokemon y) => Battle x y where
  battle :: x -> y -> IO ()
  battle x y = printBattle (show x) (show . pickMove $ x) (show y) (show . pickMove $ y) (show x)

instance Battle Water Fire
instance Battle Fire Water where
  battle = flip battle

instance Battle Grass Water
instance Battle Water Grass where
  battle = flip battle

instance Battle Fire Grass
instance Battle Grass Fire where
  battle = flip battle

append = flip (++)
newline = "\n"

battleTemplate = append newline . append newline . intercalate newline $
  [
    "%s used %s",
    "%s used %s",
    "Winner is: %s"
  ]

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle x xm y ym w = printf battleTemplate x xm y ym w
