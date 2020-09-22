REM ANTES DE EXECUTAR AJUSTAR O NLS LANG (NLS_LANG=BRAZILIAN PORTUGUESE_BRAZIL.WE8MSWIN1252)
SPOOL servcore-ng-dml_V002C001R442.log

SET DEFINE OFF;
SET ESCAPE \;
SET ECHO ON;

ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/RR HH24:MI:SSXFF';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';
ALTER SESSION SET NLS_CALENDAR='GREGORIAN';
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RR';
ALTER SESSION SET NLS_DATE_LANGUAGE='BRAZILIAN PORTUGUESE';
ALTER SESSION SET NLS_TIME_FORMAT='HH24:MI:SSXFF';
ALTER SESSION SET NLS_TIME_TZ_FORMAT='HH24:MI:SSXFF TZR';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT='DD/MM/RR HH24:MI:SSXFF TZR';
  
DECLARE

 CLOB_PAGTO CLOB;
   
BEGIN

INSERT INTO TB_SCRIPT_HIST (SCRIPT_FILE_NAME, TS_CREATED, STATUS) VALUES ('servcore-ng-dml_V002C001R442.sql', SYSTIMESTAMP, '*');

--  ATM -  COMPROVANTE DE PAGAMENTO DE TITULO - BANCOOB
DBMS_LOB.CREATETEMPORARY(CLOB_PAGTO, false);


DBMS_LOB.APPEND(CLOB_PAGTO,'#set (' || CHR(36) || 'PAGAMENTO =  ' || CHR(36) || 'JACKSON_UTIL.readMap(' || CHR(36) || 'OUTPUT_TRANSACTION.get("WS_REST_RESULT")))
'||
'#set (' || CHR(36) || 'TAM_NOME = ' || CHR(36) || 'AUDIT_TAPE.transactionTO.financialInstitution.shortName.length())
'||
'#set (' || CHR(36) || 'CHECK_POS = ((48 - ' || CHR(36) ||'TAM_NOME)/2))
'||
'#set (' || CHR(36) || 'CURRENCY = "R$ ")
'||
'##============ COMPROVANTE BANCOOB ==========
'||
'#if ((' || CHR(36) || 'PAGAMENTO.get("pagamento").get("codigoAgenteCompensacao") && ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("codigoAgenteCompensacao")=="756") && ' || CHR(36) || 'PAGAMENTO.get("comprovante").get("tipo").get("codigo")==2)
' || CHR(64) || CHR(64) || 'TEXT' || CHR(64) || '>
Convenio - Banco Cooperativo do Brasil - Bancoob
      ' || CHR(36) || 'TEMPLATE_HELPER.getCurrentDateTime("dd/MM/yyyy") - COMPROVANTE - ' || CHR(36) || 'TEMPLATE_HELPER.getCurrentDateTime("HH:mm:ss")
           COMPROVANTE DE ARRECADACAO
 
               ORIGEM DA OPERACAO
' || CHR(36) || 'STRING_UTIL.padRight(' || CHR(36) || 'PAGAMENTO.get("cooperativaCentral").get("descricao").toString(), 44, " ")
COOP. ' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'PAGAMENTO.get("convenioPagamento").get("codigoAgenciaNoConvenio").toString(), 4, "0") - ' || CHR(36) || 'PAGAMENTO.get("pessoaCC").get("contaCorrente").get("cooperativa").get("nomeAbreviado").toString()
Conta/DV: ' || CHR(36) || 'TEMPLATE_HELPER.formatConta(' || CHR(36) || 'PAGAMENTO.get("pessoaCC").get("contaCorrente").get("codigoConta").toString())          
Cliente: ' || CHR(36) || 'PAGAMENTO.get("pessoaCC").get("razaoSocialOuNome")

' || CHR(36) || 'PAGAMENTO.get("convenioPagamento").get("comentario")
------------------------------------------------
Codigo de barras:      ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").toString().replace("-","").substring(0, 12) ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").toString().replace("-","").substring(13,25)
                       ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").toString().replace("-","").substring(26, 38) ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").toString().replace("-","").substring(39)

Data do Pagamento:....................' || CHR(36) || 'TEMPLATE_HELPER.changeStrDateFormat(' || CHR(36) || 'PAGAMENTO.get("comprovante").get("dataCriacao").toString().substring(0, 10), "yyyy-MM-dd", "dd/MM/yyyy")
 
