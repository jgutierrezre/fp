declare

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
    fun {DoSplitParamsAndBody L P}
        case L
        of X|Xr then
            case X
            of '=' then function(params:{List.reverse P} body:Xr)
            else {DoSplitParamsAndBody Xr X|P}
            end
        end
    end
in
    fun {SplitParamsAndBody L}
        {DoSplitParamsAndBody L nil}
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
                if {List.length Xr}>1 then FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(body: {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-' '(' ')']} then P else if {List.is {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1} then {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1.1 else {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1 end end end} params:Xr)})}
                else FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(body: {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-' '(' ')']} then P else Xr.1 end end} params:Xr)})} end
                
                {Browse {Curry {Infix2Prefix @FUNCTIONS.X.body}}}
                {Browse 'Result of evaluation'}
                {Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.X.body}}}}
            else
                % else, throw error
                {Browse 'Error: Function not defined'}
            end
        end
    end
end

% fun {ApplyParams }

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

