--------------------------------------------------------------------------------------------
-- AUTOR........: Gustavo Guedes de Sene
-- EMPRESA......: GFT
-- DATA.........: 05/02/2018
-- OBJETIVO.....: Cadastrar o programa TAB052 na tabela CECRED.CRAPRDR e configurar 
--                seus respectivos parâmetros na tabela CECRED.CRAPACA com o objetivo
--                de se criar a Interface entre o Frontend (PHP) e Backend (Oracle PL/SQL) 
--                da Aplicação "TAB052 - Parametros para Desconto de Titulos".
--
-- INSTRUÇÕES...: Executar os scripts na ordem em que encontram,
--                uma vez que há dependências entre os registros inseridos.         
--------------------------------------------------------------------------------------------

-- 1.Cadastrando o Programa TAB052 na tabela CECRED.CRAPRDR --
INSERT INTO CECRED.CRAPRDR 
 (NMPROGRA 
  ,DTSOLICI
 )
VALUES
 ('TAB052'
  ,SYSDATE
 );
--

-- 2.Cadastrando os Parâmetros referentes ao Programa TAB052 na tabela CECRED.CRAPACA --

-- 2.1. Parâmetros para Consulta ao Programa
INSERT INTO CECRED.CRAPACA 
 ( 
   NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR
 )         
VALUES
 (
   'TAB052_CONSULTA'
  ,'TELA_TAB052'
  ,'pc_consulta_web'
  ,'pr_tpcobran'
  ,(SELECT NRSEQRDR FROM CECRED.CRAPRDR WHERE NMPROGRA = 'TAB052')
 );
--

-- 2.2 Parâmetros para Alteração do Programa
INSERT INTO CECRED.CRAPACA 
 (
   NMDEACAO
  ,NMPACKAG
  ,NMPROCED
  ,LSTPARAM
  ,NRSEQRDR
 )         
VALUES
 (
   'TAB052_ALTERAR'   
  ,'TELA_TAB052'      
  ,'pc_alterar_tab052'
  ,'pr_tpcobran,pr_vllimite,pr_vlconsul,pr_vlmaxsac,pr_vlminsac,pr_qtremcrt,pr_qttitprt,pr_qtrenova,pr_qtdiavig,pr_qtprzmin,pr_qtprzmax,pr_qtminfil,pr_nrmespsq,pr_pctitemi,pr_pctolera,pr_pcdmulta,pr_vllimite_c,pr_vlconsul_c,pr_vlmaxsac_c,pr_vlminsac_c,pr_qtremcrt_c,pr_qttitprt_c,pr_qtrenova_c,pr_qtdiavig_c,pr_qtprzmin_c,pr_qtprzmax_c,pr_qtminfil_c,pr_nrmespsq_c,pr_pctitemi_c,pr_pctolera_c,pr_pcdmulta_c,pr_cardbtit,pr_cardbtit_c,pr_pcnaopag,pr_qtnaopag,pr_qtprotes,pr_pcnaopag_c,pr_qtnaopag_c,pr_qtprotes_c'
  ,(SELECT NRSEQRDR FROM CECRED.CRAPRDR WHERE NMPROGRA = 'TAB052')
 );
--

-- 3.Atualizando o Programa TAB052 do ambiente Ayllos Caracter para o Ayllos Web --
UPDATE CECRED.CRAPTEL
SET    IDAMBTEL = 2
WHERE  NMDATELA = 'TAB052'; 
--

COMMIT;
-- FIM --
