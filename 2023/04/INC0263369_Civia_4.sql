DECLARE

    vr_dtAcao date := sysdate;
    conta_321877_116163_1 CLOB;
    conta_321877_116163_2 CLOB;
    conta_321877_116163_3 CLOB;
    conta_321877_116163_4 CLOB;
    conta_321877_116163_5 CLOB;
    conta_321877_116163_6 CLOB;
    conta_321877_116163_7 CLOB;
    conta_321877_116163_8 CLOB;
    conta_321877_116163_9 CLOB;
    conta_321877_116163_10 CLOB;
    conta_321877_116163_11 CLOB;
    conta_321877_116163_12 CLOB;
    conta_321877_116163_13 CLOB;
    conta_321877_116163_14 CLOB;
    conta_321877_116163_15 CLOB;
    conta_321877_116163_16 CLOB;
    conta_321877_116163_17 CLOB;
    conta_321877_116163_18 CLOB;
    conta_321877_116163_19 CLOB;
    conta_321877_116163_20 CLOB;
    conta_321877_116163_21 CLOB;
    conta_321877_116163_22 CLOB;
    conta_321877_116163_23 CLOB;
    conta_321877_116163_24 CLOB;
    conta_321877_116163_25 CLOB;

BEGIN
  
    conta_321877_116163_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-07-10</dataVencimento>     <identificador>2775315</identificador>     <valor>32.94</valor>   </parcela> </Root> ';
    conta_321877_116163_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-08-10</dataVencimento>     <identificador>2775316</identificador>     <valor>32.47</valor>   </parcela> </Root> ';
    conta_321877_116163_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-09-10</dataVencimento>     <identificador>2775317</identificador>     <valor>32.02</valor>   </parcela> </Root> ';
    conta_321877_116163_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-10-10</dataVencimento>     <identificador>2775318</identificador>     <valor>31.58</valor>   </parcela> </Root> ';
    conta_321877_116163_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-11-10</dataVencimento>     <identificador>2775319</identificador>     <valor>31.14</valor>   </parcela> </Root> ';
    conta_321877_116163_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-12-10</dataVencimento>     <identificador>2775320</identificador>     <valor>30.71</valor>   </parcela> </Root> ';
    conta_321877_116163_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-01-10</dataVencimento>     <identificador>2775321</identificador>     <valor>30.28</valor>   </parcela> </Root> ';
    conta_321877_116163_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-02-10</dataVencimento>     <identificador>2775322</identificador>     <valor>29.85</valor>   </parcela> </Root> ';
    conta_321877_116163_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-03-10</dataVencimento>     <identificador>2775323</identificador>     <valor>29.47</valor>   </parcela> </Root> ';
    conta_321877_116163_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-04-10</dataVencimento>     <identificador>2775324</identificador>     <valor>29.06</valor>   </parcela> </Root> ';
    conta_321877_116163_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-05-10</dataVencimento>     <identificador>2775325</identificador>     <valor>28.66</valor>   </parcela> </Root> ';
    conta_321877_116163_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-06-10</dataVencimento>     <identificador>2775326</identificador>     <valor>28.26</valor>   </parcela> </Root> ';
    conta_321877_116163_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-07-10</dataVencimento>     <identificador>2775327</identificador>     <valor>27.88</valor>   </parcela> </Root> ';
    conta_321877_116163_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-08-10</dataVencimento>     <identificador>2775328</identificador>     <valor>27.48</valor>   </parcela> </Root> ';
    conta_321877_116163_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-09-10</dataVencimento>     <identificador>2775329</identificador>     <valor>27.1</valor>   </parcela> </Root> ';
    conta_321877_116163_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-10-10</dataVencimento>     <identificador>2775330</identificador>     <valor>26.73</valor>   </parcela> </Root> ';
    conta_321877_116163_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-11-10</dataVencimento>     <identificador>2775331</identificador>     <valor>26.35</valor>   </parcela> </Root> ';
    conta_321877_116163_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2026-12-10</dataVencimento>     <identificador>2775332</identificador>     <valor>25.99</valor>   </parcela> </Root> ';
    conta_321877_116163_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-01-10</dataVencimento>     <identificador>2775333</identificador>     <valor>25.63</valor>   </parcela> </Root> ';
    conta_321877_116163_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-02-10</dataVencimento>     <identificador>2775334</identificador>     <valor>25.27</valor>   </parcela> </Root> ';
    conta_321877_116163_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-03-10</dataVencimento>     <identificador>2775335</identificador>     <valor>24.95</valor>   </parcela> </Root> ';
    conta_321877_116163_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-04-10</dataVencimento>     <identificador>2775336</identificador>     <valor>24.6</valor>   </parcela> </Root> ';
    conta_321877_116163_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-05-10</dataVencimento>     <identificador>2775337</identificador>     <valor>24.26</valor>   </parcela> </Root> ';
    conta_321877_116163_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-06-10</dataVencimento>     <identificador>2775338</identificador>     <valor>23.92</valor>   </parcela> </Root> ';
    conta_321877_116163_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2027-07-10</dataVencimento>     <identificador>2775339</identificador>     <valor>23.59</valor>   </parcela> </Root> ';

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_1
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_2
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_3
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_4
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_5
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_6
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_7
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_8
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_9
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_10
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_11
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_12
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_13
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_14
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_15
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_16
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_17
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_18
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_19
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_20
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_21
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_22
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_23
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_24
      );

    INSERT INTO cecred.tbgen_evento_soa (
      cdcooper
      ,nrdconta
      ,nrctrprp
      ,tpevento
      ,tproduto_evento
      ,tpoperacao
      ,dhoperacao
      ,dsprocessamento
      ,dsstatus
      ,dhevento
      ,dserro
      ,nrtentativas
      ,dsconteudo_requisicao
      )
    VALUES (
      13
      ,321877
      ,116163
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_321877_116163_25
      );

      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
