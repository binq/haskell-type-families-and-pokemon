module Main where

import Pokemon

main :: IO ()
main = do
  battle Squirtle Charmander
  battle Charmeleon Wartortle
  battle Bulbasaur Blastoise
  battle Wartortle Ivysaur
  battle Charmeleon Ivysaur
  battle Venusaur Charizard
  battle Pikachu Venusaur
  battle Pikachu Charizard
  battle Pikachu Squirtle
  putStrLn "Done Fighting"