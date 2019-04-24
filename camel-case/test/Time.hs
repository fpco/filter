import CamelCase
import System.CPUInstructionCounter
import System.IO

main :: IO ()
main = do
  devnull <- openFile "/dev/null" AppendMode
  lazy100 <- openFile "lazy100.txt" ReadMode
  lazy1000 <- openFile "lazy1000.txt" ReadMode
  lazy10000 <- openFile "lazy10000.txt" ReadMode
  lazy100000 <- openFile "lazy100000.txt" ReadMode
  (_, sumInstrs) <- withInstructionsCounted (camelCase' lazy100)
  putStrLn ("lazy100: " ++ show sumInstrs ++ " CPU instructions")
  (_, sumInstrs1) <- withInstructionsCounted (camelCase' lazy1000)
  putStrLn ("lazy1000: " ++ show sumInstrs1 ++ " CPU instructions")
  (_, sumInstrs2) <- withInstructionsCounted (camelCase' lazy10000)
  putStrLn ("lazy10000: " ++ show sumInstrs2 ++ " CPU instructions")
  (_, sumInstrs3) <- withInstructionsCounted (camelCase' lazy100000)
  putStrLn ("lazy100000: " ++ show sumInstrs3 ++ " CPU instructions")
  where camelCase' i = camelCase i devnull
