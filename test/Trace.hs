-- |

import           System.Exit
import qualified System.Hatrace as Hatrace
import           Test.Hspec

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  describe
    "filterLine"
    (it
       "filterLine = isInfixOf"
       (Hatrace.traceForkProcess "echo" ["hello"] `shouldReturn` ExitSuccess))
