import CamelCase
import System.IO
import Weigh

main :: IO ()
main = do
  lazy100 <- openFile "lazy100.txt" ReadMode
  lazy1000 <- openFile "lazy1000.txt" ReadMode
  lazy10000 <- openFile "lazy10000.txt" ReadMode
  lazy100000 <- openFile "lazy100000.txt" ReadMode
  mainWith
    (do io "lazy100" camelCase' lazy100
        io "lazy1000" camelCase' lazy1000
        io "lazy10000" camelCase' lazy10000
        io "lazy100000" camelCase' lazy100000
        setColumns [Case, Allocated, GCs, Max, Live])
  where camelCase' i = camelCase i stdout
