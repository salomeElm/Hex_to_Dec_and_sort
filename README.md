# Hex_to_Dec_and_sort
A MIPS program that processes a string of hexadecimal digit pairs separated by the $ character. It validates the input, converts the pairs to decimal values, and prints the results sorted in both unsigned and 2's complement representations from largest to smallest.

**Language:** MIPS Assembly  
**Purpose:** To process hexadecimal strings by validating, converting, sorting, and printing them in various formats.

## Overview
This project processes hexadecimal strings consisting of pairs of digits separated by the `$` character. The program implements the following capabilities:

1. **Validation**: Checks the validity of the input string.
2. **Conversion**: Converts digit pairs into numerical representations.
3. **Sorting**:
   - By unsigned value.
   - By two's complement representation.
4. **Printing**: Displays the results in a user-friendly format.

## Program Structure
The program is divided into separate procedures for each task:

1. **is_valid** - Validates the input string.
2. **convert** - Converts digit pairs into numeric values.
3. **sortunsign** - Sorts values by unsigned representation.
4. **sortsign** - Sorts values by two's complement representation.
5. **printunsign** - Prints values in unsigned representation.
6. **printsign** - Prints values in two's complement representation.

## Requirements
To run the project, you need a MIPS simulator such as [MARS](http://courses.missouristate.edu/KenVollmar/MARS/).

## Example Usage
### Valid Input Example:
```
EF$DE$23$56$76$AA$76$07$
```
### Invalid Input Example:
```
EEE$23$$34$QA$7$a2$2$AA$122$FF
```

## How to Run
1. Open the source code in a MIPS simulator (e.g., MARS).
2. Input a string following the required format (see examples).
3. View the printed results in the console.

## Credits
This project was developed as part of computer science studies at the Open University.

