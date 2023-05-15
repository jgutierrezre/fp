declare
%% /////////////////////////////////////////////////////////////////////////////
%%
%%                               INFIX - POSTFIX
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
%% It is necessary that every element in a program its separated by single space.  
%%
%% /////////////////////////////////////////////////////////////////////////////


%{Browse {Infix2Prefix {Str2Lst "fun hola X Y Z = var A = X * Y var B = A + 2 in A * B + Z"}}}

%{Browse {Infix2Prefix {Str2Lst "fun square x = x * x"}}}
% * fun square x = x x

% {Browse {StringListJoin {Infix2Prefix {AtomToList '( x * x ) + ( y * y )'}}}}
% + * x x * y y