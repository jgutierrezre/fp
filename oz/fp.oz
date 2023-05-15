declare

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                              ADITIONAL FUNCTIONS
%%
%% /////////////////////////////////////////////////////////////////////////////
%% Split a string by spaces
fun {AtomToList Data}
    {List.map {String.tokens {Atom.toString Data} & } fun {$ X} {String.toAtom X} end}
end

%% Convert a list of atoms to a list of strings
fun {AtomListToStringList Data}
    {List.map Data fun {$ X} {Atom.toString X} end}
end

%% Join a list of strings by spaces
fun {StringListJoin Data}
    {String.toAtom 
        {List.drop 
            {List.foldR 
                Data
                fun {$ X Y} {List.append 32|X Y} end nil
            }
            1
        }
    }
end

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                               INFIX - POSTFIX
%%
%% /////////////////////////////////////////////////////////////////////////////
%% Data is a list of the form ["(", "X", "+", "Y", ")"] en returns id prefix form ["+" "X" "Y"]
local
    fun {ReverseWithParentheses Data Ans}
        case Data of H|T then
            case H of "(" then
                {ReverseWithParentheses T ")"|Ans}
            [] ")" then
                {ReverseWithParentheses T "("|Ans}
            else
                {ReverseWithParentheses T H|Ans}
            end
        else
            Ans
        end
    end
    fun {Infix2Postfix Data Stack Res}
        case Data
        of nil then Res
        [] H|T then
            case H 
            of "(" then
                {Infix2Postfix T H|Stack Res}
            [] ")" then
                local H2 T2 T3 in
                    {List.takeDropWhile Stack fun {$ X} X \= "(" end H2 T2}
                    _|T3 = T2
                    {Infix2Postfix T T3 {List.append H2 Res}}
                end 
            [] "+" then
                local H2 T2 in
                    {List.takeDropWhile Stack fun {$ X} {List.member X ["*" "/"]} end H2 T2}
                    {Infix2Postfix T H|T2 {List.append H2 Res}}
                end
            [] "-" then
                local H2 T2 in
                    {List.takeDropWhile Stack fun {$ X} {List.member X ["*" "/"]} end H2 T2}
                    {Infix2Postfix T H|T2 {List.append H2 Res}}
                end
            [] "*" then
                local H2 T2 in
                    H2|T2|nil = [Res Stack]
                    {Infix2Postfix T H|T2 H2}
                end
            [] "/" then
                local H2 T2 in
                    H2|T2|nil = [Res Stack]
                    {Infix2Postfix T H|T2 H2}
                end
            else
                {Infix2Postfix T Stack H|Res}
            end
        end
    end
in
    fun {Infix2Prefix Data}
        {Infix2Postfix % Convert the infix to postfix
            "("|{ReverseWithParentheses "("|{AtomListToStringList Data} nil} 
            nil 
            nil
        }
    end
end

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                                  CURRY
%%
%% /////////////////////////////////////////////////////////////////////////////

%% Data is a prefix form ["+" "X" "Y"] and returns the graph representation
local
    fun {DoCurry Data}
        case Data
        of nil then nil
        [] H|T then
            case H
            of "+" then
                local A B C D in
                    A|B|nil = {DoCurry T}
                    C|D|nil = {DoCurry B}
                    [tree(tree({String.toAtom H} A) C) D]
                end
            [] "-" then
                local A B C D in
                    A|B|nil = {DoCurry T}
                    C|D|nil = {DoCurry B}
                    [tree(tree({String.toAtom H} A) C) D]
                end
            [] "*" then
                local A B C D in
                    A|B|nil = {DoCurry T}
                    C|D|nil = {DoCurry B}
                    [tree(tree({String.toAtom H} A) C) D]
                end
            [] "/" then
                local A B C D in
                    A|B|nil = {DoCurry T}
                    C|D|nil = {DoCurry B}
                    [tree(tree({String.toAtom H} A) C) D]
                end
            else
                if {String.isInt H} then [{String.toInt H} T]
                else [{String.toAtom H} T] end
            end
        end
    end
in
    fun {Curry Data}
        local H in
        H|_ = {DoCurry Data}
        H
        end
    end
end

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                                  EVALUATOR
%%
%% /////////////////////////////////////////////////////////////////////////////
local
    fun {RightEvaluate T}
        if {Number.is T} then T
        else {Evaluate T} end
    end
    fun {Operate Op A B}
        case Op
        of '+' then A + B
        [] '-' then A - B
        [] '*' then A * B
        [] '/' then A / B
        end
    end
in
    fun {Evaluate T}
        case T
        of '+' then [T nil 1]
        [] '-' then [T nil 1]
        [] '*' then [T nil 1]
        [] '/' then [T nil 1]
        else
            Op Left D in
            Op|Left|D|nil = {Evaluate T.1}
            if D == 1 then [Op {RightEvaluate T.2} 0]
            elseif D == 0 then {Operate Op Left {RightEvaluate T.2}} end
        end
    end
end


%% /////////////////////////////////////////////////////////////////////////////
%%
%%                                   EXAMPLES
%%
%% /////////////////////////////////////////////////////////////////////////////


% % + * x x * y y
% % fun square x = x * x
% {Browse {StringListJoin {Infix2Prefix {AtomToList 'x * x'}}}}
% {Browse {Curry {Infix2Prefix {AtomToList 'x * x'}}}}
% {Browse ''}

% % ( x * x ) + ( y * y )
% {Browse {StringListJoin {Infix2Prefix {AtomToList '( x * x ) + ( y * y )'}}}}
% {Browse {Curry {Infix2Prefix {AtomToList '( x * x ) + ( y * y )'}}}}
% {Browse ''}

% % fun square x = x * x
% % square square x
% {Browse {StringListJoin {Infix2Prefix {AtomToList '( x * x ) * ( x * x )'}}}}
% {Browse {Curry {Infix2Prefix {AtomToList '( x * x ) x ( x * x )'}}}}
% {Browse ''}

% % fun sqr x = (x+1) * (x-1)
% % sqr x
% {Browse {StringListJoin {Infix2Prefix {AtomToList '( x + 1 ) * ( x - 1 )'}}}}
% {Browse {Curry {Infix2Prefix {AtomToList '( x + 1 ) * ( x - 1 )'}}}}
% {Browse ''}