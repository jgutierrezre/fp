declare

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
fun {Infix2Prefix Data}
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
                    local H2 T2 in
                        {List.takeDropWhile Stack fun {$ X} X \= "(" end H2 T2} % Take all the elements until a "(" is found and add them to H2 and the rest to T2
                        {Infix2Postfix T T2 {List.append H2 Res}}
                    end 
                [] "+" then
                    local H2 T2 in
                        {List.takeDropWhile Stack fun {$ X} {List.member X ["*" "/"]} end H2 T2} % Take all the elements until a "*" or "/" is found and add them to H2 and the rest to T2
                        {Infix2Postfix T H|T2 {List.append H2 Res}}
                    end
                [] "-" then
                    local H2 T2 in
                        {List.takeDropWhile Stack fun {$ X} {List.member X ["*" "/"]} end H2 T2} % Take all the elements until a "*" or "/" is found and add them to H2 and the rest to T2
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
        {StringListJoin % Convert the list of strings to a string
            {Infix2Postfix % Convert the infix to postfix
                "("|{ReverseWithParentheses "("|{AtomListToStringList Data} nil} 
                nil 
                nil
            }
        }
    end
end

% fun {GetOperations L}
%     case L
%     of nil then nil
%     [] X|Xr then
%         case X
%         of '+' then X|{GetOperations Xr}
%         [] '-' then X|{GetOperations Xr}
%         [] '*' then X|{GetOperations Xr}
%         [] '/' then X|{GetOperations Xr}
%         [] '=' then X|{GetOperations Xr}
%         else {GetOperations Xr}
%         end
%     end
% end

% {Browse {GetOperations {AtomToList S1}}}

proc {AddFunction F}
    FUNCTIONS := {Record.adjoin @FUNCTIONS F}
end

proc {ParseString S}
    case {AtomToList S}
    of X|Xr then
        case X
        of 'fun' then
            {Browse S}
            {Browse 'Function added'}
            case Xr
            of Y|Yr then
                {AddFunction functions(Y:{SplitParamsAndBody Yr})}
            end
        else
            % Check if X is defined
            {Browse X}
            if {Value.hasFeature @FUNCTIONS X} then
                % if yes, then call it
                {Browse 'Function defined'}
                {Browse @FUNCTIONS.X}
                {Browse @FUNCTIONS.X.body}
                {Browse {AtomToList @FUNCTIONS.X.body}}
            else
                % else, throw error
                {Browse 'Error: Function not defined'}
            end
        end
    end
end

local
    fun {DoSplitParamsAndBody L P}
        case L
        of X|Xr then
            case X
            of '=' then function(params:{List.reverse P} body:{Infix2Prefix Xr})
            else {DoSplitParamsAndBody Xr X|P}
            end
        end
    end
in
    fun {SplitParamsAndBody L}
        {DoSplitParamsAndBody L nil}
    end
end

% fun square x = x * x
% square 10

FUNCTIONS = {Cell.new nil}

{Browse @FUNCTIONS}
{Browse ''}
S1 = 'fun square x = x * x'
S2 = 'square 10'
    
{ParseString S1}
{Browse ''}

{Browse @FUNCTIONS}
{Browse ''}

{ParseString S2}
{Browse ''}
{ParseString 'double 10'}
{Browse ''}

{ParseString 'fun double x = x + x'}
{Browse ''}

{Browse @FUNCTIONS}

{ParseString 'fun sum x y = x + y'}
{Browse ''}

{Browse @FUNCTIONS}

{ParseString 'fun test x y = ( x * x ) + ( y * y )'}
{Browse ''}

{Browse @FUNCTIONS}

% X = 10
% T = tree(tree('*' X) X)

% {Browse T}