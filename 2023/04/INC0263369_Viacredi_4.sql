DECLARE

    vr_dtAcao date := sysdate;
    conta_11623160_3060112_1 CLOB;
    conta_11623160_3060112_2 CLOB;
    conta_11623160_3060112_3 CLOB;
    conta_11623160_3060112_4 CLOB;
    conta_11623160_3060112_5 CLOB;
    conta_11623160_3060112_6 CLOB;
    conta_11623160_3060112_7 CLOB;
    conta_11623160_3060112_8 CLOB;
    conta_11623160_3060112_9 CLOB;
    conta_11623160_3060112_10 CLOB;
    conta_11623160_3060112_11 CLOB;
    conta_11984961_3301998_12 CLOB;
    conta_11984961_3301998_13 CLOB;
    conta_11984961_3301998_14 CLOB;
    conta_11984961_3301998_15 CLOB;
    conta_11984961_3301998_16 CLOB;
    conta_11984961_3301998_17 CLOB;
    conta_11984961_3301998_18 CLOB;
    conta_11984961_3301998_19 CLOB;
    conta_11984961_3301998_20 CLOB;
    conta_11984961_3301998_21 CLOB;
    conta_11984961_3301998_22 CLOB;
    conta_11984961_3301998_23 CLOB;
    conta_11984961_3301998_24 CLOB;
    conta_11984961_3301998_25 CLOB;
    conta_11984961_3301998_26 CLOB;


BEGIN
  
    conta_11623160_3060112_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775154</identificador>     <valor>355.38</valor>   </parcela> </Root> ';
    conta_11623160_3060112_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775155</identificador>     <valor>349.34</valor>   </parcela> </Root> ';
    conta_11623160_3060112_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-11-10</dataVencimento>     <identificador>2775156</identificador>     <valor>343.21</valor>   </parcela> </Root> ';
    conta_11623160_3060112_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-12-10</dataVencimento>     <identificador>2775157</identificador>     <valor>337.38</valor>   </parcela> </Root> ';
    conta_11623160_3060112_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-01-10</dataVencimento>     <identificador>2775158</identificador>     <valor>331.45</valor>   </parcela> </Root> ';
    conta_11623160_3060112_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-02-10</dataVencimento>     <identificador>2775159</identificador>     <valor>325.64</valor>   </parcela> </Root> ';
    conta_11623160_3060112_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-03-10</dataVencimento>     <identificador>2775160</identificador>     <valor>320.29</valor>   </parcela> </Root> ';
    conta_11623160_3060112_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-04-10</dataVencimento>     <identificador>2775161</identificador>     <valor>314.67</valor>   </parcela> </Root> ';
    conta_11623160_3060112_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-05-10</dataVencimento>     <identificador>2775162</identificador>     <valor>309.32</valor>   </parcela> </Root> ';
    conta_11623160_3060112_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-06-10</dataVencimento>     <identificador>2775163</identificador>     <valor>303.89</valor>   </parcela> </Root> ';
    conta_11623160_3060112_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3060112</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11623160</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-07-10</dataVencimento>     <identificador>2775164</identificador>     <valor>298.73</valor>   </parcela> </Root> ';
    conta_11984961_3301998_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775165</identificador>     <valor>36.32</valor>   </parcela> </Root> ';
    conta_11984961_3301998_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775166</identificador>     <valor>118.25</valor>   </parcela> </Root> ';
    conta_11984961_3301998_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775167</identificador>     <valor>117.1</valor>   </parcela> </Root> ';
    conta_11984961_3301998_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775168</identificador>     <valor>115.93</valor>   </parcela> </Root> ';
    conta_11984961_3301998_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775169</identificador>     <valor>114.76</valor>   </parcela> </Root> ';
    conta_11984961_3301998_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775170</identificador>     <valor>113.72</valor>   </parcela> </Root> ';
    conta_11984961_3301998_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775171</identificador>     <valor>110.52</valor>   </parcela> </Root> ';
    conta_11984961_3301998_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775172</identificador>     <valor>108.57</valor>   </parcela> </Root> ';
    conta_11984961_3301998_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775173</identificador>     <valor>106.83</valor>   </parcela> </Root> ';
    conta_11984961_3301998_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775174</identificador>     <valor>105.16</valor>   </parcela> </Root> ';
    conta_11984961_3301998_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775175</identificador>     <valor>103.47</valor>   </parcela> </Root> ';
    conta_11984961_3301998_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775176</identificador>     <valor>101.81</valor>   </parcela> </Root> ';
    conta_11984961_3301998_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775177</identificador>     <valor>100.22</valor>   </parcela> </Root> ';
    conta_11984961_3301998_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-11-10</dataVencimento>     <identificador>2775178</identificador>     <valor>98.61</valor>   </parcela> </Root> ';
    conta_11984961_3301998_26 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3301998</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>11984961</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-12-10</dataVencimento>     <identificador>2775179</identificador>     <valor>97.08</valor>   </parcela> </Root> ';

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
      ,conta_11623160_3060112_1
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
      ,conta_11623160_3060112_2
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
      ,conta_11623160_3060112_3
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
      ,conta_11623160_3060112_4
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
      ,conta_11623160_3060112_5
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
      ,conta_11623160_3060112_6
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
      ,conta_11623160_3060112_7
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
      ,conta_11623160_3060112_8
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
      ,conta_11623160_3060112_9
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_12
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_13
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_14
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_15
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_16
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_17
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_18
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_19
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_20
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_21
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_22
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_23
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_24
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_25
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
      ,11984961
      ,3301998
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_11984961_3301998_26
      );

      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
