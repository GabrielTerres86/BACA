CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_CRAPEDP
  AFTER UPDATE OR DELETE ON crapedp
  FOR EACH ROW
DECLARE
  ww_tpevento_ant varchar2(100);
  ww_tpevento_atu varchar2(100);

  ww_tppartic_ant varchar2(100);
  ww_tppartic_atu varchar2(100);

  ww_flgcompr_ant varchar2(100);
  ww_flgcompr_atu varchar2(100);

  ww_flgtdpac_ant varchar2(100);
  ww_flgtdpac_atu varchar2(100);

  ww_flgcerti_ant varchar2(100);
  ww_flgcerti_atu varchar2(100);

  ww_flgrestr_ant varchar2(100);
  ww_flgrestr_atu varchar2(100);

  ww_flgativo_ant varchar2(100);
  ww_flgativo_atu varchar2(100);

  ww_flgsorte_ant varchar2(100);
  ww_flgsorte_atu varchar2(100);

  ww_cdeixtem_ant varchar2(100);
  ww_cdeixtem_atu varchar2(100);

  ww_nrseqtem_ant varchar2(100);
  ww_nrseqtem_atu varchar2(100);

  ww_nrseqpri_ant varchar2(100);
  ww_nrseqpri_atu varchar2(100);

  ww_cdcopope_ant varchar2(100);
  ww_cdcopope_atu varchar2(100);

  ww_cdoperad_ant varchar2(100);
  ww_cdoperad_atu varchar2(100);

  ww_idrespub_ant varchar2(100);
  ww_idrespub_atu varchar2(100);

  -- local variables here
  PROCEDURE grava_historico (id_acao      IN VARCHAR2,
                             nm_campo     IN VARCHAR2,
                             vl_anterior  IN VARCHAR2,
                             vl_atual     IN VARCHAR2) IS
  wr_idevento crapedp.idevento%TYPE;
  wr_cdcooper crapedp.cdcooper%TYPE;
  wr_dtanoage crapedp.dtanoage%TYPE;
  wr_cdevento crapedp.cdevento%TYPE;

  wr_hratuali CRAPHEV.hratuali%TYPE := TO_CHAR(SYSDATE,'SSSSS');
  wr_cdcopope craphev.cdcopope%TYPE;
  wr_cdoperad craphev.cdoperad%TYPE;


  BEGIN
    IF id_acao = 'A' then -- Alteração
      wr_idevento := :NEW.IDEVENTO;
      wr_cdcooper := :NEW.CDCOOPER;
      wr_dtanoage := :NEW.DTANOAGE;
      wr_cdevento := :NEW.CDEVENTO;
      wr_cdcopope := :NEW.CDCOPOPE;
      wr_cdoperad := :NEW.CDOPERAD;

    ELSE
      wr_idevento := :OLD.IDEVENTO;
      wr_cdcooper := :OLD.CDCOOPER;
      wr_dtanoage := :OLD.DTANOAGE;
      wr_cdevento := :OLD.CDEVENTO;
      wr_cdcopope := :OLD.CDCOPOPE;
      wr_cdoperad := :OLD.CDOPERAD;

    END IF;

      INSERT INTO craphev
                  (IDEVENTO,
                   CDCOOPER,
                   DTANOAGE,
                   CDEVENTO,
                   NMDCAMPO,
                   DTATUALI,
                   DSANTCMP,
                   DSATUCMP,
                   HRATUALI,
                   CDCOPOPE,
                   CDOPERAD)
             VALUES(
                  wr_idevento,
                  wr_cdcooper,
                  wr_dtanoage,
                  wr_cdevento ,
                  nm_campo,
                  SYSDATE,
                  vl_anterior,
                  vl_atual,
                  wr_hratuali,
                  wr_cdcopope,
                  wr_cdoperad
                  );

  END;

