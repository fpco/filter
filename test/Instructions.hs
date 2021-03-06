{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NumericUnderscores #-}
import           Data.Bifunctor
import           Statistics.Regression
import qualified Data.Vector as V
import           Data.Vector (Vector)
import           Data.List
import           Text.Printf
import           Data.String
import           Control.Exception
import           Filter
import           System.CPUInstructionCounter
import           System.IO
import qualified Data.Vector.Unboxed as UV

data Result = OK | INVALID deriving (Show, Eq)


datapoints :: [Vector Double]
datapoints =
  map
    V.fromList
    [ [1, 597]
    , [10, 723]
    , [100, 1983]
    , [1000, 14583]
    , [10000, 140583]
    , [100000, 1400583]
    , [1000000, 14000583]
    ]

main :: IO ()
main = do
  putStrLn ""
  filterStr
  putStrLn ""
  fileIO

filterStr :: IO ()
filterStr = do
  results <-
    mapM
      (\i -> do
         let !pat = fromString "this"
             !bs = fromString (replicate i 'x' <> "this")
         (_, result) <- withInstructionsCounted (evaluate (filterLine pat bs))
         pure (i, result))
      (take 7 (iterate (* 10) 1))
  let ([per, constant], rSquared) =
        first
          UV.toList
          (olsRegress
             [UV.fromList (map (fromIntegral . fst) results)]
             (UV.fromList (map (fromIntegral . snd) results)))
  putStrLn
    (tablize
       ([(True, "Size"), (True, "Instructions")] :
        map
          (\(size, instructions) ->
             [(False, show size), (False, show instructions)])
          results))
  putStrLn ""
  printf "Constant factor: %.3f instructions per call\n" constant
  printf "Instructions per byte: %.0f\n" per
  printf "Goodness of fit R²: %f\n" rSquared

fileIO :: IO ()
fileIO = do
  devNull <- openFile "/dev/null" AppendMode
  results <-
    mapM
      (\(word, limit) -> do
         inh <- openFile "assets/war-and-peace.txt" ReadMode
         (_, sumInstrs) <-
           withInstructionsCounted (filterHandle inh devNull word)
         let result =
               if sumInstrs <= limit
                 then OK
                 else INVALID
         putStrLn
           (word ++
            "\tCPU instructions: " ++ show sumInstrs ++ " " ++ show result)
         pure result)
      [ ("he", 200_000_000)
      , ("said", 105_000_000)
      , ("Prince", 105_000_000)
      , ("Haskell", 100_000_000)
      ]
  if any (== INVALID) results
    then error "Invalid results"
    else pure ()

-- | Make a table out of a list of rows.
tablize :: [[(Bool,String)]] -> String
tablize xs =
  intercalate "\n" (map (intercalate "  " . map fill . zip [0 ..]) xs)
  where
    fill (x', (left', text')) =
      printf ("%" ++ direction ++ show width ++ "s") text'
      where
        direction =
          if left'
            then "-"
            else ""
        width = maximum (map (length . snd . (!! x')) xs)
