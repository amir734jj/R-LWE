import random
import time

def generate_matrix(dimension, modulus):
    array = []

    for i in range(0, dimension):
        f = 0
        for j in range(0, dimension):
            f += randrange(0, int(modulus / 8)) * x^j

        array.append(f)

    return Matrix(array)


def generate_distribution(size):
    P = getenrate_probablity(1, int(floor(sqrt(size))))
       
    print("Probability array: " + str(P))
    
    dist = GeneralDiscreteDistribution(P)
    
    return dist
    
    
def get_noise(dimension, modulus, dist):
    array = []

    for i in range(0, dimension):
        nested = []
        degree = dist.get_random_element()
        
        for j in range(0, dimension):
            if dimension - j - 1  == degree:
                nested.append(dist.get_random_element() * x^degree)  
            else:
                nested.append(0)
                
        array.append(nested)
        
    return Matrix(array)


def reconcile(poly, dimension, modulus):
    array = remove_values_from_list(poly.list(), 0)
    result = ""
    
    for coefficient in array:
        coefficient = int(coefficient)
        
        if (coefficient) >= (modulus / 4.0) and (coefficient) <= (3.0 * modulus / 4.0):
            result += "1"
        else:
            result += "0"  
        
        # print(str(coefficient) + "\t" + str(797 / 4.0) + "\t" + str(3.0*797 / 4) +  "\t" + str(int(1.0 * coefficient) >= (modulus / 4.0))) + "\t" + str(int((1.0 * coefficient) <= (3.0 * modulus / 4.0)))
        
    return str(result)


def reconcile2(poly, dimension, modulus, signal="null"):
    array = remove_values_from_list(poly.list(), 0)
    result = ""
    
    index = 0
    
    if signal != "null":
        temp = signal
        # print("signal: " + str(signal))
    else:
        temp = generate_signal(poly, dimension, modulus)
        

    value1 = ((modulus / 2.0 - modulus / 4.0) / 2.0) + (modulus / 4.0)
    value2 = ((modulus - 3.0 * modulus / 4.0) / 2.0) + (3.0 * modulus / 4.0)
    value3 = ((modulus / 4.0 - 0) / 2.0)
    value4 = ((3.0 * modulus / 4.0 - modulus / 2.0) / 2.0) + (modulus / 2.0)
    
    # print(str(value1) + "\t" + str(value2) + "\t" + str(value3) + "\t" + str(value4))
    
    for coefficient in array:
        coefficient = int(coefficient)
        
        if temp[index] == "1":
            if (coefficient) >= value1 and (coefficient) <= value2:
                result += "1"
            else:
                result += "0"
        else:
            if (coefficient) >= value3 and (coefficient) <= value4:
                result += "1"
            else:
                result += "0"

        index = index + 1
    
    return str(result)


def generate_signal(poly, dimension, modulus):
    array = remove_values_from_list(poly.list(), 0)
    result = ""
    
    for coefficient in array:
        coefficient = int(coefficient)
        
        if (coefficient) <= (modulus / 4.0) or ((coefficient) <= (3.0 * modulus / 4.0) and (coefficient) >= (modulus / 2.0)):
            result += "1"
        else:
            result += "0"  
  
    return str(result)
    

def remove_values_from_list(the_list, val):
   return [value for value in the_list if value != val]


def getenrate_probablity(total, count):
    sub_sum = total
    random_numbers = []

    for i in range(0, count - 2):
        random_numbers.append(random.uniform(0, sub_sum))
        sub_sum -= random_numbers[i]

    random_numbers.append(sub_sum)
   
    return random_numbers



        

start_time = time.time()
 
# constants:
#   dimension = 64
#   modulus = 797
dimension = 16
modulus = 40961
use = "FLINT"

print("Implementation: " + use);
print("Dimension: " + str(dimension));
print("Modulus: " + str(modulus));
print("Ring: " + "X^1024 + 1");

# Quotient polynomial ring
R = PolynomialRing(GF(modulus), "X", implementation=use)
X = R.gen()
Y = R.quotient(X^1024 + 1, "x")
x = Y.gen()

# Shared matrix A
shared = generate_matrix(dimension, modulus)

# Alice and Bob secret matrices
#   TODO: make the matrix generation to come from Gaussian distribution
alice_secret = generate_matrix(dimension, modulus)
bob_secret = generate_matrix(dimension, modulus)

# Calculate the value B and B' for Alice and Bob respectively
alice_value = shared.transpose() * alice_secret
bob_value = bob_secret.transpose() * shared

# ** NO ERROR **

# Calculate Alice and Bob shared key. The result is: dimension X 1 matrix 
alice_key = (bob_value.transpose() * alice_secret.transpose())[0, 0]
bob_key = (bob_secret * alice_value.transpose()).transpose()[0, 0]

# Check if Alice's and Bob shared key match
print("shared key match before error: " + str(alice_key == bob_key)+ "\n")

# Calculate the shared key in Hex
alice_key_hex = str(hex(int(reconcile(alice_key, dimension, modulus), 2)))
bob_key_hex = str(hex(int(reconcile(bob_key, dimension, modulus), 2)))

# Print shared key
print("Alice's key in Hex: " + alice_key_hex + "\n")
print("Bob's key in Hex: " + bob_key_hex + "\n")
print("Alice's and Bob shared key match (no error): " + str(alice_key_hex == bob_key_hex))

# ** WITH ERROR **
# Generate Gaussian distribution for Alice and Bob
alice_dist = generate_distribution(dimension)
bob_dist = generate_distribution(dimension)

# Generate noise based on Gaussian distribution
alice_error = get_noise(dimension, modulus, alice_dist)
bob_error = get_noise(dimension, modulus, bob_dist)

# Print Alice and Bob error values
print ("Alice's error: \n" + str(alice_error) + "\n")
print ("Bob's error: \n" + str(bob_error)+ "\n")

# Add error to Alice's B and Bob's B' matrix
alice_value = alice_value + alice_error
bob_value = bob_value + bob_error

# Re-calculate the shared key for Alice and Bob
alice_key = (bob_value.transpose() * alice_secret.transpose())[0, 0]
bob_key = (bob_secret * alice_value.transpose()).transpose()[0, 0]

# Print Alice's and Bob's shared key which has error
print("Alice's key (with error): " + str(alice_key)+ "\n")
print("Bob's key (with error): " + str(bob_key)+ "\n")

# Calculate the shared key in Hex which has error
alice_key_hex = str(hex(int(reconcile(alice_key, dimension, modulus), 2)))
bob_key_hex = str(hex(int(reconcile(bob_key, dimension, modulus), 2)))

print("Shared polynomial match after error: " + str(alice_key == bob_key))

print("Alice's key in Hex: " + alice_key_hex)
print("Bob's key in Hex: " + bob_key_hex)
print("Alice's and Bob shared key match (with error) <method #1>: " + str(alice_key_hex == bob_key_hex))

alice_key_hex = str(hex(int(reconcile2(alice_key, dimension, modulus), 2)))
help = generate_signal(alice_key, dimension, modulus)
bob_key_hex = str(hex(int(reconcile2(bob_key, dimension, modulus, signal=help), 2)))

print("Alice's key in Hex: " + alice_key_hex)
print("Bob's key in Hex: " + bob_key_hex)
print("Alice's and Bob shared key match (with error using second rounding method) <method #2>: " + str(alice_key_hex == bob_key_hex))

print("=== %s seconds ===" % (time.time() - start_time))
