DECLARE

    vr_dtAcao date := sysdate;
    conta_187402_118241_1 CLOB;
    conta_187402_118241_2 CLOB;
    conta_187402_118241_3 CLOB;
    conta_187402_118241_4 CLOB;
    conta_187402_118241_5 CLOB;
    conta_187402_118241_6 CLOB;
    conta_187402_118241_7 CLOB;
    conta_187402_118241_8 CLOB;
    conta_187402_118241_9 CLOB;
    conta_187402_118241_10 CLOB;
    conta_187402_118241_11 CLOB;
    conta_187402_118241_12 CLOB;
    conta_187402_118241_13 CLOB;
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
    conta_321877_116163_26 CLOB;

BEGIN
  
  conta_187402_118241_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-06-10</dataVencimento>     <identificador>2775263</identificador>     <valor>344.93</valor>   </parcela> </Root> ';
  conta_187402_118241_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-07-10</dataVencimento>     <identificador>2775264</identificador>     <valor>339.25</valor>   </parcela> </Root> ';
  conta_187402_118241_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-08-10</dataVencimento>     <identificador>2775265</identificador>     <valor>333.47</valor>   </parcela> </Root> ';
  conta_187402_118241_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-09-10</dataVencimento>     <identificador>2775266</identificador>     <valor>327.79</valor>   </parcela> </Root> ';
  conta_187402_118241_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-10-10</dataVencimento>     <identificador>2775267</identificador>     <valor>322.39</valor>   </parcela> </Root> ';
  conta_187402_118241_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-11-10</dataVencimento>     <identificador>2775268</identificador>     <valor>316.9</valor>   </parcela> </Root> ';
  conta_187402_118241_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-12-10</dataVencimento>     <identificador>2775269</identificador>     <valor>311.68</valor>   </parcela> </Root> ';
  conta_187402_118241_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-01-10</dataVencimento>     <identificador>2775270</identificador>     <valor>306.37</valor>   </parcela> </Root> ';
  conta_187402_118241_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-02-10</dataVencimento>     <identificador>2775271</identificador>     <valor>301.15</valor>   </parcela> </Root> ';
  conta_187402_118241_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-02-10</dataVencimento>     <identificador>2775272</identificador>     <valor>296.52</valor>   </parcela> </Root> ';
  conta_187402_118241_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-04-10</dataVencimento>     <identificador>2775273</identificador>     <valor>291.47</valor>   </parcela> </Root> ';
  conta_187402_118241_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-05-10</dataVencimento>     <identificador>2775274</identificador>     <valor>286.66</valor>   </parcela> </Root> ';
  conta_187402_118241_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>118241</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>187402</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2025-06-10</dataVencimento>     <identificador>2775275</identificador>     <valor>281.78</valor>   </parcela> </Root> ';
  conta_321877_116163_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-04-10</dataVencimento>     <identificador>2775276</identificador>     <valor>55.2</valor>   </parcela> </Root> ';
  conta_321877_116163_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-05-10</dataVencimento>     <identificador>2775277</identificador>     <valor>54.57</valor>   </parcela> </Root> ';
  conta_321877_116163_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-06-10</dataVencimento>     <identificador>2775278</identificador>     <valor>54.03</valor>   </parcela> </Root> ';
  conta_321877_116163_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-07-10</dataVencimento>     <identificador>2775279</identificador>     <valor>53.5</valor>   </parcela> </Root> ';
  conta_321877_116163_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-08-10</dataVencimento>     <identificador>2775280</identificador>     <valor>52.96</valor>   </parcela> </Root> ';
  conta_321877_116163_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-09-10</dataVencimento>     <identificador>2775281</identificador>     <valor>52.43</valor>   </parcela> </Root> ';
  conta_321877_116163_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775282</identificador>     <valor>51.92</valor>   </parcela> </Root> ';
  conta_321877_116163_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775283</identificador>     <valor>51.4</valor>   </parcela> </Root> ';
  conta_321877_116163_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775284</identificador>     <valor>50.9</valor>   </parcela> </Root> ';
  conta_321877_116163_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775285</identificador>     <valor>50.39</valor>   </parcela> </Root> ';
  conta_321877_116163_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775286</identificador>     <valor>49.88</valor>   </parcela> </Root> ';
  conta_321877_116163_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775287</identificador>     <valor>49.43</valor>   </parcela> </Root> ';
  conta_321877_116163_26 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>116163</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>321877</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775288</identificador>     <valor>48.04</valor>   </parcela> </Root> ';

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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_1
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_2
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_3
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_4
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_5
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_6
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_7
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_8
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_9
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_10
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_11
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_12
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
    ,187402
    ,118241
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_187402_118241_13
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
    ,conta_321877_116163_26
    );

      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