Valor Recolhido:' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'CURRENCY.concat(' || CHR(36) || 'NUMERO_UTIL.formatarValor(' || CHR(36) || 'PAGAMENTO.get("pagamento").get("valor").toString())), 32, ".")
                                               
-----------------------------------------------

Canal de Recebimento:' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'PAGAMENTO.get("canalRelacionamento").get("descricao").toString().substring(0, 16), 27, ".")

Autenticacao:
' || CHR(36) || 'PAGAMENTO.get("pagamento").get("protocoloComprovante")
 
------------------------------------------------
        OUVIDORIA BANCOOB ' || CHR(36) || 'PAGAMENTO.get("telefoneOuvidoriaBancoob")
               SAC ' || CHR(36) || 'PAGAMENTO.get("telefoneSACBancoob")

' || CHR(64) || CHR(64) || 'TEXT' || CHR(64) || '>
##============ OUTROS BANCOS COMPROVANTE  ==========
'||
'#else');

DBMS_LOB.APPEND(CLOB_PAGTO,'#set (' || CHR(36) || 'CURRENCY = "R$ ") 
' || CHR(64) || CHR(64) || 'TEXT' || CHR(64) || '>
' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'AUDIT_TAPE.transactionTO.financialInstitution.shortName,' || CHR(36) || 'CHECK_POS, " ") AUTOATENDIMENTO

EMISSAO: ' || CHR(36) || 'TEMPLATE_HELPER.getCurrentDateTime("dd-MM-yyyy")                   ' || CHR(36) || 'TEMPLATE_HELPER.getCurrentDateTime("HH:mm:ss")

COOPERATIVA/PA/TERMINAL: ' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'AUDIT_TAPE.transactionTO.financialInstitution.virtualCode.toString(), 4, "0")/' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'AUDIT_TAPE.transactionTO.terminal.agency.code.toString(), 4, "0")/' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'AUDIT_TAPE.transactionTO.terminal.code.toString(), 4, "0")

              COMPROVANTE DE PAGAMENTO

  BANCO: ' || CHR(36) || 'PAGAMENTO.get("pessoaCC").get("contaCorrente").get("banco").get("codigo")
AGENCIA: ' || CHR(36) || 'STRING_UTIL.padLeft(' || CHR(36) || 'PAGAMENTO.get("pessoaCC").get("contaCorrente").get("agencia").get("codigo"), 4, "0")
'||
'#if (' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("NOME_CLIENTE").length() > 26)  CONTA: ' || CHR(36) || 'TEMPLATE_HELPER.formatConta(' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("CONTA_CORRENTE").toString()) - ' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("NOME_CLIENTE").substring(0,26)
'||
'#else
  CONTA: ' || CHR(36) || 'TEMPLATE_HELPER.formatConta(' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("CONTA_CORRENTE").toString()) - ' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("NOME_CLIENTE")
'||
'#end
'||
'##============ COMPROVANTE TITULO = 1 ==========
'||
'||
'||
'#if (' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("CODIGO_COMPROVANTE")==1)
'||
'#if (' || CHR(36) || 'PAGAMENTO.get("pagamento").get("nomeAgenteCompensacao"))
'||
'#if (' || CHR(36) || 'PAGAMENTO.get("pagamento").get("contaAgenteCompensacao"))
BANCO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("contaAgenteCompensacao") - ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("nomeAgenteCompensacao")
'||
'#else
BANCO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("nomeAgenteCompensacao")
'||
'#end
'||
'#else
BANCO:
'||
'#end

'||
'#if (' || CHR(36) || 'PAGAMENTO.get("pagamento").get("comentario"))
BENEFICIARIO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("comentario")
'||
'#else
BENEFICIARIO:
'||
'#end
'||
'#if (' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificadorReceitaFederalCredor"))
CPF/CNPJ BENEFICIARIO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificadorReceitaFederalCredor")
'||
'#else
CPF/CNPJ BENEFICIARIO:
'||
'#end

'||
'#if (' || CHR(36) || 'PAGAMENTO.get("tituloCobranca").get("pagador").get("razaoSocialOuNome"))
PAGADOR: ' || CHR(36) || 'PAGAMENTO.get("tituloCobranca").get("pagador").get("razaoSocialOuNome")
'||
'#else
PAGADOR:
'||
'#end
'||
'#if (' || CHR(36) || 'PAGAMENTO.get("tituloCobranca").get("pagador").get("identificadorReceitaFederal"))
CPF/CNPJ PAGADOR: ' || CHR(36) || 'PAGAMENTO.get("tituloCobranca").get("pagador").get("identificadorReceitaFederal")
'||
'#else
CPF/CNPJ PAGADOR:
'||
'#end

'||
'#if(' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataVencimento"))
VENCIMENTO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataVencimento").substring(8,10)/' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataVencimento").substring(5,7)/' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataVencimento").substring(0,4)
'||
'#else
VENCIMENTO:
'||
'#end

