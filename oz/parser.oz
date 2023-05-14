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
            end
        else
            % Check if X is defined
            % Params must change to be the number
            {Browse X}
            if {Value.hasFeature @FUNCTIONS X} then
                % if yes, then call it
                {Browse 'Function defined'}
                {Browse @FUNCTIONS.X}
                {Browse @FUNCTIONS.X.body}
                % {Browse {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-']} then P else Xr.1 end end}}
                % {Browse {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-' '(' ')']} then P else if {List.is {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1} then {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1.1 else {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1 end end end}}
                {Browse {List.length Xr}}
                if {List.length Xr}>1 then FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(body: {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-' '(' ')']} then P else if {List.is {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1} then {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1.1 else {Filter {List.mapInd @FUNCTIONS.X.params fun {$ Is Z} if Z == P then Xr.Is else nil end end} fun{$S} S\=nil end}.1 end end end} params:Xr)})}
                else FUNCTIONS := {Adjoin @FUNCTIONS functions(X:{Adjoin @FUNCTIONS.X function(body: {Map @FUNCTIONS.X.body fun {$ P} if {List.member P ['*' '/' '+' '-' '(' ')']} then P else Xr.1 end end} params:Xr)})} end
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

% ----------------------
% FIRST EXAMPLE: SQUARE

{ParseString 'fun square x = x * x'}
% Function added
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x])) (FUNCTIONS now contains the function square)
{Browse ''}

% Curry and reduce
{Browse {StringListJoin {Infix2Prefix @FUNCTIONS.square.body}}}
% Tree
{Browse {Curry {Infix2Prefix @FUNCTIONS.square.body}}}
% Evaluate
{ParseString 'square 10'}
{Browse ''}
{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x])) (FUNCTIONS now contains the function square)
{Browse ''}
{Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.square.body}}}}

{Browse '----------------------'}

% ----------------------
% SECOND EXAMPLE: DOUBLE
{ParseString 'fun double x = x + x'}
% Function added
{Browse ''}

% Curry and reduce
{Browse {StringListJoin {Infix2Prefix @FUNCTIONS.double.body}}}
% Tree
{Browse {Curry {Infix2Prefix @FUNCTIONS.double.body}}}
% Evaluate
{ParseString 'double 2'}
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]))
{Browse ''}
{Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.double.body}}}}

{Browse '----------------------'}

% ----------------------
% THIRD EXAMPLE: SUM
{ParseString 'fun sum x y = x + y'}
% Function added
{Browse ''}

% {ParseString 'sum 2 4'}
% {Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]))
{Browse ''}

% {Browse {Map @FUNCTIONS.sum.body fun {$ P} if {List.member P ['*' '/' '+' '-']} then P else if {List.is {Filter {List.mapInd @FUNCTIONS.sum.params fun {$ Is Z} if Z == P then [5 6].Is else nil end end} fun{$S} S\=nil end}.1} then {Filter {List.mapInd @FUNCTIONS.sum.params fun {$ Is Z} if Z == P then [5 6].Is else nil end end} fun{$S} S\=nil end}.1.1 else {Filter {List.mapInd @FUNCTIONS.sum.params fun {$ Is Z} if Z == P then [5 6].Is else nil end end} fun{$S} S\=nil end}.1 end end end}}
% Curry and reduce
{Browse {StringListJoin {Infix2Prefix @FUNCTIONS.sum.body}}}
{Browse ''}
% Tree
{Browse {Curry {Infix2Prefix @FUNCTIONS.sum.body}}}
{Browse ''}
% Evaluate
{ParseString 'sum 2 4'}
{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]))
{Browse ''}
{Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.sum.body}}}}
{Browse '----------------------'}

% ----------------------
% FOURTH EXAMPLE: TEST
{ParseString 'fun test x y = ( x * x ) + ( y * y )'}
% Function added
{Browse ''}

{ParseString 'test 3 5'}
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]) test:function(body:[( x * x ) + ( y * y )] params:[x y]))
{Browse ''}

% Curry and reduce
{Browse {StringListJoin {Infix2Prefix @FUNCTIONS.test.body}}}
% Tree
{Browse {Curry {Infix2Prefix @FUNCTIONS.test.body}}}
% Evaluate
{Browse {Evaluate {Curry {Infix2Prefix @FUNCTIONS.test.body}}}}

{Browse '----------------------'}
% {Browse {StringListJoin {Infix2Prefix {AtomToList 'x * x'}}}}