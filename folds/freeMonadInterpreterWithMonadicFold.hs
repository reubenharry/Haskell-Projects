-- shows how to build up and fold an abstract syntax tree, with a monadic catamorphism
-- parser combinators via http://dev.stephendiehl.com/fun/002_parsers.html 

-- cool things to take note of: 
  -- automatic functor derivation, 
  -- use of free monad
  -- monadic fold of free monad syntax tree
  -- use of guards
  -- combinator parsers, mapping string into free monad tree 
  -- adhoc polymorphism of eval resolved with type info at print time

-- {-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

{-# LANGUAGE DeriveFunctor #-}


import Control.Monad.Free
import Data.Char
import Control.Monad
import Control.Applicative

newtype Parser a = Parser { parse :: String -> [(a,String)] }

runParser :: Parser a -> String -> a
runParser m s =
  case parse m s of
    [(res, [])] -> res
    [(_, _)]   -> error "Parser did not consume entire stream."
    _           -> error "Parser error."

item :: Parser Char
item = Parser $ \s ->
  case s of
   []     -> []
   (c:cs) -> [(c,cs)]

bind :: Parser a -> (a -> Parser b) -> Parser b
bind p f = Parser $ \s -> concatMap (\(a, s') -> parse (f a) s') $ parse p s

unit :: a -> Parser a
unit a = Parser (\s -> [(a,s)])

instance Functor Parser where
  fmap f (Parser cs) = Parser (\s -> [(f a, b) | (a, b) <- cs s])

instance Applicative Parser where
  pure = return
  (Parser cs1) <*> (Parser cs2) = Parser (\s -> [(f a, s2) | (f, s1) <- cs1 s, (a, s2) <- cs2 s1])

instance Monad Parser where
  return = unit
  (>>=)  = bind

instance MonadPlus Parser where
  mzero = failure
  mplus = combine

instance Alternative Parser where
  empty = mzero
  (<|>) = option

combine :: Parser a -> Parser a -> Parser a
combine p q = Parser (\s -> parse p s ++ parse q s)

failure :: Parser a
failure = Parser (\cs -> [])

option :: Parser a -> Parser a -> Parser a
option  p q = Parser $ \s ->
  case parse p s of
    []     -> parse q s
    res    -> res

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = item `bind` \c ->
  if p c
  then unit c
  else failure

-------------------------------------------------------------------------------
-- Combinators
-------------------------------------------------------------------------------

oneOf :: [Char] -> Parser Char
oneOf s = satisfy (flip elem s)

chainl :: Parser a -> Parser (a -> a -> a) -> a -> Parser a
chainl p op a = (p `chainl1` op) <|> return a

chainl1 :: Parser a -> Parser (a -> a -> a) -> Parser a
p `chainl1` op = do {a <- p; rest a}
  where rest a = (do f <- op
                     b <- p
                     rest (f a b))
                 <|> return a

char :: Char -> Parser Char
char c = satisfy (c ==)

natural :: Parser Integer
natural = read <$> some (satisfy isDigit)

string :: String -> Parser String
string [] = return []
string (c:cs) = do { char c; string cs; return (c:cs)}

token :: Parser a -> Parser a
token p = do { a <- p; spaces ; return a}

reserved :: String -> Parser String
reserved s = token (string s)

spaces :: Parser String
spaces = many $ oneOf " \n\r"

digit :: Parser Char
digit = satisfy isDigit

number :: Parser Int
number = do
  s <- string "-" <|> return []
  cs <- some digit
  return $ read (s ++ cs)

parens :: Parser a -> Parser a
parens m = do
  reserved "("
  n <- m
  reserved ")"
  return n

int :: Parser (Expr Int)
int = do
  n <- number
  return (Free $ Lit n)

expr :: Parser (Expr Int)
expr = term `chainl1` addop

term :: Parser (Expr Int)
term = factor `chainl1` mulop

factor :: Parser (Expr Int)
factor =
      int
  <|> parens expr

infixOp :: String -> (a -> a -> a) -> Parser (a -> a -> a)
infixOp x f = reserved x >> return f

addop :: Parser (Expr Int -> Expr Int -> Expr Int)
addop = (infixOp "+" (\x y -> Free $ Add x y)) <|> (infixOp "-" (\x y -> Free $ Sub x y))

mulop :: Parser (Expr Int -> Expr Int -> Expr Int)
mulop = (infixOp "*" (\x y -> Free $ Mul x y)) <|> (infixOp "/" (\x y -> Free $ Div x y)) 

run :: String -> Expr Int
run = runParser expr

eval :: (Monad m, Alternative m) => ExprF (m Int) -> m Int
eval ex = case ex of
  Add a b -> liftA2 (+) a b
  Mul a b -> liftA2 (*) a b
  Sub a b -> liftA2 (-) a b
  Div a b -> do
    a' <- a
    b' <- b
    guard (b' /= 0)
    return (a' `div` b')
  Lit n   -> return n


data ExprF a
  = Add a a
  | Sub a a
  | Mul a a
  | Div a a
  | Lit Int
  deriving (Show, Eq, Functor) -- fmap for free

type Expr = Free ExprF


main :: IO ()
main = do
  -- let expr = Free $ Add (Free $ Lit 1) (Free $ Lit 2)
  print $ (iterM eval $ run "(3+4)+(6/2)" :: Maybe Int)
  print $ (iterM eval $ run "(3+4)+(6/2)" :: Either String Int)
  print $ (iterM eval $ run "(3+4)+(6/2)" :: [] Int)

  print $ (iterM eval $ run "(3+4)+6/0" :: Maybe Int)
  print $ (iterM eval $ run "(3+4)+6/0" :: Either String Int)
  print $ (iterM eval $ run "(3+4)+6/0" :: [] Int)


