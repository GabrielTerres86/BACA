DECLARE

    vr_dtAcao date := sysdate;
    conta_469661_135698_1 CLOB;
    conta_469661_135698_2 CLOB;
    conta_469661_135698_3 CLOB;
    conta_469661_135698_4 CLOB;
    conta_469661_135698_5 CLOB;
    conta_469661_135698_6 CLOB;
    conta_469661_135698_7 CLOB;
    conta_503584_102245_8 CLOB;
    conta_503584_102245_9 CLOB;
    conta_503584_102245_10 CLOB;
    conta_503584_102245_11 CLOB;
    conta_503584_102245_12 CLOB;
    conta_503584_102245_13 CLOB;
    conta_503584_102245_14 CLOB;
    conta_503584_102245_15 CLOB;
    conta_503584_102245_16 CLOB;
    conta_503584_102245_17 CLOB;
    conta_503584_102245_18 CLOB;
    conta_503584_102245_19 CLOB;
    conta_503584_102245_20 CLOB;
    conta_503584_102245_21 CLOB;
    conta_503584_102245_22 CLOB;
    conta_503584_102245_23 CLOB;
    conta_503584_102245_24 CLOB;
    conta_503584_102245_25 CLOB;
    conta_503584_102245_26 CLOB;

BEGIN
  
    conta_469661_135698_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775532</identificador>     <valor>249.23</valor>   </parcela> </Root> ';
    conta_469661_135698_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775533</identificador>     <valor>244.57</valor>   </parcela> </Root> ';
    conta_469661_135698_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775534</identificador>     <valor>240.39</valor>   </parcela> </Root> ';
    conta_469661_135698_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775535</identificador>     <valor>236.42</valor>   </parcela> </Root> ';
    conta_469661_135698_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775536</identificador>     <valor>232.38</valor>   </parcela> </Root> ';
    conta_469661_135698_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775537</identificador>     <valor>228.41</valor>   </parcela> </Root> ';
    conta_469661_135698_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>135698</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>469661</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775538</identificador>     <valor>224.64</valor>   </parcela> </Root> ';
    conta_503584_102245_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-04-10</dataVencimento>     <identificador>2775539</identificador>     <valor>371.55</valor>   </parcela> </Root> ';
    conta_503584_102245_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-05-10</dataVencimento>     <identificador>2775540</identificador>     <valor>548.65</valor>   </parcela> </Root> ';
    conta_503584_102245_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-06-10</dataVencimento>     <identificador>2775541</identificador>     <valor>543.14</valor>   </parcela> </Root> ';
    conta_503584_102245_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-07-10</dataVencimento>     <identificador>2775542</identificador>     <valor>537.86</valor>   </parcela> </Root> ';
    conta_503584_102245_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-08-10</dataVencimento>     <identificador>2775543</identificador>     <valor>532.45</valor>   </parcela> </Root> ';
    conta_503584_102245_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-09-10</dataVencimento>     <identificador>2775544</identificador>     <valor>527.1</valor>   </parcela> </Root> ';
    conta_503584_102245_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775545</identificador>     <valor>521.98</valor>   </parcela> </Root> ';
    conta_503584_102245_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775546</identificador>     <valor>516.74</valor>   </parcela> </Root> ';
    conta_503584_102245_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775547</identificador>     <valor>511.72</valor>   </parcela> </Root> ';
    conta_503584_102245_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775548</identificador>     <valor>506.58</valor>   </parcela> </Root> ';
    conta_503584_102245_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775549</identificador>     <valor>501.5</valor>   </parcela> </Root> ';
    conta_503584_102245_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775550</identificador>     <valor>496.95</valor>   </parcela> </Root> ';
    conta_503584_102245_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775551</identificador>     <valor>482.95</valor>   </parcela> </Root> ';
    conta_503584_102245_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775552</identificador>     <valor>473.93</valor>   </parcela> </Root> ';
    conta_503584_102245_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775553</identificador>     <valor>465.86</valor>   </parcela> </Root> ';
    conta_503584_102245_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775554</identificador>     <valor>458.18</valor>   </parcela> </Root> ';
    conta_503584_102245_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775555</identificador>     <valor>450.38</valor>   </parcela> </Root> ';
    conta_503584_102245_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775556</identificador>     <valor>442.7</valor>   </parcela> </Root> ';
    conta_503584_102245_26 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>102245</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>503584</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775557</identificador>     <valor>435.4</valor>   </parcela> </Root> ';

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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_1
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_2
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_3
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_4
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_5
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_6
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
      ,469661
      ,135698
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_469661_135698_7
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_8
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_9
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_10
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_11
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_12
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_13
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_14
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_15
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_16
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_17
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_18
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_19
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_20
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_21
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_22
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_23
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_24
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_25
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
      ,503584
      ,102245
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_503584_102245_26
      );
      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
