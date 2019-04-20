{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE RecordWildCards #-}
-- |

module System.IO.Efficient (hGetBufFd) where

import           Control.Concurrent
import           Data.IORef
import           Data.Typeable ( cast )
import           Data.Word
import           Foreign.C.Types
import           Foreign.Ptr
import           GHC.IO.Buffer
import qualified GHC.IO.BufferedIO as Buffered
import qualified GHC.IO.Device as RawIO
import           GHC.IO.Exception
import           GHC.IO.FD
import           GHC.IO.Handle
import           GHC.IO.Handle.Internals
import           GHC.IO.Handle.Types
import           Prelude hiding (read)
import           Unsafe.Coerce

hGetBufFd :: CInt -> Ptr a -> Int -> IO Int
hGetBufFd h buf count = do

    -- case cast dev of
    --   Just (fd :: FD) -> do
        v <- read h buf count
        yield
        pure v
      -- Nothing -> throwErr "not a file descriptor"
  where


hGetBufOriginal :: Handle -> Ptr a -> Int -> IO Int
hGetBufOriginal h ptr count
  | count == 0 = return 0
  | count <  0 = illegalBufferSize h "hGetBuf" count
  | otherwise =
      wantReadableHandle_ "hGetBuf" h $ \ h_@Handle__{..} -> do
         flushCharReadBuffer h_
         buf@Buffer{ bufRaw=raw, bufR=w, bufL=r, bufSize=sz }
            <- readIORef haByteBuffer
         if isEmptyBuffer buf
            then bufReadEmpty    h_ buf (castPtr ptr) 0 count
            else bufReadNonEmpty h_ buf (castPtr ptr) 0 count

illegalBufferSize :: Handle -> String -> Int -> IO a
illegalBufferSize handle fn sz =
        ioException (IOError (Just handle)
                            InvalidArgument  fn
                            ("illegal buffer size " ++ showsPrec 9 sz [])
                            Nothing Nothing)

bufReadEmpty :: Handle__ -> Buffer Word8 -> Ptr Word8 -> Int -> Int -> IO Int
bufReadEmpty h_@Handle__{..}
             buf@Buffer{ bufRaw=raw, bufR=w, bufL=r, bufSize=sz }
             ptr so_far count
 | count > sz, Just fd <- cast haDevice = loop fd 0 count
 | otherwise = do
     (r,buf') <- Buffered.fillReadBuffer haDevice buf
     if r == 0
        then return so_far
        else do writeIORef haByteBuffer buf'
                bufReadNonEmpty h_ buf' ptr so_far count
 where
  loop :: FD -> Int -> Int -> IO Int
  loop fd off bytes | bytes <= 0 = return (so_far + off)
  loop fd off bytes = do
    r <- RawIO.read (fd::FD) (ptr `plusPtr` off) bytes
    if r == 0
        then return (so_far + off)
        else loop fd (off + r) (bytes - r)


bufReadNonEmpty :: Handle__ -> Buffer Word8 -> Ptr Word8 -> Int -> Int -> IO Int
bufReadNonEmpty h_@Handle__{..}
                buf@Buffer{ bufRaw=raw, bufR=w, bufL=r, bufSize=sz }
                ptr !so_far !count
 = do
        let avail = w - r
        if (count < avail)
           then do
                copyFromRawBuffer ptr raw r count
                writeIORef haByteBuffer buf{ bufL = r + count }
                return (so_far + count)
           else do

                copyFromRawBuffer ptr raw r avail
                let buf' = buf{ bufR=0, bufL=0 }
                writeIORef haByteBuffer buf'
                let remaining = count - avail
                    so_far' = so_far + avail
                    ptr' = ptr `plusPtr` avail

                if remaining == 0
                   then return so_far'
                   else bufReadEmpty h_ buf' ptr' so_far' remaining

copyToRawBuffer :: RawBuffer e -> Int -> Ptr e -> Int -> IO ()
copyToRawBuffer raw off ptr bytes =
 withRawBuffer raw $ \praw ->
   do _ <- memcpy (praw `plusPtr` off) ptr (fromIntegral bytes)
      return ()

copyFromRawBuffer :: Ptr e -> RawBuffer e -> Int -> Int -> IO ()
copyFromRawBuffer ptr raw off bytes =
 withRawBuffer raw $ \praw ->
   do _ <- memcpy ptr (praw `plusPtr` off) (fromIntegral bytes)
      return ()

foreign import ccall unsafe "memcpy"
   memcpy :: Ptr a -> Ptr a -> CSize -> IO (Ptr ())

foreign import ccall unsafe "read"
   read :: CInt -> Ptr a -> Int -> IO Int
