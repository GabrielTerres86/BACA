CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_CRAPEAP
  AFTER UPDATE OR DELETE ON crapeap
  FOR EACH ROW
DECLARE
  ww_flgevobr_ant varchar2(100);
  ww_flgevobr_atu varchar2(100); 
  
  ww_flgevsel_ant varchar2(100);
  ww_flgevsel_atu varchar2(100);  
  
  ww_cdcopope_ant varchar2(100);
  ww_cdcopope_atu varchar2(100);  
  
  ww_cdoperad_ant varchar2(100);
  ww_cdoperad_atu varchar2(100);
  
  -- local variables here
  PROCEDURE grava_historico (id_acao  IN VARCHAR2,
                             nm_campo IN VARCHAR2,
                             vl_anterior IN VARCHAR2,
                             vl_atual IN VARCHAR2) IS

  wr_idevento crapeap.idevento%TYPE ;
  wr_cdcooper crapeap.cdcooper%TYPE ;
  wr_dtanoage crapeap.dtanoage%TYPE ;
  wr_cdevento crapeap.cdevento%TYPE ;
  wr_cdagenci crapeap.cdagenci%TYPE ;
  wr_hratuali craphap.hratuali%TYPE := TO_CHAR(SYSDATE,'SSSSS');
  wr_cdcopope craphap.cdcopope%TYPE;
  wr_cdoperad craphap.cdoperad%TYPE;

  BEGIN
    IF id_acao = 'A' THEN -- Alteração
      wr_idevento := :NEW.IDEVENTO;
      wr_cdcooper := :NEW.CDCOOPER;
      wr_dtanoage := :NEW.DTANOAGE;
      wr_cdevento := :NEW.CDEVENTO;
      wr_cdagenci := :NEW.CDAGENCI;
      wr_cdcopope := :NEW.CDCOPOPE;
      wr_cdoperad := :NEW.CDOPERAD;
    ELSE
      wr_idevento := :OLD.IDEVENTO;
      wr_cdcooper := :OLD.CDCOOPER;
      wr_dtanoage := :OLD.DTANOAGE;
      wr_cdevento := :OLD.CDEVENTO;
      wr_cdagenci := :OLD.CDAGENCI;
      wr_cdcopope := :OLD.CDCOPOPE;
      wr_cdoperad := :OLD.CDOPERAD;
    END IF;
      INSERT INTO CRAPHAP 
                      (IDEVENTO,
                       CDCOOPER,
                       DTANOAGE,
                       CDEVENTO,
                       CDAGENCI,
                       NMDCAMPO,
                       DTATUALI, 
                       HRATUALI, 
                       DSANTCMP, 
                       DSATUCMP,
                       CDCOPOPE,
                       CDOPERAD
                      ) 
               VALUES(
                      wr_idevento,
                      wr_cdcooper,
                      wr_dtanoage,
                      wr_cdevento,
                      wr_cdagenci,
                      nm_campo,
                      SYSDATE,
                      wr_hratuali,
                      vl_anterior,
                      vl_atual,
                      wr_cdcopope,
                      wr_cdoperad                     
                      );
  END;
BEGIN
    -- Incluir no histórico a descrição dos Flags
    SELECT
      DECODE(:OLD.flgevobr,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgevobr,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgevsel,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgevsel,0,'NÃO',1,'SIM',' ')             
    INTO
      ww_flgevobr_ant,
      ww_flgevobr_atu,
      ww_flgevsel_ant,
      ww_flgevsel_atu                  
    FROM DUAL;

    -- Incluir no histórico o nome do Operador e Cooperativa
    IF NVL(trim(:OLD.CDOPERAD),' ') <> ' ' AND NVL(:OLD.CDCOPOPE,0) <> 0 THEN
      SELECT
            CC.CDCOOPER||'-'||CC.NMRESCOP,
            CO.CDOPERAD||'-'||CO.NMOPERAD                             
      INTO
            ww_cdcopope_ant,
            ww_cdoperad_ant
      FROM 
            CRAPOPE CO,
            CRAPCOP CC
      WHERE 
            CO.CDCOOPER = CC.CDCOOPER
        AND CO.CDCOOPER = :OLD.CDCOPOPE
        AND UPPER(CO.CDOPERAD) = TRIM(UPPER(:OLD.CDOPERAD));
    END IF;

    IF NVL(trim(:NEW.CDOPERAD),' ') <> ' ' AND NVL(:NEW.CDCOPOPE,0) <> 0 THEN
      SELECT
            CC.CDCOOPER||'-'||CC.NMRESCOP,
            CO.CDOPERAD||'-'||CO.NMOPERAD                             
      INTO
            ww_cdcopope_atu,
            ww_cdoperad_atu
      FROM 
            CRAPOPE CO,
            CRAPCOP CC
      WHERE 
            CO.CDCOOPER = CC.CDCOOPER
        AND CO.CDCOOPER = :NEW.CDCOPOPE
        AND UPPER(CO.CDOPERAD) = TRIM(UPPER(:NEW.CDOPERAD));
    END IF; 
         
  IF UPDATING THEN
    IF :NEW.flgevobr  <> :OLD.flgevobr THEN
      --grava_historico('A','FLGEVOBR',:OLD.flgevobr,:NEW.flgevobr );
      grava_historico('A','FLGEVOBR',ww_flgevobr_ant,ww_flgevobr_atu );
    END IF;

    IF :NEW.flgevsel         <> :OLD.flgevsel THEN
      --grava_historico('A','FLGEVSEL',:OLD.flgevsel,:NEW.flgevsel );      
      grava_historico('A','FLGEVSEL',ww_flgevsel_ant,ww_flgevsel_atu );
    END IF;

    IF :NEW.qtmaxtur         <> :OLD.qtmaxtur THEN
      grava_historico('A','QTMAXTUR',:OLD.qtmaxtur,:NEW.qtmaxtur );
    END IF;

    IF :NEW.QTOCOEVE         <> :OLD.QTOCOEVE THEN
      grava_historico('A','QTOCOEVE',:OLD.QTOCOEVE,:NEW.QTOCOEVE );
    END IF;
    
     --CDOPERAD
    IF :NEW.CDOPERAD   <> :OLD.CDOPERAD THEN
      --grava_historico('A','CDOPERAD',:OLD.CDOPERAD,:NEW.CDOPERAD );
      grava_historico('A','CDOPERAD',ww_cdoperad_ant,ww_cdoperad_atu );      
    END IF;
    
    --CDCOPOPE
    IF :NEW.CDCOPOPE <> :OLD.CDCOPOPE THEN
       --grava_historico('A','CDCOPOPE',:OLD.CDCOPOPE,:NEW.CDCOPOPE );
       grava_historico('A','CDCOPOPE',ww_cdcopope_ant,ww_cdcopope_atu );
    END IF; 
    
  ELSIF DELETING THEN

      grava_historico('E','FLGEVOBR',ww_flgevobr_ant,'' );--:OLD.FLGEVOBR,'' );
      grava_historico('E','FLGEVSEL',ww_flgevsel_ant,'' );--:OLD.FLGEVSEL,'' );
      grava_historico('E','QTMAXTUR',:OLD.QTMAXTUR,'' );
      grava_historico('E','QTOCOEVE',:OLD.QTOCOEVE,'' );
      grava_historico('E','CDCOPOPE',ww_cdcopope_ant,'' );--:OLD.CDCOPOPE,'' );
      grava_historico('E','CDOPERAD',ww_cdoperad_ant,'' );--:OLD.CDOPERAD,'' );
  END IF;
END TRG_HISTORICO_CRAPEAP;
