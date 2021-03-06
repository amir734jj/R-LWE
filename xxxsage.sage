# Simple test to verify Ring-LWE exchange, without actually
# adding any error.

from random import randint

def generate_matrix(dimension, modulus):
    array = []
    upper_limit = modulus * dimension
	    
    for i in range(0, dimension):
        f = 0
        for j in range(0, dimension):
            f = f + (randrange(0, upper_limit) * x^j)
		            
        array.append(f)
							            
    return Matrix(array)
									    
dimension = 8
modulus = 65537
R = PolynomialRing(GF(65537), "X")
X = R.gen()
S = R.quotient(X^1024 + 1, "x")
x = S.gen()

A = generate_matrix(dimension, modulus)
#print "A: " + str(A.nrows()) + " x " + str(A.ncols())
#print A.str()
#print
S = generate_matrix(dimension, modulus)
#print "S: " + str(S.nrows()) + " x " + str(S.ncols())
#print S.str()
#print
S_ = generate_matrix(dimension, modulus)
#print "S': " + str(S_.nrows()) + " x " + str(S_.ncols())
#print S_.str()
#print

B = A.transpose()*S
#print "B: " + str(B.nrows()) + " x " + str(B.ncols())
#print B.str()
#print
B_ = S_.transpose()*A
#print "B': " + str(B_.nrows()) + " x " + str(B_.ncols())
#print B_.str()
#print 

alice = B_.transpose()*S.transpose()
#print "alice: " + str(alice.nrows()) + " x " + str(alice.ncols())
#print alice.str()
#print
bob = (S_*B.transpose()).transpose()
#print "bob: " + str(bob.nrows()) + " x " + str(bob.ncols())
#print bob.str()

print alice == bob

print alice.nrows()
print alice.ncols()
print bob.nrows()
print bob.ncols()
