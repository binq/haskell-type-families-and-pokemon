module Pokemon where

import Text.Printf (printf)
import Data.List   (intercalate)

data Fire = Charmander | Charmeleon | Charizard deriving Show
data Water = Squirtle | Wartortle | Blastoise deriving Show
data Grass = Bulbasaur | Ivysaur | Venusaur deriving Show

data FireMove = Ember | FlameThrower | FireBlast deriving Show
data WaterMove = Bubble | WaterGun deriving Show
data GrassMove = WineWhip deriving Show

append = flip (++)
newline = "\n"

battleTemplate = append newline . append newline . intercalate newline $
  [
    "%s used %s",
    "%s used %s",
    "Winner is: %s"
  ]

pickFireMove :: Fire -> FireMove
pickFireMove Charmander = Ember
pickFireMove Charmeleon = FlameThrower
pickFireMove Charizard = FireBlast

pickWaterMove :: Water -> WaterMove
pickWaterMove Squirtle = Bubble
pickWaterMove _ = WaterGun

pickGrassMove :: Grass -> GrassMove
pickGrassMove _ = WineWhip

printBattle :: String -> String -> String -> String -> String -> IO ()
printBattle x xMove y yMove w = printf battleTemplate x xMove y yMove w

battleWaterVsFire :: Water -> Fire -> IO ()
battleWaterVsFire x y = printBattle (show x) (show . pickWaterMove $ x) (show y) (show . pickFireMove $ y) (show x)

battleFireVsWater :: Fire -> Water -> IO ()
battleFireVsWater = flip battleWaterVsFire

battleGrassVsWater :: Grass -> Water -> IO ()
battleGrassVsWater x y = printBattle (show x) (show . pickGrassMove $ x) (show y) (show . pickWaterMove $ y) (show x)

battleWaterVsGrass :: Water -> Grass -> IO ()
battleWaterVsGrass = flip battleGrassVsWater

battleFireVsGrass :: Fire -> Grass -> IO ()
battleFireVsGrass x y = printBattle (show x) (show . pickFireMove $ x) (show y) (show . pickGrassMove $ y) (show x)

battleGrassVsFire :: Grass -> Fire -> IO ()
battleGrassVsFire = flip battleFireVsGrass