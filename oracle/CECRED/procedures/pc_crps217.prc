CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS217
                   (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Coop conectada
									 ,pr_flgresta  IN PLS_INTEGER           --> Flag padrão para utilização de restart
                   ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                   ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
									 ,pr_dscritic OUT VARCHAR2) AS          --> Texto de erro/critica encontrada
    /*  ..........................................................................

      Programa : pc_crps217 (Antigo Fontes/crps217.p)
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Edson
      Data    : Dezembro/1997.                   Ultima atualizacao: 13/09/2016

      Dados referentes ao programa:

       Frequencia: Mensal (Batch - Background).
       Objetivo  : Emitir extrato de conta corrente (laser)
                   Solicitacao: 2
                   Ordem: 3
                   Relatorio: 171
                   Tipo Documento: 7
                   Formulario: Extrato-laser.

       Alteracoes: 29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

                   10/09/98 - Tratar tipo de conta 7 (Deborah).

                   16/10/98 - Colocar "pesos" na leitura por agencia (Deborah).

                   22/01/99 - Tratar historico 313 (Odair)

                   24/06/99 - Tratar historicos 338,340 (odair)

                   02/08/99 - Alterado para ler a lista de historicos de uma tabela
                              (Edson).

                   24/07/2000 - Acerto no acesso da tabela que estava comentado
                                (Deborah).

                   03/10/2000 - Alterar forma saida do arquivo (Margarete/Planner)

                   22/11/2000 - Alterar leitura do crapass (Margarete/Planner)

                   19/12/2000 - Nao gerar automaticamente o pedido de impressao.
                                (Eduardo).

                   03/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                                numero do documento. (Eduardo).

                   12/01/2001 - Mostrar no extrato de c/c as taxas de juros
                                utilizadas. (Eduardo).

                   17/09/2001 - Aumentar o campo nrdocmto para 11 histor. 040
                                (Ze Eduardo).

                   31/07/2002 - Incluir nova situacao da conta (Margarete).

                   26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                                o cdpesqbb. (Ze Eduardo).

                   07/04/2003 - Incluir tratamento do histor 399 (Margarete).

                   21/05/2003 - Alterado para tratar os historicos 104, 302 e 303
                                (Edson).

                   27/06/2003 - Incluir 156 na descricao do historico (Ze).

                   17/07/2003 - Antecipado a quinzena do dia 15/08/03 para
                                14/08/2003 devido a manutencao (Deborah).

                   29/01/2004 - Nao emite extrato para situacao de conta 6
                                Nao emite extrato para tipo de extrato 0
                                Colocado mensagem para solicitar o cancelamento
                                do extrato mensal (Deborah).

                   16/02/2004 - Colocado mensagem padronizada (Deborah).

                   25/04/2005 - Incluido, na linha do "EXTERNO" o nro do cadastro
                                do cooperado na empresa (Evandro).

                   08/06/2005 - Incluido tipo de conta 17 e 18(Mirtes).

                   07/11/2005 - Nova mensagem no rodape (Margarete).

                   22/11/2005 - Alterado para mostrar a alinea na descricao do
                                historico 657 (Edson).

                   22/12/2005 - Voltada mensagem anterior do rodape (Magui)

                   30/01/2006 - Colocada temporariamente a mensagem dos telefones
                                para a URA (Evandro).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   05/05/2006 - Alterada mensagem p/Viacredi(Mirtes)

                   27/12/2006 - Alterado de FormXpress para FormPrint (Julio)

                   18/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).

                   30/05/2007 - Colocado o parametro  no comando FormPrint, para
                                rodar em Back Ground e liberar o processo (Julio).

                   04/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

                   05/06/2007 - Envio de Informativos por Email (Diego).

                   24/07/2007 - Incluidos historicos de transferencia pela internet
                                (Evandro).

                   06/08/2007 - Incluido tratamento para informativos Impressos e
                                enviados por Email (Diego).

                   12/09/2007 - Efetuado acerto no Envio de Extrato por E-mail.
                                Utilizar crapass.cdsitdct = 1 somente para extratos
                                impressos (Diego).

                   17/09/2007 - USE-INDEX crapcra1 nas buscas do crapcra (Julio)

                   31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao (Guilherme).

                   21/01/2008 - Efetuado acerto para enviar extrato quinzenal
                                impresso ao final do mes (Diego).
                                Envio automatico de arquivos para PostMix (Julio)

                   13/02/2008 - Chamar nova include "gera_dados_inform_2_postmix.i"
                                (Diego).

                   06/02/2008 - Inclusao da include
                                sistema/generico/includes/b1wgen0001tt.i
                                (Diego).

                   17/03/2008 - Incluidos parametros na procedure "consulta-extrato"
                                (Diego).

                   27/03/2008 - Acerto no envia do arquivo para a PostMix. (Julio)

                   16/04/2008 - Chamar nova includes "envia_dados_postmix.i"
                                e incluir linha tracejada no final dos lancamentos
                                (Gabriel).

                   07/08/2008 - Substituida variavel aux_nrfonura pelo campo
                                crapcop.nrtelura (Diego).

                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                                includes/var_informativos.i (Diego).

                   03/03/2009 - Acerto na chamada da BO b1wgen0001 (Diego).

                   29/04/2009 - Enviar aux_nmdatspt para vendas@blucopy.com.br
                                das cooperativas 1,2,4 Tarefa: 23747 (Guilherme)
                              - Enviar tambem para variaveis@blucopy.com.br
                               (Evandro).

                   09/09/2009 - Tratamento para quebra de pagina do Extrato enviado
                                por e-mail (Diego).
                              - Incluir historicos de transferencia de credito de
                                salario (David).

                   07/12/2009 - Acerto na apresentacao das mensagens no rodape do
                                extrato (Junior).

                   08/01/2010 - Acrescentar historico 573 NO mesmo CAN-DO do 338
                                (Guilherme/Precise)

                   22/04/2010 - Gravar o PAC do associado na cratext.
                                Unificacao das includes que geram os dados
                                (Gabriel).

                   19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                                (Diego).

                   01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl"
                                (Vitor).

                   15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                                na leitura e gravacao dos arquivos (Elton).

                   12/01/2011 - Verificar se registro de e-mail foi encontrado.
                                Mostrar no log se e-mail nao existir (David).

                   03/02/2011 - Ajuste do format do numero do documento (Henrique).

                   14/03/2011 - Substituir dsdemail da ass para a crapcem (Gabriel).

                   04/06/2011 - Mehorias de performance (Magui).

                   12/12/2011 - Alteração no campo de Assunto dos email enviados (Lucas).

                   04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                                do prefixo "banco" (Guilherme Maba).

                   28/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).

                   10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                                do histórico em extratos (Lucas) [Projeto Tarifas].

                   21/11/2012 - Conversão da rotina para Oracle PLSQL (Marcos - Supero)

                   26/06/2013 - Ajustes na chamada do envio de extratos a engecopy, pois
                                a rotina foi generalizada para permitir utilização por
                                outros programas e não somente este (Marcos-Supero)

                   09/08/2013 - Troca da busca do mes por extenso com to_char para
                                utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                   27/08/2013 - Ajustes na chamada a extr0001.fn_format_nrdocmto_extr
                                devido a criação de novos parametros após liberacao das
                                transferencias entre contas (Marcos-Supero)

                   10/10/2013 - Ajuste para tratamento de criticas (Gabriel).

                   12/11/2013 - Retirada da remoção dos arquivos da pasta salvar
                                após envio a Engecopy/Postmix (Marcos-Supero)

                   15/01/2014 - Ajustada a leitura do cursor cr_crapepr, onde o campo
                                craplcm.cdpesqbb estava sendo passado para comparação
                                com o crapepr.nrctremp, com a mascara do empréstimo, o
                                que causava invalid number (Marcos-Supero)
                                
                   25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                                na critica 347. (Jaison/Diego - SD: 365193)
                                
                   03/08/2016 - Retirado processo de geração de arquivo para impressao.
                                Ajuste leitura CRAPTAB (Daniel)   
                                
                   13/09/2016 - Reestruturado o programa para efetuar apenas envio de 
                                extrato por e-mail, alterado forma de leitura da crapass 
                                e retirado todas procedures e variaveis não utilizadas (Daniel)                       

                   06/03/2018 - Alterada verificação "cdtipcta NOT IN (0,5, 6, 7, 17, 18)" para
                                modalidade do tipo de conta diferente de 2 e 3. PRJ366 (Lombardi).

    -- ............................................................................. **/
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros parando a cadeia
      vr_exc_saida EXCEPTION;
      -- Tratamento de erros sem parar a cadeia
      vr_exc_fimprg EXCEPTION;

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Cursor genérico de parametrização
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
              ,tab.ROWID
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;
      
      
      -- Lançamentos na conta do associado
      CURSOR cr_craplcm(pr_cdcooper  IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta  IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  --> Data movimento atual
                       ,pr_dtsdexes  IN crapsld.dtsdexes%TYPE  --> Data Referência extrato
                       ,pr_lsthistor_ret IN VARCHAR2 DEFAULT NULL     --> Lista com códigos de histórico a retornar
                       ,pr_lsthistor_ign IN VARCHAR2 DEFAULT NULL) IS --> Lista com códigos de histórico a ignorar
            SELECT lcm.dtmvtolt
                  ,lcm.cdhistor
                  ,lcm.cdpesqbb
                  ,lcm.nrdocmto
                  ,lcm.nrparepr
                  ,lcm.vllanmto
                  ,his.dsextrat
                  ,his.indebcre
                  ,his.inhistor
                  ,lcm.nrdctabb
              FROM craphis his
                  ,craplcm lcm
             WHERE lcm.cdcooper = his.cdcooper
               AND lcm.cdhistor = his.cdhistor
               AND lcm.cdcooper = pr_cdcooper
               AND lcm.nrdconta = pr_nrdconta
               AND lcm.dtmvtolt > pr_dtsdexes
               AND lcm.dtmvtolt <= pr_dtmvtolt
               AND ( pr_lsthistor_ret IS NULL OR ','||pr_lsthistor_ret||',' LIKE ('%,'||lcm.cdhistor||',%') )      --> Retornar quando passado
               AND ( pr_lsthistor_ign IS NULL OR ','||pr_lsthistor_ign||',' NOT LIKE ('%,'||lcm.cdhistor||',%') ); --> Ignorar quando passado
      
      -- Busca de lançamentos no mês para a conta do associado
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- Verifica se a conta solicitou este Extrato via EMAIL
      CURSOR cr_crapcra(pr_nrdconta IN crapass.nrdconta%TYPE) IS--> Se deve validar o período sim ou não
        SELECT cra.cdperiod
              ,cra.cddfrenv
              ,cra.idseqttl
              ,cra.cdseqinc
              ,cra.cdprogra
              ,cra.cdrelato
          FROM crapcra cra
         WHERE cra.cdcooper = pr_cdcooper
           AND cra.nrdconta = pr_nrdconta
           AND cra.cdprogra = 217
           AND cra.cdrelato = 171
           AND cra.cdperiod IN(2,3); --> Nem sempre validará o período
      rw_crapcra cr_crapcra%ROWTYPE;
      
      -- Verifica se a conta solicitou este Extrato via EMAIL
      CURSOR cr_crapass(pr_dtultdma IN crapdat.dtmvtolt%TYPE) IS--> Se deve validar o período sim ou não
        SELECT cra.cdperiod
              ,cra.cddfrenv
              ,cra.idseqttl
              ,cra.cdseqinc
              ,cra.cdprogra
              ,cra.cdrelato
              ,ass.nrdconta
              ,ass.inpessoa
              ,ass.tpextcta
              ,ass.cdsitdct
              ,ass.vllimcre
              ,ass.nmprimtl
              ,ass.cdagenci
              ,ass.cdsecext
          FROM crapcra cra
              ,crapass ass
              ,tbcc_tipo_conta tpcta
         WHERE cra.cdcooper = pr_cdcooper
           AND cra.cdprogra = 217
           AND cra.cdrelato = 171
           AND ass.cdcooper = cra.cdcooper
           AND ass.nrdconta = cra.nrdconta
           AND ass.inpessoa = tpcta.inpessoa
           AND ass.cdtipcta = tpcta.cdtipo_conta
           AND tpcta.cdmodalidade_tipo NOT IN(2,3)
           -- Cooperado ainda esteja ativo OU estava no mês passado OU seja da Cooperativa 3 - Cecred
           AND(ass.dtdemiss IS NULL OR ass.dtdemiss > pr_dtultdma OR pr_cdcooper = 3);
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crapttl(pr_nrdconta IN crapttl.nrdconta%TYPE) IS
        SELECT ttl.cdempres
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = 1; -- Primeiro titular
      rw_crapttl cr_crapttl%ROWTYPE;
      
      CURSOR cr_crapjur(pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT jur.cdempres
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      
      -- Busca de informações e referência do saldo do associado
      CURSOR cr_crapsld(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT sld.dtsdexes
              ,nvl(sld.vlsdexes,0)    vlsdexes
              ,nvl(sld.vlsmstre##1,0) vlsmstre##1
              ,nvl(sld.vlsmstre##2,0) vlsmstre##2
              ,nvl(sld.vlsmstre##3,0) vlsmstre##3
              ,nvl(sld.vlsmstre##4,0) vlsmstre##4
              ,nvl(sld.vlsmstre##5,0) vlsmstre##5
              ,nvl(sld.vlsmstre##6,0) vlsmstre##6
          FROM crapsld sld
         WHERE sld.cdcooper = pr_cdcooper
           AND sld.nrdconta = pr_nrdconta;
      rw_crapsld cr_crapsld%ROWTYPE;
      
      -- Busca do nome do relatório
      CURSOR cr_gnrlema IS
        SELECT nmrelato
          FROM gnrlema
         WHERE cdprogra = 217
           AND cdrelato = 171;
      vr_nmrelato gnrlema.nmrelato%TYPE;
      
      -- Busca das cotas do associado
      CURSOR cr_crapcot(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cot.vldcotas
          FROM crapcot cot
         WHERE cot.cdcooper = pr_cdcooper
           AND cot.nrdconta = pr_nrdconta;
      
      -- Listagem de históricos de movimento de cheques
      vr_lshistor craptab.dstextab%TYPE;
      -- Controle de fechamento mensal
      vr_flgmensa BOOLEAN;
      
      vr_impresso_mensal    BOOLEAN;
      vr_impresso_quinzenal BOOLEAN;
        
      -- Vetor para armazenar as informações da tabela de extratos por e-mail
      vr_tab_env_extrato EXTR0001.typ_tab_env_extrato;
      -- Indice para o vetor
      vr_ind_env_extrato BINARY_INTEGER;

      -- Valores de saldo médio mes, trimestral e capital
      vr_vlsmdmes NUMBER(10,2);
      vr_vlsmtrim NUMBER(10,2);
      vr_vltotcap NUMBER(18,2);
      
      -- Vetor com 5 linhas para montagem de mensagens no informativo
      vr_vet_msg_rodape FORM0001.typ_msg_rodape := FORM0001.typ_msg_rodape('','','','',''); --> declara um vetor com o tipo criado e já o inicializa

      vr_cdcritic crapcri.cdcritic%TYPE;     --> Codigo da critica
      vr_dscritic VARCHAR2(2000);            --> Descricao da critica
      
      vr_cdempres crapttl.cdempres%TYPE;

      -- Subprocedimento para envio do extrato por e-mail
      PROCEDURE pc_prepara_envio_extrato(pr_rw_crapass IN cr_crapass%ROWTYPE) IS
      BEGIN
        DECLARE
          -- Busca dos e-mails cadastrados na conta
          CURSOR cr_crapcem(pr_idseqttl IN crapcem.idseqttl%TYPE
                           ,pr_cdseqinc IN crapcem.cddemail%TYPE) IS
            SELECT cem.cddemail
                  ,cem.dsdemail
              FROM crapcem cem
             WHERE cem.cdcooper = pr_cdcooper
               AND cem.nrdconta = pr_rw_crapass.nrdconta
               AND cem.idseqttl = pr_idseqttl --> Seq do titular
               AND cem.cddemail = pr_cdseqinc;
          rw_crapcem cr_crapcem%ROWTYPE;
        BEGIN
          -- Retornar a parametrização de recebimento do extrato do cooperado
          FOR rw_crapcra IN cr_crapcra(pr_nrdconta => pr_rw_crapass.nrdconta) LOOP
            
            -- Não continuar Se estiver parametrizado para receber somente
            -- no fechamento E não estivermos processando o fechamento
            IF (rw_crapcra.cdperiod = 3 AND vr_flgmensa) OR rw_crapcra.cdperiod <> 3 THEN
              
              -- Buscar parametrização conforme o formulário de envio encontrado na CRAPCRA
              rw_craptab := NULL;
              OPEN cr_craptab(pr_cdcooper => 0
                             ,pr_nmsistem => 'CRED'
                             ,pr_tptabela => 'USUARI'
                             ,pr_cdempres => 11
                             ,pr_cdacesso => 'FORENVINFO'
                             ,pr_tpregist => rw_crapcra.cddfrenv);
              FETCH cr_craptab
               INTO rw_craptab;
              CLOSE cr_craptab;
              
              -- Se o valor após a virgula do campo dstextab for CRAPCEM (Cadastro de e-mail)
              IF UPPER(substr(rw_craptab.dstextab,instr(rw_craptab.dstextab,',')+1)) = 'CRAPCEM' THEN
                
                -- Buscar o cadastro de e-mail da conta conforme a
                -- parametrização do extrato do cooperado e seus dependentes (CRAPCRA)
                OPEN cr_crapcem(pr_idseqttl => rw_crapcra.idseqttl --> Seq do titular
                               ,pr_cdseqinc => rw_crapcra.cdseqinc);
                FETCH cr_crapcem
                 INTO rw_crapcem;
                -- Se encontrar
                IF cr_crapcem%FOUND THEN
                  
                  -- Fechar cursor
                  CLOSE cr_crapcem;
                  
                  -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
                  vr_ind_env_extrato := vr_tab_env_extrato.COUNT()+1;
                  
                  -- Criar um registro no vetor de extratos a enviar
                  vr_tab_env_extrato(vr_ind_env_extrato).nrdconta := pr_rw_crapass.nrdconta;
                  vr_tab_env_extrato(vr_ind_env_extrato).idseqttl := rw_crapcra.idseqttl;
                  vr_tab_env_extrato(vr_ind_env_extrato).nmprimtl := pr_rw_crapass.nmprimtl;
                  vr_tab_env_extrato(vr_ind_env_extrato).informat := rw_crapcra.cdrelato ||'-'|| vr_nmrelato;
                  vr_tab_env_extrato(vr_ind_env_extrato).cdendere := rw_crapcem.cddemail;
                  vr_tab_env_extrato(vr_ind_env_extrato).dsdemail := rw_crapcem.dsdemail;
                  vr_tab_env_extrato(vr_ind_env_extrato).cdperiod := rw_crapcra.cdperiod;
                  vr_tab_env_extrato(vr_ind_env_extrato).formaenv := rw_crapcra.cddfrenv;
                  vr_tab_env_extrato(vr_ind_env_extrato).vllimcre := pr_rw_crapass.vllimcre;
                  vr_tab_env_extrato(vr_ind_env_extrato).vltotcap := vr_vltotcap;
                  vr_tab_env_extrato(vr_ind_env_extrato).vlsmdmes := vr_vlsmdmes;
                  vr_tab_env_extrato(vr_ind_env_extrato).vlsmtrim := vr_vlsmtrim;
                  vr_tab_env_extrato(vr_ind_env_extrato).msgemail(1) := vr_vet_msg_rodape(1);
                  vr_tab_env_extrato(vr_ind_env_extrato).msgemail(2) := vr_vet_msg_rodape(2);
                  vr_tab_env_extrato(vr_ind_env_extrato).msgemail(3) := vr_vet_msg_rodape(3);
                ELSE
                  -- Fechar cursor
                  CLOSE cr_crapcem;
                  
                  -- Adicionar crítica 812 no log
                  BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 1 -- Processo normal
                                            ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || '--> '||gene0001.fn_busca_critica(pr_cdcritic => 812)||' Conta: '||rw_crapass.nrdconta);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END;
      END pc_prepara_envio_extrato;


      -- Procedimento que adiciona as taxas na mensagem do informativo
      PROCEDURE pc_lista_taxas_mensag(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_cdprogra       IN crapprg.cdprogra%TYPE --> Código do programa
                                     ,pr_nrdconta       IN crapass.nrdconta%TYPE --> Conta do associado
                                     ,pr_dtsdexes       IN crapsld.dtsdexes%TYPE --> Data fechamento do saldo
                                     ,pr_flgmensa       IN BOOLEAN               --> Indicador fechamento mensal
                                     ,pr_vet_msg_rodape IN OUT FORM0001.typ_msg_rodape --> Vetor com mensagens internas do extrato
                                     ) IS
      BEGIN
        --   Objetivo  : Adicionar nas 5 linhas de informativo do extrato
        --               as taxas aplicas na conta em caso de terem ocorrido
        --   Alteracoes:
        DECLARE
          -- Indicador de contador do historico :
          -- 1 Para > 38 JUROS LIM.CRD.
          -- 2 Para > 57 JR.SAQ.DEP.BL
          -- 3 Para > 37 TAXA C/C NEG
          vr_conthist INTEGER;
          -- Linha de crédito
          vr_cdlcremp craplim.cddlinha%TYPE;
          -- Busca de linha de crédito em contratos de limite de crédito
          CURSOR cr_craplim(pr_insitlim IN craplim.insitlim%TYPE
                           ,pr_dtfimvig IN craplim.dtfimvig%TYPE DEFAULT NULL) IS
            SELECT lim.cddlinha
              FROM craplim lim
             WHERE lim.cdcooper = pr_cdcooper
               AND lim.nrdconta = pr_nrdconta
               AND lim.tpctrlim = 1
               AND lim.insitlim = pr_insitlim
               -- Ou não foi enviada data mínima de vigência OU a data de fim
               -- da vigência do contrato deve ser maior ou igual a enviada
               AND (pr_dtfimvig IS NULL OR lim.dtfimvig >= pr_dtfimvig)
             ORDER BY lim.dtfimvig DESC; --> Ordenar pelo ultimo vigente
          -- Busca das taxas lançadas na conta
          -- Já no formato:
          -- XXXXXXXXXXXXXXXXXXXXXXXXXXXXX:   9.99% a.m.
          CURSOR cr_craptax(pr_tpdetaxa IN craptax.tpdetaxa%TYPE) IS
            SELECT RPAD(RTRIM(LTRIM(tax.dslcremp)),30,'.')||': '||LPAD(TO_CHAR(tax.txmensal,'fm0d00'),5,' ')||'% a.m.'
              FROM craptax tax
             WHERE tax.cdcooper = pr_cdcooper
               AND tax.cdlcremp = vr_cdlcremp
               AND tax.tpdetaxa = pr_tpdetaxa+1
               AND tax.dtmvtolt = pr_dtmvtolt;
        BEGIN
          -- Somente continuar se for um processamento de fechamento de mês
          IF pr_flgmensa THEN
            -- Buscar os lançamentos de juros e taxas no mês
            -- Históricos:
            -- -- --------------
            -- 37 TAXA C/C NEG.
            -- 38 JUROS LIM.CRD
            -- 57 JR.SAQ.DEP.BL
            FOR rw_craplcm IN cr_craplcm(pr_cdcooper      => pr_cdcooper
                                        ,pr_nrdconta      => pr_nrdconta
                                        ,pr_dtmvtolt      => pr_dtmvtolt  --> Data movimento atual
                                        ,pr_dtsdexes      => pr_dtsdexes  --> Data Referência extrato
                                        ,pr_lsthistor_ret => '38,37,57') LOOP --> Trazer somente destes histórios
              -- Povoar o indice do histórico cfme o tipo
              IF rw_craplcm.cdhistor = 38 THEN
                vr_conthist := 1;
              ELSIF rw_craplcm.cdhistor = 57 THEN
                vr_conthist := 2;
              ELSE
                vr_conthist := 3;
              END IF;
              -- Linha de desconto valor default
              vr_cdlcremp := 0;
              -- Para juros do Cheque Especial
              IF rw_craplcm.cdhistor = 38 THEN
                -- Buscar a linha de desconto caso tenha contrato de
                -- limite de crédito ativo (insitlim = 2)
                OPEN cr_craplim(pr_insitlim => 2);
                FETCH cr_craplim
                 INTO vr_cdlcremp;
                -- Se não encontrar
                IF cr_craplim%NOTFOUND THEN
                  -- Fecha o cursor
                  CLOSE cr_craplim;
                  -- Buscar algum contrato cancelado, desde que sua data de fim
                  -- de vigência seja superior a data do saldo da conta
                  OPEN cr_craplim(pr_insitlim => 3
                                 ,pr_dtfimvig => pr_dtsdexes);
                  FETCH cr_craplim
                   INTO vr_cdlcremp;
                  CLOSE cr_craplim;
                ELSE
                  -- Apenas fecha o cursor
                  CLOSE cr_craplim;
                END IF;
              END IF;
              -- Buscar a descrição de nome da taxa lançada no dia corrente mais o valor
              -- para a linha de crédito encontrada e para o tipo de taxa da interação
              OPEN cr_craptax(pr_tpdetaxa => vr_conthist);
              FETCH cr_craptax
               INTO pr_vet_msg_rodape(vr_conthist);
              -- Se encontrar a taxa
              IF cr_craptax%FOUND THEN
                -- Apenas fechar cursor
                CLOSE cr_craptax;
              ELSE
                -- Fechar o cursor
                CLOSE cr_craptax;
                -- Adicionar a crítica 347 no log
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                          ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| pr_cdprogra || ' --> '||
                                                              GENE0001.fn_busca_critica(pr_cdcritic => 347)||
                                                              ' Tipo de taxa: '||(vr_conthist+1)||
                                                              ' Linha de Cred.: '||vr_cdlcremp);
                -- Limpar a linha do histórico
                pr_vet_msg_rodape(vr_conthist) := '';
              END IF;
            END LOOP;
          END IF;
        END;
      END pc_lista_taxas_mensag;

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS217';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS217'
                                ,pr_action => '');
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Buscar histórico de cheques
      rw_craptab := NULL;
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => 0
                     ,pr_cdacesso => 'HSTCHEQUES'
                     ,pr_tpregist => 0);
      FETCH cr_craptab
       INTO rw_craptab;
      -- Se encontrar
      IF cr_craptab%FOUND THEN
        -- Guardar na variável a lista de históricos permitida
        -- NEste campo da tabela está gravado uma lista separada
        -- por vírgula dos históricos, ex: "21,23,46..."
        vr_lshistor := rw_craptab.dstextab;
      ELSE
        -- Usar opção genérica
        vr_lshistor := '999';
      END IF;
      -- Fechar cursor
      CLOSE cr_craptab;
      
      -- Testar fechamento do mês
      IF TRUNC(rw_crapdat.dtmvtolt,'mm') <> TRUNC(rw_crapdat.dtmvtopr,'mm') THEN
        -- Ativar varíavel de controle mensal
        vr_flgmensa := TRUE;
      ELSE
        -- Buscar se existe extrato quinzenal para a cooperativa
        rw_craptab := NULL;
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'GENERI'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'EXEQUINZEN'
                       ,pr_tpregist => 1);
        FETCH cr_craptab
         INTO rw_craptab;
        -- Se não encontrar
        IF cr_craptab%NOTFOUND THEN
          -- Fechar cursor
          CLOSE cr_craptab;
          -- Montar mensagem de critica
          vr_cdcritic := 571;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CRED-GENERI-00-EXEQUINZEN-001';
          RAISE vr_exc_saida;
        ELSE
          -- Fechar cursor
          CLOSE cr_craptab;
          -- Somente continuar se o valor setado for igual a zero
          -- A o dia atual já ultrapassou o dia 15 do mês
          IF rw_craptab.dstextab = '0' AND to_char(rw_crapdat.dtmvtopr,'dd') > 15 THEN
            -- Desativar varíavel de controle mensal
            vr_flgmensa := FALSE;
          ELSE
            -- Encerrar o processo, não é necessária a geração dos extratos
            RAISE vr_exc_fimprg;
          END IF;
        END IF;
      END IF;
      
      -- Busca do nome do relatório para envio de e-mail posterior
      OPEN cr_gnrlema;
      FETCH cr_gnrlema
       INTO vr_nmrelato;
      CLOSE cr_gnrlema;
      
      -- Inicializar variáveis necessárias
      vr_tab_env_extrato.DELETE;
  
      FOR rw_crapass IN cr_crapass(pr_dtultdma => rw_crapdat.dtultdma) LOOP  
        
        -- Para cada associoado encontrado, limpar variáveis gerais
        vr_vltotcap           := 0;
        vr_vlsmtrim           := 0;
        vr_vlsmdmes           := 0;
        vr_cdempres           := NULL;    
        vr_impresso_mensal    := FALSE;
        vr_impresso_quinzenal := FALSE;
        
        -- E o tipo de extrato é mensal ou quinzenal
        IF vr_flgmensa AND rw_crapass.tpextcta IN(1,2) THEN
          -- Ativar impressão mensal
          vr_impresso_mensal := TRUE;
        END IF;
        -- Se não estamos processando o fechamento
        -- E o tipo de extrato é quinzenal
        IF NOT vr_flgmensa AND rw_crapass.tpextcta = 2 THEN
          -- Ativa impressão quinzenal
          vr_impresso_quinzenal := TRUE;
        END IF;  
        
        IF ( NOT vr_impresso_mensal AND NOT vr_impresso_quinzenal)
            OR ( rw_crapass.cdsitdct = 1 ) THEN
            -- Se cooperado optou apenas por envio por e-mail deve continuar.
            NULL;
        ELSE
           -- Proximo Registro 
           CONTINUE;
        END IF;
                                 
        IF rw_crapass.inpessoa = 1 THEN
           
           OPEN cr_crapttl(pr_nrdconta => rw_crapass.nrdconta);
           FETCH cr_crapttl
           INTO rw_crapttl;
         
           -- Se encontrar
           IF cr_crapttl%FOUND THEN
             vr_cdempres := rw_crapttl.cdempres;
           END IF;
        
           -- Fechar o cursor
           CLOSE cr_crapttl;

        ELSE
           OPEN cr_crapjur(pr_nrdconta => rw_crapass.nrdconta);
           FETCH cr_crapjur
           INTO rw_crapjur;
         
           -- Se encontrar
           IF cr_crapjur%FOUND THEN
             vr_cdempres := rw_crapjur.cdempres;
           END IF;
        
           -- Fechar o cursor
           CLOSE cr_crapjur;
        END IF;                                  
                                          
        -- Validar se o associado teve movimentação no mês
        -- Primeiramente buscamos informações e referência do saldo do associado
        rw_crapsld := NULL;
        OPEN cr_crapsld(pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapsld
         INTO rw_crapsld;
        CLOSE cr_crapsld;
        -- Verifica se existe lançamento no mês para a conta
        OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crapass.nrdconta
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data movimento atual
                       ,pr_dtsdexes => rw_crapsld.dtsdexes); --> Data Referência extrato
        FETCH cr_craplcm
         INTO rw_craplcm;
        -- Somente continuar se o associado teve lancamentos no mes, caso contrario nao imprime o extrato
        IF cr_craplcm%FOUND THEN
          -- Fechar o cursor e continuar o processo
          CLOSE cr_craplcm;
          -- Para impressão no fechamento mensal
          IF vr_flgmensa THEN
            -- Saldo do trimestre e do mês conforme o mês atual do movimento
            -- Janeiro ou Julho
            IF to_char(rw_crapdat.dtmvtolt,'mm') IN (1,7) THEN
              -- Utilizar campos 1,6,5
              vr_vlsmtrim := (rw_crapsld.vlsmstre##1 + rw_crapsld.vlsmstre##6 + rw_crapsld.vlsmstre##5) / 3;
              -- Saldo mês está no campo 1
              vr_vlsmdmes := rw_crapsld.vlsmstre##1;
            -- Fevereiro ou Agosto
            ELSIF to_char(rw_crapdat.dtmvtolt,'mm') IN (2,8) THEN
              -- Utilizar campos 2,1,6
              vr_vlsmtrim := (rw_crapsld.vlsmstre##2 + rw_crapsld.vlsmstre##1 + rw_crapsld.vlsmstre##6) / 3;
              -- Saldo mês está no campo 2
              vr_vlsmdmes := rw_crapsld.vlsmstre##2;
            -- Março ou Setembro
            ELSIF to_char(rw_crapdat.dtmvtolt,'mm') IN (3,9) THEN
              -- Utilizar campos 3,2,1
              vr_vlsmtrim := (rw_crapsld.vlsmstre##3 + rw_crapsld.vlsmstre##2 + rw_crapsld.vlsmstre##1) / 3;
              -- Saldo mês está no campo 3
              vr_vlsmdmes := rw_crapsld.vlsmstre##3;
            -- Abril ou Outubro
            ELSIF to_char(rw_crapdat.dtmvtolt,'mm') IN (4,10) THEN
              -- Utilizar campos 4,3,2
              vr_vlsmtrim := (rw_crapsld.vlsmstre##4 + rw_crapsld.vlsmstre##3 + rw_crapsld.vlsmstre##2) / 3;
              -- Saldo mês está no campo 4
              vr_vlsmdmes := rw_crapsld.vlsmstre##4;
            -- Maio ou Novembro
            ELSIF to_char(rw_crapdat.dtmvtolt,'mm') IN (5,11) THEN
              -- Utilizar campos 5,4,3
              vr_vlsmtrim := (rw_crapsld.vlsmstre##5 + rw_crapsld.vlsmstre##4 + rw_crapsld.vlsmstre##3) / 3;
              -- Saldo mês está no campo 5
              vr_vlsmdmes := rw_crapsld.vlsmstre##5;
            ELSE -- Junho ou Dezembro
              -- Utilizar campos 6,5,4
              vr_vlsmtrim := (rw_crapsld.vlsmstre##6 + rw_crapsld.vlsmstre##5 + rw_crapsld.vlsmstre##4) / 3;
              -- Saldo mês está no campo 6
              vr_vlsmdmes := rw_crapsld.vlsmstre##6;
            END IF;
            -- Buscar informações de cotas da conta
            OPEN cr_crapcot(pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_crapcot
             INTO vr_vltotcap;
            CLOSE cr_crapcot;
          ELSE
            --  Zerar valores de saldo mes, trimestre e capital
            vr_vltotcap := 0;
            vr_vlsmtrim := 0;
            vr_vlsmdmes := 0;
          END IF;
            
          -- Limpar o vetor de tipos de taxa e de mensagens do informativo
          vr_vet_msg_rodape := FORM0001.typ_msg_rodape('','','','','');
            
           
          -- Chamar procedimento que adiciona as taxas na mensagem do informativo
          pc_lista_taxas_mensag(pr_cdcooper       => pr_cdcooper              --> Cooperativa
                               ,pr_dtmvtolt       => rw_crapdat.dtmvtolt      --> Movimento atual
                               ,pr_cdprogra       => vr_cdprogra              --> Código do programa
                               ,pr_nrdconta       => rw_crapass.nrdconta      --> Conta do associado
                               ,pr_dtsdexes       => rw_crapsld.dtsdexes      --> Data fechamento do saldo
                               ,pr_flgmensa       => vr_flgmensa              --> Indicador fechamento mensal
                               ,pr_vet_msg_rodape => vr_vet_msg_rodape);      --> Vetor em processamento das msg internas
          -- Adicionar o extrato dessa conta na lista de extratos para envio por e-mail
          pc_prepara_envio_extrato(pr_rw_crapass => rw_crapass);

        ELSE
          -- Apenas fechar
          CLOSE cr_craplcm;
        END IF;
          
      END LOOP;

      -- Chamar rotina externa de envio de e-mail aos cooperados
      EXTR0001.pc_envia_extrato_email(pr_cdcooper        => pr_cdcooper
                                     ,pr_rw_crapdat      => rw_crapdat
                                     ,pr_nmrescop        => rw_crapcop.nmrescop
                                     ,pr_cdprogra        => vr_cdprogra
                                     ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                     ,pr_lshistor        => vr_lshistor
                                     ,pr_tab_env_extrato => vr_tab_env_extrato
                                     ,pr_des_erro        => vr_dscritic);
      -- Testar saída com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levanta exceção
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
      -- Se não estiver efetuando o fechamento mensal
      IF NOT vr_flgmensa THEN
        -- Atualizar tabela de parâmetro CRAPTAB para ligar a flag de extrato quinzenal
        BEGIN
          UPDATE craptab tab
             SET tab.dstextab = '1'
           WHERE tab.cdcooper = pr_cdcooper
             AND UPPER(tab.nmsistem) = 'CRED'
             AND UPPER(tab.tptabela) = 'GENERI'
             AND tab.cdempres = 0
             AND UPPER(tab.cdacesso) = 'EXEQUINZEN'
             AND tab.tpregist = 1
             AND tab.dstextab <> '1'; --> Somente se estiver diferente
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar a tabela CRAPTAB para ativar o extrato quinzenal: '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;

    EXCEPTION

      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;

  END pc_crps217;
/
