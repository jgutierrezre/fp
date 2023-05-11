class Node:
    def __init__(self, left, right):
        self.left = left
        self.right = right

def evaluate(node):
    if isinstance(node, int):
        return node
    
    if isinstance(node, str) and node in "+-*/":
        return node, None, 1
    
    op, left, d = evaluate(node.left)
    
    if d == 1:
        return op, evaluate(node.right), 0
    elif d == 0:
        return operate(op, left, evaluate(node.right))
        

def operate(op, a, b):
    if op == "+":
        return a + b
    elif op == "-":
        return a - b
    elif op == "*":
        return a * b
    elif op == "/":
        return a / b
    
    
x = Node(Node("*", 5), 5)

y = Node(Node("+", Node(Node("*", 5), 5)), Node(Node("*", 3), 3))

print(evaluate(x))
print(evaluate(y))