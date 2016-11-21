CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_CRAPADP
  AFTER UPDATE OR DELETE ON crapadp
  FOR EACH ROW
DECLARE
  ww_cdlocali_ant varchar2(100);
  ww_cdlocali_atu varchar2(100);

  ww_cdabrido_ant  varchar2(100);
  ww_cdabrido_atu  varchar2(100);

  ww_idstaeve_ant  varchar2(100);
  ww_idstaeve_atu  varchar2(100);

  ww_nrseqtem_ant varchar2(100);
  ww_nrseqtem_atu varchar2(100);

  ww_nrseqpri_ant varchar2(100);
  ww_nrseqpri_atu varchar2(100);

  ww_cdcopope_ant varchar2(100);
  ww_cdcopope_atu varchar2(100);

  ww_cdoperad_ant varchar2(100);
  ww_cdoperad_atu varchar2(100);
  
  ww_idfimava_ant varchar2(100);
  ww_idfimava_atu varchar2(100);
  
  -- local variables here
  PROCEDURE grava_historico (id_acao IN VARCHAR2,
                             nm_campo IN VARCHAR2,
                             vl_anterior IN VARCHAR2,
                             vl_atual IN VARCHAR2) IS

  wr_idevento crapadp.idevento%TYPE ;
  wr_cdcooper crapadp.cdcooper%TYPE ;
  wr_dtanoage crapadp.dtanoage%TYPE ;
  wr_cdevento crapadp.cdevento%TYPE ;
  wr_cdagenci crapadp.cdagenci%TYPE ;
  wr_nrseqdig crapadp.nrseqdig%TYPE ;
  wr_hratuali craphea.hratuali%TYPE := TO_CHAR(SYSDATE,'SSSSS');
  wr_cdcopope craphea.cdcopope%TYPE;
  wr_cdoperad craphea.cdoperad%TYPE;

  

  BEGIN

    SELECT DECODE(:OLD.IDFIMAVA, 0, 'NÃO', 1, 'SIM', ' ')
        ,DECODE(:NEW.IDFIMAVA, 0, 'NÃO', 1, 'SIM', ' ')
    INTO ww_idfimava_ant
        ,ww_idfimava_atu
    FROM DUAL;
    
    IF id_acao = 'A' then -- Alteração
      wr_idevento := :NEW.IDEVENTO;
      wr_cdcooper := :NEW.CDCOOPER;
      wr_dtanoage := :NEW.DTANOAGE;
      wr_cdevento := :NEW.CDEVENTO;
      wr_cdagenci := :NEW.CDAGENCI;
      wr_nrseqdig := :NEW.NRSEQDIG;
      wr_cdcopope := :NEW.CDCOPOPE;
      wr_cdoperad := :NEW.CDOPERAD;
    ELSE
      wr_idevento := :OLD.IDEVENTO;
      wr_cdcooper := :OLD.CDCOOPER;
      wr_dtanoage := :OLD.DTANOAGE;
      wr_cdevento := :OLD.CDEVENTO;
      wr_cdagenci := :OLD.CDAGENCI;
      wr_nrseqdig := :OLD.NRSEQDIG;
      wr_cdcopope := :OLD.CDCOPOPE;
      wr_cdoperad := :OLD.CDOPERAD;

    END IF;
      INSERT INTO craphea
                      (IDEVENTO,
                      CDCOOPER,
                      DTANOAGE,
                      CDEVENTO,
                      CDAGENCI,
                      NRSEQDIG,
                      NMDCAMPO,
                      DTATUALI,
                      DSANTCMP,
                      DSATUCMP,
                      hratuali,
                      CDCOPOPE,
                      CDOPERAD)
               VALUES(
                      wr_idevento,
                      wr_cdcooper,
                      wr_dtanoage,
                      wr_cdevento,
                      wr_cdagenci,
                      wr_nrseqdig,
                      nm_campo,
                      sysdate,
                      nvl(vl_anterior, ' '),
                      nvl(vl_atual,' '),
                      wr_hratuali,
                      wr_cdcopope,
                      wr_cdoperad
                      );
  END;
