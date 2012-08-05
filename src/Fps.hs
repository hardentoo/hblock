-----------------------------------------------------------------------------
--
-- Module      :  Fps
-- Copyright   :
-- License     :  AllRightsReserved
--
-- Maintainer  :
-- Stability   :
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module Fps where

import Control.Monad
import Control.Monad.State
import Data.Word
import Graphics.UI.SDL as SDL

fpsLoop:: Word32 -> (Event -> Bool) -> (State Bool a) -> (Float -> a -> IO a) -> a -> IO()
fpsLoop systemFPSTime eventFunc moveFunc renderFunc funcArg = do
    time <- SDL.getTicks
    fpsLoop' time funcArg
    where
        fpsLoop' prevTime arg = do
            curTime <- SDL.getTicks
            let loopCnt = curTime - prevTime
            (prevTime', arg') <- renderLoop loopCnt prevTime arg
            SDL.delay 1
            event <- SDL.pollEvent
            when (eventFunc event) $ fpsLoop' prevTime' arg'

        moveLoop loopCnt prevTime arg
            | loopCnt >= systemFPSTime = do
                arg' <- moveFunc
                moveLoop (loopCnt-systemFPSTime) (prevTime+systemFPSTime) arg'
            | otherwise =
                return (prevTime, arg)

        renderLoop loopCnt prevTime arg
            | loopCnt >= systemFPSTime = do
                (prevTime', arg') <- moveLoop loopCnt prevTime arg
                arg'' <- renderFunc (1000.0 / fromIntegral loopCnt) arg'
                return (prevTime', arg'')
            | otherwise =
                return (prevTime, arg)


