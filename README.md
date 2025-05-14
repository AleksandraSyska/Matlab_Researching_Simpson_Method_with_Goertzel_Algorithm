# Matlab_Researching_Simpson_Method_with_Goertzel_Algorithm

## Description
This MATLAB project implements a function called `funkcja_goertzel` designed to calculate the values of a specific mathematical function. The function is defined as a sum of sine terms:
\[ f(t) = \sum_{k=1}^{n} a_k \sin(kt) \]
where:
- \(f(t)\) is the value of the function at a given point \(t\).
- \(a_k\) are coefficients for each sine term.
- \(n\) is the total number of terms in the series.

## How it Works
A distinctive feature of this project is the method used to calculate each \(\sin(kt)\) term. Instead of direct computation, the `funkcja_goertzel` utilizes the Goertzel algorithm to determine the value of each sine component[1]. The Goertzel algorithm is an efficient method for evaluating individual terms of the Discrete Fourier Transform (DFT), making it suitable for detecting specific frequency components, which in this case are represented by the \(\sin(kt)\) terms.

## Usage
To use this project:
1. Ensure you have MATLAB installed.
2. Place the `funkcja_goertzel.m` file in your MATLAB working directory or add its path.
3. You can then call the function `funkcja_goertzel` with appropriate arguments for \(t\), the coefficients \(a_k\), and \(n\).

*(You can add more specific usage examples here, such as sample function calls or expected input/output formats.)*

