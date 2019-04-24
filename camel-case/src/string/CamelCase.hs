module CamelCase (camelCase) where

import Data.Char (toUpper)
import System.IO

camelCase :: Handle -> Handle -> IO ()
camelCase h out = interactHandle simple
  where interactHandle        ::  (String -> String) -> IO ()
        interactHandle f      =   do s <- hGetContents h
                                     hPutStr out (f s)

simple :: String -> String
simple = unlines . map simple' . lines

simple' :: [Char] -> [Char]
simple' = concat . map upperFirst . words . map toSpace

toSpace :: Char -> Char
toSpace c
  | 'A' <= c && c <= 'Z' = c
  | 'a' <= c && c <= 'z' = c
  | otherwise = ' '

upperFirst :: [Char] -> [Char]
upperFirst (x:xs) = toUpper x : xs
upperFirst [] = []
