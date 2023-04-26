DECLARE

    vr_dtAcao date := sysdate;
    conta_10827200_3008250_1 CLOB;
    conta_10827200_3008250_2 CLOB;
    conta_10827200_3008250_3 CLOB;
    conta_10827200_3008250_4 CLOB;
    conta_10827200_3008250_5 CLOB;
    conta_10827200_3008250_6 CLOB;
    conta_10827200_3008250_7 CLOB;
    conta_10827200_3008250_8 CLOB;
    conta_10827200_3008250_9 CLOB;
    conta_11623160_3060112_10 CLOB;
    conta_11623160_3060112_11 CLOB;
    conta_11623160_3060112_12 CLOB;
    conta_11623160_3060112_13 CLOB;
    conta_11623160_3060112_14 CLOB;
    conta_11623160_3060112_15 CLOB;
    conta_11623160_3060112_16 CLOB;
    conta_11623160_3060112_17 CLOB;
    conta_11623160_3060112_18 CLOB;
    conta_11623160_3060112_19 CLOB;
    conta_11623160_3060112_20 CLOB;
    conta_11623160_3060112_21 CLOB;
    conta_11623160_3060112_22 CLOB;
    conta_11623160_3060112_23 CLOB;
    conta_11623160_3060112_24 CLOB;
    conta_11623160_3060112_25 CLOB;

BEGIN
  
    conta_10827200_3008250_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-02-10</dataVencimento>     <identificador>2775129</identificador>     <valor>287.49</valor>   </parcela> </Root> ';
    conta_10827200_3008250_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-03-10</dataVencimento>     <identificador>2775130</identificador>     <valor>282.76</valor>   </parcela> </Root> ';
    conta_10827200_3008250_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-04-10</dataVencimento>     <identificador>2775131</identificador>     <valor>277.8</valor>   </parcela> </Root> ';
    conta_10827200_3008250_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-05-10</dataVencimento>     <identificador>2775132</identificador>     <valor>273.08</valor>   </parcela> </Root> ';
    conta_10827200_3008250_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-06-10</dataVencimento>     <identificador>2775133</identificador>     <valor>268.29</valor>   </parcela> </Root> ';
    conta_10827200_3008250_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-07-10</dataVencimento>     <identificador>2775134</identificador>     <valor>263.73</valor>   </parcela> </Root> ';
    conta_10827200_3008250_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-08-10</dataVencimento>     <identificador>2775135</identificador>     <valor>259.1</valor>   </parcela> </Root> ';
    conta_10827200_3008250_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-09-10</dataVencimento>     <identificador>2775136</identificador>     <valor>254.55</valor>   </parcela> </Root> ';
    conta_10827200_3008250_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-10-10</dataVencimento>     <identificador>2775137</identificador>     <valor>250.22</valor>   </parcela> </Root> ';
    conta_11623160_3060112_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-05-10</dataVencimento>     <identificador>2775138</identificador>     <valor>441.6</valor>   </parcela> </Root> ';
    conta_11623160_3060112_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-06-10</dataVencimento>     <identificador>2775139</identificador>     <valor>437.16</valor>   </parcela> </Root> ';
    conta_11623160_3060112_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-07-10</dataVencimento>     <identificador>2775140</identificador>     <valor>432.91</valor>   </parcela> </Root> ';
    conta_11623160_3060112_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-08-10</dataVencimento>     <identificador>2775141</identificador>     <valor>428.56</valor>   </parcela> </Root> ';
    conta_11623160_3060112_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-09-10</dataVencimento>     <identificador>2775142</identificador>     <valor>424.25</valor>   </parcela> </Root> ';
    conta_11623160_3060112_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775143</identificador>     <valor>420.13</valor>   </parcela> </Root> ';
    conta_11623160_3060112_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775144</identificador>     <valor>415.91</valor>   </parcela> </Root> ';
    conta_11623160_3060112_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775145</identificador>     <valor>411.87</valor>   </parcela> </Root> ';
    conta_11623160_3060112_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775146</identificador>     <valor>407.74</valor>   </parcela> </Root> ';
    conta_11623160_3060112_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775147</identificador>     <valor>403.65</valor>   </parcela> </Root> ';
    conta_11623160_3060112_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775148</identificador>     <valor>399.99</valor>   </parcela> </Root> ';
    conta_11623160_3060112_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775149</identificador>     <valor>388.72</valor>   </parcela> </Root> ';
    conta_11623160_3060112_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775150</identificador>     <valor>381.24</valor>   </parcela> </Root> ';
    conta_11623160_3060112_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775151</identificador>     <valor>374.55</valor>   </parcela> </Root> ';
    conta_11623160_3060112_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775152</identificador>     <valor>368.19</valor>   </parcela> </Root> ';
    conta_11623160_3060112_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775153</identificador>     <valor>361.73</valor>   </parcela> </Root> ';

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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_1
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_2
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_3
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_4
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_5
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_6
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_7
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_8
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
      1
      ,10827200
      ,3008250
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_10827200_3008250_9
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_10
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_11
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_12
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_13
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_14
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_15
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_16
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_17
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_18
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_19
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_20
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_21
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_22
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_23
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_24
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
      1
      ,11623160
      ,3060112
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11623160_3060112_25
      );

      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
