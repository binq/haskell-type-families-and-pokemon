module Main where

import Pokemon

main :: IO ()
main = do
  battleWaterVsFire Squirtle Charmander
  battleFireVsWater Charmeleon Wartortle
  battleGrassVsWater Bulbasaur Blastoise
  battleWaterVsGrass Wartortle Ivysaur
  battleFireVsGrass Charmeleon Ivysaur
  battleGrassVsFire Venusaur Charizard
