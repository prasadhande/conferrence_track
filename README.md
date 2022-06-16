# Conference Track Management

## Problem Description
https://gist.github.com/abepetrillo/34e8b774e444a298c3a5e3e8aa058aaf

## Class explanation

* `CParser`: Parses the data from the file given
* `CValidator`: Validates parsed data and exports an Array with unique, valid  values
* `CManager`: Runs the algorithm to solve the problem
* `CPrinter`: Prints schedule to stdout

### Entity classes:
* `Talk`: Description and length for each talk
* `Track`: An array of talks and their total length for each session

## Algorithm

  * 1. Read data from file and create a list of String.
  * 2. validate each string talk, check the time.
  * 3. sort the list of talks.
  * 4. find out the combination which can fill the first half (morning session total time 180 mins).
  * 5. find out the combination that can fill the evening sessions (180 >= totalSessionTime <= 240).
  * 6. check if any task remaining in the list if yes then try to fill all the evening session.

## Usage

## Please use the master branch

The program can be ran :

`ruby lib/conference_application.rb`

```