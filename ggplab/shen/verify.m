function [f_value] =  verify(d,X0)
    % symbol vector
    X = sym('X',[19 1]);% X(1) = h1,...,X(8) = h8.  X(9) = q1,...,X(17) = q9. X(18) = speed, X(19) = z
    %W = sym('W',[18 1]);% X(1) = h1,...,X(8) = h8.  X(9) = q1,...,X(17) =
    %q9. X(18) = speed,X(19) = z
    % constant
    h_start_index = 1;
    h_end_index = 7;
    q_start_index = 8;
    q_end_index = 17;
    s_start_index = 18;
    s_end_index = 18;
    d2 =0;
    d3 = 75.0;
    d4 = 75.0;
    d5 = 100.0;
    d6 = 75.0;
    d7 = 0.0;
    href = 838.8;
    % get data from epanet
    d.getLinkNameID
    L_pipe = d.getLinkLength; % ft
    D_pipe = d.getLinkDiameter; % inches ; be careful, pump's diameter is 0
    C_pipe = d.getLinkRoughnessCoeff; % roughness of pipe
    % be careful, pump's diameter is 0, we need to exempt pump from pipe
    L_pipe = L_pipe(1:8);
    D_pipe = D_pipe(1:8)/12;
    C_pipe = C_pipe(1:8);

    % get the R cofficient for pipe 1 to 8
    Headloss_pipe_R = 4.727 * L_pipe./((C_pipe*448.8325660485).^(1.852))./(D_pipe.^(4.871));
    h_pipe = [];
    % formulate head loss of pipe 1 to 8
    for i = 1:8
        h_pipe = [h_pipe; Headloss_pipe_R(i) * X(q_start_index+i)^(1.852)];
    end
    % formulate head loss of pump 1 to 8
    h_pump = -X(18)^2*(200 - 0.0001389*(X(17)/X(18))^2);
%     f =[
%          X(17) * X(9)^(-1) ;
%          X(10) * X(9)^(-1) + X(12) * X(9)^(-1) + d3 * X(9)^(-1);
%          (X(11) + X(13) + d4) * X(10)^(-1) ;
%         (X(11) + X(15)) / d5  ;
%         (X(13) + X(14) - d6)/ X(15)  ;
%         (X(14) + X(16) + d7)/X(12)  ;
%         (X(2) + h_pump)/X(1);
%         (X(3) + h_pipe(1))/X(2);
%         (X(4) + h_pipe(2))/X(3);
%         (X(5) + h_pipe(3))/X(4);
%         (X(7) + h_pipe(4))/X(3);
%         (X(6) + h_pipe(5))/X(4);
%         (X(6) + h_pipe(6))/X(7);
%         (X(5) + h_pipe(7))/X(6);
%         (X(8) + h_pipe(8))/X(7);
%         ((X(8) - href)^2+100000)/X(19)];
    f =[
        X(17) - X(9) - d2 ;
        X(9) - X(10) - X(12) - d3 ;
        X(10) - X(11) - X(13) - d4 ;
        X(11) + X(15) - d5  ;
        X(13) + X(14) - X(15) - d6  ;
        X(12) - X(14) - X(16) - d7  ;
        X(1) - X(2) - h_pump  ;
        X(2) - X(3) - h_pipe(1)  ;
        X(3) - X(4) - h_pipe(2)  ;
        X(4) - X(5) - h_pipe(3)  ;
        X(3) - X(7) - h_pipe(4)  ;
        X(4) - X(6) - h_pipe(5)  ;
        X(7) - X(6) - h_pipe(6)  ;
        X(6) - X(5) - h_pipe(7)  ;
        X(7) - X(8) - h_pipe(8);
        (X(8) - href)^2];
    f_value = double(subs(f,X,X0));

end