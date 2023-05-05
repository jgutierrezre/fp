declare

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
                [{String.toAtom H} T]
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