CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps230 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

   Programa: PC_CRPS230 (antigo Fontes/crps230.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/98.                       Ultima atualizacao: 06/04/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 34.
               Acumula dados para CPMF.

   Alteracoes: 27/01/99 - Colocar data final de CPMF (Odair)
   
               09/06/99 - Tratar ass.iniscpmf (Odair).

               28/06/99 - Tratar estorno nas contas da cooperativa (Odair)

               29/06/99 - Colocar nrdocmto < 8000051 para filtrar cheques 
                          salarios emitidos antes do inicio da cpmf e que 
                          foram creditados valores, pois estava dando diferenca
                          na base calculada (Odair)

               12/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).
               
               13/03/2000 - Atualizar novos campos (Odair)
               
               27/03/2000 - Tratar documentos de credito C (DOC C) (Odair)

               25/06/2001 - Tratar nova conta - cheque administrativo (Deborah)
               
               19/04/2002 - Tratar historico 43 - nao estava mandando quando
                            havia cobrado do associado (Deborah)

               31/03/2003 - Incluir c/c Administrativo Concredi (Ze Eduardo).
               
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               12/12/2007 - Incluidos valores do INSS - BANCOOB (Evandro).
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               13/03/2009 - Desprezar conta 254.137-8 da Biblioteca da
                            Viacredi (Magui).

               25/08/2009 - Nao criticar como conta invalida a conta dos empres-
                            timos com emissao de boletos (Fernando).

               19/10/2009 - Alteracao Codigo Historico (Kbase).                            

               08/03/2010 - Alteracao Historico (Gati)
               
               19/04/2011 - Corrigido valores que nao estavam sendo mostrados
                            devido ao valor ser maior do que o informado 
                            no format (Adriano).
               
               02/12/2013 - Conversão Progress >> Oracle PLSQL (Andrino-RKAM)

               06/04/2015 - Retirado a critica 127 que logava no proc_batch
                            do programa (SD273530 - Tiago/Fabricio).
