PL/SQL Developer Test script 3.0
1956
DECLARE
  -- Buscar data base para transacoes com contas migradas no periodo da migracao
  vr_dtcxtmig DATE;
  vr_dscritic varchar2(5000);
  vr_cdcritic number(10);
  vr_dsmsglog VARCHAR2(4000); -- Mensagem de log
  
PROCEDURE pc_proces_arq_cet_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                     ,pr_dtmvtolt IN DATE                  --> Data Execução
                                     ,pr_dtcxtmig IN VARCHAR2              --> DAta contas migradas
                                     ,pr_nrseqarq in number                --> Sequencia do arquivo
                                     ,pr_nrseqexe in number                --> Sequencia da execucao
                                     ,pr_idparale IN NUMBER                --> Indicador de processo paralelo
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* .............................................................................

    Programa: pc_proces_arq_cet_bancoob
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Andreatta - Mouts
    Data    : Agosto/18.                    Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.

    Objetivo  : Conciliar débitos dos Cartões de Crédito BANCOOB/CABAL.
                Rotina separada para processamento paralelo por porcões do arquivo

    Observacao: -----

    Alteracoes:               
                             
    ....................................................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

      -- Extração dados XML
      vr_cdcopban   NUMBER;
      vr_nrdconta   crapass.nrdconta%type;
      vr_flgrejei   NUMBER;
      vr_cdprogra   VARCHAR2(10) := 'CRPS670';
      
      -- Numero do documento
      vr_nrdocmto   VARCHAR2(50);
      vr_crialcmt   BOOLEAN;
      vr_criardcb    BOOLEAN;
      vr_dthstran   VARCHAR2(10);
      vr_nsuredec   VARCHAR2(6);
      vr_nrseqdig_lot craplot.nrseqdig%TYPE;
      vr_cdhistor_ori craphcb.cdhistor%TYPE;
      vr_indebcre   VARCHAR2(1);
      vr_cdtrnbcb   VARCHAR2(4);
      vr_cdpesqbb   VARCHAR2(50);
      vr_dtmvtolt   DATE;
      
      vr_cdbccxlt   constant INTEGER := 100;
      vr_nrdolote   constant INTEGER := 6902;
      vr_tipostaa   INTEGER;

      vr_tpmensag   VARCHAR2(4);
      vr_cdcrimsg   VARCHAR2(2);

      vr_tpmsg200   BOOLEAN;
      vr_tpmsg220   BOOLEAN;
      vr_tpmsg420   BOOLEAN;

      vr_cdhistor   INTEGER;
      vr_vldtrans   craplcm.vllanmto%TYPE;
      vr_cdorigem   craplcm.cdorigem%TYPE;
      vr_dtmovtoo   craplcm.dtmvtolt%TYPE;
      vr_cdhistor_off INTEGER;
      vr_cdhistor_on  INTEGER;
      vr_dshistor_off VARCHAR2(100);
      vr_dshistor_on  VARCHAR2(100);
      vr_indebcre_on  Varchar2(1);
      vr_indebcre_off VARCHAR2(1);
      vr_dshistor_ori VARCHAR2(100);
      vr_flgdebcc   INTEGER;
      vr_cdtrnbcb_ori INTEGER;      
      vr_dstrnbcb VARCHAR2(100);
      vr_nrdlinha INTEGER := 0;
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_rejeitado EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      --index da temp-table do relatorio
      vr_index      VARCHAR2(38);   
      vr_idxlcm     VARCHAR2(500);
      vr_idxdcb     VARCHAR2(500);

      vr_qtacobra INTEGER := 0;
      vr_fliseope INTEGER := 0;
      
      -- data base para transacoes no periodo da migracao
      vr_dtcxtmig date;

      -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
      vr_idlog_ini_par tbgen_prglog.idprglog%type;

      ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
     
        
      -- Definicao de temptable para registros da craplcm
      TYPE typ_tab_craplcm IS
        TABLE OF craplcm%ROWTYPE
        INDEX BY VARCHAR2(500); --CDCOOPER(10) + DTMVTOLT(8) + CDAGENCI(5) + CDBCCXLT(5) + NRDOLOTE(10) + NRDCTABB(10) + NRDOCMTO(25)
      vr_tab_craplcm typ_tab_craplcm;

      TYPE typ_rec_crapdcb
       IS RECORD(det       crapdcb%ROWTYPE,
                 ROWID_dcb ROWID,
                 operacao  VARCHAR2(1));

      -- Definicao de temptable para registros da crapdcb
      TYPE typ_tab_crapdcb IS
        TABLE OF typ_rec_crapdcb--crapdcb%ROWTYPE
        INDEX BY VARCHAR2(500); -- TPMENSAG(5), NRNSUCAP(10), DTDTRGMT(8), HRDTRGMT(10), CDCOOPER(10), NRDCONTA(10)
      vr_tab_crapdcb typ_tab_crapdcb;

      -- DAdos de Lote
      type typ_reg_craplot is record(cdcooper craplot.cdcooper%type
                                    ,cdagenci craplot.cdagenci%type
                                    ,nrseqdig craplot.nrseqdig%type
                                    ,qtcompln craplot.qtcompln%type
                                    ,qtinfoln craplot.qtinfoln%type
                                    ,vlcompdb craplot.vlcompdb%type
                                    ,vlinfodb craplot.vlinfodb%type);
      type typ_tab_craplot is table of typ_reg_craplot index by varchar2(8);
      vr_tab_craplot typ_tab_craplot;
      vr_idx_lot varchar2(8);
      
      ------------------------------- CURSORES ---------------------------------
      
      -- Cursor para buscar valores para relatorio      
      cursor cr_work_arq(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_nrseqexe    tbgen_batch_relatorio_wrk.cdagenci%type
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
        select a.dschave  nmarquiv
              ,a.nrdconta nrdlinha
              ,a.dscritic des_text
          from tbgen_batch_relatorio_wrk a
         where a.cdcooper = 3
           and a.cdagenci in (34)
           and a.cdprograma = 'CRPS670'
           and a.dsrelatorio = 'DADOS_ARQ'
           and a.dtmvtolt = '04/04/2019'
           and a.dscritic like '%50213%'
           and SUBSTR(a.dscritic, 1, 5) not in ('CEXT0', 'CEXT9')
         order by a.nrdconta;

      -- busca registro de Debito efetuado com cartão Bancoob
      CURSOR cr_crapdcb_200(pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                             pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE,
                             pr_hrdtrgmt IN crapdcb.hrdtrgmt%TYPE,
                             pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrdconta IN crapdcb.nrdconta%TYPE,
                             pr_cdhistor IN crapdcb.cdhistor%TYPE) IS
        SELECT dcb.rowid,
               dcb.cdhistor
          FROM crapdcb dcb
         WHERE dcb.cdcooper = pr_cdcooper   
           AND dcb.nrdconta = pr_nrdconta   
           AND upper(dcb.tpmensag) = '0200' 
           AND dcb.nrnsuori = pr_nrnsucap   
           AND dcb.dtdtrgmt = pr_dtdtrgmt   
           AND dcb.hrdtrgmt = pr_hrdtrgmt  
           AND dcb.cdhistor = pr_cdhistor ;
      rw_crapdcb_200 cr_crapdcb_200%ROWTYPE;
      
      -- busca registro de Credito efetuado com cartão Bancoob
      CURSOR cr_crapdcb_400 (pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                             pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE,
                             pr_hrdtrgmt IN crapdcb.hrdtrgmt%TYPE,
                             pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrdconta IN crapdcb.nrdconta%TYPE,
                             pr_cdhistor IN crapdcb.cdhistor%TYPE) IS
        SELECT dcb.rowid
          FROM crapdcb dcb
         WHERE dcb.cdcooper = pr_cdcooper  
           AND dcb.nrdconta = pr_nrdconta  
           AND upper(dcb.tpmensag) = '0400'
           AND dcb.nrnsuori = pr_nrnsucap  
           AND dcb.dtdtrgmt = pr_dtdtrgmt  
           AND dcb.hrdtrgmt = pr_hrdtrgmt  
           AND dcb.cdhistor = pr_cdhistor ;
      rw_crapdcb_400 cr_crapdcb_400%ROWTYPE;
      
      -- Debitos e Creditos Bancoob
       CURSOR cr_crapdcb (pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                          pr_cdcooper IN crapass.cdcooper%TYPE,
                          pr_nrdconta IN crapdcb.nrdconta%TYPE,
                          pr_vldtrans IN crapdcb.vldtrans%TYPE,
                          pr_nrseqarq IN crapdcb.nrseqarq%TYPE,
                          pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE) IS
        SELECT dcb.dtmvtolt,
               dcb.tpmensag,
               dcb.tpdtrans,
               dcb.vldtrans,
               dcb.nrnsucap,
               dcb.nrnsuori,
               dcb.cdhistor,
               dcb.cdtrresp
          FROM crapdcb dcb
        WHERE dcb.cdcooper = pr_cdcooper
          AND dcb.nrdconta = pr_nrdconta
          AND dcb.nrnsuori = pr_nrnsucap
          AND upper(dcb.tpmensag) in ('0200','0220','0420') 
          AND dcb.vldtrans = pr_vldtrans 
          AND(dcb.nrseqarq = 1 OR ( dcb.nrseqarq < pr_nrseqarq AND dcb.dtdtrgmt = pr_dtdtrgmt )) -- considerar caso venha mais de uma vez a conciliacao
          ORDER BY dcb.tpmensag ASC;
      rw_crapdcb cr_crapdcb%ROWTYPE;

      -- Cursor para retornar cooperativa com base agencia bancoob
      CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.flgativo
        FROM crapcop cop
       WHERE cop.cdagebcb = pr_cdagebcb;
      rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

       -- cursor para busca dos vinculos da transacao bancoob
      CURSOR cr_craphcb (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE) IS
      SELECT hcb.flgdebcc
            ,hcb.cdtrnbcb
            ,hcb.dstrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
        FROM craphcb hcb,
             tbcrd_his_vinculo_bancoob tbcrd
       WHERE hcb.cdtrnbcb = pr_cdtrnbcb
         AND tbcrd.cdtrnbcb = hcb.cdtrnbcb;
      rw_craphcb cr_craphcb%ROWTYPE;
      
      -- cursor para busca dos vinculos da transacao bancoob de estorno
      CURSOR cr_craphcb_est (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE) IS
      SELECT hcb.flgdebcc
            ,hcb.cdtrnbcb
            ,hcb.dstrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
        FROM craphcb hcb,
             tbcrd_his_vinculo_bancoob tbcrd
       WHERE hcb.cdtrnbcb = pr_cdtrnbcb
         AND tbcrd.cdtrnbcb = hcb.cdtrnbcb
         AND tbcrd.tphistorico = 1; -- Offline
      rw_craphcb_est cr_craphcb_est%ROWTYPE;
      
      -- Busca de historicos
      CURSOR cr_craphis(pr_cdhistor IN craphis.cdhistor%TYPE) IS
      SELECT his.cdhistor
            ,his.dshistor
            ,his.indebcre
        FROM craphis his
       WHERE his.cdcooper = 3
         AND his.cdhistor = pr_cdhistor;
     rw_craphis cr_craphis%ROWTYPE;

      -- Buscar informações do associado
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%type,
                         pr_nrdconta crapass.nrdconta%type) IS
        SELECT ass.nrdconta,
               ass.cdagenci,
               ass.inpessoa,
               age.nmresage
          FROM crapass ass, crapage age
         WHERE ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%rowtype;
      
      -- Buscar informações do associado na nova coop (para incorporacao/migracao)
      CURSOR cr_crapass_dest (pr_cdcooper crapcop.cdcooper%type,
                              pr_nrdconta crapass.nrdconta%type) IS
        SELECT ass.cdcooper,
               ass.nrdconta,
               ass.cdagenci,
               ass.inpessoa,
               age.nmresage,
               cop.nmrescop,
               cop.cdagebcb
          FROM crapass ass, crapcop cop, crapage age
         WHERE ass.cdcooper = cop.cdcooper 
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass_dest cr_crapass_dest%rowtype;

      -- Verifica se houve lançamento no dia
      CURSOR cr_craplcm_dia(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_cdpesqbb IN VARCHAR2,
                        pr_nsuredec IN VARCHAR2,
                        pr_cdhistor IN crapdcb.cdhistor%TYPE,
                        pr_datamovt IN DATE,
                        pr_vldtrans IN craplcm.vllanmto%TYPE) IS
        SELECT lcm.nrdocmto,
               lcm.cdorigem,
               lcm.dtmvtolt
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.dtmvtolt = pr_datamovt
           AND lcm.cdbccxlt = 100
           AND lcm.nrdolote = 6902
           AND lcm.cdhistor = pr_cdhistor
           AND lcm.cdpesqbb = pr_cdpesqbb -- NUM CARTÃO
           AND TRIM(substr(lcm.nrdocmto,4,6))= pr_nsuredec --NSU REDE
           AND lcm.vllanmto = pr_vldtrans;
      rw_craplcm_dia cr_craplcm_dia%ROWTYPE;

       -- Verifica se houve lançamento
      CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_cdpesqbb IN VARCHAR2,
                        pr_nsuredec IN VARCHAR2,
                        --pr_tpmensag IN crapdcb.nrnsucap%TYPE,
                        pr_cdhistor IN crapdcb.cdhistor%TYPE,
                        pr_vldtrans IN craplcm.vllanmto%TYPE) IS
        SELECT lcm.nrdocmto,
               lcm.vllanmto,
               lcm.cdhistor,
               lcm.cdorigem,
               lcm.dtmvtolt
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdbccxlt = 100
           AND lcm.nrdolote = 6902
           AND lcm.cdhistor = pr_cdhistor
           AND TRIM(lcm.cdpesqbb) = TRIM(pr_cdpesqbb) --NUM CARTÃO
           AND TRIM(substr(lcm.nrdocmto,4,6)) = LPAD(pr_nsuredec,6,0)--NSU REDE
          AND lcm.vllanmto = pr_vldtrans;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- Checagem de transferencia de contas
      CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                         pr_nrctaant IN craptco.nrctaant%TYPE) IS
        SELECT tco.nrdconta,
               tco.cdcooper
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcopant
           AND tco.nrctaant = pr_nrctaant;
      rw_craptco cr_craptco%ROWTYPE;

      -- Gerar dados para o relatório
      procedure pc_insere_relato(pr_idxdados in varchar2,
                                 pr_cdcopreg in crapcop.cdcooper%TYPE,
                                 pr_nmrescop in crapcop.nmrescop%TYPE,
                                 pr_cdagenci in crapage.cdagenci%TYPE,
                                 pr_nmresage in crapage.nmresage%TYPE,
                                 pr_nrdconta in VARCHAR2,
                                 pr_cdtrnbcb in craphcb.cdtrnbcb%type,
                                 pr_dstrnbcb in craphcb.dstrnbcb%type,
                                 pr_cdhistor in craphis.cdhistor%type,
                                 pr_dshistor in VARCHAR2,
                                 pr_inpessoa in crapass.inpessoa%TYPE,
                                 pr_cdorigem in craplcm.cdorigem%TYPE,
                                 pr_dtdtrans in crapdcb.dtdtrans%TYPE,
                                 pr_dtmvtooo in crapdcb.dtmvtolt%TYPE,
                                 pr_flgdebcc in craphcb.flgdebcc%TYPE,
                                 pr_vldtrans NUMBER,
                                 pr_dscritic out varchar2) is 

      begin
        insert into tbgen_batch_relatorio_wrk(cdcooper
                                             ,cdprograma
                                             ,dsrelatorio
                                             ,dtmvtolt
                                             ,dschave
                                             ,nrdconta
                                             ,cdagenci
                                             ,dscritic)
                                       values(pr_cdcooper
                                             ,vr_cdprogra
                                             ,'DADOS_RELAT'
                                             ,pr_dtmvtolt
                                             ,pr_idxdados
                                             ,pr_cdcopreg
                                             ,pr_cdagenci
                                             ,pr_nmrescop||';'||     
                                              pr_nmresage||';'||
                                              pr_nrdconta||';'||
                                              pr_cdtrnbcb||';'||
                                              pr_dstrnbcb||';'||
                                              pr_cdhistor||';'||
                                              pr_dshistor||';'||
                                              pr_inpessoa||';'||
                                              pr_cdorigem||';'||
                                              to_char(pr_dtdtrans,'ddmmrrrr')||';'||
                                              to_char(pr_dtmvtooo,'ddmmrrrr')||';'||
                                              pr_flgdebcc||';'||
                                              to_char(pr_vldtrans,'fm999g999g999g999g990d00')||';');

      exception
        when others then
          pr_dscritic := 'Erro na rotina pc_insere_relato --> '||sqlerrm;
      end;
        

      -- Guardar registro para posteriormente inserir
      PROCEDURE pc_insert_craplcm(pr_cdcooper IN  craplcm.cdcooper%TYPE,
                                   pr_dtmvtolt IN  craplcm.dtmvtolt%type,
                                   pr_cdagenci IN  craplcm.cdagenci%type,
                                   pr_cdbccxlt IN  craplcm.cdbccxlt%type,
                                   pr_nrdolote IN  craplcm.nrdolote%type,
                                   pr_nrdctabb IN  craplcm.nrdctabb%type,
                                   pr_nrdocmto IN  craplcm.nrdocmto%type,
                                   pr_dtrefere IN  craplcm.dtrefere%type,
                                   pr_hrtransa IN  craplcm.hrtransa%type,
                                   pr_vllanmto IN  craplcm.vllanmto%type,
                                   pr_nrdconta IN  craplcm.nrdconta%type,
                                   pr_cdhistor IN  craplcm.cdhistor%type,
                                   pr_nrseqdig IN  craplcm.nrseqdig%type,
                                   pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE,
                                   pr_dscritic OUT VARCHAR2) IS

      BEGIN

        -- definir index da temptable
        vr_idxlcm := lpad(pr_cdcooper,10,0) || to_char(pr_dtmvtolt,'rrrrmmdd')|| lpad(pr_cdagenci,5,'0') ||
                     lpad(pr_cdbccxlt,5,'0') || lpad(pr_nrdolote,10,'0') || lpad(pr_nrdctabb,10,'0')||
                     lpad(pr_nrdocmto,25,'0');

        IF vr_tab_craplcm.exists(vr_idxlcm) THEN
          pr_dscritic := 'Registro para craplcm ja existe: nrdctabb ->'|| pr_nrdctabb ||' nrdocmto -> '|| pr_nrdocmto;
        ELSE
          vr_tab_craplcm(vr_idxlcm).cdcooper :=  pr_cdcooper;
          vr_tab_craplcm(vr_idxlcm).dtmvtolt :=  pr_dtmvtolt;
          vr_tab_craplcm(vr_idxlcm).cdagenci :=  pr_cdagenci;
          vr_tab_craplcm(vr_idxlcm).cdbccxlt :=  pr_cdbccxlt;
          vr_tab_craplcm(vr_idxlcm).nrdolote :=  pr_nrdolote;
          vr_tab_craplcm(vr_idxlcm).nrdctabb :=  pr_nrdctabb;
          vr_tab_craplcm(vr_idxlcm).nrdocmto :=  pr_nrdocmto;
          vr_tab_craplcm(vr_idxlcm).dtrefere :=  pr_dtrefere;
          vr_tab_craplcm(vr_idxlcm).hrtransa :=  pr_hrtransa;
          vr_tab_craplcm(vr_idxlcm).vllanmto :=  pr_vllanmto;
          vr_tab_craplcm(vr_idxlcm).nrdconta :=  pr_nrdconta;
          vr_tab_craplcm(vr_idxlcm).cdhistor :=  pr_cdhistor;
          vr_tab_craplcm(vr_idxlcm).nrseqdig :=  pr_nrseqdig;
          vr_tab_craplcm(vr_idxlcm).cdpesqbb :=  pr_cdpesqbb;
          vr_tab_craplcm(vr_idxlcm).cdorigem :=  7; /* Origem do lançamento feito pelo programa*/
        END IF;
      END pc_insert_craplcm;

      -- Gravar registro para posteriormente realizar o insert
      PROCEDURE pc_insert_crapdcb(pr_tpmensag IN  crapdcb.tpmensag%TYPE,
                                  pr_nrnsucap IN  crapdcb.nrnsucap%TYPE,
                                  pr_dtdtrgmt IN  crapdcb.dtdtrgmt%type,
                                  pr_hrdtrgmt IN  crapdcb.hrdtrgmt%type,
                                  pr_cdcooper IN  crapdcb.cdcooper%type,
                                  pr_nrdconta IN  crapdcb.nrdconta%type,
                                  pr_nrseqarq IN  crapdcb.nrseqarq%type,
                                  pr_nrinstit IN  crapdcb.nrinstit%type,
                                  pr_cdprodut IN  crapdcb.cdprodut%type,
                                  pr_nrcrcard IN  crapdcb.nrcrcard%type,
                                  pr_tpdtrans IN  crapdcb.tpdtrans%type,
                                  pr_cddtrans IN  crapdcb.cddtrans%type,
                                  pr_cdhistor IN  crapdcb.cdhistor%type,
                                  pr_dtdtrans IN  crapdcb.dtdtrans%type,
                                  pr_dtpostag IN  crapdcb.dtpostag%type,
                                  pr_dtcnvvlr IN  crapdcb.dtcnvvlr%type,
                                  pr_vldtrans IN  crapdcb.vldtrans%type,
                                  pr_vldtruss IN  crapdcb.vldtruss%type,
                                  pr_cdautori IN  crapdcb.cdautori%type,
                                  pr_dsdtrans IN  crapdcb.dsdtrans%type,
                                  pr_cdcatest IN  crapdcb.cdcatest%type,
                                  pr_cddmoeda IN  crapdcb.cddmoeda%type,
                                  pr_vlmoeori IN  crapdcb.vlmoeori%type,
                                  pr_cddreftr IN  crapdcb.cddreftr%type,
                                  pr_cdagenci IN  crapdcb.cdagenci%type,
                                  pr_nridvisa IN  crapdcb.nridvisa%type,
                                  pr_cdtrresp IN  crapdcb.cdtrresp%type,
                                  pr_incoopon IN  crapdcb.incoopon%type,
                                  pr_txcnvuss IN  crapdcb.txcnvuss%type,
                                  pr_cdautban IN  crapdcb.cdautban%type,
                                  pr_idtrterm IN  crapdcb.idtrterm%type,
                                  pr_tpautori IN  crapdcb.tpautori%type,
                                  pr_cdproces IN  crapdcb.cdproces%type,
                                  pr_dstrorig IN  crapdcb.dstrorig%type,
                                  pr_nrnsuori IN  crapdcb.nrnsuori%TYPE,
                                  pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE,
                                  pr_rowid_dcb IN ROWID,
                                  pr_operacao IN VARCHAR2,
                                  pr_dscritic OUT VARCHAR2) IS
      BEGIN

        -- definir index da temptable
        vr_idxdcb := lpad(pr_tpmensag,4,'0')        || lpad(pr_nrnsucap,6,'0')||
                      to_char(pr_dtdtrgmt,'rrrrmmdd')|| lpad(pr_hrdtrgmt,6,'0')||
                     lpad(pr_cdcooper,10,'0')       || lpad(pr_nrdconta,12,'0');

        IF pr_operacao = 'A' THEN
          vr_tab_crapdcb(vr_idxdcb).rowid_dcb := pr_rowid_dcb;
        ELSIF vr_tab_crapdcb.exists(vr_idxdcb) THEN
            RETURN;
          END IF;

        -- Criar registro na pltable
        vr_tab_crapdcb(vr_idxdcb).operacao := pr_operacao;
        vr_tab_crapdcb(vr_idxdcb).det.tpmensag := pr_tpmensag;
        vr_tab_crapdcb(vr_idxdcb).det.nrnsucap := pr_nrnsucap;
        vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt := pr_dtdtrgmt;
        vr_tab_crapdcb(vr_idxdcb).det.hrdtrgmt := pr_hrdtrgmt;
        vr_tab_crapdcb(vr_idxdcb).det.cdcooper := pr_cdcooper;
        vr_tab_crapdcb(vr_idxdcb).det.nrdconta := pr_nrdconta;
        vr_tab_crapdcb(vr_idxdcb).det.nrseqarq := pr_nrseqarq;
        vr_tab_crapdcb(vr_idxdcb).det.nrinstit := pr_nrinstit;
        vr_tab_crapdcb(vr_idxdcb).det.cdprodut := pr_cdprodut;
        vr_tab_crapdcb(vr_idxdcb).det.nrcrcard := pr_nrcrcard;
        vr_tab_crapdcb(vr_idxdcb).det.tpdtrans := pr_tpdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cddtrans := pr_cddtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cdhistor := pr_cdhistor;
        vr_tab_crapdcb(vr_idxdcb).det.dtdtrans := pr_dtdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.dtpostag := pr_dtpostag;
        vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr := pr_dtcnvvlr;
        vr_tab_crapdcb(vr_idxdcb).det.vldtrans := pr_vldtrans;
        vr_tab_crapdcb(vr_idxdcb).det.vldtruss := pr_vldtruss;
        vr_tab_crapdcb(vr_idxdcb).det.cdautori := pr_cdautori;
        vr_tab_crapdcb(vr_idxdcb).det.dsdtrans := pr_dsdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cdcatest := pr_cdcatest;
        vr_tab_crapdcb(vr_idxdcb).det.cddmoeda := pr_cddmoeda;
        vr_tab_crapdcb(vr_idxdcb).det.vlmoeori := pr_vlmoeori;
        vr_tab_crapdcb(vr_idxdcb).det.cddreftr := pr_cddreftr;
        vr_tab_crapdcb(vr_idxdcb).det.cdagenci := pr_cdagenci;
        vr_tab_crapdcb(vr_idxdcb).det.nridvisa := pr_nridvisa;
        vr_tab_crapdcb(vr_idxdcb).det.cdtrresp := pr_cdtrresp;
        vr_tab_crapdcb(vr_idxdcb).det.incoopon := pr_incoopon;
        vr_tab_crapdcb(vr_idxdcb).det.txcnvuss := pr_txcnvuss;
        vr_tab_crapdcb(vr_idxdcb).det.cdautban := pr_cdautban;
        vr_tab_crapdcb(vr_idxdcb).det.idtrterm := pr_idtrterm;
        vr_tab_crapdcb(vr_idxdcb).det.tpautori := pr_tpautori;
        vr_tab_crapdcb(vr_idxdcb).det.cdproces := pr_cdproces;
        vr_tab_crapdcb(vr_idxdcb).det.dstrorig := pr_dstrorig;
        vr_tab_crapdcb(vr_idxdcb).det.nrnsuori := pr_nrnsuori;
        vr_tab_crapdcb(vr_idxdcb).det.dtmvtolt := pr_dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na rotina pc_insert_crapdcb --> '||SQLERRM;
      END pc_insert_crapdcb;



      BEGIN
        -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                                  ,pr_action => 'pc_crps670_process');                                  
        -- Caso execucao paralela
        IF pr_idparale <> 0 THEN 
          -- Grava controle de batch por agência
          gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                          ,pr_cdprogra    => vr_cdprogra      -- Codigo do Programa
                                          ,pr_dtmvtolt    => pr_dtmvtolt      -- Data de Movimento
                                          ,pr_tpagrupador => 1                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                          ,pr_cdagrupador => pr_nrseqexe      -- Codigo do agrupador conforme (tpagrupador)
                                          ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                          ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                          ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                          ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                          ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
          -- Testar saida com erro
          if vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;    
        end if;

        -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe          
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par); 

        -- Buscar data base para transacoes com contas migradas no periodo da migracao
        vr_dtcxtmig := to_date(pr_dtcxtmig,'dd/mm/rrrr');
                    
        -- Ler todas as linhas da tabela direcionadas para essa execução
        FOR rw_arq in cr_work_arq(pr_cdcooper
                                 ,pr_nrseqexe
                                 ,vr_cdprogra
                                 ,'DADOS_ARQ' 
                                 ,pr_dtmvtolt) LOOP
          BEGIN
            vr_nrdlinha:= vr_nrdlinha + 1;
                   
            -- busca a cooperativa com base na agencia bancoob
            OPEN cr_crapcop_cdagebcb(pr_cdagebcb => substr(rw_arq.des_text,165,6));
            FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

            IF cr_crapcop_cdagebcb%NOTFOUND THEN
              -- Fechar o cursor pois havera raise
              CLOSE cr_crapcop_cdagebcb;
              -- Montar mensagem de critica
              vr_dscritic := 'Cod. Agencia da Bancoob ' || substr(rw_arq.des_text,165,6) ||
                             ' nao possui Cooperativa correspondente.';
              RAISE vr_exc_rejeitado;
            END IF;

            -- Fecha cursor cooperativa
            CLOSE cr_crapcop_cdagebcb;
        
            --limpar rowtype
            rw_craphcb := NULL;

            -- limpar variaveis para controle de debito
            vr_cdtrnbcb_ori := 0;
            vr_flgdebcc := 0;
            vr_dstrnbcb := '';
            vr_cdhistor_on := 0;
            vr_cdhistor_off := 0;

            -- não buscar historico qaundo for movimento de consulta
            IF  nvl(trim(substr(rw_arq.des_text,27,1)),' ') <> 'M' THEN

              vr_cdtrnbcb_ori := TO_NUMBER(substr(rw_arq.des_text,28,3));

              -- busca vinculo dos historicos com transacao bancoob
              FOR rw_craphcb IN cr_craphcb(pr_cdtrnbcb => TO_NUMBER(substr(rw_arq.des_text,28,3))) LOOP                   

                vr_flgdebcc := rw_craphcb.flgdebcc;
                vr_dstrnbcb := rw_craphcb.dstrnbcb;

                IF rw_craphcb.tphistorico = 0 THEN -- Historico Online
                  vr_cdhistor_on := rw_craphcb.cdhistor;
                ELSIF rw_craphcb.tphistorico = 1 THEN -- Historico Offline
                  vr_cdhistor_off := rw_craphcb.cdhistor;                
        END IF;
        
                    
                    -- Buscar descricao dos historicos
                    OPEN cr_craphis (pr_cdhistor => rw_craphcb.cdhistor);
                      FETCH cr_craphis INTO rw_craphis;

                      -- Se nao encontrar histórico
                      IF cr_craphis%NOTFOUND THEN
                         -- fechar o cursor
                         CLOSE cr_craphis;   
                         -- Montar mensagem de critica
                         vr_dscritic := 'Historico ' || rw_craphcb.cdhistor ||
                                        ' nao encontrado.';
                         RAISE vr_exc_rejeitado;                       
                      ELSE
                        -- fechar o cursor
                        CLOSE cr_craphis;
                         
                        IF rw_craphcb.tphistorico = 0 THEN -- Historico Online
                          vr_dshistor_on := rw_craphis.cdhistor || ' - ' || rw_craphis.dshistor;
                          vr_indebcre_on := rw_craphis.indebcre;
                        ELSIF rw_craphcb.tphistorico = 1 THEN -- Historico Offline
                          vr_dshistor_off := rw_craphis.cdhistor || ' - ' || rw_craphis.dshistor;
                          vr_indebcre_off := rw_craphis.indebcre;
                        END IF;
                         
                      END IF;
                  END LOOP;
                  
                  -- Validar se historicos Online/Offline sao validos
                  IF vr_cdhistor_on = 0 THEN
                vr_dscritic := 'Historico Online para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                   ' nao cadastrado.';
                    RAISE vr_exc_rejeitado;
                  END IF;
                    
                  IF vr_cdhistor_off = 0 THEN
                vr_dscritic := 'Historico Offline para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                   ' nao cadastrado.';
                    RAISE vr_exc_rejeitado;
                  END IF;    
                END IF;

                vr_nrdconta := NULL;
                
                --reseta as variaveis
                vr_cdorigem := 0;
                vr_dtmovtoo := NULL;                 
                
                -- EXTRAIR NUMERO DA CONTA
                BEGIN
              vr_nrdconta := to_number(substr(rw_arq.des_text,171,12));
                EXCEPTION
                  WHEN OTHERS THEN
                vr_dscritic := 'Numero de conta invalido nrdconta: '||substr(rw_arq.des_text,171,12)||' !';
                    RAISE vr_exc_rejeitado;
                END;                                
                
                -- verifica se eh uma cooperativa inativa
                IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                  
                  OPEN cr_craptco (pr_cdcopant => rw_crapcop_cdagebcb.cdcooper,
                                   pr_nrctaant => vr_nrdconta);
                  FETCH cr_craptco INTO rw_craptco;
                  
                  IF cr_craptco%NOTFOUND THEN
                    vr_dscritic := 'Associado migrado nrdconta: '||vr_nrdconta||' não encontrado!';
                    CLOSE cr_craptco;
                    RAISE vr_exc_rejeitado;                                      
                  END IF;
                  
                  CLOSE cr_craptco;
                                    
                  /* precisamos pegar a nova coop e nova conta para usar na hora de fazer o lancamento,
                     se necessario */                                                                        
                  -- Buscar informações dos associados
                  OPEN cr_crapass_dest (pr_cdcooper => rw_craptco.cdcooper,
                                        pr_nrdconta => rw_craptco.nrdconta);
                  FETCH cr_crapass_dest into rw_crapass_dest;
                  -- caso não encontrar, levantar exception
                  IF cr_crapass_dest%NOTFOUND THEN
                    vr_dscritic := 'Associado nrdconta: '||rw_craptco.nrdconta||' não encontrado!';
                    CLOSE cr_crapass_dest;
                    RAISE vr_exc_rejeitado;
                  END IF;

                  CLOSE cr_crapass_dest;
                  
                  /* se a data transacao eh a partir de 31/12 <parametro> 
                     entao nao pode mais buscar na coop antiga */
              IF to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmRRRR') >= vr_dtcxtmig THEN
                    vr_nrdconta := nvl(rw_craptco.nrdconta,0);                                                                                                               
                  
                    IF cr_crapcop_cdagebcb%ISOPEN THEN
                      CLOSE cr_crapcop_cdagebcb;
                    END IF;
                  
                    -- busca os dados da cooperativa incorporadora (nova coop)
                    OPEN cr_crapcop_cdagebcb(pr_cdagebcb => rw_crapass_dest.cdagebcb);
                    FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

                    IF cr_crapcop_cdagebcb%NOTFOUND THEN
                      -- Fechar o cursor pois havera raise
                      CLOSE cr_crapcop_cdagebcb;
                      -- Montar mensagem de critica
                      vr_dscritic := 'Cod. Agencia do Bancoob ' || rw_crapass_dest.cdagebcb ||
                                     ' nao possui Cooperativa correspondente.';
                      RAISE vr_exc_rejeitado;
                    END IF;

                    -- Fecha cursor cooperativa
                    CLOSE cr_crapcop_cdagebcb;
                  END IF;
                END IF;
                
                -- Buscar informações dos associados
                OPEN cr_crapass (pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                 pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass into rw_crapass;
                -- caso não encontrar, levantar exception
                IF cr_crapass%NOTFOUND THEN
                  vr_dscritic := 'Associado nrdconta: '||vr_nrdconta||' não encontrado!';
                  CLOSE cr_crapass;
                  RAISE vr_exc_rejeitado;
                END IF;

                CLOSE cr_crapass; 
                 
                -- CÓDIGO DA TRANSAÇÃO
            vr_cdtrnbcb := gene0002.fn_char_para_number(nvl(trim(substr(rw_arq.des_text,28,3)),0));
                               
                /*******************************/
                -- verifica se deve debitar C/C
                IF vr_flgdebcc = 1 THEN
                    --DATA E HORA DA TRANSAÇÃO GMT
              vr_dthstran := gene0002.fn_char_para_number(nvl(trim(substr(rw_arq.des_text,204,10)),0));
                    -- TIPO DE TRANSAÇÃO
              vr_indebcre := trim(substr(rw_arq.des_text,27,1));
                                     
                    -- NUMERO DO CARTAO
              vr_cdpesqbb := trim(substr(rw_arq.des_text,7,19));
                    -- NSU DA REDE DE CAPTURA
              vr_nsuredec := trim(substr(rw_arq.des_text,198,6));
                    -- DATA DO LANCAMENTO
              vr_dtmvtolt := pr_dtmvtolt;

                    -- COOPERATIVA BANCOOB
                    vr_cdcopban :=  rw_crapcop_cdagebcb.cdcooper;

              vr_cdcrimsg := substr(rw_arq.des_text,214,2);
              vr_vldtrans := (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100);

                    --resetar as variaveis
                    vr_tpmsg200 := FALSE;
                    vr_tpmsg220 := FALSE;
                    vr_tpmsg420 := FALSE;                   

                    -- validar nsu, para utilizar no numero de documento
              vr_nrdocmto := nvl(trim(substr(rw_arq.des_text,198,6)),0);                                       
                 
                    -- se estiver zerado usar i cod. autorização
                    IF nvl(vr_nrdocmto,0) = 0 THEN
                       -- Chamar a rotina de geração do NSU
                vr_nrdocmto := CCRD0002.fn_busca_nsu_transacao(pr_tpmensag => trim(substr(rw_arq.des_text,254, 4))
                                                              ,pr_nrnsucap => trim(substr(rw_arq.des_text,77,6))
                                                              ,pr_dtdtrgmt => trim(substr(rw_arq.des_text,204,10)));
                    ELSE
                        -- Chamar a rotina de geração do NSU
                vr_nrdocmto := CCRD0002.fn_busca_nsu_transacao(pr_tpmensag => trim(substr(rw_arq.des_text,254, 4))
                                                              ,pr_nrnsucap => trim(substr(rw_arq.des_text,198, 6))
                                                              ,pr_dtdtrgmt => trim(substr(rw_arq.des_text,204,10)));
                    END IF;

                    -- verifica se já existe debito de cartão bancoob
                    OPEN cr_crapdcb(pr_nrnsucap => vr_nsuredec,
                                    pr_cdcooper => vr_cdcopban,
                                    pr_nrdconta => rw_crapass.nrdconta,
                                    pr_vldtrans => vr_vldtrans,
                              pr_nrseqarq => pr_nrseqarq,
                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'));
                    FETCH cr_crapdcb INTO rw_crapdcb;

                    IF cr_crapdcb%NOTFOUND THEN

                       OPEN cr_craplcm_dia(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           vr_nsuredec,
                                           vr_cdhistor_on,
                                    to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                           vr_vldtrans);
                        FETCH cr_craplcm_dia INTO rw_craplcm_dia;

                        IF cr_craplcm_dia%NOTFOUND THEN
                           OPEN cr_craplcm(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           vr_nsuredec,
                                           vr_cdhistor_on,
                                           vr_vldtrans);
                           FETCH cr_craplcm INTO rw_craplcm;
                           IF cr_craplcm%NOTFOUND THEN
                               IF vr_cdcrimsg = '00' THEN
                                  vr_crialcmt := TRUE;
                               ELSE
                                  vr_crialcmt := FALSE;
                               END IF;
                            ELSE
                              vr_crialcmt := FALSE;
                            END IF;
                            CLOSE cr_craplcm;
                         ELSE
                              vr_crialcmt := FALSE;                             
                         END IF;
                    
                         CLOSE cr_craplcm_dia;
                         CLOSE cr_crapdcb;

                    ELSE  --SE ACHOU MENSAGENS
                        CLOSE cr_crapdcb;
                        --  PERCORRE OS debitos de cartão bancoob
                        FOR rw_crapdcb IN cr_crapdcb (pr_nrnsucap => vr_nsuredec,
                                                      pr_cdcooper => vr_cdcopban,
                                                      pr_nrdconta => rw_crapass.nrdconta,
                                                      pr_vldtrans => vr_vldtrans,
                                              pr_nrseqarq => pr_nrseqarq,
                                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd')) LOOP

                         vr_tpmensag := rw_crapdcb.tpmensag;
                vr_cdcrimsg := substr(rw_arq.des_text,214,2);
                         vr_vldtrans :=  rw_crapdcb.vldtrans;
                           -- verifica se existe lancamento correpondente no dia
                           OPEN cr_craplcm_dia(vr_cdcopban,
                                               rw_crapass.nrdconta,
                                               vr_cdpesqbb,
                                               rw_crapdcb.nrnsucap,
                                               rw_crapdcb.cdhistor,
                                               rw_crapdcb.dtmvtolt,
                                               vr_vldtrans);
                           FETCH cr_craplcm_dia INTO rw_craplcm_dia;

                           IF cr_craplcm_dia%NOTFOUND THEN -- se não encontrar NO DIA, verifica se existe outro lancamento correspondente ao nsu
                              OPEN cr_craplcm(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           rw_crapdcb.nrnsucap,
                                           rw_crapdcb.cdhistor,
                                           vr_vldtrans);
                              FETCH cr_craplcm INTO rw_craplcm;

                              IF cr_craplcm%NOTFOUND THEN -- se não encontrar lancamento verifica se é necessário fazê-lo
                                 IF vr_tpmensag = '0200' AND vr_cdcrimsg <> '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0220' AND vr_tpmsg200  THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0420' AND vr_tpmsg200 AND vr_cdcrimsg = '00' AND vr_indebcre = 'C' THEN
                                    vr_crialcmt := TRUE;
                                 ELSIF vr_tpmensag = '0420' AND NOT vr_tpmsg200 AND NOT vr_tpmsg220 AND vr_cdcrimsg <> '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0420' AND vr_tpmsg220  AND vr_cdcrimsg = '00' AND vr_indebcre = 'C' THEN
                                    vr_crialcmt := TRUE;
                                 ELSIF vr_tpmensag = '0420' AND  vr_cdcrimsg = '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSE
                                    vr_crialcmt := TRUE;
                                 END IF;
                                 CLOSE cr_craplcm;
                              ELSE -- se encontrar verifica se há necessidade de fazê-lo
                                 vr_cdorigem := rw_craplcm.cdorigem;
                                 vr_dtmovtoo := rw_craplcm.dtmvtolt;
                                 IF vr_indebcre = rw_craphis.indebcre AND vr_cdtrnbcb = vr_cdtrnbcb_ori THEN
                                    /*SE FOR UM CREDITO EFETUA O LANÇAMENTO*/
                                    IF vr_indebcre = 'C' AND vr_cdcrimsg = '00' AND vr_tpmensag <> '0420' THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmsg200 AND vr_tpmsg420 AND vr_cdcrimsg = '00' THEN -- tem a 200 e a 420 mas veio sem critica no arquivo
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0200' AND (vr_cdcrimsg <> '00' OR vr_cdcrimsg <> nvl(TRIM(rw_crapdcb.cdtrresp),'00')) THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0220' AND vr_cdcrimsg <> '00'  THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0420' AND vr_tpmsg200  AND vr_tpmsg220 AND NOT vr_tpmsg420 AND vr_cdcrimsg <> '00'  THEN
                                       vr_crialcmt := TRUE;
                                    ELSE
                                       vr_crialcmt := FALSE;
                                    END IF;
                                  ELSE
                                    vr_crialcmt := TRUE;
                                  END IF;

                                  --seta o tipo de mensagem encontrada
                                  IF vr_tpmensag = '0200' THEN
                                     vr_tpmsg200 := TRUE;
                                  ELSIF vr_tpmensag = '0220' THEN
                                     vr_tpmsg220 := TRUE;
                                  ELSIF vr_tpmensag = '0420' THEN
                                     vr_tpmsg420 := TRUE;
                                  END IF;
                               CLOSE cr_craplcm;

                              END IF;
                            ELSE -- se encontrar o lançamento no dia, verifica se há necessidade de fazê-lo
                               vr_cdorigem := rw_craplcm_dia.cdorigem; -- Grava a origem do lancamento para o relatorio
                               vr_dtmovtoo := rw_craplcm_dia.dtmvtolt;
                               IF vr_indebcre = rw_craphis.indebcre AND vr_cdtrnbcb = vr_cdtrnbcb_ori THEN
                                  /*SE FOR UM CREDITO EFETUA O LANÇAMENTO*/
                                  IF vr_indebcre = 'C'AND vr_cdcrimsg = '00' AND vr_tpmensag <> '0420' THEN   
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmsg200 AND vr_tpmsg420 AND vr_cdcrimsg = '00' THEN -- tem a 200 e a 420 mas veio sem critica no arquivo
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0200' AND (vr_cdcrimsg <> '00' OR vr_cdcrimsg <> nvl(TRIM(rw_crapdcb.cdtrresp),'00')) THEN
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0220' AND vr_cdcrimsg <> '00'  THEN
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0420' AND vr_tpmsg200  AND vr_tpmsg220 AND NOT vr_tpmsg420 AND vr_cdcrimsg <> '00'  THEN
                                     vr_crialcmt := TRUE;
                                  ELSE
                                     vr_crialcmt := FALSE;
                                  END IF;

                                ELSE
                                  vr_crialcmt := TRUE;
                                END IF;

                                --seta o tipo de mensagem encontrada
                                IF vr_tpmensag = '0200' THEN
                                   vr_tpmsg200 := TRUE;
                                ELSIF vr_tpmensag = '0220' THEN
                                   vr_tpmsg220 := TRUE;
                                ELSIF vr_tpmensag = '0420' THEN
                                   vr_tpmsg420 := TRUE;
                                END IF;
                            END IF;
                            CLOSE cr_craplcm_dia;
                        END LOOP;
                   END IF;
                   
                  /* EFETUA DÉBITOS*/
            IF substr(rw_arq.des_text,214,2)  = '00'  THEN

                     IF vr_crialcmt THEN
                       
                       -- se a coop do registro esta inativa, usa coop e conta nova
                       IF rw_crapcop_cdagebcb.flgativo = 0 THEN                         
                         vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapass_dest.cdcooper||';'||
                                                                                  to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                  rw_crapass_dest.cdagenci||';'||
                                                                                  vr_cdbccxlt||';'||
                                                                                  vr_nrdolote||'');

                          -- se marcado para debitar
                          -- cria registro na tabela de lançamentos
                          -- Guardar registro para posteriormente inserir
                          pc_insert_craplcm( pr_cdcooper  => rw_crapass_dest.cdcooper,
                                             pr_dtmvtolt  => vr_dtmvtolt,
                                             pr_cdagenci  => rw_crapass_dest.cdagenci,
                                             pr_cdbccxlt  => vr_cdbccxlt,
                                             pr_nrdolote  => vr_nrdolote,
                                     pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                             pr_nrdocmto  => vr_nrdocmto,
                                     pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                     pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                     pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                             pr_nrdconta  => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta nova
                                             pr_cdhistor  => vr_cdhistor_off,
                                             pr_nrseqdig  => vr_nrseqdig_lot,
                                             pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                             pr_dscritic  => vr_dscritic );

                          IF vr_dscritic IS NOT NULL THEN
                            RAISE vr_exc_rejeitado;
                          END IF;
                       ELSE                       
                          vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapcop_cdagebcb.cdcooper||';'||
                                                                                  to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                  rw_crapass.cdagenci||';'||
                                                                                  vr_cdbccxlt||';'||
                                                                                  vr_nrdolote||'');

                          -- se marcado para debitar
                          -- cria registro na tabela de lançamentos
                          -- Guardar registro para posteriormente inserir
                          pc_insert_craplcm( pr_cdcooper  => vr_cdcopban,
                                             pr_dtmvtolt  => vr_dtmvtolt,
                                             pr_cdagenci  => rw_crapass.cdagenci,
                                             pr_cdbccxlt  => vr_cdbccxlt,
                                             pr_nrdolote  => vr_nrdolote,
                                     pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                             pr_nrdocmto  => vr_nrdocmto,
                                     pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                     pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                     pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                             pr_nrdconta  => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                             pr_cdhistor  => vr_cdhistor_off,
                                             pr_nrseqdig  => vr_nrseqdig_lot,
                                             pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                             pr_dscritic  => vr_dscritic );

                          IF vr_dscritic IS NOT NULL THEN
                            RAISE vr_exc_rejeitado;
                          END IF;                        
                        END IF;
                      END IF;

                   ELSE --ESTORNO DA CONTA = CRÉDITO NA CONTA
              IF substr(rw_arq.des_text,214,2)  <> '00' THEN

                         IF vr_crialcmt THEN

                  vr_cdhistor := TO_NUMBER(substr(rw_arq.des_text,28,3)) ;
                            
                              IF (vr_cdhistor < 100) THEN
                                  -- busca histórico do Estorno
                    OPEN cr_craphcb_est (pr_cdtrnbcb => (TO_NUMBER(substr(rw_arq.des_text,28,3))+100));
                                  FETCH cr_craphcb_est INTO rw_craphcb_est;

                                  -- Se nao encontrar histórico
                                  IF cr_craphcb_est%NOTFOUND THEN
                                     -- fechar o cursor
                                     CLOSE cr_craphcb_est;
                                     -- Montar mensagem de critica
                       vr_dscritic := 'Historico para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                                    ' nao encontrado.';
                                     RAISE vr_exc_rejeitado;
                                  ELSE
                                     -- fechar o cursor
                                     CLOSE cr_craphcb_est;
                                  END IF;
                               END IF;
                               
                              -- se a coop do registro esta inativa, usa coop e conta nova 
                              IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                                vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapass_dest.cdcooper||';'||
                                                                                        to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                        rw_crapass_dest.cdagenci||';'||
                                                                                        vr_cdbccxlt||';'||
                                                                                        vr_nrdolote||'');
                                                             
                                -- Guardar registro para posteriormente inserir
                                pc_insert_craplcm( pr_cdcooper  => rw_crapass_dest.cdcooper,
                                                   pr_dtmvtolt  => vr_dtmvtolt,
                                                   pr_cdagenci  => rw_crapass_dest.cdagenci,
                                                   pr_cdbccxlt  => vr_cdbccxlt,
                                                   pr_nrdolote  => vr_nrdolote,
                                       pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                                   pr_nrdocmto  => vr_nrdocmto,
                                       pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                       pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                       pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                                   pr_nrdconta  => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta
                                                   pr_cdhistor  => rw_craphcb_est.cdhistor,
                                                   pr_nrseqdig  => vr_nrseqdig_lot,
                                                   pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                                   pr_dscritic  => vr_dscritic );

                                IF vr_dscritic IS NOT NULL THEN
                                  RAISE vr_exc_rejeitado;
                                END IF;
                              ELSE
                                vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapcop_cdagebcb.cdcooper||';'||
                                                                                        to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                        rw_crapass.cdagenci||';'||
                                                                                        vr_cdbccxlt||';'||
                                                                                        vr_nrdolote||'');
                                -- Guardar registro para posteriormente inserir
                                pc_insert_craplcm( pr_cdcooper  => vr_cdcopban,
                                                   pr_dtmvtolt  => vr_dtmvtolt,
                                                   pr_cdagenci  => rw_crapass.cdagenci,
                                                   pr_cdbccxlt  => vr_cdbccxlt,
                                                   pr_nrdolote  => vr_nrdolote,
                                       pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                                   pr_nrdocmto  => vr_nrdocmto,
                                       pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                       pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                       pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                                   pr_nrdconta  => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                                   pr_cdhistor  => rw_craphcb_est.cdhistor,
                                                   pr_nrseqdig  => vr_nrseqdig_lot,
                                                   pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                                   pr_dscritic  => vr_dscritic );

                                IF vr_dscritic IS NOT NULL THEN
                                  RAISE vr_exc_rejeitado;
                                END IF;
                              END IF;
                          END IF;
                      END IF;
                   END IF;
                ELSE
                  -- ALTERACAO JMD                   
                  IF vr_cdtrnbcb IN('14','50','56') THEN
                    IF vr_cdtrnbcb = '14' THEN
                      vr_tipostaa := 4;
                    ELSIF vr_cdtrnbcb = '50' THEN
                      vr_tipostaa := 2;
                    ELSE
                      vr_tipostaa := 3;
                    END IF;
                    -- se coop do registro esta inativa, temos que ver na coop destino
                    IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapass_dest.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0)
                                                          ,pr_tipotari => 1
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    ELSE
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop_cdagebcb.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => vr_nrdconta
                                                          ,pr_tipotari => 1
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    END IF;
                    
                    IF vr_dscritic IS NOT NULL OR
                       vr_cdcritic <> 0 THEN
                       RAISE vr_exc_saida;
                    END IF;
                  ELSIF vr_cdtrnbcb IN('15','52','64') THEN
                    
                    IF vr_cdtrnbcb = '15' THEN
                      vr_tipostaa := 4;
                    ELSIF vr_cdtrnbcb = '52' THEN
                      vr_tipostaa := 2;
                    ELSE
                      vr_tipostaa := 3;
                    END IF;
                    
                    -- se coop do registro esta inativa, temos que ver na coop destino
                    IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapass_dest.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0)
                                                          ,pr_tipotari => 2
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    ELSE
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop_cdagebcb.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => vr_nrdconta
                                                          ,pr_tipotari => 2
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    END IF;
                    
                    IF vr_dscritic IS NOT NULL OR
                       vr_cdcritic <> 0 THEN
                       RAISE vr_exc_saida;
                    END IF;  
                  END IF;
                  -- FIM ALTERACAO JMD                          
                END IF;

               -- verifica se já existe debito de cartão bancoob msg 0200 (historico online)
          OPEN cr_crapdcb_200 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                               pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                               pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                     pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                     pr_nrdconta => rw_crapass.nrdconta,
                                     pr_cdhistor => vr_cdhistor_on);
                FETCH cr_crapdcb_200 INTO rw_crapdcb_200;
                IF cr_crapdcb_200%NOTFOUND THEN
                  CLOSE cr_crapdcb_200;
                  -- verifica se já existe debito de cartão bancoob msg 0200 (historico offline)
            OPEN cr_crapdcb_200 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                 pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                 pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                       pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                       pr_nrdconta => rw_crapass.nrdconta,
                                       pr_cdhistor => vr_cdhistor_off);
                  FETCH cr_crapdcb_200 INTO rw_crapdcb_200;
                END IF;

                -- Se nao existir vai criar registro de débito
                IF cr_crapdcb_200%NOTFOUND THEN                    
                   -- Se for crédito insere com o tipo 0400 - Cancelamento de Compra ou Saque em ATM com cartão na função débito
            IF nvl(trim(substr(rw_arq.des_text,27,1)),0) = 'C' AND substr(rw_arq.des_text,214,2) = '00' THEN
                      vr_tpmensag := '0400';
                      -- verifica se já existe Credito de cartão bancoob msg 0400 (historico online)
              OPEN cr_crapdcb_400 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                   pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                   pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                           pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                           pr_nrdconta => rw_crapass.nrdconta,
                                           pr_cdhistor => vr_cdhistor_on);
                      FETCH cr_crapdcb_400 INTO rw_crapdcb_400;
                      IF cr_crapdcb_400%NOTFOUND THEN
                        CLOSE cr_crapdcb_400;
                        -- verifica se já existe Credito de cartão bancoob msg 0400 (historico online)
                OPEN cr_crapdcb_400 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                     pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                     pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                             pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                             pr_nrdconta => rw_crapass.nrdconta,
                                             pr_cdhistor => vr_cdhistor_off);
                        FETCH cr_crapdcb_400 INTO rw_crapdcb_400;
                      END IF;
                      IF cr_crapdcb_400%NOTFOUND THEN
                         vr_criardcb := TRUE;
                      ELSE
                         vr_criardcb := FALSE; 
                      END IF;
                      CLOSE cr_crapdcb_400;  
                   ELSE
              vr_tpmensag := nvl(trim(substr(rw_arq.des_text,254,4)),' ');
                      vr_criardcb := TRUE;
                   END IF;
                   
                   IF vr_criardcb THEN
                      -- se coop do registro esta inativa, temos que ver na coop destino
                      IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                        pc_insert_crapdcb(pr_tpmensag => vr_tpmensag,
                                  pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                  pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                  pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                          pr_cdcooper => rw_crapass_dest.cdcooper,
                                          pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta
                                  pr_nrseqarq => nvl(pr_nrseqarq,0),
                                  pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                                  pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                                  pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                                  pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                  pr_cddtrans => nvl(trim(substr(rw_arq.des_text,28,3)),0),
                                          pr_cdhistor => vr_cdhistor_off,
                                  pr_dtdtrans => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                  pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                  pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                  pr_vldtrans => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                  pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                                  pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0), -- cdautori
                                  pr_dsdtrans => nvl(trim(substr(rw_arq.des_text,83,40)),' '),
                                  pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0) ,
                                  pr_cddmoeda => nvl(trim(substr(rw_arq.des_text,128,3)),' '),
                                  pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                                  pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                          pr_cdagenci => nvl(rw_crapass_dest.cdagenci,0), -- cdagenci
                                  pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                                  pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                                  pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                                  pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                                  pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                  pr_idtrterm => nvl(trim(substr(rw_arq.des_text,231,16)),' '),
                                  pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                                  pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                  pr_dstrorig => nvl(trim(substr(rw_arq.des_text,258,42)),' '),
                                  pr_nrnsuori => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_rowid_dcb=> NULL,
                                          pr_operacao => 'I',
                                          pr_dscritic => vr_dscritic);
                      ELSE
                        pc_insert_crapdcb(pr_tpmensag => vr_tpmensag,
                                  pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                  pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                  pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                          pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                          pr_nrdconta => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                  pr_nrseqarq => nvl(pr_nrseqarq,0),
                                  pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                                  pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                                  pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                                  pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                  pr_cddtrans => nvl(trim(substr(rw_arq.des_text,28,3)),0),
                                          pr_cdhistor => vr_cdhistor_off,
                                  pr_dtdtrans => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                  pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                  pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                  pr_vldtrans => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                  pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                                  pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0), -- cdautori
                                  pr_dsdtrans => nvl(trim(substr(rw_arq.des_text,83,40)),' '),
                                  pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0) ,
                                  pr_cddmoeda => nvl(trim(substr(rw_arq.des_text,128,3)),' '),
                                  pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                                  pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                          pr_cdagenci => nvl(rw_crapass.cdagenci,0), -- cdagenci
                                  pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                                  pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                                  pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                                  pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                                  pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                  pr_idtrterm => nvl(trim(substr(rw_arq.des_text,231,16)),' '),
                                  pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                                  pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                  pr_dstrorig => nvl(trim(substr(rw_arq.des_text,258,42)),' '),
                                  pr_nrnsuori => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_rowid_dcb=> NULL,
                                          pr_operacao => 'I',
                                          pr_dscritic => vr_dscritic);
                      END IF;
      
                      IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                      END IF;
                 END IF; 
                -- caso encontre registro de débito, atualiza campos
                ELSE

                  -- se ja existe o registro deve atualizar a mensagem 200
                  pc_insert_crapdcb(pr_tpmensag => '0200',
                              pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                              pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                    pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                    pr_nrdconta => nvl(rw_crapass.nrdconta,0), -- nrdconta
                              pr_nrseqarq => nvl(pr_nrseqarq,0),
                              pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                              pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                              pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                              pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                    pr_cddtrans => NULL,
                                    pr_cdhistor => rw_crapdcb_200.cdhistor,
                                    pr_dtdtrans => NULL,
                              pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                              pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                    pr_vldtrans => NULL,
                              pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                              pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0),
                                    pr_dsdtrans => NULL,
                              pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0),
                                    pr_cddmoeda => NULL,
                              pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                              pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                    pr_cdagenci => nvl(rw_crapass.cdagenci,0), -- cdagenci
                              pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                              pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                              pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                              pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                              pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                    pr_idtrterm => NULL,
                              pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                              pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                    pr_dstrorig => NULL,
                                    pr_nrnsuori => NULL,
                                    pr_dtmvtolt => vr_dtmvtolt,
                                    pr_rowid_dcb=> rw_crapdcb_200.rowid,
                                    pr_operacao => 'A',
                                    pr_dscritic => vr_dscritic);

                  IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                END IF;

                -- fecha cursor de registro de débitos
                CLOSE cr_crapdcb_200;
                
                --verifica se efetua o lancamento offline ou é tarifa
                IF vr_crialcmt OR vr_flgdebcc = 0 THEN
                    vr_cdorigem := 7;
            vr_dtmovtoo := pr_dtmvtolt;
                    vr_cdhistor_ori := vr_cdhistor_off;
                    vr_dshistor_ori := vr_dshistor_off;
                ELSE 
                  vr_cdorigem := 8;                 
                  vr_cdhistor_ori := vr_cdhistor_on;
                  vr_dshistor_ori := vr_dshistor_on;
                END IF;

                -- não buscar historico qaundo for de consulta
          IF  nvl(trim(substr(rw_arq.des_text,27,1)),' ') <> 'M' THEN

                  -- verificar se for efetivada/aprovada
            IF substr(rw_arq.des_text,214,2)  = '00' THEN
                    vr_flgrejei := 1; -- efetivada******/
                  ELSE
                    vr_flgrejei := 0; --reprovado
                  END IF;
                  
                -- se coop do registro esta inativa, temos que ver na coop destino
                IF rw_crapcop_cdagebcb.flgativo = 0 THEN
              -- gerar index                           
                    vr_index:= lpad(rw_crapass_dest.cdcooper,5,'0') || -- cdcooper(5)
                               lpad(rw_crapass_dest.cdagenci,5,'0')||--cdagenci(5)
                               rw_crapass_dest.inpessoa ||
                               lpad(vr_cdtrnbcb_ori,3,'0')||
                               lpad(vr_cdhistor_ori,5,'0')||
                               vr_cdorigem||
                               lpad(to_char(vr_dtmovtoo,'ddmmyyyy'),8,0)||
                         lpad(trim(substr(rw_arq.des_text,31,8)),8,0);                
              --incluir informações na temptable para o relatorio
              pc_insere_relato(vr_index
                              ,rw_crapass_dest.cdcooper
                              ,rw_crapass_dest.nmrescop
                              ,rw_crapass_dest.cdagenci
                              ,rw_crapass_dest.nmresage
                              ,rw_crapass_dest.nrdconta               
                              ,vr_cdtrnbcb_ori
                              ,vr_dstrnbcb
                              ,vr_cdhistor_ori
                              ,vr_dshistor_ori
                              ,rw_crapass_dest.inpessoa
                              ,vr_cdorigem
                              ,to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                              ,vr_dtmovtoo 
                              ,vr_flgdebcc
                              ,(nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100)
                              ,vr_dscritic);
                ELSE                
                   --gerar index                           
                    vr_index:= lpad(rw_crapcop_cdagebcb.cdcooper,5,'0') || -- cdcooper(5)
                               lpad(rw_crapass.cdagenci,5,'0')||--cdagenci(5)
                               rw_crapass.inpessoa ||
                               lpad(vr_cdtrnbcb_ori,3,'0')||
                               lpad(vr_cdhistor_ori,5,'0')||
                               vr_cdorigem||
                               lpad(to_char(vr_dtmovtoo,'ddmmyyyy'),8,0)||
                         lpad(trim(substr(rw_arq.des_text,31,8)),8,0);
                    --Atribuir valores a temptable
              pc_insere_relato(vr_index
                              ,rw_crapcop_cdagebcb.cdcooper
                              ,rw_crapcop_cdagebcb.nmrescop
                              ,rw_crapass.cdagenci
                              ,rw_crapass.nmresage
                              ,rw_crapass.nrdconta               
                              ,vr_cdtrnbcb_ori
                              ,vr_dstrnbcb
                              ,vr_cdhistor_ori
                              ,vr_dshistor_ori
                              ,rw_crapass.inpessoa
                              ,vr_cdorigem
                              ,to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                              ,vr_dtmovtoo
                              ,vr_flgdebcc
                              ,(nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100)
                              ,vr_dscritic);
                END IF;
                
            -- Se houve erro
            if vr_dscritic is not null then
              raise vr_exc_saida;
            end if;
                
            -- reseta as variaveis
                vr_cdorigem := 0;
                vr_dtmovtoo := NULL;
                
                END IF;
              EXCEPTION
                WHEN vr_exc_rejeitado THEN
                  
                  --verifica se efetua o lancamento offline ou é tarifa
                  IF vr_crialcmt OR vr_flgdebcc = 0 THEN                      
                      vr_cdhistor_ori := vr_cdhistor_off;
                      vr_dshistor_ori := vr_dshistor_off;
                  ELSE 
                    vr_cdhistor_ori := vr_cdhistor_on;
                    vr_dshistor_ori := vr_dshistor_on;
                  END IF;
                
            vr_dsmsglog := to_char(pr_dtmvtolt, 'dd/mm/yy') || ' as ' || to_char(sysdate,'hh24:mi:ss') || ' -> ' ||
                                    ' ERRO - ' ||
                                    ' cdcooper: '|| LPAD(rw_crapcop_cdagebcb.cdcooper,2,0) ||
                           ' nrdconta: '|| nvl(trim(gene0002.fn_mask_conta(vr_nrdconta)),substr(rw_arq.des_text,171,12)) ||
                           ' cdtrnbcb: '|| nvl(vr_cdtrnbcb_ori,TO_NUMBER(substr(rw_arq.des_text,28,3))) ||
                                    ' dstrnbcb: '|| vr_dstrnbcb ||
                                    ' cdhistor: '|| vr_cdhistor_ori ||
                                    ' dshistor: '|| vr_dshistor_ori ||
                                    ' dscritic: '||vr_dscritic || '.';
                           
              -- cria aqrqu
              IF vr_dsmsglog IS NOT NULL THEN

                 -- Incluir log de execução.
                 BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 1
                                           ,pr_des_log      => vr_dsmsglog
                                           ,pr_nmarqlog     => 'pc_crps670'
                                           ,pr_flnovlog     => 'N');
              END IF;
                 -- processar o proximo
                  vr_dscritic := null;

                WHEN no_data_found THEN -- não encontrar mais linhas
                  EXIT;
                WHEN OTHERS THEN

            pc_internal_exception(3, 'Linha do arquivo: ' || rw_arq.des_text);
                
                  IF vr_dscritic IS NULL THEN
              vr_dscritic := 'Erro arquivo ['|| rw_arq.nmarquiv ||']: '||SQLERRM;
                  END IF;
                  RAISE vr_exc_saida;
              END;

            END LOOP;

            -- Varrer registros da lcm para inserir
            BEGIN
              vr_idxlcm := vr_tab_craplcm.first;

              WHILE vr_idxlcm IS NOT NULL LOOP

                BEGIN

                  INSERT INTO craplcm
                      (cdcooper,
                       dtmvtolt,
                       cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrdctabb,
                       nrdocmto,
                       dtrefere,
                       hrtransa,
                       vllanmto,
                       nrdconta,
                       cdhistor,
                       nrseqdig,
                       cdpesqbb,
                       cdorigem)
                  VALUES
                      (vr_tab_craplcm(vr_idxlcm).cdcooper,
                       vr_tab_craplcm(vr_idxlcm).dtmvtolt,
                       vr_tab_craplcm(vr_idxlcm).cdagenci,
                       vr_tab_craplcm(vr_idxlcm).cdbccxlt,
                       vr_tab_craplcm(vr_idxlcm).nrdolote,
                       vr_tab_craplcm(vr_idxlcm).nrdctabb,
                       vr_tab_craplcm(vr_idxlcm).nrdocmto,
                       vr_tab_craplcm(vr_idxlcm).dtrefere,
                       vr_tab_craplcm(vr_idxlcm).hrtransa,
                       vr_tab_craplcm(vr_idxlcm).vllanmto,
                       vr_tab_craplcm(vr_idxlcm).nrdconta,
                       vr_tab_craplcm(vr_idxlcm).cdhistor,
                       vr_tab_craplcm(vr_idxlcm).nrseqdig,
                       vr_tab_craplcm(vr_idxlcm).cdpesqbb,
                       vr_tab_craplcm(vr_idxlcm).cdorigem);

                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir craplcm: ' || vr_tab_craplcm(vr_idxlcm).nrdconta || SQLERRM;
                    RAISE vr_exc_saida;
                END;

                 vr_dsmsglog := to_char(vr_tab_craplcm(vr_idxlcm).dtmvtolt, 'dd/mm/yy') ||
                                ' LCMT - ' ||
                                ' cdcooper: '|| LPAD(vr_tab_craplcm(vr_idxlcm).cdcooper,2,0) ||
                                ' nrdconta: '|| LPAD(vr_tab_craplcm(vr_idxlcm).nrdconta,12,0) ||
                                ' cdpesqbb: '|| vr_tab_craplcm(vr_idxlcm).cdpesqbb ||
                                ' nrdocmto: '|| vr_tab_craplcm(vr_idxlcm).nrdocmto ||
                                ' nrnsucap: '|| substr(vr_tab_craplcm(vr_idxlcm).nrdocmto,4,6) ||
                                ' cdhistor: '|| vr_tab_craplcm(vr_idxlcm).cdhistor ||
                                ' vllanmto: '|| vr_tab_craplcm(vr_idxlcm).vllanmto || '.';

              -- cria aqrqu
              IF vr_dsmsglog IS NOT NULL THEN

                 -- Incluir log de execução.
                 BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 1
                                           ,pr_des_log      => vr_dsmsglog
                                           ,pr_nmarqlog     => 'pc_crps670'
                                           ,pr_flnovlog     => 'N');
              END IF;

          -- Inicializar vetor de lote caso nao exista para a coop
          vr_idx_lot := lpad(vr_tab_craplcm(vr_idxlcm).cdcooper,3,'0')||lpad(vr_tab_craplcm(vr_idxlcm).cdagenci,5,'0');
          if not vr_tab_craplot.exists(vr_idx_lot) then
            vr_tab_craplot(vr_idx_lot).nrseqdig := 0;
            vr_tab_craplot(vr_idx_lot).qtcompln := 0;
            vr_tab_craplot(vr_idx_lot).qtinfoln := 0;
            vr_tab_craplot(vr_idx_lot).vlcompdb := 0;
            vr_tab_craplot(vr_idx_lot).vlinfodb := 0;
          end if;
          
          -- Acumular
          vr_tab_craplot(vr_idx_lot).cdcooper := vr_tab_craplcm(vr_idxlcm).cdcooper;
          vr_tab_craplot(vr_idx_lot).cdagenci := vr_tab_craplcm(vr_idxlcm).cdagenci;
          vr_tab_craplot(vr_idx_lot).nrseqdig := greatest(vr_tab_craplot(vr_idx_lot).nrseqdig,vr_tab_craplcm(vr_idxlcm).nrseqdig);
          vr_tab_craplot(vr_idx_lot).qtcompln := vr_tab_craplot(vr_idx_lot).qtcompln + 1;
          vr_tab_craplot(vr_idx_lot).qtinfoln := vr_tab_craplot(vr_idx_lot).qtinfoln + 1;
          vr_tab_craplot(vr_idx_lot).vlcompdb := vr_tab_craplot(vr_idx_lot).vlcompdb + vr_tab_craplcm(vr_idxlcm).vllanmto;
          vr_tab_craplot(vr_idx_lot).vlinfodb := vr_tab_craplot(vr_idx_lot).vlinfodb + vr_tab_craplcm(vr_idxlcm).vllanmto;

          -- Buscar o proximo
                vr_idxlcm := vr_tab_craplcm.next(vr_idxlcm);
              END LOOP;
            END;

            -- Varrer registros da temptable da crapdcb para inserir
            BEGIN
              vr_idxdcb := vr_tab_crapdcb.first;

              WHILE vr_idxdcb IS NOT NULL LOOP
                IF vr_tab_crapdcb(vr_idxdcb).operacao = 'I' THEN
                  BEGIN
                    INSERT INTO crapdcb
                       (tpmensag
                       ,nrnsucap
                       ,dtdtrgmt
                       ,hrdtrgmt
                       ,cdcooper
                       ,nrdconta
                       ,nrseqarq
                       ,nrinstit
                       ,cdprodut
                       ,nrcrcard
                       ,tpdtrans
                       ,cddtrans
                       ,cdhistor
                       ,dtdtrans
                       ,dtpostag
                       ,dtcnvvlr
                       ,vldtrans
                       ,vldtruss
                       ,cdautori
                       ,dsdtrans
                       ,cdcatest
                       ,cddmoeda
                       ,vlmoeori
                       ,cddreftr
                       ,cdagenci
                       ,nridvisa
                       ,cdtrresp
                       ,incoopon
                       ,txcnvuss
                       ,cdautban
                       ,idtrterm
                       ,tpautori
                       ,cdproces
                       ,dstrorig
                       ,nrnsuori
                       ,dtmvtolt
                       )
                    VALUES
                      (vr_tab_crapdcb(vr_idxdcb).det.tpmensag
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt
                      ,vr_tab_crapdcb(vr_idxdcb).det.hrdtrgmt
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrdconta
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrseqarq
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrinstit
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdprodut
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrcrcard
                      ,vr_tab_crapdcb(vr_idxdcb).det.tpdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdhistor
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtpostag
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr
                      ,vr_tab_crapdcb(vr_idxdcb).det.vldtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.vldtruss
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdautori
                      ,vr_tab_crapdcb(vr_idxdcb).det.dsdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdcatest
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddmoeda
                      ,vr_tab_crapdcb(vr_idxdcb).det.vlmoeori
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddreftr
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdagenci
                      ,vr_tab_crapdcb(vr_idxdcb).det.nridvisa
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdtrresp
                      ,vr_tab_crapdcb(vr_idxdcb).det.incoopon
                      ,vr_tab_crapdcb(vr_idxdcb).det.txcnvuss
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdautban
                      ,vr_tab_crapdcb(vr_idxdcb).det.idtrterm
                      ,vr_tab_crapdcb(vr_idxdcb).det.tpautori
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdproces
                      ,vr_tab_crapdcb(vr_idxdcb).det.dstrorig
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrnsuori
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtmvtolt
                     );
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir crapdcb: '||SQLERRM 
                      || 'nsu: '|| vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                      || 'cop: '||vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                      || 'con: ' ||vr_tab_crapdcb(vr_idxdcb).det.nrdconta;
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  BEGIN
                    UPDATE crapdcb
                       SET nrseqarq = vr_tab_crapdcb(vr_idxdcb).det.nrseqarq,
                           nrinstit = vr_tab_crapdcb(vr_idxdcb).det.nrinstit,
                           cdprodut = vr_tab_crapdcb(vr_idxdcb).det.cdprodut,
                           nrcrcard = vr_tab_crapdcb(vr_idxdcb).det.nrcrcard,
                           tpdtrans = vr_tab_crapdcb(vr_idxdcb).det.tpdtrans,
                           cdhistor = vr_tab_crapdcb(vr_idxdcb).det.cdhistor,
                           dtpostag = vr_tab_crapdcb(vr_idxdcb).det.dtpostag,
                           dtcnvvlr = vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr,
                           vldtruss = vr_tab_crapdcb(vr_idxdcb).det.vldtruss,
                           cdautori = vr_tab_crapdcb(vr_idxdcb).det.cdautori,
                           cdcatest = vr_tab_crapdcb(vr_idxdcb).det.cdcatest,
                           vlmoeori = vr_tab_crapdcb(vr_idxdcb).det.vlmoeori,
                           cddreftr = vr_tab_crapdcb(vr_idxdcb).det.cddreftr,
                           cdagenci = vr_tab_crapdcb(vr_idxdcb).det.cdagenci,
                           nridvisa = vr_tab_crapdcb(vr_idxdcb).det.nridvisa,
                           cdtrresp = vr_tab_crapdcb(vr_idxdcb).det.cdtrresp,
                           incoopon = vr_tab_crapdcb(vr_idxdcb).det.incoopon,
                           txcnvuss = vr_tab_crapdcb(vr_idxdcb).det.txcnvuss,
                           cdautban = vr_tab_crapdcb(vr_idxdcb).det.cdautban,
                           tpautori = vr_tab_crapdcb(vr_idxdcb).det.tpautori,
                           cdproces = vr_tab_crapdcb(vr_idxdcb).det.cdproces
                     WHERE ROWID = vr_tab_crapdcb(vr_idxdcb).rowid_dcb;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar crapdcb: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END if;
                
                vr_idxdcb := vr_tab_crapdcb.next(vr_idxdcb);
              END LOOP;
            END;

      -- Alimentar tabela temporia com dados de LOTE
      vr_idx_lot := vr_tab_craplot.first;
      loop
        exit when vr_idx_lot is null;
        -- Gerar dados
            BEGIN
          insert into tbgen_batch_relatorio_wrk(cdcooper
                                               ,cdprograma
                                               ,dsrelatorio
                                               ,dtmvtolt
                                               ,dschave
                                               ,cdagenci
                                               ,dscritic)
                                         values(pr_cdcooper
                                               ,vr_cdprogra
                                               ,'CRAPLOT_CET'
                                               ,pr_dtmvtolt
                                               ,vr_tab_craplot(vr_idx_lot).cdcooper
                                               ,vr_tab_craplot(vr_idx_lot).cdagenci
                                               ,';'||vr_tab_craplot(vr_idx_lot).nrseqdig||';'||     
                                                     vr_tab_craplot(vr_idx_lot).qtcompln||';'||
                                                     vr_tab_craplot(vr_idx_lot).qtinfoln||';'||
                                                     vr_tab_craplot(vr_idx_lot).vlcompdb||';'||
                                                     vr_tab_craplot(vr_idx_lot).vlinfodb||';');

            EXCEPTION
              WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk LOT: '||sqlerrm;  
            raise vr_exc_saida; 
            END;
        vr_idx_lot := vr_tab_craplot.next(vr_idx_lot);
      end loop;

      -- Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe           
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par
                     ,pr_flgsucesso => 1); 

      -- Caso execucao paralela
      IF pr_idparale <> 0 THEN
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                           ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                           ,pr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_nrseqexe
                                    ,pr_des_erro => vr_dscritic);  
        -- Salvar informacoes no banco de dados
           COMMIT;
        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- loga a mensagem de critica
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;        

        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_nrseqexe,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => pr_nrseqexe
                                      ,pr_des_erro => vr_dscritic);
        end if;   

        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS670: ' || SQLERRM;
        pc_internal_exception(3, pr_dscritic);

        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_nrseqexe,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => pr_nrseqexe
                                      ,pr_des_erro => vr_dscritic);
        end if; 

        ROLLBACK;
    END;

  END pc_proces_arq_cet_bancoob;  
