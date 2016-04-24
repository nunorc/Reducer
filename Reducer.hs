
module Reducer (reduce,toDot) where

import Data.List

-- n-grams

ngramsSet 0 _  = []
ngramsSet _ [] = []
ngramsSet n xs
  | length ngram == n = ngram : ngramsSet n (tail xs)
  | otherwise         = []
  where
    ngram = take n xs

ngramsCount l = [ (x,length(filter (==x) l)) | x <- nub l ]

ngrams n l = ngramsCount $ ngramsSet n l

allGrams l = [ (n, ngrams n l) | n <- reverse [2 .. div (length l) 2] ]

filtGrams l = filter ( (>1).snd ) l  -- remove n-grams with occurences == 1

-- Replace sub lists of tokens in a list

replace _ _ [] = []
replace pat sub l = if (pat == take (length pat) l) then
                        sub : replace pat sub (drop (length pat) l)
                      else
                        (head l) : replace pat sub (tail l)

-- Count the number of replace sub lists of tokens in a list

replaceCount _ [] = 0
replaceCount pat l
  | pat == take (length pat) l = 1 + replaceCount pat (drop (length pat) l)
  | otherwise = 0 + replaceCount pat (tail l)

-- main reduce function

reduce l = reduceAux l []

reduceAux l ps = let a = allGrams l
                     f = [ (fst i, filtGrams (snd i)) | i <- a ]
                     f2 = filter ( (/=[]).snd ) f
                     flat = map fst (concat (map snd f2))
                     (x, y) = replaceAll l flat 0 []
                 in 
                     if y == [] then (x, ps)
                     else reduceAux x (ps++y)

replaceAll l [] _ ps = (l, ps)
replaceAll l (x:xs) c ps =
  let cnt = replaceCount x l
      pid = nextId c
  in 
      if cnt>1 then replaceAll (replace x pid l) xs (c+1) (ps++[(pid, x)])
      else replaceAll l xs c ps

nextId c = "P" ++ show c   -- create next pattern id

-- debugging

getP p [] = []
getP p (x:xs)
  | p == (fst x) = snd x
  | otherwise    = getP p xs

toDot (expr,_) =
  let header = ["digraph auto {","rankdir=LR;", "size=\"7,5\";", "node [shape = circle];"]
      edges  = [ toEdge e | e <- zip [1..] (ngramsSet 2 expr) ]
  in unlines $ concat [header,edges,["}"]]

toEdge (n,[f,t]) = concat ["\"",f,"\" -> \"",t,"\" [ label =\"",show n,"\" ];"]

