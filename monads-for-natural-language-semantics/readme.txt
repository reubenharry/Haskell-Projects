Haskell implementation of compositional semantics with effects, using a monad transformer stack.

The idea is that different monads represent different enrichments of Montague Grammar, i.e. Simply Typed Lambda Calculus for Natural Language. By combining all these omnads with monad transformers, we get a grammar that can handle multiple interacting effects.

The List Monad is for Focus
The State Monad is for discourse referent tracking
The Set Monad is for Non-Determinism (actually just implemented with another list monad)
The Writer Monad is for Conventional Implicature
The Exception Monad is for Presupposition Failure
The Reader Monad is for Intensionality
The Continuation Monad is for Scope Taking

To follow what's going on, read in the following order:
grammar.hs
IdentityGrammar.hs
StateT 
WriterT 
ExceptT 
ReaderT 
ContT

This represents the order in which the grammar is built, and successive files import the code from the previous ones.
