-- |

import           Data.ByteString (ByteString)
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           Data.List
import           Data.String
import           Filter (filterLine)
import           Test.Hspec
import           Test.QuickCheck

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  describe
    "filterLine"
    (it
       "filterLine = isInfixOf"
       (property
          (\x xs ->
             filterLine (fromString x) (fromString xs) ==
             isInfixOf (S.unpack (S8.pack x)) (S.unpack (S8.pack xs)))))
