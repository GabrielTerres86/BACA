CREATE OR REPLACE PROCEDURE CECRED.pc_crps585 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
																							,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
																							,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
																							,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
																							,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
																							,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps585 (Fontes/crps585.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Vitor
       Data    : Dezembro/2010                      Ultima atualizacao: 12/05/2017

       Dados referentes ao programa:

       Frequencia: Mensal (Batch).
       Objetivo  : Atende a solicitacao 004.
                   Emitir relatório mensal de acompanhamento de procuracoes
                   para cada PAC.
                   Relatorio 585.

       Alteracoes: 07/02/2011 - Alterado a chamada do fontes/imprim.p para
                                disponibilizar todos os relatórios (Vitor).
               
                   13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                                a escrita será PA (André Euzébio - Supero).              
                            
                   13/11/2013 - Alterado totalizador de PAs de 99 para 999. (Reinert)

                   16/01/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)           
									 
				   24/11/2015 - Adicionado tratamento para validar vencimento a partir
						        da quantidade de meses da tab045. (Reinert)
                                
                   23/06/2016 - Correcao para o uso da function fn_busca_dstextab 
                                da TABE0001. (Carlos Rafael Tanholi).

				   12/05/2017 - Adicionado o relatorio final _999 para agrupar 
                                todas as PA's em um só arquivo. (Andrey - Mouts)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS585';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
			vr_qtmesavs_pf NUMBER;
			vr_qtmesavs_pj NUMBER;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      /*Cadastro de avalistas terceiros, contatos da pessoa fisica   
        e referencias comerciais e bancarias da pessoa juridica*/
      CURSOR cr_crapavt IS
        SELECT nrdconta,
               dtvalida,
               nrdctato,
               nmdavali,
               dsproftl
        FROM   crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper 
        AND    crapavt.tpctrato = 6
        AND    EXISTS (SELECT 1   -- exist colocado para performance da procedure
                      FROM   crapass 
                      WHERE  crapass.cdcooper = pr_cdcooper 
                      AND    crapass.nrdconta = crapavt.nrdconta  
                      AND    crapass.dtdemiss IS NULL)
        ORDER  BY crapavt.cdagenci, crapavt.dtvalida, crapavt.nrdconta;--tipo de contrato Jur.
        
      CURSOR cr_crapass(p_nrdconta IN NUMBER) IS -- busca dados do associado/conta
        SELECT cdagenci,
               inpessoa,
               nrdconta,
               nmprimtl               
        FROM   crapass 
        WHERE  crapass.cdcooper = pr_cdcooper 
        AND    crapass.nrdconta = p_nrdconta  
        AND    crapass.dtdemiss IS NULL;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crapage(p_cdagenci IN NUMBER) IS -- busca dados do PA
        SELECT nmresage
        FROM   crapage 
        WHERE  crapage.cdcooper = pr_cdcooper
        AND    crapage.cdagenci = p_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;     
      
      CURSOR cr_crabass(p_nrdctato IN NUMBER) IS --nome avalista
        SELECT nmprimtl
        FROM   crapass
        WHERE  cdcooper = pr_cdcooper
        AND    nrdconta = p_nrdctato;
      
			
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_reg_relato IS
        RECORD ( nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,nmdavali crapass.nmprimtl%TYPE
                ,dtvalida crapavt.dtvalida%TYPE
                ,dsproftl crapavt.dsproftl%TYPE
                ,inpessoa crapass.inpessoa%TYPE
                ,cdtpdata NUMBER
                ,npessoa  VARCHAR2(15)
                ,procurac VARCHAR2(50));
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(97); --> 05 PA + 1 Cdtpdata + 1 Tp Pessoa + 20 Dt Vigencia + 10 Conta + 60 nmdavali 
      vr_tab_relato typ_tab_relato;
      vr_des_chave  VARCHAR2(97);     
      

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtmvtolt DATE;
      vr_avencer  DATE;
      vr_avencer2 DATE;
      vr_nmdavali crapass.nmprimtl%TYPE; 
      vr_inpessoa VARCHAR2(1);
      vr_npessoa  VARCHAR2(15);
      vr_cdtpdata NUMBER(1);
      vr_procurac VARCHAR2(50);
      vr_nmarqim  VARCHAR2(25);
      vr_nmresage crapage.nmresage%TYPE;
      
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;   -- Clob para conter o XML de dados
	  vr_des_xml_999 CLOB;   -- Clob para conter o XML de dados do relatorio 999
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo
      
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      
      
      --------------------------- SUBROTINAS INTERNAS --------------------------
      
       PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                                ,pr_desdados IN VARCHAR2
                                ,pr_flggeral IN NUMBER) IS
      BEGIN
        IF pr_flggeral = 1 THEN
          dbms_lob.writeappend(vr_des_xml_999, length(pr_desdados), pr_desdados);
        ELSE
          dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados); 
        END IF;
      END;
      --------------- VALIDACOES INICIAIS -----------------      
    BEGIN

      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
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
      OPEN btch0001 .cr_crapdat(pr_cdcooper => pr_cdcooper);
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => 0
                     ,pr_cdacesso => 'LIMINTERNT'
										 ,pr_tpregist => 1);
 
      vr_qtmesavs_pf := gene0002.fn_busca_entrada(pr_postext => 29, 
                                                  pr_dstext => vr_dstextab, 
                                                  pr_delimitador => ';');
      
			vr_dstextab := NULL;
			
      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => 0
                     ,pr_cdacesso => 'LIMINTERNT'
										 ,pr_tpregist => 2);
 
      vr_qtmesavs_pj := gene0002.fn_busca_entrada(pr_postext => 29, 
                                                  pr_dstext => vr_dstextab, 
                                                  pr_delimitador => ';');
      
						
      vr_dtmvtolt := rw_crapdat.dtmvtolt; 
      vr_avencer  := rw_crapdat.dtpridms;
     			
      FOR crapavt IN cr_crapavt--busca avalistas terceiros
      LOOP
        EXIT WHEN cr_crapavt%NOTFOUND;
        OPEN cr_crapass(crapavt.nrdconta);--busca informacoes do associado
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN--verifica se o associado existe
          CLOSE cr_crapass;  
          --grava informacao no log e continua para o proximo registro        
          vr_dscritic := 'Conta: '||crapavt.nrdconta||' nao encontrada.' ;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
          CONTINUE;
        ELSE
          CLOSE cr_crapass;
        END IF;
        OPEN cr_crapage(rw_crapass.cdagenci);--busca informacoes do PA
        FETCH cr_crapage INTO rw_crapage;
        IF cr_crapage%NOTFOUND THEN--verifica se o PA eh valido
          --grava informacao no log e continua para o proximo registro
          CLOSE cr_crapage;
          vr_dscritic := 'PA:  '||rw_crapass.cdagenci||' nao encontrado.' ;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
          CONTINUE;
        ELSE 
          CLOSE cr_crapage;
        END IF;
				
				IF rw_crapass.inpessoa = 1 THEN
	         vr_avencer2 := trunc(Add_Months(vr_avencer,vr_qtmesavs_pf),'mm');
				ELSE
				   vr_avencer2 := trunc(Add_Months(vr_avencer,vr_qtmesavs_pj),'mm');										 
			  END IF;
				
        -- valida se a data vigencia é menor ou igual ao 1 dia do mes corrente
        -- ou data vigencia  maior igual 1 dia mes corrente e menor que o 1 dia do mes seguinte.
        IF (crapavt.dtvalida <= vr_dtmvtolt) OR 
           (crapavt.dtvalida >= vr_avencer   AND
           crapavt.dtvalida <  vr_avencer2) THEN
           IF crapavt.nrdctato <> 0 THEN -- busca nome associado se contrato <> 0          
             OPEN cr_crabass(crapavt.nrdctato);
             FETCH cr_crabass INTO vr_nmdavali;
             CLOSE cr_crabass;
           ELSE -- utiliza o nomo do avalista
             vr_nmdavali := crapavt.nmdavali; 
           END IF;
           IF rw_crapass.inpessoa = 1 THEN -- verifica tipo pessoa
              vr_npessoa := 'Pessoa Fisica';
           ELSE
              vr_npessoa := 'Pessoa Juridica';
           END IF;           
          
           IF (crapavt.dtvalida <= vr_dtmvtolt) THEN -- verifica se contrato esta vencido
             vr_cdtpdata := 1; /* Procuracoes vencidas */ 
             vr_procurac := '***Procuracoes Vencidas***';
           ELSE
             vr_cdtpdata := 2; /* Procuracoes a vencer */ 
             vr_procurac := '***Procuracoes a Vencer***';
           END IF; 
           
           --inserir na tabela base ao relatorio
           vr_des_chave := lpad(rw_crapass.cdagenci,5,'0')||lpad(vr_cdtpdata,1,'0')||lpad(rw_crapass.inpessoa,1,'0')||to_char(crapavt.dtvalida, 'yyyy/mm/dd')||lpad(crapavt.nrdconta,10)||vr_nmdavali;
           vr_tab_relato(vr_des_chave).cdagenci := rw_crapass.cdagenci;-- PA
           vr_tab_relato(vr_des_chave).nrdconta := rw_crapass.nrdconta;-- Conta
           vr_tab_relato(vr_des_chave).nmprimtl := rw_crapass.nmprimtl;-- Nome Associado
           vr_tab_relato(vr_des_chave).dsproftl := crapavt.dsproftl;-- Nome Cargo do contato
           vr_tab_relato(vr_des_chave).dtvalida := crapavt.dtvalida;--to_char(crapavt.dtvalida, 'mm/dd/yyyy');-- Dt vigencia           
           vr_tab_relato(vr_des_chave).nmdavali := vr_nmdavali;-- Nome avalista
           vr_tab_relato(vr_des_chave).inpessoa := rw_crapass.inpessoa;-- Tp pessoa
           vr_tab_relato(vr_des_chave).cdtpdata := vr_cdtpdata;-- Tp procuracao
           vr_tab_relato(vr_des_chave).npessoa  := vr_npessoa;-- nm pessoa
           vr_tab_relato(vr_des_chave).procurac := vr_procurac;-- nm procuracao
                      
        END IF;          
      END LOOP;
      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      vr_des_chave := vr_tab_relato.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

	  dbms_lob.createtemporary(vr_des_xml_999, TRUE, dbms_lob.CALL); -- relatorio 999
      dbms_lob.open(vr_des_xml_999, dbms_lob.lob_readwrite); -- relatorio 999

      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>', 0);
      pc_escreve_clob(vr_des_xml_999,'<?xml version="1.0" encoding="utf-8"?><raiz>', 1); -- relatorio 999

      WHILE vr_des_chave IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
        --verifica se é o primeiro registro ou alterou o nro do PA
        IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdagenci THEN
          OPEN cr_crapage(vr_tab_relato(vr_des_chave).cdagenci);--busca nome PA
          FETCH cr_crapage INTO vr_nmresage; 
          CLOSE cr_crapage;
          IF vr_nmresage IS NULL THEN
            vr_nmresage := '- PA NAO CADASTRADO.';
          END IF;
          pc_escreve_clob(vr_clobxml,'<pac cdagenci="'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3,' ')||'" nmresage="'||vr_nmresage||'">', 0);
          pc_escreve_clob(vr_des_xml_999,'<pac cdagenci="'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3,' ')||'" nmresage="'||vr_nmresage||'">', 1); -- relatorio 999
          
		  vr_nmarqim := '/crrl585_'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3, '0')||'.lst';

          pc_escreve_clob(vr_clobxml,' <cdtpdata cod="'||vr_tab_relato(vr_des_chave).cdtpdata||'" procurac="'||vr_tab_relato(vr_des_chave).procurac||'">', 0); 
          pc_escreve_clob(vr_des_xml_999,' <cdtpdata cod="'||vr_tab_relato(vr_des_chave).cdtpdata||'" procurac="'||vr_tab_relato(vr_des_chave).procurac||'">', 1); -- relatorio 999
          
		  pc_escreve_clob(vr_clobxml,'  <pessoa cod="'||vr_tab_relato(vr_des_chave).inpessoa||'" npessoa="'||vr_tab_relato(vr_des_chave).npessoa||'">', 0);
          pc_escreve_clob(vr_des_xml_999,'  <pessoa cod="'||vr_tab_relato(vr_des_chave).inpessoa||'" npessoa="'||vr_tab_relato(vr_des_chave).npessoa||'">', 1); -- relatorio 999
        ELSE 
           IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdtpdata <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdtpdata THEN
            pc_escreve_clob(vr_clobxml,' <cdtpdata cod="'||vr_tab_relato(vr_des_chave).cdtpdata||'" procurac="'||vr_tab_relato(vr_des_chave).procurac||'">', 0);
            pc_escreve_clob(vr_des_xml_999,' <cdtpdata cod="'||vr_tab_relato(vr_des_chave).cdtpdata||'" procurac="'||vr_tab_relato(vr_des_chave).procurac||'">', 1); -- relatorio 999
          END IF;
          IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).inpessoa <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).inpessoa 
          OR vr_tab_relato(vr_des_chave).cdtpdata <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdtpdata THEN
            pc_escreve_clob(vr_clobxml,'  <pessoa cod="'||vr_tab_relato(vr_des_chave).inpessoa||'" npessoa="'||vr_tab_relato(vr_des_chave).npessoa||'">', 0);
			pc_escreve_clob(vr_des_xml_999,'  <pessoa cod="'||vr_tab_relato(vr_des_chave).inpessoa||'" npessoa="'||vr_tab_relato(vr_des_chave).npessoa||'">', 1); -- relatorio 999
          END IF;         
        END IF;        
        --monta xml
        pc_escreve_clob(vr_clobxml,'   <conta>'   
                                 ||'    <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</nrdconta>'
                                 ||'    <titular>'||vr_tab_relato(vr_des_chave).nmprimtl||'</titular>'
                                 ||'    <avalista>'||vr_tab_relato(vr_des_chave).nmdavali||'</avalista>'
                                 ||'    <vencimento>'||to_char(vr_tab_relato(vr_des_chave).dtvalida,'dd/mm/yyyy')||'</vencimento>'
                                 ||'    <cargo>'||vr_tab_relato(vr_des_chave).dsproftl||'</cargo>'
                                 ||'   </conta>', 0);
								                 
	    pc_escreve_clob(vr_des_xml_999,'   <conta>'   
                                 ||'    <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</nrdconta>'
                                 ||'    <titular>'||vr_tab_relato(vr_des_chave).nmprimtl||'</titular>'
                                 ||'    <avalista>'||vr_tab_relato(vr_des_chave).nmdavali||'</avalista>'
                                 ||'    <vencimento>'||to_char(vr_tab_relato(vr_des_chave).dtvalida,'dd/mm/yyyy')||'</vencimento>'
                                 ||'    <cargo>'||vr_tab_relato(vr_des_chave).dsproftl||'</cargo>'
                                 ||'   </conta>', 1); -- relatorio 999     
        
         -- No ultimo ou se for mudar a pessoa, fecha tag
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).inpessoa <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).inpessoa  
        OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci  
        OR vr_tab_relato(vr_des_chave).cdtpdata <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdtpdata THEN
          pc_escreve_clob(vr_clobxml,'</pessoa>', 0);
		  pc_escreve_clob(vr_des_xml_999,'</pessoa>', 1); -- relatorio 999
        END IF;
        -- No ultimo ou se for mudar procuracao, fecha tag
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).cdtpdata <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdtpdata 
        OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
          pc_escreve_clob(vr_clobxml,'</cdtpdata>', 0);
		  pc_escreve_clob(vr_des_xml_999,'</cdtpdata>', 1); -- relatorio 999
        END IF;
        --se for ultimo ou mudar PA, fecha tag e gera solicitacao relatorio
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA 
          pc_escreve_clob(vr_clobxml,'</pac>', 0);
		  pc_escreve_clob(vr_des_xml_999,'</pac>', 1); -- relatorio 999 
          -- Encerrar tag raiz
          pc_escreve_clob(vr_clobxml,'</raiz>', 0);  
          
          --busca diretorio padrao da cooperativa
          vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'rl');      
          -- Solicitando o relatório para o PA atual
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/raiz/pac/cdtpdata/pessoa/conta'    --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl585.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 3                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => vr_dscritic);                       --> Saída com erro
                                        
           IF vr_dscritic IS NOT NULL THEN
             -- Gerar exceção
             RAISE vr_exc_saida;
           END IF;
                  
          -- Fechando CLOB do PA atual
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          -- Abrindo novamente para iniciar o CLOB do próximo PA     
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>', 0);
        END IF;          
        -- Buscar o proximo
        vr_des_chave := vr_tab_relato.NEXT(vr_des_chave);  
      END LOOP;

      pc_escreve_clob(vr_des_xml_999,'</raiz>', 1); -- relatorio 999

	  -- Solicitando o relatório 999
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml_999                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/pac/cdtpdata/pessoa/conta'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl585.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl585_999.lst'    --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
                                        
       IF vr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_saida;
       END IF;
      
      
      -- Fechando CLOB do relatorio 999
      dbms_lob.close(vr_des_xml_999);
      dbms_lob.freetemporary(vr_des_xml_999);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT; 

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
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
        -- Devolvemos código e critica encontradas das variaveis locais
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
    END;

  END pc_crps585;
/
