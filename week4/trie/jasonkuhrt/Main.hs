
{- README
-- Trie

Construct a trie of all words in a dictionary.
Use it for searching words by prefix.

For example, a trie for words: cool, cat, coal, bet, bean.

        b       c
       /       / \
      e       a   o
     / \     /   / \
    t   a   t   a   o
        |       |   |
        n       l   l
-}
module Main where

import Data.Map (Map)
import qualified Data.Map as Map


{- Trie type.

In our model it might at first seem that one word coresponds to one path within a trie of letters, but that would be wrong; Paths can actually naturally represent multiple words since words can also be the prefix of other words. For example:

     a and
    be bean

As a visualized trie:

      a       b
     /         \
    n           e
                 \
                  a
                  |
                  n

So our solution is to model each Node with a flag indicating whether it represents a valid word or not at that point in the path. For example, the above visualization in pseudo code:

    Node False
      a : Node True
        n : Empty
      b : Node False
        e : Node True
          a : Node False
            n : Empty

Finally each letter (a Node) may branch out to zero, one, or many other letters (nodes) which themselves finish or continue toward another word. For example:

        b
       /
      e
     /|\
    t e  a
      |  |
      r  n

Our solution is to use a Map data type which permits us to model arbitrary number of children per node.
-}
data Trie a =
  Empty |
  Node Bool (Map a (Trie a))
  deriving (Show)


{- TODO
So we have two ideas to implement.

  * Index a dictionary of words.
  * Search that index for words.

We could start with searching, testing it by manually constructing a very minial tree. This arguably has the benefit of pressuring the correct indexing solution by building an interface that uses it to achieve the high-level user-facing goal.

-}

-- Manually create a minimal word trie for testing.
-- It contains four words: a, an, be, bean.
sample :: Trie Char
sample =
  Node False (Map.fromList [
    ('a', Node True (Map.fromList [
      ('n', Empty)
    ])),
    ('b', Node False (Map.fromList [
      ('e', Node True (Map.fromList [
        ('a', Node False (Map.fromList [
          ('n', Empty)
        ]))
      ]))
    ]))
  ])



{- | Convert a trie into a list of words therein.

For example:

    trie =
      Node False (Map.fromList [
        ('a', Node True (Map.fromList [
          ('n', Empty)
        ])),
        ('b', Node False (Map.fromList [
          ('e', Node True (Map.fromList [
            ('a', Node False (Map.fromList [
              ('n', Empty)
            ]))
          ]))
        ]))
      ])

    > trieToWords trie

    ["a","an","be","bean"]
-}
trieToWords :: Trie Char -> [String]
trieToWords Empty      = []
trieToWords (Node _ m) = concat . Map.elems $ Map.mapWithKey (go "") m
  where
  go :: String -> Char -> Trie Char -> [String]
  go prefix char Empty =
    [prefix ++ [char]]
  go prefix char (Node False maap) =
    concat . Map.elems $
    Map.mapWithKey (go (prefix ++ [char])) maap
  go prefix char (Node True maap) =
    ((prefix ++ [char]) :) . concat . Map.elems $
    Map.mapWithKey (go (prefix ++ [char])) maap




{- | Find the sub-trie matching a given prefix.

The trie returned does not include the prefix given. For example given a trie with the two words "be", "bean" and a prefix of "be" then the result includes just letters "a", "n". Observe:

    trie =
      Node False (Map.fromList [
        ('b', Node False (Map.fromList [
          ('e', Node True (Map.fromList [
            ('a', Node False (Map.fromList [
              ('n', Empty)
            ]))
          ]))
        ]))
      ])

    > findTrieWithPrefix "be" trie

    Just (Node True (fromList [('a',Node False (fromList [('n',Empty)]))]))
-}
findTrieWithPrefix :: String -> Trie Char -> Maybe (Trie Char)
findTrieWithPrefix ""        trie          = Just trie
findTrieWithPrefix _         Empty         = Nothing
findTrieWithPrefix (char:cs) (Node _ maap) =
  case Map.lookup char maap of
    Nothing    -> Nothing
    Just trie  -> findTrieWithPrefix cs trie



{- | Find words in given trie that have given prefix. -}
searchIn :: Trie Char -> String -> [String]
searchIn trie prefix = werds
  where
  werds = maybe [] (fmap (prefix ++) . trieToWords) maybeTrie
  maybeTrie  = findTrieWithPrefix prefix trie



{- | Search on the command line. -}
main :: IO ()
main = do
  putStrLn "Enter the initial letters of the word: "
  putStr "> "
  putStrLn . unwords . searchIn sample =<< getLine
