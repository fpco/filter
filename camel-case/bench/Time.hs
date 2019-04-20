import CamelCase
import CamelCase
import Criterion.Main
import System.IO

main :: IO ()
main = do
  devNull <- openFile "/dev/null" AppendMode
  let action fp = do
        lazy <- openFile fp ReadMode
        camelCase lazy devNull
        hClose lazy
  defaultMain
    [ bgroup
        "CamelCase"
        [ bench (show i) (nfIO (action fp))
        | i <- [100, 1000, 10000, 100000]
        , let fp = "lazy" ++ show i ++".txt"
        ]
    ]
