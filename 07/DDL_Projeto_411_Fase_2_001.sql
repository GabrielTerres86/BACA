-- Projeto 411 Fase 2 
-- Belli - Envolti - 04/04/2019
DECLARE
 VR_NRSEQRDR CRAPRDR.NRSEQRDR%TYPE;
BEGIN
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1495, '1495 - Nao foi possivel efetuar o procedimento. Tente novamente ou contacte o atendimento.', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1465, '1465 - Faixa com valor invalido.', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1466, '1466 - Informacoes passadas iguais as informacoes da base de dadaos.', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1467, '1467 - Saldo zerado ou negativo.', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1468, '1468 - Recebido arquivo de concilia��o com data antiga e ser� processado apenas o arquivo com a data parametrizada', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1469, '1469 - Concilia��o n�o confere com o Layout definido, pois existe menos de 27 caracteres em linha detalhe! O mesmo n�o ser� processado', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1470, '1470 - Valor da Aplic. B3 ("VR_VLAPLB3") diferente do valor da aplica��o no Aimaro ("VR_APLAIMARO") e com tolerancia de ("VR_PRTOLERANCIA")', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1472, '1472 - Tipo de Posi��o em Cust�dia diferente de (1)',      4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1473, '1473 - Aplica��o n�o encontrada para Concilia��o',         4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1474, '1474 - Aplica��o com quantidade de cotas Aimaro igual a zero e Quantidade B3 = ("QT_COTA_B3")', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1475, '1475 - Aplica��o (RDA ou RAC) n�o encontrada para Concilia��o',4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1476, '1476 - Data de Emiss�o diferente da Data Emiss�o Aplica��o',4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1477, '1477 - Data de Vencimento diferente da Data Vencimento Aplica��o',4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1478, '1478 - Quantidade de cotas Aimaro ("QT_COTA_AIMARO") diferente da Quantidade de Cotas B3 ("QT_COTA_B3")', 4, 0);
INSERT INTO CRAPCRI (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1479, '1479 - Valor Nominal diferente do Registrado da Aplica��o, com tolerancia',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1480, '1480 - Nenhuma Concilia��o ser� efetuada pois a op��o est� Desativada ou j� foi efetuada no dia',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1481, '1481 - Linha Original retornada n�o encontrada no arquivo de envio',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1482, '1482 - Conteudo da Linha Original retornado n�o confere com a linha Original enviada',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1483, '1483 - Arquivo persiste na pasta ENVIA',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1484, '1484 - Arquivo enviado, por�m nao foi possivel copiar arquivo para pasta de Backup',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1485, '1485 - Nenhum arquivo enviado',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1486, '1486 - Nenhum arquivo enviado',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1487, '1487 - Arquivo recebido, por�m nao foi possivel copiar arquivo para pasta de Backup',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1488, '1488 - Opera��o n�o realizada! Execu��o liberada somente',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1489, '1489 - Opera��o n�o realizada! Processo em Execu��o ou Sistema Aimaro n�o liberado!',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1490, '1490 - Opera��o n�o realizada! Execu��o s� ser� efetuada de 2a a 6a feira.',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1491, '1491 - Processo de retorno de arquivo da B3 em atraso.',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1492, '1492 - N�o ser� poss�vel enviar! A concilia��o do dia anterior ainda n�o foi efetuada!',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1493, '1493 - Resgate com cotas zerada!',4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1494, '1494 - N�o foi poss�vel carregar o extrato!',4, 0);                   
       -- 1495                         

insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'CUSTO_FIXO_CCL_DSP_FRN',
 'Custo fixo do valor devido ao fornecedor referente a transferencia de aplica��o da cust�dia - Fornecedor(FRN) => B3','250,00');
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'PERC_VLR_REG_CCL_DSP_FRN',
 'Percentual sobre o valor registrado para calculo do valor devido ao fornecedor referente as aplica��es de cust�dia - Fornecedor(FRN) => B3','0000,005000');
-- RF08 ARQUIVO HTML 
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'QTD_REG_CCL_FRN_APL',
 'Quantidade m�xima de registros por arquivo a disponibilizar em HTML referentes a concilia��o entre o fornecedor e a cooperativa central, os registros s�o toda a movimenta��o de aplica��es, sendo o fornecedor o B3 que faz a interface com o banco central.'  
,'000002000');
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'LIMERRO_ENV_REG_CTD_B3',
 'Limite de erros no processo de envio de arquivo ao fornecedor => B3',10);
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'LIMERRO_GERA_ARQ_ENV_B3',
 'Limite de erros no processo de gerar arquivos para envio ao fornecedor => B3',10);
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'LIMERRO_PROC_RET_ARQ_B3',
 'Limite de erros no processo de retorno de arquivo do fornecedor => B3',10);
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'LIMERRO_PROC_CONCILIA_B3',
 'Limite de erros no processo de concilia��o com o fornecedor => B3',10);
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'HOR_TOL_CTD_B3',
 'Busca tolerancia de tempo do retorno de arquivo do fornecedor => B3','02:30'); 
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'DAT_ENVIA_1_CUSTODIA_B3',
 'Data do processo envio de arquivo ao fornecedor => B3','01/06/2019'); 
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO , DSTEXPRM , DSVLRPRM ) values (  'CRED',0,'CTR_CLC_AVISO_EXE_B3',
 'Registro de execu��o e Horario de inicio do alerta de necessidade de e-mail do atraso da concilia��o','00;01;1000;06:00');
 
