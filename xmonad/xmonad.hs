import XMonad
import XMonad.Actions.Warp
import XMonad.Actions.GridSelect
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
-- import XMonad.Layout.IM
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.Magnifier
import XMonad.Layout.Maximize
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Simplest
import XMonad.Layout.ThreeColumns
import XMonad.Prompt
import XMonad.Prompt.Shell
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run(spawnPipe)
import Data.Monoid (All (All))
import Monad
import System.IO
import Text.Regex.Posix

main = do
       dzen <- spawnPipe myStatusBar
       conky <- spawn "conky -c ~/.conkyrc.bottom"
--        conkympd <- spawnPipe myMPDBar
--        xmonad myConfig
       xmonad $ ewmh $ myUrgencyHook $ myConfig {
                    logHook = dynamicLogWithPP (myDzenPP dzen) -- >> fadeInactiveLogHook 0x99999999
                }

myConfig = gnomeConfig {
               modMask = mod4Mask,
               terminal = "urxvt",
               workspaces = myWorkspaces,
               focusFollowsMouse = True,
               manageHook = myManageHook
                            <+> namedScratchpadManageHook scratchpads
                            <+> manageDocks
                            <+> manageHook gnomeConfig,
               layoutHook = myLayoutHook,
               handleEventHook = evHook
           } `additionalKeys` [
--              ((0, xK_Print), spawn "scrot"),
               ((mod4Mask, xK_a), sendMessage MirrorShrink),
               ((mod4Mask, xK_b), sendMessage ToggleStruts >> sendMessage ToggleGaps),
               ((mod4Mask, xK_c), banish LowerRight),
--                ((mod4Mask, xK_f), withFocused $ windows . W.float (W.RationalRect 0 0 1 1))
               ((mod4Mask, xK_g), goToSelected defaultGSConfig),
--                ((mod4Mask, xK_p), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\""),
--                ((mod4Mask, xK_p), spawn "gnome-do"),
               ((mod4Mask, xK_q), spawn "killall conky dzen2" >> restart "xmonad" True),
               ((mod4Mask, xK_s), namedScratchpadAction scratchpads "scratchpad"),
               ((mod4Mask, xK_u), namedScratchpadAction scratchpads "emacs"),
               ((mod4Mask, xK_x), shellPrompt myXPConfig),
               ((mod4Mask, xK_z), sendMessage MirrorExpand),
               ((mod4Mask, xK_backslash), withFocused (sendMessage . maximizeRestore)),
               ((mod4Mask, xK_F12), spawn "sleep 0.2; scrot '%Y-%m-%d-%H%M%S_$wx$h.png'" ),
               ((mod4Mask .|. shiftMask, xK_q), spawn "gnome-session-save --gui --logout-dialog"),
               ((mod4Mask .|. controlMask, xK_q), spawn "gnome-session-save --gui --shutdown-dialog"),
--                ((mod4Mask .|. shiftMask, xK_Return), focusUrgent),
               ((mod4Mask .|. shiftMask, xK_F12), spawn "sleep 0.2; scrot '%Y-%m-%d-%H%M%S_$wx$h.png' -e 'mv $f ~/media/desk/screenshots/'" ),
               ((mod4Mask .|. shiftMask, xK_comma), sendMessage (IncMasterN 1)),
               ((mod4Mask .|. shiftMask, xK_period), sendMessage (IncMasterN (-1)))
--              ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock"),
--              ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s"),
           ] `removeKeys` [(mod4Mask, xK_comma)]
             `removeKeys` [(mod4Mask, xK_period)]
             `removeKeys` [(mod4Mask, xK_p)]
             `removeKeys` [(mod4Mask, xK_F1)]

myWorkspaces = ["web", "work", "3", "4", "5", "6", "7", "comm", "im"]

-- colors, font and iconpath
myFont = "-xos4-terminus-medium-r-normal-*-12-*-*-*-c-*-iso10646-1"
myIconDir = "/home/jan/.dzen"
myDzenFGColor = "#555555"
myDzenBGColor = ""
myNormalFGColor = "#ffffff"
myNormalBGColor = "#0f0f0f"
myStatusBGColor = "#3c3c3c"
-- myFocusedFGColor = "#f0f0f0"
-- myFocusedBGColor = "#333333"
myFocusedFGColor = "#0f0f0f"
myFocusedBGColor = "#ffffff"
myUrgentFGColor = "#0099ff"
myUrgentBGColor = "#0077ff"
myIconFGColor = "#777777"
myIconBGColor = ""
mySeperatorColor = "#555555"

