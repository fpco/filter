-- |

import Data.List
import Data.String
import Filter (filterLine)
import Test.Hspec
import Test.QuickCheck

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  describe
    "filterLine"
    (it
       "filterLine = isInfixOf"
       (property
          (\x xs -> filterLine (fromString x) (fromString xs) == isInfixOf x xs)))
