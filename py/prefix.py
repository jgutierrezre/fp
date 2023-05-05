def postfix(data, stack, res):
    def popwhile(stack, res, cond):
        if stack:
            H = stack[0]
            T = stack[1:]
            if cond(H):
                return popwhile(T, [H] + res, cond)
            else:
                return [res, stack]
        else:
            return [res, stack]
    if data:
        H = data[0]
        T = data[1:]
        if H == "(":
            return postfix(T, [H] + stack, res)
        elif H == ")":
            H2, T2 = popwhile(stack, res, lambda x: x != "(")
            return postfix(T, T2, H2)
        elif H == "+":
            H2, T2 = popwhile(stack, res, lambda x: x in ["*", "/"])
            return postfix(T, [H] + T2, H2)
        elif H == "-":
            H2, T2 = popwhile(stack, res, lambda x: x in ["*", "/"])
            return postfix(T, [H] + T2, H2)
        elif H == "*":
            H2, T2 = [res, stack]
            return postfix(T, [H] + T2, H2)
        elif H == "/":
            H2, T2 = [res, stack]
            return postfix(T, [H] + T2, H2)
        else:
            return postfix(T, stack, [H] + res)        
            
    else:
        return res

print(postfix("( x * x ) + ( y * y )".split(" "), [], []))