----

insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,           0.00,     500000.00, 0.0010833,      0.00, SYSDATE, '1', 't0031383', SYSDATE);
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,      500000.01,    1000000.00, 0.0010292,      0.27, SYSDATE, '1', 't0031383', SYSDATE);
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,     1000000.01,    5000000.00, 0.0009777,     0.79, SYSDATE, '1', 't0031383', SYSDATE); 
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,     5000000.01,   10000000.00, 0.0009288,     3.23, SYSDATE, '1', 't0031383', SYSDATE); 
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,    10000000.01,  100000000.00, 0.0006502,    31.09, SYSDATE, '1', 't0031383', SYSDATE); 
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,   100000000.01, 1000000000.00, 0.0004551,   226.15, SYSDATE, '1', 't0031383', SYSDATE); 
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL,  1000000000.01, 10000000000.00, 0.0003186,  1591.52, SYSDATE, '1', 't0031383', SYSDATE); 
insert into TBCAPT_CUSTODIA_FRN_INVESTIDOR (idfrninv, vlfaixade, vlfaixaate, petaxa_mensal, vladicional, dtinclusao, flgativo ,dsusuario, dhatual)  
 VALUES ( NULL, 10000000000.01,           0.00, 0.0002230, 11149.10, SYSDATE, '1', 't0031383', SYSDATE); 

----
-- Tela CUSAPL
SELECT T2.NRSEQRDR INTO VR_NRSEQRDR FROM CRAPRDR T2 WHERE T2.NMPROGRA = 'TELA_CUSAPL';

insert into CRAPACA (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (NULL, 'BUSCA_HIST_APLICACAO', 'TELA_CUSAPL', 'pc_historico_aplicacao', 'pr_idaplicacao,pr_nriniseq,pr_nrregist', VR_NRSEQRDR);

update CRAPACA SET lstparam =  'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3,pr_nriniseq,pr_nrregist'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_ARQUIVOS' AND  upper(NMPACKAG)  = 'TELA_CUSAPL';
-- Tela CUSAPL op��o O adiciona dois parametros na lista de parametros, necess�rio para a pagina��o
update CRAPACA set lstparam = 'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3,pr_nrregist,pr_nriniseq'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_OPERAC'   AND  upper(NMPACKAG)  = 'TELA_CUSAPL';   
update CRAPACA set lstparam = 'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3,pr_inacao,pr_nrregist,pr_nriniseq, pr_idarquivo'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_CONT_ARQ' AND  upper(NMPACKAG)  = 'TELA_CUSAPL';

INSERT INTO CRAPRDR T2 VALUES ( NULL, 'APLI0007', SYSDATE );   
SELECT T2.NRSEQRDR INTO VR_NRSEQRDR FROM CRAPRDR T2 WHERE T2.NMPROGRA = 'APLI0007';

INSERT INTO  CRAPACA T ( T.NRSEQACA, T.NMDEACAO, T.NMPACKAG, T.NMPROCED, T.LSTPARAM, T.NRSEQRDR ) VALUES (
   NULL, 'CUSAPL_APLI0007_TRT_CST_FRN_APL', 'APLI0007', 'pc_trt_cst_frn_aplica' ,'pr_cdmodulo,pr_cdcooper,pr_nrdconta,pr_dtde,pr_dtate,pr_tpproces', VR_NRSEQRDR );  
INSERT INTO  CRAPACA T ( T.NRSEQACA, T.NMDEACAO, T.NMPACKAG, T.NMPROCED, T.LSTPARAM, T.NRSEQRDR ) VALUES (
    NULL, 'CUSAPL_APLI0007_LIS_FRN_TAB_INV', 'APLI0007', 'pc_concil_tab_investidor' ,'pr_cdmodulo,pr_cdcooper', VR_NRSEQRDR );
INSERT INTO  CRAPACA T ( T.NRSEQACA, T.NMDEACAO, T.NMPACKAG, T.NMPROCED, T.LSTPARAM, T.NRSEQRDR ) VALUES (
    NULL, 'CUSAPL_APLI0007_ATZ_FRN_TAB_INV', 'APLI0007', 'pc_atz_faixa_tab_investidor',NULL, VR_NRSEQRDR );
   
COMMIT;

EXCEPTION   
  WHEN OTHERS THEN
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'PJ411_F2_P2', action_name => 'Carga Parametros');
    CECRED.pc_internal_exception (pr_cdcooper => 0); 
END;
/
