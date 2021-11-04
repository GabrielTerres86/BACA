begin

delete tbepr_consignado_pagamento 
where cdcooper = 2
and (nrdconta, nrctremp)  in ((832510,301017), (858072,299588), (873926,300286));

insert into tbepr_consignado_pagamento ( CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (2, 832510, 301017, 3, 1, 162.19, 162.19, to_date('01-07-2021', 'dd-mm-yyyy'), 2, to_date('02-07-2021 07:00:23', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-07-2021 07:11:15', 'dd-mm-yyyy hh24:mi:ss'), 19, 0, '1', null, null, 1, to_date('02-07-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento ( CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values ( 2, 832510, 301017, 7, 1, 158.95, 4.67, to_date('01-11-2021', 'dd-mm-yyyy'), 3, to_date('03-11-2021 07:01:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-11-2021 07:03:03', 'dd-mm-yyyy hh24:mi:ss'), 19, 0, '1', null, null, null, to_date('03-11-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento ( CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values ( 2, 858072, 299588, 6, 1, 1064.51, 761.97, to_date('01-11-2021', 'dd-mm-yyyy'), 3, to_date('03-11-2021 07:01:37', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-11-2021 07:03:07', 'dd-mm-yyyy hh24:mi:ss'), 8, 0, '1', null, null, null, to_date('03-11-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento ( CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values ( 2, 873926, 300286, 7, 1, 388.88, 0.39, to_date('01-11-2021', 'dd-mm-yyyy'), 3, to_date('03-11-2021 07:01:37', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-11-2021 07:01:51', 'dd-mm-yyyy hh24:mi:ss'), 19, 0, '1', null, null, null, to_date('03-11-2021', 'dd-mm-yyyy'));

commit;

end;