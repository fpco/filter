-- |

import           Control.Monad
import           System.Exit
import qualified System.Hatrace as Hatrace
import           Test.Hspec

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  before_
    assertNoChildren
    (describe
       "filterLine"
       (it
          "filterLine = isInfixOf"
          (Hatrace.traceForkProcess "echo" ["hello"] `shouldReturn` ExitSuccess)))

-- | Assertion we run before each test to ensure no leftover child processes
-- that could affect subsequent tests.
--
-- This is obviously not effective if tests were to run in parallel.
assertNoChildren :: IO ()
assertNoChildren = do
  hasChildren <- Hatrace.doesProcessHaveChildren
  when hasChildren $ do
    error "You have children you don't know of, probably from a previous test"
