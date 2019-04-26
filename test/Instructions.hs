{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NumericUnderscores #-}
import           Data.String
import qualified Data.ByteString as S
import           Data.ByteString (ByteString)
import           Control.Exception
import           Filter
import           System.CPUInstructionCounter
import           System.IO

data Result = OK | INVALID deriving (Show, Eq)

main :: IO ()
main = do
  filterStr
  fileIO

filterStr :: IO ()
filterStr = do
  let !pat = fromString "his"
      !bs =
        fromString
          (replicate 4096 'x' <>
           "maximum. Kut\195\186zov saw this and merely sighed and shrugged his shoulders.\r")
  (_, result) <- withInstructionsCounted (evaluate (filterLine pat bs))
  putStrLn ("filterLine: " ++ "\tCPU instructions: " ++ show result)

fileIO :: IO ()
fileIO = do
  devNull <- openFile "/dev/null" AppendMode
  putStrLn ""
  results <-
    mapM
      (\(word, limit) -> do
         inh <- openFile "war-and-peace.txt" ReadMode
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
