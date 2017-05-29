CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS128(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS128        (Fontes/crps128.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : 18/07/95                            Ultima alteracao: 23/05/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Emite relatorio com os maiores depositos em conta-corrente.

               Atende solicitacao 002.
               Relatorio 105
               Ordem do programa na solicitacao : 009
               Exclusividade 2.

   Alteracoes: 21/08/95 - Alterado para rodar somente as segundas-feiras e
                          colocado o turno (Deborah).

               10/04/96 - Alterado para listar poupanca programada (Odair).

               25/11/96 - Tratar RDCAII (Odair).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               07/03/2001 - Acrescentar o numero do telefone residencial do
                            associado no relatorio. (Ze Eduardo).

               16/09/2003 - Aumentar campos de valores (Deborah).

               30/10/2003 - Substituido comando RETURN pelo QUIT(Mirtes).

               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               22/06/2007 - Somente considera aplicacoes RDCA30 e RDCA60 na
                            tabela de aplicacoes RDCA (Elton).

               31/07/2007 - Tratamento para aplicacoes RDC (David).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise)

                          - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).

               12/09/2008 - Substituido arquivo crrl105.tmp por uma TEMP TABLE
                            e retirado comando "sort" (Diego).

               14/10/2008 - Acerto qdo descarrega a BO 4 - DELETE PROCEDURE (Ze)

               24/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

               01/06/2011 - Estanciado b1wgen0004 no inicio do programa e
                            deletado ao final para ganho de performance
                            (Adriano).

               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

               27/09/2013 - Alterada atribuicao da variavel aux_nrdofone para
                            receber o telefone da tabela craptfc e alterada
                            String de "AGENCIA" para "PA". (Reinert)

               03/10/2013 - Alteração para banco Oracle. Alterada ordem de
                            listagem da Temp Table arquivo para considerar o
                            campo nrdconta (Douglas Pagel).

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               26/11/2013 - Correção em leituras de PLTables verificando seu
                            tamanho antes (Marcos-Supero)
                            
               06/01/2014 - Remoção de campos não utilizados da crapass (Marcos-Supero)               
							 
		       20/08/2014 - Adicionado saldo de resgate das aplicações de captação 
				            para a coluna de saldo rdc no relatório crrl105. (Reinert)

			   23/05/2016 - Retirado lógica para executar o programa somente na segunda-feira
						    pois foi ajustado o número de solicitação deste programa de 2 para 70.
							(Adriano - SD 454658).

