CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS615" (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utiliza��o de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                    ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................

       Programa: pc_crps615 (Antigo >> Fontes/crps615.p)
       Sistema : CRED
       Autor   : Lucas/Oscar
       Data    : Nov/2011                     Ultima atualizacao: 19/02/2014
       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Gerar arquivo com saldo devedor dos emprestimos/Cred.Liquid.
                   Solicitacao : 2
                   Ordem do programa na solicitacao = 50.


       05/01/2012 - Renomeado o arquivo "crrl615" para "cadspc" (Tiago)

       13/01/2012 - Aumentado o format do campo crapspc.nrctremp. (Tiago)

       14/03/2012 - Listar todos os mesmos contratos SPC e Serasa. (Oscar)

       27/12/2012 - Gerar arquivo TXT para AltoVale (Evandro).

       08/03/2013 - Gerar arquivo TXT para Acredicoop (Evandro).

       12/06/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)

       13/12/2013 - Alterado valor da variavel aux_titcolum, de "CPF/CGC" para
                    "CPF/CNPJ". (Reinert)

       19/02/2014 - Convers�o para PL/SQL da altera��o de 12/2013. Altera��o na
                    ordena��o do cr_crapspc, inclu� o NLS_SORT.
    ............................................................................ */

    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca das informa��es de SPC/SERASA j� unindo com as informa��es do cooperado devedor
      cursor cr_crapspc is
        select decode(spc.tpidenti,
                      1, 'Dev1',
                      2, 'Dev2',
                      3, 'Fia1',
                      'Fia2') dsidenti,
               gene0002.fn_mask_conta(spc.nrdconta) nrdconta,
               gene0002.fn_mask(spc.nrcpfcgc, 'zzzzzzzzzzzzzz') nrcpfcgc,
               gene0002.fn_mask(spc.nrctremp, 'zz.zzz.zz9') nrctremp,
               spc.nrctrspc nrctrspc,
               to_char(dtinclus, 'dd/mm/rrrr') dtinclus,
               to_char(spc.vldivida, '999999G990d00') vldivida,
               decode(spc.tpinsttu,
                      1, 'SPC',
                      'SERASA') dsinsttu
          from crapass ass,
               crapspc spc
         where spc.cdcooper = ass.cdcooper
           and spc.nrdconta = ass.nrdconta
           and spc.cdcooper = pr_cdcooper --> Coop atual
           and spc.dtdbaixa is null --> Pendente
           and ass.cdagenci between 1 and 99999 --> Agencia valida
         order by ass.cdagenci,
                  spc.nrdconta,
                  spc.nrcpfcgc,
                  spc.nrctremp,
                  nlssort(spc.nrctrspc, 'NLS_SORT=BINARY_AI'),
                  spc.dtinclus;

      ----------------------------- VARIAVEIS ------------------------------

      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS615';
      -- Tratamento de erros
      vr_exc_erro exception;

      -- Variaveis para os XMLs e relat�rios
      vr_clobarq    CLOB;                   -- Clob para conter o dados do excel
      vr_dspathsaid VARCHAR2(4000);         -- Path completo para grava��o do arquivo

      -- Subrotina para escrever texto na vari�vel CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descri��o da cr�tica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Buscar caminho para sa�da do arquivo
      vr_dspathsaid := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS615_DESTINO');
      -- Se n�o houver par�metriza��o quer dizer que n�o � necess�ria a gera��o
      IF vr_dspathsaid IS NOT NULL THEN
        -- Inicializar as informa��es do arquivo de exporta��o de dados
        dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobarq,'Ident.  ;  Conta/DV;      CPF/CNPJ;  Contrato;Nr.ContrSPC;Data Inclc;Valr.da Divida; Instit.;'||chr(10));
        -- Efetuar a varredura dos devedores na tabela CRAPSPC
        FOR rw_crapspc IN cr_crapspc LOOP
          -- Adicionamos tamb�m as informa��es para o arquivo de exporta��o de dados
          pc_escreve_clob(vr_clobarq,RPAD(rw_crapspc.dsidenti,8,' ')||';'
                                   ||rw_crapspc.nrdconta||';'
                                   ||rw_crapspc.nrcpfcgc||';'
                                   ||rw_crapspc.nrctremp||';'
                                   ||RPAD(rw_crapspc.nrctrspc,11,' ')||';'
                                   ||rw_crapspc.dtinclus||';'
                                   ||rw_crapspc.vldivida||';'
                                   ||RPAD(rw_crapspc.dsinsttu,8,' ')||';'
                                   ||chr(10));
        END LOOP;
        -- Submeter a gera��o do arquivo txt puro
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra                       --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarq                        --> Arquivo XML de dados
                                           ,pr_cdrelato  => '615'                             --> C�digo do relat�rio
                                           ,pr_dsarqsaid => gene0001.fn_diretorio('C',pr_cdcooper,'rl')||'/cadspc.lst'  --> Arquivo final com o path
                                           ,pr_dspathcop => vr_dspathsaid                     --> Caminho de c�pia
                                           ,pr_fldoscop  => 'S'                               --> Converter para DOS
                                           ,pr_dsextcop  => 'txt'                             --> Converter para txt
                                           ,pr_flg_gerar => 'N'                               --> Gera�ao na hora
                                           ,pr_des_erro  => pr_dscritic);                     --> Sa�da com erro
        -- Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_clobarq);
        dbms_lob.freetemporary(vr_clobarq);
        -- Testar se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exce��o
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps615;
/