............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS230';

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

      -- Busca sobre a tabela de dados genericos (controle de emissao de boletos)
      CURSOR cr_craptab(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT dstextab
          FROM craptab 
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = 'CRED'
           AND craptab.tptabela = 'GENERI'
           AND craptab.cdempres = 00           
           AND craptab.cdacesso = 'CTAEMISBOL'
           AND craptab.tpregist = 0;
      rw_craptab cr_craptab%ROWTYPE;

      -- Busca dos historicos
      CURSOR cr_craphis(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cdhistor,
               inclasse
          FROM craphis
         WHERE cdcooper = pr_cdcooper;
      
      -- Busca dados do perioro de apuracao da CPMF
      CURSOR cr_crapper(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT dtiniper,
               dtfimper,
               vlrbscps,
               vlrcpcps,
               ROWID
          FROM crapper 
         WHERE crapper.cdcooper  = pr_cdcooper
           AND crapper.dtdebito <= pr_dtmvtolt
           AND crapper.indebito  = 1;

      -- Busca os dados de deposito a vista
      CURSOR cr_craplcm(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtiniper crapper.dtiniper%TYPE,
                        pr_dtfimper crapper.dtfimper%TYPE) IS
        SELECT crapass.nrdconta,
               craplcm.cdhistor,
               craplcm.vldoipmf,
               crapass.inpessoa,
               craplcm.vllanmto,
               crapass.iniscpmf,
               craplcm.nrdocmto
          FROM crapass,
               craplcm 
         WHERE crapass.cdcooper = craplcm.cdcooper
           AND crapass.nrdconta = craplcm.nrdconta
           AND craplcm.cdcooper = pr_cdcooper    
           AND craplcm.dtmvtolt >= pr_dtiniper   
           AND craplcm.dtmvtolt <= pr_dtfimper;

      -- Busca os dados dos lancamentos dos pagamentos de INSS
      CURSOR cr_craplpi(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtiniper crapper.dtiniper%TYPE,
                        pr_dtfimper crapper.dtfimper%TYPE) IS
        SELECT nvl(SUM(vllanmto),0) vllanmto,
               nvl(SUM(vldoipmf),0) vldoipmf
          FROM craplpi 
         WHERE craplpi.cdcooper  = pr_cdcooper
           AND craplpi.dtmvtolt >= pr_dtiniper   
           AND craplpi.dtmvtolt <= pr_dtfimper;
      rw_craplpi cr_craplpi%ROWTYPE;
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Definicao do tipo de registro para a tabela de historicos (CRAPHIS)
      TYPE typ_reg_craphis IS
        RECORD(cdhistor craphis.cdhistor%TYPE
              ,inclasse craphis.inclasse%TYPE);
      -- Definicao do tipo de tabela de historico
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
          INDEX BY BINARY_INTEGER;
      -- Vetor para armazenar os dados do historico
      vr_tab_craphis typ_tab_craphis;

      ------------------------------- VARIAVEIS -------------------------------
      vr_nrctabol     PLS_INTEGER;
      vr_dsperiod     VARCHAR2(50);
      vr_vlaplfin_fis NUMBER(15,2);
      vr_vlaplfin_jur NUMBER(15,2);
      vr_vlbaschq_fis NUMBER(15,2);
      vr_vlbaschq_jur NUMBER(15,2);
      vr_vlretchq_fis NUMBER(15,2);
      vr_vlretchq_jur NUMBER(15,2);
      vr_vlbascsd_fis NUMBER(15,2);
      vr_vlbascsd_jur NUMBER(15,2);
      vr_vlopecrd_fis NUMBER(15,2);
      vr_vlopecrd_jur NUMBER(15,2);
      vr_vloutdeb_fis NUMBER(15,2);
      vr_vloutdeb_jur NUMBER(15,2);
      vr_vlpgtaut_fis NUMBER(15,2);
      vr_vlpgtaut_jur NUMBER(15,2);
      vr_vlretapl_fis NUMBER(15,2);
      vr_vlretapl_jur NUMBER(15,2);
      vr_vlretcsd_fis NUMBER(15,2);
      vr_vlretcsd_jur NUMBER(15,2);
      vr_vlretope_fis NUMBER(15,2);
      vr_vlretope_jur NUMBER(15,2);
      vr_vlretout_fis NUMBER(15,2);
      vr_vlretout_jur NUMBER(15,2);
      vr_vlretpgt_fis NUMBER(15,2);
      vr_vlretpgt_jur NUMBER(15,2);
      vr_vltrfmtl     NUMBER(15,2);
      vr_vlretinv     NUMBER(15,2);
      vr_vlretimo     NUMBER(15,2);
      vr_vlretdsp     NUMBER(15,2);
      vr_vlinvcco     NUMBER(15,2);
      vr_vlimocco     NUMBER(15,2);
      vr_vlestcri     NUMBER(15,2);
      vr_vldspcco     NUMBER(15,2);
      vr_vldebntr     NUMBER(15,2);
      vr_vltrbcco     NUMBER(15,2);
      vr_vlrettrb     NUMBER(15,2);
      vr_vlcpmcps     NUMBER(15,2);
      vr_vlpesfis     NUMBER(15,2);
      vr_vlretfis     NUMBER(15,2);
      vr_vlpesjur     NUMBER(15,2);
      vr_vlretjur     NUMBER(15,2);
      vr_vlasscpm     NUMBER(15,2);
      vr_vlretass     NUMBER(15,2);
      vr_vlcpmncb     NUMBER(15,2);
      vr_vlcooper     NUMBER(15,2);
      vr_vlretcoo     NUMBER(15,2);
      vr_vlapurad     NUMBER(15,2);
      vr_vlcpmapu     NUMBER(15,2);
      vr_vlcalcul     NUMBER(15,2);
      vr_vlcpmcal     NUMBER(15,2);
      vr_vlbascmp     NUMBER(15,2);
      vr_vloutcop     NUMBER(15,2);
      vr_vlsaqmgn_fis NUMBER(15,2);
      vr_vlsaqmgn_jur NUMBER(15,2);
      vr_vlretsaq_fis NUMBER(15,2);
      vr_vlretsaq_jur NUMBER(15,2);
      vr_vldccdeb_fis NUMBER(15,2);
      vr_vldccdeb_jur NUMBER(15,2);
      vr_vlretdcc_fis NUMBER(15,2);
      vr_vlretdcc_jur NUMBER(15,2);
      vr_vlordpgt     NUMBER(15,2);
      vr_vlordret     NUMBER(15,2);
      
      -- Variaveis do XML
      vr_des_xml      CLOB;
      vr_diretorio    VARCHAR2(100);


    PROCEDURE pc_escreve_xml(pr_des_dados in VARCHAR2) is
    BEGIN
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
 
    BEGIN -- Inicio do programa principal

      --------------- VALIDACOES INICIAIS -----------------

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Abre o cursor de dados genericos
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper);
      FETCH cr_craptab INTO rw_craptab;
      
      -- Se encontrou registro
      IF cr_craptab%FOUND THEN
        vr_nrctabol := rw_craptab.dstextab;
      ELSE
        vr_nrctabol := 0;
      END IF;
      CLOSE cr_craptab;
        
      -- Atualiza Pl Table da tabela de historico (CRAPHIS)
      FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
              -- Vetor para armazenar os dados de resumo
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).inclasse := rw_craphis.inclasse;
      END LOOP;

      -- Inicializar o CLOB para armazenar os arquivos XML
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o arquivo XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>' ||
                       '<crps230>');

      -- Efetua repeticao sobre o periodo de apuracao da CPMF
      FOR rw_crapper IN cr_crapper(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        vr_dsperiod := to_char(rw_crapper.dtiniper,'dd/mm/yyyy') || ' A ' || to_char(rw_crapper.dtfimper,'dd/mm/yyyy');
        
        vr_vlaplfin_fis := 0; 
        vr_vlaplfin_jur := 0; 
        vr_vlbaschq_fis := 0;
        vr_vlbaschq_jur := 0;
        vr_vlretchq_fis := 0;
        vr_vlretchq_jur := 0;
        vr_vlbascsd_jur := 0;
        vr_vlbascsd_fis := 0;
        vr_vlopecrd_fis := 0;
        vr_vlopecrd_jur := 0;
        vr_vloutdeb_fis := 0;
        vr_vloutdeb_jur := 0;
        vr_vlpgtaut_fis := 0;
        vr_vlpgtaut_jur := 0;
        vr_vlretapl_fis := 0;                  
        vr_vlretapl_jur := 0;                  
        vr_vlretcsd_fis := 0; 
        vr_vlretcsd_jur := 0; 
        vr_vlretope_fis := 0;
        vr_vlretope_jur := 0;
        vr_vlretout_fis := 0;
        vr_vlretout_jur := 0;
        vr_vlretpgt_fis := 0; 
        vr_vlretpgt_jur := 0; 
        vr_vltrfmtl     := 0;
        vr_vlretinv     := 0;
        vr_vlretimo     := 0;
        vr_vlretdsp     := 0;
        vr_vlinvcco     := 0;
        vr_vlimocco     := 0;
        vr_vlestcri     := 0;
        vr_vldspcco     := 0;
        vr_vldebntr     := 0; 
        vr_vltrbcco     := 0;
        vr_vlrettrb     := 0;
        vr_vlcpmcps     := 0;
        vr_vlpesfis     := 0;
        vr_vlretfis     := 0;
        vr_vlpesjur     := 0;
        vr_vlretjur     := 0;
        vr_vlasscpm     := 0;
        vr_vlretass     := 0;
        vr_vlcpmncb     := 0;
        vr_vlcooper     := 0;
        vr_vlretcoo     := 0;
        vr_vlapurad     := 0;
        vr_vlcpmapu     := 0;
        vr_vlcalcul     := 0;
        vr_vlcpmcal     := 0;
        vr_vlbascmp     := 0;
        vr_vloutcop     := 0; 
        vr_vlsaqmgn_fis := 0; 
        vr_vlsaqmgn_jur := 0; 
        vr_vlretsaq_fis := 0;
        vr_vlretsaq_jur := 0;
        vr_vldccdeb_fis := 0;
        vr_vldccdeb_jur := 0;
        vr_vlretdcc_fis := 0;
        vr_vlretdcc_jur := 0;
        vr_vlordpgt     := 0;
        vr_vlordret     := 0;
        
        -- Efetua repeticao sobre os lancamentos de depositos a vista
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => pr_cdcooper,
                                     pr_dtiniper => rw_crapper.dtiniper,
                                     pr_dtfimper => rw_crapper.dtfimper) LOOP

          -- Se a classe de calculo de CPMF for igual a 0
          IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 0 THEN
             /* Acerto para tratar debitos de cheque salario que foram
                tributados indevidamente em marco e abril/2002 - Deborah */
            IF rw_craplcm.cdhistor = 43 and rw_craplcm.vldoipmf > 0 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlbaschq_fis := vr_vlbaschq_fis + rw_craplcm.vllanmto;
                vr_vlretchq_fis := vr_vlretchq_fis + rw_craplcm.vldoipmf;
              ELSIF rw_craplcm.inpessoa = 2 THEN -- Se for juridico
                vr_vlbaschq_jur := vr_vlbaschq_jur + rw_craplcm.vllanmto;
                vr_vlretchq_jur := vr_vlretchq_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSE
              CONTINUE;
            END IF; 
          END IF; -- Verificacao da classe igual a zero

          -- Se o indicador de isencao de CPMF nao for isento
          IF rw_craplcm.iniscpmf = 1 THEN
            IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse IN (10,110,20,30,40,50,90,120,130) THEN 
              vr_vldebntr := vr_vldebntr + rw_craplcm.vllanmto;
            END IF;
            CONTINUE;
          END IF;

          -- Inst.inan.outras cooperativas
          IF rw_craplcm.iniscpmf = 2 THEN  
            IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse IN (10,110,20,30,40,50,90,120,130) THEN
              vr_vloutcop := vr_vloutcop + rw_craplcm.vllanmto;
            END IF;
            CONTINUE;
          END IF;

          -- Se for pessoa fisica ou juridica (exclui as cooperativas)
          IF rw_craplcm.inpessoa < 3 THEN
            IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 10 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlbaschq_fis := vr_vlbaschq_fis + rw_craplcm.vllanmto;
                vr_vlretchq_fis := vr_vlretchq_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlbaschq_jur := vr_vlbaschq_jur + rw_craplcm.vllanmto;
                vr_vlretchq_jur := vr_vlretchq_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 20 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlpgtaut_fis := vr_vlpgtaut_fis + rw_craplcm.vllanmto;
                vr_vlretpgt_fis := vr_vlretpgt_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlpgtaut_jur := vr_vlpgtaut_jur + rw_craplcm.vllanmto;
                vr_vlretpgt_jur := vr_vlretpgt_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 30 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlopecrd_fis := vr_vlopecrd_fis + rw_craplcm.vllanmto;
                vr_vlretope_fis := vr_vlretope_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlopecrd_jur := vr_vlopecrd_jur + rw_craplcm.vllanmto;
                vr_vlretope_jur := vr_vlretope_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 40 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlaplfin_fis := vr_vlaplfin_fis + rw_craplcm.vllanmto;
                vr_vlretapl_fis := vr_vlretapl_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlaplfin_jur := vr_vlaplfin_jur + rw_craplcm.vllanmto;
                vr_vlretapl_jur := vr_vlretapl_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 50 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vloutdeb_fis := vr_vloutdeb_fis + rw_craplcm.vllanmto;
                vr_vlretout_fis := vr_vlretout_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vloutdeb_jur := vr_vloutdeb_jur + rw_craplcm.vllanmto;
                vr_vlretout_jur := vr_vlretout_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 60 THEN
              vr_vltrfmtl := vr_vltrfmtl + rw_craplcm.vllanmto;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 70 THEN
              vr_vlestcri := vr_vlestcri + rw_craplcm.vllanmto;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 80 THEN
              vr_vldebntr := vr_vldebntr + rw_craplcm.vllanmto;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 90 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlbascsd_fis := vr_vlbascsd_fis + rw_craplcm.vllanmto;
                vr_vlretcsd_fis := vr_vlretcsd_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlbascsd_jur := vr_vlbascsd_jur + rw_craplcm.vllanmto;
                vr_vlretcsd_jur := vr_vlretcsd_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 100 THEN
              vr_vlcpmcps := vr_vlcpmcps + rw_craplcm.vldoipmf;
              vr_vlbascmp := vr_vlbascmp + rw_craplcm.vllanmto;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 110 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                IF rw_craplcm.nrdocmto < 8000051 THEN
                  vr_vlbaschq_fis := vr_vlbaschq_fis + rw_craplcm.vllanmto;
                ELSE
                  vr_vlbaschq_fis := vr_vlbaschq_fis + rw_craplcm.vllanmto + rw_craplcm.vldoipmf;
                END IF;
                vr_vlretchq_fis := vr_vlretchq_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                IF rw_craplcm.nrdocmto < 8000051 THEN
                  vr_vlbaschq_jur := vr_vlbaschq_jur + rw_craplcm.vllanmto;
                ELSE
                  vr_vlbaschq_jur := vr_vlbaschq_jur + rw_craplcm.vllanmto + rw_craplcm.vldoipmf;
                END IF;
                vr_vlretchq_jur := vr_vlretchq_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 120 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vlsaqmgn_fis := vr_vlsaqmgn_fis + rw_craplcm.vllanmto;
                vr_vlretsaq_fis := vr_vlretsaq_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vlsaqmgn_jur := vr_vlsaqmgn_jur + rw_craplcm.vllanmto;
                vr_vlretsaq_jur := vr_vlretsaq_jur + rw_craplcm.vldoipmf;
              END IF;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 130 THEN
              IF rw_craplcm.inpessoa = 1 THEN -- Se for pessoa fisica
                vr_vldccdeb_fis := vr_vldccdeb_fis + rw_craplcm.vllanmto;
                vr_vlretdcc_fis := vr_vlretdcc_fis + rw_craplcm.vldoipmf;
              ELSE -- Se for juridico
                vr_vldccdeb_jur := vr_vldccdeb_jur + rw_craplcm.vllanmto;
                vr_vlretdcc_jur := vr_vlretdcc_jur + rw_craplcm.vldoipmf;
              END IF;
            END IF;
          ELSE -- Se inpessoa = 3
            IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 100 THEN
              vr_vlcpmcps := vr_vlcpmcps + rw_craplcm.vldoipmf;
              vr_vlbascmp := vr_vlbascmp + rw_craplcm.vllanmto;
            ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inclasse = 80 THEN
              vr_vldebntr := vr_vldebntr + rw_craplcm.vllanmto;
            END IF;
            
            IF rw_craplcm.nrdconta = 850004 OR 
               rw_craplcm.nrdconta = 847810 OR
               rw_craplcm.nrdconta = 50008   THEN /* Concredi */
              IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse NOT IN (60,70,80,100) THEN                                 
                vr_vldspcco := vr_vldspcco + rw_craplcm.vllanmto;
                vr_vlretdsp := vr_vlretdsp + rw_craplcm.vldoipmf;
              END IF;
            ELSIF rw_craplcm.nrdconta = 850012 THEN
              IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse NOT IN (60,70,80,100) THEN
                vr_vlinvcco := vr_vlinvcco + rw_craplcm.vllanmto;
                vr_vlretinv := vr_vlretinv + rw_craplcm.vldoipmf;
              END IF;
            ELSIF rw_craplcm.nrdconta = 850020 THEN
              IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse NOT IN (60,70,80,100) THEN                              
                vr_vlimocco := vr_vlimocco + rw_craplcm.vllanmto;
                vr_vlretimo := vr_vlretimo + rw_craplcm.vldoipmf;
              END IF;
            ELSE
              IF vr_tab_craphis(rw_craplcm.cdhistor).inclasse NOT IN (60,70,80,100) THEN
                vr_vltrbcco := vr_vltrbcco + rw_craplcm.vllanmto;
                vr_vlrettrb := vr_vlrettrb + rw_craplcm.vldoipmf;
              END IF;
            END IF;
          END IF; /* inpessoa < 3 */


        END LOOP; -- cursor sobre a CRAPLCM


        /* Lancamentos do INSS - BANCOOB */
        rw_craplpi := NULL;
        OPEN cr_craplpi(pr_cdcooper => pr_cdcooper,
                        pr_dtiniper => rw_crapper.dtiniper,
                        pr_dtfimper => rw_crapper.dtfimper);
        FETCH cr_craplpi INTO rw_craplpi;
        CLOSE cr_craplpi;
        vr_vlordpgt := vr_vlordpgt + nvl(rw_craplpi.vllanmto,0);
        vr_vlordret := vr_vlordret + nvl(rw_craplpi.vldoipmf,0);

        vr_vlpesfis := vr_vlbaschq_fis + vr_vlpgtaut_fis + 
                       vr_vlopecrd_fis + vr_vlaplfin_fis +
                       vr_vloutdeb_fis + vr_vlbascsd_fis +
                       vr_vlsaqmgn_fis + vr_vldccdeb_fis;

        vr_vlretfis := vr_vlretchq_fis + vr_vlretpgt_fis +
                       vr_vlretope_fis + vr_vlretapl_fis + 
                       vr_vlretout_fis + vr_vlretcsd_fis +
                       vr_vlretsaq_fis + vr_vlretdcc_fis;
 
        vr_vlpesjur := vr_vlbaschq_jur + vr_vlpgtaut_jur + 
                       vr_vlopecrd_jur + vr_vlaplfin_jur +
                       vr_vloutdeb_jur + vr_vlbascsd_jur + 
                       vr_vlsaqmgn_jur + vr_vldccdeb_jur;

        vr_vlretjur := vr_vlretchq_jur + vr_vlretpgt_jur +
                       vr_vlretope_jur + vr_vlretapl_jur + 
                       vr_vlretout_jur + vr_vlretcsd_jur +
                       vr_vlretsaq_jur + vr_vlretdcc_jur;
                          
        vr_vlasscpm := vr_vlpesfis + vr_vlpesjur;
                          
        vr_vlretass := vr_vlretfis + vr_vlretjur;
                          
        vr_vlcooper := vr_vldspcco + vr_vlinvcco + 
                       vr_vlimocco + vr_vltrbcco;
                          
        vr_vlretcoo := vr_vlretdsp + vr_vlretinv + 
                       vr_vlretimo + vr_vlrettrb;
                          
        vr_vlcpmncb := vr_vltrfmtl + vr_vlestcri +
                       vr_vldebntr + vr_vlcpmcps +
                       vr_vloutcop;

        vr_vlapurad := vr_vlcooper + vr_vlasscpm + vr_vlordpgt;
        vr_vlcpmapu := vr_vlretcoo + vr_vlretass + vr_vlordret;
        vr_vlcalcul := vr_vlapurad - vr_vlbascmp + (rw_crapper.vlrbscps * -1);
        vr_vlcpmcal := vr_vlcpmapu - vr_vlcpmcps + (rw_crapper.vlrcpcps * -1);
        
        --------------------------- GERA O XML ------------------------------
        pc_escreve_xml('<crapper>'||
                         '<periodo>'     ||vr_dsperiod                                ||'</periodo>' ||
                         '<vlordpgt>'    ||to_char(vr_vlordpgt,'fm999G999G990D00')    ||'</vlordpgt>'||
                         '<vlordret>'    ||to_char(vr_vlordret,'fm999G999G990D00')    ||'</vlordret>'||
                         '<vlbaschq_fis>'||to_char(vr_vlbaschq_fis,'fm999G999G990D00')||'</vlbaschq_fis>'||
                         '<vlretchq_fis>'||to_char(vr_vlretchq_fis,'fm999G999G990D00')||'</vlretchq_fis>'||
                         '<vlbaschq_jur>'||to_char(vr_vlbaschq_jur,'fm999G999G990D00')||'</vlbaschq_jur>'||
                         '<vlretchq_jur>'||to_char(vr_vlretchq_jur,'fm999G999G990D00')||'</vlretchq_jur>'||
                         '<vlpgtaut_fis>'||to_char(vr_vlpgtaut_fis,'fm999G999G990D00')||'</vlpgtaut_fis>'||
                         '<vlretpgt_fis>'||to_char(vr_vlretpgt_fis,'fm999G999G990D00')||'</vlretpgt_fis>'||
                         '<vlpgtaut_jur>'||to_char(vr_vlpgtaut_jur,'fm999G999G990D00')||'</vlpgtaut_jur>'||
                         '<vlretpgt_jur>'||to_char(vr_vlretpgt_jur,'fm999G999G990D00')||'</vlretpgt_jur>'||
                         '<vlopecrd_fis>'||to_char(vr_vlopecrd_fis,'fm999G999G990D00')||'</vlopecrd_fis>'||
                         '<vlretope_fis>'||to_char(vr_vlretope_fis,'fm999G999G990D00')||'</vlretope_fis>'||
                         '<vlopecrd_jur>'||to_char(vr_vlopecrd_jur,'fm999G999G990D00')||'</vlopecrd_jur>'||
                         '<vlretope_jur>'||to_char(vr_vlretope_jur,'fm999G999G990D00')||'</vlretope_jur>'||
                         '<vlaplfin_fis>'||to_char(vr_vlaplfin_fis,'fm999G999G990D00')||'</vlaplfin_fis>'||
                         '<vlretapl_fis>'||to_char(vr_vlretapl_fis,'fm999G999G990D00')||'</vlretapl_fis>'||
                         '<vlaplfin_jur>'||to_char(vr_vlaplfin_jur,'fm999G999G990D00')||'</vlaplfin_jur>'||
                         '<vlretapl_jur>'||to_char(vr_vlretapl_jur,'fm999G999G990D00')||'</vlretapl_jur>'||
                         '<vlsaqmgn_fis>'||to_char(vr_vlsaqmgn_fis,'fm999G999G990D00')||'</vlsaqmgn_fis>'||
                         '<vlretsaq_fis>'||to_char(vr_vlretsaq_fis,'fm999G999G990D00')||'</vlretsaq_fis>'||
                         '<vlsaqmgn_jur>'||to_char(vr_vlsaqmgn_jur,'fm999G999G990D00')||'</vlsaqmgn_jur>'||
                         '<vlretsaq_jur>'||to_char(vr_vlretsaq_jur,'fm999G999G990D00')||'</vlretsaq_jur>'||
                         '<vldccdeb_fis>'||to_char(vr_vldccdeb_fis,'fm999G999G990D00')||'</vldccdeb_fis>'||
                         '<vlretdcc_fis>'||to_char(vr_vlretdcc_fis,'fm999G999G990D00')||'</vlretdcc_fis>'||
                         '<vldccdeb_jur>'||to_char(vr_vldccdeb_jur,'fm999G999G990D00')||'</vldccdeb_jur>'||
                         '<vlretdcc_jur>'||to_char(vr_vlretdcc_jur,'fm999G999G990D00')||'</vlretdcc_jur>'||
                         '<vloutdeb_fis>'||to_char(vr_vloutdeb_fis,'fm999G999G990D00')||'</vloutdeb_fis>'||
                         '<vlretout_fis>'||to_char(vr_vlretout_fis,'fm999G999G990D00')||'</vlretout_fis>'||
                         '<vloutdeb_jur>'||to_char(vr_vloutdeb_jur,'fm999G999G990D00')||'</vloutdeb_jur>'||
                         '<vlretout_jur>'||to_char(vr_vlretout_jur,'fm999G999G990D00')||'</vlretout_jur>'||
                         '<vlbascsd_fis>'||to_char(vr_vlbascsd_fis,'fm999G999G990D00')||'</vlbascsd_fis>'||
                         '<vlretcsd_fis>'||to_char(vr_vlretcsd_fis,'fm999G999G990D00')||'</vlretcsd_fis>'||
                         '<vlbascsd_jur>'||to_char(vr_vlbascsd_jur,'fm999G999G990D00')||'</vlbascsd_jur>'||
                         '<vlretcsd_jur>'||to_char(vr_vlretcsd_jur,'fm999G999G990D00')||'</vlretcsd_jur>'||
                         '<vlpesfis>'    ||to_char(vr_vlpesfis,'fm999G999G990D00')    ||'</vlpesfis>'||
                         '<vlretfis>'    ||to_char(vr_vlretfis,'fm999G999G990D00')    ||'</vlretfis>'||
                         '<vlpesjur>'    ||to_char(vr_vlpesjur,'fm999G999G990D00')    ||'</vlpesjur>'||
                         '<vlretjur>'    ||to_char(vr_vlretjur,'fm999G999G990D00')    ||'</vlretjur>'||
                         '<vlasscpm>'    ||to_char(vr_vlasscpm,'fm999G999G990D00')    ||'</vlasscpm>'||
                         '<vlretass>'    ||to_char(vr_vlretass,'fm999G999G990D00')    ||'</vlretass>'||
                         '<vldspcco>'    ||to_char(vr_vldspcco,'fm999G999G990D00')    ||'</vldspcco>'||
                         '<vlretdsp>'    ||to_char(vr_vlretdsp,'fm999G999G990D00')    ||'</vlretdsp>'||
                         '<vlinvcco>'    ||to_char(vr_vlinvcco,'fm999G999G990D00')    ||'</vlinvcco>'||
                         '<vlretinv>'    ||to_char(vr_vlretinv,'fm999G999G990D00')    ||'</vlretinv>'||
                         '<vlimocco>'    ||to_char(vr_vlimocco,'fm999G999G990D00')    ||'</vlimocco>'||
                         '<vlretimo>'    ||to_char(vr_vlretimo,'fm999G999G990D00')    ||'</vlretimo>'||
                         '<vltrbcco>'    ||to_char(vr_vltrbcco,'fm999G999G990D00')    ||'</vltrbcco>'||
                         '<vlrettrb>'    ||to_char(vr_vlrettrb,'fm999G999G990D00')    ||'</vlrettrb>'||
                         '<vlcooper>'    ||to_char(vr_vlcooper,'fm999G999G990D00')    ||'</vlcooper>'||
                         '<vlretcoo>'    ||to_char(vr_vlretcoo,'fm999G999G990D00')    ||'</vlretcoo>'||
                         '<vloutcop>'    ||to_char(vr_vloutcop,'fm999G999G990D00')    ||'</vloutcop>'||
                         '<vltrfmtl>'    ||to_char(vr_vltrfmtl,'fm999G999G990D00')    ||'</vltrfmtl>'||
                         '<vlestcri>'    ||to_char(vr_vlestcri,'fm999G999G990D00')    ||'</vlestcri>'||
                         '<vldebntr>'    ||to_char(vr_vldebntr,'fm999G999G990D00')    ||'</vldebntr>'||
                         '<vlcpmcps>'    ||to_char(vr_vlcpmcps,'fm999G999G990D00')    ||'</vlcpmcps>'||
                         '<vlcpmncb>'    ||to_char(vr_vlcpmncb,'fm999G999G990D00')    ||'</vlcpmncb>'||
                         '<vlordpgt2>'   ||to_char(vr_vlordpgt,'fm999G999G990D00')    ||'</vlordpgt2>'||
                         '<vlordret2>'   ||to_char(vr_vlordret,'fm999G999G990D00')    ||'</vlordret2>'||
                         '<vlasscpm2>'   ||to_char(vr_vlasscpm,'fm999G999G990D00')    ||'</vlasscpm2>'||
                         '<vlretass2>'   ||to_char(vr_vlretass,'fm999G999G990D00')    ||'</vlretass2>'||
                         '<vlcooper2>'   ||to_char(vr_vlcooper,'fm999G999G990D00')    ||'</vlcooper2>'||
                         '<vlretcoo2>'   ||to_char(vr_vlretcoo,'fm999G999G990D00')    ||'</vlretcoo2>'||
                         '<vlapurad>'    ||to_char(vr_vlapurad,'fm999G999G990D00')    ||'</vlapurad>'||
                         '<vlcpmapu>'    ||to_char(vr_vlcpmapu,'fm999G999G990D00')    ||'</vlcpmapu>'||
                         '<vlbascmp>'    ||to_char(vr_vlbascmp,'fm999G999G990D00')||'-' ||'</vlbascmp>'||
                         '<vlcpmcps2>'   ||to_char(vr_vlcpmcps,'fm999G999G990D00')||'-' ||'</vlcpmcps2>'||
                         '<vlrbscps>'    ||to_char(rw_crapper.vlrbscps,'fm999G999G990D00')||'</vlrbscps>'||
                         '<vlrcpcps>'    ||to_char(rw_crapper.vlrcpcps,'fm999G999G990D00')||'</vlrcpcps>'||
                         '<vlcalcul>'    ||to_char(vr_vlcalcul,'fm999G999G990D00')    ||'</vlcalcul>'||
                         '<vlcpmcal>'    ||to_char(vr_vlcpmcal,'fm999G999G990D00')    ||'</vlcpmcal>'||
                      '</crapper>');
        
        -------------------- FIM DA GERACAO DO XML --------------------------
             
        -- Atualiza tabela de periodos de apuracao da CPMF
        BEGIN
          UPDATE crapper
             SET crapper.vlbaschq##1 = vr_vlbaschq_fis,
                 crapper.vlbaschq##2 = vr_vlbaschq_jur,
                 crapper.vlretbas##1 = vr_vlretchq_fis,
                 crapper.vlretbas##2 = vr_vlretchq_jur,
                 crapper.vlpgtaut##1 = vr_vlpgtaut_fis,
                 crapper.vlpgtaut##2 = vr_vlpgtaut_jur,
                 crapper.vlretpgt##1 = vr_vlretpgt_fis,
                 crapper.vlretpgt##2 = vr_vlretpgt_jur,
                 crapper.vlopecrd##1 = vr_vlopecrd_fis,
                 crapper.vlopecrd##2 = vr_vlopecrd_jur,
                 crapper.vlretope##1 = vr_vlretope_fis,
                 crapper.vlretope##2 = vr_vlretope_jur,
                 crapper.vlaplfin##1 = vr_vlaplfin_fis,
                 crapper.vlaplfin##2 = vr_vlaplfin_jur,
                 crapper.vlretapl##1 = vr_vlretapl_fis,
                 crapper.vlretapl##2 = vr_vlretapl_jur,
                 crapper.vloutdeb##1 = vr_vloutdeb_fis,
                 crapper.vloutdeb##2 = vr_vloutdeb_jur,
                 crapper.vlretout##1 = vr_vlretout_fis,
                 crapper.vlretout##2 = vr_vlretout_jur,
                 crapper.vlsaqmgn##1 = vr_vlsaqmgn_fis,
                 crapper.vlsaqmgn##2 = vr_vlsaqmgn_jur,
                 crapper.vlretsaq##1 = vr_vlretsaq_fis,
                 crapper.vlretsaq##2 = vr_vlretsaq_jur,
                 crapper.vldccdeb##1 = vr_vldccdeb_fis,
                 crapper.vldccdeb##2 = vr_vldccdeb_jur,
                 crapper.vlretdcc##1 = vr_vlretdcc_fis,
                 crapper.vlretdcc##2 = vr_vlretdcc_jur,
                 crapper.vlbascsd##1 = vr_vlbascsd_fis,
                 crapper.vlbascsd##2 = vr_vlbascsd_jur,
                 crapper.vlretcsd##1 = vr_vlretcsd_fis,
                 crapper.vlretcsd##2 = vr_vlretcsd_jur,
                 crapper.vltrfmtl = vr_vltrfmtl,
                 crapper.vlestcri = vr_vlestcri,
                 crapper.vldebntr = vr_vldebntr,
                 crapper.vldspcco = vr_vldspcco,
                 crapper.vlretdsp = vr_vlretdsp,
                 crapper.vlinvcco = vr_vlinvcco,
                 crapper.vlretinv = vr_vlretinv,
                 crapper.vlimocco = vr_vlimocco,
                 crapper.vlretimo = vr_vlretimo,
                 crapper.vltrbcco = vr_vltrbcco,
                 crapper.vlrettrb = vr_vlrettrb,
                 crapper.vlcpmcps = vr_vlcpmcps,
                 crapper.vloutcop = vr_vloutcop
           WHERE ROWID = rw_crapper.rowid;
        EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := ' Erro ao atualizar a tabela CRAPPER: ' ||SQLERRM;
             RAISE vr_exc_saida;
        END;

      END LOOP; -- Cursor sobre a CRAPPER
      
      -- Finaliza o no principal
      pc_escreve_xml('</crps230>');

      -- Verifica se teve dados para gerar
      IF vr_dsperiod IS NOT NULL THEN
        
        -- Busca o diretorio para geracao do relatorio
        vr_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                           ,pr_cdcooper => pr_cdcooper) || '/rl';
        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/crps230/crapper',  --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl181.jasper',    --> Arquivo de layout do iReport
                                    pr_dsparams  => NULL,                --> nao enviar parametros
                                    pr_dsarqsaid =>  vr_diretorio||'/crrl181.lst', --> Arquivo final
                                    pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                    pr_qtcoluna  => 132,                  --> Quantidade de colunas
                                    pr_sqcabrel  => 1,                   --> Sequencia do cabecalho
                                    pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                    pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                    pr_des_erro  => vr_dscritic);        --> Saida com erro

        -- Verifica se ocorreu erro na solicitacao do relatorio
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

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

  END pc_crps230;
/

