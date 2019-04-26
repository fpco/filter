import qualified Filter.Blue
import qualified Filter.Gold
import qualified Filter.Green
import qualified Filter.Pink
import qualified Filter.Silver
import Criterion.Main
import System.IO

main :: IO ()
main = do
  devNull <- openFile "/dev/null" AppendMode
  let action act fp wrd = do
        lazy <- openFile fp ReadMode
        act lazy devNull wrd
        hClose lazy
  defaultMain
    [ bgroup
        "War and Peace"
        [ bench
          (impl ++ "/" ++ wrd)
          (nfIO (action act ("war-and-peace.txt") wrd))
        | (impl, act) <-
            [ ("Pink", Filter.Pink.filterHandle)
            , ("Blue", Filter.Blue.filterHandle)
            , ("Silver", Filter.Silver.filterHandle)
            , ("Green", Filter.Green.filterHandle)
            , ("Gold", Filter.Gold.filterHandle)
            ]
        , wrd <- ["he", "said", "Prince"]
        ]
    ]
