CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps219 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps219 (Fontes/crps219.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Dezembro/97.                    Ultima atualizacao: 05/06/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Emitir os avisos de debito em conta corrente (173) a laser.
                   Atende solicitacao 61.

       Alteracoes: 29/01/98 - Acerto para nao emitir avisos com lancamentos a
                              credito (Deborah).

                   09/03/98 - Alterado para mostrar a prestacao a pagar do empres-
                              timo (Deborah).

                   13/03/98 - Acerto para mostrar a quantidade de prestacoes atua-
                              lizada (Deborah).

                   29/04/98 - Tratamento para milenio e troca para V8 (Margarete).
                   
                   31/07/98 - Acerto na leitura dos lancamentos de emprestimo
                              (Deborah).

                   08/09/98 - Acerto na numeracao do lote (Deborah).

                   09/09/98 - Nomes diferentes para o aviso de debito em conta e 
                              em folha.
                              Se nao houve um dos tipos de aviso, remover o arquivo
                              para nao gerar pedidos vazios para a laser (Deborah).
                              
                   08/10/98 - Colocado descending na leitura do aviso (Deborah). 

                   09/10/98 - Colocado descending na leitura do aviso por agencia
                              (Deborah).

                   21/12/98 - Desmembrado em tres arquivos de impressao (Deborah).

                   13/04/1999 - Gerar aviso somente se ass.tpavsdeb for 1
                                (Deborah).
                                
                   29/10/1999 - Identificar as conta com talao no aviso da
                                Seara (Deborah).

                   25/08/2000 - Nao imprimir aviso de cotas da Kyly (Deborah).
                   
                   30/08/2000 - Acerto na alteracao anterior (Deborah).  

                   28/09/2000 - Alterar forma geracao da saida (Margarete/Planner)
                   
                   22/11/2000 - Alterar leitura do crapavs (Margarete/Planner)

                   19/12/2000 - Nao gerar automaticamente o pedido de impressao.
                                (Eduardo).
                                
                   20/06/2002 - Arrumar erro quando chama o crps295.p (Ze Eduardo)
                   
                   05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).
                   
                   11/09/2002 - Quando ultimo dia do mes no ant e mes atual no
                                glb nao ler craplem (Margarete).

                   16/02/2004 - Colocado mensagem interna provisoria (Deborah).
                   
                   31/03/2004 - Nao gerar aviso tipo 1 para Cooper 6 (Margarete).
                   
                   27/09/2004 - Nao gerar aviso tipo 1 para VIACREDI, pacs 14 e 21
                                (Edson).

                   25/04/2005 - Incluido, no fim da 3a linha, o nro do cadastro do
                                cooperado na empresa (Evandro).

                   27/04/2005 - Alterado para exibir a mensagem interna do crrl173
                                conforme a data atual (Evandro).

                   07/06/2005 - Alterado para emitir tipo de aviso 1, somente se o
                                associado estiver cadastrado(crapcex) para
                                recebimento de aviso (Diego).

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                                crapcop.cdcooper = glb_cdcooper (Diego).
                                
                   21/11/2005 - Acerto no programa (Ze).
                   
                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                   
                   19/09/2007 - Alterado de FormXpress para FormPrint (Diego).
                   
                   31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao(Guilherme).
                   
                   17/12/2007 - Incluida atribuicao para variavel aux_cdacesso
                                referente mensagem no Aviso (Diego).
                   
                   08/04/2008 - Alterado formato para vizualizaçao do campo 
                                "crapepr.qtpreemp" de "99" para "zz9" - 
                                Kbase IT Solutions - Paulo Ricardo Maciel.

                   16/06/2008 - Envio de informativo pela Postmix (Elton). 
                                   
                   23/07/2008 - Incluida includes/envia_dados_postmix.i (Gabriel).
                    
                   14/08/2008 - Alterado para solucionar probelma de upload 
                                (Gabriel).
                                
                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                   
                   06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                                includes/var_informativos.i (Diego).
                    
                   19/10/2009 - Alteracao Codigo Historico (Kbase). 
                   
                   01/02/2010 - Enviar arquivo para impressao na Engecopy das
                                cooperativas 1,2 e 4 (Diego).
                                
                   08/03/2010 - Alteracao Historico (Gati).
                   
                   22/04/2010 - Gravar o nome da faixa do CEP na cratext e
                                o PAC.
                                Unificacao das includes que geram os dados.
                                (Gabriel).
                                
                   01/06/2010 - Alteraçao do campo "pkzip25" para "zipcecred.pl" 
                                (Vitor).
                                
                   19/08/2011 - Incluido nome da centralizadora e faixa do CEP
                                nas cartas separadoras (Elton).
                                
                   20/09/2011 - Tratamento de verificacao do registro de endereco
                                (crapenc) na procedure p_criaext para nao ocasionar
                                erro quando nao encontrar registro (GATI - Eder)
                                
                   21/09/2011 - Atribuir cratext.indespac = 2(Balcao) quando 
                                crapdes.indespac <> 1 (Correio) (Diego).  
                                
                   10/10/2012 - Tratamento para novo campo da 'craphis' de descriçao
                                do histórico em extratos (Lucas) [Projeto Tarifas].     
                                
                   03/05/2013 - Alterado para nao forçar usar o indice na tabela 
                                CRAPLEM deixar o banco escolher o novo indice criado 
                                (Oscar).
                   
                   10/06/2013 - Alteraçao funçao enviar_email_completo para
                                nova versao (Jean Michel).

                   13/03/2014 - Conversão Progress para PLSQL (Edison-AMcom)
                   
                   20/06/2014 - #123392 Retirado o envio do relatorio para impressao 
                                (Carlos)
                   
				   05/06/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                          crapass, crapttl, crapjur (Adriano - P339).
                   
				           06/03/2018 - Substituída verificacao do tipo de conta "NOT IN (5,6,7,17,18)" para a 
                                modalidade do tipo de conta diferente de "2" e "3". PRJ366 (Lombardi).
                   
    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS219';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

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

      --cadastro de historicos da cooperativa
      CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
               ,craphis.dsextrat
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper;
               
      --cadastro de empresas
      CURSOR cr_crapemp(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapemp.cdempres
              ,crapemp.nmresemp
        FROM   crapemp
        WHERE  crapemp.cdcooper = pr_cdcooper;

      -- Cadastro dos avisos de debito em conta corrente
      CURSOR cr_crapavs( pr_cdcooper IN crapcop.cdcooper%TYPE --codigo da cooperativa
                        ,pr_dtmvtolt IN DATE                  --data do movimento
                        ,pr_tpdaviso IN INTEGER               --tipo de aviso de debito
                        ,pr_cdhistor IN INTEGER) IS           --codigo do historico
        SELECT crapavs.dtmvtolt
              ,crapavs.cdempres 
              ,crapavs.cdagenci   
              ,crapavs.cdsecext
              ,crapavs.nrdconta
              ,crapavs.dtdebito
              ,crapavs.cdhistor                  
              ,crapavs.nrdocmto
              ,crapavs.tpdaviso
              ,crapavs.vllanmto              
              ,ROW_NUMBER () OVER (PARTITION BY crapavs.cdagenci
                                               ,crapavs.nrdconta 
                                       ORDER BY crapavs.cdagenci
                                               ,crapavs.nrdconta
                                               ,crapavs.dtdebito
                                               ,crapavs.cdhistor
                                               ,crapavs.nrdocmto ) nrseq
              ,COUNT(1)      OVER (PARTITION BY crapavs.cdagenci
                                               ,crapavs.nrdconta) qtreg
        FROM   crapavs
              ,craphis 
        WHERE  crapavs.cdcooper = pr_cdcooper       
        AND    crapavs.dtmvtolt = pr_dtmvtolt       
        AND    crapavs.tpdaviso = pr_tpdaviso --tipo de aviso de debito      
        AND    (crapavs.cdhistor <> pr_cdhistor OR pr_cdhistor IS NULL)
        AND    craphis.cdcooper = crapavs.cdcooper
        AND    craphis.cdhistor = crapavs.cdhistor   
        AND    craphis.indebcre = 'D';

      rw_crapavs cr_crapavs%ROWTYPE;
                
      --cadastro de controle de emissao de extrato     
      CURSOR cr_crapcex (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT DISTINCT crapcex.nrdconta
        FROM  crapcex
        WHERE crapcex.cdcooper = pr_cdcooper
        AND   crapcex.tpextrat = 5;   

      --cadastro de associados
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.inpessoa
              ,crapass.tpavsdeb
              ,crapass.cdagenci
              ,crapass.cdsecext
              ,crapass.cdtipcta
              ,crapass.nmprimtl
        FROM  crapass
        WHERE crapass.cdcooper = pr_cdcooper;

      -- cadastro de titulares da conta
      CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE) IS 
        SELECT crapttl.cdempres
              ,crapttl.nrdconta
        FROM   crapttl 
        WHERE  crapttl.cdcooper = pr_cdcooper      
        AND    crapttl.idseqttl = 1;

      -- cadastro de pessoas juridicas
      CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE) IS 
        SELECT crapjur.cdempres
              ,crapjur.nrdconta
        FROM   crapjur 
        WHERE  crapjur.cdcooper = pr_cdcooper;      
      
      --cadastro de emprestimos       
      CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapepr.nrdconta
              ,crapepr.nrctremp
              ,crapepr.qtprecal
              ,crapepr.qtpreemp
        FROM   crapepr 
        WHERE  crapepr.cdcooper = pr_cdcooper;      
      
      --cadastro de lencamentos de emprestimo 
      CURSOR cr_craplem ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN craplem.nrdconta%TYPE
                         ,pr_nrctremp IN craplem.nrctremp%TYPE
                         ,pr_dtinimes IN DATE) IS
        SELECT craplem.nrdolote
              ,craplem.dtmvtolt
              ,craplem.vlpreemp
              ,craplem.cdhistor
              ,craplem.vllanmto
        FROM   craplem 
        WHERE  craplem.cdcooper = pr_cdcooper     
        AND    craplem.nrdconta = pr_nrdconta
        AND    craplem.nrctremp = pr_nrctremp
        AND    craplem.dtmvtolt > pr_dtinimes;
        
      --cadastor do destino de extratos 
      CURSOR cr_crapdes(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapdes.indespac
              ,crapdes.nmsecext
              ,crapdes.cdagenci
              ,crapdes.cdsecext
        FROM   crapdes
        WHERE  crapdes.cdcooper = pr_cdcooper;
      
      --cadastro de agencias
      CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapage.cdagenci
              ,crapage.nmresage       
        FROM   crapage
        WHERE  crapage.cdcooper = pr_cdcooper;

      --cadastro de enderecos
      CURSOR cr_crapenc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT  crapenc.nrdconta
               ,crapenc.nrcepend
               ,crapenc.nmcidade
               ,crapenc.dsendere
               ,crapenc.nrendere
               ,crapenc.nmbairro
               ,crapenc.cdufende
               ,crapenc.complend
        FROM   crapenc
        WHERE  crapenc.cdcooper = pr_cdcooper
        AND    crapenc.idseqttl = 1
        AND    crapenc.cdseqinc = 1;       
        
      -- Cursor para busca dos tipos de conta
      CURSOR cr_tipcta IS
        SELECT inpessoa
              ,cdtipo_conta cdtipcta
              ,cdmodalidade_tipo cdmodali
          FROM tbcc_tipo_conta;
          
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_dsintern IS VARRAY(23) OF VARCHAR2(80);

      --estrutura para armazenar as informacoes do relatorio
      TYPE typ_reg_wcratext IS
        RECORD( tpdaviso  INTEGER  
                ,nrdconta INTEGER --FORMAT "zzzz,zz9,9"
                ,cdagenci INTEGER 
                ,nmprimtl crapass.nmprimtl%TYPE
                ,indespac INTEGER    
                ,nrseqint INTEGER
                ,nmempres VARCHAR2(100)
                ,nmsecext VARCHAR2(100)
                ,nmagenci VARCHAR2(100) 
                ,dsender1 VARCHAR2(200)--crapenc.dsendere %TYPE
                ,dsender2 varchar2(200)--crapenc.dsendere%TYPE              
                ,nrcepend crapenc.nrcepend%TYPE
                ,nomedcdd VARCHAR2(35)
                ,nrcepcdd VARCHAR2(23)
                ,dscentra VARCHAR2(100)
                ,complend VARCHAR2(40) --FORMAT "x(40)"
                ,dtemissa DATE
                ,nrdordem INTEGER
                ,tpdocmto INTEGER
                ,dsintern typ_dsintern := typ_dsintern('','','','','','','','','','','','','','','','','','','','','','','')
        );
      --estrutura para armazenar as informacoes do relatorio
      TYPE typ_tab_wcratext IS TABLE OF typ_reg_wcratext INDEX BY VARCHAR2(500);
      
      --tabela temporaria para armazenar as informacoes do relatorio
      vr_tab_wcratext typ_tab_wcratext;
      -- 
      vr_tab_cratext  form0001.typ_tab_cratext;
      
      --estrutura para armazenar o cadastro de historicos
      TYPE typ_reg_craphis IS         
        RECORD( cdhistor craphis.cdhistor%TYPE
               ,dsextrat craphis.dsextrat%TYPE
        );
        
      --estrutura para armazenar o cadastro de historicos
      TYPE typ_tab_craphis IS TABLE OF typ_reg_craphis INDEX BY PLS_INTEGER;         
      
      --tabela temporaria para armazenar historicos
      vr_tab_craphis typ_tab_craphis;
      
      --tipo para armazenar a estrutura do cadastro de empresas
      TYPE typ_reg_crapemp IS 
        RECORD( cdempres crapemp.cdempres%TYPE
               ,nmresemp crapemp.nmresemp%TYPE
        );
      --estrutura do cadastro de empresas
      TYPE typ_tab_crapemp IS TABLE OF typ_reg_crapemp INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar os codigos de empresa
      vr_tab_crapemp typ_tab_crapemp; 

      --estrutura para armazenar o cadastro de historicos
      TYPE typ_tab_crapcex IS TABLE OF INTEGER INDEX BY PLS_INTEGER;         
      
      --tabela temporaria para armazenar historicos
      vr_tab_crapcex typ_tab_crapcex;

      --tipo para armazenar a estrutura do cadastro de associados
      TYPE typ_reg_crapass IS 
        RECORD( nrdconta crapass.nrdconta%TYPE
               ,inpessoa crapass.inpessoa%TYPE
               ,tpavsdeb crapass.tpavsdeb%TYPE
               ,cdagenci crapass.cdagenci%TYPE
               ,cdsecext crapass.cdsecext%TYPE
               ,cdtipcta crapass.cdtipcta%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE
        );
      --estrutura do cadastro de associados
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes de associados
      vr_tab_crapass typ_tab_crapass; 

      --tipo para armazenar a estrutura do cadastro de titulares
      TYPE typ_reg_crapttl IS 
        RECORD( cdempres crapttl.cdempres%TYPE
        );
      --estrutura do cadastro de titulares
      TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes dos titulares
      vr_tab_crapttl typ_tab_crapttl; 

      --tipo para armazenar a estrutura do cadastro de pessoas juridicas
      TYPE typ_reg_crapjur IS 
        RECORD( cdempres crapjur.cdempres%TYPE
        );
      --estrutura do cadastro de pessoas juridicas
      TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes de pessoas juridicas
      vr_tab_crapjur typ_tab_crapjur; 

      --tipo para armazenar a estrutura do cadastro de emprestimos
      TYPE typ_reg_crapepr IS 
        RECORD( nrdconta crapepr.nrdconta%TYPE
               ,qtprecal crapepr.qtprecal%TYPE
               ,qtpreemp crapepr.qtpreemp%TYPE
               ,nrctremp crapepr.nrctremp%TYPE
        );
      --estrutura do cadastro de pessoas juridicas
      TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY varchar2(100);
      --tabela temporaria para armazenar as informacoes de pessoas juridicas
      vr_tab_crapepr typ_tab_crapepr; 

      --tipo para armazenar a estrutura do cadastro de destino de extratos
      TYPE typ_reg_crapdes IS 
        RECORD( indespac crapdes.indespac%TYPE
               ,nmsecext crapdes.nmsecext%TYPE
               ,cdagenci crapdes.cdagenci%TYPE
               ,cdsecext crapdes.cdsecext%TYPE
        );
      --estrutura do cadastro de pessoas juridicas
      TYPE typ_tab_crapdes IS TABLE OF typ_reg_crapdes INDEX BY varchar2(100);
      --tabela temporaria para armazenar as informacoes de pessoas juridicas
      vr_tab_crapdes typ_tab_crapdes; 

      --tipo para armazenar a estrutura do cadastro de agencias
      TYPE typ_reg_crapage IS 
        RECORD( nmresage crapage.nmresage%TYPE
        );
      --estrutura do cadastro de agencias
      TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;
      --tabela temporaria para armazenar as informacoes de agencias
      vr_tab_crapage typ_tab_crapage; 

      --estrutura do cadastro de tipos de endereco
      TYPE typ_reg_crapenc IS 
        RECORD( nrcepend crapenc.nrcepend%TYPE 
               ,nmcidade crapenc.nmcidade%TYPE
               ,dsendere crapenc.dsendere%TYPE
               ,nrendere crapenc.nrendere%TYPE
               ,nmbairro crapenc.nmbairro%TYPE
               ,cdufende crapenc.cdufende%TYPE
               ,complend crapenc.complend%TYPE
        );       
      --estrutura do cadastro de enderecos
      TYPE typ_tab_crapenc IS TABLE OF typ_reg_crapenc INDEX BY VARCHAR2(100);          
      --tabela temporaria para armazenar as informacoes de enderecos
      vr_tab_crapenc typ_tab_crapenc; 

      -- Definicao do tipo de tabela para os tipos de conta
      TYPE typ_reg_tipcta   IS RECORD(cdmodali tbcc_tipo_conta.cdmodalidade_tipo%TYPE);        
      TYPE typ_tab_tipcta_2 IS TABLE OF typ_reg_tipcta   INDEX BY PLS_INTEGER;        
      TYPE typ_tab_tipcta   IS TABLE OF typ_tab_tipcta_2 INDEX BY PLS_INTEGER;          
      -- Vetor para armazenar os dados para o processo definitivo
      vr_tab_tipcta typ_tab_tipcta;
      
      ------------------------------- VARIAVEIS -------------------------------
      vr_dtmvtolt VARCHAR2(100);
      vr_deschist VARCHAR2(100);       
      vr_nrdocmto VARCHAR2(100);       
      vr_vllanmto VARCHAR2(100);       
      vr_tot_vldebito NUMBER;
      vr_nmdsecao VARCHAR2(100);
      vr_qtprecal INTEGER;    
      vr_nrdconta INTEGER;    
      vr_dtinimes DATE;   
      vr_contador INTEGER;    
      vr_dshis108 VARCHAR2(100);
      vr_lshistor INTEGER;
      vr_seqav173 INTEGER; 
      vr_seqav193 INTEGER; 
      vr_seqav204 INTEGER;  
      vr_dstipcta VARCHAR2(100);
      vr_indespac INTEGER; 
      vr_nrregext VARCHAR2(500);
      vr_nrdordem INTEGER; 
      vr_nrarquiv INTEGER := 1;
      vr_cdempres INTEGER; 
      vr_imlogoin VARCHAR2(100);
      vr_imlogoex VARCHAR2(100);
      vr_cdacesso VARCHAR2(100);
      
      vr_indcrapepr VARCHAR2(100);
      vr_indcrapdes VARCHAR2(100);
      vr_crapenc  BOOLEAN; 
      vr_crapage  BOOLEAN;
      
      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Insere dados na temp table vr_tab_cratext
      PROCEDURE pc_cria_crapext( pr_nrdordem IN INTEGER
                                ,pr_nrregext OUT VARCHAR2
                                ,pr_contador OUT INTEGER
                                ,pr_tpdaviso IN PLS_INTEGER) IS
      BEGIN
        DECLARE
          --dados dos centros de distribuição
          CURSOR cr_crapcdd(pr_nrcepend IN crapenc.nrcepend%TYPE) IS
            SELECT crapcdd.nomedcdd
                  ,crapcdd.nrcepini
                  ,crapcdd.nrcepfim
                  ,crapcdd.dscentra
            FROM   crapcdd
            WHERE crapcdd.nrcepini <= pr_nrcepend   
            AND   crapcdd.nrcepfim >= pr_nrcepend;
          --  
          rw_crapcdd cr_crapcdd%ROWTYPE;
          
          vr_indwcratext VARCHAR2(500);
          vr_nomedcdd crapcdd.nomedcdd %TYPE;
          vr_nrcepcdd VARCHAR2(100);
          vr_dscentra crapcdd.dscentra%TYPE; 
          vr_nmsecext VARCHAR2(100);
          vr_nmagenci VARCHAR2(100);
          vr_dsender1 VARCHAR2(100);  
          
        BEGIN
          --verifica a sequencia do aviso
          IF pr_tpdaviso = 1 THEN
            vr_seqav173 := nvl(vr_seqav173,0) + 1;
          ELSIF pr_tpdaviso = 2  THEN
            vr_seqav193 := nvl(vr_seqav193,0) + 1;
          ELSIF pr_tpdaviso = 3  THEN
            vr_seqav204 := nvl(vr_seqav204,0) + 1;
          END IF; 
          
          --busca o nome da agencia
          IF vr_crapage THEN
            vr_nmagenci := vr_tab_crapage(vr_tab_crapass(rw_crapavs.nrdconta).cdagenci).nmresage;
          ELSE
            vr_nmagenci := ' ';
          END IF;         

          --verifica os centros de distribuicao
          OPEN cr_crapcdd(pr_nrcepend => vr_tab_crapenc(rw_crapavs.nrdconta).nrcepend);  
          FETCH cr_crapcdd INTO rw_crapcdd;
          
          --se localizar o centro de distibuicao, alimenta as variaveis auxiliares
          IF cr_crapcdd%FOUND THEN
            CLOSE cr_crapcdd;
            vr_nomedcdd := rw_crapcdd.nomedcdd; 
            vr_nrcepcdd := to_char(rw_crapcdd.nrcepini,'fm99G999G999') || ' - ' ||
                           to_char(rw_crapcdd.nrcepfim,'fm99G999G999');
            vr_dscentra := rw_crapcdd.dscentra; 
          ELSE
            CLOSE cr_crapcdd;
            vr_nomedcdd := ' ';
            vr_nrcepcdd := ' ';
            vr_dscentra := ' '; 
          END IF;

          --se existir informacao no cadastro de pessoa fisica
          IF vr_tab_crapttl.EXISTS(rw_crapavs.nrdconta) THEN
            IF vr_tab_crapass(rw_crapavs.nrdconta).cdsecext <> 0 THEN
              vr_nmsecext := vr_nmdsecao;
            END IF;  
          ELSE
            IF vr_tab_crapass(rw_crapavs.nrdconta).cdsecext = 0 THEN  
              vr_nmsecext := NULL;
            ELSE 
              vr_nmsecext := vr_nmdsecao;
            END IF;  
          END IF; 
          
          -- endereço
          vr_dsender1 := vr_tab_crapenc(rw_crapavs.nrdconta).dsendere || ' ' ||
                         TRIM(gene0002.fn_mask(vr_tab_crapenc(rw_crapavs.nrdconta).nrendere, 'zzz.zzz'));
          
          --monta o indice de acordo com o indicador de despacho (0=Normal e 1=Correio). 
          IF vr_indespac = 1 THEN
            --criando o indice da tabela temporaria
            vr_indwcratext := vr_indespac||
                              rpad(vr_nomedcdd,50,'#')|| 
                              lpad(vr_tab_crapenc(rw_crapavs.nrdconta).nrcepend,10,'0')||
                              rpad(vr_dsender1,60,'#')||
                              lpad(rw_crapavs.nrdconta,10,'0')||
                              to_char(rw_crapavs.dtdebito,'YYYYMMDD')||
                              lpad(rw_crapavs.cdhistor,10,'0')||
                              lpad(rw_crapavs.nrdocmto,25,'0')||
                              lpad(vr_tab_wcratext.count + 1,7,'0');
          ELSE   
            --criando o indice da tabela temporaria
            vr_indwcratext := vr_indespac||
                              lpad(vr_tab_crapass(rw_crapavs.nrdconta).cdagenci,5,'0')||
                              lpad(rw_crapavs.nrdconta,10,'0')||
                              to_char(rw_crapavs.dtdebito,'YYYYMMDD')||
                              lpad(rw_crapavs.cdhistor,10,'0')||
                              lpad(rw_crapavs.nrdocmto,25,'0')||
                              lpad(vr_tab_wcratext.count + 1,7,'0');
          END IF;
          
          --criando novo registro na tabela temporaria 
          vr_tab_wcratext(vr_indwcratext).tpdaviso := pr_tpdaviso;
          --se tem informacoes no cadastro de endereco
          IF vr_crapenc THEN
            vr_tab_wcratext(vr_indwcratext).dsender1 := vr_dsender1;
            vr_tab_wcratext(vr_indwcratext).dsender2 := rpad(vr_tab_crapenc(rw_crapavs.nrdconta).nmbairro,15,' ') || '   ' ||  
                                                       rpad(vr_tab_crapenc(rw_crapavs.nrdconta).nmcidade,15,' ') || ' - ' ||
                                                       rpad(vr_tab_crapenc(rw_crapavs.nrdconta).cdufende, 2,' '); 
            vr_tab_wcratext(vr_indwcratext).nrcepend := vr_tab_crapenc(rw_crapavs.nrdconta).nrcepend;
            vr_tab_wcratext(vr_indwcratext).complend := rpad(vr_tab_crapenc(rw_crapavs.nrdconta).complend,35,' '); 
          ELSE
            vr_tab_wcratext(vr_indwcratext).dsender1 := ' ';
            vr_tab_wcratext(vr_indwcratext).dsender2 := ' ';
            vr_tab_wcratext(vr_indwcratext).nrcepend := ' ';
            vr_tab_wcratext(vr_indwcratext).complend := ' ';
          END IF;
          vr_tab_wcratext(vr_indwcratext).nmsecext := vr_nmsecext;
          vr_tab_wcratext(vr_indwcratext).nomedcdd := vr_nomedcdd;
          vr_tab_wcratext(vr_indwcratext).nrcepcdd := vr_nrcepcdd;
          vr_tab_wcratext(vr_indwcratext).dscentra := vr_dscentra;
          vr_tab_wcratext(vr_indwcratext).nmempres := vr_tab_crapemp(vr_cdempres).nmresemp;
          vr_tab_wcratext(vr_indwcratext).nmagenci := vr_nmagenci;
          vr_tab_wcratext(vr_indwcratext).nrdconta := vr_tab_crapass(rw_crapavs.nrdconta).nrdconta;
          vr_tab_wcratext(vr_indwcratext).cdagenci := vr_tab_crapass(rw_crapavs.nrdconta).cdagenci;
          vr_tab_wcratext(vr_indwcratext).nmprimtl := rpad(vr_tab_crapass(rw_crapavs.nrdconta).nmprimtl,40,' ')|| 
                                                      '   ' || vr_dstipcta;
          vr_tab_wcratext(vr_indwcratext).dtemissa := rw_crapdat.dtmvtolt;
          vr_tab_wcratext(vr_indwcratext).nrdordem := pr_nrdordem;
          vr_tab_wcratext(vr_indwcratext).tpdocmto := 13;
          vr_tab_wcratext(vr_indwcratext).indespac := vr_indespac;  
          
          --tipo de aviso de debito
          IF pr_tpdaviso = 1 THEN
            vr_tab_wcratext(vr_indwcratext).nrseqint := vr_seqav173; 
          ELSE 
            IF pr_tpdaviso = 2 THEN  
              vr_tab_wcratext(vr_indwcratext).nrseqint := vr_seqav193;
            ELSE
              vr_tab_wcratext(vr_indwcratext).nrseqint := vr_seqav204;
            END IF;
          END IF;  
          -- Dados Internos  
          vr_tab_wcratext(vr_indwcratext).dsintern(1) := rpad(vr_tab_crapass(rw_crapavs.nrdconta).nmprimtl,40,' ')|| 
                                                        rpad(' ',9,' ') ||
                                                        gene0002.fn_mask(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta,'zzzz.zz9.9');
          -- retorna o indice da tabela
          pr_nrregext := vr_indwcratext;
          pr_contador := 1;

        EXCEPTION
          WHEN OTHERS THEN
            --gera a critica
            vr_dscritic := 'Erro no procedimento pc_criaext. '||SQLERRM;
            --aborta a execucao
            RAISE vr_exc_saida;  
        END;  
      END pc_cria_crapext;   
      
      PROCEDURE pc_final_crapext( pr_nrregext IN VARCHAR2
                                 ,pr_tpdaviso IN PLS_INTEGER ) IS
      BEGIN
        BEGIN
          --verifica se a tabela temporaria possui o registro informado
          IF NOT vr_tab_wcratext.EXISTS(pr_nrregext) THEN
            --codigo da critica
            vr_cdcritic := 11;--011 - Lancamentos nao encontrados.
            --descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                           ' Conta: ' || TRIM( vr_tab_crapass(rw_crapavs.nrdconta).nrdconta);
            --finaliza a execucao do programa 
            RAISE vr_exc_fimprg;
          END IF;
          
          IF pr_tpdaviso = 1 THEN     /* crrl173 - DEBITO EM FOLHA */
            vr_tab_wcratext(pr_nrregext).dsintern(19) := 'O VALOR TOTAL SERA DEBITADO';
            vr_tab_wcratext(pr_nrregext).dsintern(20) := 'NO DIA DO CREDITO DO SALARIO.';
            vr_tab_wcratext(pr_nrregext).dsintern(21) := 'CASO NAO QUEIRA RECEBER ESSE AVISO, SOLICITE O';
            vr_tab_wcratext(pr_nrregext).dsintern(22) := 'CANCELAMENTO NO SEU POSTO DE ATENDIMENTO.';
            vr_tab_wcratext(pr_nrregext).dsintern(23) := '#';                 
          ELSE
            vr_tab_wcratext(pr_nrregext).dsintern(19) := '#';
          END IF;
          
        END;  
      END pc_final_crapext;

      --subrotina para geracao dos arquivos
      PROCEDURE pc_finaliza(pr_tpdaviso IN INTEGER) IS
      BEGIN
        DECLARE
          vr_nmarqdat    VARCHAR2(100);
          vr_dsdireto    VARCHAR2(500);
          vr_dsarq       VARCHAR2(500);
          vr_dssalvar    VARCHAR2(500);
          vr_indwcratext VARCHAR2(500);
          vr_indice      varchar2(140);

          -- variaveis de controle de comandos shell
          vr_comando			VARCHAR2(500);
          vr_typ_saida    VARCHAR2(1000);
          
        BEGIN
          --limpando a tabela temporaria que sera utilizada como parametro
          vr_tab_cratext.delete;
          
          -- Busca os diretorios da cooperativa conectada
          vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '');
          vr_dsarq    := vr_dsdireto||'/arq';
          vr_dssalvar := vr_dsdireto||'/salvar';

          --posiciona no primeiro registro da tabela
          vr_indwcratext := vr_tab_wcratext.first;
          LOOP
            --sai quando percorrer toda a tabela temporaria
            EXIT WHEN vr_indwcratext IS NULL;
            
            --verifica o codigo de aviso que está sendo gerado
            IF vr_tab_wcratext(vr_indwcratext).tpdaviso = pr_tpdaviso THEN
              --gera o indexador da tabela temporaria
              vr_indice := lpad(vr_tab_cratext.count + 1, 10,'0');
              --carrega a tabela temporaria
              vr_tab_cratext(vr_indice).nmempres := vr_tab_wcratext(vr_indwcratext).nmempres;
              vr_tab_cratext(vr_indice).nmsecext := vr_tab_wcratext(vr_indwcratext).nmsecext;
              vr_tab_cratext(vr_indice).nmagenci := substr(vr_tab_wcratext(vr_indwcratext).nmagenci,1,15);
              vr_tab_cratext(vr_indice).nrdconta := vr_tab_wcratext(vr_indwcratext).nrdconta;
              vr_tab_cratext(vr_indice).cdagenci := vr_tab_wcratext(vr_indwcratext).cdagenci;
              vr_tab_cratext(vr_indice).nmprimtl := vr_tab_wcratext(vr_indwcratext).nmprimtl;
              vr_tab_cratext(vr_indice).dsender1 := vr_tab_wcratext(vr_indwcratext).dsender1;
              vr_tab_cratext(vr_indice).dsender2 := vr_tab_wcratext(vr_indwcratext).dsender2;
              vr_tab_cratext(vr_indice).nrcepend := vr_tab_wcratext(vr_indwcratext).nrcepend;
              vr_tab_cratext(vr_indice).nomedcdd := vr_tab_wcratext(vr_indwcratext).nomedcdd;
              vr_tab_cratext(vr_indice).nrcepcdd := vr_tab_wcratext(vr_indwcratext).nrcepcdd; 
              vr_tab_cratext(vr_indice).dscentra := vr_tab_wcratext(vr_indwcratext).dscentra;
              vr_tab_cratext(vr_indice).complend := vr_tab_wcratext(vr_indwcratext).complend; 
              vr_tab_cratext(vr_indice).dtemissa := vr_tab_wcratext(vr_indwcratext).dtemissa;
              vr_tab_cratext(vr_indice).nrdordem := vr_tab_wcratext(vr_indwcratext).nrdordem;
              vr_tab_cratext(vr_indice).tpdocmto := vr_tab_wcratext(vr_indwcratext).tpdocmto;
              vr_tab_cratext(vr_indice).indespac := vr_tab_wcratext(vr_indwcratext).indespac;
              vr_tab_cratext(vr_indice).nrseqint := vr_tab_wcratext(vr_indwcratext).nrseqint;
              --se o tipo de aviso = 1 insere 23 posicoes do vetor  
              IF pr_tpdaviso = 1 THEN
                FOR vr_ind IN 1 .. 23 LOOP
                  vr_tab_cratext(vr_indice).dsintern(vr_ind) := vr_tab_wcratext(vr_indwcratext).dsintern(vr_ind);
                END LOOP;
              --senao insere somente 19  
              ELSE
                FOR vr_ind IN 1 .. 19 LOOP
                  vr_tab_cratext(vr_indice).dsintern(vr_ind) := vr_tab_wcratext(vr_indwcratext).dsintern(vr_ind);
                END LOOP;
              END IF;
            END IF;  
            --vai para o proximo registro
            vr_indwcratext := vr_tab_wcratext.next(vr_indwcratext);
          END LOOP; 
          --se o aviso de debito 1 gera o relatorio 173
          IF pr_tpdaviso = 1 THEN
            --nome do arquivo .dat
            vr_nmarqdat := lpad(pr_cdcooper, 2,'0') || 
                           'crrl173_' || to_char(rw_crapdat.dtmvtolt, 'DD') ||
                           to_char(rw_crapdat.dtmvtolt, 'MM')||'.dat';          
          ELSIF pr_tpdaviso = 2 THEN
            --nome do arquivo .dat
            vr_nmarqdat := lpad(pr_cdcooper, 2,'0') || 
                           'crrl193_' || to_char(rw_crapdat.dtmvtolt, 'DD') ||
                           to_char(rw_crapdat.dtmvtolt, 'MM')||'.dat';          
          ELSE
            --nome do arquivo .dat
            vr_nmarqdat := lpad(pr_cdcooper, 2,'0') || 
                           'crrl204_' || to_char(rw_crapdat.dtmvtolt, 'DD') ||
                           to_char(rw_crapdat.dtmvtolt, 'MM')||'.dat';          
          END IF;  

          /* Gerar os dados para a frente e verso dos informativos. */
          FORM0001.pc_gera_dados_inform( pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdacesso => vr_cdacesso
                                        ,pr_qtmaxarq => 0
                                        ,pr_nrarquiv => vr_nrarquiv
                                        ,pr_dsdireto => vr_dsarq
                                        ,pr_nmarqdat => vr_nmarqdat
                                        ,pr_tab_cratext => vr_tab_cratext
                                        ,pr_imlogoex    => vr_imlogoex
                                        ,pr_imlogoin    => vr_imlogoin
                                        ,pr_des_erro => vr_dscritic);
                                        
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;

          -- Comando para copiar o arquivo para a pasta salvar
          vr_comando:= 'mv '||vr_dsarq||'/'||vr_nmarqdat||' '||vr_dssalvar;

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => pr_dscritic);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
           pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           -- retornando ao programa chamador
           RETURN;
          END IF;
          
        END;   
      END pc_finaliza;   
        
    --inicio do programa   
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
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
      
      vr_tab_tipcta.delete;
      /*  Carrega tabela de tipos de conta  */
      FOR rw_tipcta IN cr_tipcta LOOP
        vr_tab_tipcta(rw_tipcta.inpessoa)(rw_tipcta.cdtipcta).cdmodali := rw_tipcta.cdmodali;
      END LOOP; /*  Fim do LOOP -- Carga da tabela de tipos de conta  */
            
      --limpa a tabela de historicos
      vr_tab_craphis.delete;
      --carrega a tabela de historicos
      FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).dsextrat := rw_craphis.dsextrat;
      END LOOP; 
      
      --limpa a tabela de empresas
      vr_tab_crapemp.delete;
      --carrega a tabela de empresas
      FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapemp(rw_crapemp.cdempres).cdempres := rw_crapemp.cdempres;
        vr_tab_crapemp(rw_crapemp.cdempres).nmresemp := rw_crapemp.nmresemp;
      END LOOP; 
      
      --limpa a tabela de emissao de extratos
      vr_tab_crapcex.delete;
      --carrega a tabela temporaria de emissao de extratos
      FOR rw_crapcex IN cr_crapcex(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapcex(rw_crapcex.nrdconta) := rw_crapcex.nrdconta;
      END LOOP;  
      
      --limpa a tabela de associados
      vr_tab_crapass.delete;
      --carrega a tabela temporaria de associados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).tpavsdeb := rw_crapass.tpavsdeb;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).cdtipcta := rw_crapass.cdtipcta;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;  

      --limpa a tabela de titulares
      vr_tab_crapttl.delete;
      --carrega a tabela temporaria de titulares
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapttl(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
      END LOOP;  

      --limpa a tabela de pessoas juridicas
      vr_tab_crapjur.delete;
      --carrega a tabela temporaria de pessoas juridicas
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapjur(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;  

      --limpa a tabela de emprestimos
      vr_tab_crapepr.delete;
      --carrega a tabela temporaria de pessoas juridicas
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapepr(lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0')).nrctremp := rw_crapepr.nrctremp;
        vr_tab_crapepr(lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0')).qtprecal := rw_crapepr.qtprecal;
        vr_tab_crapepr(lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0')).qtpreemp := rw_crapepr.qtpreemp;
      END LOOP;  

      --limpa a tabela de destino de extratos
      vr_tab_crapdes.delete;
      --carrega a tabela temporaria de destino de extratos
      FOR rw_crapdes IN cr_crapdes(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapdes(lpad(rw_crapdes.cdagenci,5,'0')||lpad(rw_crapdes.cdsecext,5,'0')).indespac := rw_crapdes.indespac;
        vr_tab_crapdes(lpad(rw_crapdes.cdagenci,5,'0')||lpad(rw_crapdes.cdsecext,5,'0')).nmsecext := rw_crapdes.nmsecext;
      END LOOP;  

      --limpa a tabela de agencias
      vr_tab_crapage.delete;
      --carrega a tabela temporaria de agencias
      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;  
      
      --limpa a tabela de enderecos
      vr_tab_crapenc.delete;
      --carrega a tabela de enderecos
      FOR rw_crapenc IN cr_crapenc(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapenc(rw_crapenc.nrdconta).nrcepend := rw_crapenc.nrcepend;
        vr_tab_crapenc(rw_crapenc.nrdconta).nmcidade := rw_crapenc.nmcidade;
        vr_tab_crapenc(rw_crapenc.nrdconta).dsendere := rw_crapenc.dsendere;
        vr_tab_crapenc(rw_crapenc.nrdconta).nrendere := rw_crapenc.nrendere;
        vr_tab_crapenc(rw_crapenc.nrdconta).nmbairro := rw_crapenc.nmbairro;
        vr_tab_crapenc(rw_crapenc.nrdconta).cdufende := rw_crapenc.cdufende;
        vr_tab_crapenc(rw_crapenc.nrdconta).complend := rw_crapenc.complend;
      END LOOP;  
      
      --inicializando as variaveis
      vr_imlogoin := 'laser/imagens/logo_'||TRIM(lower(rw_crapcop.nmrescop))||'_interno.pcx';
      vr_imlogoex := 'laser/imagens/logo_'||TRIM(lower(rw_crapcop.nmrescop))||'_externo.pcx';
      vr_cdacesso := 'MSGDOAVISO';
      vr_seqav173 := 0;
      vr_seqav193 := 0;
      vr_seqav204 := 0;       

      --primeiro dia do mes
      vr_dtinimes := trunc(rw_crapdat.dtmvtolt,'MONTH');

      --limpando as informacoes da tabela temporaria
      vr_tab_wcratext.delete;
      
      --gera relatorios para os tres tipos de aviso de debito
      FOR vr_tpdaviso IN 1 .. 3 LOOP
        
        -- iniciallizando as variaveis auxiliares
        vr_nrdconta     := 0;
        vr_tot_vldebito := 0;

        /* Monta lista de historicos que nao devem ser processados */
        IF vr_tpdaviso = 1 AND pr_cdcooper = 2 THEN
          vr_lshistor := 127; 
        ELSE
          vr_lshistor := NULL;
        END IF;        
        
        --verifica todos os avisos de debito em conta corrente
        --na data e pelo tipo de aviso de debito
        OPEN cr_crapavs(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_tpdaviso => vr_tpdaviso
                       ,pr_cdhistor => vr_lshistor);
        LOOP
          FETCH cr_crapavs INTO rw_crapavs;
          EXIT WHEN cr_crapavs%NOTFOUND;
          --se o tipo de aviso de débito igual a 1 e se não exitir registros
          --na tabela de emissao de extratos
          IF vr_tpdaviso = 1  AND NOT(vr_tab_crapcex.EXISTS(rw_crapavs.nrdconta))THEN
            CONTINUE;                         
          END IF;
                     
          --se a conta do associado nao existir, aborta a execucao
          IF NOT vr_tab_crapass.exists(rw_crapavs.nrdconta) THEN
            --gera critica
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                          ' Conta: '||gene0002.fn_mask_conta(rw_crapavs.nrdconta);
            --aborta a execucao               
            RAISE vr_exc_saida;               
          END IF;  
                     
          --se nao existir o historico, aborta a execucao
          IF NOT vr_tab_craphis.exists(rw_crapavs.cdhistor) THEN
            --gera excecao
            vr_dscritic := 'Historico '||rw_crapavs.cdhistor||' nao está cadastrado.';
            --aborta a execucao
            RAISE vr_exc_saida;
          END IF; 
                     
          -- se o associado é pessoa fisica
          IF vr_tab_crapass(rw_crapavs.nrdconta).inpessoa = 1 THEN 
                       
            --se existir informacao no cadastro de pessoa fisica
            IF vr_tab_crapttl.EXISTS(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta) THEN
              vr_cdempres := vr_tab_crapttl(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta).cdempres;
            END IF;  
          ELSE
            --se existir informacao no cadastro de pessoa juridica
            IF vr_tab_crapjur.EXISTS(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta) THEN
              vr_cdempres := vr_tab_crapjur(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta).cdempres;
            END IF;  
          END IF;
                     
          --se tipo de aviso de debito igual a 2 e o tipo de emissao seja 0-não emite
          --vai para o proximo registro
          IF rw_crapavs.tpdaviso = 2 AND vr_tab_crapass(rw_crapavs.nrdconta).tpavsdeb = 0 THEN 
            CONTINUE;
          END IF;     
                                      
          -- se é  CREDIFIESC e tipo de aviso de debito igual a 1
          -- vai para o proximo registro   
          IF pr_cdcooper = 6   AND rw_crapavs.tpdaviso = 1   THEN
            CONTINUE;
          END IF;  

          /*  Edson - 27/09/2004  */
          IF pr_cdcooper = 1   AND           /*  VIACREDI            */
             rw_crapavs.tpdaviso = 1   AND   /*  DESCTO VINC. FOLHA  */
             (vr_tab_crapass(rw_crapavs.nrdconta).cdagenci = 14  OR     /*  PAC JARAGUA SEARA   */
             vr_tab_crapass(rw_crapavs.nrdconta).cdagenci = 21) THEN   /*  PAC JARAGUA CENTRO  */
           CONTINUE;
          END IF;  

          --se o codigo do historico é 108
          IF rw_crapavs.cdhistor = 108 THEN
                       
            -- recebe a descricao do extrato
            vr_dshis108 := vr_tab_craphis(rw_crapavs.cdhistor).dsextrat;
                       
            --se o tipo de aviso é 1
            IF rw_crapavs.tpdaviso = 1 THEN
              vr_qtprecal := 1;
            ELSE 
              vr_qtprecal := 0;
            END IF;
                                   
            --monta a chave de busca dos emprestimos
            vr_indcrapepr := lpad(rw_crapavs.nrdconta,10,'0')||lpad(rw_crapavs.nrdocmto,10,'0');
                       
            --se possuir registro de emprestimo                
            IF vr_tab_crapepr.EXISTS(vr_indcrapepr) THEN
                         
              --se o mes do movimento é o mesmo mes do movimento do dia anterior 
              IF to_char(rw_crapdat.dtmvtolt,'MM') = to_char(rw_crapdat.dtmvtoan,'MM') THEN
                           
                --busca todos os lancamentos de emprestimo do associado no mes
                FOR rw_craplem IN cr_craplem( pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapavs.nrdconta
                                            ,pr_nrctremp => rw_crapavs.nrdocmto
                                            ,pr_dtinimes => vr_dtinimes)
                LOOP 
                  --verifica o numero do lote e a data do movimento                                             
                  IF rw_craplem.nrdolote > 5500 AND
                     rw_craplem.nrdolote < 6000 AND
                     rw_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
                    CONTINUE;
                  END IF;
                             
                  --verifica se o valor do emprestimo e maior do que zero                                   
                  IF rw_craplem.vlpreemp > 0 THEN
                    --se o historico eh 80 ou 120
                    IF rw_craplem.cdhistor = 88 OR rw_craplem.cdhistor = 120 THEN 
                      --diminui o valor do lancamento
                      vr_qtprecal := vr_qtprecal - ROUND(rw_craplem.vllanmto / rw_craplem.vlpreemp,4);
                    ELSE 
                      --soma o valor do lancamento
                      vr_qtprecal := vr_qtprecal + ROUND(rw_craplem.vllanmto / rw_craplem.vlpreemp,4);
                    END IF;
                  END IF;
                END LOOP;                 
              END IF;
                                     
              vr_dshis108 := 'PREST.EMP.'||
                             lpad(round(nvl(vr_tab_crapepr(vr_indcrapepr).qtprecal,0) + nvl(vr_qtprecal,0)),2,'0')||
                             '/' ||lpad(vr_tab_crapepr(vr_indcrapepr).qtpreemp,3,' ');
            END IF;
          END IF;--IF rw_crapavs.cdhistor = 108 THEN
                     
          -- se a variavel de controle da conta é diferente da conta do lancamento do aviso
          IF vr_nrdconta <> rw_crapavs.nrdconta THEN
                       
            --inicializando as variaveis de controle
            vr_contador := 0; 
            vr_nrdordem := 1;
            vr_nrdconta := rw_crapavs.nrdconta;   
                                               
            --monta a chave de busca do destino de extratos 
            vr_indcrapdes := lpad(vr_tab_crapass(rw_crapavs.nrdconta).cdagenci,5,'0')||
                             lpad(vr_tab_crapass(rw_crapavs.nrdconta).cdsecext,5,'0');

            --Descricao do destino dos avisos  
            IF vr_tab_crapdes.EXISTS(vr_indcrapdes) THEN
              --se o indicador de despacho for 1-correio
              IF vr_tab_crapdes(vr_indcrapdes).indespac = 1 THEN
               vr_indespac := 1; /* Destino Correio */ 
              ELSE 
               vr_indespac := 2; /* Destino Balcao */ 
              END IF;
                                                             
              --nome da secao para onde sao enviados os extratos
              vr_nmdsecao := vr_tab_crapdes(vr_indcrapdes).nmsecext;
            ELSE
              vr_nmdsecao := 'SECAO EXCLUIDA';
              vr_indespac := 2; /* Destino Balcao */ 
            END IF;    

            --verifica se a agencia está cadastrada
            vr_crapage := vr_tab_crapage.EXISTS(vr_tab_crapass(rw_crapavs.nrdconta).cdagenci);
                                   
            --verifica o tipo de conta do associado
            IF vr_tpdaviso = 1 AND vr_cdempres = 6 AND 
               vr_tab_tipcta(vr_tab_crapass(rw_crapavs.nrdconta).inpessoa)
                            (vr_tab_crapass(rw_crapavs.nrdconta).cdtipcta).cdmodali NOT IN (2,3) THEN
              vr_dstipcta := 'C/C';
            ELSE
              vr_dstipcta := NULL;
            END IF;  
                                     
            --verifica se o endereco existe
            vr_crapenc := vr_tab_crapenc.EXISTS(vr_tab_crapass(rw_crapavs.nrdconta).nrdconta);

            -- cria o registro na tabela temporaria
            pc_cria_crapext( pr_nrdordem => 1
                            ,pr_nrregext => vr_nrregext
                            ,pr_contador => vr_contador
                            ,pr_tpdaviso => vr_tpdaviso);

          END IF;
          --incrementa o contador
          vr_contador := nvl(vr_contador,0) + 1;

          --se tem mais de 18 registros
          IF vr_contador > 18 THEN
            -- preenche o campo dsintern
            pc_final_crapext( pr_nrregext => vr_nrregext
                             ,pr_tpdaviso => vr_tpdaviso);
                                   
            --incrementa a ordem       
            vr_nrdordem := nvl(vr_nrdordem,0) + 1;
                                   
            --insere novo registro na wcrapext        
            pc_cria_crapext( pr_nrdordem => vr_nrdordem 
                            ,pr_nrregext => vr_nrregext
                            ,pr_contador => vr_contador
                            ,pr_tpdaviso => vr_tpdaviso);
                                  
            --incrementa o contador       
            vr_contador := nvl(vr_contador,0) + 1;
          END IF;

          --trata a data do debito
          IF rw_crapavs.dtdebito IS NULL THEN
            vr_dtmvtolt := '          ';
          ELSE 
            vr_dtmvtolt := to_char(rw_crapavs.dtdebito, 'DD/MM/YYYY');
          END IF;  
                     
          --se historico diferente de 108 busca descricao na tabela de hitoricos                   
          IF rw_crapavs.cdhistor = 108 THEN
            vr_deschist := rpad(vr_dshis108, 21,' '); 
          ELSE 
            vr_deschist := rpad(vr_tab_craphis(rw_crapavs.cdhistor).dsextrat, 21,' ');
          END IF;
                     
          --se o numero do documento eh maior que nove posicoes
          --concatena zeros e retorna parte do numero 
          IF LENGTH(rw_crapavs.nrdocmto) > 9 THEN
            vr_nrdocmto := SUBSTR(lpad(rw_crapavs.nrdocmto,14,'0'),4,11);
          ELSE 
            IF rw_crapavs.cdhistor = 46 THEN
              vr_nrdocmto := gene0002.fn_mask(rw_crapavs.nrdocmto,'zzzzz.zzz.9');
            ELSE 
              vr_nrdocmto := gene0002.fn_mask(rw_crapavs.nrdocmto,'zzz.zzz.zz9');
            END IF;                
          END IF;  
          --armazena o valor do lancamento 
          vr_vllanmto := to_char(rw_crapavs.vllanmto, '99G999G990D00');
          --acumula o total de lancamentos
          vr_tot_vldebito := nvl(vr_tot_vldebito,0) + rw_crapavs.vllanmto;

          --atualizando o campo da tabela temporaria
          vr_tab_wcratext(vr_nrregext).dsintern(vr_contador) := vr_dtmvtolt || '  ' ||
                                                                vr_deschist || '  ' ||
                                                                vr_nrdocmto || '   ' ||
                                                                vr_vllanmto;
          --LAST-OF(crapavs.nrdconta)
          IF rw_crapavs.nrseq = rw_crapavs.qtreg THEN
            --incrementando o contador
            vr_contador := nvl(vr_contador,0) + 1;
                             
            --se o contador ultrapassar 18 registros
            IF vr_contador > 18 THEN
              -- preenche o campo dsintern
              pc_final_crapext( pr_nrregext => vr_nrregext
                               ,pr_tpdaviso => vr_tpdaviso);
                                          
              --incrementa o numero da ordem
              vr_nrdordem := vr_nrdordem + 1;
              
              -- cria novo registro na tabela temporaria wcratext
              pc_cria_crapext( pr_nrdordem => vr_nrdordem
                              ,pr_nrregext => vr_nrregext
                              ,pr_contador => vr_contador
                              ,pr_tpdaviso => vr_tpdaviso);
                                                   
              vr_contador := nvl(vr_contador,0) + 1;
            END IF;
                             
            vr_vllanmto     := TRIM(to_char(vr_tot_vldebito,'999G999G990D00'));
            vr_vllanmto     := lpad('-',14 - LENGTH(vr_vllanmto) - 2,'-') ||'> ' || vr_vllanmto;
            vr_tot_vldebito := 0;
            vr_tab_wcratext(vr_nrregext).dsintern(vr_contador) := rpad(' ',37,' ')|| 'T O T A L   ' || vr_vllanmto; 
            
            --finaliza as infomacoes na wcratext                                 
            pc_final_crapext(pr_nrregext => vr_nrregext
                            ,pr_tpdaviso => vr_tpdaviso);
          END IF;
 
        END LOOP;--OPEN cr_crapavs( pr_cdcooper => pr_cdcooper   
        --fecha o cursor
        CLOSE cr_crapavs;                                   

      END LOOP;--FOR vr_tpdaviso IN 1 .. 3 LOOP  
      
      IF nvl(vr_seqav173,0) > 0 THEN
        --gera o relatorio crrl173
        pc_finaliza(pr_tpdaviso => 1);
      END IF;
      
      IF nvl(vr_seqav193,0) > 0 THEN  
        --gera o relatorio crrl193
        pc_finaliza(pr_tpdaviso => 2);
      END IF;
      
      IF nvl(vr_seqav204,0) > 0 THEN     
        --gera o relatorio crrl204
        pc_finaliza(pr_tpdaviso => 3);
      END IF;
      
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

  END pc_crps219;
/

