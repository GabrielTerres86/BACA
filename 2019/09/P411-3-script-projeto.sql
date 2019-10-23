
/* Parametro de criticas ignoradas para envio de e-mail */
insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 values
('CRED', 0, 'CRITIC_IGNORE_B3','Listagem de códigos de crítica para não alertar via e-mail no processo de integração com a B3.','1201,1489,1490,1498,1482,1481,1471,1472,1473,1474,1475,1476,1477,1478,1479,1470,1484');


/* Configuracao de qtd. maxima de registro por arquivo - html conciliacao */
update crapprm 
  set dsvlrprm = '000050000' 
where nmsistem = 'CRED'
  and cdcooper = 0
  and cdacesso = 'QTD_REG_CCL_FRN_APL';


commit;