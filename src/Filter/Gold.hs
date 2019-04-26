{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Naive filter using bytestring.

module Filter.Gold where

import           Control.DeepSeq
import           Data.Bits hiding (shift)
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import qualified Data.ByteString.Unsafe as S
import           Data.Conduit
import qualified Data.Conduit.Binary as CB
import qualified Data.Conduit.List as CL
import           Data.Maybe
import           Data.Word
import           System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle input out (S8.pack -> query) = do
  runConduit
    (CB.sourceHandle input .| CB.lines .| CL.filter (filterLine query) .| CL.map (<> "\n") .|
     CB.sinkHandle out)

filterLine :: S8.ByteString -> S8.ByteString -> Bool
filterLine = isInfixOf

-- | Check whether one string is a substring of another. @isInfixOf
-- p s@ is equivalent to @not (null (findSubstrings p s))@.
isInfixOf :: ByteString -> ByteString -> Bool
isInfixOf p s = isJust (force (findSubstring p s))

-- | Break a string on a substring, returning a pair of the part of the
-- string prior to the match, and the rest of the string.
--
-- The following relationships hold:
--
-- > break (== c) l == breakSubstring (singleton c) l
--
-- and:
--
-- > findSubstring s l ==
-- >    if null s then Just 0
-- >              else case breakSubstring s l of
-- >                       (x,y) | null y    -> Nothing
-- >                             | otherwise -> Just (length x)
--
-- For example, to tokenise a string, dropping delimiters:
--
-- > tokenise x y = h : if null t then [] else tokenise x (drop (length x) t)
-- >     where (h,t) = breakSubstring x y
--
-- To skip to the first occurence of a string:
--
-- > snd (breakSubstring x y)
--
-- To take the parts of a string before a delimiter:
--
-- > fst (breakSubstring x y)
--
-- Note that calling `breakSubstring x` does some preprocessing work, so
-- you should avoid unnecessarily duplicating breakSubstring calls with the same
-- pattern.
--
breakSubstring :: ByteString -- ^ String to search for
               -> ByteString -- ^ String to search in
               -> (ByteString,ByteString) -- ^ Head and tail of string broken at substring
breakSubstring pat =
  case lp of
    0 -> \src -> (S8.empty,src)
    1 -> S.break (==(S.unsafeHead pat))
    _ -> if lp * 8 <= finiteBitSize n
             then shift
             else karpRabin
             where !n = (0 :: Word)
  where
    unsafeSplitAt i s = (S.unsafeTake i s, S.unsafeDrop i s)
    lp                = S.length pat
    karpRabin :: ByteString -> (ByteString, ByteString)
    karpRabin src
        = if S.length src < lp then (src,S.empty)
        else search (rollingHash $ S.unsafeTake lp src) lp
      where
        k           = 2891336453 :: Word32
        rollingHash = S.foldl' (\h b -> h * k + fromIntegral b) 0
        hp          = rollingHash pat
        m           = k ^ lp
        get = fromIntegral . S.unsafeIndex src
        search !hs !i
            = if hp == hs && pat == S.unsafeTake lp b then u
            else if S.length src <= i                    then (src,S.empty) -- not found
            else search hs' (i + 1)
          where
            u@(_, b) = unsafeSplitAt (i - lp) src
            hs' = hs * k +
                  get i -
                  m * get (i - lp)
    {-# INLINE karpRabin #-}

    shift :: ByteString -> (ByteString, ByteString)
    shift !src
        | S.length src < lp = (src,S.empty)
    shift !src        = search (intoWord $ S.unsafeTake lp src) lp
      where
        intoWord :: ByteString -> Word
        intoWord = S.foldl' (\w b -> (w `shiftL` 8) .|. fromIntegral b) 0
        wp   = intoWord pat
        mask = (1 `shiftL` (8 * lp)) - 1
        search !w !i
            | w == wp         = unsafeSplitAt (i - lp) src
            | S.length src <= i = (src, S.empty)
        search w i       = search w' (i + 1)
          where
            b  = fromIntegral (S.unsafeIndex src i)
            w' = mask .&. ((w `shiftL` 8) .|. b)
    {-# INLINE shift #-}

-- | Get the first index of a substring in another string,
--   or 'Nothing' if the string is not found.
--   @findSubstring p s@ is equivalent to @listToMaybe (findSubstrings p s)@.
findSubstring :: ByteString -- ^ String to search for.
              -> ByteString -- ^ String to seach in.
              -> Maybe Int
findSubstring pat src
    | S.null pat && S.null src = Just 0
    | S.null b = Nothing
    where (_, b) = breakSubstring pat src
findSubstring pat src = Just (S.length a)
                      where (a, _) = breakSubstring pat src
