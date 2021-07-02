BEGIN
  DELETE tbepr_renegociacao_craplem l
  WHERE  l.cdcooper =   1
  AND    l.cdhistor =   2535
  AND    l.nrdconta =   10469150
  AND    l.nrctremp in (2275902,2276420,2275287,2275645)
  AND    l.nrdocmto in (6167083,6167088,6167096,6167106)
  AND    l.dtmvtolt =  '01/04/2021' 
  AND    l.nrversao =   2;
  --     
  DELETE tbepr_renegociacao_craplem l
  WHERE  l.cdcooper =   1
  AND    l.cdhistor =   2535
  AND    l.nrdconta =   8783926
  AND    l.nrctremp in (2255514,2255458)
  AND    l.nrdocmto in (6467166,6467174)
  AND    l.dtmvtolt =  '06/04/2021' 
  AND    l.nrversao =   2;
  --
  DELETE tbepr_renegociacao_craplem l
  WHERE  l.cdcooper =   1
  AND    l.cdhistor =   2535
  AND    l.nrdconta =   6263453
  AND    l.nrctremp in (2231340,2231369,2231285,2231317)
  AND    l.nrdocmto in (6636875,6636880,6636890,6636901)
  AND    l.dtmvtolt =  '07/04/2021' 
  AND    l.nrversao =   2;      
  --
  COMMIT;
  --                                          
END;
