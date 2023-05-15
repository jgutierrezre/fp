declare

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                                   PARSER
%%
%% /////////////////////////////////////////////////////////////////////////////

fun {AtomToList Data}
    {List.map {String.tokens {Atom.toString Data} & } fun {$ X} {String.toAtom X} end}
end

fun {ReplaceParams Var Val}
    {Record.map }
end

proc {AddFunction F}
    FUNCTIONS := {Record.adjoin @FUNCTIONS F}
end

local
    fun {DoSplitParamsAndBody L P V VF} % P: lista de parametros , V: lista de variables , VF: si tiene variables o no
        case L
        of X|Xr then
            case X
            of '=' then 
                case Xr 
                of N|O then
                    if N == 'var' then 
                        {DoSplitParamsAndBody O P O.1|V true}
                    else if VF then function(a:VF params:{List.reverse P} body:{List.takeWhile Xr fun{$X} X\='in' end} vars:{Map {List.reverse V} fun{$Y} {List.drop {List.dropWhile Xr fun{$X} X\='in' end} 1} end}.1) 
                    else function(a:VF params:{List.reverse P} body:{List.takeWhile Xr fun{$X} X\='in' end} vars:{Map {List.reverse V} fun{$Y} {List.drop {List.dropWhile Xr fun{$X} X\='in' end} 1} end}) end end
                end
            [] 'in' then function(a:VF params:{List.reverse P} body:{List.takeWhile Xr fun{$X} X\='in' end} vars:{Map {List.reverse V} fun{$Y} {List.drop {List.dropWhile Xr fun{$X} X\='in' end} 1} end}.1)
            else 
                if VF then {DoSplitParamsAndBody Xr P V VF}
                else {DoSplitParamsAndBody Xr X|P V VF} end
            end
        end
    end
in
    fun {SplitParamsAndBody L}
        {DoSplitParamsAndBody L nil nil false}
    end
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
                {Browse 'Tree Added for'}
                {Browse {StringListJoin {Infix2Prefix @FUNCTIONS.Y.body}}}
                {Browse {Curry {Infix2Prefix @FUNCTIONS.Y.body}}}
            end
        else
            % Check if X is defined
            % Params must change to be the number
            {Browse X}
            if {Value.hasFeature @FUNCTIONS X} then
                % if yes, then call it
                {Browse 'Function defined'}
                % {Browse @FUNCTIONS.X}
                % {Browse @FUNCTIONS.X.body}
                if {List.length Xr}>1 then 
                    FUNCTIONS := {Adjoin @FUNCTIONS functions(
                        X:{Adjoin @FUNCTIONS.X function(
                            body: {Map @FUNCTIONS.X.body fun {$ P} 
                                if {List.member P ['*' '/' '+' '-' '(' ')']} then P 
                                else if {List.is {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is 
                                else nil end end} fun{$S} S\=nil end}.1} then {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} 
                                    if Z == P then Xr.Is 
                                    else nil end end} fun{$S} S\=nil end}.1.1 
                                else {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} 
                                    if Z == P then Xr.Is 
                                    else nil end end} fun{$S} S\=nil end}.1 end end end} 
                            params:Xr)})}
                else FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(
                    body: {Map @FUNCTIONS.X.body fun {$ P} 
                        if {List.member P ['*' '/' '+' '-' '(' ')']} then P 
                        else Xr.1 end end} 
                    params:Xr)})} end
                
                if @FUNCTIONS.X.a then 
                    {Browse {Curry {Infix2Prefix @FUNCTIONS.X.body}}}
                    {Browse 'Result of evaluation for the variable'}
                    {Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.X.body}}}}
                    {Browse 'Result of evaluation for the varibale'}
                    FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(
                        vars: {Map @FUNCTIONS.X.vars fun {$ P} 
                            if {List.member P ['*' '/' '+' '-' '(' ')']} then P 
                            else {String.toAtom {Int.toString {Evaluate {Curry {Infix2Prefix @FUNCTIONS.X.body}}}}} end end} 
                        params:Xr)})}
                    {Browse @FUNCTIONS.X}
                    {Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.X.vars}}}}
                else
                    {Browse {Curry {Infix2Prefix @FUNCTIONS.X.body}}}
                    {Browse 'Result of evaluation'}
                    {Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.X.body}}}}
                end
            else
                % else, throw error
                {Browse 'Error: Function not defined'}
            end
        end
    end
end

%% /////////////////////////////////////////////////////////////////////////////
%%
%%                                   EXAMPLES
%%
%% /////////////////////////////////////////////////////////////////////////////

% In order to run the parser, run first the file fp.oz

FUNCTIONS = {Cell.new nil}

{Browse @FUNCTIONS}
% nil (FUNCTIONS is empty as no function has been added yet)
{Browse ''}

% ------------------------------------------------------------------------------
% FIRST EXAMPLE: SQUARE

{ParseString 'fun square x = x * x'}
% Function added
% Tree Added for
% * x x
% tree(tree('*' x) x)
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x])) (FUNCTIONS now contains the function square)
{Browse ''}

% Evaluate
{ParseString 'square 10'}
% square
% Function defined
% tree(tree('*' 10) 10)
% Result of evaluation
% 100
{Browse '----------------------'}

% ------------------------------------------------------------------------------
% SECOND EXAMPLE: DOUBLE
{ParseString 'fun double x = x + x'}
% Function added
% Tree Added for
% + x x
% tree(tree('+' x) x)
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]))
{Browse ''}

% Evaluate
{ParseString 'double 2'}
% double
% Function defined
% tree(tree('+' 2) 2)
% Result of evaluation
% 4
{Browse ''}

{Browse '----------------------'}

% ------------------------------------------------------------------------------
% THIRD EXAMPLE: SUM
{ParseString 'fun sum x y = x + y'}
% Function added
% Tree Added for
% + x y
% tree(tree('+' x) y)
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]))
{Browse ''}

% Evaluate
{ParseString 'sum 2 4'}
% sum
% Function defined
% tree(tree('+' 2) 4)
% Result of evaluation
% 6
{Browse ''}

% ------------------------------------------------------------------------------
% FOURTH EXAMPLE: TEST
{ParseString 'fun test x y = ( x * x ) + ( y * y )'}
% Function added
% Tree Added for
% + * x x * y y
% tree(tree('+' tree(tree('*' x) x)) tree(tree('*' y) y))
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]) test:function(body:[( x * x ) + ( y * y )] params:[x y]))
{Browse ''}

{ParseString 'test 3 5'}
% test
% Function defined
% tree(tree('+' tree(tree('*' 3) 3)) tree(tree('*' 5) 5))
% Result of evaluation
% 34
{Browse ''}

% ------------------------------------------------------------------------------
% FIFTH EXAMPLE: fourtimes
{ParseString 'fun fourtimes x = var y = x * x in y + y'}
% Function added
% Tree Added for
% + * x x * x x
% tree(tree('+' tree(tree('*' x) x)) tree(tree('*' x) x))
{Browse ''}
    
{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]) test:function(body:[( x * x ) + ( y * y )] params:[x y]))
{Browse ''}

{ParseString 'fourtimes 2'}
% test
% Function defined
% tree(tree('+' tree(tree('*' 3) 3)) tree(tree('*' 5) 5))
% Result of evaluation
% 34
{Browse ''}