CREATE OR REPLACE PROCEDURE CECRED.pc_crps195(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN
  /* ............................................................................
     Programa: pc_crps195                      Antigo: Fontes/crps195.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odair
     Data    : Maio/97.                        Ultima atualizacao: 11/12/2015
  
     Dados referentes ao programa:
  
     Frequencia: Solicitacao (Batch).
     Objetivo  : Atende a solicitacao 072.
                 Gerar avisos de debito/credito referente convenios.
                 Emite relatorio 152.
  
     Alteracoes: 01/07/97 - Criar tabela para fechamento convenio 8 (Odair)
  
                 15/07/97 - Tratar parametro da solicitacao 1,2 (Odair)
  
                 27/08/97 - Alterado para incluir o campo flgproce na criacao
                            do crapavs (Deborah).
  
                 05/11/97 - Criar o numero do documento que vem do arquivo (Odair)
  
                 16/12/97 - Colocar dtresumo no crapctc para arquivos zerados
                            (Odair)
  
                 22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                            zeros (Deborah).
  
                 24/03/98 - Cancelada a alteracao anterior (Deborah).
  
                 27/04/98 - Melhorar restart (Odair)
  
                 09/11/98 - Tratar situacao em prejuizo (Deborah).
  
                 09/04/1999 - Alterado para tirar a consistencia das
                              empresas conveniadas (Deborah).
  
                 08/10/1999 - No convenio 8 permitir somente empresa 1 (Deborah).
  
                 11/11/1999 - No convenio 8 permitir tambem empresa 99 (Deborah).
  
                 15/02/2000 - Quando integrar apos o credito da folha,
                              jogar para debito em conta (Deborah).
  
                 24/02/2000 - Acerto na alteracao anterior (Deborah).
  
                 29/03/2000 - Jogar os debitos para conta corrente se a folha
                              ja tiver sido creditada (Deborah).
  
                 23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                              titular (Eduardo).
  
                 25/11/2003 - Nao imprimir se o convenio nao foi integrado e nao
                              nao e obrigatorio (Deborah).
  
                 11/11/2004 - Enviar e-mail, se existir o e-mail, com o relatorio
                              gerado em anexo (Evandro).
  
                 29/06/2005 - Alimentado campo cdcooper das tabelas craprej,
                              crapavs, crapctc e crapepc (Diego).
  
                 20/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).
  
                 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                              ATENCAO: ESSA ALTERACAO NAO FOI INCLUIDA NO
                              BACALHAU/CRPB169
  
                 20/11/2006 - Envio de email pela BO b1wgen0011 (David).
  
                 02/03/2007 - Criticar empresas que nao estiverem no crapcnv
                              (Julio)
  
                 27/03/2007 - Acerto na critica da empresa - Criticar somente a
                              for conveniado a FOLHA (Ze).
  
                 12/04/2007 - Retirar rotina de email em comentario (David).
  
                 31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
  
                 19/10/2009 - Alteracao Codigo Historico (Kbase).
  
                 06/05/2011 - Melhorado mensagem da critica referente ao erro
                              182 para ser colocada no log (Adriano).
  
                 14/05/2012 - Tratado para nao parar processo quando critica 182
                              (Diego).
  
                 16/01/2014 - Inclusao de VALIDATE craprej, crapavs, crapctc e
                              crapepc (Carlos)
   
                 22/05/2014 - Remover o comando que despreza cod. convenios
                            superior a 48 (Ze).
                            
                 03/06/2014 - Ajustado tamanho do numero do documento (Elton).
                            
                 05/06/2014 - Conversao Progress -> Oracle (Alisson - AMcom)
                 
                 22/01/2015 - Revalidação do Programa. Foram ajustadas as atribuições 
                              das variaveis vr_nmarquiv, vr_nmarqimp e vr_dsconven retirando o 
                              to_char e usando o lpad para respeitar a formatação do progress. (Alisson - AMcom)
                              
                 20/03/2015 - Ajustado para não gerar relatorio quando critica 562, conforme
                              versão Progress (Daniel/Tiago)          

			     05/05/2015 - Incluso tratamento para não gerar error ao converter data do arquivo (Daniel)
                 
                 18/05/2015 - Incluso alteração para enviar e-mail comunicando arquivos que geraram erro no 
                              batch e alterar para mover os arquivos apenas depois do commit. O programa não
                              irá mais causar paradas no batch. ( Renato - Supero )
                 
                 23/06/2015 - Feito tratamento para não gerar erro ao converter data, antes era feito um trim 
                              na variável e comparado com null [ TRIM(vr_tab_string(idx)) IS NOT NULL ] , 
                              agora foi posto uma validação comparando com [ AND vr_tab_string(idx) <> '' ]
                              SD 294181. (Kelvin)              
				
				 11/06/2015 - Projeto 158 - Servico Folha de Pagto
                              (Andre Santos - SUPERO)
                              
                 11/12/2015 - Alterado log do proc_batch para o proc_message (Lucas Ranghetti #366543)
                
  Atencao ----> Sempre que alterar este programa alterar o bacalhau/crpb169.
  ............................................................................. */

  DECLARE
  
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS195';
  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_dscrtrel   VARCHAR2(4000);
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Selecionar informacoes da solicitação
    CURSOR cr_crapsol (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
      SELECT sol.dsparame
        FROM crapsol sol, crapprg prg
       WHERE prg.cdcooper = sol.cdcooper AND
             prg.nrsolici = sol.nrsolici AND
             prg.cdcooper = pr_cdcooper  AND
             prg.cdprogra = pr_cdprogra  AND
             sol.insitsol = 1; -- Ativa
    vr_dsparame crapsol.dsparame%TYPE;
  
    -- Busca dados dos convenios
    CURSOR cr_crapcnv(pr_cdcooper IN crapcnv.cdcooper%TYPE
		                 ,pr_nrconven IN crapcnv.nrconven%TYPE
                     ,pr_tpconven IN NUMBER) IS
      SELECT cnv.nrconven,
             cnv.dsconven,
             cnv.lshistor,
             cnv.inobriga,
             decode(cnv.inobriga,1,'Sim','Nao') dsobriga,
             cnv.intipdeb,
             decode(cnv.intipdeb,1,'Conta','Folha') dstipdeb,
             cnv.indebcre,
             decode(cnv.indebcre,'D','Debito','Credito') dsdebcre,
             cnv.inlimsld,
             decode(cnv.inlimsld,1,'Sim','Nao') dslimsld,
             cnv.lsempres,
             cnv.dsdemail,
             cnv.dddebito,
             cnv.inmesdeb
        FROM crapcnv cnv
       WHERE cnv.cdcooper = pr_cdcooper AND
             cnv.nrconven > pr_nrconven AND
             cnv.tpconven = pr_tpconven 
       ORDER BY cnv.cdcooper, cnv.nrconven;
  
    -- Cursor para busca de associados
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta,
             ass.inpessoa,
             ass.cdsitdtl,
             ass.dtelimin,
             ass.cdagenci,
             ass.cdsecext
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper AND
             ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    -- Cursor para busca de titular da conta pf
    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT ttl.cdempres
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper AND
             ttl.nrdconta = pr_nrdconta AND
             ttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;
  
    -- Cursor para busca de titular da conta pj
    CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.cdempres
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper AND
             jur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
  
    -- Cursor para transferencia e duplicação da matrícula
    CURSOR cr_craptrf (pr_cdcooper IN crapcop.cdcooper%TYPE 
                      ,pr_nrdconta IN craptrf.nrdconta%TYPE) IS
      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper AND
             trf.nrdconta = pr_nrdconta AND
             trf.tptransa = 1 AND
             trf.insittrs = 2
      ORDER BY trf.cdcooper, trf.nrdconta, trf.tptransa, trf.nrsconta, trf.progress_recid;
    rw_craptrf cr_craptrf%ROWTYPE;
  
    -- Cursor para busca de empresa
    CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdempres IN crapemp.cdempres%TYPE) IS
      SELECT emp.flgpagto, emp.flgpgtib, emp.cdempres, emp.dtavsemp, emp.tpconven
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper AND
             emp.cdempres = pr_cdempres;
    rw_crapemp cr_crapemp%ROWTYPE;
  
    -- Cursor para verificar débito em folha
    CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT  tab.cdempres
             ,tab.dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper  AND
             upper(tab.nmsistem) = 'CRED'       AND
             upper(tab.tptabela) = 'USUARI'     AND
             upper(tab.cdacesso) = 'EXECDEBEMP' AND
             tab.tpregist = 0;
    
	  -- Cursor de tabela genérica
		CURSOR cr_craptab_proc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT tab.dstextab
  	        ,tab.ROWID
			  FROM craptab tab
			 WHERE tab.cdcooper = pr_cdcooper
			   AND upper(tab.nmsistem) = 'CRED'
				 AND upper(tab.tptabela) = 'GENERI'
				 AND tab.cdempres = 11
				 AND upper(tab.cdacesso) = 'PROCCONVEN'
				 AND tab.tpregist = 0;
		rw_craptab_proc cr_craptab_proc%ROWTYPE;
  
    -- Cursor para controle de convenio integrados por empresa
    CURSOR cr_crapepc (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrconven IN crapepc.nrconven%TYPE
		                  ,pr_cdempres IN crapepc.cdempres%TYPE
											,pr_dtrefere IN crapepc.dtrefere%TYPE) IS
      SELECT epc.cdcooper
			  FROM crapepc epc
			 WHERE epc.cdcooper = pr_cdcooper AND
			       epc.nrconven = pr_nrconven AND
						 epc.cdempres = pr_cdempres AND
						 epc.dtrefere = pr_dtrefere;
		rw_crapepc cr_crapepc%ROWTYPE;
    				 
	  -- Conta quantidade de convenios integrados por empresa
	  CURSOR cr_qtdcrapepc (pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrconven crapepc.nrconven%TYPE
											   ,pr_dtrefere crapepc.dtrefere%TYPE) IS
      SELECT count(1)
			  FROM crapepc epc
			 WHERE epc.cdcooper = pr_cdcooper AND
			       epc.nrconven = pr_nrconven AND
						 epc.dtrefere = pr_dtrefere;

		-- Cursor de controle de restart
    CURSOR cr_crapres (pr_cdcooper crapres.cdcooper%TYPE
		                  ,pr_cdprogra crapres.cdprogra%TYPE) IS
	    SELECT ROWID
			  FROM crapres res
			 WHERE res.cdcooper = pr_cdcooper
			   AND res.cdprogra = pr_cdprogra;
    rw_crapres cr_crapres%ROWTYPE;
		
		-- Cursor de rejeitados na integração
		CURSOR cr_craprej (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt craprej.dtmvtolt%TYPE
		                  ,pr_nrconven craprej.nrdolote%TYPE) IS
	    SELECT rej.vllanmto
			      ,rej.cdcritic
						,rej.nrdocmto
						,rej.nrdconta
						,rej.cdhistor
						,rej.dtdaviso
       FROM craprej rej
			WHERE rej.cdcooper = pr_cdcooper
			  AND rej.dtmvtolt = pr_dtmvtolt
				AND rej.cdagenci = 195
				AND rej.cdbccxlt = 195
				AND rej.nrdolote = pr_nrconven
				AND rej.tpintegr = 195
		  ORDER BY rej.nrdocmto
			        ,rej.dtmvtolt
							,rej.nrdconta;
		rw_craprej cr_craprej%ROWTYPE;			
		
		-- Cursor para controle de convenios
	  CURSOR cr_crapctc (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrconven crapctc.nrconven%TYPE
		                  ,pr_dtrefere crapctc.dtrefere%TYPE) IS
			SELECT ctc.nrconven,
						 ctc.dtrefere,
						 ctc.cdempres,
						 ctc.cdhistor,
						 ctc.vltarifa,
						 ctc.qtempres,
						 ctc.qtrejeit,
						 ctc.vlrejeit,
						 ctc.qtlanmto,
						 ctc.vllanmto			
			  FROM crapctc ctc
			 WHERE ctc.cdcooper = pr_cdcooper
			   AND ctc.nrconven = pr_nrconven
				 AND ctc.dtrefere = pr_dtrefere
				 AND ctc.cdempres = 0
				 AND ctc.cdhistor = 0;
		rw_crapctc cr_crapctc%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  
    TYPE typ_tab_craptab IS TABLE OF NUMBER INDEX BY VARCHAR2(21);
    vr_tab_craptab typ_tab_craptab;
    
    TYPE typ_tab_arquivo IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    vr_tab_movarq        typ_tab_arquivo;  -- Tabela de memória com os comandos de mov de arquivos
    vr_tab_arqerr        typ_tab_arquivo;  -- Tabela de memória com os arquivos que apresentaram erro
    vr_tab_deserr        typ_tab_arquivo;  -- Tabela de memória com o erro ocorrido no arquivo
    
    ------------------------------- VARIAVEIS -------------------------------
  
	  -- Variaveis para controle de arquivos/diretorios
		vr_nom_direto        VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    vr_nom_direto_rl     VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    vr_nom_direto_salvar VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    vr_nom_direto_conven VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    vr_comando           VARCHAR2(200);                 -- Descricao do comando para executar no Unix
    vr_typ_saida         VARCHAR2(3);                   -- Retorno da Execucao do comando unix
		vr_nmarquiv          VARCHAR2(15);                  -- Nome do arquivo
    vr_nmarqdir          VARCHAR2(100);                 -- Nome do arquivo de convênio
    vr_nmarqimp          VARCHAR2(20);                  -- Nome do relatório
		vr_input_file        utl_file.file_type;            -- Handle para leitura de arquivo
    vr_setlinha          VARCHAR2(4000);                -- Texto do arquivo lido
    vr_dsparam           VARCHAR2(4000);                -- Parametros com os totais do relatorio
		vr_texto_completo    VARCHAR2(32600);               -- String Completa para o CLOB    
  	vr_tab_string        gene0002.typ_split;            -- Tabela de String

    vr_dsemlctr          CRAPPRM.DSVLRPRM%TYPE;         -- Endereço de e-mail para envio das informações de arquivos com erro
    vr_conteudo          VARCHAR2(30000);               -- Montar a mensagem de e-mail
		
	  -- Variaveis utilizadas para o relatório
    vr_clobxml    CLOB;                                 -- Clob para conter o XML de dados    
    vr_dtfimmes   DATE;                                 -- Data do fim do mês
    vr_dtinimes   DATE;                                 -- Data de inicio do mês    
    vr_dsconven   VARCHAR2(100);                        -- Descrição do convênio
    vr_lshisto1   VARCHAR2(100);                        -- Lista de históricos 1
    vr_lshisto2   VARCHAR2(100);                        -- Lista de históricos 2
    vr_vllanmto_aux VARCHAR2(100);                      -- Valor lancamento na string
    vr_flgmostra  VARCHAR2(1);                          -- Mostrar ou nao o cabecalho
    vr_flgfirst   BOOLEAN;                              -- Flag para identificar primeira linha do arquivo
    vr_vlinfoln   NUMBER(12,2);                         -- Valor do débito a integrar
    vr_qtinfoln   INTEGER(6);                           -- Quantidade a integrar
    vr_qtdifeln   INTEGER(6);                           -- Quantidade rejeitados
    vr_vldifeln   NUMBER(12,2);                         -- Valor do débito rejeitado
    vr_cdempant   INTEGER;                              -- Código da empresa anterior
    vr_cdempres   INTEGER;                              -- Código da empresa
    vr_qtcompln   INTEGER(6);                           -- Quantidade integrados
    vr_vlcompln   NUMBER(12,2);                         -- Valor do débito integrado
    
    vr_dtregist   DATE;                                 -- Data do registro do arquivo de convenio
    vr_tpregist   INTEGER(1);                           -- Tipo do registro do arquivo de convenio
    vr_vllanmto   NUMBER(12,2);                         -- Valor do lancamento
    vr_nrseqint   INTEGER;                              -- Número de sequencia
    vr_nrdocmto   INTEGER;                              -- Número do documento
    vr_set_nrdocmto NUMBER;                             -- Número do documento auxiliar
		vr_nrdocavs   NUMBER;                               -- Número de documento dos avisos de débito em C.C.
    vr_nrdconta   crapass.nrdconta%TYPE;                -- Número da conta
    vr_cdhistor   NUMBER;                               -- Código do histórico
    vr_dtrefhis   DATE;                                 -- Data de referencia do histórico
	  vr_flgfolha   BOOLEAN;		                          -- Débito em folha ou em conta
    vr_dtdebavs   DATE;                                 -- Data débito dos avisos de débito em C.C.
    vr_dtdebito   DATE;                                 -- Data do débito
		vr_incvcta1   NUMBER;                               -- Ind. de controle de debito em conta.
    vr_qtempcnv   INTEGER;                              -- Quantidade de emprestimo por convenio
    vr_indfolha   INTEGER;                              -- Indicador desconto folha
		vr_dtresumo   crapctc.dtresumo%TYPE;		            -- Data de emissao do resumo
		
    -- Variaveis para Controle Indices 
    vr_index_craptab  VARCHAR2(21);
    vr_index_craptab2 VARCHAR2(21);
		-- Variáveis para controle de restart
		vr_nrctares crapass.nrdconta%TYPE;    --> Número da conta de restart
		vr_dsrestar VARCHAR2(4000);           --> String genérica com informações para restart
		vr_inrestar INTEGER;                  --> Indicador de Restart
  
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
		/* Procedure para criação de controle de convenio integrados por empresa */
    PROCEDURE pc_nova_empresa(pr_cdcooper IN crapcop.cdcooper%TYPE      -- Cod. Cooperativa
                             ,pr_cdempres IN crapemp.cdempres%TYPE      -- Cód. da empresa
                             ,pr_intipdeb IN crapcnv.intipdeb%TYPE      -- Indicador de debito (0-na folha, 1-sempre debito em conta).
                             ,pr_dttabela IN DATE                       -- Data do fim do mes
                             ,pr_dddebito IN crapcnv.dddebito%TYPE      -- Dia para débito
                             ,pr_inmesdeb IN crapcnv.inmesdeb%TYPE      -- Indicador do mes de debito (0-no mes, 1-no mes seguinte).
												     ,pr_nrconven IN crapcnv.nrconven%TYPE   	  -- Número do convênio
                             ,pr_flgfolha IN OUT BOOLEAN                -- Desconto em Folha
                             ,pr_dscritic OUT VARCHAR2) IS              -- Descricao Erro 
			--Variaveis Locais
      vr_exc_erro EXCEPTION;														
    BEGIN
      --Inicializar parametro erro
      pr_dscritic:= NULL;
      
			-- Busca empresa
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_cdempres => pr_cdempres);
      FETCH cr_crapemp INTO rw_crapemp;
		  -- Se não encontrou empresa
      IF cr_crapemp%NOTFOUND THEN
				-- 040 - Empresa nao cadastrada.
        vr_cdcritic:= 40;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
				-- Fecha cursor da crapemp
				CLOSE cr_crapemp;
				
				-- Gera log da crítica
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE') 
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        -- Retorna para onde esta procedure foi chamada																											
        RETURN;
      END IF;
			-- Fecha o cursor
			CLOSE cr_crapemp;
      
      -- Débito em conta
      pr_flgfolha:= FALSE;
			-- Débito no dia da Folha
      IF (rw_crapemp.flgpagto = 1 OR rw_crapemp.flgpgtib = 1) THEN
				-- Indicador de débito em folha
        IF pr_intipdeb = 0 THEN
					-- Montar Indice acesso tabela generica
          vr_index_craptab:= lpad(rw_crapemp.cdempres,10,'0')||TO_CHAR(pr_dttabela,'DD/MM/YYYY')||'1';
          vr_index_craptab2:= lpad(rw_crapemp.cdempres,10,'0')||TO_CHAR(pr_dttabela,'DD/MM/YYYY')||'2';
          -- Verifica Cobranca na tabela genérica
          IF NOT vr_tab_craptab.EXISTS(vr_index_craptab) AND NOT vr_tab_craptab.EXISTS(vr_index_craptab2) THEN
            -- Se não encontrou, Débito em folha
            pr_flgfolha:= TRUE;
          END IF;
        END IF;
      END IF;
      
			-- Se a data de geracao do aviso de debito de emprestimos for menor que a data atual
      IF rw_crapemp.dtavsemp < rw_crapdat.dtmvtolt THEN
				-- Data de geracao do aviso de debito de emprestimos recebe a data atual
        vr_dtdebavs:= rw_crapdat.dtmvtolt;
      ELSE
				-- Se o Tipo de convenio for 1 - normal
        IF rw_crapemp.tpconven = 1 THEN
					-- Data de geracao do aviso de debito de emprestimos recebe data de aviso da empresa
          vr_dtdebavs:= rw_crapemp.dtavsemp;
        ELSE
					-- Senao recebe data de inicio do mes 
          vr_dtdebavs:= vr_dtinimes;
        END IF;
      END IF;
      -- Cód. empresa anterior recebe cód. da empresa
      vr_cdempant:= vr_cdempres;
    
		  -- Se for débito em conta
      IF NOT pr_flgfolha THEN
				-- Monta a data de débito a partir do dia do débito passado por parâmetro
        vr_dtdebito:= to_date(
                         to_char(rw_crapdat.dtmvtolt, 'MM')||
                         to_char(pr_dddebito,'FM09')||
                         to_char(rw_crapdat.dtmvtolt, 'RRRR')
                      ,'MMDDRRRR');
			  -- Se o indicador do mês de débito não for no mês corrente
        IF pr_inmesdeb > 0 THEN
          -- Monta data de débito a partir da quantidade de meses no pr_inmesdeb
          vr_dtdebito:= GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtdebito     --> Data do movimento
                                             ,pr_qtmesano => pr_inmesdeb     --> Quantidade a acumular
                                             ,pr_tpmesano => 'M'             --> Tipo Mes ou Ano
                                             ,pr_des_erro => vr_dscritic);   --> Saída com erro          
        END IF;
      ELSE
				-- Se for débito em folha, data de débito recebe null
        vr_dtdebito := NULL;
      END IF;
			
			-- Abre cursor de controle de convenio integrados por empresa.
			OPEN cr_crapepc (pr_cdcooper => pr_cdcooper,       -- Cod. Cooperativa
                       pr_nrconven => pr_nrconven,       -- Nr. Convênio
			                 pr_cdempres => pr_cdempres,       -- Cód. empresa
											 pr_dtrefere => pr_dttabela);      -- Data de referencia
			FETCH cr_crapepc INTO rw_crapepc;
			-- Se não encontrar convênio da empresa
			IF cr_crapepc%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapepc;
				-- Se débito em folha
				IF pr_flgfolha THEN					 
				  vr_incvcta1:= 0;
          vr_indfolha:= 1;
        ELSE
					-- Débito em conta
					vr_incvcta1:= 1;
          vr_indfolha:= 0;
			  END IF;
				-- Insere controle de convenio por empresa
        BEGIN
  				INSERT INTO crapepc
				    (cdcooper    
						,nrconven    
						,cdempres
						,dtrefere    
						,incvfol1
						,incvfol2    
						,incvcta1
						,incvcta2
						,dtcvfol1
						,dtcvfol2
						,dtcvcta1
						,dtcvcta2)
					VALUES
					  (pr_cdcooper          -- Cooperativa
					  ,pr_nrconven          -- Numero do convenio
					 	,rw_crapemp.cdempres  -- Cód. empresa
					  ,pr_dttabela	        -- Data de referencia
						,vr_indfolha          -- Indice de controle se há debito em folha (0 - nao tem, 1 - tem)
						,0                    -- Ind. de controle de debito 2 dias apos a folha
						,vr_incvcta1          -- Ind. de controle de debito em conta.
						,0                    -- Ind. de controle do segundo debito em conta.
						,NULL                 -- Data do credito da folha.
						,NULL                 -- Data do dia seguinte ao credito da folha
						,vr_dtdebito          -- Data do debito em conta.
						,NULL);               -- Data do segundo debito em conta.
        EXCEPTION
          WHEN OTHERS THEN
            --Montar Erro
            vr_dscritic:= 'Erro ao inserir crapepc. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;                  
			ELSE
				-- Fecha cursor
				CLOSE cr_crapepc;
			END IF;			
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic:= 'Erro na rotina pc_crps195.pc_nova_empresa: '||sqlerrm;  
    END; -- Fim nova_empresa
  
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
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
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
	  -- Tratamento e retorno de valores de restart
		btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
															,pr_cdprogra  => vr_cdprogra   --> Código do programa
															,pr_flgresta  => pr_flgresta   --> Indicador de restart
															,pr_nrctares  => vr_nrctares   --> Número da conta de restart
															,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
															,pr_inrestar  => vr_inrestar   --> Indicador de Restart
															,pr_cdcritic  => vr_cdcritic   --> Código de erro
															,pr_des_erro  => vr_dscritic); --> Saída de erro
    -- Se encontrou erro, gerar exceção
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;   
		
    -- Consultar Solicitacoes
		OPEN cr_crapsol (pr_cdcooper => pr_cdcooper
                    ,pr_cdprogra => vr_cdprogra);
    FETCH cr_crapsol INTO vr_dsparame;
    --Fechar Cursor
    CLOSE cr_crapsol;

    IF vr_dsparame = '2' THEN
      -- Atribui o último dia do mês passado
      vr_dtfimmes:= rw_crapdat.dtmvtolt - to_number(to_char(rw_crapdat.dtmvtolt, 'dd'));
      vr_dtinimes:= rw_crapdat.dtmvtolt;
    ELSE
      -- Atribui o último dia do mês corrente
      vr_dtfimmes:= trunc(last_day(rw_crapdat.dtmvtolt));
      vr_dtinimes:= vr_dtfimmes;
    
      --Buscar Proximo Dia Util
      vr_dtinimes:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => vr_dtinimes
                                               ,pr_tipo     => 'P');
    END IF;
      
    --Limpar tabela de Memoria Debito Empresa
    vr_tab_craptab.DELETE;
    --Carregar tabela de memoria Debito Empresa
    FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper) LOOP
      --Montar Indice
      vr_index_craptab:= lpad(rw_craptab.cdempres,10,'0')||SUBSTR(rw_craptab.dstextab,01,10)||'1';
      --Se nao existir
      IF NOT vr_tab_craptab.EXISTS(vr_index_craptab) THEN  
        --Inserir na tabela memoria
        vr_tab_craptab(vr_index_craptab):= 0;
      ELSE
        vr_index_craptab:= lpad(rw_craptab.cdempres,10,'0')||SUBSTR(rw_craptab.dstextab,01,10)||'2';
        --Inserir na tabela memoria
        vr_tab_craptab(vr_index_craptab):= 0;
      END IF;    
    END LOOP;
      
	  -- Busca do diretório base da cooperativa para a geração de relatórios
	  vr_nom_direto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
							    										   ,pr_cdcooper => pr_cdcooper   --> Cooperativa
							  	   									   ,pr_nmsubdir => NULL);        --> Utilizaremos o rl
    
    -- Montar Demais diretorios
    vr_nom_direto_rl:= vr_nom_direto||'/rl';
    vr_nom_direto_salvar:= vr_nom_direto||'/salvar';
    vr_nom_direto_conven:= vr_nom_direto||'/convenios';

		-- Para cada convênio
    FOR rw_crapcnv IN cr_crapcnv(pr_cdcooper => pr_cdcooper                     -- Cod. Cooperativa
			                          ,pr_nrconven => vr_nrctares                     -- Nr. convênio
                                ,pr_tpconven => to_number(vr_dsparame)) LOOP    -- Tipo convênio
			BEGIN
        
        SAVEPOINT processa_arquivo;
        
        -- Inicializar a variável a cada iteração
        vr_clobxml := NULL;
        vr_texto_completo := NULL;
        																						
        -- Inicializar as informações do XML de dados para o relatório
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

        -- Atribui nome do arquivo de convênio
        vr_nmarquiv:= to_char(vr_dtfimmes, 'ddmmyyyy') ||'.'||SUBSTR(lpad(rw_crapcnv.nrconven,6,'0'),4,3);

        -- Montar Nome arquivo com diretorio Convenio
        vr_nmarqdir:= vr_nom_direto_conven ||'/'|| vr_nmarquiv;
        
        -- Nome do relatório
        vr_nmarqimp:= 'crrl152_'||SUBSTR(lpad(rw_crapcnv.nrconven,6,'0'),5,2) ||'.lst';
        -- <Nr. do convênio> - <Descrição do convênio>
        vr_dsconven:= SUBSTR(lpad(rw_crapcnv.nrconven,6,'0'),4,3) ||' - ' || rw_crapcnv.dsconven;
        -- Lista de históricos 1
        vr_lshisto1:= trim(SUBSTR(nvl(rw_crapcnv.lshistor, ' '),1,80));
        -- Lista de históricos 2
        vr_lshisto2:= trim(SUBSTR(nvl(rw_crapcnv.lshistor, ' '),81,80));
  			
        
        -- Escreve dados do convênio no relatório
        gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
            '<crrl152 dsconven="'||vr_dsconven||'" inobriga="'||rw_crapcnv.dsobriga||
            '" dsdebcre="'||rw_crapcnv.dsdebcre||'" indebito="'||rw_crapcnv.dstipdeb||  
            '" inlimite="'||rw_crapcnv.dslimsld||'" lshisto1="'||vr_lshisto1||
            '" lshisto2="'||vr_lshisto2||'"><criticas><critica>');
        
        -- Verifica se arquivo de convênio existe
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqdir) THEN
          -- Ind. de obrigatoriedade (0-nao obrigatorio, 1-obrigatorio)
          IF rw_crapcnv.inobriga = 1 THEN
            -- 182 - Arquivo nao existe
            vr_cdcritic:= 182;
            -- Buscar a descrição da critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

            -- Escreve crítica no relatório
            gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
                '<dscritic>' || vr_dscritic || '</dscritic>' ||'</critica></criticas></crrl152>',TRUE);                  
                                      
            -- Montar parametros com os totais
            vr_dsparam:= 'PR_DSDEBCRE##'||rw_crapcnv.dsdebcre||'@@'||
                         'PR_QTINFOLN##0@@'||
                         'PR_VLINFOLN##0,00@@'||
                         'PR_QTCOMPLN##0@@'||
                         'PR_VLCOMPLN##0,00@@'||
                         'PR_QTDIFELN##0@@'||
                         'PR_VLDIFELN##0,00@@'||
                         'PR_MOSTRATOT##N@@'||
                         'PR_MOSTRADAD##N';                                                        
                           
                 
            -- Submeter o relatório 152
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
                                       ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl152'                    --> Nó base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl152.jasper'              --> Arquivo de layout do iReport
                                       ,pr_dsparams  => vr_dsparam                    --> Parâmetros para totais
                                       ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
                                       ,pr_qtcoluna  => 132                           --> 132 colunas
                                       ,pr_flg_gerar => 'N'                           --> Geraçao na hora
                                       ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                       ,pr_nrcopias  => 2                             --> Número de cópias
                                       ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                       ,pr_fldoscop  => 'S'                           --> Executar ux2dos
                                       ,pr_dsmailcop => rw_crapcnv.dsdemail           --> Email
                                       ,pr_dsassmail => 'INTEGRACAO DE CONVENIOS'     --> Assunto do e-mail		 
                                       ,pr_des_erro  => vr_dscritic);                 --> Saída com erro

            -- Se ocorreu erro no relatorio
            IF vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            -- Gera log para informar que arquivo não foi processado
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2 -- Erro tratato
									  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')			
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')    ||
                                                          ' - ' || vr_cdprogra    ||' --> '||
                                                          vr_dscritic             ||' --> '||
                                                          'ATENCAO!! O arquivo '  ||vr_nmarquiv||
                                                          ' do convenio '         ||vr_dsconven||
                                                          ' nao foi processado. VERIFICAR DIRETORIO CONVENIOS.');
            -- Zera variáveis																							
            vr_cdcritic:= 0;
            vr_dscritic:= NULL;
            --Liberar Memoria alocada pelo Clob
            dbms_lob.close(vr_clobxml);
            dbms_lob.freetemporary(vr_clobxml);
            -- Pula para o próximo registro de convênio																												
            CONTINUE;
          -- Se não for obrigatório
          ELSIF rw_crapcnv.inobriga = 0 THEN
            -- 562 - Convenio nao processado.
            vr_cdcritic:= 562;
            -- Buscar a descrição da critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
  				  						 
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2 -- Erro tratato
									  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(SYSDATE,
                                                                  'hh24:mi:ss') ||
                                                          ' - '   ||vr_cdprogra||
                                                          ' --> ' ||vr_dscritic||
                                                          ' --> ' ||vr_nmarquiv);												 
            -- Zera variáveis																							
            vr_cdcritic:= 0;
            vr_dscritic:= NULL;
            -- Fechar Clob
            dbms_lob.close(vr_clobxml);
            dbms_lob.freetemporary(vr_clobxml);
            -- Pula para o próximo registro de convênio
            CONTINUE;
          END IF;							
        END IF;
      
        -- Zera variáveis
        vr_flgfirst:= TRUE;
        vr_vlinfoln:= 0;
        vr_qtinfoln:= 0;
        vr_qtdifeln:= 0;
        vr_vldifeln:= 0;
        vr_cdempant:= 0;
        vr_qtcompln:= 0;
        vr_vlcompln:= 0;
        vr_dscritic:= NULL;
      
        -- Abrir o arquivo para leitura
        gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarqdir   --> Diretório do arquivo
                                ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic); --> Descricao do erro
      
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Escrever erro no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2 -- Erro tratato
									  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(SYSDATE,
                                                                  'hh24:mi:ss') ||
                                                          ' - ' ||vr_cdprogra   ||
                                                          ' --> ' ||vr_dscritic ||
                                                          ' --> Erro ao abrir arquivo: '|| vr_nmarquiv);
        END IF;
      
        -- Verifica se o arquivo esta aberto
        IF utl_file.IS_OPEN(vr_input_file) THEN
          LOOP
            --Inicializar Critica
            vr_cdcritic:= 0;
            -- Se for a primeira linha
            IF vr_flgfirst THEN
              -- Se não estiver em restart
              IF vr_inrestar = 0 THEN
                -- 219 - INTEGRANDO ARQUIVO
                vr_cdcritic:= 219;
                -- Busca critica
                vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
                
                -- Gera critica no log
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2 -- Erro tratato
										  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                          ,pr_des_log      => to_char(SYSDATE,
                                                                      'hh24:mi:ss') ||' - ' ||
                                                              vr_cdprogra || ' --> '||
                                                              vr_dscritic || ' --> '||
                                                              vr_nmarquiv);
                -- Zera cód. crítica
                vr_cdcritic:= 0;
                -- Le os dados do arquivo e coloca na variavel vr_setlinha
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido
                
                -- Pega primeira entrada anterior ao caracter <espaço> (' ')
                vr_tpregist:= NVL(gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_setlinha,' ')), 0);
                -- Pega segunda entrada anterior ao caracter <espaço> (' ')
                vr_dtregist:= to_date(gene0002.fn_busca_entrada(2, vr_setlinha, ' '), 'dd/mm/rrrr');
  								
                /* Se a data de registro for nula ou data de regitro for diferente da data de fim do mês 
                   ou tipo de registro for diferente de 1 */
                IF vr_dtregist IS NULL OR vr_dtregist <> vr_dtfimmes OR vr_tpregist <> 1 THEN
                  -- 301 - DADOS NAO CONFEREM!
                  vr_cdcritic:= 301;
                END IF;
                
                -- Se houve crítica
                IF vr_cdcritic > 0 THEN
                  -- Busca critica
                  vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic) ||' No registro de Controle';
                  -- Gera critica no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                             pr_ind_tipo_log => 2 -- Erro tratato
										    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                            ,pr_des_log      => to_char(SYSDATE,
                                                                        'hh24:mi:ss') ||
                                                                ' - ' ||vr_cdprogra   ||
                                                                ' --> '||vr_dscritic);

                  -- Escreve crítica no relatório
                  gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
                    '<dscritic>' || vr_dscritic || '</dscritic>' ||'</critica></criticas></crrl152>',TRUE);												  																 

                                        
                  -- Montar parametros com os totais
                  vr_dsparam:= 'PR_DSDEBCRE##'||rw_crapcnv.dsdebcre||'@@'||
                               'PR_QTINFOLN##0@@'||
                               'PR_VLINFOLN##0,00@@'||
                               'PR_QTCOMPLN##0@@'||
                               'PR_VLCOMPLN##0,00@@'||
                               'PR_QTDIFELN##0@@'||
                               'PR_VLDIFELN##0,00@@'||
                               'PR_MOSTRATOT##N@@'||
                               'PR_MOSTRADAD##N';                                                                                                              

                  -- Submeter o relatório 152
                  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                             ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
                                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
                                             ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                             ,pr_dsxmlnode => '/crrl152'                    --> Nó base do XML para leitura dos dados
                                             ,pr_dsjasper  => 'crrl152.jasper'              --> Arquivo de layout do iReport
                                             ,pr_dsparams  => vr_dsparam                    --> Parâmetros para totais
                                             ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
                                             ,pr_qtcoluna  => 132                           --> 132 colunas
                                             ,pr_flg_gerar => 'N'                           --> Geraçao na hora
                                             ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
                                             ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                             ,pr_nrcopias  => 2                             --> Número de cópias
                                             ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                             ,pr_fldoscop  => 'S'                           --> Executar ux2dos
                                             ,pr_dsmailcop => rw_crapcnv.dsdemail           --> Email
                                             ,pr_dsassmail => 'INTEGRACAO DE CONVENIOS'     --> Assunto do e-mail		 
                                             ,pr_des_erro  => vr_dscrtrel);                 --> Saída com erro

                  --Se ocorreu erro no relatorio
                  IF vr_dscrtrel IS NOT NULL THEN
                    vr_dscritic := vr_dscrtrel;
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                  END IF; 											
                  -- Liberar Memoria alocada pelo Clob											 
                  dbms_lob.close(vr_clobxml);
                  dbms_lob.freetemporary(vr_clobxml);
                  -- Levanta exceção
                  RAISE vr_exc_saida;
                  
                END IF;
                -- Atribui flag de primeira linha para false
                vr_flgfirst:= FALSE;
              -- Se está em restart
              ELSE
                  
                /*  Registro de Controle  */
                -- Le os dados do arquivo e coloca na variavel vr_setlinha
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido
                
                -- Pega primeira entrada anterior ao caracter <espaço> (' ')
                vr_tpregist:= NVL(gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_setlinha,' ')),0);
                
                -- Ignorar registros de restart já processados
                WHILE vr_nrseqint < TO_NUMBER(vr_dsrestar) LOOP
                  -- Le os dados do arquivo e coloca na variavel vr_setlinha
                  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                              ,pr_des_text => vr_setlinha); --> Texto lido
                           
                  -- Quebrar Informacoes da String e colocar no vetor                            
                  vr_tab_string:= gene0002.fn_quebra_string(vr_setlinha,' ');
                                       
                  --Separar os valores lidos da string
                  FOR idx IN 1..6 LOOP
                    IF idx IN (1,2,4) AND vr_tab_string.EXISTS(idx) THEN
                      CASE idx
                        WHEN 1 THEN --Tipo de Registro
                          vr_tpregist:= vr_tab_string(idx);
                        WHEN 2 THEN --Sequencial
                          vr_nrseqint:= gene0002.fn_char_para_number(vr_tab_string(idx));
                        WHEN 4 THEN --Valor Lancamento
                          vr_vllanmto_aux:= vr_tab_string(idx);
                      END CASE;        
                    END IF;                            
                  END LOOP;
                      
                  -- Incrementa quantidade a integrar
                  vr_qtinfoln:= nvl(vr_qtinfoln,0) + 1;
                  -- Pega quarta entrada anterior ao caracter <espaço> (' ')
                  vr_vllanmto:= gene0002.fn_char_para_number(vr_vllanmto_aux);
                  -- Incrementa o valor do débito a integrar com o valor de lançamento
                  vr_vlinfoln:= nvl(vr_vlinfoln,0) + nvl(vr_vllanmto,0);
                END LOOP;
                  
                -- Nr. do documento recebe quantidade a integrar + 1
                vr_nrdocmto:= nvl(vr_qtinfoln,0) + 1;
                  
                -- Se o tipo do registro do arquivo de convenio for 9
                IF vr_tpregist = 9 THEN
                  -- Decrementa Quantidade a integrar								  
                  vr_qtinfoln:= nvl(vr_qtinfoln,0) - 1;
                  -- Decrementa valor do débito a integrar
                  vr_vlinfoln:= nvl(vr_vlinfoln,0) - nvl(vr_vllanmto,0);
                  -- Escreve crítica no relatório
                  gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
                      '<dscritic>' || vr_dscritic || '</dscritic>');
                  -- Sair do loop
                  EXIT;
                END IF;
                -- Atribui flag de primeira linha para false
                vr_flgfirst:= FALSE;
              END IF;
            END IF; --vr_flgfirst
              
            -- Zerar Documento
            vr_set_nrdocmto:= 0;
              
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
  																				
            -- Quebrar Informacoes da String e colocar no vetor                            
            vr_tab_string:= gene0002.fn_quebra_string(vr_setlinha,' ');
              
            FOR idx IN 1..7 LOOP
              --Se Existir informacao
              IF vr_tab_string.EXISTS(idx) THEN
                CASE idx
                  WHEN 1 THEN --Tipo de Registro
                    vr_tpregist:= vr_tab_string(idx);
                  WHEN 2 THEN --Sequencial
                    vr_nrseqint:= gene0002.fn_char_para_number(vr_tab_string(idx));
                  WHEN 3 THEN --Numero da Conta
                    vr_nrdconta:= gene0002.fn_char_para_number(vr_tab_string(idx));
                  WHEN 4 THEN --Valor Lancamento
                    vr_vllanmto_aux:= vr_tab_string(idx);
                  WHEN 5 THEN --Historico
                    vr_cdhistor:= gene0002.fn_char_para_number(vr_tab_string(idx));
                  WHEN 6 THEN --Data Referencia
                     IF TRIM(vr_tab_string(idx)) IS NOT NULL THEN 
                       vr_dtrefhis:= to_date(vr_tab_string(idx),'dd/mm/rrrr');
                    END IF;   
                  WHEN 7 THEN --Numero Documento   
                    vr_set_nrdocmto:= gene0002.fn_char_para_number(vr_tab_string(idx));
                END CASE;        
              END IF;
            END LOOP;   
  												
            -- Se o tipo do registro do arquivo de convenio for 9 ou Nr. da conta 99999999
            IF vr_tpregist = 9 OR vr_nrdconta = 99999999 THEN
              -- Fim do arquivo, sai do loop
              EXIT;
            END IF;
              
            -- Converter valor do lancamento
            vr_vllanmto:= gene0002.fn_char_para_number(vr_vllanmto_aux);
            -- Incrementa o valor do débito a integrar com o valor de lançamento
            vr_vlinfoln:= nvl(vr_vlinfoln,0) + nvl(vr_vllanmto,0);
            -- Incrementa quantidade a integrar
            vr_qtinfoln:= nvl(vr_qtinfoln,0) + 1;
              
            -- Abre cursor de associados  
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
                
            -- Se encontrou associado
            IF cr_crapass%FOUND THEN
              -- Fecha cursor
              CLOSE cr_crapass;
              -- Se for pessoa física
              IF rw_crapass.inpessoa = 1 THEN
                -- Busca titular da conta
                OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta);
                FETCH cr_crapttl INTO rw_crapttl;
                -- Se encontrou titular
                IF cr_crapttl%FOUND THEN
                  -- Atribui código da empresa do titular
                  vr_cdempres:= rw_crapttl.cdempres;
                ELSE
                  vr_cdempres:= NULL;  
                END IF;
                -- Fecha cursor
                CLOSE cr_crapttl;
               -- Se for pessoa jurídica
              ELSE
                -- Abre cursor de pessoa jurídica
                OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta);
                FETCH cr_crapjur INTO rw_crapjur;
                -- Se encontrou PJ
                IF cr_crapjur%FOUND THEN
                  -- Pega código da empresa da PJ
                  vr_cdempres:= rw_crapjur.cdempres;
                ELSE
                  vr_cdempres:= NULL;  
                END IF;
                -- Fecha cursor
                CLOSE cr_crapjur;
              END IF;
               -- Se o cód. da situação do titular for (5,6,7 ou 8)
              IF rw_crapass.cdsitdtl BETWEEN 5 AND 8 THEN
                -- 695 - ATENCAO! Houve prejuizo nessa conta
                vr_cdcritic:= 695;
              -- Senão, se cód. da situação do titular for (2 ou 4)
              ELSIF rw_crapass.cdsitdtl IN (2,4) THEN
                 -- Abre cursor de Transferencia e Duplicacao de Matricula
                OPEN cr_craptrf (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta);
                FETCH cr_craptrf INTO rw_craptrf;
                 -- Se encontrar registro de Transferencia e Duplicacao de Matricula
                IF cr_craptrf%FOUND THEN
                  -- Variável recebe  número da conta de Transferencia e Duplicacao de Matricula
                  vr_nrdconta:= rw_craptrf.nrsconta;
                  -- Fecha o cursor
                  CLOSE cr_craptrf;
                  -- Pula para o próximo registro do loop
                  CONTINUE;
                ELSE
                  -- Fecha cursor
                  CLOSE cr_craptrf;
                  -- 095 - Titular da conta bloqueado.
                  vr_cdcritic:= 95;
                END IF;
              -- Senão, se Data de eliminacao dos valores (Saldo e capital) for nula.
              ELSIF rw_crapass.dtelimin IS NOT NULL THEN
                -- 410 - Associado excluido.
                vr_cdcritic:= 410;
              -- Senão, se na lista de empresas conveniadas não conterem o código da empresa e for débito em folha
              ELSIF (gene0002.fn_existe_valor(pr_base => rw_crapcnv.lsempres
                                             ,pr_busca => vr_cdempres
                                             ,pr_delimite => ',') = 'N' AND rw_crapcnv.intipdeb = 0) THEN
                -- 558 - Empresa nao e conveniada.
                vr_cdcritic:= 558;
              --Senao, se na lista de empresas conveniadas não conterem o código da empresa e o número de convênio for 8
              ELSIF (gene0002.fn_existe_valor(pr_base => rw_crapcnv.lsempres
                                              ,pr_busca => vr_cdempres
                                              ,pr_delimite => ',') = 'N' AND rw_crapcnv.nrconven = 8) THEN
                -- 558 - Empresa nao e conveniada.
                vr_cdcritic:= 558;
              -- Senão, se a lista de historicos não conterem o código do historico	
              ELSIF (gene0002.fn_existe_valor(pr_base => rw_crapcnv.lshistor
                                              ,pr_busca => vr_cdhistor
                                              ,pr_delimite => ',') = 'N') THEN
                -- 559 - Historico nao permitido no convenio.
                vr_cdcritic:= 559;
              -- Senão, se encontrar "." no valor de lançamento ou for menor ou igual a 0
              ELSIF SUBSTR(to_char(vr_vllanmto_aux),10,1) = '.' OR vr_vllanmto <= 0 THEN
                -- 269 - Valor errado.
                vr_cdcritic:= 269;
              -- Senão, se o tipo de registro for diferente de 0
              ELSIF vr_tpregist <> 0 THEN
                -- 468 - Tipo de registro errado.
                vr_cdcritic:= 468;
              -- Senão, se cód. da empresa anterior for diferente do cód. da empresa
              ELSIF vr_cdempant <> vr_cdempres THEN
                -- Chama procedure para criação de controle de convenio integrados por empresa
                pc_nova_empresa(pr_cdcooper => pr_cdcooper
                               ,pr_cdempres => vr_cdempres
                               ,pr_intipdeb => rw_crapcnv.intipdeb
                               ,pr_dttabela => vr_dtfimmes
                               ,pr_dddebito => rw_crapcnv.dddebito
                               ,pr_inmesdeb => rw_crapcnv.inmesdeb
                               ,pr_nrconven => rw_crapcnv.nrconven
                               ,pr_flgfolha => vr_flgfolha
                               ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;                 
              END IF;
            -- Se não encontrar associado	                                              
            ELSE
              -- Fecha cursor
              CLOSE cr_crapass;
              -- 009 - Associado nao cadastrado.
              vr_cdcritic:= 9;
            END IF;
  						
            -- Salva programa até aqui
            SAVEPOINT saveP1;
  						
            -- Se houve crítica	
            IF vr_cdcritic > 0 THEN
              BEGIN
                -- Insere cadastro de rejeitados na integracao - D23.
                INSERT INTO craprej
                  (dtmvtolt 
                  ,tplotmov 
                  ,nrdconta 
                  ,cdempres 
                  ,cdhistor
                  ,vllanmto
                  ,nrdocmto
                  ,dtdaviso
                  ,cdcritic
                  ,cdagenci
                  ,cdbccxlt
                  ,nrdolote
                  ,tpintegr
                  ,cdcooper)
                VALUES
                  (rw_crapdat.dtmvtolt -- Data atual
                  ,0                   -- Tipo de movimento do lote
                  ,vr_nrdconta         -- Nr. da conta
                  ,0                   -- Cód. empresa
                  ,vr_cdhistor         -- Cód. histórico
                  ,vr_vllanmto         -- Valor de lançamento
                  ,vr_nrseqint         -- Número de sequencia
                  ,vr_dtrefhis         -- Data de referencia do histórico
                  ,vr_cdcritic         -- Código da crítica
                  ,195                 -- Número do PA
                  ,195                 -- Código Banco/Caixa
                  ,rw_crapcnv.nrconven -- Número do convenio
                  ,195                 -- Tipo de integracao onde houve ocorrencias.
                  ,pr_cdcooper);       -- Código da cooperativa
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  -- Gera crítica
                  vr_dscritic := 'Erro ao inserir craprej -> ' || SQLERRM;
                  -- Levanta exceção
                  RAISE vr_exc_saida;
              END;
              -- Zera cód. crítica								
              vr_cdcritic:= 0;		
            -- Se não houve crítica				
            ELSE
              -- Débito em folha
              IF vr_flgfolha THEN
                -- Incrementa número do documento
                vr_nrdocmto:= nvl(vr_nrdocmto,0) + 1;
  								
                -- Se o nr. do documento auxiliar for maior que 0
                IF vr_set_nrdocmto > 0 THEN
                  -- Número de documento dos avisos de débito em C.C. recebe nr. do documento auxiliar
                  vr_nrdocavs:= vr_set_nrdocmto;
                ELSE
                  -- Número de documento dos avisos de débito em C.C. recebe número do documento
                  vr_nrdocavs:= vr_nrdocmto;
                END IF;
                -- Se nr. do convenio for 8
                IF rw_crapcnv.nrconven = 8 THEN
                  -- Incrementa valor de lançamento com 0.5
                  vr_vllanmto:= nvl(vr_vllanmto,0) + 0.50;
                END IF;
                  
                BEGIN		
                  -- Insere cadastro dos avisos de debito em conta corrente.
                  INSERT INTO crapavs
                    (dtmvtolt
                    ,cdagenci
                    ,cdempres
                    ,cdhistor
                    ,cdsecext
                    ,dtdebito
                    ,dtrefere
                    ,insitavs
                    ,nrdconta
                    ,cdcooper
                    ,nrseqdig
                    ,nrdocmto
                    ,vllanmto
                    ,tpdaviso
                    ,vldebito
                    ,vlestdif
                    ,dtintegr
                    ,nrconven
                    ,cdempcnv
                    ,flgproce)
                   VALUES 
                     (vr_dtdebavs         -- Data de débito do aviso
                     ,rw_crapass.cdagenci -- PA
                     ,vr_cdempres         -- Cód. da empresa
                     ,vr_cdhistor         -- Cód. do histórico
                     ,rw_crapass.cdsecext -- Codigo da secao para onde deve ser enviado o extrato.
                     ,NULL                -- Data de débito
                     ,vr_dtfimmes         -- Data de referencia
                     ,0                   -- Situação do aviso
                     ,vr_nrdconta         -- Nr. da conta
                     ,pr_cdcooper         -- Cooperativa
                     ,vr_nrdocmto         -- Nr. do documento
                     ,vr_nrdocavs         -- Nr do documento do aviso
                     ,vr_vllanmto         -- Valor de lançamento
                     ,1                   -- Tipo de aviso
                     ,0                   -- Valor de débito
                     ,0                   -- Valor do estouro ou diferenca.
                     ,vr_dtrefhis         -- Data de integracao.
                     ,rw_crapcnv.nrconven -- Nr. do convênio
                     ,vr_cdempres         -- Cód. da empresa conveniada
                     ,0);                 -- Não processado
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    -- Monta descrição da crítica
                    vr_dscritic := 'Erro ao atualizar tabela crapavs com desconto em folha -> ' || SQLERRM;
                    -- Levanta exceção
                    RAISE vr_exc_saida;
                END;
              -- Se for débito em conta
              ELSE
                -- Incrementa nr. do documento
                vr_nrdocmto:= nvl(vr_nrdocmto,0) + 1;

                -- Se nr. do documento auxiliar for maior que 0
                IF vr_set_nrdocmto > 0 THEN
                  -- Nr. do documento do aviso recebe nr. do documento aux
                  vr_nrdocavs:= vr_set_nrdocmto;
                ELSE
                  -- Senão, recebe Nr. do documento
                  vr_nrdocavs:= vr_nrdocmto;
                END IF;
                -- Se número do convenio for 8
                IF rw_crapcnv.nrconven = 8 THEN
                  -- Incrementa valor de lançamento com 0.5
                  vr_vllanmto:= nvl(vr_vllanmto,0) + 0.50;
                END IF;
                  
                BEGIN	
                  -- Insere cadastro dos avisos de debito em conta corrente.
                  INSERT INTO crapavs
                    (cdagenci
                    ,cdempres
                    ,cdhistor
                    ,cdsecext
                    ,dtdebito
                    ,dtmvtolt															  
                    ,dtrefere
                    ,cdcooper
                    ,insitavs
                    ,nrdconta
                    ,nrdocmto
                    ,nrseqdig
                    ,tpdaviso
                    ,vldebito
                    ,vlestdif
                    ,dtintegr
                    ,vllanmto																
                    ,nrconven
                    ,cdempcnv
                    ,flgproce)
                  VALUES 
                     (rw_crapass.cdagenci -- PA
                     ,0                   -- Cód. da empresa
                     ,vr_cdhistor         -- Cód. do histórico
                     ,rw_crapass.cdsecext -- Codigo da secao para onde deve ser enviado o extrato.
                     ,vr_dtdebito			    -- Data de débito
                     ,rw_crapdat.dtmvtolt -- Data atual
                     ,vr_dtfimmes         -- Data do final do mês
                     ,pr_cdcooper         -- Cooperativa
                     ,0                   -- Situacao do aviso (0-naodeb/1-deb/2-deb menor).
                     ,rw_crapass.nrdconta -- Nr. da conta
                     ,vr_nrdocavs         -- Nr. doc. de aviso
                     ,vr_nrdocmto         -- Nr. doc
                     ,3                   -- Tipo de aviso
                     ,0                   -- Valor de débito
                     ,0									  -- Valor do estouro ou diferenca.
                     ,vr_dtrefhis         -- Data de integracao.
                     ,vr_vllanmto         -- Valor lançamento
                     ,rw_crapcnv.nrconven -- Nr. convenio
                     ,vr_cdempres         -- Cód. empresa conveniada
                     ,0);                 -- Não processado
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    -- Monta crítica
                    vr_dscritic:= 'Erro ao atualizar tabela crapavs sem desconto em folha -> ' || SQLERRM;
                    -- Levanta exceção
                    RAISE vr_exc_saida;
                END;
              END IF;							
  									
            END IF;						
              
            --Se tem controle de Restart
            IF NVL(vr_inrestar,0) <> 0 THEN
              -- Abre controle de restart
              OPEN cr_crapres(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra);
              FETCH cr_crapres INTO rw_crapres;								
              -- Se não encontrou
              IF cr_crapres%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_crapres;
                -- 151 - Registro de restart nao encontrado.
                vr_cdcritic:= 151;
                vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
                -- Gera log da crítica
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                              ' - ' || vr_cdprogra ||
                                                              ' --> ' || vr_dscritic);
                -- Faz rollback até o ponto salvo do programa																										
                ROLLBACK TO SAVEPOINT saveP1;
              ELSE
                -- Fecha cursor
                CLOSE cr_crapres;
                BEGIN
                  -- Atualiza dados para o restart do programa.
                  UPDATE crapres 
                     SET crapres.dsrestar = to_char(vr_nrseqint, '000000')
                   WHERE crapres.rowid = rw_crapres.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapres -> ' || SQLERRM;
                    --Sair
                    RAISE vr_exc_saida;
                END;
              END IF;
            END IF; --vr_inrestar <> 0 
          END LOOP;
  				
          -- Fecha arquivo
          utl_file.fclose(vr_input_file);
        END IF;
        
        -- Escreve no relatório o cadastro de rejeitados
        gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,'</critica></criticas><rejeitados>');
  			
        -- Para cada cadastro de rejeitados na integracao - D23.
        FOR rw_craprej IN cr_craprej (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_nrconven => rw_crapcnv.nrconven) LOOP
          -- Incrementa quantidade rejeitados
          vr_qtdifeln:= nvl(vr_qtdifeln,0) + 1;
          -- Incrementa valor do débito rejeitado com valor de lançamento
          vr_vldifeln:= nvl(vr_vldifeln,0) + rw_craprej.vllanmto;
  				
          -- Se o código da crítica for diferente da de cadastro de rejeitados
          IF vr_cdcritic <> rw_craprej.cdcritic THEN
            -- recebe código da crítica do cadastro de rejeitados
            vr_cdcritic:= rw_craprej.cdcritic;
            -- busca descrição da crítica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Escreve no relatório o cadastro de rejeitados
          gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
                         '<rejeitado>' || 
                           '<nrdocmto>' || rw_craprej.nrdocmto || '</nrdocmto>' ||
                           '<nrdconta>' || gene0002.fn_mask_conta(rw_craprej.nrdconta) || '</nrdconta>' ||
                           '<cdhistor>' || rw_craprej.cdhistor || '</cdhistor>' ||
                           '<vllanmto>' || rw_craprej.vllanmto || '</vllanmto>' ||
                           '<dtdaviso>' || rw_craprej.dtdaviso || '</dtdaviso>' ||
                           '<dscritic>' || vr_dscritic         || '</dscritic>' ||
                         '</rejeitado>');
  				
        END LOOP;			
  			
        -- Conta a quantidade de convenios integrados por empresa
        OPEN cr_qtdcrapepc (pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => rw_crapcnv.nrconven
                           ,pr_dtrefere => vr_dtfimmes);
        FETCH cr_qtdcrapepc INTO vr_qtempcnv;		
        --Fechar Cursor	
        CLOSE cr_qtdcrapepc;
  			
        -- Abre controle de convenios
        OPEN cr_crapctc (pr_cdcooper => pr_cdcooper
                        ,pr_nrconven => rw_crapcnv.nrconven
                        ,pr_dtrefere => vr_dtfimmes);
        FETCH cr_crapctc INTO rw_crapctc;
        -- Se não encontrar
        IF cr_crapctc%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapctc;
          -- Se a quantidade a integrar for 0
          IF vr_qtinfoln = 0 THEN
            -- Data de resumo recebe a data atual 
            vr_dtresumo:= rw_crapdat.dtmvtolt;
          ELSE
            -- Senão nulo
            vr_dtresumo:= NULL;
          END IF;		
          			
          BEGIN
            -- Insere controle de convenio
            INSERT INTO crapctc
               (nrconven
               ,dtrefere
               ,cdempres
               ,cdhistor
               ,vltarifa
               ,qtempres
               ,qtrejeit
               ,vlrejeit
               ,qtlanmto
               ,cdcooper
               ,vllanmto
               ,dtresumo)
            VALUES 
               (rw_crapcnv.nrconven           -- Nr. do convenio
               ,vr_dtfimmes                   -- Data de referencia
               ,0                             -- Cód. empresa
               ,0                             -- Cód. histórico
               ,0                             -- Valor tarifa
               ,vr_qtempcnv                   -- Quantidade de empresas a processar
               ,vr_qtdifeln                   -- Quantidade rejeitados
               ,vr_vldifeln                   -- Valor do débito rejeitado
               ,vr_qtinfoln                   -- Quantidade a integrar
               ,pr_cdcooper                   -- Cooperativa
               ,vr_vlinfoln                   -- Valor do débito a integrar
               ,vr_dtresumo);                 -- Data de emissao do resumo
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              -- Monta crítica
              vr_dscritic:= 'Erro ao inserir registros na crapctc -> ' || SQLERRM;
              -- Levanta exceção
              RAISE vr_exc_saida;
          END;							
        ELSIF nvl(rw_crapctc.nrconven,0) <> nvl(rw_crapcnv.nrconven,0) OR
              rw_crapctc.dtrefere <> vr_dtfimmes                       OR
              nvl(rw_crapctc.cdempres,0) <> 0                          OR
              nvl(rw_crapctc.cdhistor,0) <> 0                          OR
              nvl(rw_crapctc.vltarifa,0) <> 0                          OR
              nvl(rw_crapctc.qtempres,0) <> nvl(vr_qtempcnv,0)         OR
              nvl(rw_crapctc.qtrejeit,0) <> nvl(vr_qtdifeln,0)         OR
              nvl(rw_crapctc.vlrejeit,0) <> nvl(vr_vldifeln,0)         OR
              nvl(rw_crapctc.qtlanmto,0) <> nvl(vr_qtinfoln,0)         OR
              nvl(rw_crapctc.vllanmto,0) <> nvl(vr_vlinfoln,0)         THEN
          -- Fechar Cursor
          CLOSE cr_crapctc;    
          -- 301 - DADOS NAO CONFEREM!
          vr_cdcritic:= 301;
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
  					
          -- Gera log da crítica
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE') 
                                    ,pr_des_log      => to_char(SYSDATE,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' || vr_dscritic);
          -- Zera variável
          vr_cdcritic := 0;
          --Sair
          RAISE vr_exc_saida;
        END IF;

        -- Se não fechou o cursor ainda
        IF cr_crapctc%ISOPEN THEN
          CLOSE cr_crapctc;
        END IF;
        
        -- Decrementa quantidade integrados
        vr_qtcompln:= nvl(vr_qtinfoln,0) - nvl(vr_qtdifeln,0);
        -- Decrementa valor do débito integrado
        vr_vlcompln:= nvl(vr_vlinfoln,0) - nvl(vr_vldifeln,0);
  			
        -- Escreve totais no relatório
        gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,'</rejeitados></crrl152>',TRUE);
        
        -- Se quantidade rejeitados for 0
        IF nvl(vr_qtdifeln,0) = 0 THEN
          -- 190 - ARQUIVO INTEGRADO COM SUCESSO
          vr_cdcritic := 190;
          -- Marcar que nao deve imprimir cabecalho
          vr_flgmostra:= 'N';
        ELSE										 
          -- 191 - ARQUIVO INTEGRADO COM REJEITADOS
          vr_cdcritic := 191;
          -- Marcar que deve imprimir cabecalho
          vr_flgmostra:= 'S';                                                        
        END IF;
  			
        -- Busca crítica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        -- Gera log da crítica
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
  																												  
        -- Montar parametros com os totais
        vr_dsparam:= 'PR_DSDEBCRE##'||rw_crapcnv.dsdebcre||'@@'||
                     'PR_QTINFOLN##'||to_char(vr_qtinfoln,'fm999g990')||'@@'||
                     'PR_VLINFOLN##'||to_char(vr_vlinfoln,'fm999g999g999g990d00')||'@@'||
                     'PR_QTCOMPLN##'||to_char(vr_qtcompln,'fm999g990')||'@@'||
                     'PR_VLCOMPLN##'||to_char(vr_vlcompln,'fm999g999g999g990d00')||'@@'||
                     'PR_QTDIFELN##'||to_char(vr_qtdifeln,'fm999g990')||'@@'||
                     'PR_VLDIFELN##'||to_char(vr_vldifeln,'fm999g999g999g990d00')||'@@'||
                     'PR_MOSTRATOT##S@@'||'PR_MOSTRADAD##'||vr_flgmostra;                                                      
                                                           

        -- Gera relatório 152
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl152'                    --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl152.jasper'              --> Arquivo de layout do iReport
                                   ,pr_dsparams  => vr_dsparam                    --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                           --> 132 colunas
                                   ,pr_flg_gerar => 'N'                           --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => NULL                          --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 2                             --> Número de cópias
                                   ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                   ,pr_fldoscop  => 'S'                           --> Executar ux2dos
                                   ,pr_dsmailcop => rw_crapcnv.dsdemail           --> Email
                                   ,pr_dsassmail => 'INTEGRACAO DE CONVENIOS'     --> Assunto do e-mail		 
                                   ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;  
        --Fechar Clob e Liberar Memoria	
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);
        
        /*  Move arquivo integrado para o diretorio salvar  */
        vr_comando := 'mv ' || vr_nmarqdir || ' ' || vr_nom_direto_salvar;

        ------
        -- Adiciona o comando de Mov a tabela de memória
        vr_tab_movarq(vr_tab_movarq.count()+1) := vr_comando;
        ------
         
        
        /*  Exclusao dos rejeitados apos a impressao  */
        BEGIN
          -- Remove registros do cadastro de rejeitados na integracao - D23.
          DELETE FROM craprej 
          WHERE craprej.cdcooper = pr_cdcooper                      -- Cooperativa
          AND   craprej.dtmvtolt = rw_crapdat.dtmvtolt              -- Data atual
          AND   craprej.cdagenci = 195                              -- PA
          AND   craprej.cdbccxlt = 195                              -- Cód. Banco/Caixa
          AND   craprej.nrdolote = rw_crapcnv.nrconven              -- Nr. do convênio
          AND   craprej.tpintegr = 195;                             -- Tipo de integração
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            -- Monta crítica
            vr_dscritic:= 'Erro ao deletar registros da tabela craprej -> ' || SQLERRM;
            -- Levanta exceção
            RAISE vr_exc_saida;					
        END;										       										 
  			
        --Se tem controle de Restart
        IF NVL(vr_inrestar,0) <> 0 THEN
          BEGIN
            -- Atualiza controle de restart
            UPDATE crapres SET nrdconta = rw_crapcnv.nrconven     -- Nr. da conta
                              ,dsrestar = '000000'                -- Dados para o restart dos programas.
            WHERE cdcooper = pr_cdcooper   -- Cooperativa
            AND cdprogra   = vr_cdprogra;  -- Programa
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              -- Monta crítica
              vr_dscritic:= 'Erro ao atualizar registros da crapres -> ' || SQLERRM;
              -- Levanta exceção
              RAISE vr_exc_saida;
          END;
  			
          -- Zera variáveis de restart
          vr_nrctares:= 0;
          vr_dsrestar:= '000000';
          vr_inrestar:= 0;
        END IF;
        	
      EXCEPTION
        WHEN OTHERS THEN
          IF vr_dscritic IS NULL THEN
            -- Guarda a crítica
            vr_dscritic := SQLERRM;
          END IF;
            
          -- Em caso de erro deve retornar as operações efetuadas
          ROLLBACK TO processa_arquivo;
            
          -- Incluir o arquivo na lista de arquivos com erro
          vr_tab_arqerr(vr_tab_arqerr.COUNT()+1) := vr_nmarquiv||' - '||rw_crapcnv.dsconven;
          -- Incluir o erro na lista de erros
          vr_tab_deserr(vr_tab_arqerr.LAST) := vr_dscritic;
            
          -- Monta mensagem do log
          vr_dscritic:= 'Erro ao integrar arquivo ' || vr_nmarquiv || ' -> ' || vr_dscritic;
            
          -- Escreve no log a falha do registro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')                                    
									,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                           ' - ' || vr_cdprogra ||
                                                           ' --> ' || vr_dscritic);
            
          -- Limpar as variáveis de crítica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;
            
          -- Fecha arquivo
          utl_file.fclose(vr_input_file);
            
          -- Continuar com o processamento do próximo arquivo
          CONTINUE;
      END; -- Fim leitura arquivo
    END LOOP;
		
		-- Se solicitacao for processada
		IF vr_dsparame = '1' THEN
      -- Abre cursor de tabela genérica para indicar convenio como processado
			OPEN cr_craptab_proc (pr_cdcooper => pr_cdcooper);
			FETCH cr_craptab_proc INTO rw_craptab_proc;
			-- Se não encontrou registro
			IF cr_craptab_proc%NOTFOUND THEN
				-- Gera crítica no log
				btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
									      ,pr_ind_tipo_log => 2 -- Erro tratato
                                    	  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
										  ,pr_des_log      => to_char(SYSDATE,
                                                     'hh24:mi:ss') ||
                                                     ' - ' || vr_cdprogra ||
                                                     ' --> Falta tabela CRED-GENERI-11-PROCCONVEN-00');
			END IF;
			--Fechar Cursor
      CLOSE cr_craptab_proc;
      
			BEGIN
				-- Atualiza craptab CRED-GENERI-11-PROCCONVEN-00
				UPDATE craptab SET dstextab = SUBSTR(dstextab, 1, 11) || '1'
				WHERE  craptab.rowid = rw_craptab_proc.rowid;
			EXCEPTION
				WHEN OTHERS THEN
					vr_cdcritic:= 0;
					-- Monta crítica
					vr_dscritic:= 'Erro ao atualizar craptab: CRED-GENERI-11-PROCCONVEN-00 -> ' || SQLERRM;
					-- Levanta exceção
          RAISE vr_exc_saida;											
			END;
		END IF;
    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
  
		-- Chamar rotina para eliminação do restart para evitarmos
		-- reprocessamento das aplicações indevidamente
		btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
															 ,pr_cdprogra => vr_cdprogra   --> Código do programa
															 ,pr_flgresta => pr_flgresta   --> Indicador de restart
															 ,pr_des_erro => vr_dscritic); --> Saída de erro
		-- Testar saída de erro
		IF vr_dscritic IS NOT NULL THEN
			-- Sair do processo
			RAISE vr_exc_saida;
		END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
															
		-- Saída de termino da solicitação
		pr_infimsol:= 1;

		-- commit das alterações
		COMMIT;
    
    --  verifica se há arquivos para mover
    IF vr_tab_movarq.COUNT() > 0 THEN
      -- Percorre todos os registros de move
      FOR ind IN vr_tab_movarq.FIRST..vr_tab_movarq.LAST LOOP    
    
        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_tab_movarq(ind)
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
        END IF;  
           
      END LOOP;
    END IF;
    
    -- Verifica se há arquivos com erro para enviar o e-mail de alerta
    IF vr_tab_arqerr.COUNT() > 0 THEN
      
      -- Buscar o parametro com o endereço de email para envio
      vr_dsemlctr := gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_ERRO_ARQ_CRPS195');
      
      -- Se há destinatário para o email
      IF TRIM(vr_dsemlctr) IS NOT NULL THEN
         
        -- Monta o conteúdo da mensagem de e-mails
        vr_conteudo := 'Atencao!<br><br>'||
                       'Os arquivos abaixo nao foram processados. <br><br>'||
                       'Favor verificar.<br><br>';
        
        FOR ind IN vr_tab_arqerr.first..vr_tab_arqerr.last LOOP
          vr_conteudo := vr_conteudo||vr_tab_arqerr(ind)||' - ERRO: '||vr_tab_deserr(ind)||'<br><br>';
        END LOOP;
      
        -- Enviar Email de para o departamento de contabilidade comunicando sobre a gerac?o do arquivo
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_dsemlctr
                                  ,pr_des_assunto     => 'CRPS195 - Arquivos de convenios nao importados'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => null--> n?o envia anexo, anexo esta disponivel no dir conf. gerac?o do arq.
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        --Se ocorreu algum erro no envio do e-mail
        IF vr_dscritic IS NOT NULL  THEN
          -- Descric?o do erro
          vr_dscritic := 'Problemas no envio do e-mail: '||vr_dscritic;

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE') 
                                    ,pr_des_log      => to_char(SYSDATE,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' || vr_dscritic);
        END IF;
      END IF;
    END IF;
    
    --
    COMMIT;
    --
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar ROLLBACK; -- commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps195;
/

