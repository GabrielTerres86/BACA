create or replace package cecred.SICR0002 is
  /*..............................................................................

     Programa: SICR0002
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Ranghetti
     Data    : Junho/2014                       Ultima atualizacao: 18/11/2015

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Procedimentos para os débitos automáticos dos convênios do Sicredi que não tiveram saldo no
                 processo noturno.

     Alteracoes: 12/02/2015 - Tratamento na procedure pc_consulta_convenios_wt para listar a partir de agora
                              tambem os convenios nossos (CECRED) que nao foram debitados no processo
                              noturno por insuficiencia de fundos. 
                              (Chamado 229249 - PRJ Melhoria) - (Fabricio)
                              
                 27/03/2015 - Ajustado para na gravacao do campo craplcm.cdpesqbb 
                              (procedure pc_cria_lancamentos_deb), gravar as informacoes
                              da mesma forma que quando gravado pelo pc_crps123.prc e/ou
                              pelo pc_crps509.prc (pos-liberacao). (Fabricio)
                              
                 30/03/2015 - Alterado na leitura da craplau para buscar as datas de
                              pagamentos tambem menores que a data atual, isto
                              para os casos de pagamentos com data no final de
                              semana. (Ajustes pos-liberacao # PRJ Melhoria) - 
                              (Fabricio)
                              
                 31/08/2015 - Incluir Hora da transação na inclusão da tabela craplcm 
                              (Lucas Ranghetti #324864)
                  
                 18/11/2015 - Alterado para que ao criar lancamentos seja atualizado
                              a dtultdeb da tabela crapatr conforme solicitado no 
                              chamado 322424 (Kelvin).
  ......................................................................................................... */

  -- Efetuar consulta dos debitos
  PROCEDURE pc_consulta_convenios_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                     pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,     --> Data do movimento
                                     pr_cdcritic   OUT PLS_INTEGER,     --> Codigo de Erro
                                     pr_dscritic   OUT VARCHAR2);                 --> Descricao de Erro

  -- Criar lançamentos de debitos automaticos na tabela craplcm conforme dados buscados do progress da tela DEBCON
  PROCEDURE pc_cria_lancamentos_deb(pr_cdcooper IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                    pr_dtmvtolt IN DATE,                      --> Data do movimento
                                    pr_cdhistor IN craplau.cdhistor%TYPE,     --> Codigo do historico
                                    pr_cdagenci IN crapass.cdagenci%TYPE,     --> Agencia PA
                                    pr_nrdconta IN crapass.nrdconta%TYPE,     --> conta/dv
                                    pr_vllanaut IN craplau.vllanaut%TYPE,     --> Valor lancamento
                                    pr_nrdocmto IN VARCHAR2,                  --> Documento
                                    pr_cdcritic OUT PLS_INTEGER,    --> Codigo de Erro
                                    pr_dscritic OUT VARCHAR2);                --> Descricao de Erro

END SICR0002;
/

