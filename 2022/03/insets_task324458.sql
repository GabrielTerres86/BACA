begin

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1175201, 14, 289310, 50890, 1, 1, 373.91, 373.91, to_date('10-02-2022', 'dd-mm-yyyy'), 3, to_date('11-02-2022 07:00:47', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:03:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 0, '1', null, null, null, to_date('11-02-2022', 'dd-mm-yyyy'));

commit;
end;
