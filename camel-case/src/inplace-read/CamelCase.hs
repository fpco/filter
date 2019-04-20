{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MultiWayIf #-}

module CamelCase (camelCase) where

import           Control.Concurrent
import qualified Data.Vector.Storable.Mutable as SVM
import           Data.Word
import           GHC.IO.FD
import           GHC.IO.Handle
import           GHC.IO.Handle.Internals
import           GHC.IO.Handle.Types
import           GHC.Ptr
import           System.IO
import           System.IO (stdout)
import           System.IO.Efficient
import           Unsafe.Coerce

camelCase :: Handle -> Handle -> IO ()
camelCase input output = do
  buf <- SVM.new bufferSize
  SVM.unsafeWith
    buf
    (\ptr -> wantReadableHandle_ "hGetBuf" input $ \Handle__ {haDevice = dev} ->
      (do
        let fd = fdFD (unsafeCoerce dev)
        let loop was_space0 = do
              size <- hGetBufFd fd ptr bufferSize
              if size == 0
                then pure ()
                else if True
                       then loop False
                       else let reader (!dest, !src, !was_space)
                                  | src < size = do
                                    b <- pure 0
                                    b <- SVM.read buf src
                                    let ord =
                                          fromIntegral . fromEnum :: Char -> Word8
                                    if | b == ord '\n' ||
                                           (ord 'A' <= b && b <= ord 'Z') ->
                                         do SVM.write buf dest b
                                            reader (dest + 1, src + 1, False)
                                       | ord 'a' <= b && b <= ord 'z' ->
                                         do SVM.write
                                              buf
                                              dest
                                              (if was_space
                                                 then b - 32
                                                 else b)
                                            reader (dest + 1, src + 1, False)
                                       | otherwise ->
                                         reader (dest, src + 1, True)
                                  | otherwise = pure (dest, was_space)
                                writer :: Ptr Word8 -> Int -> IO ()
                                writer (!start) (!dest)
                                  | dest > 0 = do
                                    written <-
                                      hPutBufNonBlocking output start dest
                                    writer
                                      (plusPtr start written)
                                      (dest - written)
                                  | otherwise = pure ()
                             in do (dest0, was_space) <-
                                     reader (0, 0, was_space0)
                                   SVM.unsafeWith buf (\ptr -> writer ptr dest0)
                                   loop was_space
        loop False))
  where
    bufferSize = 4096
