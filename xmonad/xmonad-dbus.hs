import Control.OldException
import Control.Monad
import DBus
import DBus.Connection
import DBus.Message
import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog

-- This retry is really awkward, but sometimes DBus won't let us get our
-- name unless we retry a couple times.
getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn` (\ (DBus.Error _ _) ->
                                                getWellKnownName dbus)
 where
  tryGetName = do
    namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
    addArgs namereq [String "org.xmonad.Log", Word32 5]
    sendWithReplyAndBlock dbus namereq 0
    return ()

main :: IO ()
main = withConnection Session $ \ dbus -> do
  putStrLn "Getting well-known name."
  getWellKnownName dbus
  putStrLn "Got name, starting XMonad."
  xmonad $ gnomeConfig {
    focusedBorderColor = "DarkBlue"
  , borderWidth = 2
  , logHook    = dynamicLogWithPP $ defaultPP {
                   ppOutput   = \ str -> do
                     let str'  = "<span font=\"Terminus 9 Bold\">" ++ str ++ 
                                 "</span>"
                         str'' = sanitize str'
                     msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" 
                                "Update"
                     addArgs msg [String str'']
                     -- If the send fails, ignore it.
                     send dbus msg 0 `catchDyn`
                       (\ (DBus.Error _name _msg) ->
                         return 0)
                     return ()
                 , ppTitle    = pangoColor "#003366" . shorten 50
                 , ppCurrent  = pangoColor "#006666" . wrap "[" "]"
                 , ppVisible  = pangoColor "#663366" . wrap "(" ")"
                 , ppHidden   = wrap " " " "
                 , ppUrgent   = pangoColor "red"
                 }
  }

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
 where
  left  = "<span foreground=\"" ++ fg ++ "\">"
  right = "</span>"

sanitize :: String -> String
sanitize [] = []
sanitize (x:rest) | fromEnum x > 127 = "&#" ++ show (fromEnum x) ++ "; " ++
                                       sanitize rest
                  | otherwise        = x : sanitize rest

