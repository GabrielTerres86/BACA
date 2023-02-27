BEGIN
  UPDATE crapaca a
  SET a.nmdeacao = 'PROCESSA_ARQ_FUND_COTISTA'
     ,a.lstparam = 'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados,pr_tpprocesso'
       ,a.nmproced = 'pc_processar_arq_funding_cotista'     
  WHERE a.nmdeacao LIKE  'PROCESSA_ARQ_F%'
  AND a.nmpackag = 'EMPR0025';
  
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
         values ('CRED', 1, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '710');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
         values ('CRED', 16, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central','728');

  INSERT INTO cecred.crappco a
  (a.cdpartar, a.cdcooper, a.dsconteu)
  VALUES (118, 11, '10000,100,11000');

  INSERT INTO cecred.crappco a
  (a.cdpartar, a.cdcooper, a.dsconteu)
  VALUES (118, 2, '10000,100,11000');

  INSERT INTO cecred.crappco a
  (a.cdpartar, a.cdcooper, a.dsconteu)
  VALUES (118, 7, '10000,100,11000');
  
  UPDATE cecred.crappco a
  SET a.dsconteu = '1,15476588,3968/2,820024,3968/3,0,3968/5,0,3968/6,0,3968/7,850004,3968/8,0,3968/9,0,3968/10,0,3968/11,498823,3968/12,0,3968/13,0,3968/14,0,3968/16,933392,3968/'
  WHERE a.cdpartar = 176 AND a.cdcooper = 3;
   
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
