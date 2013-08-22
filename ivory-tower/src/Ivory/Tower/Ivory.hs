{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE Rank2Types #-}

module Ivory.Tower.Ivory where

import Ivory.Language

import Ivory.Tower.Types
import Ivory.Tower.Tower
import Ivory.Tower.Task
import Ivory.Tower.Node

-- DataPort Interface ----------------------------------------------------------

-- | Atomic read of shared data, copying to local reference. Always succeeds.
--   Takes a 'DataReader'.
readData :: (GetAlloc eff ~ Scope cs, IvoryArea area)
         => DataReader area -> Ref s area -> Ivory eff ()
readData reader ref = dr_extern reader ref

-- | Atomic write to shared data, copying from local reference. Always
--   succeeds. Takes a 'DataWriter'.
writeData :: (GetAlloc eff ~ Scope cs, IvoryArea area)
          => DataWriter area -> ConstRef s area -> Ivory eff ()
writeData writer ref = dw_extern writer ref

-- Special OS function interface -----------------------------------------------

-- | Use an 'Ivory.Tower.Types.OSGetTimeMillis' implementation in an Ivory
--   monad context. We unwrap so the implementation can bind to the
--   Ivory effect scope
getTimeMillis :: OSGetTimeMillis -> Ivory eff Uint32
getTimeMillis = unOSGetTimeMillis

-- Event Interface--------------------------------------------------------------

-- | Nonblocking emit. Indicates success in return value.
emit :: (SingI n, IvoryArea area, GetAlloc eff ~ Scope cs)
   => ChannelEmitter n area -> ConstRef s area -> Ivory eff IBool
emit c r = ce_extern_emit c r
-- | Nonblocking emit. Fails silently.
emit_ :: (SingI n, IvoryArea area, GetAlloc eff ~ Scope cs)
   => ChannelEmitter n area -> ConstRef s area -> Ivory eff ()
emit_ c r = ce_extern_emit_ c r

-- | Emit by value - saves the user from having to give a constref
--   to an atomic value.
emitV :: (SingI n, IvoryInit t, IvoryArea (Stored t), GetAlloc eff ~ Scope cs)
   => ChannelEmitter n (Stored t) -> t -> Ivory eff IBool
emitV c v = local (ival v) >>= \r -> emit c (constRef r)

emitV_ :: ( SingI n, IvoryInit t
          , IvoryArea (Stored t)
          , GetAlloc eff ~ Scope cs
          ) => ChannelEmitter n (Stored t) -> t -> Ivory eff ()
emitV_ c v = local (ival v) >>= \r -> emit_ c (constRef r)

-- | Nonblocking receive.
--   Indicates success in return value.
receive :: (SingI n, IvoryArea area, GetAlloc eff ~ Scope cs)
     => ChannelReceiver n area -> Ref s area -> Ivory eff IBool
receive rxer ref = cr_extern_rx rxer ref

-- StateProxy ------------------------------------------------------------------

-- | A convenient way to transform a 'ChannelSink' to a 'DataSink' for places
--   where you only want to read the most recent value posted to a Channel,
--   rather than receive each one individually.
--   Written entirely with public API.

stateProxy :: (SingI n, IvoryArea area, IvoryZero area)
           => ChannelSink n area -> Tower p (DataSink area)
stateProxy chsink = do
  (src_data, snk_data) <- dataport
  task "stateProxy" $ do
    data_writer <- withDataWriter src_data "proxyData"
    onChannel chsink "proxyEvent" $ \val -> writeData data_writer val
  return snk_data

