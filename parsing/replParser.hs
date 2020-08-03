-- repl with very simple parsing, via attoparsec

import Control.Applicative ((<*>),(*>),(<$>),(<|>), pure)
import qualified Data.Attoparsec.Text as A
import qualified Data.Attoparsec.Combinator as AC
import Data.Attoparsec.Text (Parser)
import Data.Text (Text)

main :: IO ()
main = do
  case A.eitherResult $ A.feed (A.parse input ":c the thing") "" of
        Right r -> eval r
        Left err -> print "Error"

data Command = Help | ChangeDomain Text | Quit deriving Show
data Input = Command Command | Sentence Text deriving Show

command :: Parser Command
command = 
  (A.asciiCI ":h" *> pure Help) <|>
  (A.asciiCI ":q" *> pure Quit) <|>
  (A.asciiCI ":c" *> (ChangeDomain <$> A.takeText))

input :: Parser Input
input = 
  (Command <$> command) <|>
  (Sentence <$> A.takeText)

eval :: Input -> IO ()
eval (Command Help) = print "help instructions"
eval (Command Quit) = return ()
eval (Command (ChangeDomain str)) = print "change domains"
eval (Sentence t) = print t


