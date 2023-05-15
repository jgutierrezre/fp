declare
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

% %X = tree(tree('+' tree(tree('*' x) x)) tree(tree('*' y) y))
% X = tree(tree('+' tree(tree('*' 5) 5)) tree(tree('*' 3) 3)) % x = 5, y = 3

% %Y = tree(tree('*' tree(tree('+' x) 1)) tree(tree('-' x) 1))
% Y = tree(tree('*' tree(tree('+' 4) 1)) tree(tree('-' 4) 1)) % x = 4

% {Browse {Evaluate X}}
% {Browse {Evaluate Y}}