VALOR TITULO: ' || CHR(36) || 'NUMERO_UTIL.formatarValor(' || CHR(36) || 'PAGAMENTO.get("tituloCobranca").get("valorDocumento").toString())
ENCARGOS: ' || CHR(36) || 'NUMERO_UTIL.formatarValor(' || CHR(36) || 'PAGAMENTO.get("pagamento").get("jurosEMulta").toString())
DESCONTOS: ' || CHR(36) || 'NUMERO_UTIL.formatarValor(' || CHR(36) || 'PAGAMENTO.get("pagamento").get("desconto").toString())
'||
'#else
'||
'##============ COMPROVANTE CONTA CONSUMO = 2 ==========
'||
'#if (' || CHR(36) || 'PAGAMENTO.get("convenioPagamento").get("comentario"))
CONVENIO: ' || CHR(36) || 'PAGAMENTO.get("convenioPagamento").get("comentario")
'||
'#else
CONVENIO:
'||
'#end
'||
'#end

DATA DO PAGAMENTO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataEfetivacao").substring(8,10)/' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataEfetivacao").substring(5,7)/' || CHR(36) || 'PAGAMENTO.get("pagamento").get("dataEfetivacao").substring(0,4)

VALOR DO PAGAMENTO: ' || CHR(36) || 'NUMERO_UTIL.formatarValor(' || CHR(36) || 'PAGAMENTO.get("pagamento").get("valor").toString())

'||
'#if (' || CHR(36) || 'AUDIT_TAPE.transactionTO.data.get("CODIGO_COMPROVANTE")==1)
LINHA DIGITAVEL: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").substring(0,24)
                ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").substring(24)
'||
'#else
LINHA DIGITAVEL: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").substring(0,27)
                ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("identificador").substring(27)
'||
'#end

   PROTOCOLO: ' || CHR(36) || 'PAGAMENTO.get("pagamento").get("protocoloComprovante")

    SAC - Servico de Atendimento ao Cooperado
                  ' || CHR(36) || 'PAGAMENTO.get("telefoneSAC")
    Atendimento todos os dias das ' || CHR(36) || 'PAGAMENTO.get("horarioInicialSAC").substring(0,2)h as ' || CHR(36) || 'PAGAMENTO.get("horarioFinalSAC").substring(0,2)h

                    OUVIDORIA
                  ' || CHR(36) || 'PAGAMENTO.get("telefoneOuvidoria")
    Atendimento nos dias uteis das ' || CHR(36) || 'PAGAMENTO.get("horarioInicialOuvidoria").substring(0,2)h as ' || CHR(36) || 'PAGAMENTO.get("horarioFinalOuvidoria").substring(0,2)h

               ** FIM DA IMPRESSÃO **
' || CHR(64) || CHR(64) || 'TEXT' || CHR(64) || '>
'||
'#end');


-- 557. 5 COMPROVANTE DE PAGAMENTO 
DELETE TB_TEMPLATE_MODEL WHERE ID_IF=0 AND ID_CHANNEL=0 AND ID_TRANSACTION=557 AND SEQ_FLOW=5;
INSERT INTO TB_TEMPLATE_MODEL (ID_IF, ID_CHANNEL, ID_TRANSACTION, ID_TEMPLATE_TYPE, DE_TEMPLATE_MODEL, SEQ_FLOW) VALUES ('0', '0', '557', '2',CLOB_PAGTO,'5');


END;
/
COMMIT;

SET ESCAPE OFF;
SPOOL OFF;