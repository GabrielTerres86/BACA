DECLARE
  -- Arrays a serem usados com o cursor.
  TYPE typ_lancamentos_a_portar IS RECORD 
  (
    nrdconta   tbcc_operacoes_diarias.nrdconta%TYPE,
    qtd_aa_ano tbcc_operacoes_diarias.nrsequen%TYPE,
    cdoperacao tbcc_operacoes_diarias.cdoperacao%TYPE,
    cdcooper   tbcc_operacoes_diarias.cdcooper%TYPE,
    dtmvtolt   craplcm.dtmvtolt%TYPE,
    nrsequen   tbcc_operacoes_diarias.nrsequen%TYPE,
    dtoperacao tbcc_operacoes_diarias.dtoperacao%TYPE,
    qtddif     tbcc_operacoes_diarias.nrsequen%TYPE
  );
  
  TYPE typ_tab_lancamentos_a_portar IS TABLE OF typ_lancamentos_a_portar INDEX BY PLS_INTEGER;
  
  vr_tab_lancamentos_a_portar typ_tab_lancamentos_a_portar;
  vr_tab_insert typ_tab_lancamentos_a_portar;
  vr_tab_update typ_tab_lancamentos_a_portar;
  
  vr_idx_insert PLS_INTEGER NOT NULL := 0;
  vr_idx_update PLS_INTEGER NOT NULL := 0;
  --
  
  -- Limite de registros pro bulk collect.
  vr_lim_reg NUMBER(5) NOT NULL := 0;
  
  -- Tratamento de excessões.
  BULK_DML_EXCEPTION EXCEPTION;
  vr_exc_saida EXCEPTION;
  
  PRAGMA EXCEPTION_INIT(BULK_DML_EXCEPTION, -24381);
  
  vr_dscritic VARCHAR2(5000) := ' ';
  --
  
  CURSOR cr_lancamentos_a_portar (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT AUTOATENDIMENTO_PIX.NRDCONTA AS NRDCONTA
          ,NVL(SUM(AUTOATENDIMENTO_PIX.QTD), 0) AS qtd_aa_ano
          ,AUTOATENDIMENTO_PIX.OPERACAO AS cdoperacao
          ,AUTOATENDIMENTO_PIX.CDCOOPER AS CDCOOPER
          ,AUTOATENDIMENTO_PIX.DTMVTOLT AS DTMVTOLT
          ,OPERACOESDIARIAS.NRSEQUEN AS NRSEQUEN
          ,OPERACOESDIARIAS.DTOPERACAO AS DTOPERACAO
          , CASE 
              WHEN AUTOATENDIMENTO_PIX.OPERACAO = 25 THEN
                (NVL(SUM(AUTOATENDIMENTO_PIX.QTD), 0) * (-1) - NVL(OPERACOESDIARIAS.NRSEQUEN, 0))
              ELSE
                (NVL(SUM(AUTOATENDIMENTO_PIX.QTD), 0) - NVL(OPERACOESDIARIAS.NRSEQUEN, 0))
            END AS QTDDIF
      FROM (SELECT LCM.NRDCONTA
                  ,LCM.CDCOOPER
                  ,CASE
                     WHEN LCM.CDHISTOR IN (3318, 3320, 3371, 3373, 3450, 3671, 3677, 3675, 3396, 3397, 3437, 3438, 3468) THEN
                      24
                     WHEN LCM.CDHISTOR IN (3319, 3321, 3322, 3323, 3377, 3375, 3379, 3380, 3451, 3452, 3453, 3673, 3681,
                                           3684, 3683, 3679, 3435, 3436, 3469, 3470) THEN
                      25
                     WHEN LCM.CDHISTOR = 508 THEN
                      18
                     WHEN LCM.CDHISTOR = 856 THEN
                      19
                   END OPERACAO
                  ,COUNT(LCM.NRDCONTA) QTD 
                  ,LCM.DTMVTOLT
              FROM CRAPLCM LCM
             WHERE LCM.CDHISTOR IN (3318, 3320, 3371, 3373, 3450, 3671, 3677, 3675, 3396, 3397,
                                    3437, 3438, 3468, 3319, 3321, 3322, 3323, 3377, 3375, 3379,
                                    3380, 3451, 3452, 3453, 3673, 3681, 3684, 3683, 3679, 3435,
                                    3436, 3469, 3470, 508, 856)
               AND LCM.DTMVTOLT IN ('17/12/2021', '20/12/2021')
               AND LCM.CDCOOPER = pr_cdcooper
             GROUP BY LCM.NRDCONTA
                     ,LCM.CDHISTOR
                     ,LCM.CDCOOPER
                     ,LCM.DTMVTOLT) AUTOATENDIMENTO_PIX
          LEFT JOIN
           (SELECT SUM(NVL(APURACAO_AUTOATENDIMENTO.NRSEQUEN, 0)) NRSEQUEN
                  ,APURACAO_AUTOATENDIMENTO.DTOPERACAO
                  ,APURACAO_AUTOATENDIMENTO.CDOPERACAO
                  ,APURACAO_AUTOATENDIMENTO.NRDCONTA
                  ,APURACAO_AUTOATENDIMENTO.CDCOOPER
              FROM TBCC_OPERACOES_DIARIAS APURACAO_AUTOATENDIMENTO
             WHERE APURACAO_AUTOATENDIMENTO.CDCOOPER = pr_cdcooper
               AND APURACAO_AUTOATENDIMENTO.DTOPERACAO IN ('17/12/2021', '20/12/2021')
               AND APURACAO_AUTOATENDIMENTO.CDOPERACAO IN (18, 19, 24, 25)
             GROUP BY APURACAO_AUTOATENDIMENTO.NRDCONTA
                     ,APURACAO_AUTOATENDIMENTO.DTOPERACAO
                     ,APURACAO_AUTOATENDIMENTO.CDOPERACAO
                     ,APURACAO_AUTOATENDIMENTO.NRDCONTA
                     ,APURACAO_AUTOATENDIMENTO.CDCOOPER) OPERACOESDIARIAS
        ON OPERACOESDIARIAS.DTOPERACAO = AUTOATENDIMENTO_PIX.DTMVTOLT
       AND OPERACOESDIARIAS.NRDCONTA = AUTOATENDIMENTO_PIX.NRDCONTA
       AND OPERACOESDIARIAS.CDCOOPER = AUTOATENDIMENTO_PIX.CDCOOPER
       AND OPERACOESDIARIAS.CDOPERACAO = AUTOATENDIMENTO_PIX.OPERACAO
     WHERE AUTOATENDIMENTO_PIX.CDCOOPER = pr_cdcooper 
    HAVING NVL(SUM(AUTOATENDIMENTO_PIX.QTD), 0) <> CASE
                                                     WHEN AUTOATENDIMENTO_PIX.OPERACAO = 25 THEN
                                                      NVL(OPERACOESDIARIAS.NRSEQUEN, 0) * (-1)
                                                     ELSE
                                                      NVL(OPERACOESDIARIAS.NRSEQUEN, 0)
                                                   END
     GROUP BY AUTOATENDIMENTO_PIX.NRDCONTA
             ,AUTOATENDIMENTO_PIX.DTMVTOLT
             ,OPERACOESDIARIAS.NRSEQUEN
             ,OPERACOESDIARIAS.DTOPERACAO
             ,AUTOATENDIMENTO_PIX.CDCOOPER
             ,AUTOATENDIMENTO_PIX.OPERACAO
     ORDER BY AUTOATENDIMENTO_PIX.NRDCONTA
             ,AUTOATENDIMENTO_PIX.CDCOOPER
             ,AUTOATENDIMENTO_PIX.DTMVTOLT ASC;
BEGIN
  FOR rw IN (SELECT cop.cdcooper
             FROM crapcop cop
             WHERE cop.flgativo = 1) 
  LOOP
    IF rw.cdcooper = 1 THEN
      vr_lim_reg := 50000;
    ELSE
      vr_lim_reg := 10000;
    END IF;
    
    OPEN cr_lancamentos_a_portar(pr_cdcooper => rw.cdcooper);
    LOOP
      FETCH cr_lancamentos_a_portar BULK COLLECT INTO vr_tab_lancamentos_a_portar LIMIT vr_lim_reg;
      EXIT WHEN vr_tab_lancamentos_a_portar.COUNT = 0;
      
      -- Varrer os resultados para determinar quais são as operações de insert e update.
      FOR idx IN 1 .. vr_tab_lancamentos_a_portar.COUNT LOOP
        IF
          vr_tab_lancamentos_a_portar(idx).nrsequen IS NULL
          AND vr_tab_lancamentos_a_portar(idx).dtoperacao IS NULL
        THEN
          vr_idx_insert := vr_idx_insert + 1;
          vr_tab_insert(vr_idx_insert).nrdconta   := vr_tab_lancamentos_a_portar(idx).nrdconta;
          vr_tab_insert(vr_idx_insert).qtd_aa_ano := vr_tab_lancamentos_a_portar(idx).qtd_aa_ano;
          vr_tab_insert(vr_idx_insert).cdoperacao := vr_tab_lancamentos_a_portar(idx).cdoperacao;
          vr_tab_insert(vr_idx_insert).cdcooper   := vr_tab_lancamentos_a_portar(idx).cdcooper;
          vr_tab_insert(vr_idx_insert).dtmvtolt   := vr_tab_lancamentos_a_portar(idx).dtmvtolt;
          vr_tab_insert(vr_idx_insert).nrsequen   := vr_tab_lancamentos_a_portar(idx).nrsequen;
          vr_tab_insert(vr_idx_insert).dtoperacao := vr_tab_lancamentos_a_portar(idx).dtoperacao;
          vr_tab_insert(vr_idx_insert).qtddif     := vr_tab_lancamentos_a_portar(idx).qtddif;
        ELSE
          vr_idx_update := vr_idx_update + 1;
          vr_tab_update(vr_idx_update).nrdconta   := vr_tab_lancamentos_a_portar(idx).nrdconta;
          vr_tab_update(vr_idx_update).qtd_aa_ano := vr_tab_lancamentos_a_portar(idx).qtd_aa_ano;
          vr_tab_update(vr_idx_update).cdoperacao := vr_tab_lancamentos_a_portar(idx).cdoperacao;
          vr_tab_update(vr_idx_update).cdcooper   := vr_tab_lancamentos_a_portar(idx).cdcooper;
          vr_tab_update(vr_idx_update).dtmvtolt   := vr_tab_lancamentos_a_portar(idx).dtmvtolt;
          vr_tab_update(vr_idx_update).nrsequen   := vr_tab_lancamentos_a_portar(idx).nrsequen;
          vr_tab_update(vr_idx_update).dtoperacao := vr_tab_lancamentos_a_portar(idx).dtoperacao;
          vr_tab_update(vr_idx_update).qtddif     := vr_tab_lancamentos_a_portar(idx).qtddif;
        END IF;
      END LOOP;
      
      -- Quando atingir o valor da janela do bulk collect, realizar os inserts/updates.
      IF vr_tab_insert.COUNT > 0 THEN
        FORALL idx_ins IN INDICES OF vr_tab_insert SAVE EXCEPTIONS
          INSERT INTO TBCC_OPERACOES_DIARIAS 
          (CDCOOPER, NRDCONTA, 
           CDOPERACAO, DTOPERACAO, 
           NRSEQUEN)
          VALUES
          (vr_tab_insert(idx_ins).cdcooper, vr_tab_insert(idx_ins).nrdconta,
           vr_tab_insert(idx_ins).cdoperacao, vr_tab_insert(idx_ins).dtmvtolt,
           vr_tab_insert(idx_ins).qtddif);
        
        vr_idx_insert := 0;
        vr_tab_insert.Delete();
      END IF;
          
      IF vr_tab_update.COUNT > 0 THEN
        FORALL idx_updt IN INDICES OF vr_tab_update SAVE EXCEPTIONS
          UPDATE TBCC_OPERACOES_DIARIAS OPER
             SET OPER.NRSEQUEN = vr_tab_update(idx_updt).nrsequen + vr_tab_update(idx_updt).qtddif
           WHERE OPER.CDCOOPER = vr_tab_update(idx_updt).cdcooper
             AND OPER.NRDCONTA = vr_tab_update(idx_updt).nrdconta
             AND OPER.DTOPERACAO = vr_tab_update(idx_updt).dtoperacao
             AND OPER.CDOPERACAO = vr_tab_update(idx_updt).cdoperacao;
        
        vr_idx_update := 0;
        vr_tab_update.Delete();
      END IF;
      
      -- Um commit a cada batch.
      COMMIT;
    END LOOP;
    CLOSE cr_lancamentos_a_portar;
  END LOOP;
EXCEPTION
  WHEN vr_exc_saida THEN
    IF cr_lancamentos_a_portar%ISOPEN THEN
      CLOSE cr_lancamentos_a_portar;
    END IF;
    
    DBMS_OUTPUT.put_line('Erro Interno: ' || SQLERRM || ' - ' || vr_dscritic);
    
    ROLLBACK;
  WHEN BULK_DML_EXCEPTION THEN
    IF cr_lancamentos_a_portar%ISOPEN THEN
      CLOSE cr_lancamentos_a_portar;
    END IF;
    
    DBMS_OUTPUT.put_line('Erro de BULK_DML_EXCEPTION - ' || SQLERRM || ' - Descarregando erros de FORALL:');
    
    FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.put_line (
            SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
         || ' : '
         || sqlerrm(-SQL%BULK_EXCEPTIONS (indx).ERROR_CODE));
    END LOOP;
    
    ROLLBACK;
  WHEN OTHERS THEN
    IF cr_lancamentos_a_portar%ISOPEN THEN
      CLOSE cr_lancamentos_a_portar;
    END IF;
    
    DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
    
    ROLLBACK;
END;
/