scratchpads = [ NS "scratchpad" "urxvt -name scratchpad -bg rgba:0000/0000/0000/dddd" (resource =? "scratchpad") (customFloating $ W.RationalRect 0.02 0.05 0.6 0.8),
                NS "emacs" "emacs ~/projects/org/gtd.org" (className =? "Emacs") (customFloating $ W.RationalRect 0.02 0.05 0.6 0.8)
              ]

myStatusBar = "dzen2 -x '0' -y '4' -h '16' -w '700' -ta 'l' -fg '"
              ++ myNormalFGColor ++ "' -bg '" ++ myStatusBGColor
              ++ "' -fn '" ++ myFont ++ "'"
-- myMPDBar = "conky -c .conkympd | dzen2 -x '0' -y '784' -h '16' -w '1280' -ta 'l' -fg '" ++ myDzenFGColor ++ "' -bg '" ++ myNormalBGColor ++ "' -fn '" ++ myFont ++ "'"
myMPDBar = "conky -c .conkympd | dzen2 -x '0' -y '784' -h '16' -w '1280'"
           ++ " -ta 'l' -fg '#aaaaaa' -bg '"
           ++ myNormalBGColor ++ "' -fn '" ++ myFont ++ "'"

myUrgencyHook = withUrgencyHook dzenUrgencyHook
                { args = ["-x", "0", "-y", "1184", "-h", "16", "-w", "1920",
                          "-ta", "r", "-expand", "l",
                          "-fg", "" ++ myUrgentFGColor ++ "",
                          "-bg", "" ++ myNormalBGColor ++ "",
                          "-fn", "" ++ myFont ++ ""] }

-- XPConfig options:
myXPConfig = defaultXPConfig {
                 font = "" ++ myFont ++ "",
                 bgColor = "" ++ myNormalBGColor ++ "",
                 fgColor = "" ++ myNormalFGColor ++ "",
                 fgHLight = "" ++ myFocusedFGColor ++ "",
--                  bgHLight = "" ++ myUrgentBGColor ++ "",
                 bgHLight = "" ++ myFocusedBGColor ++ "",
                 borderColor = "" ++ myNormalFGColor ++ "",
                 promptBorderWidth = 1,
                 position = Bottom,
                 height = 16,
                 historySize = 100,
                 autoComplete = Nothing
             }

myManageHook = composeAll [
                   className =? "MPlayer"        --> doFloat,
                   className =? "Sonata"         --> doFloat,
--                    className =? "Totem"          --> doFloat,
                   className ~? "Gimp.*"         --> doFloat,
--                    className ~? "DDD.*"           --> doFloat,
--                    resource  =? "desktop_window" --> doIgnore,
                   resource  =? "Do"             --> doIgnore,
                   resource  =? "kupfer"         --> doFloat,
                   isFullscreen                  --> doFullFloat,
--                    isDialog                      --> doCenterFloat
                   className =? "Iceweasel"      --> doF (W.shift "1:web")
               ]
               where
               q ~? x = fmap (=~ x) q

myLayoutHook = gaps [(D,14)]
               $ avoidStruts
               $ layoutHints
               $ maximize
               $ onWorkspace "web" (smartBorders Full)
--                 $ onWorkspace "8:comm" (smartBorders (Full ||| resizableTile))
               $ onWorkspace "im" (smartBorders threeCol)
--                $ smartBorders (tiled ||| Mirror tiled ||| Full)
--                $ smartBorders (magnifier resizableTile ||| Mirror resizableTile ||| Full)
               $ smartBorders (resizableTile
                               ||| Mirror resizableTile
                               ||| Full
                               ||| Grid
                               ||| threeCol)
    where
    resizableTile = ResizableTall nmaster delta ratio []
    threeCol = ThreeCol nmaster delta ratio
    -- default tiling algorithm partitions the screen into two panes
--     tiled   = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Percent of screen to increment by when resizing panes
    delta   = 3/100
    -- Default proportion of screen occupied by master pane
    ratio   = 4/7