............................................................................. */
  DECLARE
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS128';
    -- Tratamento de erros
    vr_exc_erro   exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Cursor generico de calendario */
    rw_crapdat btch0001.cr_crapdat%rowtype;

    --Buscar Saldos do associado em depositos a vista
    CURSOR cr_crapsld (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_vlsddisp IN crapsld.vlsddisp%TYPE) IS
      SELECT nrdconta,
             vlsddisp
        FROM crapsld
       WHERE crapsld.cdcooper  = pr_cdcooper
         AND crapsld.vlsddisp >= pr_vlsddisp;

    -- Buscar associado
    CURSOR cr_crapass (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT NMPRIMTL,
             nrdconta,
             cdagenci,
             nrramemp,
             cdsitdct,
             cdtipcta,
             inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper;

    --Tipo do Cursor de associados para Bulk Collect
    TYPE typ_crapass_bulk IS TABLE of cr_crapass%ROWTYPE;
    vr_tab_crapass_bulk typ_crapass_bulk;

    -- Buscar Cadastro de aplicacoes RDCA.
    CURSOR cr_craprda (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT /*+ INDEX (craprda CRAPRDA##CRAPRDA2)*/
             tpaplica,
             nraplica,
             nrdconta,
             vlsdrdca
        FROM craprda
       WHERE craprda.cdcooper = pr_cdcooper
         AND craprda.nrdconta = pr_nrdconta
         AND craprda.insaqtot = 0;
				 
		-- Buscar cadastro de aplicações de captação
		CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE,
		                   pr_nrdconta IN craprac.nrdconta%TYPE) IS
			SELECT rac.cdoperad
			      ,rac.nrdconta
						,rac.nraplica
						,rac.cdprodut
						,rac.idblqrgt
			  FROM craprac rac
			 WHERE rac.cdcooper = pr_cdcooper
			   AND rac.nrdconta = pr_nrdconta
				 AND rac.idsaqtot = 0;				 

    -- Buscar tipos de captacao oferecidas para o cooperado.
    CURSOR cr_crapdtc (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT tpaplrdc,
             tpaplica
        FROM crapdtc
       WHERE crapdtc.cdcooper = pr_cdcooper;

    -- Buscar Cadastro de poupanca programada.
    CURSOR cr_craprpp (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT rowid
        FROM craprpp
       WHERE craprpp.cdcooper = pr_cdcooper
         AND craprpp.nrdconta = pr_nrdconta;

    -- Buscar titulares da conta
    CURSOR cr_crapttl (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cdturnos,
             nrdconta
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.idseqttl = 1;

    --Tipo do Cursor de titulares para Bulk Collect
    TYPE typ_crapttl_bulk IS TABLE of cr_crapttl%ROWTYPE;
    vr_tab_crapttl_bulk typ_crapttl_bulk;

    -- Buscar nome da agencia
    CURSOR cr_crapage (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT nmresage,
             cdagenci
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper;

    -- Buscar Cadastro dos numeros de telefone de cada titular da conta.
    CURSOR cr_craptfc (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_nrdconta IN craptfc.nrdconta%TYPE,
                       pr_tptelefo IN craptfc.tptelefo%TYPE
                       ) IS
      SELECT nrdddtfc,
             nrtelefo
        FROM craptfc f
       WHERE f.progress_recid =
                    (SELECT MIN(f1.progress_recid) -- FIND FIRST
                       FROM craptfc f1
                      WHERE f1.cdcooper = pr_cdcooper
                        AND f1.nrdconta = pr_nrdconta
                        AND f1.tptelefo = pr_tptelefo);



    rw_craptfc cr_craptfc%rowtype;

    --Type para armazenar as informacoes para exibir no relatorio
    type typ_reg_arquivo is record (cdagenci crapass.cdagenci%type,
                                    nrdconta crapsld.nrdconta%type,
                                    nrdofone craptfc.nrtelefo%type,
                                    cdturnos crapttl.cdturnos%type,
                                    cdsitcst varchar2(5),
                                    vlsddisp crapsld.vlsddisp%type,
                                    vlrdcadc number,
                                    vlsldrdc number,
                                    vlsdpoup number,
                                    nmprimtl crapass.nmprimtl%type);

    type typ_tab_reg_arquivo is table of typ_reg_arquivo
                           index by varchar2(38); --Ag(3) + vlsddisp(25) + cta(10)
    vr_tab_arquivo typ_tab_reg_arquivo;

    --Type para armazenar Cadastro de titulares da conta
    type typ_reg_crapttl is record (cdturnos crapttl.cdturnos%type);

    type typ_tab_reg_crapttl is table of typ_reg_crapttl
                           index by Binary_Integer; -- cta(10)
    vr_tab_crapttl typ_tab_reg_crapttl;

    --Type para armazenar as os associados
    type typ_reg_crapass is record (cdagenci crapass.cdagenci%type,
                                    nrdconta crapass.nrdconta%type,
                                    cdsitdct crapass.cdsitdct%type,
                                    nrramemp crapass.nrramemp%type,
                                    cdtipcta crapass.cdtipcta%type,
                                    nmprimtl crapass.nmprimtl%type,
                                    inpessoa crapass.inpessoa%type);

    type typ_tab_reg_crapass is table of typ_reg_crapass
                           index by Binary_Integer; --cta(10)
    vr_tab_crapass typ_tab_reg_crapass;

    --Type para armazenar os tipos de captacao oferecidas para o cooperado.
    type typ_reg_crapdtc is record (tpaplrdc crapdtc.tpaplrdc%type);

    type typ_tab_reg_crapdtc is table of typ_reg_crapdtc
                           index by Binary_Integer; -- TPAPLICA(5)
    vr_tab_crapdtc typ_tab_reg_crapdtc;

    --Type para armazenar informacoes das agencias
    type typ_reg_crapage is record (nmresage crapage.nmresage%type);

    type typ_tab_reg_crapage is table of typ_reg_crapage
                           index by Binary_Integer; -- CDAGENCI(5)
    vr_tab_crapage typ_tab_reg_crapage;

    -- Variavel para chaveamento (hash) da tabela arquivo
    vr_deschave varchar2(38);

    vr_cdagenci_ant  crapass.cdagenci%type := 0;
    vr_dstextab craptab.dstextab%type;
    vr_vlrdcadc number(12,2) := 0;
    vr_vlsdpoup number(12,2) := 0;
    vr_vlsldrdc number(12,2) := 0;
    vr_vlsdrdca NUMBER;       --> Saldo da aplicac?o
    vr_vlsldapl NUMBER(25,8); --> Saldo da aplicacao RDCA
    vr_vldperda NUMBER(25,8); --> Valor calculado da perda
    vr_txaplica NUMBER(25,8); --> Taxa aplicada sob o emprestimo
    vr_sldpresg NUMBER(25,8); --> Saldo para resgate
    vr_vlrenrgt NUMBER(25,8); --> Rendimento total a ser pago quando resgate total
    vr_vlrdirrf NUMBER;       --> IRRF do que foi solicitado
    vr_perirrgt NUMBER;       --> Percentual de aliquota para calculo do IRRF
    vr_vlrrgtot NUMBER;       --> Resgate para zerar a aplicac?o
    vr_vlirftot NUMBER;       --> IRRF para finalizar a aplicacao
    vr_vlrendmm NUMBER;       --> Rendimento da ultima provisao ate a data do resgate
    vr_vlrvtfim NUMBER;       --> Quantia provisao reverter para zerar a aplicac?o
    vr_vlsdrdppe craprpp.vlsdrdpp%type;--> Saldo da poupanca programada
    vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
    vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA
		vr_vlsldtot NUMBER;                    --> Valor saldo total das aplicações
		vr_vlsldrgt NUMBER;                    --> Valor total de resgate

    vr_rel_vlmaidep number;
    vr_ger_vlsdrdca NUMBER;

   -- Data de fim e inicio da utilizacao da taxa de poupanca.
    vr_dtinitax     DATE;
    vr_dtfimtax     DATE;
    vr_dextabi      craptab.dstextab%type;
    vr_cdturnos     crapttl.cdturnos%type;

    -- Erros na gene0001.pc_gera_erro
    vr_des_reto VARCHAR2(3);  --> Saida do metodo de calculo de rendimentos
    vr_tab_erro gene0001.typ_tab_erro; --> Tabela com erros da gene0001.pc_gera_erro

    -- Variavel para armazenar as informacos em XML
    vr_des_xml       clob;
    vr_des_xml_tmp   varchar2(32000);

    -- Variavel para criacao do relatorio
    vr_nom_direto    varchar2(100);
    vr_nom_arquivo   varchar2(100);

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB,
                             pr_ultimo    IN BOOLEAN default false) IS
    BEGIN
      -- Armazenar quantidade em uma variavel temporaria antes de inclui no clob, para maximizar a performace
      IF LENGTH(vr_des_xml_tmp)+LENGTH(pr_des_dados) > 31999 OR
         pr_ultimo THEN
        --Escrever no arquivo XML
        vr_des_xml := vr_des_xml||vr_des_xml_tmp||pr_des_dados;
        vr_des_xml_tmp := NULL;
      ELSE
        vr_des_xml_tmp := vr_des_xml_tmp||pr_des_dados;
      END IF;
    END pc_escreve_xml;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
     Utiliza-se essa data quando o rendimento da aplicacao for menor que
     a poupanca, a cooperativa opta por usar ou nao.
     Essa informacao eh necessaria para a rotina pc_saldo_rgt_rdc_pos */
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MXRENDIPOS'
                                             ,pr_tpregist => 1);
    --Determinar as data de inicio e fim das taxas para rotina pc_saldo_rgt_rdc_pos
    vr_dtinitax := To_Date(gene0002.fn_busca_entrada(1, vr_dstextab, ';'),'DD/MM/YYYY');
    vr_dtfimtax := To_Date(gene0002.fn_busca_entrada(2, vr_dstextab, ';'),'DD/MM/YYYY');

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PERCIRAPLI'
                                             ,pr_tpregist => 0);
    vr_dextabi := vr_dstextab;

    -- Leitura do valor na craptab
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MAIORESDEP'
                                             ,pr_tpregist => 1);
    -- Se encontrar
    IF vr_dstextab IS NOT NULL THEN
      -- extrair valor
      vr_rel_vlmaidep := TO_NUMBER(SUBSTR(vr_dstextab,17,15));
      IF vr_rel_vlmaidep = 0 THEN
        vr_rel_vlmaidep := 0.01;
      END IF;
    ELSE
      -- Nao existe
      vr_rel_vlmaidep := 0.01;
    END IF;

    -- Armazenar valores no pl/tables para melhorar performace
    --Carregar tabela memoria titulares
    OPEN cr_crapttl (pr_cdcooper => pr_cdcooper);
    --Carregar Bulk Collect
    FETCH cr_crapttl BULK COLLECT INTO vr_tab_crapttl_bulk;
    --Fechar Cursor
    CLOSE cr_crapttl;

    --Montar o indice por conta a partir do bulk collect
    IF vr_tab_crapttl_bulk.COUNT > 0 THEN
      FOR idx IN vr_tab_crapttl_bulk.FIRST..vr_tab_crapttl_bulk.LAST LOOP
        vr_tab_crapttl(vr_tab_crapttl_bulk(idx).nrdconta).cdturnos := vr_tab_crapttl_bulk(idx).cdturnos;
      END LOOP;
    END IF;

    --Carregar tabela memoria associados
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper);
    --Carregar Bulk Collect
    FETCH cr_crapass BULK COLLECT INTO vr_tab_crapass_bulk;
    --Fechar Cursor
    CLOSE cr_crapass;

    --Montar o indice por conta a partir do bulk collect
    IF vr_tab_crapass_bulk.COUNT > 0 THEN
      FOR idx IN vr_tab_crapass_bulk.FIRST..vr_tab_crapass_bulk.LAST LOOP
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nrdconta := vr_tab_crapass_bulk(idx).nrdconta;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdagenci := vr_tab_crapass_bulk(idx).cdagenci;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdsitdct := vr_tab_crapass_bulk(idx).cdsitdct;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nrramemp := vr_tab_crapass_bulk(idx).nrramemp;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdtipcta := vr_tab_crapass_bulk(idx).cdtipcta;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmprimtl := vr_tab_crapass_bulk(idx).nmprimtl;
        vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).inpessoa := vr_tab_crapass_bulk(idx).inpessoa;
      END LOOP;
    END IF;

    -- Buscar tipos de captacao
    FOR rw_crapdtc in cr_crapdtc(pr_cdcooper => pr_cdcooper)LOOP
      vr_tab_crapdtc(rw_crapdtc.tpaplica).tpaplrdc := rw_crapdtc.tpaplrdc;
    END LOOP;

    -- Buscar agencias
    FOR rw_crapage in cr_crapage(pr_cdcooper => pr_cdcooper)LOOP
      vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
    END LOOP;

    --ler Saldos do associado em depositos a vista
    FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper,
                                 pr_vlsddisp => vr_rel_vlmaidep) LOOP

      --Validar associaco
      IF vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) THEN
        --inicializar valores
        vr_vlrdcadc := 0;
        vr_vlsdpoup := 0;
        vr_vlsldrdc := 0;
      ELSE
        -- Montar mensagem de critica
        vr_cdcritic := 251; --> 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;

      -- Ler Cadastro de aplicacoes RDCA.
      FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => rw_crapsld.nrdconta) LOOP

        /* Calcular o Saldo da aplicacao ate a data do movimento
           ger_vlsdrdca contem o valor calculado                 */
        IF rw_craprda.tpaplica = 3 THEN --Tipo de aplicacao 3 RDCA
          APLI0001.pc_consul_saldo_aplic_rdca30( pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                                ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Proximo dia util
                                                ,pr_cdprogra => vr_cdprogra         --> Programa em execucao
                                                ,pr_cdagenci => 1                   --> Codigo da agencia
                                                ,pr_nrdcaixa => 999                 --> Numero do caixa
                                                ,pr_nrdconta => rw_crapsld.nrdconta --> Nro da conta da aplicac?o RDCA
                                                ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicac?o RDCA
                                                ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicac?o
                                                ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicacao RDCA
                                                ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                                ,pr_txaplica => vr_txaplica         --> Taxa aplicada sob o emprestimo
                                                ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                                ,pr_tab_erro => vr_tab_erro);

          -- Se retornar erro
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            ELSE
              vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informac?o na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            END IF;
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;

          vr_ger_vlsdrdca := vr_vlsdrdca;

          IF vr_ger_vlsdrdca > 0 THEN
            vr_vlrdcadc := nvl(vr_vlrdcadc,0) + vr_ger_vlsdrdca;
          END IF;

        ELSIF rw_craprda.tpaplica = 5 THEN --Tipo de aplicacao 5 RDCAII
          APLI0001.pc_consul_saldo_aplic_rdca60( pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Proximo dia util
                                                ,pr_cdprogra => vr_cdprogra         --> Programa em execucao
                                                ,pr_cdagenci => 1                   --> Codigo da agencia
                                                ,pr_nrdcaixa => 999                 --> Numero do caixa
                                                ,pr_nrdconta => rw_crapsld.nrdconta --> Nro da conta da aplicac?o RDCA
                                                ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicac?o RDCA
                                                ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicac?o
                                                ,pr_sldpresg => vr_sldpresg         --> Saldo para resgate
                                                ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                                ,pr_tab_erro => vr_tab_erro);
          -- Se retornar erro
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            ELSE
              vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca60 e sem informacao na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            END IF;
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;

          vr_ger_vlsdrdca := vr_vlsdrdca;

          IF vr_ger_vlsdrdca > 0 THEN
            vr_vlrdcadc := nvl(vr_vlrdcadc,0) + vr_ger_vlsdrdca;
          END IF;

        ELSE
          -- Buscar tipos de captacao oferecidas para o cooperado.
          IF vr_tab_crapdtc.EXISTS(rw_craprda.tpaplica) = FALSE THEN

            -- Montar mensagem de critica
            vr_cdcritic := 346; --> 346 - Tipo de aplicacao errado.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic
                                                         ||' Conta/dv: ' ||gene0002.fn_mask_conta (rw_craprda.nrdconta)
                                                         ||' Nr.Aplicacao: '|| gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9'));
            vr_cdcritic := 0;
            vr_dscritic := null;
            continue;
          END IF;

          IF vr_tab_crapdtc(rw_craprda.tpaplica).tpaplrdc = 1 THEN /* RDCPRE */
            vr_vlsldrdc := nvl(vr_vlsldrdc,0) + rw_craprda.vlsdrdca;
          ELSIF vr_tab_crapdtc(rw_craprda.tpaplica).tpaplrdc = 2 THEN /* RDCPOS */

            /* Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF. */
            APLI0001.pc_saldo_rgt_rdc_pos ( pr_cdcooper    => pr_cdcooper         --> Cooperativa
                                           ,pr_cdagenci    => 1                   --> Codigo da agencia
                                           ,pr_nrdcaixa    => 999                 --> Numero do caixa
                                           ,pr_nrctaapl    => rw_craprda.nrdconta --> Numero da conta
                                           ,pr_nraplres    => rw_craprda.nraplica --> Numero da aplicac?o
                                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt --> Data do movimento
                                           ,pr_dtaplrgt    => rw_crapdat.dtmvtolt --> Data aplicac?o
                                           ,pr_vlsdorgt    => 0                   --> Valor DCA
                                           ,pr_flggrvir    => FALSE               --> Identificador se deve gravar valor insento
                                           ,pr_dtinitax    => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                           ,pr_dtfimtax    => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                           --OUT
                                           ,pr_vlsddrgt    => vr_sldpresg         --> Valor do resgate total sem irrf ou o solicitado
                                           ,pr_vlrenrgt    => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                           ,pr_vlrdirrf    => vr_vlrdirrf         --> IRRF do que foi solicitado
                                           ,pr_perirrgt    => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                           ,pr_vlrgttot    => vr_vlrrgtot         --> Resgate para zerar a aplicac?o
                                           ,pr_vlirftot    => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                           ,pr_vlrendmm    => vr_vlrendmm         --> Rendimento da ultima provisao ate a data do resgate
                                           ,pr_vlrvtfim    => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicac?o
                                           ,pr_des_reto    => vr_des_reto         --> Indicador de saida com erro (OK/NOK)
                                           ,pr_tab_erro    => vr_tab_erro );      --> Tabela com erros

            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF vr_tab_erro.COUNT > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              ELSE
                vr_dscritic := 'Retorno "NOK" na apli0001.pc_saldo_rgt_rdc_pos e sem informacao na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              END IF;

              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic
                                                           ||' Conta/dv: ' ||gene0002.fn_mask_conta (rw_craprda.nrdconta)
                                                           ||' Nr.Aplicacao: '|| gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9'));
              vr_cdcritic := 0;
              vr_dscritic := null;
              continue;

            END IF;

            IF vr_vlrrgtot > 0 THEN
              vr_vlsldrdc := vr_vlsldrdc + vr_vlrrgtot;
            ELSE
              vr_vlsldrdc := vr_vlsldrdc + rw_craprda.vlsdrdca;
            END IF;

          END IF; -- Fim rw_crapdtc.tpaplrdc

        END IF; -- Fim rw_craprda.tpaplica

      END LOOP;  /* Fim do LOOP craprda */

      -- Buscar Cadastro de poupanca programada..
      FOR rw_craprpp IN cr_craprpp (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => rw_crapsld.nrdconta) LOOP

        /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
        APLI0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper,        --> Cooperativa
                                  pr_dstextab  => vr_dextabi,         --> Percentual de IR da aplicac?o
                                  pr_cdprogra  => vr_cdprogra,        --> Programa chamador
                                  pr_inproces  => rw_crapdat.inproces,--> Indicador do processo
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,--> Data do processo
                                  pr_dtmvtopr  => rw_crapdat.dtmvtopr,--> Proximo dia util
                                  pr_rpp_rowid => rw_craprpp.rowid,   --> Identificador do registro da tabela CRAPRPP em processamento
                                  pr_vlsdrdpp  => vr_vlsdrdppe,       --> Saldo da poupanca programada
                                  pr_cdcritic  => vr_cdcritic,        --> Codigo da critica de erro
                                  pr_des_erro  => vr_dscritic);       --> Descric?o do erro encontrado

        -- Se encontrar erros na execuc?o
        IF vr_dscritic is not null THEN
          RAISE vr_exc_erro;
        END IF;

        vr_vlsdpoup := vr_vlsdpoup + vr_vlsdrdppe;

      END LOOP;  -- Fim loop rw_craprpp
      
			-- Percorre todas as aplicações de captação da conta
      FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
				                          ,pr_nrdconta => rw_crapsld.nrdconta) LOOP
				
			  -- Chama procedure para buscar o saldo total de resgate
			  apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper, 
																					 pr_cdoperad => '1', 
																					 pr_nmdatela => 'crps128', 
																					 pr_idorigem => 1, 
																					 pr_nrdconta => rw_craprac.nrdconta, 
																					 pr_idseqttl => 1, 
																					 pr_nraplica => rw_craprac.nraplica, 
																				 	 pr_dtmvtolt => rw_crapdat.dtmvtolt, 
																				 	 pr_cdprodut => rw_craprac.cdprodut, 
																					 pr_idblqrgt => 1, 
																					 pr_idgerlog => 0, 
																					 pr_vlsldtot => vr_vlsldtot, 
																					 pr_vlsldrgt => vr_vlsldrgt, 
																					 pr_cdcritic => vr_cdcritic, 
																					 pr_dscritic => vr_dscritic);
				
				-- Se retornou algum erro													 
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					-- Levanta exceção
					RAISE vr_exc_erro;
				END IF;
				-- Soma valor do saldo de resgate retornado da procedure com o saldo rdc
				vr_vlsldrdc := vr_vlsldrdc + vr_vlsldrgt;
			
			END LOOP;

      -- Buscar turno na pl table titulares da conta
      IF vr_tab_crapttl.EXISTS(lpad(rw_crapsld.nrdconta,10,0)) THEN
         vr_cdturnos := vr_tab_crapttl(lpad(rw_crapsld.nrdconta,10,0)).cdturnos;
      ELSE
        vr_cdturnos := 0;
      END IF;

      vr_deschave := lpad(vr_tab_crapass(rw_crapsld.nrdconta).cdagenci,3,0) ||
                     --para exibir a ordenacao de valores do maior para o menor, diminui-se do valor o valor maximo permitido
                     lpad((9999999999999999999999999 - (rw_crapsld.vlsddisp*100)),25,0) ||
                     lpad(rw_crapsld.nrdconta,10,0);

      vr_tab_arquivo(vr_deschave).cdagenci := vr_tab_crapass(rw_crapsld.nrdconta).cdagenci;
      vr_tab_arquivo(vr_deschave).nrdconta := rw_crapsld.nrdconta;

      --buscar numero do telefone
      OPEN cr_craptfc(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => rw_crapsld.nrdconta,
                      pr_tptelefo => (case vr_tab_crapass(rw_crapsld.nrdconta).inpessoa
                                      when 1 then 1
                                      else 3
                                      end )
                      );
      FETCH cr_craptfc
        INTO rw_craptfc;
      IF cr_craptfc%NOTFOUND THEN
        vr_tab_arquivo(vr_deschave).nrdofone := null;
        close cr_craptfc;
      ELSE
        vr_tab_arquivo(vr_deschave).nrdofone := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
        close cr_craptfc;
      END IF;

      vr_tab_arquivo(vr_deschave).cdturnos := vr_cdturnos;
      vr_tab_arquivo(vr_deschave).cdsitcst := vr_tab_crapass(rw_crapsld.nrdconta).cdsitdct
                                              || lpad(vr_tab_crapass(rw_crapsld.nrdconta).cdtipcta,2,0);
      vr_tab_arquivo(vr_deschave).vlsddisp := rw_crapsld.vlsddisp;
      vr_tab_arquivo(vr_deschave).vlrdcadc := vr_vlrdcadc;
      vr_tab_arquivo(vr_deschave).vlsldrdc := vr_vlsldrdc;
      vr_tab_arquivo(vr_deschave).vlsdpoup := vr_vlsdpoup;
      vr_tab_arquivo(vr_deschave).nmprimtl := vr_tab_crapass(rw_crapsld.nrdconta).nmprimtl;

    END LOOP; /*  Fim do LOOP  --  Leitura do crapsld  */

    -- Gerar xml para emissao do relatorio
    IF vr_tab_arquivo.count > 0 THEN
      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      --Determinar o nome do arquivo que sera gerado
      vr_nom_arquivo := 'crrl105';

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      vr_deschave := vr_tab_arquivo.FIRST;
      vr_cdagenci_ant := 0;

      LOOP
        EXIT WHEN vr_deschave IS NULL;

        IF vr_cdagenci_ant <> vr_tab_arquivo(vr_deschave).cdagenci  THEN
          IF vr_cdagenci_ant <> 0 THEN
            pc_escreve_xml('</agencia>');
          END IF;

          -- Buscar nome da agencia
          IF vr_tab_crapage.exists(vr_tab_arquivo(vr_deschave).cdagenci) THEN
            pc_escreve_xml('<agencia nmagenci="'||gene0002.fn_mask(vr_tab_arquivo(vr_deschave).cdagenci,'zz9')
                           ||' - '|| vr_tab_crapage(vr_tab_arquivo(vr_deschave).cdagenci).nmresage ||'"'
                           ||' vlmaidep="'||vr_rel_vlmaidep||'">');
          -- Se nao encontrar
          ELSE
            pc_escreve_xml('<agencia nmagenci="'||gene0002.fn_mask(vr_tab_arquivo(vr_deschave).cdagenci,'zz9')
                           ||'- Desconhecida">');
          END IF;

          vr_cdagenci_ant := vr_tab_arquivo(vr_deschave).cdagenci;
        END IF;

        pc_escreve_xml('
                        <saldos>
                          <nrdconta>'|| gene0002.fn_mask_conta(vr_tab_arquivo(vr_deschave).nrdconta) ||'</nrdconta>
                          <nrdofone>'|| vr_tab_arquivo(vr_deschave).nrdofone ||'</nrdofone>
                          <cdturnos>'|| vr_tab_arquivo(vr_deschave).cdturnos ||'</cdturnos>
                          <cdsitcst>'|| vr_tab_arquivo(vr_deschave).cdsitcst ||'</cdsitcst>
                          <vlsddisp>'|| vr_tab_arquivo(vr_deschave).vlsddisp ||'</vlsddisp>
                          <nmprimtl>'|| substr(vr_tab_arquivo(vr_deschave).nmprimtl,1,29) ||'</nmprimtl>
                       ');

        -- Exibir os valores apenas quando forem maior que zero
        -- SALDO RDCA
        IF vr_tab_arquivo(vr_deschave).vlrdcadc > 0 THEN
          pc_escreve_xml('<vlrdcadc>'|| vr_tab_arquivo(vr_deschave).vlrdcadc ||'</vlrdcadc>');
        ELSE
          pc_escreve_xml('<vlrdcadc>0</vlrdcadc>');
        END IF;

        -- SALDO RDC
        IF vr_tab_arquivo(vr_deschave).vlsldrdc > 0 THEN
          pc_escreve_xml('<vlsldrdc>'|| vr_tab_arquivo(vr_deschave).vlsldrdc ||'</vlsldrdc>');
        ELSE
          pc_escreve_xml('<vlsldrdc>0</vlsldrdc>');
        END IF;

        -- POUPANCA PROGR.
        IF vr_tab_arquivo(vr_deschave).vlsdpoup > 0 THEN
          pc_escreve_xml('<vlsdpoup>'|| vr_tab_arquivo(vr_deschave).vlsdpoup ||'</vlsdpoup>');
        ELSE
          pc_escreve_xml('<vlsdpoup>0</vlsdpoup>');
        END IF;

        pc_escreve_xml('
                        </saldos>
                       ');

        -- Buscar proximo
        vr_deschave := vr_tab_arquivo.NEXT(vr_deschave);
      END LOOP;

      pc_escreve_xml('</agencia>',pr_ultimo => true);
      vr_des_xml := '<?xml version="1.0" encoding="utf-8"?><crrl105>'||vr_des_xml||'</crrl105>';

      -- solicitar impressao
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl105'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl105.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com codigo da agencia
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.freetemporary(vr_des_xml);

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_erro;
      END IF;

    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
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

    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;
  END;
END;
/

