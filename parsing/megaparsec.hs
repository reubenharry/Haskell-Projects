-- excellent tutorial on which this is based: 
-- https://markkarpov.com/tutorial/megaparsec.html

{-# LANGUAGE OverloadedStrings #-}

import Text.Megaparsec
import Text.Megaparsec.Char
import Data.Text (Text)
import Data.Void

type Parser = Parsec Void Text

main = do
  parseTest (satisfy (> 'a') :: Parser Char) ""
  parseTest (satisfy (> 'a') :: Parser Char) "a"
  parseTest (satisfy (> 'a') :: Parser Char) "b"