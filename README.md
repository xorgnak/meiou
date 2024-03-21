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
