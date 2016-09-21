CREATE OR REPLACE FUNCTION CECRED.fn_risco_pp(pr_cdcooper IN NUMBER
                                      ,pr_nrdconta IN NUMBER
                                      ,pr_nrctremp IN NUMBER
                                      ,pr_innivris IN NUMBER
                                      ,pr_inprejuz IN crapepr.inprejuz%TYPE
                                      ,pr_qtdiaatr IN crapris.qtdiaatr%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) RETURN NUMBER IS
BEGIN
  DECLARE 
  
  -- Vetor para armazenar os dados de riscos, dessa forma temos o valor
  -- char do risco (AA, A, B...HH) como chave e o valor é seu indice
  TYPE typ_tab_risco IS
    TABLE OF PLS_INTEGER
      INDEX BY VARCHAR2(2);
  vr_tab_risco typ_tab_risco;
      
        
    vr_nivel_atraso NUMBER;
    vr_aux_nivel    NUMBER;
    vr_risco_rating NUMBER;
    
    CURSOR cr_crawepr IS
      SELECT dsnivris
        FROM crawepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
    vr_dsnivris crawepr.dsnivris%TYPE;
    
    CURSOR cr_crapnrc IS
      SELECT NVL(nrc.indrisco,' ') indrisco
            ,nrc.dtmvtolt
            ,'S' indexis
        FROM crapnrc nrc
       WHERE nrc.cdcooper = pr_cdcooper
         AND nrc.nrdconta = pr_nrdconta
         AND nrc.insitrat = 2; --> efetivo
    rw_crapnrc cr_crapnrc%ROWTYPE;
    
    
  BEGIN

    -- Carregar a tabela de de-para do risco como texto e como valor
    vr_tab_risco(' ') := 2;
    vr_tab_risco('AA') := 1;
    vr_tab_risco('A') := 2;
    vr_tab_risco('B') := 3;
    vr_tab_risco('C') := 4;
    vr_tab_risco('D') := 5;
    vr_tab_risco('E') := 6;
    vr_tab_risco('F') := 7;
    vr_tab_risco('G') := 8;
    vr_tab_risco('H') := 9;
    vr_tab_risco('HH') := 10;

    -- Backup da variavel vr_aux_nivel
    vr_nivel_atraso := pr_innivris;    
    
    -- Para cada associado, rating efetivo inicia com nível 2
    vr_risco_rating := 2;
    
    -- Se encontrou notas de rating do contrado da conta e existir o indicador
    OPEN cr_crapnrc;
    FETCH cr_crapnrc
     INTO rw_crapnrc;
    IF cr_crapnrc%FOUND AND rw_crapnrc.indrisco <> ' ' THEN
      -- Traduzir o indice char do risco para seu valor number
      vr_risco_rating := vr_tab_risco(rw_crapnrc.indrisco);
    END IF;
    CLOSE cr_crapnrc;
    
    -- Buscar nivel do risco do cadastro
    OPEN cr_crawepr;
    FETCH cr_crawepr
     INTO vr_dsnivris;
    IF cr_crawepr%FOUND THEN
      -- Vamos verificar qual nivel de risco esta na proposto do emprestimo
      CASE
        WHEN vr_dsnivris = ' '  THEN
          vr_aux_nivel := 2;
        WHEN vr_dsnivris = 'AA' THEN
          vr_aux_nivel := 1;
        WHEN vr_dsnivris = 'A'  THEN
          vr_aux_nivel := 2;
        WHEN vr_dsnivris = 'B'  THEN
          vr_aux_nivel := 3;
        WHEN vr_dsnivris = 'C'  THEN
          vr_aux_nivel := 4;
        WHEN vr_dsnivris = 'D'  THEN
          vr_aux_nivel := 5;
        WHEN vr_dsnivris = 'E'  THEN
          vr_aux_nivel := 6;
        WHEN vr_dsnivris = 'F'  THEN
          vr_aux_nivel := 7;
        WHEN vr_dsnivris = 'G'  THEN
          vr_aux_nivel := 8;
        ELSE
          vr_aux_nivel := 9;
      END CASE;

      IF vr_risco_rating <> 0 THEN
        IF rw_crapnrc.indexis = 'S' THEN
          -- Se a data do rating for superior ou igual a do vencimento da parcela
          IF rw_crapnrc.dtmvtolt >= pr_dtmvtolt THEN
            -- Assumir o nível do rating
            vr_aux_nivel := vr_risco_rating;
          END IF;

        END IF;

      END IF; /* END IF pr_risco_rating <> 0 */

    END IF;
    CLOSE cr_crawepr;

    /* Se emprestimo tiver nivel maior que o atraso....*/
    IF vr_nivel_atraso > vr_aux_nivel THEN
      vr_aux_nivel := vr_nivel_atraso;
    END IF;

    -- Verifica se o emprestimo esta em prejuizo
    IF pr_inprejuz = 1 THEN
      vr_aux_nivel := 9;
    END IF;

    IF vr_risco_rating <> 0 AND vr_risco_rating > vr_aux_nivel THEN
      vr_aux_nivel := vr_risco_rating;
    END IF;

    IF vr_risco_rating <> 0 AND pr_qtdiaatr <= 0 THEN
      IF rw_crapnrc.indexis = 'S' THEN
        -- Se a data do rating for superior ou igual a do vencimento da parcela
        IF rw_crapnrc.dtmvtolt >= pr_dtmvtolt THEN
          -- Assumir o nível do rating
          vr_aux_nivel := vr_risco_rating;
        END IF;

      END IF;

    END IF;
    
    RETURN vr_aux_nivel;
    
  END;
END;
/

