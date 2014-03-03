{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module Ivory.Tower.Types.Time
  ( Time
  , Microseconds(..)
  , Milliseconds(..)
  , toMicroseconds

  , ITime
  , fromIMicroseconds
  , fromIMilliseconds
  , toIMicroseconds
  ) where

import Ivory.Language

class Time a where
  toMicroseconds :: a -> Integer

newtype Microseconds = Microseconds Integer
instance Time Microseconds where
  toMicroseconds (Microseconds t) = t

newtype Milliseconds = Milliseconds Integer
instance Time Milliseconds where
  toMicroseconds (Milliseconds t) = t * 1000

newtype ITime = ITime Sint64
  deriving (Num, IvoryType, IvoryVar, IvoryExpr, IvoryEq, IvoryOrd, IvoryIntegral, IvoryStore, IvoryInit)

fromIMicroseconds :: (SafeCast a Sint64) => a -> ITime
fromIMicroseconds = ITime . safeCast

fromIMilliseconds :: (SafeCast a Sint64) => a -> ITime
fromIMilliseconds = ITime . (*1000) . safeCast

toIMicroseconds :: ITime -> Sint64
toIMicroseconds (ITime t) = t
