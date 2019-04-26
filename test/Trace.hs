-- |

import           Control.Monad
import           Filter
import           System.Environment
import           System.Exit
import qualified System.Hatrace as Hatrace
import           System.IO
import           Test.Hspec

main :: IO ()
main = do
  hspec spec

spec :: SpecWith ()
spec =
  before_
    assertNoChildren
    (describe
       "filterLine"
       (it
          "filterLine = isInfixOf"
          (Hatrace.traceForkProcess "filter" ["-f","assets/simple.txt","maximum"] `shouldReturn` ExitSuccess)))

-- | Assertion we run before each test to ensure no leftover child processes
-- that could affect subsequent tests.
--
-- This is obviously not effective if tests were to run in parallel.
assertNoChildren :: IO ()
assertNoChildren = do
  hasChildren <- Hatrace.doesProcessHaveChildren
  when hasChildren $ do
    error "You have children you don't know of, probably from a previous test"