CREATE OR REPLACE PACKAGE BODY CECRED.sicr0002 AS

  -- VARIAVEIS A UTILIZAR
  /* Tratamento de erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;

  -- VARIAVEIS DE ERRO
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(4000);

  -- VARIAVEIS DE EXCECAO
  vr_exc_saida EXCEPTION;

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  -- nome empresa conveniada
  vr_nmempres crapscn.dsnomcnv%TYPE;
  
  -- codigo convenio / codigo empresa (convenio Sicredi)
  vr_cdempres crapscn.cdempres%TYPE;

  vr_dtmvtolt date;
  vr_nrdocmto varchar2(25);
  vr_nrseqdig number;
  vr_dtmvtopg DATE;

  -- DECLARAÇÃO DE CURSORES
 
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
 
  -- Cursor de lançamentos automáticos
  CURSOR cr_craplau (pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                     pr_lshistor IN VARCHAR2) IS
    SELECT lau.cdcooper
          ,lau.dtmvtolt
          ,lau.dtmvtopg
          ,lau.cdtiptra
          ,lau.vllanaut
          ,lau.dttransa
          ,lau.nrdocmto
          ,lau.dslindig
          ,lau.dsorigem
          ,lau.idseqttl
          ,lau.nrdconta
          ,lau.dscedent
          ,lau.hrtransa
          ,lau.cdhistor
          ,lau.cdempres
          ,lau.cdagenci
          ,ROWID
          ,lau.progress_recid
    FROM  craplau lau
    WHERE lau.cdcooper  = pr_cdcooper
    AND   lau.dtmvtopg <= pr_dtmvtolt
    AND   lau.insitlau  = 1
    AND   ',' || pr_lshistor || ',' LIKE ('%,' || lau.cdhistor || ',%'); -- Retorna historicos passados na listagem
    rw_craplau cr_craplau%ROWTYPE;

  -- BUSCA DOS DADOS DE LOTES
  CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                    pr_cdagenci IN crapass.cdagenci%TYPE) IS
    SELECT lot.cdcooper,
           lot.cdagenci,
           lot.cdbccxlt,
           lot.dtmvtolt,
           lot.nrdolote,
           lot.qtcompln,
           lot.qtinfoln,
           lot.tplotmov,
           lot.vlcompcr,
           lot.vlcompdb,
           lot.vlinfocr,
           lot.vlinfodb,
           lot.nrseqdig,
           lot.cdbccxpg,
           lot.rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
	  	 AND lot.dtmvtolt = pr_dtmvtolt
		   AND lot.cdagenci = pr_cdagenci
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 6651;
  rw_craplot cr_craplot%ROWTYPE;

  -- BUSCA DADOS DE LANCAMENTOS
  CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                    pr_nrdconta IN craplcm.nrdconta%TYPE,
                    pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
    SELECT lcm.nrdolote
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
       AND lcm.nrdconta = pr_nrdconta  -- CONTA/DV
       AND lcm.dtmvtolt = pr_dtmvtolt  -- DATA DE MOVIMENTACAO
       AND lcm.cdhistor = 1019         -- BANCO/CAIXA
       AND lcm.nrdocmto = pr_nrdocmto  -- NUMERO DO DOCUMENTO
       AND lcm.nrdolote = 6651;         -- NUMERO DO LOTE
  rw_craplcm cr_craplcm%ROWTYPE;
    
  CURSOR cr_crapatr(pr_cdcooper IN crapatr.cdcooper%TYPE,
                    pr_nrdconta IN crapatr.nrdconta%TYPE,
                    pr_cdhistor IN crapatr.cdhistor%TYPE,
                    pr_cdrefere IN crapatr.cdrefere%TYPE) IS
    SELECT atr.dtfimatr
          ,atr.cdrefere
          ,atr.dtultdeb
          ,atr.rowid
          ,atr.flgmaxdb
          ,atr.vlrmaxdb
      FROM crapatr atr
     WHERE atr.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
       AND atr.nrdconta = pr_nrdconta -- NUMERO DA CONTA
       AND atr.cdhistor = pr_cdhistor -- CODIGO DO HISTORICO
       AND atr.cdrefere = pr_cdrefere; -- COD. REFERENCIA
  rw_crapatr cr_crapatr%ROWTYPE;     

  /* Efetua consulta para listar todos os débitos automáticos dos convênios do Sicredi que não tiveram saldo no
   processo noturno anterior para realizar o lançamento do débito.
   Utiliza gravacao em tabelas para serem chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_consulta_convenios_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                     pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,     --> Data do movimento
                                     pr_cdcritic   OUT PLS_INTEGER,     --> Codigo de Erro
                                     pr_dscritic   OUT VARCHAR2) IS               --> Descricao de Erro
      vr_lshistor VARCHAR2(1000);
    
    PROCEDURE pc_retorna_lista_historicos (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                           pr_lshistor OUT VARCHAR2) IS
                                           
      CURSOR cr_craphis (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor FROM craphis, gnconve WHERE
        craphis.cdhistor = gnconve.cdhisdeb AND
        craphis.cdcooper = pr_cdcooper      AND
        craphis.inautori = 1                AND /*Debito Automatico*/
        gnconve.flgativo = 1;
    BEGIN
      pr_lshistor := '1019';
      FOR vr_craphis IN cr_craphis (pr_cdcooper) LOOP
        pr_lshistor := pr_lshistor || ',' || to_char(vr_craphis.cdhistor);
      END LOOP;
    END pc_retorna_lista_historicos;

  BEGIN
    -- Limpa a tabela temporaria de interface       
    BEGIN
      DELETE wt_convenios_debitos;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_convenios_debitos: '||SQLERRM;
        RETURN;
    END;
    
    pc_retorna_lista_historicos (pr_cdcooper,
                                 vr_lshistor);

    -- Faz a busca dos registros na craplau
    FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_dtmvtolt,
                                 pr_lshistor => vr_lshistor) LOOP
                                 
      IF rw_craplau.cdhistor = 1019 THEN
        SELECT crapscn.dsnomcnv INTO vr_nmempres 
          FROM crapscn
        WHERE crapscn.cdempres = rw_craplau.cdempres;
        
        vr_cdempres := rw_craplau.cdempres;
      ELSE
        SELECT gnconve.nmempres, TO_CHAR(gnconve.cdconven) INTO vr_nmempres, vr_cdempres
          FROM gnconve
        WHERE gnconve.cdhisdeb = rw_craplau.cdhistor;
      END IF;

      -- criar registro na tabela wt_convenios que sera usada no progress
      BEGIN 
        INSERT INTO wt_convenios_debitos
          (cdcooper,
           cdagenci,
           nrdconta,
           dtmvtolt,
           cdhistor,
           vllanmto,
           nrdocmto,
           cdempres,
           nmempres)
         VALUES
           (rw_craplau.cdcooper,
            rw_craplau.cdagenci,
            rw_craplau.nrdconta,
            pr_dtmvtolt,
            rw_craplau.cdhistor,
            rw_craplau.vllanaut,
            rw_craplau.nrdocmto,
            vr_cdempres,
            vr_nmempres);
      EXCEPTION
        -- se ocorreu erro gera critica
        WHEN OTHERS THEN          
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao inserir na tabela wt_convenios_debitos: '||SQLERRM;            
          RETURN;
      END;  
            
    END LOOP;    
  -- COMMIT;
  END pc_consulta_convenios_wt;

  -- Criar lançamentos de debitos automaticos na tabela craplcm conforme dados buscados do progress da tela DEBCON
  PROCEDURE pc_cria_lancamentos_deb(pr_cdcooper IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                    pr_dtmvtolt IN DATE,                      --> Data do movimento
                                    pr_cdhistor IN craplau.cdhistor%TYPE,     --> Codigo do historico
                                    pr_cdagenci IN crapass.cdagenci%TYPE,     --> Agencia PA
                                    pr_nrdconta IN crapass.nrdconta%TYPE,     --> conta/dv
                                    pr_vllanaut IN craplau.vllanaut%TYPE,     --> Valor lancamento
                                    pr_nrdocmto IN VARCHAR2,                  --> Documento
                                    pr_cdcritic OUT PLS_INTEGER,    --> Codigo de Erro
                                    pr_dscritic OUT VARCHAR2) IS              --> Descricao de Erro                                    
                                    
  BEGIN                           
                                      
    -- BUSCA REGISTRO REFERENTES A LOTES
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_dtmvtolt,
                    pr_cdagenci => pr_cdagenci);

    FETCH cr_craplot INTO rw_craplot;

    -- SE NÃO ENCONTRAR
    IF cr_craplot%NOTFOUND THEN
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- A primeira vez o sequencial do lote sera 0
      vr_nrseqdig := 0;
      -- CASO NAO ENCONTRE O LOTE, INSERE
      BEGIN
        INSERT INTO craplot
          (dtmvtolt,
           cdagenci,
           cdbccxlt,
           nrdolote,
           cdbccxpg,
           tplotmov,
           nrseqdig,
           cdcooper)
        VALUES
          (pr_dtmvtolt,
           pr_cdagenci,
           100, -- cdbccxlt
           6651, -- nrdolote
           11, -- cdbccxpg
           1, -- tplotmov
           vr_nrseqdig,
           pr_cdcooper)
        RETURNING craplot.dtmvtolt,
                  craplot.cdagenci,
                  craplot.cdbccxlt,
                  craplot.nrdolote,
                  craplot.cdbccxpg,
                  craplot.tplotmov,
                  craplot.cdcooper,
                  craplot.nrseqdig,
                  craplot.rowid
           INTO   rw_craplot.dtmvtolt,
                  rw_craplot.cdagenci,
                  rw_craplot.cdbccxlt,
                  rw_craplot.nrdolote,
                  rw_craplot.cdbccxpg,
                  rw_craplot.tplotmov,
                  rw_craplot.cdcooper,
                  rw_craplot.nrseqdig,
                  rw_craplot.rowid;

      -- VERIFICA SE HOUVE PROBLEMA NA INSERCAO DE REGISTROS
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao inserir na tabela craplot: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- INCREMENTAR sequencial do lote
      vr_nrseqdig := rw_craplot.nrseqdig + 1;
      -- se ja existe lote INCREMENTAR sequencial
      BEGIN
        UPDATE craplot
          SET nrseqdig = vr_nrseqdig
          WHERE craplot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao atualizar a tabela craplot: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;    

    -- BUSCA REGISTRO REFERENTES A LOTES
    OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_dtmvtolt,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrdocmto => pr_nrdocmto);

    FETCH cr_craplcm INTO rw_craplcm;

    -- SE NÃO ENCONTRAR
    IF cr_craplcm%NOTFOUND THEN
      -- FECHAR O CURSOR
      CLOSE cr_craplcm;
      BEGIN
        INSERT INTO craplcm
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdctabb,
             nrdocmto,
             cdhistor,
             vllanmto,
             nrseqdig,
             cdpesqbb,
             hrtransa) -- Gravar a hora da transação em segundos
        VALUES
          (pr_cdcooper,
           rw_craplot.dtmvtolt,
           1,    -- cdagenci
           100,  -- cdbccxlt
           6651, -- nrdolote
           pr_nrdconta,
           pr_nrdconta, -- nrdctabb
           pr_nrdocmto,
           pr_cdhistor,
           pr_vllanaut,
           nvl(rw_craplot.nrseqdig,0) + 1,
           'Lote ' || TO_CHAR(pr_dtmvtolt, 'dd') || '/' ||
           TO_CHAR(pr_dtmvtolt, 'mm') || '-' ||
           to_char(gene0002.fn_mask(pr_cdagenci, '999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.cdbccxlt, '999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.nrdolote, '999999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.nrseqdig, '99999'))  || '-' ||
           to_char(pr_nrdocmto),
           to_char(SYSDATE,'sssss'));

      -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao inserir na tabela craplcm: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- ATUALIZACAO DE REGISTROS DE LOTES
      BEGIN
        UPDATE craplot
           SET qtcompln = nvl(qtcompln,0) + 1,
               vlcompdb = nvl(vlcompdb,0) + nvl(pr_vllanaut,0),
               qtinfoln = nvl(qtinfoln,0) + 1,
               vlinfodb = nvl(vlinfodb,0) + nvl(pr_vllanaut,0),
               nrseqdig = nvl(nrseqdig,0) + 1
         WHERE craplot.rowid = rw_craplot.rowid;

      -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLOT: ' || sqlerrm;
          RAISE vr_exc_erro;
      END;

      BEGIN
        -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS CONFORME PARAMETROS
        UPDATE craplau
           SET insitlau = 2,
               dtdebito = rw_craplot.dtmvtolt
         WHERE craplau.cdcooper  = pr_cdcooper AND
               craplau.dtmvtopg <= pr_dtmvtolt AND
               craplau.insitlau  = 1           AND
               craplau.nrdconta  = pr_nrdconta AND
               to_char(craplau.nrdocmto) = pr_nrdocmto AND
               craplau.cdhistor = pr_cdhistor;

        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplau: '||SQLERRM;
          RAISE vr_exc_erro;
      END;  -- fim do update craplau
      
      -- Atualiza data do último débito da autorização
      OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdhistor => pr_cdhistor,
                      pr_cdrefere => pr_nrdocmto);
      FETCH cr_crapatr INTO rw_crapatr;

      IF cr_crapatr%NOTFOUND THEN
        -- FECHAR O CURSOR
        CLOSE cr_crapatr;
        -- retorna erro para procedure chamadora
        pr_dscritic := 'Autorizacao de debito nao encontrada.';
        RAISE vr_exc_erro;
      ELSE
        -- FECHAR O CURSOR
        CLOSE cr_crapatr;

        -- VERIFICA DATA DO ULTIMO DEBITO
        IF NVL(to_char(rw_crapatr.dtultdeb,'MMYYYY'),'0') <> to_char(pr_dtmvtolt,'MMYYYY') THEN
          BEGIN
            -- ATUALIZA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
            UPDATE crapatr
               SET dtultdeb = pr_dtmvtolt -- ATUALIZA DATA DO ULTIMO DEBITO
             WHERE ROWID = rw_crapatr.rowid;
          -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar registro na tabela CRAPATR: ' || sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;
    ELSE
      -- FECHAR O CURSOR DA CRAPLCM
      CLOSE cr_craplcm;
    END IF; -- fim do notfound craplcm
    
    -- Gravar as informações no banco
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
       pr_cdcritic := nvl(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado em sicr0002.pc_cria_lancamentos_debitos --> '||SQLERRM;

  END pc_cria_lancamentos_deb;

END sicr0002;
/

