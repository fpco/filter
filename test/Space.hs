{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NumericUnderscores #-}

-- | Test allocation limits.

import           Control.Applicative
import           Control.Monad
import qualified Filter
import           System.IO
import           Weigh

main :: IO ()
main =
  mainWith
    (do setColumns [Case, Allocated, Max, GCs, Check]
        wgroup
          "war-and-peace"
          (mapM_
             (\word ->
                validateAction
                  word
                  (const
                     (do file <- openFile "war-and-peace.txt" ReadMode
                         devNull <- openFile "/dev/null" AppendMode
                         Filter.filterHandle file devNull word
                         hClose file
                         hClose devNull))
                  ()
                  validation)
             ["he", "said", "Prince"]))
  where
    validation weight = residency <|> allocations
      where
        allocations = do
          guard (weightAllocatedBytes weight > 70_000_000)
          pure "Total allocated exceeded."
        residency = do
          guard (weightMaxBytes weight > 20_000)
          pure "Max residency exceeded."
