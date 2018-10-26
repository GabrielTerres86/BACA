CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_CRAPADP
  AFTER UPDATE OR DELETE ON crapadp
  FOR EACH ROW
DECLARE
  CURSOR cr_crapedp(pr_idevento crapedp.idevento%TYPE
                   ,pr_cdcooper crapedp.cdcooper%TYPE
                   ,pr_dtanoage crapedp.dtanoage%TYPE
                   ,pr_cdevento crapedp.cdevento%TYPE) IS
    SELECT edp.nmevento
          ,cop.nmrescop
          ,edp.tpevento
      FROM crapedp edp
          ,crapcop cop
     WHERE edp.idevento = pr_idevento
       AND edp.cdcooper = pr_cdcooper
       AND edp.dtanoage = pr_dtanoage
       AND edp.cdevento = pr_cdevento
       AND cop.cdcooper = edp.cdcooper;

  rw_crapedp cr_crapedp%ROWTYPE;

  CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                   ,pr_cdagenci crapage.cdagenci%TYPE) IS
    SELECT cop.nmrescop AS nmrescop
          ,NVL(age.nmresage,'TODOS') AS nmresage
    FROM crapcop cop
        ,crapage age
    WHERE cop.cdcooper = pr_cdcooper
      AND cop.cdcooper = age.cdcooper(+)
      AND age.cdagenci(+) = pr_cdagenci;

  rw_crapage cr_crapage%ROWTYPE;

  CURSOR cr_crapppc(pr_idevento crapppc.idevento%TYPE
                   ,pr_dtanoage crapppc.dtanoage%TYPE
                   ,pr_cdcooper crapppc.cdcooper%TYPE) IS

    SELECT ppc.dsemlace
      FROM crapppc ppc
     WHERE ppc.idevento = pr_idevento
       AND ppc.dtanoage = pr_dtanoage
       AND ppc.cdcooper = pr_cdcooper;

  rw_crapppc cr_crapppc%ROWTYPE;
  
  -- Início Chamado PRB0040122 - Erro tela de Inscrições
  CURSOR cr_crapagp IS
    SELECT count(*) qt_registros
      FROM crapagp c
     WHERE c.idevento = :new.idevento
       AND c.dtanoage = :new.dtanoage
       AND c.cdcooper = :new.cdcooper
       AND c.cdagenci <>:new.cdagenci
       AND c.idstagen = 5;

  rw_crapagp cr_crapagp%ROWTYPE;
  --Fim Chamado PRB0040122 - Erro tela de Inscrições
  
  ww_cdlocali_ant VARCHAR2(100);
  ww_cdlocali_atu VARCHAR2(100);
  
  ww_cdabrido_ant VARCHAR2(100);
  ww_cdabrido_atu VARCHAR2(100);

  ww_idstaeve_ant VARCHAR2(100);
  ww_idstaeve_atu VARCHAR2(100);

  ww_nrseqtem_ant VARCHAR2(100);
  ww_nrseqtem_atu VARCHAR2(100);

  ww_nrseqpri_ant VARCHAR2(100);
  ww_nrseqpri_atu VARCHAR2(100);

  ww_cdcopope_ant VARCHAR2(100);
  ww_cdcopope_atu VARCHAR2(100);

  ww_cdoperad_ant VARCHAR2(100);
  ww_cdoperad_atu VARCHAR2(100);

  ww_idfimava_ant VARCHAR2(100);
  ww_idfimava_atu VARCHAR2(100);

  ww_nrseqfea_ant VARCHAR2(100);
  ww_nrseqfea_atu VARCHAR2(100);

  vr_texto_email VARCHAR2(4000) := NULL;
  vr_conteudo    VARCHAR2(4000) := NULL;
  vr_cdcritic    crapcri.cdcritic%TYPE := 0;
  vr_dscritic    crapcri.dscritic%TYPE := '';

  vr_cdprogra  VARCHAR2(40) := 'TRG_HISTORICO_ADP';
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;

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
  aux_campo VARCHAR2(100)  := nm_campo;
  aux_dtatuali DATE;

  BEGIN

    SELECT DECODE(:OLD.IDFIMAVA, 0, 'NÃO', 1, 'SIM', ' ')
        ,DECODE(:NEW.IDFIMAVA, 0, 'NÃO', 1, 'SIM', ' ')
    INTO ww_idfimava_ant
        ,ww_idfimava_atu
    FROM DUAL;
    
    BEGIN
      SELECT TRIM(substr(NVL(a.COMMENTS,nm_campo),1,100))
        INTO aux_campo
        FROM all_col_comments a
       WHERE a.TABLE_NAME = 'CRAPADP'
         AND a.COLUMN_NAME = nm_campo;
    EXCEPTION
      WHEN OTHERS THEN
        aux_campo:=nm_campo;
    END;
 
    IF id_acao = 'A' then -- Alteração
      wr_idevento := :NEW.IDEVENTO;
      wr_cdcooper := :NEW.CDCOOPER;
      wr_dtanoage := :NEW.DTANOAGE;
      wr_cdevento := :NEW.CDEVENTO;
      wr_cdagenci := :NEW.CDAGENCI;
      wr_nrseqdig := :NEW.NRSEQDIG;
      wr_cdcopope := :NEW.CDCOPOPE;
      wr_cdoperad := :NEW.CDOPERAD;

      vr_texto_email := vr_texto_email || '<tr><td>' || aux_campo || '</td><td>' || vl_anterior || '</td><td>' || vl_atual || '</td></tr>';
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
      aux_dtatuali := SYSDATE;

      BEGIN
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
               VALUES(wr_idevento,
                      wr_cdcooper,
                      wr_dtanoage,
                      wr_cdevento,
                      wr_cdagenci,
                      wr_nrseqdig,
                      nm_campo,
                      aux_dtatuali,
                      nvl(vl_anterior, ' '),
                      nvl(vl_atual,' '),
                      wr_hratuali,
                      wr_cdcopope,
                      wr_cdoperad);
       EXCEPTION
         WHEN dup_val_on_index THEN
           UPDATE craphea
              SET DSANTCMP = nvl(vl_anterior, ' ')
                 ,DSATUCMP = nvl(vl_atual,' ')
                 ,hratuali = wr_hratuali
                 ,CDCOPOPE = wr_cdcopope
                 ,CDOPERAD = wr_cdoperad
            WHERE IDEVENTO = wr_idevento
              AND CDCOOPER = wr_cdcooper
              AND DTANOAGE = wr_dtanoage
              AND CDEVENTO = wr_cdevento
              AND CDAGENCI = wr_cdagenci
              AND NRSEQDIG = wr_nrseqdig
              AND NMDCAMPO = nm_campo
              AND DTATUALI = aux_dtatuali;
  END;
  END;
