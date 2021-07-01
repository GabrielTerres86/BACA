begin
  delete tbepr_renegociacao_craplem l
  WHERE  l.cdcooper =   1
  AND    l.cdhistor =   2535
  AND    l.nrdconta in (10469150
                       ,8783926
                       ,6263453)
  AND    l.nrdocmto in (6167083,6167088,6167096,6167106
                       ,6467166,6467174
                       ,6636875,6636880,6636890,6636901);
  --
  commit;
  --                                          
end;
