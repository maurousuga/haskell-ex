module Main where

import           Data.List
import           Text.Read

data Pad = L | R deriving (Eq)

normalize :: [[String]] -> (Int, Int, [Maybe Int])
normalize ss = (length ss, n, concatMap f rows)
  where
    cols = map length ss
    n = maximum cols
    rows = zip cols ss
    f (j, row) = (map readMaybe row::[Maybe Int]) ++ replicate (n-j) Nothing


lengthMaybeInt :: Maybe Int -> Int
lengthMaybeInt = length . showMaybeInt

showMaybeInt :: Maybe Int -> String
showMaybeInt = maybe "" show

pad p n s =
 case p of
   L -> padding ++ s
   R -> s ++ padding
 where
   padding = replicate (n - length s) ' '

showTable :: [[String]] -> String
showTable numbers =
  concatMap f [(i, j, table !! (i*n+j)) | i<-[0..m-1], j <- [0..n-1]]
  where
    (m, n, table) = normalize numbers
    widths = [maximum (map lengthMaybeInt $ getCol j) | j <- [0..n-1]]
    getCol j = [table !! (i*n+j) | i <- [0..m-1]]
    f (i, j, mi)
      = pad (if j == 0 then R else L) (widths !! j) (showMaybeInt mi)
      ++ if j == (n - 1) then "\n" else " "

getTable :: IO [[String]]
getTable = loop (return []) where
  loop rows = do
    row <- getLine
    case row of
      [] -> rows
      _ -> loop $ (++ [words row]) <$> rows

main :: IO ()
main = do
  putStrLn "Enter a table:"
  table <- getTable
  putStrLn $ showTable table
