-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito
-- Tipo: Parametros

DECLARE
/*
  Autor   : 
  Data    : Março/2020

  Frequencia: Especifico

  Objetivo  : Rotina para popular nova tabela de parametros TBCRED_PARAMETRO_ANALISE, com tipo de produto 3 (Limite Crédito),
*/

  -- Variáveis
  vr_qtcooper NUMBER;
  vr_dscritic VARCHAR2(10000);

  CURSOR cr_crapcop IS
    SELECT   0 incontigen, --Não

           0 incomite, -- Não

           1  inanlautom, -- Sim
           'PoliticaLimiteCreditoPF' nmregmpf,
           'PoliticaLimiteCreditoPJ' nmregmpj,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'TIME_RESP_MOTOR_DESC') qtsstime,                                     
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DEVCHQ_DESC') qtmeschq,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DC_A11_DESC') qtmeschqal11,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_DC_A12_DESC') qtmeschqal12,  
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_EST_DESC') qtmesest,
           GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdcooper => cop.cdcooper,
                                     pr_cdacesso => 'QTD_MES_HIST_EMPRES_DESC') qtmesemp,
           --
           cdcooper,
           Initcap(nmrescop) nmrescop

      FROM crapcop cop
     WHERE cop.flgativo = 1
    -- and cop.cdcooper =1
     ORDER BY cop.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

begin
  FOR rw_crapcop  in cr_crapcop  LOOP
      -- Grava linha para as cooperativas
      BEGIN
        INSERT INTO CECRED.TBCRED_PARAMETRO_ANALISE (
              cdcooper,
              tpproduto,
              incomite,
              incontigen,
              inanlautom,
              nmregmpf,
              nmregmpj,
              qtsstime,
              qtmeschq,
              qtmeschqal11,
              qtmeschqal12,
              qtmesest,
              qtmesemp)        
        VALUES(
             rw_crapcop.cdcooper,  -- cdcooper,
             3,  -- tpproduto, --Limite Crédito
             rw_crapcop.incomite, -- incomite,
             rw_crapcop.incontigen, -- incontigen,
             rw_crapcop.inanlautom,  -- inanlautom,
             rw_crapcop.nmregmpf,  -- nmregmpf,
             rw_crapcop.nmregmpj, -- nmregmpj,
             rw_crapcop.qtsstime,  -- qtsstime,
             rw_crapcop.qtmeschq,  -- qtmeschq,
             NVL(rw_crapcop.qtmeschqal11,0), -- qtmeschqal11,
             NVL(rw_crapcop.qtmeschqal12,0), -- qtmeschqal12,
             rw_crapcop.qtmesest,  -- qtmesest,
             rw_crapcop.qtmesemp  -- qtmesemp
             )  ;     
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não inseriu linha na tab TBCRED_PARAMETRO_ANALISE - ' || SQLERRM;
          DBMS_OUTPUT.PUT_LINE (vr_dscritic);
          EXIT;
      END;
  END LOOP;

END;
/

DECLARE 
BEGIN
  INSERT INTO crapprm (
          NMSISTEM,
          CDCOOPER,
          CDACESSO,
          DSTEXPRM,
          DSVLRPRM)
  VALUES('CRED'
         ,0---indicando para todas
         ,'DTVIGENCIA_NOVO_LIMITE'
         ,'Inicio vigência análise automatica Limite Cred. '
         ,TO_CHAR(TRUNC(SYSDATE),'dd/mm/yyyy'));
         
EXCEPTION
  WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE ('Não inseriu data inicio vigencia na tab CRAPPRM');

END;
/

commit;
