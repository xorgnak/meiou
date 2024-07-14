# Meiou

Used to find keywords in input text and return context about those keywords.

## Installation
### bundle
```
bundle add meiou
```
### gems
```
gem install meiou
```
## Usage
### basic
```
Mieou["What is the meaning of life?"]
```
### custom
First, create the "books/" directory in your project.
Then include txt files with the necessary pieces of information.
Finally you can do the following:
```
Meiou.compile!
```
Then you can use as normal, but also giving references to given text snippets.


## Utilities

### Toki Pona
Toki Pona is a constructed language with only 125 words.

```
s = Meiou.to_toki "I Love toki pona"
Meiou.from_toki s
```

### dictionary
```
Meiou.extract("A string of input.") # extract keywords.
Meiou.extract("A string of input.") { |word|  } # extract keywords and process.
Meiou.define("A string of input.")  # define keywords of input.
Meiou.example("A string of input.") # find example from books.
Meiou.cite("A string of input.")    # Cite example from books.
```

### mood
```
Meiou.mood["A string of input."]
```

### emoji-fy
```
Meiou.simplify("A string of input.")
```

### astronomy
```
Meiou.astronomy # astronomy object reference
Meiou.zodiac["year/month/day hour:minute"] # zodiac lookup by date
```


