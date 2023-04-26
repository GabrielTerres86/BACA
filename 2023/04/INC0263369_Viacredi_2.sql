DECLARE

    vr_dtAcao date := sysdate;
    conta_7894694_3222606_1 CLOB;
    conta_7894694_3222606_2 CLOB;
    conta_7894694_3222606_3 CLOB;
    conta_7894694_3222606_4 CLOB;
    conta_7894694_3222606_5 CLOB;
    conta_10827200_3008250_6 CLOB;
    conta_10827200_3008250_7 CLOB;
    conta_10827200_3008250_8 CLOB;
    conta_10827200_3008250_9 CLOB;
    conta_10827200_3008250_10 CLOB;
    conta_10827200_3008250_11 CLOB;
    conta_10827200_3008250_12 CLOB;
    conta_10827200_3008250_13 CLOB;
    conta_10827200_3008250_14 CLOB;
    conta_10827200_3008250_15 CLOB;
    conta_10827200_3008250_16 CLOB;
    conta_10827200_3008250_17 CLOB;
    conta_10827200_3008250_18 CLOB;
    conta_10827200_3008250_19 CLOB;
    conta_10827200_3008250_20 CLOB;
    conta_10827200_3008250_21 CLOB;
    conta_10827200_3008250_22 CLOB;
    conta_10827200_3008250_23 CLOB;
    conta_10827200_3008250_24 CLOB;
    conta_10827200_3008250_25 CLOB;

BEGIN
  
    conta_7894694_3222606_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-08-10</dataVencimento>     <identificador>2775104</identificador>     <valor>121.83</valor>   </parcela> </Root> ';
    conta_7894694_3222606_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-09-10</dataVencimento>     <identificador>2775105</identificador>     <valor>119.69</valor>   </parcela> </Root> ';
    conta_7894694_3222606_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-10-10</dataVencimento>     <identificador>2775106</identificador>     <valor>117.66</valor>   </parcela> </Root> ';
    conta_7894694_3222606_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-11-10</dataVencimento>     <identificador>2775107</identificador>     <valor>115.59</valor>   </parcela> </Root> ';
    conta_7894694_3222606_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-12-10</dataVencimento>     <identificador>2775108</identificador>     <valor>113.63</valor>   </parcela> </Root> ';
    conta_10827200_3008250_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-06-10</dataVencimento>     <identificador>2775109</identificador>     <valor>385.96</valor>   </parcela> </Root> ';
    conta_10827200_3008250_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-07-10</dataVencimento>     <identificador>2775110</identificador>     <valor>382.2</valor>   </parcela> </Root> ';
    conta_10827200_3008250_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-08-10</dataVencimento>     <identificador>2775111</identificador>     <valor>378.36</valor>   </parcela> </Root> ';
    conta_10827200_3008250_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-09-10</dataVencimento>     <identificador>2775112</identificador>     <valor>374.56</valor>   </parcela> </Root> ';
    conta_10827200_3008250_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775113</identificador>     <valor>370.92</valor>   </parcela> </Root> ';
    conta_10827200_3008250_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775114</identificador>     <valor>367.2</valor>   </parcela> </Root> ';
    conta_10827200_3008250_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775115</identificador>     <valor>363.63</valor>   </parcela> </Root> ';
    conta_10827200_3008250_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775116</identificador>     <valor>359.98</valor>   </parcela> </Root> ';
    conta_10827200_3008250_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775117</identificador>     <valor>356.37</valor>   </parcela> </Root> ';
    conta_10827200_3008250_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775118</identificador>     <valor>353.14</valor>   </parcela> </Root> ';
    conta_10827200_3008250_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775119</identificador>     <valor>343.19</valor>   </parcela> </Root> ';
    conta_10827200_3008250_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775120</identificador>     <valor>336.59</valor>   </parcela> </Root> ';
    conta_10827200_3008250_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775121</identificador>     <valor>330.68</valor>   </parcela> </Root> ';
    conta_10827200_3008250_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775122</identificador>     <valor>325.06</valor>   </parcela> </Root> ';
    conta_10827200_3008250_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775123</identificador>     <valor>319.35</valor>   </parcela> </Root> ';
    conta_10827200_3008250_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775124</identificador>     <valor>313.75</valor>   </parcela> </Root> ';
    conta_10827200_3008250_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775125</identificador>     <valor>308.42</valor>   </parcela> </Root> ';
    conta_10827200_3008250_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-11-10</dataVencimento>     <identificador>2775126</identificador>     <valor>303</valor>   </parcela> </Root> ';
    conta_10827200_3008250_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-12-10</dataVencimento>     <identificador>2775127</identificador>     <valor>297.85</valor>   </parcela> </Root> ';
    conta_10827200_3008250_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3008250</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>10827200</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-01-10</dataVencimento>     <identificador>2775128</identificador>     <valor>292.62</valor>   </parcela> </Root> ';

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
  ,7894694
  ,3222606
  ,'PAGTO_PAGAR'
  ,'CONSIGNADO'
  ,'INSERT'
  ,SYSDATE
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,conta_7894694_3222606_1
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
  ,7894694
  ,3222606
  ,'PAGTO_PAGAR'
  ,'CONSIGNADO'
  ,'INSERT'
  ,SYSDATE
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,conta_7894694_3222606_2
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
  ,7894694
  ,3222606
  ,'PAGTO_PAGAR'
  ,'CONSIGNADO'
  ,'INSERT'
  ,SYSDATE
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,conta_7894694_3222606_3
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
  ,7894694
  ,3222606
  ,'PAGTO_PAGAR'
  ,'CONSIGNADO'
  ,'INSERT'
  ,SYSDATE
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,conta_7894694_3222606_4
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
  ,7894694
  ,3222606
  ,'PAGTO_PAGAR'
  ,'CONSIGNADO'
  ,'INSERT'
  ,SYSDATE
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,conta_7894694_3222606_5
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
  ,conta_10827200_3008250_10
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
  ,conta_10827200_3008250_11
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
  ,conta_10827200_3008250_12
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
  ,conta_10827200_3008250_13
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
  ,conta_10827200_3008250_14
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
  ,conta_10827200_3008250_15
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
  ,conta_10827200_3008250_16
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
  ,conta_10827200_3008250_17
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
  ,conta_10827200_3008250_18
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
  ,conta_10827200_3008250_19
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
  ,conta_10827200_3008250_20
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
  ,conta_10827200_3008250_21
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
  ,conta_10827200_3008250_22
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
  ,conta_10827200_3008250_23
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
  ,conta_10827200_3008250_24
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
  ,conta_10827200_3008250_25
  );


      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
