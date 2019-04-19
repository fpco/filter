module CamelCase (camelCase) where

import Data.Char (toUpper)
import System.IO

camelCase :: Handle -> IO ()
camelCase h = interactHandle simple
  where interactHandle        ::  (String -> String) -> IO ()
        interactHandle f      =   do s <- hGetContents h
                                     putStr (f s)

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