BEGIN
  NULL;
    -- Incluir no histórico a descrição do local
    IF NVL(:OLD.cdlocali,0) <> 0 THEN
      begin
      SELECT
            CL.NRSEQDIG||'-'||CL.DSLOCALI
      INTO
            ww_cdlocali_ant
      FROM
            CRAPLDP CL
      WHERE
            CL.IDEVENTO = :OLD.IDEVENTO
        AND CL.CDCOOPER = :OLD.CDCOOPER
        --AND CL.CDAGENCI = :OLD.CDAGENCI
        AND CL.NRSEQDIG = :OLD.CDLOCALI
        AND ROWNUM = 1;
        exception
          when no_data_found then
            ww_cdlocali_ant:= :OLD.CDLOCALI||' - '||'NÃO CADASTRADA';
        end;
    END IF;

    IF NVL(:NEW.cdlocali,0) <> 0 THEN
      begin
      SELECT
            CL.NRSEQDIG||'-'||CL.DSLOCALI
      INTO
            ww_cdlocali_atu
      FROM
            CRAPLDP CL
      WHERE
            CL.IDEVENTO = :NEW.IDEVENTO
        AND CL.CDCOOPER = :NEW.CDCOOPER
        --AND CL.CDAGENCI = :NEW.CDAGENCI
        AND CL.NRSEQDIG = :NEW.CDLOCALI
        AND ROWNUM = 1;
        exception
          when no_data_found then
            ww_cdlocali_atu:= :NEW.CDLOCALI||' - '||'NÃO CADASTRADA';
        end;        
    END IF;

    -- Incluir no histórico a descrição da pessoa para abertura
    IF NVL(:OLD.cdabrido,0) <> 0 THEN
      BEGIN
        SELECT
              CA.NRSEQDIG||'-'||CA.NMABREVE
        INTO
              ww_cdabrido_ant
        FROM
              CRAPAEP CA
        WHERE
              CA.IDEVENTO = :OLD.IDEVENTO
          AND CA.CDCOOPER = :OLD.CDCOOPER
          AND CA.CDAGENCI = :OLD.CDAGENCI
          AND CA.NRSEQDIG = :OLD.cdabrido;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
            SELECT
                  CA.NRSEQDIG||'-'||CA.NMABREVE
            INTO
                  ww_cdabrido_ant
            FROM
                  CRAPAEP CA
            WHERE
                  CA.IDEVENTO = :OLD.IDEVENTO
              AND CA.CDCOOPER = :OLD.CDCOOPER
              AND CA.CDAGENCI = 0 -- TODAS
              AND CA.NRSEQDIG = :OLD.cdabrido;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                begin
                SELECT
                      CA.NRSEQDIG||'-'||CA.NMABREVE
                INTO
                      ww_cdabrido_ant
                FROM
                      CRAPAEP CA
                WHERE
                      CA.IDEVENTO = :OLD.IDEVENTO
                  AND CA.CDCOOPER = :OLD.CDCOOPER
                  AND CA.NRSEQDIG = :OLD.cdabrido
                  AND ROWNUM = 1;
                exception
                  when no_data_found then
                    ww_cdabrido_ant:= :OLD.cdabrido||' - '||'NÃO CADASTRADO';
                end;            
            END;
        END;
    END IF;

    IF NVL(:NEW.cdabrido,0) <> 0 THEN
      BEGIN
        SELECT
              CA.NRSEQDIG||'-'||CA.NMABREVE
        INTO
              ww_cdabrido_atu
        FROM
              CRAPAEP CA
        WHERE
              CA.IDEVENTO = :NEW.IDEVENTO
          AND CA.CDCOOPER = :NEW.CDCOOPER
          AND CA.CDAGENCI = :NEW.CDAGENCI
          AND CA.NRSEQDIG = :NEW.cdabrido;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT
                    CA.NRSEQDIG||'-'||CA.NMABREVE
              INTO
                    ww_cdabrido_atu
              FROM
                    CRAPAEP CA
              WHERE
                    CA.IDEVENTO = :NEW.IDEVENTO
                AND CA.CDCOOPER = :NEW.CDCOOPER
                AND CA.CDAGENCI = 0 -- TODAS
                AND CA.NRSEQDIG = :NEW.cdabrido;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                begin
                SELECT
                      CA.NRSEQDIG||'-'||CA.NMABREVE
                INTO
                      ww_cdabrido_atu
                FROM
                      CRAPAEP CA
                WHERE
                      CA.IDEVENTO = :NEW.IDEVENTO
                  AND CA.CDCOOPER = :NEW.CDCOOPER
                  AND CA.NRSEQDIG = :NEW.cdabrido
                  AND ROWNUM = 1;
                exception
                  when no_data_found then
                    ww_cdabrido_atu:= :NEW.cdabrido||' - '||'NÃO CADASTRADO';
                end;            
                  
            END;
        END;
    END IF;

    -- Incluir no histórico a descrição do status do evento
    SELECT
          DECODE(:OLD.IDSTAEVE,1,'1 - AGENDADO',
                               2,'2 - CANCELADO',
                               3,'3 - TRANSFERIDO',
                               4,'4 - ENCERRADO',
                               5,'5 - REALIZADO',
                               6,'6 - ACRESCIDO',
                               :OLD.IDSTAEVE),
          DECODE(:NEW.IDSTAEVE,1,'1 - AGENDADO',
                               2,'2 - CANCELADO',
                               3,'3 - TRANSFERIDO',
                               4,'4 - ENCERRADO',
                               5,'5 - REALIZADO',
                               6,'6 - ACRESCIDO',
                               :NEW.IDSTAEVE)
    INTO
      ww_idstaeve_ant,
      ww_idstaeve_atu
    FROM DUAL;

    -- Incluir no histórico a descrição do Tema
    IF NVL(:OLD.NRSEQTEM,0) <> 0 THEN
      begin
      SELECT
            CT.NRSEQTEM||'-'||CT.DSTEMEIX
      INTO
            ww_nrseqtem_ant
      FROM
            CRAPTEM CT
      WHERE
            CT.IDEVENTO = :OLD.IDEVENTO
        AND CT.CDCOOPER = 0
        AND CT.NRSEQTEM = :OLD.NRSEQTEM;
      exception
         when no_data_found then
           ww_nrseqtem_ant:= :OLD.NRSEQTEM||' - '||'NÃO CADASTRADO';
      end;            
    END IF;

    IF NVL(:NEW.NRSEQTEM,0) <> 0 THEN
      begin
      SELECT
            CT.NRSEQTEM||'-'||CT.DSTEMEIX
      INTO
            ww_nrseqtem_atu
      FROM
            CRAPTEM CT
      WHERE
            CT.IDEVENTO = :NEW.IDEVENTO
        AND CT.CDCOOPER = 0
        AND CT.NRSEQTEM = :NEW.NRSEQTEM;
      exception
         when no_data_found then
           ww_nrseqtem_atu:= :NEW.NRSEQTEM||' - '||'NÃO CADASTRADO';
      end;            

    END IF;

    -- Incluir no histórico a descrição da Parceria Institucional
    IF NVL(:OLD.NRSEQPRI,0) <> 0 THEN
      begin
      SELECT
            CP.NRSEQPRI||'-'||CP.NMPRCINS
      INTO
            ww_nrseqpri_ant
      FROM
            CRAPPRI CP
      WHERE
            CP.NRSEQPRI = :OLD.NRSEQPRI;
      exception
         when no_data_found then
           ww_nrseqpri_ant:= :OLD.NRSEQPRI||' - '||'NÃO CADASTRADA';
      end;            
            
    END IF;

    IF NVL(:NEW.NRSEQPRI,0) <> 0 THEN
      begin
      SELECT
            CP.NRSEQPRI||'-'||CP.NMPRCINS
      INTO
            ww_nrseqpri_atu
      FROM
            CRAPPRI CP
      WHERE
            CP.NRSEQPRI = :NEW.NRSEQPRI;
      exception
         when no_data_found then
           ww_nrseqpri_atu:= :NEW.NRSEQPRI||' - '||'NÃO CADASTRADA';
      end;            
    END IF;

    -- Incluir no histórico o nome do Operador e Cooperativa
    IF NVL(:OLD.CDOPERAD,' ') <> ' ' AND NVL(:OLD.CDCOPOPE,0) <> 0 THEN
      begin
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
        AND CO.CDOPERAD = :OLD.CDOPERAD;
      exception
         when no_data_found then
           ww_cdcopope_ant:= :OLD.CDCOPOPE||' - '||'NÃO CADASTRADA';
           ww_cdoperad_ant:= :OLD.CDOPERAD||' - '||'NÃO CADASTRADO';                      
      end;            
    END IF;

    IF NVL(:NEW.CDOPERAD,' ') <> ' ' AND NVL(:NEW.CDCOPOPE,0) <> 0 THEN
      begin
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
        AND CO.CDOPERAD = :NEW.CDOPERAD;
      exception
         when no_data_found then
           ww_cdcopope_atu:= :NEW.CDCOPOPE||' - '||'NÃO CADASTRADA';
           ww_cdoperad_atu:= :NEW.CDOPERAD||' - '||'NÃO CADASTRADO';                      
      end;            
        
    END IF;

  IF UPDATING THEN
    IF :NEW.cdlocali  <> :OLD.cdlocali THEN
      --grava_historico('A','CDLOCALI',:OLD.cdlocali,:NEW.cdlocali );
      grava_historico('A','CDLOCALI',ww_cdlocali_ant,ww_cdlocali_atu );

    END IF;

    IF :NEW.cdabrido         <> :OLD.cdabrido THEN
      --grava_historico('A','CDABRIDO',:OLD.cdabrido,:NEW.cdabrido );
      grava_historico('A','CDABRIDO',ww_cdabrido_ant,ww_cdabrido_atu );
    END IF;

    IF :NEW.nrmeseve         <> :OLD.nrmeseve THEN
      grava_historico('A','NRMESEVE',:OLD.nrmeseve,:NEW.nrmeseve );
    END IF;

    IF :NEW.dtinieve         <> :OLD.dtinieve THEN
      grava_historico('A','DTINIEVE',to_char(:OLD.dtinieve,'DDMMYYYY'), to_char(:NEW.dtinieve,'DDMMYYYY'));
    END IF;

    IF :NEW.dtfineve         <> :OLD.dtfineve THEN
      grava_historico('A','DTFIMEVE',to_char(:OLD.dtfineve,'DDMMYYYY'),to_char(:NEW.dtfineve,'DDMMYYYY'));
    END IF;

    IF :NEW.dshroeve         <> :OLD.dshroeve THEN
      grava_historico('A','DSHROEVE',:OLD.dshroeve,:NEW.dshroeve );
    END IF;

    IF :NEW.dsdiaeve         <> :OLD.dsdiaeve THEN
      grava_historico('A','DSDIAEVE',:OLD.dsdiaeve,:NEW.dsdiaeve );
    END IF;

    IF :NEW.idstaeve         <> :OLD.idstaeve THEN
      --grava_historico('A','IDSTAEVE',:OLD.idstaeve,:NEW.idstaeve );
      grava_historico('A','IDSTAEVE',ww_idstaeve_ant,ww_idstaeve_atu );
    END IF;

    IF :NEW.dtmvtolt         <> :OLD.dtmvtolt THEN
      grava_historico('A','DTMVTOLT',:OLD.dtmvtolt,:NEW.dtmvtolt );
    END IF;

    IF :NEW.qtdiaeve         <> :OLD.qtdiaeve THEN
      grava_historico('A','QTDIAEVE',:OLD.qtdiaeve,:NEW.qtdiaeve );
    END IF;

    IF :NEW.dtlibint         <> :OLD.dtlibint THEN
      grava_historico('A','DTLIBINT',:OLD.dtlibint,:NEW.dtlibint );
    END IF;

    IF :NEW.dtretint         <> :OLD.dtretint THEN
      grava_historico('A','DTRETINT',:OLD.dtretint,:NEW.dtretint );
    END IF;

    IF :NEW.nrmesage         <> :OLD.nrmesage THEN
      grava_historico('A','NRMESAGE',:OLD.nrmesage,:NEW.nrmesage );
    END IF;


    --Campos novos para inclusão após criação dos mesmos na tabela:
    --NRSEQTEM
    IF :NEW.NRSEQTEM   <> :OLD.NRSEQTEM THEN
      --grava_historico('A','NRSEQTEM',:OLD.NRSEQTEM,:NEW.NRSEQTEM );
      grava_historico('A','NRSEQTEM',ww_nrseqtem_ant,ww_nrseqtem_atu );
    END IF;

     --NRSEQPRI
    IF :NEW.NRSEQPRI   <> :OLD.NRSEQPRI THEN
      --grava_historico('A','NRSEQPRI',:OLD.NRSEQPRI,:NEW.NRSEQPRI );
      grava_historico('A','NRSEQPRI',ww_nrseqpri_ant,ww_nrseqpri_atu );
    END IF;

    --DSJUSTIF
    IF :NEW.DSJUSTIF   <> :OLD.DSJUSTIF THEN
      grava_historico('A','DSJUSTIF',:OLD.DSJUSTIF,:NEW.DSJUSTIF );
    END IF;

    --CDOPERAD
    IF :NEW.CDOPERAD   <> :OLD.CDOPERAD THEN
      --grava_historico('A','CDOPERAD',:OLD.CDOPERAD,:NEW.CDOPERAD );
      grava_historico('A','CDOPERAD',ww_cdoperad_ant,ww_cdoperad_atu );
    END IF;

    --CDCOPOPE
    IF :NEW.CDCOPOPE <> :OLD.CDCOPOPE THEN
       --grava_historico('A','CDCOPOPE',:OLD.CDCOPOPE,:NEW.CDCOPOPE );
       grava_historico('A','CDCOPOPE',ww_cdcopope_ant,ww_cdcopope_atu);
    END IF;
    
    --IDFIMAVA
    IF :NEW.IDFIMAVA <> :OLD.IDFIMAVA THEN
       grava_historico('A','IDFIMAVA',ww_idfimava_ant,ww_idfimava_atu);
    END IF;
   
  ELSIF DELETING THEN

      grava_historico('E','CDLOCALI',ww_cdlocali_ant,' ' );--:OLD.cdlocali,'' );
      grava_historico('E','CDABRIDO',ww_cdabrido_ant,' ' );--:OLD.cdabrido,'' );
      grava_historico('E','NRMESEVE',:OLD.nrmeseve,' ' );
      grava_historico('E','DTINIEVE',:OLD.dtinieve,' ' );
      grava_historico('E','DTFIMEVE',:OLD.dtfineve,' ' );
      grava_historico('E','DSHROEVE',:OLD.dshroeve,' ' );
      grava_historico('E','DSDIAEVE',:OLD.dsdiaeve,' ' );
      grava_historico('E','IDSTAEVE',ww_idstaeve_ant,' ' );--:OLD.idstaeve,'' );
      grava_historico('E','DTMVTOLT',:OLD.dtmvtolt,' ' );
      grava_historico('E','CDOPERAD',ww_cdoperad_ant,' ' );--:OLD.cdoperad,'' );
      grava_historico('E','QTDIAEVE',:OLD.qtdiaeve,' ' );
      grava_historico('E','DTLIBINT',:OLD.dtlibint,' ' );
      grava_historico('E','DTRETINT',:OLD.dtretint,' ' );
      grava_historico('E','NRMESAGE',:OLD.nrmesage,' ' );
      grava_historico('E','NRSEQTEM',ww_nrseqtem_ant,' ' );--:OLD.NRSEQTEM,'' );
      grava_historico('E','NRSEQPRI',ww_nrseqpri_ant,' ' );--:OLD.NRSEQPRI,'' );
      grava_historico('E','DSJUSTIF',:OLD.DSJUSTIF,' ' );
      grava_historico('E','CDCOPOPE',ww_cdcopope_ant,' ' );--OLD.CDCOPOPE,'' );
      grava_historico('E','IDFIMAVA',ww_idfimava_ant,' ' );

  END IF;

END TRG_HISTORICO_CRAPADP;
/