myDzenPP h = defaultPP {
--                  ppCurrent = wrap ("^fg(" ++ myUrgentFGColor ++ ")^bg(" ++ myFocusedBGColor ++ ")^p()^i(" ++ myIconDir ++ "/corner.xbm)^fg(" ++ myFocusedFGColor ++ ")") "^fg()^bg()^p()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId,
--                  ppVisible = wrap ("^fg(" ++ myNormalFGColor ++ ")^bg(" ++ myFocusedBGColor ++ ")^p()^i(" ++ myIconDir ++ "/corner.xbm)^fg(" ++ myNormalFGColor ++ ")") "^fg()^bg()^p()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId,
--                  ppHidden = wrap ("^i(" ++ myIconDir ++ "/corner.xbm)") "^fg()^bg()^p()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId, -- don't use ^fg() here!!
--                  ppHiddenNoWindows = wrap ("^fg(" ++ myDzenFGColor ++ ")^bg()^p()^i(" ++ myIconDir ++ "/corner.xbm)") "^fg()^bg()^p()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId,

                 ppCurrent = wrap ("^fg(" ++ myFocusedFGColor ++ ")"
                                   ++ "^bg(" ++ myFocusedBGColor ++ ")")
                                  "^fg()^bg()" .
                                  \wsId -> if wsId /= "NSP" then wsId else "",
                 -- Xinerama
                 ppVisible = wrap ("^fg(" ++ myNormalFGColor ++ ")"
                                   ++ "^bg(" ++ myNormalBGColor ++ ")")
                                  "^fg()^bg()" .
                                  \wsId -> if wsId /= "NSP" then wsId else "",
                 ppHidden = \wsId -> if wsId /= "NSP" then wsId else "",
                 ppHiddenNoWindows = wrap ("^fg(" ++ myDzenFGColor ++ ")")
                                          "^fg()" .
                                          \wsId -> if wsId /= "NSP" then wsId else "",
                 ppUrgent = wrap ("^fg(" ++ myUrgentFGColor ++ ")^bg()^p()")
                                 "^fg()^bg()^p()" .
                                 \wsId -> if wsId /= "NSP" then wsId else "",
                 ppSep = " ",
                 ppWsSep = " ",
                 ppTitle = dzenColor ("" ++ myNormalFGColor ++ "") "" . wrap "< " " >",
                 ppLayout = dzenColor ("" ++ myNormalFGColor ++ "") "" . (
                   \x -> case x of
                     "Hinted Maximize ResizableTall" -> "^fg(" ++ myIconFGColor ++ ")"
                                                        ++ "^i(" ++ myIconDir
                                                        ++ "/layout-tall-right.xbm)"
                     "Hinted Maximize Mirror ResizableTall" -> "^fg(" ++ myIconFGColor ++ ")"
                                                               ++ "^i(" ++ myIconDir
                                                               ++ "/layout-tall-bottom.xbm)"
                     "Hinted Maximize Full" -> "^fg(" ++ myIconFGColor ++ ")"
                                               ++ "^i(" ++ myIconDir
                                               ++ "/layout-full.xbm)"
                     "Hinted Maximize Grid" -> "^fg(" ++ myIconFGColor ++ ")"
                                               ++ "^i(" ++ myIconDir
                                               ++ "/layout-grid.xbm)"
                     "Hinted Maximize ThreeCol" -> "^fg(" ++ myIconFGColor ++ ")"
                                                   ++ "^i(" ++ myIconDir ++ "/layout-threecol.xbm)"
                     _ -> x
                 ),
                 ppOutput = hPutStrLn h
             }

-- from http://code.google.com/p/xmonad/issues/detail?id=339
-- Helper functions to fullscreen the window
fullFloat, tileWin :: Window -> X ()
fullFloat w = windows $ W.float w r
    where r = W.RationalRect 0 0 1 1
tileWin w = windows $ W.sink w

evHook :: Event -> X All
evHook (ClientMessageEvent _ _ _ dpy win typ dat) = do
  state <- getAtom "_NET_WM_STATE"
  fullsc <- getAtom "_NET_WM_STATE_FULLSCREEN"
  isFull <- runQuery isFullscreen win

  -- Constants for the _NET_WM_STATE protocol
  let remove = 0
      add = 1
      toggle = 2

      -- The ATOM property type for changeProperty
      ptype = 4

      action = head dat

  when (typ == state && (fromIntegral fullsc) `elem` tail dat) $ do
    when (action == add || (action == toggle && not isFull)) $ do
         io $ changeProperty32 dpy win state ptype propModeReplace [fromIntegral fullsc]
         fullFloat win
    when (head dat == remove || (action == toggle && isFull)) $ do
         io $ changeProperty32 dpy win state ptype propModeReplace []
         tileWin win

  -- It shouldn't be necessary for xmonad to do anything more with this event
  return $ All False

evHook _ = return $ All True
