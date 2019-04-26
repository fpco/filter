{-# LANGUAGE OverloadedStrings #-}

-- | Existential tests.

import           Control.Exception
import           Data.ByteString (ByteString)
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           Filter
import           System.IO
import           System.IO.Temp
import           Test.Hspec

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec = do
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
  describe
    "Predicate"
    (do it "Empty" (shouldBe (filterLine "" "") True)
        it "Empty one side" (shouldBe (filterLine "maximum" "") False)
        it "Empty other side" (shouldBe (filterLine "" "maximum") True)
        it "Same length" (shouldBe (filterLine "maximum" "maximum") True)
        it "Single char" (shouldBe (filterLine "m" "m") True)
        it
          "Basic test"
          (shouldBe
             (filterLine
                "maximum"
                "maximum. Kut\195\186zov saw this and merely sighed and shrugged his shoulders.\r")
             True)
        it "Large pat" (shouldBe (filterLine "shoulders" "five") False)
        it
          "Large pat: same length"
          (shouldBe (filterLine "shoulders" "SHOULDERS") False)
        it
          "Large pat: larger output"
          (shouldBe (filterLine "shoulders" maximumOutput) True))

maximumOutput :: ByteString
maximumOutput =
  "maximum. Kut\195\186zov saw this and merely sighed and shrugged his shoulders.\r\n\
  \accessible, we get the conception of a maximum of inevitability and a\r\n\
  \inevitability and a maximum of freedom.\r\n\
  \interpreted to make the maximum disclaimer or limitation permitted by\r\n"
