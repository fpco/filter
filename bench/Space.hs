{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NumericUnderscores #-}

-- | Test allocation limits.

import           Control.Applicative
import           Control.Monad
import qualified Filter.Blue
import qualified Filter.Gold
import qualified Filter.Green
import qualified Filter.Pink
import qualified Filter.Silver
import           System.IO
import           Weigh

main :: IO ()
main =
  mainWith
    (do setColumns [Case, Allocated, Max, GCs, Check]
        wgroup
          "war-and-peace"
          (mapM_
             (\(name, filterHandle) ->
                wgroup
                  name
                  ((mapM_
                      (\word ->
                         validateAction
                           word
                           (const
                              (do file <- openFile "war-and-peace.txt" ReadMode
                                  devNull <- openFile "/dev/null" AppendMode
                                  filterHandle file devNull word
                                  hClose file
                                  hClose devNull))
                           ()
                           validation)
                      ["he", "said", "Prince"])))
             [ ("Pink", Filter.Pink.filterHandle)
             , ("Blue", Filter.Blue.filterHandle)
             , ("Silver", Filter.Silver.filterHandle)
             , ("Green", Filter.Green.filterHandle)
             , ("Gold", Filter.Gold.filterHandle)
             ]))
  where
    validation weight = residency <|> allocations
      where
        allocations = do
          guard (weightAllocatedBytes weight > 33000000)
          pure "Total allocated exceeded."
        residency = do
          guard (weightMaxBytes weight > 20000)
          pure "Max residency exceeded."