BEGIN
  
    -- Incluir o histórico a descrição do tipo de evento
    SELECT
          DECODE(:OLD.tpevento,1,'1 - CURSO',
                               2,'2 - INTEGRACAO',
                               3,'3 - GINCANA',
                               4,'4 - PALESTRA',
                               5,'5 - TEATRO',
                               6,'6 - OUTROS',
                               7,'7 - ASSEMBLEIA',
                               8,'8 - PRE-ASSEMBLEIA',
                               9,'9 - PROGRAMA',
                               10,'10 - EAD',
                               11,'11 - EAD ASSEMBLEAR',
                               :OLD.tpevento),
          DECODE(:NEW.tpevento,1,'1 - CURSO',
                               2,'2 - INTEGRACAO',
                               3,'3 - GINCANA',
                               4,'4 - PALESTRA',
                               5,'5 - TEATRO',
                               6,'6 - OUTROS',
                               7,'7 - ASSEMBLEIA',
                               8,'8 - PRE-ASSEMBLEIA',
                               9,'9 - PROGRAMA',
                               10,'10 - EAD',
                               11,'11 - EAD ASSEMBLEAR',
                               :NEW.tpevento)
    INTO
      ww_tpevento_ant,
      ww_tpevento_atu
    FROM DUAL;

    -- Incluir no histórico a descrição do tipo de participação permitida
    SELECT
          DECODE(:OLD.tppartic,1,'1 - ABERTO A COMUNIDADE',
                               2,'2 - EXCLUSIVO A COOPERADOS',
                               3,'3 - LIMITADO POR CONTA',
                               4,'4 - EXCLUSIVO A COMUNIDADE',
                               5,'5 - EAD',
                               :OLD.tppartic),
          DECODE(:NEW.tppartic,1,'1 - ABERTO A COMUNIDADE',
                               2,'2 - EXCLUSIVO A COOPERADOS',
                               3,'3 - LIMITADO POR CONTA',
                               4,'4 - EXCLUSIVO A COMUNIDADE',
                               5,'5 - EAD',
                               :NEW.tppartic)
    INTO
      ww_tppartic_ant,
      ww_tppartic_atu
    FROM DUAL;

    -- Incluir no histórico a descrição dos Flags
    SELECT
      DECODE(:OLD.flgcompr,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgcompr,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgtdpac,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgtdpac,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgcerti,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgcerti,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgrestr,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgrestr,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgativo,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgativo,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.flgsorte,0,'NÃO',1,'SIM',' '),
      DECODE(:NEW.flgsorte,0,'NÃO',1,'SIM',' '),
      DECODE(:OLD.idrespub,'N','NÃO','S','SIM',' '),
      DECODE(:NEW.idrespub,'N','NÃO','S','SIM',' ')
    INTO
      ww_flgcompr_ant,
      ww_flgcompr_atu,
      ww_flgtdpac_ant,
      ww_flgtdpac_atu,
      ww_flgcerti_ant,
      ww_flgcerti_atu,
      ww_flgrestr_ant,
      ww_flgrestr_atu,
      ww_flgativo_ant,
      ww_flgativo_atu,
      ww_flgsorte_ant,
      ww_flgsorte_atu,
      ww_idrespub_ant,
      ww_idrespub_atu
    FROM DUAL;

    -- Incluir no histórico a descrição do Eixo
    IF NVL(:OLD.cdeixtem,0) <> 0 THEN
      BEGIN
    SELECT
          G.CDEIXTEM||'-'||G.DSEIXTEM
    INTO
          ww_cdeixtem_ant
    FROM
          GNAPETP G
    WHERE
          G.IDEVENTO = :OLD.IDEVENTO
      AND G.CDCOOPER = 0
      AND G.CDEIXTEM = :OLD.cdeixtem;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ww_cdeixtem_ant:= :OLD.cdeixtem||'- Eixo temático anterior não existente';
      END;
    END IF;

    IF NVL(:NEW.cdeixtem,0) <> 0 THEN
      BEGIN
    SELECT
          G.CDEIXTEM||'-'||G.DSEIXTEM
    INTO
          ww_cdeixtem_atu
    FROM
          GNAPETP G
    WHERE
          G.IDEVENTO = :NEW.IDEVENTO
      AND G.CDCOOPER = 0
      AND G.CDEIXTEM = :NEW.cdeixtem;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ww_cdeixtem_ant:= :NEW.cdeixtem||'- Novo Eixo temático não existente';
      END;
    END IF;

    -- Incluir no histórico a descrição do Tema
    IF NVL(:OLD.NRSEQTEM,0) <> 0 THEN
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
    END IF;

    IF NVL(:NEW.NRSEQTEM,0) <> 0 THEN
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
    END IF;

    -- Incluir no histórico a descrição da Parceria Institucional
    IF NVL(:OLD.NRSEQPRI,0) <> 0 THEN
      SELECT
            CP.NRSEQPRI||'-'||CP.NMPRCINS
      INTO
            ww_nrseqpri_ant
      FROM
            CRAPPRI CP
      WHERE
            CP.NRSEQPRI = :OLD.NRSEQPRI;
    END IF;

    IF NVL(:NEW.NRSEQPRI,0) <> 0 THEN
      SELECT
            CP.NRSEQPRI||'-'||CP.NMPRCINS
      INTO
            ww_nrseqpri_atu
      FROM
            CRAPPRI CP
      WHERE
            CP.NRSEQPRI = :NEW.NRSEQPRI;
    END IF;

    -- Incluir no histórico o nome do Operador e Cooperativa
    IF NVL(:OLD.CDOPERAD,' ') <> ' ' AND NVL(:OLD.CDCOPOPE,0) <> 0 THEN
      BEGIN
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
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ww_cdcopope_ant := :OLD.CDCOOPER||'- Cooperativa/Operador anterior não existente';
            ww_cdoperad_ant := :OLD.CDOPERAD||'- Cooperativa/Operador anterior não existente';
        END;
    END IF;

    IF NVL(:NEW.CDOPERAD,' ') <> ' ' AND NVL(:NEW.CDCOPOPE,0) <> 0 THEN
      BEGIN
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
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ww_cdcopope_atu := :NEW.CDCOOPER||'- Cooperativa/Operador atual não existente';
            ww_cdoperad_atu := :NEW.CDOPERAD||'- Cooperativa/Operador atual não existente';
      END;
    END IF;

  IF UPDATING THEN
    IF :NEW.tpevento  <> :OLD.tpevento THEN
     -- grava_historico('A','TPEVENTO',:OLD.tpevento,:NEW.tpevento );
      grava_historico('A','TPEVENTO',ww_tpevento_ant,ww_tpevento_atu );
    END IF;

    IF :NEW.qtmaxtur         <> :OLD.qtmaxtur THEN
      grava_historico('A','QTMAXTUR',:OLD.qtmaxtur,:NEW.qtmaxtur );
    END IF;

    IF :NEW.qtmintur         <> :OLD.qtmintur THEN
      grava_historico('A','QTMINTUR',:OLD.qtmintur,:NEW.qtmintur );
    END IF;

    IF :NEW.tppartic         <> :OLD.tppartic THEN
      --grava_historico('A','TPPARTIC',:OLD.tppartic,:NEW.tppartic );
      grava_historico('A','TPPARTIC',ww_tppartic_ant,ww_tppartic_atu );
    END IF;

    IF :NEW.qtparcta         <> :OLD.qtparcta THEN
      grava_historico('A','QTPARCTA',:OLD.qtparcta,:NEW.qtparcta );
    END IF;

    IF :NEW.flgcompr         <> :OLD.flgcompr THEN
      --grava_historico('A','FLGCOMPR',:OLD.flgcompr,:NEW.flgcompr );
      grava_historico('A','FLGCOMPR',ww_flgcompr_ant,ww_flgcompr_atu );
    END IF;

    IF :NEW.flgtdpac         <> :OLD.flgtdpac THEN
      --grava_historico('A','FLGTDPAC',:OLD.flgtdpac,:NEW.flgtdpac );
      grava_historico('A','FLGTDPAC',ww_flgtdpac_ant,ww_flgtdpac_atu );

    END IF;

    IF :NEW.flgcerti         <> :OLD.flgcerti THEN
      --grava_historico('A','FLGCERTI',:OLD.flgcerti,:NEW.flgcerti );
      grava_historico('A','FLGCERTI',ww_flgcerti_ant,ww_flgcerti_atu );

    END IF;

    IF :NEW.flgrestr         <> :OLD.flgrestr THEN
      --grava_historico('A','FLGRESTR',:OLD.flgrestr,:NEW.flgrestr );
            grava_historico('A','FLGRESTR',ww_flgrestr_ant,ww_flgrestr_atu );
    END IF;

    IF :NEW.flgativo         <> :OLD.flgativo THEN
      --grava_historico('A','FLGATIVO',:OLD.flgativo,:NEW.flgativo );
      grava_historico('A','FLGATIVO',ww_flgativo_ant,ww_flgativo_atu );
    END IF;

    IF :NEW.flgsorte         <> :OLD.flgsorte THEN
      --grava_historico('A','FLGSORTE',:OLD.flgsorte,:NEW.flgsorte );
      grava_historico('A','FLGSORTE',ww_flgsorte_ant,ww_flgsorte_atu );
    END IF;

    IF :NEW.nridamin         <> :OLD.nridamin THEN
      grava_historico('A','NRIDAMIN',:OLD.nridamin,:NEW.nridamin );
    END IF;

    IF :NEW.prfreque         <> :OLD.prfreque THEN
      grava_historico('A','PRFREQUE',:OLD.prfreque,:NEW.prfreque );
    END IF;

    IF :NEW.cdeixtem         <> :OLD.cdeixtem THEN
      --grava_historico('A','CDEIXTEM',:OLD.cdeixtem,:NEW.cdeixtem );
      grava_historico('A','CDEIXTEM',ww_cdeixtem_ant,ww_cdeixtem_atu );
    END IF;

    IF :NEW.nmevento         <> :OLD.nmevento THEN
      grava_historico('A','NMEVENTO',:OLD.nmevento,:NEW.nmevento );
    END IF;

    IF :NEW.dtlibint         <> :OLD.dtlibint THEN
      grava_historico('A','DTLIBINT',:OLD.dtlibint,:NEW.dtlibint );
    END IF;

    IF :NEW.dtretint         <> :OLD.dtretint THEN
      grava_historico('A','DTRETINT',:OLD.dtretint,:NEW.dtretint );
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
      grava_historico('A','NRSEQPRI',ww_nrseqpri_ant,ww_nrseqpri_atu);
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

    --DSJUSTIF
    IF :NEW.DSJUSTIF   <> :OLD.DSJUSTIF THEN
      grava_historico('A','DSJUSTIF',:OLD.DSJUSTIF,:NEW.DSJUSTIF );
    END IF;

    IF :NEW.qtdiaeve         <> :OLD.qtdiaeve THEN
      grava_historico('A','QTDIAEVE',:OLD.qtdiaeve,:NEW.qtdiaeve );
    END IF;
    --IDRESPUB
    IF :NEW.IDRESPUB         <> :OLD.IDRESPUB THEN
      grava_historico('A','IDRESPUB',ww_idrespub_ant,ww_idrespub_atu );
    END IF;

  ELSIF DELETING THEN
      grava_historico('E','TPEVENTO',ww_tpevento_ant,'' );--:OLD.tpevento,'' );
      grava_historico('E','QTMAXTUR',:OLD.qtmaxtur,'' );
      grava_historico('E','QTMINTUR',:OLD.qtmintur,'' );
      grava_historico('E','TPPARTIC',ww_tppartic_ant,'' ); --:OLD.tppartic,'' );
      grava_historico('E','QTPARCTA',:OLD.qtparcta,'' );
      grava_historico('E','FLGCOMPR',ww_flgcompr_ant,'' );--:OLD.flgcompr,'' );
      grava_historico('E','FLGTDPAC',ww_flgtdpac_ant,'' );--:OLD.flgtdpac,'' );
      grava_historico('E','FLGCERTI',ww_flgcerti_ant,'' );--:OLD.flgcerti,'' );
      grava_historico('E','FLGRESTR',ww_flgrestr_ant,'' );--:OLD.flgrestr,'' );
      grava_historico('E','FLGATIVO',ww_flgativo_ant,'' );--:OLD.flgativo,'' );
      grava_historico('E','FLGSORTE',ww_flgsorte_ant,'' );--:OLD.flgsorte,'' );
      grava_historico('E','NRIDAMIN',:OLD.nridamin,'' );
      grava_historico('E','PRFREQUE',:OLD.prfreque,'' );
      grava_historico('E','CDEIXTEM',ww_cdeixtem_ant,'' );--:OLD.cdeixtem,'' );
      grava_historico('E','NMEVENTO',:OLD.nmevento,'' );
      grava_historico('E','DTLIBINT',:OLD.dtlibint,'' );
      grava_historico('E','DTRETINT',:OLD.dtretint,'' );
      grava_historico('E','NRSEQPRI',ww_nrseqpri_ant,'' );--:OLD.NRSEQPRI,'' );
      grava_historico('E','NRSEQTEM',ww_nrseqtem_ant,'' );--:OLD.NRSEQTEM,'' );
      grava_historico('E','CDOPERAD',ww_cdoperad_ant,'' );--:OLD.CDOPERAD,'' );
      grava_historico('E','DSJUSTIF',:OLD.DSJUSTIF,'' );
      grava_historico('E','QTDIAEVE',:OLD.QTDIAEVE,'' );
      grava_historico('E','CDCOPOPE',ww_cdcopope_ant,'' );--:OLD.CDCOPOPE,'' );
      grava_historico('E','IDRESPUB',ww_idrespub_ant,'' );
  END IF;

END TRG_HISTORICO_CRAPEDP;
