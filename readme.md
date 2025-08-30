# LL(1) Parser Project

This project implements a simple LL(1) parser that computes the parse table for a given grammar using FIRST and FOLLOW sets. It also parses an input string to check its validity according to the grammar.

## Files Overview

- [`grammar.txt`](grammar.txt): Contains the grammar rules in the format `NonTerminal = {Productions}`.
- [`first.txt`](first.txt): Contains the FIRST sets for each non-terminal.
- [`follow.txt`](follow.txt): Contains the FOLLOW sets for each non-terminal.
- [`input.txt`](input.txt): Contains the input string to be parsed.
- [`b.l`](b.l): Flex (lex) file for parsing the grammar, FIRST, and FOLLOW sets, building the LL(1) parse table, and parsing the input string.
- [`c.l`](c.l): Similar to `b.l`, but for a different grammar (change terminals/non-terminals as needed).

## How It Works

1. **Compute FIRST and FOLLOW Sets**  
   Run [`first_follow.cpp`](first_follow.cpp) to read the grammar from [`grammar.txt`](grammar.txt) and compute the FIRST and FOLLOW sets. These are written to [`first.txt`](first.txt) and [`follow.txt`](follow.txt).

2. **Build Parse Table and Parse Input**  
   Use the provided `.l` files ([`b.l`](b.l) or [`c.l`](c.l)) to:
   - Read the grammar, FIRST, and FOLLOW sets.
   - Build the LL(1) parse table.
   - Parse the input string from [`input.txt`](input.txt) and print whether it is valid.

## How to Run

### 1. Compute FIRST and FOLLOW Sets

Compile and run [`first_follow.cpp`](first_follow.cpp):

```sh
g++ first_follow.cpp -o first_follow
./first_follow
```

This will generate [`first.txt`](first.txt) and [`follow.txt`](follow.txt).

### 2. Build and Run the Parser

#### Using Flex and GCC

For example, to use [`b.l`](b.l):

```sh
flex b.l
g++ lex.yy.c -o parser -lfl
./parser
```

Or for [`c.l`](c.l):

```sh
flex c.l
g++ lex.yy.c -o parser -lfl
./parser
```

### 3. Check Output

- The parser will print the FIRST and FOLLOW sets, the productions, the LL(1) parse table, and the step-by-step parsing of the input string.
- It will indicate whether the input string is **VALID** or **NOT valid** according to the grammar.

## Notes

- You can modify [`grammar.txt`](grammar.txt) and [`input.txt`](input.txt) to test different grammars and input strings.
- Make sure to re-run [`first_follow.cpp`](first_follow.cpp) after changing the grammar.

## Example

Given the grammar:

```
E = {TX}
X = {+TX,#}
T = {FY}
Y = {*FY,#}
F = {(E),i}
```

And input string:

```
i+i*i
```

The parser will check if the string can be derived from the grammar using the LL(1) parsing method.