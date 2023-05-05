def curry(data):
    H = data[0]
    T = data[1:]
    if H in "+-*/":
        a, b = curry(T)
        c, d = curry(b)
        return [[H, a], c], d
    else:
        return H, T

print(curry("*xx")[0])

#print(curry("+*xx*yy")[0])

#[['+', [['*', 'x'], 'x']], [['*', 'y'], 'y']]

#print(curry("*x*xx")[0])
#print(curry("**xxx")[0])