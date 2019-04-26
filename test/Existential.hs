{-# LANGUAGE OverloadedStrings #-}

-- | Existential tests.

import           Control.Exception
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import           Filter
import           System.IO
import           System.IO.Temp
import           Test.Hspec

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  describe
    "Sample file"
    (do it
          "war-and-peace.txt"
          (do bracket
                (openFile "war-and-peace.txt" ReadMode)
                hClose
                (\inp ->
                   withSystemTempFile
                     "filter"
                     (\fp out -> do
                        filterHandle inp out "maximum"
                        hClose out
                        bs <- S.readFile fp
                        shouldBe bs maximumOutput))))

maximumOutput :: ByteString
maximumOutput =
  "maximum. Kut\195\186zov saw this and merely sighed and shrugged his shoulders.\r\n\
  \accessible, we get the conception of a maximum of inevitability and a\r\n\
  \inevitability and a maximum of freedom.\r\n\
  \interpreted to make the maximum disclaimer or limitation permitted by\r\n"