begin
  
    update tbgen_batch_relatorio_wrk a
       set a.dscritic = '7560005474080090750637   2C5102803201904042019280320190000000966200000009662383477SUNSHINE 305           MEDLEY         FL0000084000000009662                       004444000000201294               05021303262143470010000000000000013701201        12000000400                                          '
     where a.cdcooper = 3
       and a.cdagenci in (34)
       and a.cdprograma = 'CRPS670'
       and a.dsrelatorio = 'DADOS_ARQ'
       and a.dtmvtolt = '04/04/2019'
       and a.dscritic like '%50213%'
       and SUBSTR(a.dscritic, 1, 5) not in ('CEXT0', 'CEXT9');
       
       update crapdcb b
          set hrdtrgmt = 214343 
        where b.nrdconta = 201294 
          and b.cdcooper = 9 
          and b.dtdtrgmt = '26/03/2019' 
          and nrnsucap = 50213 
          and nrseqarq = 1152;
      commit;
        
    vr_dtcxtmig := to_date(gene0001.fn_param_sistema('CRED',3,'DT_CEXT_CTA_MIGRADA'));
    
  -- Call the procedure
  pc_proces_arq_cet_bancoob(pr_cdcooper => 3,
                            pr_dtmvtolt => to_date('04/04/2019'),
                            pr_dtcxtmig => vr_dtcxtmig,
                            pr_nrseqarq => 1156,
                            pr_nrseqexe => 1,
                            pr_idparale => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic);

  if nvl(vr_cdcritic, 0) <> 0 or vr_dscritic is not null then
    dbms_output.put_line('Erro: ' || vr_dscritic);
  else
    dbms_output.put_line('Executado com sucesso!');
    
    -- Atualizar sequencia do arquivo processado
    UPDATE crapscb
       SET nrseqarq = 1156,
           dtultint = SYSDATE
     WHERE crapscb.tparquiv = 2;
     commit;
  end if;
end;
0
0