BEGIN

    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

    pc_log_programa(PR_DSTIPLOG   => 'O'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_dsmensagem => 'OLD CDLOCALI: ' || to_CHAR(NVL(:OLD.cdlocali,0))
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)


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
            CL.IDEVENTO = 1
        AND CL.CDCOOPER = :OLD.CDCOOPER
        --AND CL.CDAGENCI = :OLD.CDAGENCI
        AND CL.NRSEQDIG = :OLD.CDLOCALI
        AND ROWNUM = 1;
        exception
          when no_data_found then
            ww_cdlocali_ant:= :OLD.CDLOCALI||' - '||'NÃO CADASTRADA';
            pc_log_programa(PR_DSTIPLOG   => 'O'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_dsmensagem => 'ERRO CDLOCALI OLD '
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)
        end;
    END IF;


    pc_log_programa(PR_DSTIPLOG   => 'O'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_dsmensagem => 'NEW CDLOCALI: ' || to_CHAR(NVL(:NEW.cdlocali,0))
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

    IF NVL(:NEW.cdlocali,0) <> 0 THEN
      begin
      SELECT
            CL.NRSEQDIG||'-'||CL.DSLOCALI
      INTO
            ww_cdlocali_atu
      FROM
            CRAPLDP CL
      WHERE
            CL.IDEVENTO = 1
        AND CL.CDCOOPER = :NEW.CDCOOPER
        --AND CL.CDAGENCI = :NEW.CDAGENCI
        AND CL.NRSEQDIG = :NEW.CDLOCALI
        AND ROWNUM = 1;
        exception
          when no_data_found then
            ww_cdlocali_atu:= :NEW.CDLOCALI||' - '||'NÃO CADASTRADA';
            pc_log_programa(PR_DSTIPLOG   => 'O'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_dsmensagem => 'ERRO CDLOCALI NEW '
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)
        end;        
    END IF;

    pc_log_programa(PR_DSTIPLOG   => 'O'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_dsmensagem => 'SAIU CDLOCALI: ' || to_CHAR(NVL(:NEW.cdlocali,0))
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

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

    OPEN cr_crapedp(pr_idevento => :NEW.IDEVENTO
                   ,pr_cdcooper => :NEW.CDCOOPER
                   ,pr_dtanoage => :NEW.DTANOAGE
                   ,pr_cdevento => :NEW.CDEVENTO);

    FETCH cr_crapedp INTO rw_crapedp;

    OPEN cr_crapage(pr_cdcooper => :NEW.CDCOOPER
                   ,pr_cdagenci => :NEW.CDAGENCI);

    FETCH cr_crapage INTO rw_crapage;

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

    IF NVL(:NEW.dtinieve,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtinieve,TO_DATE('01/01/1900','dd/mm/RRRR')) THEN
      grava_historico('A','DTINIEVE',to_char(:OLD.dtinieve,'dd/mm/RRRR'), to_char(:NEW.dtinieve,'dd/mm/RRRR'));
    -- Início Chamado PRB0040122 - Erro tela de Inscrições
    -- Verificar se já existem registros na tabela crapagp onde o status já esteja como 5 e o PA seja diferente do atual
    OPEN cr_crapagp;
    FETCH cr_crapagp INTO rw_crapagp;    
      IF rw_crapagp.qt_registros > 0 THEN
        -- Se já existem registros com status 5 em outros PAs, altera o status deste PA para 5 se o status estiver como 3
        UPDATE
              crapagp c
           SET
              c.idstagen = 5
         WHERE 
              c.idevento = :new.idevento
          AND c.dtanoage = :new.dtanoage
          AND c.cdcooper = :new.cdcooper
          AND c.cdagenci = :new.cdagenci
          AND c.idstagen = 3;
      END IF;
    -- Fim Chamado PRB0040122 - Erro tela de Inscrições      
    END IF;

    IF NVL(:NEW.dtfineve,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtfineve,TO_DATE('01/01/1900','dd/mm/RRRR')) THEN
      grava_historico('A','DTFINEVE',to_char(:OLD.dtfineve,'dd/mm/RRRR'),to_char(:NEW.dtfineve,'dd/mm/RRRR'));
    END IF;

    IF (NVL(:NEW.dtinieve,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtinieve,TO_DATE('01/01/1900','dd/mm/RRRR'))) OR
       (NVL(:NEW.dtfineve,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtfineve,TO_DATE('01/01/1900','dd/mm/RRRR'))) THEN
      
      IF rw_crapedp.tpevento = 8  OR rw_crapedp.tpevento = 13 OR
         rw_crapedp.tpevento = 14 OR rw_crapedp.tpevento = 15 OR rw_crapedp.tpevento = 16 THEN  

        PROGRID.ASSE0001.pc_envia_email_data_evento(pr_cdcooper => :NEW.cdcooper       --> Código da Cooperativa
                                                   ,pr_cdagenci => :NEW.cdagenci       --> Código do PA
                                                   ,pr_nmevento => rw_crapedp.nmevento --> Nome do Evento
                                                   ,pr_dtinieve => :NEW.Dtinieve       --> Data de Início do Evento
                                                   ,pr_dtfimeve => :NEW.dtfineve       --> Data de Fim do Evento
                                                   ,pr_cdcritic => vr_cdcritic         --> Código da Crítica
                                                   ,pr_dscritic => vr_dscritic);       --> Descrição da Crítica

        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          pc_log_programa(pr_dstiplog      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                         ,pr_cdprograma    => vr_cdprogra   --> Codigo do programa ou do job
                         ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          -- Parametros para Ocorrencia
                         ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                         ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                         ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                         ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                         ,pr_idprglog      => vr_idprglog); --> Identificador unico da tabela (sequence)
        END IF;
      END IF;
    END IF;

    IF :NEW.dshroeve         <> :OLD.dshroeve THEN
      grava_historico('A','DSHROEVE',:OLD.dshroeve,:NEW.dshroeve );
    END IF;

    IF :NEW.dsdiaeve         <> :OLD.dsdiaeve THEN
      grava_historico('A','DSDIAEVE',:OLD.dsdiaeve,:NEW.dsdiaeve );
    END IF;

    IF :NEW.idstaeve         <> :OLD.idstaeve THEN
      grava_historico('A','IDSTAEVE',ww_idstaeve_ant,ww_idstaeve_atu );
    END IF;


    IF NVL(:NEW.dtmvtolt,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtmvtolt,TO_DATE('01/01/1900','dd/mm/RRRR')) THEN
      grava_historico('A','DTMVTOLT',to_char(:OLD.dtmvtolt,'dd/mm/RRRR'),to_char(:NEW.dtmvtolt,'dd/mm/RRRR'));
    END IF;

    IF :NEW.qtdiaeve         <> :OLD.qtdiaeve THEN
      grava_historico('A','QTDIAEVE',:OLD.qtdiaeve,:NEW.qtdiaeve );
    END IF;

    IF NVL(:NEW.dtlibint,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtlibint,TO_DATE('01/01/1900','dd/mm/RRRR')) THEN
      grava_historico('A','DTLIBINT',to_char(:OLD.dtlibint,'dd/mm/RRRR'),to_char(:NEW.dtlibint,'dd/mm/RRRR'));
    END IF;

    IF NVL(:NEW.dtretint,TO_DATE('01/01/1900','dd/mm/RRRR')) <> NVL(:OLD.dtretint,TO_DATE('01/01/1900','dd/mm/RRRR')) THEN
      grava_historico('A','DTRETINT',to_char(:OLD.dtretint,'dd/mm/RRRR'),to_char(:NEW.dtretint,'dd/mm/RRRR'));
    END IF;

    IF :NEW.nrmesage         <> :OLD.nrmesage THEN
      grava_historico('A','NRMESAGE',:OLD.nrmesage,:NEW.nrmesage );
    END IF;

    --Campos novos para inclusão após criação dos mesmos na tabela:
    --NRSEQTEM
    IF :NEW.NRSEQTEM   <> :OLD.NRSEQTEM THEN
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
      grava_historico('A','CDOPERAD',ww_cdoperad_ant,ww_cdoperad_atu );
    END IF;

    --CDCOPOPE
    IF :NEW.CDCOPOPE <> :OLD.CDCOPOPE THEN
       grava_historico('A','CDCOPOPE',ww_cdcopope_ant,ww_cdcopope_atu);
    END IF;
    
    --IDFIMAVA
    IF :NEW.IDFIMAVA <> :OLD.IDFIMAVA THEN
       grava_historico('A','IDFIMAVA',:OLD.IDFIMAVA,:NEW.IDFIMAVA);
    END IF;

    --NRCPFCGC
    IF :NEW.NRCPFCGC <> :OLD.NRCPFCGC THEN
       grava_historico('A','NRCPFCGC',:OLD.NRCPFCGC,:NEW.NRCPFCGC);
    END IF;

    --NRPROPOS
    IF :NEW.NRPROPOS <> :OLD.NRPROPOS THEN
       grava_historico('A','NRPROPOS',:OLD.NRPROPOS,:NEW.NRPROPOS);
    END IF;

    --NRDOCFMD
    IF :NEW.NRDOCFMD <> :OLD.NRDOCFMD THEN
       grava_historico('A','NRDOCFMD',:OLD.NRDOCFMD,:NEW.NRDOCFMD);
    END IF;

    --VLHONEVE
    IF :NEW.VLHONEVE <> :OLD.VLHONEVE THEN
       grava_historico('A','VLHONEVE',:OLD.VLHONEVE,:NEW.VLHONEVE);
    END IF;

    --VLLOCEVE
    IF :NEW.VLLOCEVE <> :OLD.VLLOCEVE THEN
       grava_historico('A','VLLOCEVE',:OLD.VLLOCEVE,:NEW.VLLOCEVE);
    END IF;

    --VLALIEVE
    IF :NEW.VLALIEVE <> :OLD.VLALIEVE THEN
       grava_historico('A','VLALIEVE',:OLD.VLALIEVE,:NEW.VLALIEVE);
    END IF;    

    --VLMATEVE
    IF :NEW.VLMATEVE <> :OLD.VLMATEVE THEN
       grava_historico('A','VLMATEVE',:OLD.VLMATEVE,:NEW.VLMATEVE);
    END IF;

    --VLTRAEVE
    IF :NEW.VLTRAEVE <> :OLD.VLTRAEVE THEN
       grava_historico('A','VLTRAEVE',:OLD.VLTRAEVE,:NEW.VLTRAEVE);
    END IF;

    --VLBRIEVE
    IF :NEW.VLBRIEVE <> :OLD.VLBRIEVE THEN
       grava_historico('A','VLBRIEVE',:OLD.VLBRIEVE,:NEW.VLBRIEVE);
    END IF;

    --VLDIVEVE
    IF :NEW.VLDIVEVE <> :OLD.VLDIVEVE THEN
       grava_historico('A','VLDIVEVE',:OLD.VLDIVEVE,:NEW.VLDIVEVE);
    END IF;

    --VLOUTEVE
    IF :NEW.VLOUTEVE <> :OLD.VLOUTEVE THEN
       grava_historico('A','VLOUTEVE',:OLD.VLOUTEVE,:NEW.VLOUTEVE);
    END IF;

    --VLTEREVE
    IF :NEW.VLTEREVE <> :OLD.VLTEREVE THEN
       grava_historico('A','VLTEREVE',:OLD.VLTEREVE,:NEW.VLTEREVE);
    END IF;

    --PRDESCON
    IF :NEW.PRDESCON <> :OLD.PRDESCON THEN
       grava_historico('A','PRDESCON',:OLD.PRDESCON,:NEW.PRDESCON);
    END IF;

    --NRSEQINT
    IF :NEW.NRSEQINT <> :OLD.NRSEQINT THEN
       grava_historico('A','NRSEQINT',:OLD.NRSEQINT,:NEW.NRSEQINT);
    END IF;

    --QTPARPRE
    IF :NEW.QTPARPRE <> :OLD.QTPARPRE THEN
       grava_historico('A','QTPARPRE',:OLD.QTPARPRE,:NEW.QTPARPRE);

       PROGRID.ASSE0001.pc_envia_email_qtd_part(pr_cdcooper => :NEW.cdcooper       --> Código da Cooperativa
                                               ,pr_cdagenci => :NEW.cdagenci       --> Código do PA
                                               ,pr_nmevento => rw_crapedp.nmevento --> Nome do Evento
                                               ,pr_qtturant => :OLD.QTPARPRE       --> Quantidade de Participantes Anterior
                                               ,pr_qtturatu => :NEW.QTPARPRE       --> Quantidade de Participantes Atual
                                               ,pr_dtinieve => :NEW.DTINIEVE       --> Data de Inicio de Evento
                                               ,pr_cdcritic => vr_cdcritic         --> Código da Crítica
                                               ,pr_dscritic => vr_dscritic);       --> Descrição da Crítica

      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        pc_log_programa(pr_dstiplog      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,pr_cdprograma    => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                       ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                       ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                       ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                       ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
      END IF;
    END IF;

    --DSOBSLOC
    IF :NEW.DSOBSLOC <> :OLD.DSOBSLOC THEN
       grava_historico('A','DSOBSLOC',SUBSTR(:OLD.DSOBSLOC,1,100),SUBSTR(:NEW.DSOBSLOC,1,100));
    END IF;

    --VLRECEVE
    IF :NEW.VLRECEVE <> :OLD.VLRECEVE THEN
       grava_historico('A','VLRECEVE',:OLD.VLRECEVE,:NEW.VLRECEVE);
    END IF;

    -- Incluir no histórico o nome do facilitador
    IF NVL(:OLD.NRSEQFEA,0) <> 0 THEN
      BEGIN
        SELECT CF.NRSEQFEA||'-'||CF.NMFACILI
          INTO ww_NRSEQFEA_ant
          FROM CRAPFEA CF
         WHERE CF.NRSEQFEA = :OLD.NRSEQFEA;
      EXCEPTION
        WHEN no_data_found THEN
          ww_NRSEQFEA_ant:= 'Facilitador = '||:OLD.NRSEQFEA||' - '||'NÃO CADASTRADO';
      END;
    END IF; 

    IF NVL(:NEW.NRSEQFEA,0) <> 0 THEN
      BEGIN
        SELECT CF.NRSEQFEA||'-'||CF.NMFACILI
          INTO ww_NRSEQFEA_atu
          FROM CRAPFEA CF
         WHERE CF.NRSEQFEA = :NEW.NRSEQFEA;
      EXCEPTION
        WHEN no_data_found THEN
          ww_NRSEQFEA_atu:= 'Facilitador = '||:NEW.NRSEQFEA||' - '||'NÃO CADASTRADO';
      END;
    END IF;

    --NRSEQFEA
    IF :NEW.NRSEQFEA <> :OLD.NRSEQFEA THEN
       grava_historico('A','NRSEQFEA',WW_NRSEQFEA_ANT,WW_NRSEQFEA_ATU);
    END IF;

    --NRSEQFEA
    IF :NEW.NRSEQFEA <> :OLD.NRSEQFEA THEN
       grava_historico('A','NRSEQFEA',:OLD.NRSEQFEA,:NEW.NRSEQFEA);
    END IF;

    -- EMAIL
    IF vr_texto_email IS NOT NULL AND :NEW.IDEVENTO = 2 THEN

      OPEN cr_crapppc(pr_idevento => 1
                     ,pr_dtanoage => :NEW.DTANOAGE
                     ,pr_cdcooper => :NEW.CDCOOPER);

      FETCH cr_crapppc INTO rw_crapppc;

      vr_conteudo := '<b>ATENÇÃO!</b>' ||
                     '<br>O evento ' || rw_crapedp.nmevento || '  do dia: ' || NVL(TO_CHAR(:NEW.dtinieve),'Data inicial do evento não informada') ||
                     '<br>da Cooperativa ' || rw_crapage.nmrescop || ' e do PA: ' || rw_crapage.nmresage || ' foi alterado.' || 
                     '<br><br>' ||
                     '<table>' || 
                     '<tr><td><b>Campo Alterado</b></td><td><b>Valor Anterior</b></td><td><b>Valor Atual</b></td></tr>' ||
                     vr_texto_email ||
                     '</table>';
        
      vr_dscritic := NULL;
                                      
      gene0003.pc_solicita_email(pr_cdcooper        => :NEW.CDCOOPER
                                ,pr_cdprogra        => 'PROGRID'
                                ,pr_des_destino     => rw_crapppc.dsemlace
                                ,pr_des_assunto     => 'Alteração de Evento Assemblear'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                       ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                       ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                       ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                       ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
      END IF;

    END IF;
   
  ELSIF DELETING THEN

      grava_historico('E','CDLOCALI',ww_cdlocali_ant,' ' );--:OLD.cdlocali,'' );
      grava_historico('E','CDABRIDO',ww_cdabrido_ant,' ' );--:OLD.cdabrido,'' );
      grava_historico('E','NRMESEVE',:OLD.nrmeseve,' ' );
      grava_historico('E','DTINIEVE',:OLD.dtinieve,' ' );
      grava_historico('E','DTFINEVE',:OLD.dtfineve,' ' );
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
	    grava_historico('E','NRCPFCGC',:OLD.NRCPFCGC,' ');
      grava_historico('E','NRPROPOS',:OLD.NRPROPOS,' ');
      grava_historico('E','NRDOCFMD',:OLD.NRDOCFMD,' ');
      grava_historico('E','VLHONEVE',:OLD.VLHONEVE,' ');
      grava_historico('E','VLLOCEVE',:OLD.VLLOCEVE,' ');
      grava_historico('E','VLALIEVE',:OLD.VLALIEVE,' ');
      grava_historico('E','VLMATEVE',:OLD.VLMATEVE,' ');
      grava_historico('E','VLTRAEVE',:OLD.VLTRAEVE,' ');
      grava_historico('E','VLBRIEVE',:OLD.VLBRIEVE,' ');
      grava_historico('E','VLDIVEVE',:OLD.VLDIVEVE,' ');
      grava_historico('E','VLOUTEVE',:OLD.VLOUTEVE,' ');
      grava_historico('E','VLTEREVE',:OLD.VLTEREVE,' ');
      grava_historico('E','PRDESCON',:OLD.PRDESCON,' ');
      grava_historico('E','NRSEQINT',:OLD.NRSEQINT,' ');
      grava_historico('E','QTPARPRE',:OLD.QTPARPRE,' ');
      grava_historico('E','NRSEQFEA',:OLD.NRSEQFEA,' ');
      grava_historico('E','DSOBSLOC',:OLD.DSOBSLOC,' ');
      grava_historico('E','VLRECEVE',:OLD.VLRECEVE,' ');
  END IF;

  pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  -- Parametros para Ocorrencia
                 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence) 

END TRG_HISTORICO_CRAPADP;
/
