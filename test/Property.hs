{-# LANGUAGE OverloadedStrings #-}

-- | Property tests.

import qualified Data.ByteString.Char8 as S8
import           Data.List
import           Filter (filterLine)
import           Test.Hspec
import           Test.QuickCheck
import Data.GenValidity.ByteString ()
import Test.Hspec.QuickCheck
import Test.Validity

main :: IO ()
main = hspec spec

spec :: SpecWith ()
spec =
  describe "filterLine" $
  modifyMaxSize (* 100) $ do
    it "finds nothing in an empty bytestring" $
      forAll (genValid `suchThat` (not . S8.null)) $ \needle ->
        filterLine needle "" `shouldBe` False
    it "finds the entire haystack if the needle and the haystack are the same" $
      forAll genValid $ \needle -> filterLine needle needle `shouldBe` True
    it "finds nothing in a needle that is too long" $
      forAllValid $ \haystack ->
        forAll (genValid `suchThat` ((> S8.length haystack) . S8.length)) $ \needle ->
          filterLine needle haystack `shouldBe` False
    it "filterLine = isInfixOf" $
      forAllValid $ \x ->
        forAllValid $ \xs ->
          cover 30 (S8.length x < S8.length xs) "short needle" $
          cover 30 (S8.length x > S8.length xs) "long needle" $
          filterLine x xs `shouldBe` isInfixOf (S8.unpack x) (S8.unpack xs)
