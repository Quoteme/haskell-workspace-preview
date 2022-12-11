import System.Directory
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.Pixbuf
import Data.List (isPrefixOf)

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

  let thumbnailFolder = "/home/luca/.cache/"

  -- get the list of files in the current directory
  files <- getDirectoryContents thumbnailFolder

  -- filter the list of files to only include those with the prefix "xmonad-"
  let xmonadFiles = [ thumbnailFolder ++ file | file <- files, "xmonad_workspace_thumbnail-" `isPrefixOf` file]

  -- load the images from the filtered list of files
  images <- mapM (\f -> pixbufNewFromFile f) xmonadFiles

  -- add the images to the box layout
  mapM_ (\i -> containerAdd hbox =<< imageNewFromPixbuf i) images

  -- set the window layout
  containerAdd window hbox

  -- show the window and all of its child widgets
  widgetShowAll window

  mainGUI
