import CamelCase
import System.IO

main :: IO ()
main = do
  lazy100000 <- openFile "lazy100000.txt" ReadMode
  devNull <- openFile "/dev/null" AppendMode
  camelCase lazy100000 devNull
