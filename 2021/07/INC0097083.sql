begin
  --
  delete
  from   crapprp t
  where  t.cdcooper = 1
  and    t.nrdconta = 11657138
  and    t.nrctrato in (4087081,4087088)
  and    t.tpctrato = 90;
  --
  delete 
  from   tbrating_historicos t
  where  t.cdcooper = 1
  and    t.nrdconta = 11657138
  and    t.nrctremp in (4087081,4087088)
  and    t.tpctrato = 90;
  --
  delete
  FROM   tbrisco_operacoes t
  WHERE  t.cdcooper = 1
  AND    t.nrdconta = 11657138
  AND    t.nrctremp in (4087081,4087088)
  AND    t.tpctrato = 90;
  --
  delete
  from   crawepr t
  where  t.cdcooper = 1
  and    t.nrdconta = 11657138
  and    t.nrctremp in (4087081,4087088);
  --
  delete
  from   tbepr_renegociacao_contrato t
  where  t.cdcooper = 1
  and    t.nrdconta = 11657138
  and    t.nrctremp in (4087081,4087088);
  --
  delete
  from   tbepr_renegociacao t
  where  t.cdcooper = 1
  and    t.nrdconta = 11657138
  and    t.nrctremp in (4087081,4087088);  
  --
  ------------------------------------------------------------
  --
  delete
  from   crapprp t
  where  t.cdcooper = 10
  and    t.nrdconta = 13951
  and    t.nrctrato = 28277
  AND    t.tpctrato = 90;
  --
  delete
  from   tbrating_historicos t
  where  t.cdcooper = 10
  and    t.nrdconta = 13951
  and    t.nrctremp = 28277
  and    t.tpctrato = 90;
  --
  delete
  FROM   tbrating_detalhes td
  WHERE  td.idrating IN (SELECT tbo.idrating
                         FROM   tbrisco_operacoes tbo
                         WHERE  tbo.cdcooper = 10
                         AND    tbo.nrdconta = 13951
                         AND    tbo.nrctremp = 28277
                         AND    tbo.tpctrato = 90);
  --                                         
  delete
  FROM   tbrisco_operacoes tbo
  WHERE  tbo.cdcooper = 10
  AND    tbo.nrdconta = 13951
  AND    tbo.nrctremp = 28277
  AND    tbo.tpctrato = 90;
  --
  delete
  from   crawepr t
  where  t.cdcooper = 10
  and    t.nrdconta = 13951
  and    t.nrctremp = 28277;
  --
  delete
  from   tbepr_renegociacao_contrato t
  where  t.cdcooper = 10
  and    t.nrdconta = 13951
  and    t.nrctremp = 28277;
  --
  delete
  from   tbepr_renegociacao t
  where  t.cdcooper = 10
  and    t.nrdconta = 13951
  and    t.nrctremp = 28277;
  --
  commit;
  --
end;  
