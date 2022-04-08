begin

insert into tbepr_consignado_pagamento ( CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values ( 2, 1069217, 338555, 2, 2, 87.03, 87.03, to_date('10-02-2022', 'dd-mm-yyyy'), 3, to_date('05-03-2022 09:38:14', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-03-2022 09:39:01', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 'f0020642', null, null, null, to_date('07-03-2022', 'dd-mm-yyyy'));
commit;
end;
