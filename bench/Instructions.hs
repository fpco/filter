import qualified Filter.Blue
import qualified Filter.Gold
import qualified Filter.Green
import qualified Filter.Pink
import qualified Filter.Silver
import System.CPUInstructionCounter
import System.IO

main :: IO ()
main = do
  devNull <- openFile "/dev/null" AppendMode
  mapM_
    (\(label, impl) ->
       do putStrLn ("\n" ++ label)
          mapM
            (\word -> do
               inh <- openFile "assets/war-and-peace.txt" ReadMode
               (_, sumInstrs) <- withInstructionsCounted (impl inh devNull word)
               putStrLn (word ++ "\tCPU instructions: " ++ show sumInstrs))
            ["he","said","Prince"])
    [ ("Pink", Filter.Pink.filterHandle)
    , ("Blue", Filter.Blue.filterHandle)
    , ("Silver", Filter.Silver.filterHandle)
    , ("Green", Filter.Green.filterHandle)
    , ("Gold", Filter.Gold.filterHandle)
    ]
