﻿DECLARE

  vr_idremessa tbconv_remessa_pagfor.idremessa%TYPE;
begin

	insert into tbconv_remessa_pagfor (IDREMESSA, CDCONVENIO_PAGFOR, DTMOVIMENTO, DHENVIO_REMESSA, NMARQUIVO, TPSEGMENTO, NRSEQUENCIA_ARQUIVO, QTDREGISTROS, VLRARRECADACAO, CDSTATUS_REMESSA, CDSTATUS_RETORNO, FLGOCORRENCIA, CDAGENTE_ARRECADACAO)
	values (158729, '1QTH', to_date('21-12-2021', 'dd-mm-yyyy'), to_date('21-12-2021 07:00:02', 'dd-mm-yyyy hh24:mi:ss'), 'N1QTH210003.REM', 'N', 3, 1, 524.79, 1, 3, 1, 3)
  RETURNING idremessa INTO vr_idremessa;

	insert into tbconv_registro_remessa_pagfor (IDREGISTRO, IDREMESSA, IDSICREDI, TPPAGAMENTO, CDSTATUS_PROCESSAMENTO, VLRPAGAMENTO, DHINCLUSAO_PROCESSAMENTO, DHRETORNO_PROCESSAMENTO, NMARQUIVO_INCLUSAO, NMARQUIVO_RETORNO, DSPROCESSAMENTO, CDCOOPER, NRDCONTA, CDAGENCI, NRDOLOTE, CDEMPRESA_DOCUMENTO, NRAUTENTICACAO_DOCUMENTO, CDSTATUSHTTP, CDPROCESSAMENTO, QTENVIOS, NRNSUBCB, CDSITUACAO)
	values (4080402, vr_idremessa, 4669380, 4, 3, 524.79, null, to_date('05-01-2022 09:15:00', 'dd-mm-yyyy hh24:mi:ss'), null, '1QTH211210438564.RET', 'Aceito para processamento - 341000000006143922112202110432200052479', 16, 524824, 90, 31900, 'C06', 31530, '0', '0', 0, null, '02');

	insert into crapaut (CDAGENCI, NRDCAIXA, DTMVTOLT, NRSEQUEN, CDOPECXA, HRAUTENT, VLDOCMTO, NRDOCMTO, TPOPERAC, CDSTATUS, ESTORNO, NRSEQAUT, CDHISTOR, DSLITERA, BLIDENTI, BLTOTPAG, BLTOTREC, BLSLDINI, BLVALREC, INUSODBL, NRDCONTA, NRDCTADP, DSLEITUR, DSOBSERV, CDCOOPER, DSPROTOC, PROGRESS_RECID)
	values (90, 900, to_date('20-12-2021', 'dd-mm-yyyy'), 31530, '996', 49446, 524.79, 45.00, 0, '1', 0, 0, 3361, 'CVAV 31530 20DEZ21              *524,79RC 90009011877572700104', ' ', 0.00, 0.00, 0.00, 0.00, 0, 0, 0, ' ', ' ', 16, 'ED3B.CB6B.6943.35A0.3203.266B.4F2F.5FD6', 634572350);

	insert into crappro (DTMVTOLT, CDCOOPER, DSPROTOC, NRDCONTA, CDTIPPRO, DSINFORM##1, DSINFORM##2, DSINFORM##3, VLDOCMTO, NRDOCMTO, HRAUTENT, DTTRANSA, DSCEDENT, FLGAGEND, NRSEQAUT, NRCPFOPE, NRCPFPRE, NMPREPOS, PROGRESS_RECID, FLGATIVO, DSCOMPROVANTE_PARCEIRO, CDAGEARR, NMAGEARR, CDAGENCI, NMAGENCI)
	values (to_date('20-12-2021', 'dd-mm-yyyy'), 16, 'ED3B.CB6B.6943.35A0.3203.266B.4F2F.5FD6', 524824, 13, 'Pagamento de GPS', 'DIERSCHNABEL E CIA LTDA#Conta/dv: 524824 - DIERSCHNABEL E CIA LTDA', 'Linha Digitavel: #Codigo de Barras: #03 - Codigo de Pagamento: 4308#04 - Competência: 12/2021#05 - Identificador: 11877572700104#06 - Valor do INSS(R$): 524,79#09 - Valor Out. Entidades(R$): 0,00#10 - ATM/Multa e Juros(R$): 0,00#11 - Valor Total(R$): 524,79#Agente Arrecadador: 93 - POLOCRED SCMEPP LTDA.                             #Agência: 9999 - POLOCRED SCMEPP LTDA.                             ', 524.79, 45.00, 49447, to_date('20-12-2021 13:44:07', 'dd-mm-yyyy hh24:mi:ss'), 'GPS - IDENTIFICADOR 11877572700104', 0, 31530, 0, 98371770987, 'EDSON DIERSCHNABEL', 322294098, 1, null, null, null, null, null);

	insert into craplgp (CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, CDIDENTI, MMAACOMP, VLRDINSS, VLROUENT, VLRJUROS, VLRTOTAL, CDOPECXA, NRDCAIXA, NRDMAQUI, NRAUTDOC, NRSEQDIG, FLGENVIO, HRTRANSA, CDDPAGTO, IDSICRED, PROGRESS_RECID, CDBARRAS, NRCTAPAG, NRSEQAGP, INPESGPS, TPDPAGTO, DSLINDIG, DTVENCTO, NRSEQUNI, DSTIPARR, FLGPAGTO, TPLEITUR, CDIDENTI2, FLGATIVO, NRAUTSIC, IDANAFRD, IDSEQTTL, TPPAGMTO, CDORIGEM, QTENVIOS)
	values (16, to_date('20-12-2021', 'dd-mm-yyyy'), 90, 100, 31900, 11877572700104.00, 122021, 524.79, 0.00, 0.00, 524.79, '996', 900, 900, 31530, 45, 1, 49446, 4308, 4669380.00, 3557364, ' ', 524824, 0, 2, 2, ' ', to_date('30-12-2021', 'dd-mm-yyyy'), 0, 'TIVIT', 1, 0, '11877572700104', 1, 45, null, 0, 0, 3, 0);

	commit;

end;