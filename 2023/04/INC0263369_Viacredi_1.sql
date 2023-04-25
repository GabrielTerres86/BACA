DECLARE

    vr_dtAcao date := sysdate;
    conta_6419119_2040482_1 CLOB;
    conta_6419119_2040482_2 CLOB;
    conta_7894694_3222606_3 CLOB;
    conta_7894694_3222606_4 CLOB;
    conta_7894694_3222606_5 CLOB;
    conta_7894694_3222606_6 CLOB;
    conta_7894694_3222606_7 CLOB;
    conta_7894694_3222606_8 CLOB;
    conta_7894694_3222606_9 CLOB;
    conta_7894694_3222606_10 CLOB;
    conta_7894694_3222606_11 CLOB;
    conta_7894694_3222606_12 CLOB;
    conta_7894694_3222606_13 CLOB;
    conta_7894694_3222606_14 CLOB;
    conta_7894694_3222606_15 CLOB;
    conta_7894694_3222606_16 CLOB;
    conta_7894694_3222606_17 CLOB;
    conta_7894694_3222606_18 CLOB;
    conta_7894694_3222606_19 CLOB;
    conta_7894694_3222606_20 CLOB;
    conta_7894694_3222606_21 CLOB;
    conta_7894694_3222606_22 CLOB;
    conta_7894694_3222606_23 CLOB;
    conta_7894694_3222606_24 CLOB;
    conta_7894694_3222606_25 CLOB;

BEGIN
  
    conta_6419119_2040482_1 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>2040482</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>6419119</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-04-10</dataVencimento>     <identificador>2775080</identificador>     <valor>200.69</valor>   </parcela> </Root> ';
    conta_6419119_2040482_2 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>2040482</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>6419119</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-05-10</dataVencimento>     <identificador>2775081</identificador>     <valor>215.85</valor>   </parcela> </Root> ';
    conta_7894694_3222606_3 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-10-10</dataVencimento>     <identificador>2775082</identificador>     <valor>138.08</valor>   </parcela> </Root> ';
    conta_7894694_3222606_4 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-11-10</dataVencimento>     <identificador>2775083</identificador>     <valor>172.67</valor>   </parcela> </Root> ';
    conta_7894694_3222606_5 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2022-12-10</dataVencimento>     <identificador>2775084</identificador>     <valor>171</valor>   </parcela> </Root> ';
    conta_7894694_3222606_6 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-01-10</dataVencimento>     <identificador>2775085</identificador>     <valor>169.28</valor>   </parcela> </Root> ';
    conta_7894694_3222606_7 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-02-10</dataVencimento>     <identificador>2775086</identificador>     <valor>167.58</valor>   </parcela> </Root> ';
    conta_7894694_3222606_8 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-03-10</dataVencimento>     <identificador>2775087</identificador>     <valor>166.06</valor>   </parcela> </Root> ';
    conta_7894694_3222606_9 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-04-10</dataVencimento>     <identificador>2775088</identificador>     <valor>161.38</valor>   </parcela> </Root> ';
    conta_7894694_3222606_10 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-05-10</dataVencimento>     <identificador>2775089</identificador>     <valor>158.27</valor>   </parcela> </Root> ';
    conta_7894694_3222606_11 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-06-10</dataVencimento>     <identificador>2775090</identificador>     <valor>155.5</valor>   </parcela> </Root> ';
    conta_7894694_3222606_12 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-07-10</dataVencimento>     <identificador>2775091</identificador>     <valor>152.85</valor>   </parcela> </Root> ';
    conta_7894694_3222606_13 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-08-10</dataVencimento>     <identificador>2775092</identificador>     <valor>150.17</valor>   </parcela> </Root> ';
    conta_7894694_3222606_14 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-09-10</dataVencimento>     <identificador>2775093</identificador>     <valor>147.53</valor>   </parcela> </Root> ';
    conta_7894694_3222606_15 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-10-10</dataVencimento>     <identificador>2775094</identificador>     <valor>145.03</valor>   </parcela> </Root> ';
    conta_7894694_3222606_16 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-11-10</dataVencimento>     <identificador>2775095</identificador>     <valor>142.48</valor>   </parcela> </Root> ';
    conta_7894694_3222606_17 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2023-12-10</dataVencimento>     <identificador>2775096</identificador>     <valor>140.06</valor>   </parcela> </Root> ';
    conta_7894694_3222606_18 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-01-10</dataVencimento>     <identificador>2775097</identificador>     <valor>137.6</valor>   </parcela> </Root> ';
    conta_7894694_3222606_19 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-02-10</dataVencimento>     <identificador>2775098</identificador>     <valor>135.18</valor>   </parcela> </Root> ';
    conta_7894694_3222606_20 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-03-10</dataVencimento>     <identificador>2775099</identificador>     <valor>132.96</valor>   </parcela> </Root> ';
    conta_7894694_3222606_21 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-04-10</dataVencimento>     <identificador>2775100</identificador>     <valor>130.63</valor>   </parcela> </Root> ';
    conta_7894694_3222606_22 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-05-10</dataVencimento>     <identificador>2775101</identificador>     <valor>128.41</valor>   </parcela> </Root> ';
    conta_7894694_3222606_23 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-06-10</dataVencimento>     <identificador>2775102</identificador>     <valor>126.15</valor>   </parcela> </Root> ';
    conta_7894694_3222606_24 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-07-10</dataVencimento>     <identificador>2775103</identificador>     <valor>124.01</valor>   </parcela> </Root> ';
    conta_7894694_3222606_25 := '<?xml version= 1 ?> <Root>   <convenioCredito><cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3222606</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente><contaCorrente>         <codigoContaSemDigito>7894694</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>'||  to_char(vr_dtAcao, 'yyyy-mm-dd') || 'T08:00:00'  ||'</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2023-04-07T08:00:00</dataEfetivacao><dataVencimento>2024-08-10</dataVencimento>     <identificador>2775104</identificador>     <valor>121.83</valor>   </parcela> </Root> ';

  
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
      ,6419119
      ,2040482
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_6419119_2040482_1
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
      ,6419119
      ,2040482
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_6419119_2040482_2
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
      ,conta_7894694_3222606_6
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
      ,conta_7894694_3222606_7
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
      ,conta_7894694_3222606_8
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
      ,conta_7894694_3222606_9
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
      ,conta_7894694_3222606_10
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
      ,conta_7894694_3222606_11
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
      ,conta_7894694_3222606_12
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
      ,conta_7894694_3222606_13
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
      ,conta_7894694_3222606_14
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
      ,conta_7894694_3222606_15
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
      ,conta_7894694_3222606_16
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
      ,conta_7894694_3222606_17
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
      ,conta_7894694_3222606_18
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
      ,conta_7894694_3222606_19
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
      ,conta_7894694_3222606_20
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
      ,conta_7894694_3222606_21
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
      ,conta_7894694_3222606_22
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
      ,conta_7894694_3222606_23
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
      ,conta_7894694_3222606_24
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
      ,conta_7894694_3222606_25
      );
      
 COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
