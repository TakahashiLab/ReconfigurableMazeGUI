S=0;
for i=1:100
  S=S+max(size( rawData.trial(i).sptrain ));
end
S