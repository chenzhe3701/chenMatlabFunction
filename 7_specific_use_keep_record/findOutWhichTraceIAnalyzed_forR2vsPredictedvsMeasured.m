% In 1st draft of Exp Mech paper, we plotted some RDR values, but lost
% track of their grain ID.  This code is used to compare the RDR with those
% saved in traceStruct, and find out the grain ID.
%
% chenzhe note: 2016-10-7

a=[-0.78669
    0.77950
    -0.93272
    -1.0646
    -0.99917
    1.2673
    0.59496
    -0.69626
    -0.86992
    0.83198
    -0.97264
    -0.95376
    -0.94276
    2.3512
    -0.96295
    1.4401
    1.5308
    -0.72442
    1.7043
    -0.81838
    0.83435
    0.70123
    -1.5087
    -0.75651
    -2.3364
    0.75209
    -1.0178
    0.55416
    -1.0209
    0.85842
    -0.67178
    -1.0531
    -0.65995
    0.88484
    -0.67040
    0.86526
    -0.80403
    1.3599
    -0.64565
    -1.1650
    -2.1744
    -1.2775
    -1.7556
    0.84685
    1.4455
    -0.90296
    -1.4055
    2.4639
    -1.2967
    1.2284
    1.8652
    0.60448
    0.90189
    1.0297
    -1.7032
    0.55619
    -1.4710
    1.0109
    -0.74381
    1.7588
    -1.1755
    1.0232
    -0.78493
    -0.67160
    -0.53121];
for ll=1:length(a);
    target = a(ll);
    for ii = 1:162
        d = traceStruct(ii).RDR;
        for kk = 1:size(d,1)
            dd = d(kk,:);
            for jj = 1:length(dd)
                if abs(dd(jj)-target)<0.001
                    disp([ii, jj]);
%                     disp(dd);
                end
            end
        end
    end
end