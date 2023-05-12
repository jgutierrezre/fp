declare

fun {AtomToList Data}
    {List.map {String.tokens {Atom.toString Data} & } fun {$ X} {String.toAtom X} end}
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
                % @FUNCTIONS.X.params.1 = 10
            else
                % else, throw error
                {Browse 'Error: Function not defined'}
            end
        end
    end
end

FUNCTIONS = {Cell.new nil}

{Browse @FUNCTIONS}
% nil (FUNCTIONS is empty as no function has been added yet)
{Browse ''}

S1 = 'fun square x = x * x'
S2 = 'square 10'
{ParseString S1}
% Function added
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x])) (FUNCTIONS now contains the function square)
{Browse ''}

{ParseString S2}
% square
% Function defined
% square:function(body:[x * x] params:[x])
% [x * x]
{Browse ''}
{Browse @FUNCTIONS}

{ParseString 'double 10'}
% double
% Error: Function not defined)
{Browse ''}

{ParseString 'fun double x = x + x'}
% Function added
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]))
{Browse ''}

{ParseString 'fun sum x y = x + y'}
% Function added
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]))
{Browse ''}

{ParseString 'fun test x y = ( x * x ) + ( y * y )'}
% Function added
{Browse ''}

{Browse @FUNCTIONS}
% functions(square:function(body:[x * x] params:[x]) double:function(body:[x + x] params:[x]) sum:function(body:[x + y] params:[x y]) test:function(body:[( x * x ) + ( y * y )] params:[x y]))
{Browse ''}