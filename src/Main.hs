import System.Directory
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.Pixbuf
import Data.List (isPrefixOf, sort)
import System.Process (spawnCommand)

main = do
  -- initialize GTK
  initGUI

  -- create a new window
  window <- windowNew

  -- set the window title
  set window [windowTitle := "XMonad Images"]

  -- make the window floating
  windowSetTypeHint window WindowTypeHintDialog

  -- create a new vertical box layout
  hbox <- hBoxNew False 0

  home <- getHomeDirectory

  let thumbnailFolder = home ++ "/.cache/"

  -- get the list of files in the current directory
  files <- getDirectoryContents thumbnailFolder

  -- filter the list of files to only include those with the prefix "xmonad-"
  let thumbnails = [ file | file <- sort files, "xmonad_workspace_thumbnail-" `isPrefixOf` file]

  let removePrefix = drop (length "xmonad_workspace_thumbnail-")
  let removeSuffix = takeWhile (/= '.')

  let workspaceNames = map (removePrefix . removeSuffix) thumbnails

  -- load the images from the filtered list of files
  images <- mapM (imageNewFromFile . (thumbnailFolder ++)) thumbnails

  -- wrap the images in buttons
  buttons <- mapM (\i -> do
    b <- buttonNew
    containerAdd b i
    return b) images

  -- add onlcik handlers to the buttons
  mapM_ (\(button, workspace) -> do
    onClicked button $ do
      spawnCommand $ "xmonadctl WORKSPACE " ++ workspace
      print $ "xmonadctl WORKSPACE " ++ workspace
      mainQuit
    ) $ zip buttons workspaceNames

  -- add the images to the box layout
  mapM_ (\b -> do
    containerAdd hbox b
    ) buttons

  -- set the window layout
  containerAdd window hbox

  -- show the window and all of its child widgets
  widgetShowAll window

  -- Set up a callback function to be called when the window is closed
  onDestroy window mainQuit

  mainGUI
