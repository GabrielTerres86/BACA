CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS140(pr_cdcooper  IN NUMBER         --> Código da cooperativa
                                             ,pr_flgresta  IN PLS_INTEGER    --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER    --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER    --> Saída de termino da solicitação
                                             ,pr_cdcritic  OUT NUMBER        --> Código crítica
                                             ,pr_dscritic  OUT VARCHAR2) IS  --> Descrição crítica
/* ..........................................................................

   Programa: Pc_crps140 (antigo Fontes/crps140.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/95                      Ultima atualizacao: 07/12/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio 117 com os maiores aplicadores.
               Esse relatorio deve rodar sempre depois do mensal
               das aplicacoes e da poupanca programada.

   Alteracoes: 01/12/95 - Acerto no numero de vias (Deborah).

               11/04/96 - Incluir procedimentos poupanca programada (Odair).

               26/11/96 - Tratar RDCAII (Odair).

               26/12/97 - Alterado para calcular RDCA ate o dia do movimento
                          (Deborah).

               27/08/1999 - Tratar circular 2852 (Deborah).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               01/04/2004 - Alteracao no FORMAT do numero sequencial (Julio)

               22/11/2004 - Gerar tambem relatorio com TODOS os aplicadores
                            (rl/crrl117_99.lst) (Evandro).

               06/12/2005 - Gerar relatorio dos 100 maiores aplicadores sem
                            quebras de paginas (crrl117.txt) e com envio
                            de email (Diego).

               03/02/2006 - Modificado nome relatorio(str_4), e alterado
                            para listar TODOS APLICADORES (Diego).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/11/2006 - Incluido PAC do associado no relatorio (Elton).

               30/11/2006 - Melhoria de performance (Evandro).

               10/04/2007 - Gerar arquivo com totais das operacoes por CPF
                            (David).

               30/05/2007 - Incluir USE-INDEX para melhorar a performace
                            (Ze/Evandro).

               13/07/2007 - Retirado envio de email. Alterado nome do arquivo
                            que e salvo na pasta 'rl/' crrl117 e sua extensao
                            para .lst (Guilherme).

               23/08/2007 - Incluir valores de aplicacoes RDC (David).

               29/10/2007 - Acerto nos valores de aplicacoes RDC (ZE).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i. (Sidnei - Precise).

               03/04/2008 - Alterado mascara do FORM do relatorio de aplicadores
                            por CPF para mostrar numeros negativos;
                          - Lista somente aplicadores com saldo das aplicacoes
                            maiores do que zero "0" nos relatorios (Elton).

               28/04/2008 - Acertado para que relatorio de aplicadores por CPF
                            gere saldo das aplicacoes do ultimo dia util do mes
                            anterior (Elton).

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               06/01/2010 - Relatorio não irá mais listar os 100 maiores, e sim
                            os cooperados cujo valor das aplicacoes seja maior
                            que o parametrizado na TAB007 (Fernando).

               11/01/2011 - Definido o format "x(40)" nmprimtl (Kbase - Gilnei).

               21/01/2011 - Ajuste no layout de impressao devido a alteracao
                            do format da variavel aux_qtregist (Henrique).

               01/06/2011 - Instanciar a b1wgen0004 ao inicio do programa e
                            deletado ao final para ganho de performance
                            (Adriano).

               09/01/2012 - Melhorar desempenho (Gabriel).

               28/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            (Diego).

               01/04/2013 - Conversão Progress >> PLSQL (Petter-Supero)

               25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                            inpessoa (Marcos-Supero)

               11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel)

               16/09/2013 - Alterada coluna do FORM f_label de PAC para PA.
                            (Reinert)

               04/10/2013 - Adicionado parametro na chamada da procedure
                            saldo_rdc_pos. (Reinert)

               12/11/2013 - Remoção do parâmetro pr_flgimpri na chamada da
                            solicita_relato pois não havia no fonte original (Marcos-Supero)
                            
               18/12/2013 - Implementação das alterações de novembro (Petter - Supero).
               
               18/02/2014 - Alterado totalizador de PAs de 99 para 999. (Gabriel) 
							 
               21/08/2014 - Adicionado tratamento para aplicações dos produtos de 
                            captação (craprac). (Reinert)

               07/12/2015 - Adicionado validacao para limpar o buffer da string de xml
                            quando montar as tags com os totais. (Douglas - Chamado 368794)
............................................................................. */
BEGIN

  DECLARE
    vr_qtregist            NUMBER;                         --> Quantidade de registros
    vr_vlsldapl            NUMBER(20,8) := 0;              --> Valor da aplicação
    vr_vlsldapl2           NUMBER(20,8) := 0;              --> Valor da aplicação
    vr_vlsldrdc            NUMBER(20,8) := 0;              --> Valor do RDC
    vr_vlsldrda            NUMBER(20,8) := 0;              --> Valor do RDCA
    vr_vlsdpoup            NUMBER(20,8) := 0;              --> Valor poupança
    vr_perirrgt            NUMBER(10,2) := 0;              --> Percentual de IRR
    vr_vlaplrdc            NUMBER(20,8) := 0;              --> Valor de aplicação RDC
    vr_vlslfrda            NUMBER(20,8) := 0;              --> Valor de fração RDA
    vr_vlslfrdc            NUMBER(20,8) := 0;              --> Valor de fração RDC
    vr_vlsfpoup            NUMBER(20,8) := 0;              --> Valor de fração poupança
    vr_cdempres            NUMBER;                         --> Código da empresa
    vr_tot_vlsldapl        NUMBER(20,8) := 0;              --> Valor total de aplicação
    vr_tot_vlsldrdc        NUMBER(20,8) := 0;              --> Valor total de RDC
    vr_tot_vlsdrdca        NUMBER(20,8) := 0;              --> Valor total de RDCA
    vr_tot_vlsdpoup        NUMBER(20,8) := 0;              --> Valor total de poupança

    -- Variaveis para o total de todos os aplicadores
    vr_tab_vlsdmadp        NUMBER(20,8);                   --> Valor total de mapeamento
    vr_nrcpfcgc            VARCHAR2(20);                   --> Número de CPF/CNPJ

    vr_dextabi             craptab.dstextab%type;          --> Parametro utilizado no cal. poupança
    vr_dstextab            craptab.dstextab%type;          --> Variabel utilizada para buscar parametro

    -- Variaveis RDCA para BO
    vr_vlrentot            NUMBER(20,8) := 0;              --> Valor de rendimento total
    vr_vldperda            NUMBER(20,8) := 0;              --> Valor da perda
    vr_vlsdrdca            NUMBER(20,8) := 0;              --> Valor saldo do RDCA
    vr_txaplica            NUMBER(20,8) := 0;              --> Taxa de aplicação
    vr_nrcopias            NUMBER;                         --> Número de cópias do relatório
    vr_nmformul            VARCHAR2(400);                  --> Nome do formulário
    vr_cdprogra            VARCHAR2(10);                   --> Nome do programa
    vr_desc_erro           VARCHAR2(8000);                 --> Mensagem de erro
    vr_exc_erro            EXCEPTION;                      --> Controle de saída para exceção
    rw_crapdat             btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
    vr_str_1               CLOB;                           --> Variável para armazenar dadso do XML dos maiores aplicadores
    vr_str_5               CLOB;                           --> Variável para armazenar dados do XML de relatório de CPF
    vr_nom_dir             VARCHAR2(400);                  --> Variável para armazenar o path do arquivo
    vr_proximo             EXCEPTION;                      --> Variável para controle de fluxo na iteração
    vr_rd2_vlsdrdca        NUMBER(20,8) := 0;              --> Valor de cálculo do RDCA
    vr_vlrdirrf            NUMBER(20,8) := 0;              --> Cálculo do valor de IRRF
    vr_dtinitax            DATE;                           --> Data início da taxa de poupança
    vr_dtfimtax            DATE;                           --> Data final da taxa de poupança
    vr_idxpl               VARCHAR2(50);                   --> Índice de PL Table
    vr_icxauto             NUMBER;                         --> Auto incremento para contador de índice
    vr_idxindc             VARCHAR2(20);                   --> Variável para armazenar índice de PL Table
    vr_iterar              EXCEPTION;                      --> Variável para controle de fluxo na iteração
    vr_rpp_vlsdrdpp        NUMBER(20,8) := 0;              --> Valor de poupança acumulado
    vr_idxcrapasss         VARCHAR2(15);                   --> Variável para armazenar índice de PL Table
    vr_pula                EXCEPTION;                      --> Variável para controlar iteração de LOOP
    vr_idxrda              VARCHAR2(25);                   --> Indexador da PL Table para dados de curosr
    vr_data_buffer         VARCHAR2(32767);                --> Variável para armazenar buffer de dados para o CLOB
    vr_agendamento         VARCHAR2(1) := 'N';             --> Variável de controle para definir agendamento de relatório
    vr_nomarq              VARCHAR2(50) := '/crrl117';     --> Nome raiz do arquivo
    vr_saida               EXCEPTION;                      --> Escapar erros do LOOP
    vr_sldpresg_tmp        craplap.vllanmto%TYPE;          --> Valor saldo de resgate
    vr_dup_vlsdrdca        craplap.vllanmto%TYPE;          --> Acumulo do saldo da aplicacao RDCA
		
		-- Variaveis usadas no retorno da procedure pc_posicao_saldo_aplicacao_pre/pos
		vr_vlsldtot NUMBER;      --> Saldo Total da Aplicação
 		vr_vlultren NUMBER;      --> Valor Último Rendimento
		vr_vlsldrgt NUMBER;      --> Saldo Total para Resgate
		vr_vlrevers NUMBER;      --> Valor de Reversão
		vr_percirrf NUMBER;      --> Percentual do IRRF
		vr_vlbascal NUMBER := 0; --> Valor Base Cálculo

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
		
		TYPE typ_reg_vlsldtot IS RECORD (vlsldtot NUMBER);
		TYPE typ_tab_vlsldtot IS TABLE OF typ_reg_vlsldtot INDEX BY VARCHAR2(25);
		vr_tab_vlsldtot typ_tab_vlsldtot;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dados de taxas
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE               --> Código cooperativa
                     ,pr_nmsistem IN craptab.nmsistem%TYPE               --> Nome sistema
                     ,pr_tptabela IN craptab.tptabela%TYPE               --> Tipo tabela
                     ,pr_cdempres IN craptab.cdempres%TYPE               --> código empresa
                     ,pr_cdacesso IN craptab.cdacesso%TYPE               --> Código acesso
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS           --> Tipo de registro
      SELECT substr(cb.dstextab, 49, 15) dstextabs
            ,cb.dstextab
      FROM craptab cb
      WHERE cb.cdcooper = pr_cdcooper
        AND cb.nmsistem = pr_nmsistem
        AND cb.tptabela = pr_tptabela
        AND cb.cdempres = pr_cdempres
        AND cb.cdacesso = pr_cdacesso
        AND cb.tpregist = pr_tpregist;
    rw_craptab cr_craptab%rowtype;

    -- Busca de dados dos associados
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cs.cdagenci
            ,cs.nrdconta
      FROM crapass cs
      WHERE cs.cdcooper  = pr_cdcooper
        AND cs.dtelimin  IS NULL
        AND cs.inpessoa <> 3
      ORDER BY cs.nrdconta;
			
	  -- Buscar PA do cooperador
		CURSOR cr_crapass_rac(pr_cdcooper IN crapass.cdcooper%TYPE     --> Código da cooperativa
		                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS --> Nr. da conta
			SELECT ass.cdagenci
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta;
		rw_crapass_rac cr_crapass_rac%ROWTYPE;

    -- Buscar dados do cadastro das aplicações RDCA
    CURSOR cr_craprda(pr_cdcooper IN craptab.cdcooper%TYPE) IS    --> Código da cooperativa
      SELECT cd.tpaplica
            ,cd.vlslfmes
            ,cd.cdageass
            ,cd.nrdconta
            ,cd.nraplica
      FROM craprda cd
      WHERE cd.cdcooper = pr_cdcooper
        AND cd.insaqtot = 0
      ORDER BY cd.nrdconta, cd.nraplica;

    -- PL Table para armazenar dados de cadastro de aplicações RDCA
    TYPE typ_reg_craprda IS
      RECORD(tpaplica  craprda.tpaplica%TYPE
            ,vlslfmes  craprda.vlslfmes%TYPE
            ,cdageass  craprda.cdageass%TYPE
            ,nrdconta  craprda.nrdconta%TYPE
            ,nraplica  craprda.nraplica%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craprda IS TABLE OF typ_reg_craprda INDEX BY VARCHAR2(25);
    vr_tab_craprda typ_tab_craprda;

    -- Buscar as aplicações de captação
    CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT rac.cdprodut
			      ,rac.nrdconta
						,rac.nraplica
						,rac.txaplica
						,rac.dtmvtolt
						,rac.qtdiacar
						,rac.vlslfmes
			  FROM craprac rac
			 WHERE rac.cdcooper = pr_cdcooper
			   AND rac.idsaqtot = 0
			 ORDER BY rac.nrdconta, rac.nraplica;
			 
		-- Selecionar informações de produtos de captação
		 CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
		   SELECT cpc.idtippro
			       ,cpc.cddindex
						 ,cpc.idtxfixa
			   FROM crapcpc cpc
				WHERE cpc.cdprodut = pr_cdprodut;
		 rw_crapcpc cr_crapcpc%ROWTYPE;

    -- Buscar dados dos tipos de aplicação cadastradas
    CURSOR cr_crapdtc(pr_cdcooper IN craptab.cdcooper%TYPE) IS      --> Código da cooperativa
      SELECT ct.tpaplica
            ,ct.tpaplrdc
      FROM crapdtc ct
      WHERE ct.cdcooper = pr_cdcooper;

    -- Buscar dados do cadastro de poupança programada
    CURSOR cr_craprpp(pr_cdcooper IN craptab.cdcooper%TYPE) IS      --> Código da cooperativa
      SELECT cp.nrdconta
            ,cp.cdsitrpp
            ,cp.vlslfmes
            ,cp.rowid
      FROM craprpp cp
      WHERE cp.cdcooper = pr_cdcooper
      ORDER BY cp.nrdconta;

    -- Busca de dados dos associados (segunda consulta diferenciada)
    CURSOR cr_crapasss(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cs.inpessoa
            ,cs.nrdconta
            ,cs.nrcpfcgc
            ,cs.nrmatric
            ,cs.cdagenci
            ,cs.nmprimtl
      FROM crapass cs
      WHERE cs.cdcooper = pr_cdcooper;

    -- Buscar dados de aplicações pessoa física
    CURSOR cr_crapttl(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cl.nrdconta
            ,cl.cdempres
      FROM crapttl cl
      WHERE cl.cdcooper = pr_cdcooper
        AND cl.idseqttl = 1;

    -- Buscar dados de aplicações pessoa jurídica
    CURSOR cr_crapjur(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cj.nrdconta
            ,cj.cdempres
      FROM crapjur cj
      WHERE cj.cdcooper = pr_cdcooper;

    -- PL Table para armazenar dados de aplicações pessoa jurídica
    TYPE typ_reg_crapjur IS
      RECORD(cdempres  crapjur.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(10);
    vr_tab_crapjur typ_tab_crapjur;

    -- PL Table para armazenar dados de aplicações pessoa física
    TYPE typ_reg_crapttl IS
      RECORD(cdempres  crapttl.cdempres%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(10);
    vr_tab_crapttl typ_tab_crapttl;

    -- PL Table para armazenar dados dos associados
    TYPE typ_reg_crapasss IS
      RECORD(inpessoa  crapass.inpessoa%TYPE
            ,nrdconta  crapass.nrdconta%TYPE
            ,nrcpfcgc  crapass.nrcpfcgc%TYPE
            ,nrmatric  crapass.nrmatric%TYPE
            ,cdagenci  crapass.cdagenci%TYPE
            ,nmprimtl  crapass.nmprimtl%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapasss IS TABLE OF typ_reg_crapasss INDEX BY VARCHAR2(15);
    vr_tab_crapasss typ_tab_crapasss;

    -- PL Table para armazenar dados da iteração de arquivo temporário (.TMP)
    TYPE typ_reg_temp IS
      RECORD(nrdconta     crapass.nrdconta%TYPE
            ,vr_vlsldapl1 NUMBER(20,8)
            ,vr_vlsldrdc  NUMBER(20,8)
            ,vr_vlsldrda  NUMBER(20,8)
            ,vr_vlsdpoup  NUMBER(20,8)
            ,vr_vlsldapl2 NUMBER(20,8)
            ,vr_vlslfrdc  NUMBER(20,8)
            ,vr_vlslfrda  NUMBER(20,8)
            ,vr_vlsfpoup  NUMBER(20,8));

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_temp IS TABLE OF typ_reg_temp INDEX BY VARCHAR2(50);
    vr_tab_temp typ_tab_temp;

    -- PL Table para armazenar dados de poupança programada
    TYPE typ_reg_craprpp IS
      RECORD(nrdconta  craprpp.nrdconta%TYPE
            ,cdsitrpp  craprpp.cdsitrpp%TYPE
            ,vlslfmes  craprpp.vlslfmes%TYPE
            ,rowid     VARCHAR2(50));

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craprpp IS TABLE OF typ_reg_craprpp INDEX BY VARCHAR2(20);
    vr_tab_craprpp typ_tab_craprpp;

    -- Instancia TEMP TABLE referente a tabela CRAPERR
    vr_tab_craterr GENE0001.typ_tab_erro;

    -- Pl Table para armazenar dados de tipos de aplicação
    TYPE typ_reg_crapdtc IS
      RECORD(tpaplica  crapdtc.tpaplica%TYPE
            ,tpaplrdc  crapdtc.tpaplrdc%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_crapdtc IS TABLE OF typ_reg_crapdtc INDEX BY PLS_INTEGER;
    vr_tab_crapdtc typ_tab_crapdtc;

    -- PL Table para gravar aplicadores
    TYPE typ_reg_aplicadores IS
      RECORD(nmprimtl  crapass.nmprimtl%TYPE
            ,nrcpfcgc  VARCHAR2(20)
            ,vlslfapl  NUMBER
            ,vlslfrda  NUMBER
            ,vlslfrdc  NUMBER
            ,vlsfpoup  NUMBER);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_aplicadores IS TABLE OF typ_reg_aplicadores INDEX BY VARCHAR2(30);
    vr_tab_aplicadores typ_tab_aplicadores;

    -- PL Table para gravar aplicadores com nova ordenação
    TYPE typ_reg_oaplicadores IS
      RECORD(nmprimtl  crapass.nmprimtl%TYPE
            ,nrcpfcgc  VARCHAR2(20)
            ,vlslfapl  NUMBER
            ,vlslfrda  NUMBER
            ,vlslfrdc  NUMBER
            ,vlsfpoup  NUMBER);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_oaplicadores IS TABLE OF typ_reg_oaplicadores INDEX BY VARCHAR2(95);
    vr_tab_oaplicadores typ_tab_oaplicadores;

    -- Procedure para escrever texto na variável CLOB do XML
    PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2                --> String que será adicionada ao CLOB
                        ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que irá receber a string
    BEGIN
      dbms_lob.writeappend(pr_clob, length(pr_des_dados), pr_des_dados);
    END pc_xml_tag;

    -- Procedure para limpar o buffer da variável e imprimir seu conteúdo para o CLOB
    PROCEDURE pc_limpa_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Variável com o conteúdo de buffer
                             ,pr_str     IN OUT NOCOPY CLOB) AS   --> Variável CLOB que irá receber o buffer
    BEGIN
      IF LENGTH(pr_buffer) >= 32600 THEN
        pc_xml_tag(pr_buffer, pr_str);
        pr_buffer := '';
      END IF;
    END pc_limpa_buffer;

    -- Procedure para finalizar a execução do buffer e imprimir seu conteúdo no CLOB
    PROCEDURE pc_final_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Variável com o conteúdo de buffer
                             ,pr_str     IN OUT NOCOPY CLOB) AS   --> Variável CLOB que irá receber o buffer
    BEGIN
      pc_xml_tag(pr_buffer, pr_str);
      pr_buffer := '';
    END pc_final_buffer;

    -- Procedure para criar dados de aplicadores
    PROCEDURE pc_cria_aplicadores(pr_nrcpfcgc  IN VARCHAR2                   --> CPF/CNPJ
                                 ,pr_inpessoa  IN NUMBER                     --> Tipo pessoa
                                 ,pr_vlsldapl2 IN NUMBER                     --> Valor total de aplicação de aplicadores
                                 ,pr_vlslfrdc  IN NUMBER                     --> Valor de fração RDC
                                 ,pr_vlslfrda  IN NUMBER                     --> Valor de fração RDA
                                 ,pr_vlsfpoup  IN NUMBER                     --> Valor de fração poupança
                                 ,pr_nmprimtl  IN crapass.nmprimtl%TYPE      --> Nome impressão
                                 ,pr_des_erro  OUT VARCHAR2) AS              --> Variável para captura de erros
    BEGIN
      BEGIN
        -- Verifica se já existe registro na PL Table para o indice pesquisado para efetuar update/insert
        IF vr_tab_aplicadores.exists(lpad(pr_nrcpfcgc, 20, '0')) THEN
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl + pr_vlsldapl2;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc + pr_vlslfrdc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda + pr_vlslfrda;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup := vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup + pr_vlsfpoup;
        ELSE
          -- Aplicar máscara CPF/CNPJ
          vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,pr_inpessoa);

          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).nrcpfcgc := vr_nrcpfcgc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).nmprimtl := pr_nmprimtl;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfapl := pr_vlsldapl2;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrdc := pr_vlslfrdc;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlslfrda := pr_vlslfrda;
          vr_tab_aplicadores(lpad(pr_nrcpfcgc, 20, '0')).vlsfpoup := pr_vlsfpoup;
        END IF;
      EXCEPTION
        WHEN others THEN
          pr_des_erro := 'Erro em pc_cria_aplicadores: ' || SQLERRM;
      END;
    END pc_cria_aplicadores;

    -- Procedure para reordenar e criar novo indexador para PL Table
    PROCEDURE pc_order_table (pr_des_erro  OUT VARCHAR2) AS      --> Variável para captura de erros
    BEGIN
      DECLARE
        vr_index    VARCHAR2(20);       --> Indice para PL Table que será reordenada
        vr_oindex   VARCHAR2(105);      --> Indice para a nova PL Table
        vr_count    NUMBER := 0;        --> Variável para incrementar o indexador

      BEGIN
        vr_index := vr_tab_aplicadores.first;

        -- Iteração desde o primeiro registro para reordenar com novo índice
        LOOP
          EXIT WHEN vr_index IS NULL;

          -- Criar novo indice para reordenamento
          vr_count := vr_count + 1;
          vr_oindex := lpad((vr_tab_aplicadores(vr_index).vlslfapl * 100), 35, '0') ||
                       lpad( vr_index , 20, '0');

          -- Cria registros na nova PL Table
          vr_tab_oaplicadores(vr_oindex).nrcpfcgc := vr_tab_aplicadores(vr_index).nrcpfcgc;
          vr_tab_oaplicadores(vr_oindex).nmprimtl := vr_tab_aplicadores(vr_index).nmprimtl;
          vr_tab_oaplicadores(vr_oindex).vlslfapl := vr_tab_aplicadores(vr_index).vlslfapl;
          vr_tab_oaplicadores(vr_oindex).vlslfrdc := vr_tab_aplicadores(vr_index).vlslfrdc;
          vr_tab_oaplicadores(vr_oindex).vlslfrda := vr_tab_aplicadores(vr_index).vlslfrda;
          vr_tab_oaplicadores(vr_oindex).vlsfpoup := vr_tab_aplicadores(vr_index).vlsfpoup;

          -- Busca o próximo índice
          vr_index := vr_tab_aplicadores.next(vr_index);
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro em pc_order_table: ' || SQLERRM;
      END;
    END pc_order_table;

    -- Procedure para gerar output de arquivo para relatório de CPF
    PROCEDURE pc_relatorio_cpf(pr_des_erro  OUT VARCHAR2) AS     --> Mensagem de erro
    BEGIN
      DECLARE
        vr_indxpl     VARCHAR2(100);          --> Variável para armazenar índice da PL Table
        vr_buffer     VARCHAR2(32767);       --> Variável para armazenar buffer de dados para o CLOB
        vr_ex_erro    EXCEPTION;             --> Handle para tratar exceção personalizada

      BEGIN
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_str_5, TRUE);
        dbms_lob.open(vr_str_5, dbms_lob.lob_readwrite);

        -- Inicilizar as informações do XML
        vr_buffer := '<?xml version="1.0" encoding="utf-8"?><base>';

        -- Busca primeiro índice da PL Table
        vr_indxpl := vr_tab_oaplicadores.last;

        -- Iteração sob a PL Table
        LOOP
          EXIT WHEN vr_indxpl IS NULL;
          IF vr_tab_oaplicadores(vr_indxpl).vlslfapl > 0 THEN
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<dados coop=''' || lpad(pr_cdcooper, 4, '0') || '''>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<nome>'||substr(vr_tab_oaplicadores(vr_indxpl).nmprimtl,1,40)||'</nome>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<cpfcnpj>'||vr_tab_oaplicadores(vr_indxpl).nrcpfcgc||'</cpfcnpj>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<RDC>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfrdc,'FM999G999G999G990D00')||'</RDC>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<RDCA>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfrda,'FM999G999G999G990D00')||'</RDCA>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<poupprog>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlsfpoup,'FM999G999G999G990D00')||'</poupprog>';
            pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
            vr_buffer := vr_buffer||'<totalapli>'||to_char(vr_tab_oaplicadores(vr_indxpl).vlslfapl,'FM999G999G999G990D00')||'</totalapli></dados>';
          END IF;

          -- Busca o próximo registro
          vr_indxpl := vr_tab_oaplicadores.prior(vr_indxpl);
        END LOOP;

        -- Finalizar arquivo XML
        pc_limpa_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);
        vr_buffer := vr_buffer || '</base>';
        pc_final_buffer(pr_buffer => vr_buffer, pr_str => vr_str_5);

        -- Criar arquivo LST
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_str_5
                                   ,pr_dsxmlnode => '/base/dados'
                                   ,pr_dsjasper  => 'crrl117_dir_cpf.jasper'
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || rw_crapcop.dsdircop || '_CPF.lst'
                                   ,pr_flg_gerar => vr_agendamento
                                   ,pr_qtcoluna  => 132
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => NULL
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => NULL
                                   ,pr_nrcopias  => NULL
                                   ,pr_dspathcop => NULL
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_flsemqueb => 'S'
                                   ,pr_des_erro  => pr_des_erro);

        -- Verifica se ocorreram erros
        IF pr_des_erro IS NOT NULL THEN
          RAISE vr_ex_erro;
        END IF;

        -- Liberar dados do CLOB da memória
        dbms_lob.close(vr_str_5);
        dbms_lob.freetemporary(vr_str_5);
      EXCEPTION
        WHEN vr_ex_erro THEN
          pr_des_erro := pr_des_erro;
        WHEN others THEN
          pr_des_erro := 'Erro em pc_relatorio_cpf: ' || SQLERRM;
      END;
    END pc_relatorio_cpf;

    -- Procedure para inserir registros na Pl Table de registros temporários
    PROCEDURE pc_insere_temp(pr_nrdconta  crapass.nrdconta%TYPE  --> Número da conta
                            ,pr_vlsldapl1 IN NUMBER              --> Saldo da aplicação
                            ,pr_vlsldrdc  IN NUMBER              --> Saldo do RDC
                            ,pr_vlsldrda  IN NUMBER              --> Saldo do RDA
                            ,pr_vlsdpoup  IN NUMBER              --> Saldo poupança
                            ,pr_vlsldapl2 IN NUMBER              --> Saldo da aplicação
                            ,pr_vlslfrdc  IN NUMBER              --> Saldo da fração do RDC
                            ,pr_vlslfrda  IN NUMBER              --> Saldo da fração do RDA
                            ,pr_vlsfpoup  IN NUMBER              --> Saldo da fração da poupança
                            ,pr_des_erro  OUT VARCHAR2) AS       --> Mensagem de erro
    BEGIN
      DECLARE
        vr_index     VARCHAR2(50);
        vr_valor     NUMBER(20,2);

      BEGIN
        -- Cálculo do índice da PL Table
        IF pr_vlsldapl1 < 0 THEN
          vr_valor := pr_vlsldapl1 * -100;
        ELSE
          vr_valor := pr_vlsldapl1 * 100;
        END IF;

        vr_index := lpad(vr_valor, 35, '0') || lpad(999999999999999-pr_nrdconta , 15, '0');

        vr_tab_temp(vr_index).nrdconta := pr_nrdconta;
        vr_tab_temp(vr_index).vr_vlsldapl1 := pr_vlsldapl1;
        vr_tab_temp(vr_index).vr_vlsldrdc := nvl(pr_vlsldrdc, 0);
        vr_tab_temp(vr_index).vr_vlsldrda := pr_vlsldrda;
        vr_tab_temp(vr_index).vr_vlsdpoup := pr_vlsdpoup;
        vr_tab_temp(vr_index).vr_vlsldapl2 := pr_vlsldapl2;
        vr_tab_temp(vr_index).vr_vlslfrdc := pr_vlslfrdc;
        vr_tab_temp(vr_index).vr_vlslfrda := pr_vlslfrda;
        vr_tab_temp(vr_index).vr_vlsfpoup := pr_vlsfpoup;
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao executar pc_insere_temp: ' || SQLERRM;
      END;
    END pc_insere_temp;
  BEGIN

  EXECUTE IMMEDIATE 'Alter session set session_cached_cursors=200';

    -- Atribuição de valores iniciais da procedure
    vr_nrcopias := 2;
    vr_nmformul := '';
    vr_cdprogra := 'CRPS140';

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;

      pr_cdcritic := 651;

      vr_desc_erro := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

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

    -- Data de fim e inicio da utilização da taxa de poupança.
    -- Utiliza-se essa data quando o rendimento da aplicação for menor que
    -- a poupança, a cooperativa opta por usar ou não.
    -- Buscar a descrição das faixas contido na craptab
    OPEN cr_craptab(pr_cdcooper, 'CRED', 'USUARI', 11, 'MXRENDIPOS', 1);
    FETCH cr_craptab INTO rw_craptab;

    -- Se não encontrar registros
    IF cr_craptab%NOTFOUND THEN
      vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
      vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
    ELSE
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, rw_craptab.dstextab, ';'), 'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, rw_craptab.dstextab, ';'), 'DD/MM/YYYY');
    END IF;

    CLOSE cr_craptab;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PERCIRAPLI'
                                             ,pr_tpregist => 0);
    vr_dextabi := vr_dstextab;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Buscar dados das taxas
    OPEN cr_craptab(pr_cdcooper, 'CRED', 'USUARI', 11, 'MAIORESDEP', 1);
    FETCH cr_craptab INTO rw_craptab;

    -- Verifica se foram retornados registros
    IF cr_craptab%NOTFOUND THEN
      CLOSE cr_craptab;

      vr_tab_vlsdmadp := 10000;
    ELSE
      CLOSE cr_craptab;

      vr_tab_vlsdmadp := rw_craptab.dstextabs;

      IF vr_tab_vlsdmadp = 0 THEN
        vr_tab_vlsdmadp := 0.01;
      END IF;
    END IF;

    -- Carregar PL Table
    FOR vr_crapdtc IN cr_crapdtc(pr_cdcooper) LOOP
      vr_tab_crapdtc(vr_crapdtc.tpaplica).tpaplica := vr_crapdtc.tpaplica;
      vr_tab_crapdtc(vr_crapdtc.tpaplica).tpaplrdc := vr_crapdtc.tpaplrdc;
    END LOOP;

    -- Carregar PL Table
    vr_icxauto := 0;
    FOR vr_craprpp IN cr_craprpp(pr_cdcooper) LOOP
      vr_icxauto := vr_icxauto + 1;

      -- Criar registro de marcação de conta
      IF vr_icxauto = 1 THEN
        vr_tab_craprpp(lpad(vr_craprpp.nrdconta, 10, '0') || '0000000000').nrdconta := 99999;
      ELSE
        IF vr_craprpp.nrdconta <> vr_tab_craprpp(vr_idxindc).nrdconta THEN
          vr_tab_craprpp(lpad(vr_craprpp.nrdconta, 10, '0') || '0000000000').nrdconta := 99999;
        END IF;
      END IF;

      -- Criar índice
      vr_idxindc := lpad(vr_craprpp.nrdconta, 10, '0') || lpad(vr_icxauto, 10, '0');

      vr_tab_craprpp(vr_idxindc).nrdconta := vr_craprpp.nrdconta;
      vr_tab_craprpp(vr_idxindc).cdsitrpp := vr_craprpp.cdsitrpp;
      vr_tab_craprpp(vr_idxindc).vlslfmes := vr_craprpp.vlslfmes;
      vr_tab_craprpp(vr_idxindc).rowid := vr_craprpp.rowid;
    END LOOP;

    -- Carregar PL Table
    vr_icxauto := 0;
    FOR vr_craprda IN cr_craprda(pr_cdcooper) LOOP
      vr_icxauto := vr_icxauto + 1;

      -- Criar registro de marcação de conta
      IF vr_icxauto = 1 THEN
        vr_tab_craprda(lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || '0000000000').nrdconta := 99999;
      ELSE
        IF lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') <>
           lpad(vr_tab_craprda(vr_idxrda).nrdconta, 10, '0') || lpad(vr_tab_craprda(vr_idxrda).cdageass, 5, '0') THEN
          vr_tab_craprda(lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || '0000000000').nrdconta := 99999;
        END IF;
      END IF;

      -- Criar índice
      vr_idxrda := lpad(vr_craprda.nrdconta, 10, '0') || lpad(vr_craprda.cdageass, 5, '0') || lpad(vr_icxauto, 10, '0');

      vr_tab_craprda(vr_idxrda).nrdconta := vr_craprda.nrdconta;
      vr_tab_craprda(vr_idxrda).tpaplica := vr_craprda.tpaplica;
      vr_tab_craprda(vr_idxrda).vlslfmes := vr_craprda.vlslfmes;
      vr_tab_craprda(vr_idxrda).cdageass := vr_craprda.cdageass;
      vr_tab_craprda(vr_idxrda).nraplica := vr_craprda.nraplica;
    END LOOP;
		
		FOR vr_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper) LOOP
			
		  -- Abre cursor de cadastro de produtos
		  OPEN cr_crapcpc(vr_craprac.cdprodut);
		  FETCH cr_crapcpc INTO rw_crapcpc;
				 
		  -- Se não encontrar levantar exceção
		  IF cr_crapcpc%NOTFOUND THEN
			  vr_cdcritic := 0;
			  vr_dscritic := 'Produto de captacao nao encontrado';
				CLOSE cr_crapcpc;
			  RAISE vr_exc_saida;			 
		  END IF; 
			CLOSE cr_crapcpc;
				
		  IF rw_crapcpc.idtippro = 1 THEN -- Pré-fixada
				-- Calculo para obter saldo atualizado de aplicacao pre
			  APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
																							 ,pr_nrdconta => vr_craprac.nrdconta   --> Número da Conta
																							 ,pr_nraplica => vr_craprac.nraplica   --> Número da Aplicação
																							 ,pr_dtiniapl => vr_craprac.dtmvtolt   --> Data de Início da Aplicação
																							 ,pr_txaplica => vr_craprac.txaplica   --> Taxa da Aplicação
																							 ,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
																							 ,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
																							 ,pr_qtdiacar => vr_craprac.qtdiacar   --> Dias de Carência
																							 ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
																							 ,pr_dtinical => vr_craprac.dtmvtolt   --> Data Inicial Cálculo
																							 ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
																							 ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
																							 ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
																							 ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
																							 ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
																							 ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
																							 ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
																							 ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
																							 ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
																							 ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
																							 ,pr_cdcritic => vr_cdcritic           --> Código da crítica
																							 ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
																							          																							 
				-- Se procedure retornou erro																				
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				  vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> ' || vr_dscritic;
				  -- Levanta exceção
				  RAISE vr_exc_saida;
			  END IF;
				
			ELSIF rw_crapcpc.idtippro = 2 THEN -- Pós-fixada
					 
				APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
																							,pr_nrdconta => vr_craprac.nrdconta   --> Número da Conta
																							,pr_nraplica => vr_craprac.nraplica   --> Número da Aplicação
																							,pr_dtiniapl => vr_craprac.dtmvtolt   --> Data de Início da Aplicação
																							,pr_txaplica => vr_craprac.txaplica   --> Taxa da Aplicação
																							,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
																							,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
																							,pr_qtdiacar => vr_craprac.qtdiacar   --> Dias de Carência
																							,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
																							,pr_dtinical => vr_craprac.dtmvtolt   --> Data Inicial Cálculo
																							,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
																							,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
																							,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
																							,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
																							,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
																							,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
																							,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
																							,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
																							,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
																							,pr_percirrf => vr_percirrf           --> Percentual do IRRF
																							,pr_cdcritic => vr_cdcritic           --> Código da crítica
																							,pr_dscritic => vr_dscritic);         --> Descrição da crítica
																										
				-- Se procedure retornou erro																				
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				  vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos -> ' || vr_dscritic;
				  -- Levanta exceção
				  RAISE vr_exc_saida;
			  END IF;
					 
			END IF;
			
			OPEN cr_crapass_rac(pr_cdcooper => pr_cdcooper
			                   ,pr_nrdconta => vr_craprac.nrdconta);
      FETCH cr_crapass_rac INTO rw_crapass_rac;
			CLOSE cr_crapass_rac;
			-- Buscar dados de RDA
      -- Verificar se existe registros na PL Table
      IF vr_tab_craprda.exists(lpad(vr_craprac.nrdconta, 10, '0') || lpad(rw_crapass_rac.cdagenci, 5, '0') || '0000000000') THEN
        vr_idxrda := vr_tab_craprda.next(lpad(vr_craprac.nrdconta, 10, '0') || lpad(rw_crapass_rac.cdagenci, 5, '0') || '0000000000');
      ELSE
        vr_tab_craprda(lpad(vr_craprac.nrdconta, 10, '0') || lpad(rw_crapass_rac.cdagenci, 5, '0') || '0000000000').nrdconta := 99999;
				vr_icxauto := 1;
				vr_idxrda:= NULL;
      END IF;      			
			
			LOOP
        BEGIN
          EXIT WHEN vr_idxrda IS NULL;
			
					-- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
					-- Verifica se o próximo registro é null (chegamos ao final da PL Table)
					IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
						vr_icxauto := TO_NUMBER(SUBSTR(vr_idxrda, -10, 10)) + 1;
						vr_idxrda := NULL;						
					ELSE
						-- Verifica se já existe proxima conta
						IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
							 lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
							 lpad(vr_craprac.nrdconta, 10, '0') || lpad(rw_crapass_rac.cdagenci, 5, '0') THEN
							vr_icxauto := TO_NUMBER(SUBSTR(vr_idxrda, -10, 10)) + 1;
							vr_idxrda := NULL;
						ELSE
							vr_idxrda := vr_tab_craprda.next(vr_idxrda);
						END IF;
					END IF;					
				END;
			END LOOP;
			
      -- Criar índice
      vr_idxrda := lpad(vr_craprac.nrdconta, 10, '0') || lpad(rw_crapass_rac.cdagenci, 5, '0') || lpad(vr_icxauto, 10, '0');

      vr_tab_craprda(vr_idxrda).nrdconta := vr_craprac.nrdconta;
      vr_tab_craprda(vr_idxrda).tpaplica := rw_crapcpc.idtippro;
      vr_tab_craprda(vr_idxrda).vlslfmes := vr_craprac.vlslfmes;
      vr_tab_craprda(vr_idxrda).cdageass := rw_crapass_rac.cdagenci;
      vr_tab_craprda(vr_idxrda).nraplica := vr_craprac.nraplica;
			vr_tab_vlsldtot(vr_idxrda).vlsldtot := vr_vlsldtot;
		
		END LOOP;

    -- Carregar PL Table
    FOR vr_crapasss IN cr_crapasss(pr_cdcooper) LOOP
      -- Criar índice
      vr_idxindc := lpad(vr_crapasss.nrdconta, 10, '0');

      vr_tab_crapasss(vr_idxindc).nrdconta := vr_crapasss.nrdconta;
      vr_tab_crapasss(vr_idxindc).inpessoa := vr_crapasss.inpessoa;
      vr_tab_crapasss(vr_idxindc).nrcpfcgc := vr_crapasss.nrcpfcgc;
      vr_tab_crapasss(vr_idxindc).nrmatric := vr_crapasss.nrmatric;
      vr_tab_crapasss(vr_idxindc).cdagenci := vr_crapasss.cdagenci;
      vr_tab_crapasss(vr_idxindc).nmprimtl := vr_crapasss.nmprimtl;
    END LOOP;

    -- Carregar PL Table
    FOR vr_crapttl IN cr_crapttl(pr_cdcooper) LOOP
      vr_tab_crapttl(lpad(vr_crapttl.nrdconta, 10, '0')).cdempres := vr_crapttl.cdempres;
    END LOOP;

    -- Carregar PL Table
    FOR vr_crapjur IN cr_crapjur(pr_cdcooper) LOOP
      vr_tab_crapjur(lpad(vr_crapjur.nrdconta, 10, '0')).cdempres := vr_crapjur.cdempres;
    END LOOP;

    -- Iterar sob os dados os associados
    FOR vr_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_vlsldrdc := 0;
      vr_vlsldrda := 0;
      vr_vlsdpoup := 0;
      vr_vlslfrdc := 0;
      vr_vlslfrda := 0;
      vr_vlsfpoup := 0;

      -- Buscar dados de RDA
      -- Verificar se existe registros na PL Table
      IF vr_tab_craprda.exists(lpad(vr_crapass.nrdconta, 10, '0') || lpad(vr_crapass.cdagenci, 5, '0') || '0000000000') THEN
        vr_idxrda := vr_tab_craprda.next(lpad(vr_crapass.nrdconta, 10, '0') || lpad(vr_crapass.cdagenci, 5, '0') || '0000000000');
      ELSE
        vr_idxrda := null;
      END IF;

      LOOP
        BEGIN
          EXIT WHEN vr_idxrda IS NULL;

          IF vr_tab_craprda(vr_idxrda).tpaplica = 3 THEN
            -- Consultar cálculo de saldo
            apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                 ,pr_inproces => rw_crapdat.inproces
                                                 ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                 ,pr_cdprogra => vr_cdprogra
                                                 ,pr_cdagenci => vr_tab_craprda(vr_idxrda).cdageass
                                                 ,pr_nrdcaixa => 99 --> somente para gerar mensagem em caso de erro
                                                 ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
                                                 ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
                                                 ,pr_vlsdrdca => vr_vlsdrdca
                                                 ,pr_vlsldapl => vr_vlsldapl
                                                 ,pr_vldperda => vr_vldperda
                                                 ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                 ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                 ,pr_txaplica => vr_txaplica
                                                 ,pr_des_reto => vr_desc_erro
                                                 ,pr_tab_erro => vr_tab_craterr);

            -- Verifica se ocorreram erros na execução
            IF vr_desc_erro = 'NOK' THEN
              vr_desc_erro := 'Erro em apli0001.pc_consul_saldo_aplic_rdca30.';
              pr_cdcritic := 0;

              RAISE vr_saida;
            END IF;

            -- Se os aldo RDCA retornar zero ou menor irá para a próxima iteração
            IF nvl(vr_vlsdrdca, 0) <= 0 THEN
              RAISE vr_proximo;
            END IF;

            -- Atribuir valores
            vr_vlsldrda := vr_vlsldrda + vr_vlsdrdca;
            vr_vlslfrda := vr_vlslfrda + vr_tab_craprda(vr_idxrda).vlslfmes;

          ELSIF vr_tab_craprda(vr_idxrda).tpaplica = 5 THEN
            -- Consultar dados de aniversário para RDCA
            apli0001.pc_calc_aniver_rdca2c(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
                                          ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
                                          ,pr_vlsdrdca => vr_rd2_vlsdrdca
                                          ,pr_des_erro => vr_desc_erro);

            -- Verifica se ocorreram erros na execução
            IF vr_desc_erro = 'NOK' THEN
              vr_desc_erro := 'Erro em apli0001.pc_calc_aniver_rdca2c.';
              pr_cdcritic := 0;

              RAISE vr_saida;
            END IF;

            -- Atribuir valores
            vr_vlsldrda := vr_vlsldrda + vr_rd2_vlsdrdca;
            vr_vlslfrda := vr_vlslfrda + vr_tab_craprda(vr_idxrda).vlslfmes;
          ELSE
						IF NOT(vr_tab_craprda(vr_idxrda).tpaplica = 1  OR
							     vr_tab_craprda(vr_idxrda).tpaplica = 2) THEN
							-- Se não existir registro gera crítica e aborta execução
							IF NOT vr_tab_crapdtc.exists(vr_tab_craprda(vr_idxrda).tpaplica) THEN
								vr_cdcritic := 346;
								vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);

								btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
																					,pr_ind_tipo_log => 2 -- Erro tratato
																					,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||vr_cdprogra||' --> '||
																															vr_dscritic||'. '||' Conta/DV: '||
																															GENE0002.fn_mask_conta(pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta) ||
																															' - Nr. aplicação: ' ||
																															GENE0002.fn_mask(pr_dsorigi => vr_tab_craprda(vr_idxrda).nraplica,pr_dsforma => 'zzz.zz9'));

								RAISE vr_saida;
							END IF;

							-- Limpar tabela de erros e variável
							vr_tab_craterr.delete;
							vr_vlaplrdc := 0;

							-- Para RDCPRE
							IF vr_tab_crapdtc(vr_tab_craprda(vr_idxrda).tpaplica).tpaplrdc = 1 THEN
								apli0001.pc_saldo_rdc_pre(pr_cdcooper    => pr_cdcooper
																				 ,pr_nrdconta    => vr_tab_craprda(vr_idxrda).nrdconta
																				 ,pr_nraplica    => vr_tab_craprda(vr_idxrda).nraplica
																				 ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
																				 ,pr_dtiniper    => NULL
																				 ,pr_dtfimper    => NULL
																				 ,pr_txaplica    => 0
																				 ,pr_flggrvir    => FALSE
																				 ,pr_tab_crapdat => rw_crapdat
																				 ,pr_vlsdrdca    => vr_vlaplrdc
																				 ,pr_vlrdirrf    => vr_vlrdirrf
																				 ,pr_perirrgt    => vr_perirrgt
																				 ,pr_des_reto    => vr_desc_erro
																				 ,pr_tab_erro    => vr_tab_craterr);

								-- Caso encontre erros
								IF vr_desc_erro = 'NOK' THEN
									vr_cdcritic := 0;
									btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
																						,pr_ind_tipo_log => 2 -- Erro tratato
																						,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
																																vr_desc_erro || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
																																' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);

									RAISE vr_saida;
								END IF;
							-- Para RDCPOS
							ELSIF vr_tab_crapdtc(vr_tab_craprda(vr_idxrda).tpaplica).tpaplrdc = 2 THEN
								apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper
																				 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																				 ,pr_dtmvtopr => rw_crapdat.dtmvtopr
																				 ,pr_nrdconta => vr_tab_craprda(vr_idxrda).nrdconta
																				 ,pr_nraplica => vr_tab_craprda(vr_idxrda).nraplica
																				 ,pr_dtmvtpap => rw_crapdat.dtmvtolt
																				 ,pr_dtcalsld => rw_crapdat.dtmvtolt
																				 ,pr_flantven => FALSE
																				 ,pr_flggrvir => FALSE
																				 ,pr_dtinitax => vr_dtinitax
																				 ,pr_dtfimtax => vr_dtfimtax
																				 ,pr_vlsdrdca => vr_vlaplrdc
																				 ,pr_vlrentot => vr_vlrentot
																				 ,pr_vlrdirrf => vr_vlrdirrf
																				 ,pr_perirrgt => vr_perirrgt
																				 ,pr_des_reto => vr_desc_erro
																				 ,pr_tab_erro => vr_tab_craterr);

								-- Verifica se ocorreram erros na execução
								IF vr_desc_erro = 'NOK' THEN
									vr_cdcritic := 0;
									btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
																						,pr_ind_tipo_log => 2 -- Erro tratato
																						,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
																																vr_desc_erro || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
																																' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);

									RAISE vr_saida;
								END IF;
							END IF;

							-- Atribuição de valores
							vr_vlsldrdc := nvl(vr_vlsldrdc, 0) + nvl(vr_vlaplrdc, 0);
							vr_vlslfrdc := vr_vlslfrdc + nvl(vr_tab_craprda(vr_idxrda).vlslfmes, 0);
						
						ELSE
							-- Atribuição de valores
							vr_vlsldrdc := nvl(vr_vlsldrdc, 0) + vr_tab_vlsldtot(vr_idxrda).vlsldtot;
							vr_vlslfrdc := vr_vlslfrdc + nvl(vr_tab_craprda(vr_idxrda).vlslfmes, 0);
						END IF;

          END IF;

          -- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
          -- Verifica se o próximo registro é null (chegamos ao final da PL Table)
          IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
            vr_idxrda := NULL;
          ELSE
            -- Verifica se já existe proxima conta
            IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
                 lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
               lpad(vr_crapass.nrdconta, 10, '0') || lpad(vr_crapass.cdagenci, 5, '0') THEN
              vr_idxrda := NULL;
            ELSE
              vr_idxrda := vr_tab_craprda.next(vr_idxrda);
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_saida THEN
            RAISE vr_exc_erro;
          WHEN vr_proximo THEN
            -- Controle para definir se o LOOP irá continuar a iteração (atribui NULL caso não continue)
            -- Verifica se o próximo registro é null (chegamos ao final da PL Table)
            IF vr_tab_craprda.next(vr_idxrda) IS NULL THEN
              vr_idxrda := NULL;
            ELSE
              -- Verifica se já existe proxima conta
              IF lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).nrdconta, 10, '0') ||
                   lpad(vr_tab_craprda(vr_tab_craprda.next(vr_idxrda)).cdageass, 5, '0') <>
                 lpad(vr_crapass.nrdconta, 10, '0') || lpad(vr_crapass.cdagenci, 5, '0') THEN
                vr_idxrda := NULL;
              ELSE
                vr_idxrda := vr_tab_craprda.next(vr_idxrda);
              END IF;
            END IF;
          WHEN others THEN
            vr_cdcritic := 0;
            vr_desc_erro := 'Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

      -- Verificar se existe registros na PL Table
      IF vr_tab_craprpp.exists(lpad(vr_crapass.nrdconta, 10, '0') || '0000000000') THEN
        vr_idxindc := vr_tab_craprpp.next(lpad(vr_crapass.nrdconta, 10, '0') || '0000000000');
      ELSE
        vr_idxindc := null;
      END IF;

      -- Iterar sobre a PL Table
      LOOP
        BEGIN
          EXIT WHEN vr_idxindc IS NULL;

          -- Sempre irá testar o índice futuro para executar atribuição de dados pelo índice anterior
          IF vr_tab_craprpp(vr_idxindc).nrdconta = vr_crapass.nrdconta THEN
            -- Passa para o próximo registro
            IF vr_tab_craprpp(vr_idxindc).cdsitrpp = 5 THEN
              -- Buscar próximo índice
              vr_idxindc := vr_tab_craprpp.next(vr_idxindc);

              RAISE vr_iterar;
            END IF;

            -- Calcular o saldo até a data do movimento
            apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                     ,pr_dstextab  => vr_dextabi
                                     ,pr_cdprogra  => vr_cdprogra
                                     ,pr_inproces  => rw_crapdat.inproces
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                     ,pr_rpp_rowid => vr_tab_craprpp(vr_idxindc).rowid
                                     ,pr_vlsdrdpp  => vr_rpp_vlsdrdpp
                                     ,pr_cdcritic  => pr_cdcritic
                                     ,pr_des_erro  => vr_desc_erro);

            -- Se encontrar erros na execução
            IF vr_desc_erro IS NOT NULL THEN
              vr_cdcritic := 0;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_desc_erro || '. ');

              RAISE vr_saida;
            END IF;

            -- Atribuir valores para as variáveis
            vr_vlsdpoup := vr_vlsdpoup + nvl(vr_rpp_vlsdrdpp, 0);
            vr_vlsfpoup := vr_vlsfpoup + nvl(vr_tab_craprpp(vr_idxindc).vlslfmes, 0);

            -- Buscar próximo índice
            vr_idxindc := vr_tab_craprpp.next(vr_idxindc);
          ELSE
            vr_idxindc := null;
          END IF;
        EXCEPTION
          WHEN vr_saida THEN
            RAISE vr_exc_saida;
          WHEN vr_iterar THEN
            NULL;
        END;
      END LOOP;

      -- Atribuir valores para as variáveis
      vr_vlsldapl := nvl(vr_vlsldrda, 0) + nvl(vr_vlsldrdc, 0) + nvl(vr_vlsdpoup, 0);
      vr_vlsldapl2 := nvl(vr_vlslfrda, 0) + nvl(vr_vlslfrdc, 0) + nvl(vr_vlsfpoup, 0);

      -- Criar dados de arquivo temporário
      pc_insere_temp(pr_nrdconta  => vr_crapass.nrdconta
                    ,pr_vlsldapl1 => vr_vlsldapl
                    ,pr_vlsldrdc  => vr_vlsldrdc
                    ,pr_vlsldrda  => vr_vlsldrda
                    ,pr_vlsdpoup  => vr_vlsdpoup
                    ,pr_vlsldapl2 => vr_vlsldapl2
                    ,pr_vlslfrdc  => vr_vlslfrdc
                    ,pr_vlslfrda  => vr_vlslfrda
                    ,pr_vlsfpoup  => vr_vlsfpoup
                    ,pr_des_erro  => vr_desc_erro);

      -- Se encontrar erros na execução
      IF vr_desc_erro = 'NOK' THEN
        vr_cdcritic := 0;
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_desc_erro || '. ');

        RAISE vr_exc_saida;
      END IF;
    END LOOP;

    -- Verificar se ocorreram críticas
    IF vr_cdcritic > 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Especificar inicialização do XML
    -- Arquivo CRRL117
    dbms_lob.createtemporary(vr_str_1, TRUE);
    dbms_lob.open(vr_str_1, dbms_lob.lob_readwrite);
    vr_data_buffer := '<?xml version="1.0" encoding="utf-8"?><base>';

    -- Limpar quantidade de registros processados
    vr_qtregist := 0;

    -- Iterar sobre PL Table de registros temporários
    vr_idxpl := vr_tab_temp.last;

    LOOP
      BEGIN
        EXIT WHEN vr_idxpl IS NULL;

        -- Acumular quantidade de registros
        vr_qtregist := vr_qtregist + 1;

        -- Verifica se existe registro, se não encontrar gera crítica
        IF NOT vr_tab_crapasss.exists(lpad(vr_tab_temp(vr_idxpl).nrdconta, 10, '0')) THEN
          vr_cdcritic := 9;
          RAISE vr_exc_saida;
        ELSE
          vr_idxcrapasss := lpad(vr_tab_temp(vr_idxpl).nrdconta, 10, '0');
        END IF;

        -- Limpar valor da variável
        vr_cdempres := 0;

        -- Identifica se é pessoa jurídica ou física
        IF vr_tab_crapasss(vr_idxcrapasss).inpessoa = 1 THEN
          -- Verifica se registro de pessoa física existe
          IF vr_tab_crapttl.exists(vr_idxcrapasss) THEN
            vr_cdempres := vr_tab_crapttl(vr_idxcrapasss).cdempres;
          END IF;
        ELSE
          -- Verifica se registro de pessoa jurídica existe
          IF vr_tab_crapjur.exists(vr_idxcrapasss) THEN
            vr_cdempres := vr_tab_crapjur(vr_idxcrapasss).cdempres;
          END IF;
        END IF;

        pc_cria_aplicadores(pr_nrcpfcgc  => vr_tab_crapasss(vr_idxcrapasss).nrcpfcgc
                           ,pr_inpessoa  => vr_tab_crapasss(vr_idxcrapasss).inpessoa
                           ,pr_vlsldapl2 => vr_tab_temp(vr_idxpl).vr_vlsldapl2
                           ,pr_vlslfrdc  => vr_tab_temp(vr_idxpl).vr_vlslfrdc
                           ,pr_vlslfrda  => vr_tab_temp(vr_idxpl).vr_vlslfrda
                           ,pr_vlsfpoup  => vr_tab_temp(vr_idxpl).vr_vlsfpoup
                           ,pr_nmprimtl  => vr_tab_crapasss(vr_idxcrapasss).nmprimtl
                           ,pr_des_erro  => vr_desc_erro);

        -- Se ocorreu erro
        IF vr_desc_erro IS NOT NULL THEN
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;

        -- Pular caso valor atenda condição
        IF nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0) <= 0 THEN
          RAISE vr_pula;
        END IF;

        -- Valida valores para ir para a proxima iteração do laço
        IF nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0) < nvl(vr_tab_vlsdmadp, 0) THEN
          RAISE vr_pula;
        END IF;

        -- Gera dados para arquivo principal
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<dados cdagenci=''' || vr_tab_crapasss(vr_idxcrapasss).cdagenci || '''>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<qtregist>'||to_char(vr_qtregist,'FM999G999G990')||'</qtregist>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<nrdconta>'||to_char(vr_tab_temp(vr_idxpl).nrdconta,'FM999999G999G0')||'</nrdconta>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<cdempres>'||vr_cdempres||'</cdempres>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<nrmatric>'||to_char(vr_tab_crapasss(vr_idxcrapasss).nrmatric,'FM999G999G990')||
                                          '</nrmatric>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
        vr_data_buffer := vr_data_buffer||'<nmprimtl>'||vr_tab_crapasss(vr_idxcrapasss).nmprimtl||'</nmprimtl>';
        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

        IF vr_tab_temp(vr_idxpl).vr_vlsldapl1 > 0 THEN
          vr_data_buffer := vr_data_buffer||'<vlsldapl>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldapl1,'FM999G999G999G999G990D90')||
                                            '</vlsldapl>';
        ELSE
          vr_data_buffer := vr_data_buffer||'<vlsldapl> </vlsldapl>';
        END IF;

        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

        IF vr_tab_temp(vr_idxpl).vr_vlsldrdc > 0 THEN
          vr_data_buffer := vr_data_buffer||'<vlsldrdc>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldrdc,'FM999G999G999G999G990D90')||
                                            '</vlsldrdc>';
        ELSE
          vr_data_buffer := vr_data_buffer||'<vlsldrdc> </vlsldrdc>';
        END IF;

        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

        IF vr_tab_temp(vr_idxpl).vr_vlsldrda > 0 THEN
          vr_data_buffer := vr_data_buffer||'<vlsldrda>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsldrda,'FM999G999G999G999G990D90')||
                                            '</vlsldrda>';
        ELSE
          vr_data_buffer := vr_data_buffer||'<vlsldrda> </vlsldrda>';
        END IF;

        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

        IF vr_tab_temp(vr_idxpl).vr_vlsdpoup > 0 THEN
          vr_data_buffer := vr_data_buffer||'<vlsdpoup>'||to_char(vr_tab_temp(vr_idxpl).vr_vlsdpoup,'FM999G999G999G999G990D90')||
                                              '</vlsdpoup></dados>';
        ELSE
          vr_data_buffer := vr_data_buffer||'<vlsdpoup> </vlsdpoup></dados>';
        END IF;

        pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

        -- Sumarização de valores
        vr_tot_vlsldapl := vr_tot_vlsldapl + nvl(vr_tab_temp(vr_idxpl).vr_vlsldapl1, 0);
        vr_tot_vlsldrdc := vr_tot_vlsldrdc + nvl(vr_tab_temp(vr_idxpl).vr_vlsldrdc, 0);
        vr_tot_vlsdrdca := vr_tot_vlsdrdca + nvl(vr_tab_temp(vr_idxpl).vr_vlsldrda, 0);
        vr_tot_vlsdpoup := vr_tot_vlsdpoup + nvl(vr_tab_temp(vr_idxpl).vr_vlsdpoup, 0);

        -- Localiza próximo registro
        vr_idxpl := vr_tab_temp.prior(vr_idxpl);
      EXCEPTION
        WHEN vr_pula THEN
          -- Localiza próximo registro
          vr_idxpl := vr_tab_temp.prior(vr_idxpl);
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_desc_erro := 'Erro gerando XML STR_1: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    END LOOP;

    -- Gerar dados da sumarização no arquivo principal
    pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

    vr_data_buffer := vr_data_buffer||'<total><tot_vlsldapl>'||to_char(vr_tot_vlsldapl,'FM999G999G999G999G990D90')||'</tot_vlsldapl>';
    pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
    
    vr_data_buffer := vr_data_buffer||'<tot_vlsldrdc>'||to_char(vr_tot_vlsldrdc,'FM999G999G999G999G990D90')||'</tot_vlsldrdc>';
    pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
    
    vr_data_buffer := vr_data_buffer||'<tot_vlsdrdca>'||to_char(vr_tot_vlsdrdca,'FM999G999G999G999G990D90')||'</tot_vlsdrdca>';
    pc_limpa_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);
    
    vr_data_buffer := vr_data_buffer||'<tot_vlsdpoup>'||to_char(vr_tot_vlsdpoup,'FM999G999G999G999G990D90')||'</tot_vlsdpoup></total></base>';
    pc_final_buffer(pr_buffer => vr_data_buffer, pr_str => vr_str_1);

    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_str_1
                               ,pr_dsxmlnode => '/base/dados'
                               ,pr_dsjasper  => 'crrl117.jasper'
                               ,pr_dsparams  => 'PR_QUEBRA##N'
                               ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || '.lst'
                               ,pr_flg_gerar => vr_agendamento
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => vr_desc_erro);

    -- Verifica se ocorreram erros
    IF vr_desc_erro IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_desc_erro := 'Erro gerando arquivo ' || vr_nomarq || '.lst' || ': ' || vr_desc_erro;
      RAISE vr_exc_saida;
    END IF;

    -- Criar arquivo igual ao anterior, somente para agendamento
    IF vr_agendamento = 'N' THEN
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_str_1
                                 ,pr_dsxmlnode => '/base/dados'
                                 ,pr_dsjasper  => 'crrl117.jasper'
                                 ,pr_dsparams  => 'PR_QUEBRA##N'
                                 ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || '_999.lst'
                                 ,pr_flg_gerar => vr_agendamento
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => NULL
                                 ,pr_nrcopias  => NULL
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_flsemqueb => 'N'
                                 ,pr_des_erro  => vr_desc_erro);

      -- Verifica se ocorreram erros
      IF vr_desc_erro IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_desc_erro := 'Erro gerando arquivo ' || vr_nomarq || '_99.lst' || ': ' || vr_desc_erro;
        RAISE vr_exc_saida;
     END IF;
    ELSE
      gene0001.pc_OScommand_Shell('cp ' || vr_nom_dir || vr_nomarq || '.lst '|| vr_nom_dir || vr_nomarq || '_99.lst');
    END IF;

    -- Criar arquivo totalização sem quebra com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_str_1
                               ,pr_dsxmlnode => '/base/dados'
                               ,pr_dsjasper  => 'crrl117.jasper'
                               ,pr_dsparams  => 'PR_QUEBRA##S'
                               ,pr_dsarqsaid => vr_nom_dir || vr_nomarq || rw_crapcop.dsdircop || '.lst'
                               ,pr_flg_gerar => vr_agendamento
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'N'
                               ,pr_nmformul  => NULL
                               ,pr_nrcopias  => NULL
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'S'
                               ,pr_des_erro  => vr_desc_erro);

    -- Verifica se ocorreram erros
    IF vr_desc_erro IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_desc_erro := 'Erro gerando arquivo ' || vr_nomarq || rw_crapcop.dsdircop || '.lst' || ': ' || vr_desc_erro;
      RAISE vr_exc_saida;
    END IF;

    -- Liberar dados do CLOB da memória
    dbms_lob.close(vr_str_1);
    dbms_lob.freetemporary(vr_str_1);

    -- Criar nova PL Table reordenada
    pc_order_table(vr_desc_erro);

    -- Verifica se ocorreram erros
    IF vr_desc_erro IS NOT NULL THEN
      pr_cdcritic := 0;
      RAISE vr_exc_saida;
    END IF;

    -- Gerar arquivo separado por CPF
    pc_relatorio_cpf(vr_desc_erro);

    -- Verifica se ocorreram erros
    IF vr_desc_erro IS NOT NULL THEN
      vr_cdcritic := 0;
      RAISE vr_exc_saida;
    END IF;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
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
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_desc_erro;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS140;
/

