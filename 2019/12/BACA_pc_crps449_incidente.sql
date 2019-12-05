
declare
pr_stprogra BINARY_INTEGER;
pr_infimsol BINARY_INTEGER;
pr_cdcritic NUMBER(10);
pr_dscritic VARCHAR2(2000);

  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT to_date('03/12/2019','dd/mm/yyyy') dtmvtolt
          ,to_date('04/12/2019','dd/mm/yyyy') dtmvtopr
          ,to_date('02/12/2019','dd/mm/yyyy') dtmvtoan
          ,3 inproces
          ,21 qtdiaute
          ,'CRPS423' cdprgant
          ,to_date('03/12/2019','dd/mm/yyyy') dtmvtocd
          ,trunc(to_date('03/12/2019','dd/mm/yyyy'),'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(to_date('03/12/2019','dd/mm/yyyy'),1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(to_date('03/12/2019','dd/mm/yyyy'),-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(to_date('03/12/2019','dd/mm/yyyy'))                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;  

PROCEDURE pc_crps449_renato(pr_cdcooper IN crapcop.cdcooper%TYPE     --> COOPERATIVA SOLICITADA
                                      ,pr_flgresta IN PLS_INTEGER               --> FLAG PADRÃO PARA UTILIZAÇÃO DE RESTART
                                      ,pr_stprogra OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA EXECUÇÃO
                                      ,pr_infimsol OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA SOLICITAÇÃO
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> CRITICA ENCONTRADA
                                      ,pr_dscritic OUT VARCHAR2) IS             --> TEXTO DE ERRO/CRITICA ENCONTRADA
BEGIN


  DECLARE

    -- CÓDIGO DO PROGRAMA
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS449';

    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    vr_dtproxim crapdat.dtmvtopr%TYPE; -- PROXIMA DATA UTIL

    vr_dscdiren VARCHAR(100); -- DIRETORIO DE COPIA DE ARQUIVO
    vr_nmempres VARCHAR(100); -- NOME DA EMPRESA
    vr_nmarqped VARCHAR(100);
    vr_nmarqdat VARCHAR(100);
    vr_nmarqrel VARCHAR(100);
    vr_nomdiret VARCHAR2(200) := ''; -- NOME DIRETORIO
    vr_strtexto VARCHAR2(4000) := '';

    vr_nrbranco INTEGER;
    vr_verifpac INTEGER;
    vr_nrseqdig INTEGER;

    vr_tiparqui INTEGER := 0; -- TIPO DE ARQUIVO

    vr_flgfirst BOOLEAN := FALSE; -- INDICADOR DE PRIMEIRO REGISTRO
    vr_flaglast BOOLEAN := FALSE; -- INDICADOR DE ULTIMO REGISTRO
    vr_exisdare BOOLEAN := FALSE; -- INDICADOR DE DARE EXISTENTE
    vr_exisgnre BOOLEAN := FALSE; -- INDICADOR DE GNRE EXISTENTE
    vr_flgproce BOOLEAN := FALSE; -- INDICADOR DE PROCESSO

    vr_xml      CLOB;
    vr_arq      CLOB;
    vr_textcomp VARCHAR2(32600) := '';
    vr_textarqu VARCHAR2(32600) := '';

    vr_vlfatura DECIMAL(25, 10); -- VALOR DE FATURA
    vr_vllanmto DECIMAL(25, 10); -- VALOR DE LANCAMENTO
    vr_vlapagar DECIMAL(25, 10); -- VALOR A PAGAR
    vr_vltottar gnconve.vltrfnet%TYPE; -- VALOR TOTAL DE TARIFAS
    vr_vltarifa gnconve.vltrfnet%TYPE; -- VALOR DE TARIFA
    vr_cdagenci crapage.cdagenci%TYPE; -- CODIGO DA AGENCIA
    vr_nrseqarq gnconve.nrseqcxa%TYPE; -- NUMERO DE SEQUENCIA DO ARQUIVO
    vr_cdconven gnconve.cdconven%TYPE; -- CODIGO DO CONVBNIO

    ------------------------------- CURSORES ---------------------------------

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop cr_crapcop%ROWTYPE;

    -- BUSCA DE MOVIMENTACAO DE CONVENIOS UNIFICADOS
    CURSOR cr_gncvuni(pr_tpdcontr IN gncvuni.tpdcontr%TYPE) IS

      SELECT uni.cdcooper,
             uni.dsmovtos,
             uni.cdconven,
             uni.tpdcontr,
             uni.flgproce,
             uni.rowid,
             ROW_NUMBER() OVER(PARTITION BY uni.cdconven, uni.cdcooper ORDER BY uni.cdconven, uni.cdcooper) AS seqlauto,
             Count(1) OVER(PARTITION BY uni.cdconven, uni.cdcooper) as seqlast
        FROM gncvuni uni
       WHERE uni.tpdcontr = pr_tpdcontr -- TIPO DE CONTROLE
         AND uni.flgproce = 0;          -- ARQUIVO PROCESSADO

    rw_gncvuni cr_gncvuni%ROWTYPE;

    -- BUSCA DE CONVENIOS
    CURSOR cr_gnconve(pr_cdconven IN gnconve.cdconven%TYPE) IS

      SELECT nve.cdconven,
             nve.nmempres,
             nve.cdcooper,
             nve.nrcnvfbr,
             nve.cddbanco,
             nve.vltrfnet,
             nve.vltrftaa,
             nve.vltrfcxa,
             nve.nrseqcxa,
             nve.tpdenvio,
             nve.nrseqatu,
             nve.nmarqcxa,
             nve.nmarqdeb,
             nve.nmarqatu,
             nve.dsendcxa,
             nve.dsenddeb,
             nve.vltrfdeb,
             nve.rowid
        FROM gnconve nve
       WHERE nve.cdconven = pr_cdconven; -- CODIGO DO CONVENIO

    rw_gnconve cr_gnconve%ROWTYPE;

    --------------------------- PROCEDURES INTERNAS --------------------------

    PROCEDURE pc_obtem_atualiza_sequencia(pr_contatip IN INTEGER                    --> TIPO DA CONTA
                                         ,pr_prorecid IN ROWID                      --> ROWID
                                         ,pr_cdconven IN gnconve.cdconven%TYPE      --> CODIGO DO CONVENIO
                                         ,pr_nrseqarq OUT gnconve.nrseqatu%TYPE) IS --> NR.SEQ.ARQ.ARRECADACAO
    /* .............................................................................
      Programa: pc_obtem_atualiza_sequencia
      Autor   : Jean Michel.
      Data    : 28/02/2014                     Ultima atualizacao: 31/03/2014

      Dados referentes ao programa:

      Objetivo   : Cria registro na gncontr (Tabela para Controle de Execucoes).

      Parametros : pr_contatip => Tipo de Conta
                   pr_prorecid => ROWID
                   pr_cdconven => Codigo do Convenio
                   pr_nrseqarq => Nr. Seq. Arq. Arrecadacao
      Premissa   :

      Alteracoes :

    ...............................................................................*/

    BEGIN
      DECLARE

        vr_nrseqarq INTEGER := 0; -- SEQUENCIA DE ARQUIVO

      BEGIN
        -- RECEBE CODIGO DE CONVENIO PASSADO POR PARAMETRO
        vr_cdconven := pr_cdconven;

        -- VERIFICA TIPO DA CONTA
        CASE pr_contatip
          WHEN 1 THEN -- CAIXA

            -- ATUALIZA REGISTRO DE CONVENIOS
            BEGIN
              UPDATE gnconve
                 SET gnconve.nrseqcxa = NVL(gnconve.nrseqcxa, 0) + 1
               WHERE gnconve.rowid = pr_prorecid -- ROWID
              RETURNING nrseqcxa - 1 INTO vr_nrseqarq; -- RETORNA NR.SEQ.ARQ.ARRECADACAO

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao atualizar registro na tabela GNCONVE: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- INSERE REGISTRO PARA CONTROLE DE EXECUCOES
          /*  BEGIN
              INSERT INTO gncontr
                (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen)
              VALUES
                (3, 1, pr_cdconven, rw_crapdat.dtmvtolt, vr_nrseqarq);

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao inserir registro na tabela GNCONTR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END; */

          WHEN 2 THEN -- DEB AUTOMATICO

            -- ATUALIZA REGISTRO DE CONVENIOS
            BEGIN
              UPDATE gnconve
                 SET nrseqatu = NVL(nrseqatu, 0) + 1
               WHERE gnconve.rowid = pr_prorecid -- ROWID
              RETURNING nrseqatu - 1 INTO vr_nrseqarq;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao atualizar registro na tabela GNCONVE: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- INSERE REGISTRO PARA CONTROLE DE EXECUCOES
          /*  BEGIN
              INSERT INTO gncontr
                (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen)
              VALUES
                (3, 4, pr_cdconven, rw_crapdat.dtmvtolt, vr_nrseqarq);

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao inserir registro na tabela GNCONTR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;*/

          WHEN 3 THEN -- AUTORIZACAO DE DEBITO

            -- ATUALIZA REGISTRO DE CONVENIOS
            BEGIN
              UPDATE gnconve
                 SET nrseqatu = NVL(nrseqatu, 0) + 1
               WHERE gnconve.rowid = pr_prorecid -- ROWID
              RETURNING nrseqatu - 1 INTO vr_nrseqarq; -- RETORNA NR. ARQUIVO DE ATU. CADAST

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao atualizar registro na tabela GNCONVE: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- INSERE REGISTRO PARA CONTROLE DE EXECUCOES
          /*  BEGIN
              INSERT INTO gncontr
                (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen)
              VALUES
                (3, 2, pr_cdconven, rw_crapdat.dtmvtolt, vr_nrseqarq);

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                pr_dscritic := 'Problema ao inserir registro na tabela GNCONTR: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;*/

        END CASE;

        pr_nrseqarq := vr_nrseqarq; -- PARAMETRO DE SAIDA COM SEQUENCIA DE ARQUIVO

      END;

    END pc_obtem_atualiza_sequencia;

    -------------------------------------------------------------------------------------------------

    PROCEDURE pc_nomeia_arquivos(pr_contatip IN INTEGER                --> TIPO DA CONTA
                                ,pr_cdcooper IN crapcop.cdcooper%TYPE  --> CODIGO DA COOPERATIVA
                                ,pr_nmarqcxa IN gnconve.nmarqcxa%TYPE  --> ARQUIVO DE ARRECADACAO
                                ,pr_nmarqdeb IN gnconve.nmarqdeb%TYPE  --> ARQUIVO DE DEBITOS
                                ,pr_nmarqatu IN gnconve.nmarqatu%TYPE  --> ARQUIVO DE ATU. CADASTRAL
                                ,pr_prorecid IN ROWID                  --> ROWID
                                ,pr_nrseqarq OUT gnconve.nrseqcxa%TYPE --> NR.SEQ.ARQ.ARRECADACAO
                                ,pr_nmarquiv OUT VARCHAR2              --> NOME ARQUIVO
                                ,pr_nmarqdat OUT VARCHAR2              --> NOME ARQUIVO
                                ,pr_nmarqped OUT VARCHAR2) IS          --> NOME ARQUIVO

      /* .............................................................................
      Programa: pc_nomeia_arquivos
      Autor   : Jean Michel.
      Data    : 28/02/2014                     Ultima atualizacao: 31/03/2014

      Dados referentes ao programa:

      Objetivo   : Retorna nomes de arquivos de relatorio.

      Parametros : pr_contatip --> TIPO DA CONTA
                   pr_cdcooper --> CODIGO DA COOPERATIVA
                   pr_nmarqcxa --> ARQUIVO DE ARRECADACAO
                   pr_nmarqdeb --> ARQUIVO DE DEBITOS
                   pr_nmarqatu --> ARQUIVO DE ATU. CADASTRAL
                   pr_prorecid --> ROWID
                   pr_nrseqarq --> NR.SEQ.ARQ.ARRECADACAO
                   pr_nmarquiv --> NOME ARQUIVO
                   pr_nmarqdat --> NOME ARQUIVO
                   pr_nmarqped --> NOME ARQUIVO

      Premissa   :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        vr_nrseqarq INTEGER := 0;

        -- BUSCA CADASTRO DOS LANCAMENTOS DE APLICACOES RDCA
        CURSOR cr_gncontr(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_tpdcontr IN gncontr.tpdcontr%TYPE,
                          pr_cdconven IN gnconve.cdconven%TYPE,
                          pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS

          SELECT nrsequen
            FROM gncontr ntr
           WHERE ntr.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
             AND ntr.tpdcontr = pr_tpdcontr  -- TIPO DE CONTROLE
             AND ntr.cdconven = pr_cdconven  -- CODIGO DO CONVENIO
             AND ntr.dtmvtolt = pr_dtmvtolt; -- NUMERO DA APLICACAO

        rw_gncontr cr_gncontr%ROWTYPE;

      BEGIN

        -- VERIFICA TIPO DE CONTA
        CASE pr_contatip

          WHEN 1 THEN -- ARREC.CAIXA
            pr_nmarquiv := pr_nmarqcxa; -- NOME ARQ. ARREC. CAIXA

            -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
            OPEN cr_gncontr(pr_cdcooper => 3,                    -- CODIGO DA COOPERATIVA
                            pr_tpdcontr => 1,                    -- TIPO DO CONTROLE
                            pr_cdconven => vr_cdconven,          -- CODIGO DO CONVENIO
                            pr_dtmvtolt => rw_crapdat.dtmvtolt); -- DATA DE MOVIMENTACAO ATUAL

            FETCH cr_gncontr
              INTO rw_gncontr;

            -- SE NÃO ENCONTRAR
            IF cr_gncontr%NOTFOUND THEN
              -- FECHAR O CURSOR
              CLOSE cr_gncontr;

              -- CRIA REGISTRO DE CONTROLE DE EXECUCOES
              pc_obtem_atualiza_sequencia(pr_contatip => pr_contatip   --> TIPO DA CONTA
                                         ,pr_prorecid => pr_prorecid   --> PROGRESS_RECID
                                         ,pr_cdconven => vr_cdconven   --> CODIGO DO CONVENIO
                                         ,pr_nrseqarq => vr_nrseqarq); --> NR.SEQ.ARQ.ARRECADACAO

            ELSE
              -- FECHAR O CURSOR
              CLOSE cr_gncontr;

              vr_nrseqarq := rw_gncontr.nrsequen; -- CODIGO DE SEQUENCIA DE ARQUIVO
            END IF;

          WHEN 2 THEN -- ARREC.DEB.AUTOM.

            pr_nmarquiv := pr_nmarqdeb; -- NOME DO ARQUIVO DE DEBITO

            -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
            OPEN cr_gncontr(pr_cdcooper => 3                     --> CODIGO DA COOPERATIVA
                           ,pr_tpdcontr => 4                     --> TIPO DE CONTROLE
                           ,pr_cdconven => vr_cdconven           --> CODIGO DO CONVENIO
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt); --> DATA DE MOVIMENTACAO ATUAL

            FETCH cr_gncontr
              INTO rw_gncontr;

            -- SE NÃO ENCONTRAR
            IF cr_gncontr%NOTFOUND THEN
              -- FECHAR O CURSOR
              CLOSE cr_gncontr;

              -- CRIA REGISTRO DE CONTROLE DE EXECUCOES
              pc_obtem_atualiza_sequencia(pr_contatip => pr_contatip   --> TIPO DA CONTA
                                         ,pr_prorecid => pr_prorecid   --> PROGRESS_RECID
                                         ,pr_cdconven => vr_cdconven   --> CODIGO DO CONVENIO
                                         ,pr_nrseqarq => vr_nrseqarq); --> NR.SEQ.ARQ.ARRECADACAO

            ELSE
              -- APENAS FECHAR O CURSOR
              CLOSE cr_gncontr;

              vr_nrseqarq := rw_gncontr.nrsequen; -- CODIGO DE SEQUENCIA DE ARQUIVO

            END IF;

          WHEN 3 THEN -- AUTORIZ DEB.

            pr_nmarquiv := pr_nmarqatu; -- NOME ARQ. AUTORIZ DEB.

            -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
            OPEN cr_gncontr(pr_cdcooper => 3                     -- CODIGO DA COOPERATIVA
                           ,pr_tpdcontr => 2                     -- TIPO DE CONTROLE
                           ,pr_cdconven => vr_cdconven           -- CODIGO DO CONVENIO
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt); -- NUMERO DA APLICACAO

            FETCH cr_gncontr
              INTO rw_gncontr;

            -- SE NÃO ENCONTRAR
            IF cr_gncontr%NOTFOUND THEN
              -- FECHAR O CURSOR
              CLOSE cr_gncontr;

              -- CRIA REGISTRO DE CONTROLE DE EXECUCOES
              pc_obtem_atualiza_sequencia(pr_contatip => pr_contatip   --> TIPO DA CONTA
                                         ,pr_prorecid => pr_prorecid   --> ROWID
                                         ,pr_cdconven => vr_cdconven   --> CODIGO DO CONVENIO
                                         ,pr_nrseqarq => vr_nrseqarq); --> NR.SEQ.ARQ.ARRECADACAO

            ELSE
              -- APENAS FECHAR O CURSOR
              CLOSE cr_gncontr;

              vr_nrseqarq := rw_gncontr.nrsequen; -- CODIGO DE SEQUENCIA DE ARQUIVO
            END IF;

        END CASE;

        -- MONTA NOME ARQUIVO
        IF UPPER(SUBSTR(pr_nmarquiv, 5, 4)) = 'MMDD' AND
           UPPER(SUBSTR(pr_nmarquiv, 10, 3)) = 'TXT' THEN

          vr_nmarqdat := TRIM(SUBSTR(pr_nmarquiv, 1, 4)) ||
                         TO_CHAR(rw_crapdat.dtmvtolt, 'mmdd') || '.txt';

        ELSIF UPPER(SUBSTR(pr_nmarquiv, 5, 4)) = 'DDMM' AND
              UPPER(SUBSTR(pr_nmarquiv, 10, 3)) = 'RET' THEN

          vr_nmarqdat := TRIM(SUBSTR(pr_nmarquiv, 1, 4)) ||
                         TO_CHAR(rw_crapdat.dtmvtolt, 'ddmm') || '.ret';

        ELSIF UPPER(SUBSTR(pr_nmarquiv, 5, 6)) = 'CPMMDD' AND
              UPPER(SUBSTR(pr_nmarquiv, 12, 3)) = 'SEQ' THEN

          vr_nmarqdat := TRIM(SUBSTR(pr_nmarquiv, 1, 4)) ||
                         gene0002.fn_mask(pr_cdcooper, '99') ||
                         TO_CHAR(rw_crapdat.dtmvtolt, 'mmdd') || '.' ||
                         SUBSTR(gene0002.fn_mask(vr_nrseqarq, '999999'),
                                4,
                                3);

        ELSIF UPPER(SUBSTR(pr_nmarquiv, 4, 5)) = 'CSEQU' AND
              UPPER(SUBSTR(pr_nmarquiv, 10, 3)) = 'RET' THEN

          vr_nmarqdat := TRIM(SUBSTR(pr_nmarquiv, 1, 3)) ||
                         gene0002.fn_mask(pr_cdcooper, '9') ||
                         SUBSTR(gene0002.fn_mask(vr_nrseqarq, '999999'),
                                3,
                                4) || '.' || 'ret';
        ELSE
          vr_nmarqdat := TRIM(SUBSTR(pr_nmarquiv, 1, 4)) ||
                         TO_CHAR(rw_crapdat.dtmvtolt, 'mmdd') || '.' ||
                         SUBSTR(gene0002.fn_mask(vr_nrseqarq, '999999'), 4, 3);
        END IF;

        -- NOME DO ARQUIVO
        pr_nmarqped := vr_nmarqdat;
        pr_nmarqdat := vr_nmarqdat;
        pr_nrseqarq := vr_nrseqarq;

      END;

    END pc_nomeia_arquivos;

    -------------------------------------------------------------------------------------

    PROCEDURE pc_atualiza_controle(pr_cdcooper IN crapcop.cdcooper%TYPE --> COOPERATIVA CONECTADA
                                  ,pr_tpdenvio IN INTEGER               --> TIPO DE ENVIO
                                  ,pr_nmarqdat IN VARCHAR2              --> NOME DO ARQUIVO
                                  ,pr_nmarqped IN VARCHAR2              --> NOME DO ARQUIVO
                                  ,pr_nmempres IN VARCHAR2              --> NOME DA EMPRESA
                                  ,pr_tpdcontr IN gncvuni.tpdcontr%TYPE --> TIPO DE CONTROLE
                                  ,pr_dsendcxa IN gnconve.dsendcxa%TYPE --> E-MAIL PARA ARQ. ARREC
                                  ,pr_dsenddeb IN gnconve.dsenddeb%TYPE --> E-MAIL PARA ARQ. DEBIT
                                   ) IS

      /* .............................................................................
      Programa: pc_atualiza_controle
      Autor   : Jean Michel.
      Data    : 05/03/2014                     Ultima atualizacao: 05/03/2014

      Dados referentes ao programa:

      Objetivo   : Efetua o envio dos arquivos por email

      Parametros : pr_cdcooper --> Cooperativa
                   pr_tpdenvio --> Tipo de Envio
                   pr_nmarqdat --> Nome do Arquivo
                   pr_nmarqped --> Nome do Arquivo
                   pr_nmempres --> Nome da Empresa
                   pr_tpdcontr --> Tipo de Controle
                   pr_dsendcxa --> E-mail para Arq. Arrec
                   pr_dsenddeb --> E-mail para Arq. Debit

      Premissa   :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        vr_nrentrie INTEGER := 0;
        vr_contador INTEGER := 1;

        vr_dsdemail VARCHAR2(500) := '';
        vr_dsdireto VARCHAR2(500) := '';

        vr_dsemail2 gnconve.dsendcxa%TYPE;

      BEGIN
        -- BUSCA DIRETORIO
        vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => pr_cdcooper);

        -- VERIFICA TIPO DE EMAIL
        IF pr_tpdenvio IN (1, 4) THEN -- 1,4 -> ENVIO POR EMAIL

          GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper   --> COOPERATIVA CONECTADA
                                      ,pr_nmarquiv => pr_nmarqped   --> CAMINHO E NOME DO ARQUIVO A SER CONVERTIDO
                                      ,pr_nmarqenv => pr_nmarqdat   --> NOME DESEJADO PARA O ARQUIVO CONVERTIDO
                                      ,pr_des_erro => vr_dscritic); --> DESCRICAO DE CRITICA DE ERRO

          -- VERIFICA SE OCORREU ERRO AO CONVERTER ARQUIVO
          IF vr_dscritic IS NOT NULL THEN
            -- CASO OCORREU ERRO NA CONVERSAO DE ARQUIVO, ABORTA O PROGRAMA
            RAISE vr_exc_saida;
          END IF;

          IF vr_cdconven = 21 THEN -- 21 ->CASA FELIZ

            gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper                   --> COOPERATIVA CONECTADA
                                 ,pr_dsorigem => pr_nmarqdat                   --> ARQUIVO A ZIPAR
                                 ,pr_tpfuncao => 'A'                           --> TIPO FUNÇÃO (A-ADD;E-EXTRACT;V-VIEW)
                                 ,pr_dsdestin => vr_dsdireto || 'converte/' ||
                                                 pr_nmarqdat || '.zip'         --> ARQUIVO FINAL .ZIP OU DESCOMPAC
                                 ,pr_dspasswd => 'casafeliz'                   --> SENHA DO ARQUIVO
                                 ,pr_des_erro => vr_dscritic);                 --> DESCRICAO DO ERRO

            -- VERIFICA SE OCORREU ERRO AO GERAR ZIP
            IF vr_dscritic IS NOT NULL THEN
              -- CASO OCORREU ERRO NO ZIP, ABORTA O PROGRAMA
              RAISE vr_exc_saida;
            END IF;

          END IF;

        END IF;

        vr_cdcritic := 657; -- INTRANET - TPDENVIO = 1

        -- VERIFICA TIPO DE ENVIO DE ARQUIVO
     /*   IF pr_tpdenvio IN (3) THEN

          vr_cdcritic := 748;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          -- DIRETORIO P/ ONDE SERA FEITA COPIA DO ARQUIVO
          vr_dscdiren := gene0001.fn_param_sistema('CRED',0,'DIR_NEXXERA');

          -- COPIA DE ARQUIVO
          gene0001.pc_OScommand(pr_typ_comando => 'S',
                                pr_des_comando => 'cp ' || pr_nmarqped || vr_dscdiren);

        END IF;*/

        IF pr_tpdenvio IN (2, 5) THEN -- 2 --> INTERCHANGE / 5 --> ACCESTAGE

          IF pr_tpdenvio = 2 THEN -- INTERCHANGE
            vr_cdcritic := 696;
          ELSE
            vr_cdcritic := 905;
          END IF;

          -- BUSCA DESCRICAO DA CRITICA
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          -- COPIA DE ARQUIVO
          gene0001.pc_OScommand(pr_typ_comando => 'S',
                                pr_des_comando => 'cp ' || pr_nmarqped ||
                                                  ' salvar');

        ELSE
          -- MOVE ARQUIVO
          gene0001.pc_OScommand(pr_typ_comando => 'S',
                                pr_des_comando => 'mv ' || pr_nmarqped ||
                                                  ' salvar 2> /dev/null');
        END IF;

        -- ENVIO CENTRALIZADO DE LOG DE ERRO
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- ERRO TRATATO
                                  ,pr_des_log      => to_char(sysdate,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        -- VERIFICA TIPO DE ENVIO
        IF pr_tpdenvio IN (2, 3, 5) THEN

          -- ENVIO CENTRALIZADO DE LOG DE ERRO
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1,
                                     pr_des_log      => to_char(sysdate,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' ||
                                                        vr_dscritic ||
                                                        pr_nmarqdat ||
                                                        ' -  Arrecadacao Cx. - ' ||
                                                        pr_nmempres ||
                                                        ': _________');
        ELSE

          -- SE 1 - CAIXA OU 2 - DEBITO, MUDA EMAIL DE DESTINATARIO
          IF pr_tpdcontr = 1 THEN
            vr_dsemail2 := pr_dsendcxa;
          ELSE
            vr_dsemail2 := pr_dsenddeb;
          END IF;

          -- QUANTIDADE DE EMAIL CONTIDOS  NA STRING
          vr_nrentrie := REGEXP_COUNT(vr_dsemail2, ',') + 1;

          WHILE vr_contador <= vr_nrentrie LOOP

            -- RECEBE EMAIL
            vr_dsdemail := GENE0002.fn_busca_entrada(vr_contador,
                                                     vr_dsemail2, ',');

            -- VERIFICA SE EMAIL É VAZIO OU NULL
            IF vr_dsdemail IS NULL THEN

              vr_contador := NVL(vr_contador, 0) + 1;
              -- VAI PARA PROXIMO REGISTRO
              CONTINUE;

            END IF;

            -- VERIFICA TIPO DE ENVIO
            IF pr_tpdenvio = 1 THEN

              -- CHAMAR ENVIO DOS E-MAILS
              gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper,                    -- CODIGO DA COOPERATIVA
                                         pr_cdprogra    => vr_cdprogra,                    -- CODIGO DO PROGRAMA
                                         pr_des_destino => vr_dsdemail,                    -- EMAIL DE DESTINATARIO
                                         pr_des_assunto => 'ARQUIVO DE ARRECADACAO DA ' ||
                                                           rw_crapcop.nmrescop,            -- ASSUNTO DO EMAIL
                                         pr_des_corpo   => '',                             -- TEXTO DO CORPO DO EMAIL
                                         pr_des_anexo   => vr_dsdireto ||
                                                           pr_nmarqdat,                    -- ANEXOS
                                         pr_des_erro    => vr_dscritic);                   -- VARIAVEL DE CRITICA CASO OCORRA ALGUM ERRO

              -- SE HOUVER ERRO
              IF vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
                -- LEVANTAR EXCEÇÃO
                RAISE vr_exc_saida;
              END IF;

            -- VERIFICA TIPO DE ENVIO
            ELSIF pr_tpdenvio = 4 THEN

              -- CHAMAR ENVIO DOS E-MAILS
              gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper,                    -- CODIGO DA COOPERATIVA
                                         pr_cdprogra    => vr_cdprogra,                    -- CODIGO DO PROGRAMA
                                         pr_des_destino => vr_dsdemail,                    -- EMAIL DE DESTINATARIO
                                         pr_des_assunto => 'ARQUIVO DE ARRECADACAO DA ' ||
                                                           rw_crapcop.nmrescop,            -- ASSUNTO DO EMAIL
                                         pr_des_corpo   => '',                             -- TEXTO DO CORPO DO EMAIL
                                         pr_des_anexo   => vr_dsdireto || '/converte/' ||
                                                           pr_nmarqdat || '.zip',          -- ANEXOS
                                         pr_des_erro    => vr_dscritic);                   -- VARIAVEL DE CRITICA CASO OCORRA ALGUM ERRO

              -- SE HOUVER ERRO
              IF vr_dscritic IS NOT NULL THEN
                -- LEVANTAR EXCEÇÃO
                RAISE vr_exc_saida;
              END IF;

            END IF;

            -- INCREMENTA CONTADOR
            vr_contador := NVL(vr_contador, 0) + 1;

          END LOOP;

        END IF;

        -- ENVIO CENTRALIZADO DE LOG DE ERRO
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1,
                                   pr_des_log      => TO_CHAR(sysdate,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
      END;

    END pc_atualiza_controle;

    ----------------------------------------------------------------------------------------

    PROCEDURE pc_efetua_geracao_arq(pr_cdcooper IN gncvuni.cdcooper%TYPE --> CODIGO COOPERATIVA
                                   ,pr_flgfirst IN OUT BOOLEAN           --> INDICA PRIMEIRO REGISTRO (TRUE-PRIMEIRO REGISTRO / FALSE - REGISTRO QUALQUER))
                                   ,pr_flaglast IN BOOLEAN               --> INDICA ULTIMO REGISTRO (TRUE-ULTIMO REGISTRO / FALSE - ULTIMO QUALQUER))
                                   ,pr_contatip IN gncvuni.tpdcontr%TYPE --> TIPO DE CONTA
                                   ,pr_nmempres IN gnconve.nmempres%TYPE --> NOME DA EMPRESA
                                   ,pr_nrcnvfbr IN gnconve.nrcnvfbr%TYPE --> NRD.CONVENIO P/ FEBRAB
                                   ,pr_nrseqdig IN INTEGER               --> NUMERO SEQUENCIAL
                                   ,pr_nrconven IN gncvuni.cdconven%TYPE --> NUMERO DO CONVENIO
                                   ,pr_nrdbanco IN gnconve.cddbanco%TYPE --> CODIGO DO BANCO
                                   ,pr_nmdbanco IN crapcop.nmrescop%TYPE --> NOME DA COOPERATIVA
                                   ,pr_dsmovtos IN gncvuni.dsmovtos%TYPE --> DETALHE DO MOVIMENTO
                                   ,pr_verifpac IN gnconve.vltrfnet%TYPE --> TARIFA PA
                                   ,pr_vltrfnet IN gnconve.vltrfnet%TYPE --> TARIFA ARRECAD. INTERN
                                   ,pr_vltrftaa IN gnconve.vltrftaa%TYPE --> VALOR TARIFA TAA
                                   ,pr_vltrfcxa IN gnconve.vltrfcxa%TYPE --> TARIFA DE ARRECADACAO CAIXA
                                   ,pr_vltrfdeb IN gnconve.vltrfdeb%TYPE --> TARIFA DE ARRECADACAO CAIXA
                                   ,pr_nmarqped IN VARCHAR2              --> NOME ARQUIVO
                                   ,pr_nmarqdat IN VARCHAR2              --> NOME ARQUIVO
                                   ,pr_tipenvio IN gnconve.tpdenvio%TYPE --> TIPO DE ENVIO
                                   ,pr_prorecid IN ROWID                 --> ROWID
                                   ,pr_rowiduni IN ROWID                 --> ROWID
                                   ,pr_nmarqcxa IN gnconve.nmarqcxa%TYPE --> ARQ. CAIXA
                                   ,pr_nmarqdeb IN gnconve.nmarqdeb%TYPE --> ARQ. DEB. EFETUADOS
                                   ,pr_nmarqatu IN gnconve.nmarqatu%TYPE --> ARQUIVO DE ATU. CADAST
                                   ,pr_tpdcontr IN gncvuni.tpdcontr%TYPE --> TIPO DE CONTROLE
                                   ,pr_dsendcxa IN gnconve.dsendcxa%TYPE --> E-MAIL PARA ARQ. ARREC
                                   ,pr_dsenddeb IN gnconve.dsenddeb%TYPE --> E-MAIL PARA ARQ. DEBIT
                                   ,pr_flgproce OUT BOOLEAN) IS          --> FLAG DE PROCESSO

      /* .............................................................................
      Programa: pc_efetua_geracao_arq
      Autor   : Jean Michel.
      Data    : 28/02/2014                     Ultima atualizacao: 31/03/2014

      Dados referentes ao programa:

      Objetivo   : Gera os relatórios de saida do programa

      Parametros :  pr_cdcooper --> CODIGO COOPERATIVA
                    pr_tiparqui --> TIPO DE ARQUIVO A SER GERADO (1-NORMAL / 2- DEBITO / 3-AUTORIZACAO)
                    pr_flgfirst --> INDICA PRIMEIRO REGISTRO (TRUE-PRIMEIRO REGISTRO / FALSE - REGISTRO QUALQUER))
                    pr_flaglast --> INDICA ULTIMO REGISTRO (TRUE-ULTIMO REGISTRO / FALSE - ULTIMO QUALQUER))
                    pr_contatip --> TIPO DE CONTA
                    pr_nmempres --> NOME DA EMPRESA
                    pr_nrcnvfbr --> NRD.CONVENIO P/ FEBRAB
                    pr_nrseqdig --> NUMERO SEQUENCIAL
                    pr_nrconven --> NUMERO DO CONVENIO
                    pr_nrdbanco --> CODIGO DO BANCO
                    pr_nmdbanco --> NOME DA COOPERATIVA
                    pr_dsmovtos --> DETALHE DO MOVIMENTO
                    pr_verifpac --> TARIFA PA
                    pr_vltrfnet --> TARIFA ARRECAD. INTERN
                    pr_vltrftaa --> VALOR TARIFA TAA
                    pr_vltrfcxa --> TARIFA DE ARRECADACAO CAIXA
                    pr_vltrfdeb --> TARIFA DE ARRECADACAO CAIXA
                    pr_nrseqarq --> NR.SEQ.ARQ.ARRECADACAO
                    pr_nmarqped --> NOME ARQUIVO
                    pr_nmarqdat --> NOME ARQUIVO
                    pr_tipenvio --> TIPO DE ENVIO
                    pr_prorecid --> ROWID
                    pr_rowiduni --> ROWID
                    pr_nmarqcxa --> ARQ. CAIXA
                    pr_nmarqdeb --> ARQ. DEB. EFETUADOS
                    pr_nmarqatu --> ARQUIVO DE ATU. CADAST
                    pr_tpdcontr --> TIPO DE CONTROLE
                    pr_dsendcxa --> E-MAIL PARA ARQ. ARREC
                    pr_dsenddeb --> E-MAIL PARA ARQ. DEBIT
                    pr_flgproce --> FLAG DE PROCESSO
      Premissa   :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        vr_nmarquiv VARCHAR2(200) := '';
        vr_cdseqfat VARCHAR2(25) := '';

      BEGIN

        -- VERIFICA PRIMEIRO REGISTRO
        IF pr_flgfirst THEN

          pc_nomeia_arquivos(pr_contatip => pr_contatip   --> TIPO DA CONTA
                            ,pr_cdcooper => pr_cdcooper   --> CODIGO DA COOPERATIVA
                            ,pr_nmarqcxa => pr_nmarqcxa   --> ARQUIVO DE ARRECADACAO
                            ,pr_nmarqdeb => pr_nmarqdeb   --> ARQUIVO DE DEBITOS
                            ,pr_nmarqatu => pr_nmarqatu   --> ARQUIVO DE ATU. CADASTRAL
                            ,pr_prorecid => pr_prorecid   --> ROWID
                            ,pr_nrseqarq => vr_nrseqarq   --> NR.SEQ.ARQ.ARRECADACAO
                            ,pr_nmarquiv => vr_nmarquiv   --> NOME ARQUIVO
                            ,pr_nmarqdat => vr_nmarqdat   --> NOME ARQUIVO
                            ,pr_nmarqped => vr_nmarqped); --> NOME ARQUIVO

          vr_textarqu := '';

          dbms_lob.createtemporary(vr_xml, TRUE);
          dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

          dbms_lob.createtemporary(vr_arq, TRUE);
          dbms_lob.open(vr_arq, dbms_lob.lob_readwrite);

          -- INICILIZAR AS INFORMAÇÕES DO XML
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_textcomp,
                                  '<?xml version="1.0" encoding="utf-8"?><raiz>');

          -- NOME DO ARQUIVO
          vr_nmarqrel := 'rl/crrl387_c' ||
                         gene0002.fn_mask(vr_cdconven, '9999') || '.lst';

          -- CAMINHO DO ARQUIVO COMPLETO
          vr_nomdiret := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper);

          -- MONTA XML
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_textcomp,
                                  '<nmarqdat>' || vr_nmarqdat || '</nmarqdat>' ||
                                  '<dttransm>' || TO_CHAR(SYSDATE, 'dd/mm/yyyy') || '</dttransm>' ||
                                  '<nmempcov>' || pr_nmempres || '</nmempcov>');

          -- VERIFICA SE TIPO DE ARQUIVO 1-NORMAL
          IF vr_tiparqui = 1 THEN
            -- TEXTO DO ARQUIVO
            vr_strtexto := 'A2' ||
                           gene0002.fn_mask(pr_nrcnvfbr, '99999999') ||
                           SUBSTR(pr_nmempres, 0, 20) ||
                           gene0002.fn_mask(pr_nrdbanco, '999') ||
                           SUBSTR(pr_nmdbanco, 0, 20) ||
                           TO_CHAR(rw_crapdat.dtmvtolt, 'yyyymmdd') ||
                           vr_nrseqarq || '03ARRECADACAO CAIXA' ||
                           LPAD(' ', 52);

            -- INICILIZAR AS INFORMAÇÕES DO XML
            gene0002.pc_escreve_xml(vr_arq,
                                    vr_textarqu,
                                    vr_strtexto || chr(13));

          -- VERIFICA SE TIPO DE ARQUIVO 2- DEBITO OU 3-AUTORIZACAO
          ELSIF vr_tiparqui IN (2, 3) THEN
            -- TEXTO DO ARQUIVO
            vr_strtexto := 'A2' || RPAD(TRIM(gene0002.fn_mask(pr_nrcnvfbr,
                                                              'zzzzzzzzzzzzzzzzzzzz')),
                                        20,' ') ||
                           RPAD(SUBSTR(pr_nmempres, 0, 20), 20, ' ') ||
                           gene0002.fn_mask(pr_nrdbanco, '999') ||
                           RPAD(SUBSTR(pr_nmdbanco, 0, 20), 20, ' ') ||
                           TO_CHAR(rw_crapdat.dtmvtolt, 'yyyymmdd') ||
                           gene0002.fn_mask(vr_nrseqarq, '999999') ||
                           '04DEBITO AUTOMATICO' || LPAD(' ', 52);

            -- ESCREVE INFORMACOES DO XML
            gene0002.pc_escreve_xml(vr_arq,
                                    vr_textarqu,
                                    vr_strtexto || chr(13));
          END IF;

          -- INDICA QUE NAO E MAIS O PRIMEIRO REGISTRO
          pr_flgfirst := FALSE;

        END IF;

        -- VERIFICA SE TIPO DE ARQUIVO 3-AUTORIZACAO
        IF vr_tiparqui = 3 THEN
          vr_vltarifa := 0; -- AUTORIZACAO NAO TEM TARIFA
        ELSE
          -- VERIFICA TARIFA PA
          IF pr_verifpac = 90 THEN -- TARIFA DO PA 90 - INTERNET
            vr_vltarifa := pr_vltrfnet; -- VALOR DA TARIFA
          ELSIF pr_verifpac = 91 THEN -- TARIFA DO PA 91 - TAA
            vr_vltarifa := pr_vltrftaa; -- VALOR DA TARIFA
          ELSE
            -- RECEBE VALOR DE TARIFA
            IF vr_tiparqui = 1 THEN -- ARQUIVO DE CAIXA
              vr_vltarifa := pr_vltrfcxa;
            ELSIF vr_tiparqui = 2 THEN -- ARQUIVO DEB.AUTOM.
              vr_vltarifa := pr_vltrfdeb; -- VALOR DA TARIFA
            END IF;
          END IF;
        END IF;

        IF vr_tiparqui = 1 THEN -- ARQUIVO DE CAIXA
          vr_cdagenci := NVL(REPLACE(REPLACE(SUBSTR(pr_dsmovtos, 4, 2),'.', ''), ' ', ''), 0);      -- CODIGO DA AGENCIA
          vr_vllanmto := NVL(REPLACE(REPLACE(SUBSTR(pr_dsmovtos, 82, 12),'.',''),' ',''), 0) / 100; -- VALOR DE LANCAMENTO
        ELSIF vr_tiparqui IN (2, 3) THEN -- ARQUIVO DEB.AUTOM. / AUTORIZ. DEBITO
          vr_cdagenci := NVL(REPLACE(REPLACE(SUBSTR(pr_dsmovtos, 27, 4),'.', ''), ' ', ''), 0);    -- CODIGO DA AGENCIA
          vr_vllanmto := NVL(REPLACE(REPLACE(SUBSTR(pr_dsmovtos, 53, 15),'.',''),' ',''),0) / 100; -- VALOR DE LANCAMENTO
        END IF;

        vr_nrseqdig := NVL(pr_nrseqdig, 0) + 1;                   -- NUMERO SEQUENCIAL
        vr_vlfatura := NVL(vr_vlfatura, 0) + NVL(vr_vllanmto, 0); -- VALOR TOTAL DE FATURA
        vr_vltottar := NVL(vr_vltottar, 0) + NVL(vr_vltarifa, 0); -- VALOR TOTAL DE TARIFA

        -- VERIFICA ARQUIVO
        IF vr_tiparqui IN (1) THEN
          -- VERIFICA CONVENIO
          IF pr_nrconven = 21 THEN
            -- CASA FELIZ
            vr_cdseqfat := SUBSTR(pr_dsmovtos, 70, 12);
          ELSE
            vr_cdseqfat := SUBSTR(pr_dsmovtos, 71, 11); -- SAMAE GASPAR
          END IF;

        -- VERIFICA TIPO DE ARQUIVO E TIPO DE CONTROLE
        ELSIF vr_tiparqui IN (2) AND pr_tpdcontr = 2 THEN
          vr_cdseqfat := SUBSTR(pr_dsmovtos, 70, 20);
        -- VERIFICA TIPO DE ARQUIVO
        ELSIF vr_tiparqui IN (3) THEN
          vr_cdseqfat := SUBSTR(pr_dsmovtos, 53, 20);
        END IF;

        -- MONTA XML
        gene0002.pc_escreve_xml(vr_xml,
                                vr_textcomp,
                                '<cod id="' || NVL(TRIM(gene0002.fn_mask(vr_cdseqfat,
                                                                         'zzzzzzzzzzzzzzzzzz9')), 0) || '">' ||
                                  '<tparquiv>' || vr_tiparqui || '</tparquiv>' ||
                                  '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
                                  '<dtrecebm>' || TO_CHAR(rw_crapdat.dtmvtolt, 'dd/mm/yyyy') || '</dtrecebm>' ||
                                  '<nrseqdig>' || vr_nrseqdig || '</nrseqdig>' ||
                                  '<cdagenci>' || vr_cdagenci || '</cdagenci>' ||
                                  '<vllanmto>' || TRIM(TO_CHAR(vr_vllanmto, '99999G990d00')) || '</vllanmto>' ||
                                '</cod>');

        IF vr_tiparqui IN (1) THEN
          -- TEXTO DO RELATORIO
          vr_strtexto := SUBSTR(pr_dsmovtos, 1, 100) ||
                         gene0002.fn_mask(vr_nrseqdig, '99999999') ||
                         SUBSTR(pr_dsmovtos, 109, 42);

          -- ESCREVE INFORMACOES NO XML
          gene0002.pc_escreve_xml(vr_arq,
                                  vr_textarqu,
                                  vr_strtexto || chr(13));

        ELSIF vr_tiparqui IN (2, 3) THEN

          vr_strtexto := SUBSTR(pr_dsmovtos, 1, 150);

          -- ESCREVE INFORMACOES NO XML
          gene0002.pc_escreve_xml(vr_arq,
                                  vr_textarqu,
                                  vr_strtexto || chr(13));

        END IF;

        -- INDICADOR DE PROCESSO
        pr_flgproce := TRUE;

        BEGIN
          -- ATUALIZA REGISTRO QUE FOI PROCESSADO
          UPDATE gncvuni SET flgproce = 1 WHERE ROWID = pr_rowiduni;

        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
        EXCEPTION
          WHEN OTHERS THEN
            -- DESCRICAO DO ERRO NA ATUALIZACAO DE REGISTROS
            pr_dscritic := 'Problema ao atualizar registro na tabela GNCVUNI: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- VERIFICA SE E ULTIMO REGISTRO
        IF pr_flaglast THEN

          -- VALOR A PAGAR
          vr_vlapagar := NVL(vr_vlfatura, 0) - NVL(vr_vltottar, 0);

          -- MONTA XML
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_textcomp,
                                  '<qtdfatur>' || NVL(vr_nrseqdig, '0') || '</qtdfatur>' ||
                                  '<vltotare>' || TO_CHAR(NVL(vr_vlfatura, '0'), '99999G990d00') || '</vltotare>' ||
                                  '<vltarifa>' || TO_CHAR(NVL(vr_vltottar, '0'), '99999G990d00') || '</vltarifa>' ||
                                  '<vlapagar>' || TO_CHAR(NVL(vr_vlapagar, '0'), '99999G990d00') || '</vlapagar>' ||
                                  '<dtcredit>' || TO_CHAR(vr_dtproxim, 'dd/mm/yyyy') || '</dtcredit>');

          -- EFETUA O ENVIO DOS ARQUIVOS POR EMAIL
          pc_atualiza_controle(pr_cdcooper => pr_cdcooper    --> COOPERATIVA CONECTADA
                              ,pr_tpdenvio => pr_tipenvio    --> TIPO DE ENVIO
                              ,pr_nmarqdat => pr_nmarqdat    --> NOME DO ARQUIVO
                              ,pr_nmarqped => pr_nmarqped    --> NOME DO ARQUIVO
                              ,pr_nmempres => pr_nmempres    --> NOME DA EMPRESA
                              ,pr_tpdcontr => pr_tpdcontr    --> TIPO DE CONTROLE
                              ,pr_dsendcxa => pr_dsendcxa    --> E-MAIL PARA ARQ. ARREC
                              ,pr_dsenddeb => pr_dsenddeb); --> E-MAIL PARA ARQ. DEBIT

          -- MONTA XML
          gene0002.pc_escreve_xml(vr_xml, vr_textcomp, '</raiz>', true);

          -- SOLICITACAO DO RELATORIO
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,          --> COOPERATIVA
                                      pr_cdprogra  => vr_cdprogra,          --> PROGRAMA CHAMADOR
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,  --> DATA DO MOVIMENTO ATUAL
                                      pr_dsxml     => vr_xml,               --> ARQUIVO XML DE DADOS
                                      pr_dsxmlnode => '/raiz',              --> NÓ DO XML PARA ITERAÇÃO
                                      pr_dsjasper  => 'crrl387.jasper',     --> ARQUIVO DE LAYOUT DO IREPORT
                                      pr_dsparams  => '',                   --> ARRAY DE PARAMETROS DIVERSOS
                                      pr_dsarqsaid => vr_nomdiret || '/' ||
                                                      vr_nmarqrel,          --> PATH/NOME DO ARQUIVO PDF GERADO
                                      pr_flg_gerar => 'N',                  --> GERAR O ARQUIVO NA HORA*
                                      pr_qtcoluna  => 80,                   --> QTD COLUNAS DO RELATÓRIO (80,132,234)
                                      pr_flg_impri => 'S',                  --> CHAMAR A IMPRESSÃO (IMPRIM.P)*
                                      pr_nrcopias  => 1,                    --> QTD DE CÓPIAS
                                      pr_des_erro  => vr_dscritic);         --> SAÍDA COM ERRO

          -- VERIFICA SE OCORREU UMA CRITICA
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
          dbms_lob.close(vr_xml);
          dbms_lob.freetemporary(vr_xml);

          -- TEXTO QUE IRA CONSTAR NO RELATORIO
          vr_strtexto := 'Z' ||
                         gene0002.fn_mask(NVL(vr_nrseqdig, 0) + 2, '999999') ||
                         gene0002.fn_mask(NVL(vr_vlfatura, 0) * 100, '99999999999999999');

          gene0002.pc_escreve_xml(vr_arq, vr_textarqu, vr_strtexto, true);

          -- Gerar o arquivo
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_arq
                                       ,pr_caminho  => vr_nomdiret || '/arq'
                                       ,pr_arquivo  => vr_nmarqped
                                       ,pr_des_erro => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;                            
                                      

          -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
          dbms_lob.close(vr_arq);
          dbms_lob.freetemporary(vr_arq);

        END IF;

      END;

    END pc_efetua_geracao_arq;

    ----------------------------------------------------------------------------------------------------

    PROCEDURE pc_gera_arq_sem_movimento(pr_contatip IN gncvuni.tpdcontr%TYPE --> TIPO DE CONTA
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> CODIGO DO CONVENIO
                                       ,pr_tipenvio IN gnconve.tpdenvio%TYPE --> TIPO DE ENVIO
                                       ,pr_tpdcontr IN gncvuni.tpdcontr%TYPE --> TIPO DE CONTROLE
                                        ) IS

      /* .............................................................................
      Programa: pc_gera_arq_sem_movimento
      Autor   : Jean Michel.
      Data    : 28/02/2014                     Ultima atualizacao: 28/02/2014

      Dados referentes ao programa:

      Objetivo   : Cria arquivos XML responsáveis pelos relatórios

      Parametros :  pr_contatip --> TIPO DE CONTA
                    pr_cdconven --> CODIGO DO CONVENIO
                    pr_tipenvio --> TIPO DE ENVIO
                    pr_tpdcontr --> TIPO DE CONTROLE
      Premissa   :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        vr_nmarquiv VARCHAR2(200) := '';   -- NOME DO ARQUIVO
        vr_nrseqarq gnconve.nrseqcxa%TYPE; -- NUMERO SEQUENCIAL

        -- BUSCA DE CONVENIOS
        CURSOR cr_gnconve(pr_cdconven IN gnconve.cdconven%TYPE) IS

          SELECT nve.cdconven,
                 nve.cdcooper,
                 nve.nmarqcxa,
                 nve.nmarqatu,
                 nve.nmarqdeb,
                 nve.nrcnvfbr,
                 nve.nmempres,
                 nve.cddbanco,
                 nve.dsendcxa,
                 nve.dsenddeb,
                 nve.rowid
            FROM gnconve nve
           WHERE nve.cdconven = pr_cdconven -- CODIGO DO CONVENIO
             AND nve.flgativo = 1;          -- FLAG ATIVO TRUE

        rw_gnconve cr_gnconve%ROWTYPE;

      BEGIN

        -- BUSCA DE CONVENIOS
        OPEN cr_gnconve(pr_cdconven => pr_cdconven); -- CODIGO DO CONVENIO

        FETCH cr_gnconve
          INTO rw_gnconve;

        -- SE NÃO ENCONTRAR
        IF cr_gnconve%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_gnconve;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_gnconve;

          pc_nomeia_arquivos(pr_contatip => pr_contatip         --> TIPO DA CONTA
                            ,pr_cdcooper => rw_gnconve.cdcooper --> CODIGO DA COOPERATIVA
                            ,pr_nmarqcxa => rw_gnconve.nmarqcxa --> ARQUIVO DE ARRECADACAO
                            ,pr_nmarqdeb => rw_gnconve.nmarqdeb --> ARQUIVO DE DEBITOS
                            ,pr_nmarqatu => rw_gnconve.nmarqatu --> ARQUIVO DE ATU. CADASTRAL
                            ,pr_prorecid => rw_gnconve.rowid    --> ROWID
                            ,pr_nrseqarq => vr_nrseqarq         --> SEQUENCIA DE ARQUIVO
                            ,pr_nmarquiv => vr_nmarquiv         --> NOME ARQUIVO
                            ,pr_nmarqdat => vr_nmarqdat         --> NOME ARQUIVO
                            ,pr_nmarqped => vr_nmarqped);       --> NOME ARQUIVO

          dbms_lob.createtemporary(vr_arq, TRUE);
          dbms_lob.open(vr_arq, dbms_lob.lob_readwrite);

          -- DIRETORIO QUE SERA GERADO O RELATORIO
          vr_nomdiret := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => rw_gnconve.cdcooper
                                              ,pr_nmsubdir => 'arq'); --> UTILIZAREMOS O DIRETORIO /arq

          -- TEXTO QUE SERA INSERIDO NO RELATORIO
          vr_strtexto := 'A2' ||
                         gene0002.fn_mask(rw_gnconve.nrcnvfbr, '99999999') ||
                         SUBSTR(rw_gnconve.nmempres, 0, 20) ||
                         gene0002.fn_mask(rw_gnconve.cddbanco, '999') ||
                         SUBSTR(rw_crapcop.nmrescop, 0, 20) ||
                         TO_CHAR(rw_crapdat.dtmvtolt, 'yyyymmdd') ||
                         vr_nrseqarq || '03ARRECADACAO CAIXA';

          -- ESCREVE INFORMACOES NO XML
          gene0002.pc_escreve_xml(vr_arq,
                                  vr_textarqu,
                                  vr_strtexto || chr(13));

          -- INFORMACOES QUE O RELATORIO IRA CONTER
          vr_strtexto := 'Z00000200000000000000000' || LPAD(' ', 126);

          -- ESCREVE INFORMACOES NO XML
          gene0002.pc_escreve_xml(vr_arq,
                                  vr_textarqu,
                                  vr_strtexto || chr(13),
                                  true);

          -- Gerar o arquivo
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_arq
                                       ,pr_caminho  => vr_nomdiret
                                       ,pr_arquivo  => vr_nmarqped
                                       ,pr_des_erro => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF; 
          

          -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
          dbms_lob.close(vr_arq);
          dbms_lob.freetemporary(vr_arq);

          -- EFETUA O ENVIO DOS ARQUIVOS POR EMAIL
          pc_atualiza_controle(pr_cdcooper => rw_gnconve.cdcooper,  -- CODIGO DA COOPERATIVA
                               pr_tpdenvio => pr_tipenvio,          -- TIPO DE ENVIO
                               pr_nmarqdat => vr_nmarqdat,          -- NOME DO ARQUIVO
                               pr_nmarqped => vr_nmarqped,          -- NOME DO ARQUIVO
                               pr_nmempres => rw_gnconve.nmempres,  -- NOME DA EMPRESA
                               pr_tpdcontr => pr_tpdcontr,          -- TIPO DE CONTROLE
                               pr_dsendcxa => rw_gnconve.dsendcxa,  -- EMAIL PARA ARQ. ARRECADAO
                               pr_dsenddeb => rw_gnconve.dsenddeb); -- EMAIL PARA ARQ. DEBITO
        END IF;

      END;

    END pc_gera_arq_sem_movimento;

  BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;

    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapdat
      INTO rw_crapdat;

    -- SE NÃO ENCONTRAR
    IF cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapdat;
    END IF;

    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    -- PROXIDO DIA APÓS PRÓXIMO DIA ÚTIL
    vr_dtproxim := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => (rw_crapdat.dtmvtopr + 1));

    -- 1-CAIXA | 2-DEBITO | 3-AUTORIZ. DEBITO
    FOR i IN 1 .. 3 LOOP

      vr_flgfirst := FALSE;
      vr_exisdare := FALSE;
      vr_exisgnre := FALSE;

      -- BUSCA CADASTRO DOS LANCAMENTOS DE APLICACOES RDCA
      OPEN cr_gncvuni(pr_tpdcontr => i); -- NUMERO DA APLICACAO

      LOOP
        FETCH cr_gncvuni
          INTO rw_gncvuni;

        -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
        EXIT WHEN cr_gncvuni%NOTFOUND;

        -- CONSULTA NUMERO PA
        vr_verifpac := SUBSTR(rw_gncvuni.dsmovtos, 4, 2);

        -- VERIFICA SE É PRIMEIRO REGISTRO DE CONVENIO E COOPERATIVA
        IF rw_gncvuni.seqlauto = 1 THEN

          -- BUSCA DE CONVENIOS
          OPEN cr_gnconve(pr_cdconven => rw_gncvuni.cdconven); -- CODIGO DO CONVENIO

          FETCH cr_gnconve
            INTO rw_gnconve;

          -- SE NÃO ENCONTRAR
          IF cr_gnconve%NOTFOUND THEN
            -- APENAS FECHAR O CURSOR
            CLOSE cr_gnconve;
            -- PROXIMO REGISTRO
            CONTINUE;
          ELSE
            -- APENAS FECHAR O CURSOR
            CLOSE cr_gnconve;

            -- INCLUI ESPACOS EM BRANCO PARA PADRAO DO RELATORIO
            vr_nrbranco := 10 -
                           ROUND(LENGTH(TRIM(rw_gnconve.nmempres)) / 2, 0);
            vr_nmempres := LPAD(TRIM(rw_gnconve.nmempres), vr_nrbranco, ' '); -- NOME DA EMPRESA
            vr_flgfirst := TRUE; -- INDICA PRIMEIRO REGISTRO
            vr_nrseqdig := 0;
            vr_vlfatura := 0;    -- VALOR DA FATURA

            vr_dscritic := 'Executando Convenio - ' || vr_nmempres;

            -- GRAVACAO DE LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- PROCESSO NORMAL
                                      ,pr_des_log      => to_char(sysdate,
                                                                  'hh24:mi:ss') ||
                                                          ' - ' ||
                                                          vr_cdprogra ||
                                                          ' --> ' ||
                                                          vr_dscritic);

            vr_dscritic := NULL;

          END IF;

          -- INDICA QUE NAO E ULTIMO REGISTRO
          vr_flaglast := FALSE;

          -- VERIFICA SE EXISTEM GUIAS DA SEFAZ
          IF rw_gncvuni.cdconven = 59 THEN -- DARE
            vr_exisdare := TRUE;
          ELSIF rw_gncvuni.cdconven = 60 THEN -- GNRE
            vr_exisgnre := TRUE;
          END IF;

          -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
          OPEN cr_crapcop(pr_cdcooper => rw_gncvuni.cdcooper);

          FETCH cr_crapcop
            INTO rw_crapcop;

          -- SE NÃO ENCONTRAR
          IF cr_crapcop%NOTFOUND THEN
            -- FECHAR O CURSOR POIS HAVERÁ RAISE
            CLOSE cr_crapcop;
            -- MONTAR MENSAGEM DE CRITICA
            vr_cdcritic := 651;
            RAISE vr_exc_saida;
          ELSE
            -- APENAS FECHAR O CURSOR
            CLOSE cr_crapcop;
          END IF;

        END IF; -- FIM IF 'FIRST-OF'

        -- LAST-OF
        IF rw_gncvuni.seqlast = rw_gncvuni.seqlauto THEN
          vr_flaglast := TRUE;
        END IF;

        -- VERIFICA TIPO DE CONTROLE
        CASE rw_gncvuni.tpdcontr

          WHEN 1 THEN
            vr_tiparqui := 1; -- CAIXA
          WHEN 2 THEN
            vr_tiparqui := 2; -- DEBITO AUTOMATICO
          WHEN 3 THEN
            vr_tiparqui := 3; -- AUTORIZACAO DEBITO
        END CASE;

        -- CODIGO DO CONVENIO
        vr_cdconven := rw_gnconve.cdconven;

        -- EFETUA A GERACAO DE RELATORIOS
        pc_efetua_geracao_arq(pr_cdcooper => rw_gnconve.cdcooper --> CODIGO COOPERATIVA
                             ,pr_flgfirst => vr_flgfirst         --> INDICA PRIMEIRO REGISTRO (TRUE-PRIMEIRO REGISTRO / FALSE - REGISTRO QUALQUER))
                             ,pr_flaglast => vr_flaglast         --> INDICA ULTIMO REGISTRO (TRUE-ULTIMO REGISTRO / FALSE - ULTIMO QUALQUER))
                             ,pr_contatip => rw_gncvuni.tpdcontr --> TIPO DE CONTA
                             ,pr_nmempres => rw_gnconve.nmempres --> NOME DA EMPRESA
                             ,pr_nrcnvfbr => rw_gnconve.nrcnvfbr --> NRD.CONVENIO P/ FEBRAB
                             ,pr_nrseqdig => vr_nrseqdig         --> NUMERO SEQUENCIAL
                             ,pr_nrconven => rw_gncvuni.cdconven --> NUMERO DO CONVENIO
                             ,pr_nrdbanco => rw_gnconve.cddbanco --> CODIGO DO BANCO
                             ,pr_nmdbanco => rw_crapcop.nmrescop --> NOME DA COOPERATIVA
                             ,pr_dsmovtos => rw_gncvuni.dsmovtos --> DETALHE DO MOVIMENTO
                             ,pr_verifpac => vr_verifpac         --> TARIFA PA
                             ,pr_vltrfnet => rw_gnconve.vltrfnet --> TARIFA ARRECAD. INTERN
                             ,pr_vltrftaa => rw_gnconve.vltrftaa --> VALOR TARIFA TAA
                             ,pr_vltrfcxa => rw_gnconve.vltrfcxa --> TARIFA DE ARRECADACAO CAIXA
                             ,pr_vltrfdeb => rw_gnconve.vltrfdeb --> TARIFA DE ARRECADACAO DEBITO
                             ,pr_nmarqped => vr_nmarqped         --> NOME ARQUIVO
                             ,pr_nmarqdat => vr_nmarqdat         --> NOME ARQUIVO
                             ,pr_tipenvio => rw_gnconve.tpdenvio --> TIPO DE ENVIO
                             ,pr_prorecid => rw_gnconve.rowid    --> ROWID
                             ,pr_rowiduni => rw_gncvuni.rowid    --> ROWID
                             ,pr_nmarqcxa => rw_gnconve.nmarqcxa --> ARQUIVO DE ARRECADACAO
                             ,pr_nmarqdeb => rw_gnconve.nmarqdeb --> ARQ. DEB. EFETUADOS
                             ,pr_nmarqatu => rw_gnconve.nmarqatu --> ARQUIVO DE ATU. CADAST
                             ,pr_tpdcontr => rw_gncvuni.tpdcontr --> TIPO DE CONTROLE
                             ,pr_dsendcxa => rw_gnconve.dsendcxa --> EMAIL DE ARQ. DE ARREC.
                             ,pr_dsenddeb => rw_gnconve.dsenddeb --> EMAIL DE ARQ. DE DEBITO.
                             ,pr_flgproce => vr_flgproce);       --> FLAG DE PROCESSO

      END LOOP;

      IF cr_gncvuni%NOTFOUND THEN

        -- FECHA CURSOR
        CLOSE cr_gncvuni;

      ELSE
        -- FECHA CURSOR
        CLOSE cr_gncvuni;

        -- VERIFICA SE CAIXA E DARE EXISTENTE
        IF i = 1 AND NOT vr_exisdare THEN

          -- EFETUA A GERACAO DE RELATORIOS
          pc_gera_arq_sem_movimento(pr_contatip => rw_gncvuni.tpdcontr   --> TIPO DE CONTA
                                   ,pr_cdconven => 59                    --> CODIGO DO CONVENIO
                                   ,pr_tipenvio => rw_gnconve.tpdenvio   --> TIPO DE ENVIO
                                   ,pr_tpdcontr => rw_gncvuni.tpdcontr); --> TIPO DE CONTROLE
        END IF;

        -- VERIFICA SE CAIXA E GNRE EXISTENTE
        IF i = 1 AND NOT vr_exisgnre THEN

          -- EFETUA A GERACAO DE RELATORIOS
          pc_gera_arq_sem_movimento(pr_contatip => rw_gncvuni.tpdcontr   --> TIPO DE CONTA
                                   ,pr_cdconven => 60                    --> CODIGO DO CONVENIO
                                   ,pr_tipenvio => rw_gnconve.tpdenvio   --> TIPO DE ENVIO
                                   ,pr_tpdcontr => rw_gncvuni.tpdcontr); --> TIPO DE CONTROLE
        END IF;

      END IF;

    END LOOP;

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;
    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
null;
      ROLLBACK;
  END;

END pc_crps449_renato;





begin

  dbms_output.put_line('Inicio...');

--  for creg in (select * from crapcop a where a.cdcooper in (1)) loop
  for creg in (select * from crapcop a where a.cdcooper = 3) loop
    dbms_output.put_line('Processando coop='||creg.cdcooper);
     pc_crps449_renato(pr_cdcooper => creg.cdcooper, 
                       pr_flgresta => 0, 
                       pr_stprogra => pr_stprogra, 
                       pr_infimsol => pr_infimsol, 
                       pr_cdcritic => pr_cdcritic, 
                       pr_dscritic => pr_dscritic);
     if pr_cdcritic <> 0 or pr_dscritic is not null then
       dbms_output.put_line('Cooper='||creg.cdcooper||' com erro: '||pr_cdcritic||'/'||pr_dscritic);
     end if;
  end loop;

  commit;
  
  dbms_output.put_line('Fim...');

end;