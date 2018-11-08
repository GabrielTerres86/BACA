CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS250 (pr_cdcooper IN crapcop.cdcooper%type   --> Codigo da cooperativa
                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                      ,pr_nmtelant  IN VARCHAR2               --> Nome da tela anterior
                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                      ,pr_cdcritic OUT crapcri.cdcritic%type  --> Codigo de critica
                      ,pr_dscritic OUT VARCHAR2) IS           --> Descricao de critica
BEGIN  

/* .............................................................................

   Programa: Fontes/crps250.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98.                       Ultima atualizacao: 21/06/2017
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos do BANCOOB de cheques.
               Emite relatorio 203.

   Alteracoes: 02/01/2007 - Reativacao do BANCOOB (Ze Eduardo).
   
               17/05/2007 - Acerto no CREATE craplot, aux_nrdconta e Totais (Ze)

               08/06/2007 - Gravar inf. da conta onde foi efetuado o deposito 
                            na tabela crapfdc e Acerto no aux_nrdctitg (Ze).
                            
               04/07/2007 - Envia email alertando quando nao existe arquivo 
                            para ser integrado (Elton).
               
               19/07/2007 - Alterado para mostrar corretamente no relatorio o
                            nome do arquivo que foi integrado (Elton).

               27/08/2007 - Retirado envio de email (Guilherme).

               21/01/2008 - Acerto na devolucao pela 49 - crapneg - 14989 (ZE).

               22/07/2008 - Corrigido problema de RESTART e contador de
                            REJEITADOS (Evandro).

               18/08/2008 - Alteracao na Aliena 43 para 49 (quando houver
                            contra-ordem) - Tarefa 18.958 (Ze).

               15/09/2008 - Incluido no-error no assign da linha 451 e em caso 
                            de erro, gravar no log e passar para o proximo 
                            registro(Gabriel).

               14/10/2008 - Aumento tamanho do campo nrdconta - Trf 20117 (Ze).

               17/04/2009 - Nao cancelar o programa se tiver alguma devolucao
                            ja cadastrada - Trf 23315 (Ze).

               01/12/2010 - Substituir alinea 43 por 21 e 49 por 28. (Ze).

               08/12/2010 - Condicoes Transferencia de PAC e novo relat 203_99
                            (Guilherme/Supero)
                            
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).

               18/02/2011 - Alterar alinea para 43 quando ja houve uma 1a vez
                            (Guilherme/Supero)
                            
               12/04/2011 - Nao sera permitido a entrada de cheques que estao
                            em custodia ou em desconto de cheques (Adriano).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)
                            
               06/12/2011 - Sustação provisória (André R./Supero). 
               
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                            
               25/06/2012 - Retirada do email fabiano@viacredi.coop.br (Ze).
               
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               08/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)

               20/12/2012 - Adaptacao para Migracao AltoVale (Ze).
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
               
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/10/2013 - Retirado o "new" e comentarios de teste
                            (Adriano)
                            
               08/11/2013 - Adicionado o PA do cooperado ao conteudo do email
                            de notificacao de cheque VLB. (Fabricio)
                            
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
               
               17/01/2014 - Inclusao de VALIDATE craprej, craplot e craplcm 
                            (Carlos)
                            
               01/07/2014 - Substituido e-mail 
                            "juliana.carla@viacredialtovale.coop.br"
                            para
                            "suporte@viacredialtovale.coop.br"  (Daniele).
                            
              25/09/2014 - Ajustes devido a incorporação ca coop. Concredi,
                           incluido tratamento para importar os arquivos da concredi
                           no processo da coop viacredi, porém irá apenas incluir no
                           relatorio de rejeitados (Odirlei/Amcom).

              30/09/2015 - #328382 Conversão Oracle PLSQL crps250 (Carlos)

              23/12/2015 - Ajustar validação da critica na chamada de CHEQ0001.pc_gera_devolucao_cheque 
                           e as validacoes de alinea, conforme revisao de alineas e processo 
                           de devolucao de cheque (Douglas - Melhoria 100)

			  31/03/2016 - Ajuste para nao deixar alinea zerada na validação de historicos
				  		  (Adriano - SD 426308).			    

              21/06/2017 - Removidas condições que validam o valor de cheque VLB e enviam
                           email para o SPB. PRJ367 - Compe Sessao Unica (Lombardi)

              29/05/2018 - Alteração INSERT na craplcm pela chamada da rotina LANC0001
                           PRJ450 - Renato Cordeiro (AMcom)         

............................................................................. */
    DECLARE
    
    --====================== VARIAVEIS PRINCIPAIS ========================
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS250';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(4000);

    --===================== FIM VARIAVEIS PRINCIPAIS =====================

    --======================== CURSORES ==================================
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
            ,cop.cdagebcb
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    
    rw_crapcop cr_crapcop%ROWTYPE;
    
    cr_crapcop_found boolean;
       
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    CURSOR cr_crapcop_concredi IS
      SELECT cop.*            
        FROM crapcop cop
       WHERE cop.cdcooper = 4;    
    rw_crapcop_concredi cr_crapcop_concredi%ROWTYPE;       
    
    CURSOR cr_craptab_CNVBANCOOB (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT t.*
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'GENERI'
       AND t.cdempres = pr_cdcooper
       AND t.cdacesso = 'CNVBANCOOB'
       AND t.tpregist = 001;
    rw_craptab_CNVBANCOOB cr_craptab_CNVBANCOOB%ROWTYPE;
    
    CURSOR cr_craptab_VALORESVLB (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT t.*
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'GENERI'
       AND t.cdempres = 0
       AND t.cdacesso = 'VALORESVLB'
       AND t.tpregist = 0;
     rw_craptab_VALORESVLB cr_craptab_VALORESVLB%ROWTYPE;

    CURSOR cr_craptab_NUMLOTEBCO (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM craptab
     WHERE cdcooper = pr_cdcooper
       AND nmsistem = 'CRED'
       AND tptabela = 'GENERI'
       AND cdempres = 00
       AND cdacesso = 'NUMLOTEBCO'
       AND tpregist = 001;
     rw_craptab_NUMLOTEBCO cr_craptab_NUMLOTEBCO%ROWTYPE;

     CURSOR cr_craptco_concredi (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT *
       FROM craptco
      WHERE craptco.cdcopant = 4
        AND craptco.cdcooper = pr_cdcooper
        AND craptco.nrctaant = pr_nrdconta;
     rw_craptco_concredi cr_craptco_concredi%ROWTYPE;     
     
     CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT *
       FROM crapass
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;
     
     CURSOR cr_craptco (pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT *
       FROM craptco
      WHERE craptco.cdcopant = pr_cdcooper
        AND craptco.nrctaant = pr_nrdconta
        AND craptco.tpctatrf = 1
        AND craptco.flgativo = 1;
     rw_craptco cr_craptco%ROWTYPE;
     
     CURSOR cr_craptrf (pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT *
       FROM craptrf
      WHERE craptrf.cdcooper = pr_cdcooper
        AND craptrf.nrdconta = pr_nrdconta
        AND craptrf.tptransa = 1;
     rw_craptrf cr_craptrf%ROWTYPE;     
     
     CURSOR cr_crapfdc (pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_cdagebcb IN crapcop.cdagebcb%TYPE,
                        pr_nrctachq IN INTEGER,
                        pr_nrcheque IN INTEGER) IS
     SELECT *
       FROM crapfdc
      WHERE cdcooper = pr_cdcooper
        AND cdbanchq = 756
        AND cdagechq = pr_cdagebcb
        AND nrctachq = pr_nrctachq
        AND nrcheque = pr_nrcheque;
     rw_crapfdc cr_crapfdc%ROWTYPE;
     
     CURSOR cr_last_craplcm (pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_nrdconta IN crapass.nrdconta%TYPE,
                             pr_nrdocmto IN INTEGER) IS
     SELECT *
       FROM craplcm
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrdocmto = pr_nrdocmto
        AND cdhistor IN (21, 313, 340)
      ORDER BY progress_recid DESC;
     rw_last_craplcm cr_last_craplcm%ROWTYPE;

     CURSOR cr_last_craplcm2 (pr_cdcooper IN crapcop.cdcooper%TYPE, 
                              pr_nrdconta IN crapass.nrdconta%TYPE, 
                              pr_nrdocmto IN INTEGER) IS     
     SELECT *
       FROM craplcm
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND cdhistor IN (47, 191, 338, 573)
        AND nrdocmto = pr_nrdocmto
        AND cdpesqbb = '21'
        AND ROWNUM = 1
      ORDER BY progress_recid DESC;
     rw_last_craplcm2 cr_last_craplcm%ROWTYPE; 

     CURSOR cr_crapcor (pr_cdcooper IN crapcop.cdcooper%TYPE, 
                        pr_cdbanchq IN crapcor.cdbanchq%TYPE, 
                        pr_cdagechq IN crapcor.cdagechq%TYPE,
                        pr_nrctachq IN crapcor.nrctachq%TYPE,
                        pr_nrcheque IN INTEGER) IS
     SELECT *
       FROM crapcor
      WHERE cdcooper = pr_cdcooper
        AND cdbanchq = pr_cdbanchq
        AND cdagechq = pr_cdagechq
        AND nrctachq = pr_nrctachq
        AND nrcheque = pr_nrcheque
        AND flgativo = 1;
     rw_crapcor cr_crapcor%ROWTYPE;
     
     CURSOR cr_crapcor_756 (pr_cdcooper IN crapcop.cdcooper%TYPE, 
                            pr_cdagebcb IN crapcop.cdagebcb%TYPE,
                            pr_nrdconta IN crapass.nrdconta%TYPE,
                            pr_nrdocmto IN INTEGER) IS
     SELECT *
       FROM crapcor
      WHERE cdcooper = pr_cdcooper
        AND cdbanchq = 756
        AND cdagechq = pr_cdagebcb
        AND nrdctabb = pr_nrdconta
        AND nrcheque = pr_nrdocmto
        AND flgativo = 1;        
     rw_crapcor_756 cr_crapcor_756%ROWTYPE;     
     
     CURSOR cr_crapneg (pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrdocmto IN INTEGER) IS
     SELECT *
       FROM crapneg
      WHERE crapneg.cdcooper = pr_cdcooper
        AND crapneg.nrdconta = pr_nrdconta
        AND crapneg.nrdocmto = pr_nrdocmto
        AND crapneg.cdhisest = 1
        AND ROWNUM = 1
      ORDER BY crapneg.nrseqdig DESC;
      rw_crapneg cr_crapneg%ROWTYPE;

      CURSOR cr_crapcst (pr_cdcooper IN crapfdc.cdcooper%TYPE, 
                         pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE, 
                         pr_cdbanchq IN crapfdc.cdbanchq%TYPE,
                         pr_cdagechq IN crapfdc.cdagechq%TYPE,
                         pr_nrctachq IN crapfdc.nrctachq%TYPE,
                         pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT *
        FROM crapcst
       WHERE cdcooper = pr_cdcooper
         AND cdcmpchq = pr_cdcmpchq
         AND cdbanchq = pr_cdbanchq
         AND cdagechq = pr_cdagechq
         AND nrctachq = pr_nrctachq
         AND nrcheque = pr_nrcheque;
      rw_crapcst cr_crapcst%ROWTYPE;
      
      CURSOR cr_crapcdb (pr_cdcooper IN crapfdc.cdcooper%TYPE, 
                         pr_cdcmpchq IN crapfdc.cdcmpchq%TYPE, 
                         pr_cdbanchq IN crapfdc.cdbanchq%TYPE,
                         pr_cdagechq IN crapfdc.cdagechq%TYPE,
                         pr_nrctachq IN crapfdc.nrctachq%TYPE,
                         pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT *
        FROM crapcdb
       WHERE cdcooper = pr_cdcooper
         AND cdcmpchq = pr_cdcmpchq
         AND cdbanchq = pr_cdbanchq
         AND cdagechq = pr_cdagechq
         AND nrctachq = pr_nrctachq
         AND nrcheque = pr_nrcheque;
      rw_crapcdb cr_crapcdb%ROWTYPE;
     
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE, 
                         pr_dtmvtolt IN crapdat.dtmvtolt%TYPE, 
                         pr_cdagenci IN crapass.cdagenci%TYPE,
                         pr_cdbccxlt IN VARCHAR2, 
                         pr_nrdolote IN INTEGER) IS
      SELECT *
        FROM craplot
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci 
         AND cdbccxlt = pr_cdbccxlt 
         AND nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      CURSOR cr_craplcm (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                         pr_cdagenci IN craplcm.cdagenci%TYPE,
                         pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                         pr_nrdolote IN craplcm.nrdolote%TYPE,
                         pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                         pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
      SELECT *
        FROM craplcm
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci
         AND cdbccxlt = pr_cdbccxlt
         AND nrdolote = pr_nrdolote
         AND nrdctabb = pr_nrdctabb
         AND nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;

      CURSOR cr_craprej (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtrefere IN craprej.dtrefere%TYPE) IS
      SELECT *
        FROM craprej r
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere
       ORDER BY r.nrdconta;
      rw_craprej cr_craprej%ROWTYPE;
      
      CURSOR cr_craprej_999 (pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_dtrefere IN craprej.dtrefere%TYPE) IS
      SELECT *
        FROM craprej r
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere
         AND r.cdcritic = 999
       ORDER BY r.nrdconta;
      rw_craprej_999 cr_craprej_999%ROWTYPE;
      


    --========================== FIM CURSORES ==========================


    --============================ VARIAVEIS ===========================

    -- Variaveis para controle de restart
    vr_nrctares crapass.nrdconta%TYPE;    --> Numero da conta de restart
    vr_dsrestar VARCHAR2(4000);           --> String generica com informac?es para restart
    vr_inrestar INTEGER;                  --> Indicador de Restart
    vr_nrctremp INTEGER := 0;             --> Numero do contrato do Restart
    vr_dslinhas VARCHAR2(32767) := '000,';--> Linhas processadas do Restart (inicializada para evitar problemas com null)
    vr_qtregres NUMBER := 0;              --> Quantidade de registros ignorados por terem sido processados antes do restart

    -- Variável para armazenar as informações em XML    
    vr_clobxml         CLOB;
    vr_caminho         VARCHAR2(100);

    vr_nmarquiv        VARCHAR2(100);
    vr_cdageban_04     VARCHAR2(4);
    vr_typ_said        VARCHAR2(50);

    vr_listadir        VARCHAR2(2000);
    vr_listadiratual   VARCHAR2(2000); -- dir da coop atual
    vr_dirintegra      VARCHAR2(200);
    
    vr_aux_cdbancob    VARCHAR2(3) := '756';
    vr_aux_cdageban    VARCHAR2(4);
    vr_aux_nmarqban    VARCHAR2(6);
    vr_aux_dtleiarq    DATE;
    vr_aux_dtauxili    VARCHAR2(8);
    vr_aux_vlchqvlb    NUMBER(25,2);
    vr_aux_flgrejei    BOOLEAN;
    vr_aux_vldebito    NUMBER(25,2);
    vr_aux_qtcompln    INTEGER;
    vr_aux_vlcompdb    NUMBER(25,2);
 
    vr_aux_contareg    NUMBER;
 
    vr_tab_linhas gene0009.typ_tab_linhas;    

    vr_aux_nrseqarq    INTEGER;
    vr_aux_cdalinea    NUMBER;
    vr_aux_indevchq    NUMBER;
    
    vr_aux_nrdolote    INTEGER;
    vr_aux_nrdolot2    INTEGER;

    vr_aux_nrdconta    INTEGER;
    vr_aux_nrdocmto    INTEGER;
    vr_aux_vllanmto    NUMBER(25,2);
    vr_aux_cdbanchq    INTEGER;
    vr_aux_cdcmpchq    INTEGER;
    vr_aux_cdagechq    INTEGER;
    vr_aux_nrctachq    NUMBER;
    vr_aux_nrlotchq    INTEGER;
    vr_aux_sqlotchq    INTEGER;
    vr_aux_cdpesqbb    VARCHAR2(200);
    
    vr_ant_nrdconta    INTEGER;
    vr_aux_nrdctabb    INTEGER;
    vr_dstextab        craptab.dstextab%TYPE;
    vr_numlotebco      VARCHAR2(8);
    vr_aux_nrdctitg    VARCHAR2(8);

    vr_assunto         VARCHAR2(100);
    vr_conteudo        VARCHAR2(4000);

    vr_aux_cdagenci    INTEGER := 1;
    vr_aux_tplotmov    INTEGER := 1;

    vr_flgcraprej      BOOLEAN;

    vr_craptrf_found   BOOLEAN;

    -- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp      gene0002.typ_split;

    vr_des_xml         CLOB;
    vr_dsdireto        VARCHAR2(200);
    vr_dsdirarq        VARCHAR2(200);   -- Caminho e nome do arquivo      
    vr_Bufdes_xml      VARCHAR2(32000); -- Dados relatorio
    vr_typ_saida       VARCHAR2(4000);
    
    vr_tot_qtregrec    INTEGER := 0;
    vr_tot_qtregint    INTEGER := 0;
    vr_tot_qtregrej    INTEGER := 0;
    vr_tot_vlregrec    NUMBER(25,2);
    vr_tot_vlregint    NUMBER(25,2);
    vr_tot_vlregrej    NUMBER(25,2);
    vr_aux_flgfirst    BOOLEAN;
    vr_nmarqimp        VARCHAR2(200);
    vr_cdempres        PLS_INTEGER;
    flg_detalhes       PLS_INTEGER;
    
    vr_rel_dspesqbb    VARCHAR2(4000);    
                
    TYPE typ_rec_craprej is record (cdagenci craprej.cdagenci%type,
                                    cdbccxlt craprej.cdbccxlt%type,
                                    cdcritic craprej.cdcritic%type,
                                    cdempres craprej.cdempres%type,
                                    dtmvtolt craprej.dtmvtolt%type,
                                    nrdconta craprej.nrdconta%type,
                                    nrdolote craprej.nrdolote%type,
                                    tpintegr craprej.tpintegr%type,
                                    cdhistor craprej.cdhistor%type,
                                    vllanmto craprej.vllanmto%type,
                                    tplotmov craprej.tplotmov%type,
                                    cdpesqbb craprej.cdpesqbb%type,
                                    dshistor craprej.dshistor%type,
                                    nrseqdig craprej.nrseqdig%type,
                                    nrdocmto craprej.nrdocmto%type,
                                    nrdctabb craprej.nrdctabb%type,
                                    indebcre craprej.indebcre%type,
                                    dtrefere craprej.dtrefere%type,
                                    vlsdapli craprej.vlsdapli%type,
                                    dtdaviso craprej.dtdaviso%type,
                                    vldaviso craprej.vldaviso%type,
                                    nraplica craprej.nraplica%type,
                                    cdcooper craprej.cdcooper%type,
                                    nrdctitg craprej.nrdctitg%type,
                                    dscritic crapcri.dscritic%type);                                    
    TYPE typ_tab_craprej IS TABLE OF typ_rec_craprej 
       INDEX BY VARCHAR2(100);       
    vr_tab_craprej typ_tab_craprej;
    
    vr_idx_rej VARCHAR2(100);
    
    vr_indice  VARCHAR2(100);

    vr_rowid     ROWID;
    vr_nmtabela  VARCHAR2(100);
    vr_incrineg  INTEGER;

    vr_rw_craplot  lanc0001.cr_craplot%ROWTYPE;
    vr_tab_retorno lanc0001.typ_reg_retorno;
    
    --======================= SUBROTINAS INTERNAS ==========================       

    PROCEDURE pc_verifica_incorporacoes(pr_index INTEGER) IS
    BEGIN
      -- Se a cooperativa for a viacredi  e o cdageban for igual coop. migrada 
      -- está processando arquivo da concredi
      IF pr_cdcooper = 1 AND vr_aux_cdageban = vr_cdageban_04 THEN
        OPEN cr_craptco_concredi (pr_cdcooper => pr_cdcooper, pr_nrdconta => vr_aux_nrdconta);
        FETCH cr_craptco_concredi INTO rw_craptco_concredi;
        
        IF cr_craptco_concredi%FOUND THEN
          CLOSE cr_craptco_concredi;
          BEGIN            
            INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrdocmto, vllanmto, nrseqdig, cdcritic, cdpesqbb)
            VALUES(pr_cdcooper                                  --cdcooper
                  ,to_char(vr_aux_dtauxili,'dd/mm/RRRR')        --dtrefere
                  ,vr_aux_nrdconta                              --nrdconta
                  ,vr_ant_nrdconta                              --nrdocmto
                  ,vr_tab_linhas(pr_index)('VLDOCMTO').numero  --vllanmto
                  ,vr_aux_nrseqarq                              --nrseqdig
                  ,999                                          --cdcritic
                  ,vr_aux_cdpesqbb                              --cdpesqbb
                  ); 
            vr_flgcraprej := true;
            RETURN;                                        
            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro craprej (#1): '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craptco_concredi;
        END IF;        
      END IF;
      
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper, pr_nrdconta => vr_aux_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        BEGIN            
          INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrdocmto, vllanmto, nrseqdig, cdcritic, cdpesqbb)
          VALUES(pr_cdcooper          --cdcooper
                ,vr_aux_dtauxili      --dtrefere
                ,vr_aux_nrdconta      --nrdconta
                ,vr_aux_nrdocmto      --nrdocmto
                ,vr_aux_vllanmto      --vllanmto
                ,vr_aux_nrseqarq      --nrseqdig
                ,9                    --cdcritic
                ,vr_aux_cdpesqbb      --cdpesqbb
                ); 
          vr_flgcraprej := true;
          RETURN;                             
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro craprej (#2): '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      ELSE
        CLOSE cr_crapass;
      END IF;

      IF pr_cdcooper = 1 OR pr_cdcooper = 2 THEN
        OPEN cr_craptco(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => vr_aux_nrdconta);
        FETCH cr_craptco INTO rw_craptco;
        
        IF cr_craptco%FOUND THEN
          CLOSE cr_craptco;
          vr_ant_nrdconta := vr_aux_nrdocmto * 10;          
          IF gene0005.fn_calc_digito(pr_nrcalcul => vr_ant_nrdconta) THEN
            NULL;
          END IF;          
          BEGIN
            INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrdocmto, vllanmto, nrseqdig, cdcritic, cdpesqbb)
            VALUES(pr_cdcooper                                  --cdcooper
                  ,vr_aux_dtauxili                              --dtrefere
                  ,vr_aux_nrdconta                              --nrdconta
                  ,vr_ant_nrdconta                              --nrdocmto
                  ,vr_tab_linhas(pr_index)('VLDOCMTO').numero  --vllanmto
                  ,vr_aux_nrseqarq                              --nrseqdig
                  ,999                                          --cdcritic
                  ,vr_aux_cdpesqbb                              --cdpesqbb
                  );
            vr_flgcraprej := true;
            RETURN;
            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro craprej (#3): '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craptco;
        END IF;
      END IF;
      
      IF rw_crapass.cdsitdtl IN (2,4,5,6,7,8) THEN
        OPEN cr_craptrf (pr_cdcooper => pr_cdcooper, pr_nrdconta => vr_aux_nrdconta);
        FETCH cr_craptrf INTO rw_craptrf;
        vr_craptrf_found := cr_craptrf%FOUND;
        CLOSE cr_craptrf;
        
        IF vr_craptrf_found THEN
          vr_aux_nrdconta := rw_craptrf.nrsconta;
          pc_verifica_incorporacoes(pr_index);
        END IF;
      END IF;      
      
      vr_flgcraprej := false; -- não criou craprej
          
    END; -- fim pc_verifica_incorporacoes

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fimarq    IN BOOLEAN default false) IS
    BEGIN
      --Verificar se ja atingiu o tamanho do buffer, ou se é o final do xml
      IF length(vr_Bufdes_xml) + length(pr_des_dados) > 31000 OR pr_fimarq THEN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(vr_Bufdes_xml||pr_des_dados),vr_Bufdes_xml||pr_des_dados);
        vr_Bufdes_xml := null;
      ELSE
        --armazena no buffer
        vr_Bufdes_xml := vr_Bufdes_xml||pr_des_dados;
      END IF;
    END pc_escreve_xml;
    
    
    --======================= FIM SUBROTINAS ===============================    
    
    BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;

    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    -- Tratamento e retorno de valores de restart
    btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                              ,pr_cdprogra  => vr_cdprogra   --> Codigo do programa
                              ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                              ,pr_nrctares  => vr_nrctares   --> Numero da conta de restart
                              ,pr_dsrestar  => vr_dsrestar   --> String generica com informacoes para restart
                              ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                              ,pr_cdcritic  => vr_cdcritic   --> Codigo de erro
                              ,pr_des_erro  => vr_dscritic); --> Saida de erro
    -- Se encontrou erro, gerar excec?o
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    -- Se houver indicador de restart, mas nao veio conta
    IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
      -- Remover o indicador
      vr_inrestar := 0;
    END IF;


    -- se for a cooperativa Viacredi, deve buscar também os arquivos da Concredi, que foi migrada
    IF pr_cdcooper = 1 THEN
        OPEN cr_crapcop_concredi;
        FETCH cr_crapcop_concredi INTO rw_crapcop_concredi;
        -- SE NÃO ENCONTRAR
        IF cr_crapcop_concredi%NOTFOUND THEN
          CLOSE cr_crapcop_concredi;
          vr_cdcritic := 651;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcop_concredi;
        END IF;

        vr_nmarquiv := 'integra/1'||trim(to_char(rw_crapcop_concredi.cdagebcb,'9999'))||'*.RT*';
        vr_cdageban_04 := trim(to_char(rw_crapcop_concredi.cdagebcb,'9999'));

        -- diretorio integra da cooperativa
        vr_dirintegra := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'integra'); 
        BEGIN
          gene0001.pc_lista_arquivos(pr_path     => vr_dirintegra
                                    ,pr_pesq     => '1'||trim(to_char(rw_crapcop_concredi.cdagebcb,'9999'))||'%.RT%'
                                    ,pr_listarq  => vr_listadir
                                    ,pr_des_erro => vr_dscritic);

          -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
          IF TRIM(vr_dscritic) IS NOT NULL THEN            
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic);
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao recuperar lista de arquivos de integra: '||sqlerrm;
        END;

    END IF;


  -- Busca dados da cooperativa 
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  CLOSE cr_crapcop;
          
  vr_nmarquiv := 'integra/1'||trim(to_char(rw_crapcop.cdagebcb,'9999'))||'*.RT*';

  -- diretorio integra da cooperativa (caminho absoluto)
  vr_dirintegra := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'integra');

  gene0001.pc_lista_arquivos(pr_path     => vr_dirintegra
                            ,pr_pesq     => '1'||trim(to_char(rw_crapcop.cdagebcb,'9999'))||'%.RT%'
                            ,pr_listarq  => vr_listadiratual
                            ,pr_des_erro => vr_dscritic);

  -- Se for viacredi, une arquivos da concredi
  IF pr_cdcooper = 1 THEN
    IF vr_listadir IS NOT NULL THEN
      IF vr_listadiratual IS NOT NULL THEN 
        vr_listadir := vr_listadir||','||vr_listadiratual;
      END IF;
    ELSE
      vr_listadir := vr_listadiratual;
    END IF;
  ELSE
    vr_listadir := vr_listadiratual;
  END IF;

  IF vr_listadir IS NULL THEN
    vr_cdcritic := 182;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
  
  OPEN cr_craptab_CNVBANCOOB(pr_cdcooper);
  FETCH cr_craptab_CNVBANCOOB INTO rw_craptab_CNVBANCOOB;
  IF cr_craptab_CNVBANCOOB%NOTFOUND THEN
    CLOSE cr_craptab_CNVBANCOOB;
    vr_cdcritic := 472;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' (#1)';
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);    
    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_craptab_CNVBANCOOB;
  END IF;

  vr_aux_cdbancob := '756';
  vr_aux_cdageban := trim(to_char(rw_crapcop.cdagebcb,'9999'));
  vr_aux_nmarqban := SUBSTR(rw_craptab_CNVBANCOOB.dstextab,10,6);
  
  vr_aux_dtleiarq := rw_crapdat.dtmvtoan;
  vr_aux_dtauxili := to_char(rw_crapdat.dtmvtoan,'RRRRmmdd');
  
  OPEN cr_craptab_VALORESVLB(pr_cdcooper);
  FETCH cr_craptab_VALORESVLB INTO rw_craptab_VALORESVLB;
  IF cr_craptab_VALORESVLB%FOUND THEN
    vr_aux_vlchqvlb := to_number(GENE0002.fn_busca_entrada(pr_postext     => 2
                                                          ,pr_dstext      => rw_craptab_VALORESVLB.dstextab
                                                          ,pr_delimitador => ';'));
  ELSE
    vr_aux_vlchqvlb := 0;
  END IF;
  CLOSE cr_craptab_VALORESVLB;

  --Carregar a lista de arquivos txt na pl/table
  vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listadir);  
  
  -- Leitura da PL/Table e processamento dos arquivos
  FOR idx in 1..vr_tab_arqtmp.count LOOP
   
    vr_aux_flgrejei := FALSE;
    vr_aux_vldebito := 0;
    vr_aux_qtcompln := 0;
    vr_aux_vlcompdb := 0;
    
    IF pr_cdcooper = 1 THEN
      IF INSTR(vr_tab_arqtmp(idx), '1'||trim(to_char(rw_crapcop_concredi.cdagebcb,'9999'))) > 0 THEN
        vr_aux_cdageban := trim(to_char(rw_crapcop_concredi.cdagebcb,'9999'));
      ELSE
        vr_aux_cdageban := trim(to_char(rw_crapcop.cdagebcb,'9999'));
      END IF;      
    END IF;

    gene0009.pc_importa_arq_layout(pr_nmlayout => 'CEL615', 
                                   pr_dsdireto => vr_dirintegra, 
                                   pr_nmarquiv => vr_tab_arqtmp(idx), 
                                   pr_dscritic => vr_dscritic, 
                                   pr_tab_linhas => vr_tab_linhas);

    -- validação de header
    IF vr_tab_linhas(1)('CONTROLE').numero <> 0 THEN
      vr_cdcritic := 468;
    ELSIF vr_tab_linhas(1)('NMARQUIVO').texto <> vr_aux_nmarqban THEN
      vr_cdcritic := 173;
    ELSIF vr_tab_linhas(1)('CDBANDEST').numero <> vr_aux_cdbancob THEN
      vr_cdcritic := 057;
    ELSIF to_char(vr_tab_linhas(1)('DTMOVIMENTO').data,'RRRRmmdd') <> vr_aux_dtauxili THEN
      vr_cdcritic := 013;
    ELSIF vr_cdcritic <> 0 THEN

      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_tab_arqtmp(idx)||' '
                                                    ||'integra/err'
                                                    || substr(vr_tab_arqtmp(idx),12)
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
                                     
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);
      vr_cdcritic := 0;
      continue;
    END IF;

    vr_aux_contareg := 1;
    
    -- loop a partir dos details
    -- calcula totais e valida sequenciais
    FOR i IN 2..vr_tab_linhas.count LOOP    
      vr_aux_contareg := vr_aux_contareg + 1;
      
      IF vr_tab_linhas(i)('$LAYOUT$').texto = 'D' THEN
        IF vr_tab_linhas(i)('CDAGEDEST').numero = to_number(vr_aux_cdageban) AND
           vr_tab_linhas(i)('CDBANDEST').numero = to_number(vr_aux_cdbancob) THEN
           vr_aux_vldebito := vr_aux_vldebito + vr_tab_linhas(i)('VLDOCMTO').numero;
        END IF;
      ELSIF vr_tab_linhas(i)('$LAYOUT$').texto = 'T' THEN
        IF vr_aux_contareg <> vr_tab_linhas(i)('SEQARQUIVO').numero THEN
          vr_cdcritic := 504;
        ELSIF vr_aux_vldebito <> vr_tab_linhas(i)('VLARQUIVO').numero THEN
          vr_cdcritic := 505;
        END IF;
        EXIT;
      ELSE
        vr_cdcritic := 513;
        EXIT;
      END IF;     
      
    END LOOP;
    -- details e trailler

    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_tab_arqtmp(idx)||' '
                                                    ||'integra/err'
                                                    || substr(vr_tab_arqtmp(idx),12)
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic || ' - ' 
                                                  || vr_tab_arqtmp(idx));
      vr_cdcritic := 0;
      CONTINUE; -- proximo arquivo
    END IF;   
  
    vr_aux_flgfirst := (vr_inrestar = 0 OR vr_nrctares = 0);
    
    -- msg log notificando integracao do arquivo atual.
    vr_cdcritic := 219;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);    
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                || vr_cdprogra || ' --> '
                                                || vr_dscritic);
    vr_cdcritic := 0;
    -----------------------------------------------

    -- loop a partir dos details
    FOR i IN 2..vr_tab_linhas.count LOOP    
      
      IF vr_tab_linhas(i)('$LAYOUT$').texto = 'D' THEN
        vr_aux_nrseqarq := vr_tab_linhas(i)('SEQARQUIV').numero;
      ELSE
        vr_aux_nrseqarq := vr_tab_linhas(i)('SEQARQUIVO').numero;
      END IF;
      
      IF vr_aux_nrseqarq <= vr_nrctares THEN
        continue;
      END IF;

      vr_aux_cdalinea := 0;
      vr_aux_indevchq := 0;

      IF vr_tab_linhas(i)('$LAYOUT$').texto = 'T' THEN        
        -- Deverá criar o registro
        BEGIN        
          INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrseqdig, vllanmto)
                        VALUES(pr_cdcooper                                  --cdcooper
                              ,vr_aux_dtauxili                              --dtrefere
                              ,999999999                                    --nrdconta
                              ,vr_aux_nrseqarq                              --nrseqdig
                              ,vr_tab_linhas(i)('VLARQUIVO').numero         --vllanmto
                              );
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar CRAPREJ - (#4)' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        IF NOT vr_aux_flgfirst THEN
          
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                     pr_nmsistem => 'CRED',
                                     pr_tptabela => 'GENERI', 
                                     pr_cdempres => 0, 
                                     pr_cdacesso => 'NUMLOTEBCO', 
                                     pr_tpregist => 1);                                   

          IF vr_dstextab IS NULL THEN
            vr_cdcritic := 472;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' (#2)';
            btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                            ,pr_ind_tipo_log       => 2 -- Erro tratato
                            ,pr_des_log            => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic);          
            RAISE vr_exc_saida;
          END IF;
                    
          IF  vr_aux_nrdolote = 7019 THEN
            vr_numlotebco := '7010';
          ELSE            
            vr_numlotebco := to_char(vr_aux_nrdolote + 1, '9999');
          END IF;       
          
          BEGIN
            UPDATE craptab
               SET dstextab = vr_numlotebco
             WHERE cdcooper = pr_cdcooper
               AND nmsistem = 'CRED'
               AND tptabela = 'GENERI'
               AND cdempres = 00
               AND cdacesso = 'NUMLOTEBCO'
               AND tpregist = 001;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar craptab: '||sqlerrm;
              RAISE vr_exc_saida;              
          END;

        END IF; -- flg first
        continue;  
      END IF; -- FIM if trailler      

      vr_aux_nrdconta := vr_tab_linhas(i)('NRDCONTA').numero; 
      vr_aux_nrdocmto := vr_tab_linhas(i)('NRDOCMTO').numero;
      vr_aux_vllanmto := vr_tab_linhas(i)('VLDOCMTO').numero;
      vr_aux_nrseqarq := vr_tab_linhas(i)('SEQARQUIV').numero;
      vr_aux_cdbanchq := vr_tab_linhas(i)('CDBANAPRES').numero;
      vr_aux_cdcmpchq := vr_tab_linhas(i)('LOCALORI').numero;
      vr_aux_cdagechq := vr_tab_linhas(i)('NRAGEDEP').numero;
      vr_aux_nrctachq := vr_tab_linhas(i)('CTADEPOS').numero;
      vr_aux_nrlotchq := vr_tab_linhas(i)('NRDOLOTE').numero;
      vr_aux_sqlotchq := vr_tab_linhas(i)('SEQDOLOTE').numero;
      vr_aux_cdpesqbb := vr_tab_linhas(i)('$LINHA$').texto;
      vr_ant_nrdconta := vr_aux_nrdconta;            
      
      -- Se não ter o digito correto, pega a conta com o digito correto
      IF NOT gene0005.fn_calc_digito(pr_nrcalcul => vr_ant_nrdconta) THEN
        vr_aux_nrdconta := vr_ant_nrdconta;
      END IF;
      
      -- usado na geradev, find lcm e insert lcm
      vr_aux_nrdctabb := vr_aux_nrdconta;
      
      -- Tratamentos de incorporações de cooperativas/PAs
      pc_verifica_incorporacoes(i); 
      
      IF vr_flgcraprej THEN
        continue;
      END IF;

      OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper,
                      pr_cdagebcb => rw_crapcop.cdagebcb,
                      pr_nrctachq => vr_tab_linhas(i)('NRDCONTA').numero,
                      pr_nrcheque => vr_tab_linhas(i)('NRDOCMTO').numero);
      FETCH cr_crapfdc INTO rw_crapfdc;
      
      IF cr_crapfdc%NOTFOUND THEN 
        CLOSE cr_crapfdc;
        vr_cdcritic := 108;
      ELSE
        CLOSE cr_crapfdc;
        vr_aux_nrdocmto := to_number(to_char(rw_crapfdc.nrcheque,'fm999990') || to_char(rw_crapfdc.nrdigchq,'fm9'));
        
        IF rw_crapfdc.tpcheque = 3 THEN
          vr_cdcritic := 289;
        ELSIF rw_crapfdc.dtemschq IS NULL THEN
          vr_cdcritic := 108;
        ELSIF rw_crapfdc.dtretchq IS NULL THEN
          vr_cdcritic := 109;
        ELSIF rw_crapfdc.incheque IN (5,6,7) THEN
          vr_cdcritic := 97;
        ELSIF rw_crapfdc.incheque = 8 THEN
          vr_cdcritic := 320;
        END IF;
        
        IF vr_cdcritic = 0 THEN 
          IF rw_crapfdc.incheque = 1 THEN
            OPEN cr_last_craplcm (pr_cdcooper => pr_cdcooper, 
                                  pr_nrdconta => vr_tab_linhas(i)('NRDCONTA').numero, 
                                  pr_nrdocmto => vr_aux_nrdocmto);
            FETCH cr_last_craplcm INTO rw_last_craplcm;
            
            IF cr_last_craplcm%NOTFOUND THEN
              CLOSE cr_last_craplcm;
              vr_cdcritic := 96;
              IF rw_crapfdc.tpcheque = 1 THEN
                vr_aux_indevchq := 1;
              ELSE
                vr_aux_indevchq := 3;
              END IF;
              vr_aux_cdalinea := 0;
            ELSE
              CLOSE cr_last_craplcm;
              OPEN cr_crapcor (pr_cdcooper => pr_cdcooper, 
                               pr_cdbanchq => rw_crapfdc.cdbanchq, 
                               pr_cdagechq => rw_crapfdc.cdagechq,
                               pr_nrctachq => rw_crapfdc.nrctachq,
                               pr_nrcheque => vr_aux_nrdocmto);
              FETCH cr_crapcor INTO rw_crapcor;

              IF cr_crapcor%NOTFOUND THEN
                vr_cdcritic     := 439;
                vr_aux_indevchq := 1;
                vr_aux_cdalinea := 0;
              ELSIF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                vr_cdcritic     := 96;
                IF rw_crapfdc.tpcheque = 1 THEN
                  vr_aux_indevchq := 1;
                ELSE
                  vr_aux_indevchq := 3;
                END IF;
                vr_aux_cdalinea := 70;
              ELSIF rw_crapcor.dtemscor > rw_last_craplcm.dtmvtolt THEN
                vr_cdcritic := 96;
                IF rw_crapfdc.tpcheque = 1 THEN
                  vr_aux_indevchq := 1;
                ELSE
                  vr_aux_indevchq := 3;
                END IF;
                vr_aux_cdalinea := 0;
              ELSE
                vr_cdcritic := 439;
                IF rw_crapfdc.tpcheque = 1 THEN
                  vr_aux_indevchq := 1;
                ELSE
                  vr_aux_indevchq := 3;
                END IF;
                
                IF rw_crapcor.cdhistor = 835 THEN
                  vr_aux_cdalinea := 28;
                ELSIF rw_crapcor.cdhistor = 815 THEN
                  vr_aux_cdalinea := 21;
                ELSIF rw_crapcor.cdhistor = 818 THEN
                  vr_aux_cdalinea := 20;
                ELSE
                  vr_aux_cdalinea := 21;
                END IF;
              END IF;  
              CLOSE cr_crapcor;
            END IF;            
          END IF;

          FOR rw_crapneg IN cr_crapneg (pr_cdcooper, vr_aux_nrdconta, vr_aux_nrdocmto) LOOP
            IF rw_crapneg.cdobserv IN (12,13) AND rw_crapneg.dtfimest IS NULL THEN
              IF rw_crapfdc.tpcheque = 1 THEN
                vr_aux_indevchq := 1;
              ELSE
                vr_aux_indevchq := 3;
              END IF;
              vr_aux_cdalinea := 49;
              vr_cdcritic     := 414;
            END IF;
          END LOOP;
          
        END IF;  
      END IF; --fim cr_crapfdc found

      OPEN cr_crapcst (pr_cdcooper => rw_crapfdc.cdcooper, 
                       pr_cdcmpchq => rw_crapfdc.cdcmpchq, 
                       pr_cdbanchq => rw_crapfdc.cdbanchq,
                       pr_cdagechq => rw_crapfdc.cdagechq,
                       pr_nrctachq => rw_crapfdc.nrctachq,
                       pr_nrcheque => rw_crapfdc.nrcheque);
      FETCH cr_crapcst INTO rw_crapcst;

      IF cr_crapcst%FOUND THEN
        CLOSE cr_crapcst;
        vr_cdcritic := 757; --757 - Cheque em custodia
        
        -- índice da pl table
        vr_idx_rej := to_char(pr_cdcooper)     || 
                      to_char(vr_aux_dtauxili) || 
                      to_char(vr_aux_nrdconta) || 
                      to_char(vr_aux_nrdocmto) || 
                      to_char(vr_aux_vllanmto) ||
                      to_char(vr_aux_nrseqarq) ||
                      to_char(vr_cdcritic)     ||
                      to_char(vr_aux_cdpesqbb);
        
        vr_tab_craprej(vr_idx_rej).cdcooper := pr_cdcooper;
        vr_tab_craprej(vr_idx_rej).dtrefere := vr_aux_dtauxili;
        vr_tab_craprej(vr_idx_rej).nrdconta := vr_aux_nrdconta;
        vr_tab_craprej(vr_idx_rej).nrdocmto := vr_aux_nrdocmto;
        vr_tab_craprej(vr_idx_rej).vllanmto := vr_aux_vllanmto;
        vr_tab_craprej(vr_idx_rej).nrseqdig := vr_aux_nrseqarq;
        vr_tab_craprej(vr_idx_rej).cdcritic := vr_cdcritic;
        vr_tab_craprej(vr_idx_rej).cdpesqbb := vr_aux_cdpesqbb;
        vr_tab_craprej(vr_idx_rej).dscritic := 'Conta ' || to_char(rw_crapcst.nrdconta);
        
      ELSE 
        CLOSE cr_crapcst;  
      END IF;      

      OPEN cr_crapcdb (pr_cdcooper => rw_crapfdc.cdcooper, 
                       pr_cdcmpchq => rw_crapfdc.cdcmpchq, 
                       pr_cdbanchq => rw_crapfdc.cdbanchq,
                       pr_cdagechq => rw_crapfdc.cdagechq,
                       pr_nrctachq => rw_crapfdc.nrctachq,
                       pr_nrcheque => rw_crapfdc.nrcheque);
      FETCH cr_crapcdb INTO rw_crapcdb;

      IF cr_crapcdb%FOUND THEN
        CLOSE cr_crapcdb;
        vr_cdcritic := 811; --811 - Cheque para desconto.
        
        -- índice da pl table
        vr_idx_rej := to_char(pr_cdcooper)     || 
                      to_char(vr_aux_dtauxili) || 
                      to_char(vr_aux_nrdconta) || 
                      to_char(vr_aux_nrdocmto) || 
                      to_char(vr_aux_vllanmto) ||
                      to_char(vr_aux_nrseqarq) ||
                      to_char(vr_cdcritic)     ||
                      to_char(vr_aux_cdpesqbb);
        
        vr_tab_craprej(vr_idx_rej).cdcooper := pr_cdcooper;
        vr_tab_craprej(vr_idx_rej).dtrefere := vr_aux_dtauxili;
        vr_tab_craprej(vr_idx_rej).nrdconta := vr_aux_nrdconta;
        vr_tab_craprej(vr_idx_rej).nrdocmto := vr_aux_nrdocmto;
        vr_tab_craprej(vr_idx_rej).vllanmto := vr_aux_vllanmto;
        vr_tab_craprej(vr_idx_rej).nrseqdig := vr_aux_nrseqarq;
        vr_tab_craprej(vr_idx_rej).cdcritic := vr_cdcritic;
        vr_tab_craprej(vr_idx_rej).cdpesqbb := vr_aux_cdpesqbb;
        vr_tab_craprej(vr_idx_rej).dscritic := 'Conta ' || to_char(rw_crapcdb.nrdconta);
      ELSE 
        CLOSE cr_crapcdb;  
      END IF;      

      IF vr_cdcritic > 0 THEN
        BEGIN            
          INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrdocmto, vllanmto, nrseqdig, cdcritic, cdpesqbb)
          VALUES(pr_cdcooper          --cdcooper
                ,vr_aux_dtauxili      --dtrefere
                ,vr_aux_nrdconta      --nrdconta
                ,vr_aux_nrdocmto      --nrdocmto
                ,vr_aux_vllanmto      --vllanmto
                ,vr_aux_nrseqarq      --nrseqdig
                ,vr_cdcritic          --cdcritic
                ,vr_aux_cdpesqbb      --cdpesqbb
                );
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro craprej (#5): '||sqlerrm;
            RAISE vr_exc_saida;
        END;
        
        IF vr_cdcritic IN (96,257,414,439,950) THEN
          vr_cdcritic := 0;
          vr_aux_nrdctitg := to_char(vr_aux_nrdconta,'99999999');
          
          -- Se for devolucao de cheque verifica o indicador de
          -- historico da contra-ordem. 
          -- Se for 2, alimenta aux_cdalinea
          -- com 28 para nao gerar taxa de devolucao
          
          IF vr_aux_indevchq IN (1, 3) AND 
             vr_aux_cdalinea = 0 THEN
            OPEN cr_crapcor_756 (pr_cdcooper => pr_cdcooper, 
                                 pr_cdagebcb => rw_crapcop.cdagebcb,
                                 pr_nrdconta => vr_aux_nrdconta,
                                 pr_nrdocmto => vr_aux_nrdocmto);
            FETCH cr_crapcor_756 INTO rw_crapcor_756;
            
            IF cr_crapcor_756%NOTFOUND THEN
              CLOSE cr_crapcor_756;
              vr_cdcritic := 179;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);              
              vr_dscritic := vr_dscritic || 
                             gene0002.fn_mask_conta(pr_nrdconta => vr_aux_nrdconta) ||
                             ' Docmto = ' ||   to_char(vr_aux_nrdocmto) || 
                             ' Cta Base = ' || vr_aux_nrdconta;
              btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                              ,pr_ind_tipo_log       => 2 -- Erro tratato
                              ,pr_des_log            => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic);
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_crapcor_756;
              IF rw_crapcor_756.dtvalcor IS NOT NULL AND
                 rw_crapcor_756.dtvalcor >= rw_crapdat.dtmvtolt THEN
                vr_aux_cdalinea := 70;
              ELSIF rw_crapcor_756.cdhistor = 835 THEN
                vr_aux_cdalinea := 28;
              ELSIF rw_crapcor_756.cdhistor = 815 THEN
                vr_aux_cdalinea := 21;
              ELSIF rw_crapcor_756.cdhistor = 818 THEN
                vr_aux_cdalinea := 20;
              ELSE
                vr_aux_cdalinea := 21;
              END IF;
            END IF;

            IF vr_aux_indevchq > 0 THEN
              IF vr_aux_cdalinea = 21 THEN
                
                OPEN cr_last_craplcm2(pr_cdcooper => pr_cdcooper, 
                                      pr_nrdconta => vr_aux_nrdconta,
                                      pr_nrdocmto => vr_aux_nrdocmto);
                FETCH cr_last_craplcm2 INTO rw_last_craplcm2;
                
                IF cr_last_craplcm2%FOUND THEN
                  vr_aux_cdalinea := 43;
                END IF;
                CLOSE cr_last_craplcm2;

              END IF;
              
              cheq0001.pc_gera_devolucao_cheque(pr_cdcooper => pr_cdcooper, 
                pr_dtmvtolt => rw_crapdat.dtmvtolt,
                pr_cdbccxlt => 756,
                pr_cdbcoctl => 756,
                pr_inchqdev => vr_aux_indevchq, 
                pr_nrdconta => vr_aux_nrdconta, 
                pr_nrdocmto => vr_aux_nrdocmto, 
                pr_nrdctitg => vr_aux_nrdctitg, 
                pr_vllanmto => vr_aux_vllanmto, 
                pr_cdalinea => vr_aux_cdalinea, 
                pr_cdhistor => (CASE rw_crapfdc.tpcheque
                                 WHEN 1 THEN 338
                                 ELSE 78
                                END),
                pr_cdoperad => '1', 
                pr_cdagechq => rw_crapcop.cdagebcb, 
                pr_nrctachq => vr_aux_nrdctabb, 
                pr_cdprogra => vr_cdprogra, 
                pr_nrdrecid => 0, 
                pr_vlchqvlb => vr_aux_vlchqvlb, 
                pr_cdcritic => vr_cdcritic, 
                pr_des_erro => vr_dscritic);              
            END IF;


          END IF;
          
        ELSE
          vr_cdcritic := 0;
          continue;
        END IF;

        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          vr_dscritic := vr_dscritic || 
                         ' CONTA '    || gene0002.fn_mask_conta(pr_nrdconta => vr_aux_nrdconta) ||
                         ' DOCMTO '   || to_char(vr_aux_nrdocmto) || 
                         ' CTA BASE ' || vr_aux_nrdconta;
          btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                          ,pr_ind_tipo_log       => 2 -- Erro tratato
                          ,pr_des_log            => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);
          IF vr_cdcritic <> 415 THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
       
      END IF;

      IF vr_aux_flgfirst THEN

        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                   pr_nmsistem => 'CRED',
                                   pr_tptabela => 'GENERI', 
                                   pr_cdempres => 0, 
                                   pr_cdacesso => 'NUMLOTEBCO', 
                                   pr_tpregist => 1);
        IF vr_dstextab IS NULL THEN
          vr_cdcritic := 472;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' (#3)';
          btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                          ,pr_ind_tipo_log       => 2 -- Erro tratato
                          ,pr_des_log            => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic);          
          RAISE vr_exc_saida;
        END IF;
        
        vr_aux_nrdolot2 := TO_NUMBER(vr_dstextab);

        WHILE 1 = 1 LOOP
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper, 
                           pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                           pr_cdagenci => vr_aux_cdagenci,
                           pr_cdbccxlt => vr_aux_cdbancob, 
                           pr_nrdolote => vr_aux_nrdolot2);
          FETCH cr_craplot INTO rw_craplot;          
                    
          IF cr_craplot%FOUND THEN
            CLOSE cr_craplot;
            vr_aux_nrdolot2 := vr_aux_nrdolot2 + 1;
          ELSE 
            CLOSE cr_craplot;
            EXIT; -- sai do loop com o ultimo nrdolote disponível
          END IF;
        END LOOP;
        
        vr_aux_nrdolote := vr_aux_nrdolot2;
  
        BEGIN
          INSERT INTO craplot
            (cdcooper
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,tplotmov)
          VALUES
            (pr_cdcooper
            ,rw_crapdat.dtmvtolt
            ,vr_aux_cdagenci
            ,vr_aux_cdbancob
            ,vr_aux_nrdolote
            ,vr_aux_tplotmov);        
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro craplot (#1): '||sqlerrm;
            RAISE vr_exc_saida;
        END;
        
        vr_aux_flgfirst := false;
      
      ELSE
        
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper, 
                         pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                         pr_cdagenci => vr_aux_cdagenci,
                         pr_cdbccxlt => vr_aux_cdbancob, 
                         pr_nrdolote => vr_aux_nrdolote);
        FETCH cr_craplot INTO rw_craplot;
        
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          IF vr_nrctares <> 0 THEN
            vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                           pr_nmsistem => 'CRED',
                           pr_tptabela => 'GENERI', 
                           pr_cdempres => 0, 
                           pr_cdacesso => 'NUMLOTEBCO', 
                           pr_tpregist => 1);
            IF vr_dstextab IS NULL THEN
              vr_cdcritic := 472;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' (#4)';
              btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                              ,pr_ind_tipo_log       => 2 -- Erro tratato
                              ,pr_des_log            => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic);          
              RAISE vr_exc_saida;
            END IF;

            vr_aux_nrdolote := to_number(vr_dstextab);
            
            OPEN cr_craplot (pr_cdcooper => pr_cdcooper, 
                             pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                             pr_cdagenci => vr_aux_cdagenci,
                             pr_cdbccxlt => vr_aux_cdbancob, 
                             pr_nrdolote => vr_aux_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            
            IF cr_craplot%NOTFOUND THEN
              CLOSE cr_craplot;
              BEGIN
                INSERT INTO craplot
                  (cdcooper
                  ,dtmvtolt
                  ,cdagenci
                  ,cdbccxlt
                  ,nrdolote
                  ,tplotmov)
                VALUES
                  (pr_cdcooper
                  ,rw_crapdat.dtmvtolt
                  ,vr_aux_cdagenci
                  ,vr_aux_cdbancob
                  ,vr_aux_nrdolote
                  ,vr_aux_tplotmov);        
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir registro craplot (#2): '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
            ELSE
              CLOSE cr_craplot;
            END IF;

          ELSE -- vr_nrctares = 0
            vr_cdcritic := 60;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || vr_dscritic);
            RAISE vr_exc_saida;            
          END IF;
        ELSE
          CLOSE cr_craplot;
        END IF;
        
      END IF;

      OPEN cr_craplcm(pr_cdcooper => pr_cdcooper, 
                      pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                      pr_cdagenci => vr_aux_cdagenci,
                      pr_cdbccxlt => vr_aux_cdbancob,
                      pr_nrdolote => vr_aux_nrdolote,
                      pr_nrdctabb => vr_aux_nrdctabb,
                      pr_nrdocmto => vr_aux_nrdocmto);
      FETCH cr_craplcm INTO rw_craplcm;
      
      IF cr_craplcm%FOUND THEN
        CLOSE cr_craplcm;
        vr_cdcritic := 92;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' (#1)';
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craplcm;
      END IF;

      IF vr_cdcritic > 0 THEN
          BEGIN            
            INSERT INTO craprej (cdcooper, dtrefere, nrdconta, nrdocmto, vllanmto, nrseqdig, cdcritic, cdpesqbb)
            VALUES(pr_cdcooper                                  --cdcooper
                  ,vr_aux_dtauxili                              --dtrefere
                  ,vr_aux_nrdconta                              --nrdconta
                  ,vr_aux_nrdocmto                              --nrdocmto
                  ,vr_tab_linhas(i)('VLDOCMTO').numero          --vllanmto
                  ,vr_aux_nrseqarq                              --nrseqdig
                  ,vr_cdcritic                                  --cdcritic
                  ,vr_aux_cdpesqbb                              --cdpesqbb
                  );
            continue;
            EXCEPTION
              WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro craprej (#7): '||sqlerrm;
              RAISE vr_exc_saida;
          END;        
      END IF;


      OPEN cr_craplot (pr_cdcooper => pr_cdcooper, 
                       pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                       pr_cdagenci => vr_aux_cdagenci,
                       pr_cdbccxlt => vr_aux_cdbancob, 
                       pr_nrdolote => vr_aux_nrdolote);
      FETCH cr_craplot INTO rw_craplot;
      CLOSE cr_craplot;

      BEGIN
        lanc0001.pc_gerar_lancamento_conta(
           pr_cdcooper => pr_cdcooper,
           pr_dtmvtolt => rw_crapdat.dtmvtolt,
           pr_dtrefere => vr_aux_dtleiarq,
           pr_cdagenci => vr_aux_cdagenci,
           pr_cdbccxlt => vr_aux_cdbancob, 
           pr_nrdolote => vr_aux_nrdolote,
           pr_nrdconta => vr_aux_nrdconta,
           pr_nrdctabb => vr_aux_nrdctabb,
           pr_nrdocmto => vr_aux_nrdocmto,
           pr_cdhistor => (case rw_crapfdc.tpcheque
                           when 2 then 340 
                           else 313
                           end),
           pr_vllanmto => vr_tab_linhas(i)('VLDOCMTO').numero,
           pr_nrseqdig => vr_aux_nrseqarq,
           pr_cdpesqbb => vr_aux_cdpesqbb,
           pr_cdbanchq => vr_aux_cdbanchq,
           pr_cdcmpchq => vr_aux_cdcmpchq,
           pr_cdagechq => vr_aux_cdagechq,
           pr_nrctachq => vr_aux_nrctachq,
           pr_nrlotchq => vr_aux_nrlotchq,
           pr_sqlotchq => vr_aux_sqlotchq,
           pr_tab_retorno => vr_tab_retorno,
--           pr_rowid => vr_rowid,
  --         pr_nmtabela => vr_nmtabela,
           pr_incrineg => vr_incrineg,
           pr_cdcritic => vr_cdcritic,
           pr_dscritic => vr_dscritic)
           ;
           if (nvl(vr_cdcritic,0) <>0 or vr_dscritic is not null) then
              RAISE vr_exc_saida;
           end if;
      END;

      BEGIN
        --atualizar craplot                
        UPDATE craplot
           SET qtinfoln = qtinfoln + 1
              ,qtcompln = qtcompln + 1
              ,vlinfodb = vlinfodb + vr_aux_vllanmto
              ,vlcompdb = vlcompdb + vr_aux_vllanmto
              ,nrseqdig = vr_aux_nrseqarq
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = rw_crapdat.dtmvtolt
           AND cdagenci = vr_aux_cdagenci
           AND cdbccxlt = vr_aux_cdbancob
           AND nrdolote = vr_aux_nrdolote;        
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro craplot: cdcooper = '||pr_cdcooper||
                         ', dtmvtolt = '||rw_crapdat.dtmvtolt||
                         ', cdagenci = '||vr_aux_cdagenci||
                         ', cdbccxlt = '||vr_aux_cdbancob||
                         ', nrdolote = '||vr_aux_nrdolote||'. '||sqlerrm;
          RAISE vr_exc_saida;
      END;
      
      vr_aux_qtcompln := vr_aux_qtcompln + 1;
      vr_aux_vlcompdb := vr_aux_vlcompdb + vr_aux_vllanmto;
      
      BEGIN        
        UPDATE crapfdc
           SET dtliqchq = rw_crapdat.dtmvtolt
              ,vlcheque = vr_aux_vllanmto
              ,cdbandep = vr_tab_linhas(i)('CDBANAPRES').numero
              ,cdagedep = vr_tab_linhas(i)('NRAGEAPRES').numero
              ,nrctadep = vr_tab_linhas(i)('CTADEPOS').numero
              ,incheque = incheque + 5
         WHERE cdcooper = pr_cdcooper
           AND cdbanchq = 756
           AND cdagechq = rw_crapcop.cdagebcb
           AND nrcheque = vr_tab_linhas(i)('NRDOCMTO').numero
           AND nrctachq = vr_tab_linhas(i)('NRDCONTA').numero;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro crapfdc: cdcooper = '||pr_cdcooper||
                       ', dtmvtolt = '||rw_crapdat.dtmvtolt||
                       ', cdagechq = '||rw_crapcop.cdagebcb||
                       ', nrcheque = '||vr_tab_linhas(i)('NRDOCMTO').numero||
                       ', nrctachq = '||vr_tab_linhas(i)('NRDCONTA').numero||'. '||sqlerrm;
        RAISE vr_exc_saida;
      END;

    END LOOP;  -- details e trailler



    /* Início relatório */
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nmsubdir => 'salvar');    
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dirintegra||'/'||vr_tab_arqtmp(idx)||' '||vr_dsdireto
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
     vr_dscritic:= 'Não foi possível executar comando unix.';
     RAISE vr_exc_saida;
    END IF;
    
    vr_tot_qtregrec := 0;
    vr_tot_qtregint := 0;
    vr_tot_qtregrej := 0;
    vr_tot_vlregrec := 0;
    vr_tot_vlregint := 0;
    vr_tot_vlregrej := 0;
    vr_cdcritic     := 0;
    vr_aux_flgfirst := TRUE;
    

    vr_nmarqimp := 'rl/crrl203_' || TO_CHAR(idx,'fm00') || '.lst';
    vr_cdempres := 11;

    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_Bufdes_xml := null;
    
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
    pc_escreve_xml('<detalhe nmarquiv="integra/'||vr_tab_arqtmp(idx)||'" '||
                   'dtmvtolt="'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||'" '||
                   'cdagenci="1" cdbccxlt="756" nrdolote="'||nvl(vr_aux_nrdolote,0)||'" '||
                   'tplotmov="1">');

    flg_detalhes := 0;
    
    FOR rw_craprej IN cr_craprej(pr_cdcooper => pr_cdcooper
                                ,pr_dtrefere => vr_aux_dtauxili) LOOP

      flg_detalhes := 1; --existe detalhe

      IF rw_craprej.nrdconta < 999999999 THEN
        vr_aux_flgrejei := TRUE;
        vr_cdcritic := rw_craprej.cdcritic;
        
        IF vr_cdcritic = 999 THEN
          IF pr_cdcooper = 2 THEN
            vr_dscritic := 'Rejeitado - Associado com a conta na VIACREDI';
          -- se a cooperativa for a viacredi e o cdageban for igual coop. migrada 
          -- está processando arquivo da concredi
          ELSIF pr_cdcooper = 1 AND vr_aux_cdageban = vr_cdageban_04 THEN
            vr_dscritic := 'Rejeitado - Associado com a conta na CONCREDI';
          ELSE
            vr_dscritic := 'Rejeitado - Associado com a conta na ALTOVALE';
          END IF;
        ELSE
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);        
        END IF;
        
        vr_rel_dspesqbb := SUBSTR(rw_craprej.cdpesqbb,56,3) || '    ' || -- BCO
                           SUBSTR(rw_craprej.cdpesqbb,59,4) || ' ' ||  -- AG.
                           SUBSTR(rw_craprej.cdpesqbb,79,3) || ' ' ||  -- CMP
                           SUBSTR(rw_craprej.cdpesqbb,90,7) || ' ' ||  -- LOTE
                           SUBSTR(rw_craprej.cdpesqbb,97,3);           -- SEQ
        
        -- Estas criticas integram os cheques, sao "alertas" 
        IF vr_cdcritic IN(96,257,414,439,929) THEN
          vr_dscritic := SUBSTR(vr_dscritic,1,41) || 'INTEGRADO' || SUBSTR(vr_dscritic,51);
        ELSIF vr_cdcritic <> 950 THEN
          vr_tot_qtregrej := vr_tot_qtregrej + 1;
          vr_tot_vlregrej := vr_tot_vlregrej + rw_craprej.vllanmto;
        END IF;

        IF vr_cdcritic = 811 OR 
           vr_cdcritic = 757 THEN
          vr_indice := to_char(pr_cdcooper)     || 
                       to_char(vr_aux_dtauxili) || 
                       to_char(rw_craprej.nrdconta) || 
                       to_char(rw_craprej.nrdocmto) || 
                       to_char(rw_craprej.vllanmto) ||
                       to_char(rw_craprej.nrseqdig) ||
                       to_char(rw_craprej.cdcritic) ||
                       to_char(rw_craprej.cdpesqbb);
          IF vr_tab_craprej.exists(vr_indice) THEN
            vr_dscritic := vr_dscritic || vr_tab_craprej(vr_indice).dscritic;
          END IF;
        END IF;

        pc_escreve_xml('<linha>');
        pc_escreve_xml('<nrseqdig>' || rw_craprej.nrseqdig || '</nrseqdig>');
        pc_escreve_xml('<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta => rw_craprej.nrdconta) || '</nrdconta>');
        pc_escreve_xml('<nrdocmto>' || gene0002.fn_mask_contrato(pr_nrcontrato => rw_craprej.nrdocmto) || '</nrdocmto>');
        pc_escreve_xml('<cdpesqbb>' || vr_rel_dspesqbb || '</cdpesqbb>');
        pc_escreve_xml('<vllanmto>' || TO_CHAR(nvl(rw_craprej.vllanmto,0),'fm99999g999g990d00') || '</vllanmto>');
        pc_escreve_xml('<dscritic>' || vr_dscritic || '</dscritic>');
        pc_escreve_xml('</linha>');

      ELSE -- rw_craprej.nrdconta = 999999999
        
        --pro caso de nao haver linhas deve criar pelo menos
        --uma tag para o jasper se achar
        IF vr_aux_flgrejei = FALSE THEN
          pc_escreve_xml('<linha/>');
        END IF;
      
        vr_tot_qtregrec := rw_craprej.nrseqdig - 2;
        vr_tot_qtregint := vr_aux_qtcompln;
        vr_tot_vlregrec := rw_craprej.vllanmto;
        vr_tot_vlregint := vr_aux_vlcompdb;

        pc_escreve_xml('</detalhe>');
        pc_escreve_xml('<total>');
        pc_escreve_xml('<qtregrec>' || TO_CHAR(vr_tot_qtregrec) || '</qtregrec>');
        pc_escreve_xml('<qtregint>' || TO_CHAR(vr_tot_qtregint) || '</qtregint>');
        pc_escreve_xml('<qtregrej>' || TO_CHAR(vr_tot_qtregrej) || '</qtregrej>');        
        pc_escreve_xml('<vlregrec>' || TO_CHAR(vr_tot_vlregrec,'fm99999g999g990d00') || '</vlregrec>');
        pc_escreve_xml('<vlregint>' || TO_CHAR(vr_tot_vlregint,'fm99999g999g990d00') || '</vlregint>');
        pc_escreve_xml('<vlregrej>' || TO_CHAR(vr_tot_vlregrej,'fm99999g999g990d00') || '</vlregrej>');
        pc_escreve_xml('</total>');

        pc_escreve_xml('</raiz>',TRUE);
       
      END IF;

    END LOOP;
    
    IF flg_detalhes = 0 THEN
      pc_escreve_xml('<linha/>');
      pc_escreve_xml('</detalhe>');
      pc_escreve_xml('</raiz>',TRUE);
    END IF;
   
    IF vr_aux_flgrejei THEN  vr_cdcritic := 191; -- com rejeitados
    ELSE                     vr_cdcritic := 190;
    END IF;

    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic || ' --> '
                                                  || vr_tab_arqtmp(idx));

    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => null);

    vr_dsdirarq := vr_dsdireto||'/'||vr_nmarqimp;
    
    vr_cdcritic := 0;

    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz/detalhe/linha'                --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl203.jasper'                     --> Arquivo de layout do iReport
                               ,pr_dsparams  => null                                 --> Sem parâmetros
                               ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                               ,pr_qtcoluna  => 132                                  --> 132 colunas
                               ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                               ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                                    --> Número de cópias
                               ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                               ,pr_cdrelato  => '203'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                               ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
        
    IF pr_cdcooper = 1 OR
       pr_cdcooper = 2 THEN
       
      /**** IMPRESSAO DO RELAT  CRRL203_99 - CRITICA 999 ****/
      vr_tot_qtregrec := 0;
      vr_tot_qtregint := 0;
      vr_tot_vlregrec := 0;
      vr_tot_vlregint := 0;
      vr_tot_vlregrej := 0;
      vr_cdcritic     := 0;
      vr_aux_flgfirst := TRUE;
      vr_aux_flgrejei := FALSE;

      vr_nmarqimp := 'rl/crrl203_999_' || TO_CHAR(idx,'fm00') || '.lst';
      vr_cdempres := 11;      
      
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_Bufdes_xml := null;
      
      -- Inicilizar as informações do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
      pc_escreve_xml('<detalhe nmarquiv="integra/'||vr_tab_arqtmp(idx)||'" '||
                    'dtmvtolt="'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||'" '||
                    'cdagenci="1" cdbccxlt="756" nrdolote="'||nvl(vr_aux_nrdolote,0)||'" '||
                    'tplotmov="1">');

      flg_detalhes := 0;

      FOR rw_craprej IN cr_craprej_999(pr_cdcooper => pr_cdcooper
                                      ,pr_dtrefere => vr_aux_dtauxili) LOOP

        flg_detalhes := 1; --existe detalhe

        vr_aux_flgrejei := TRUE;

        -- se a cooperativa for a viacredi e o cdageban for igual coop. migrada 
        -- esta processando arquivo da concredi, deve ignorar o registro.        
        IF pr_cdcooper = 1 AND vr_aux_cdageban = vr_cdageban_04 THEN
          continue;
        ELSE
          IF pr_cdcooper = 1 THEN
            vr_dscritic := 'Rejeitado - Associado com a conta na ALTOVALE';
          ELSE
            vr_dscritic := 'Rejeitado - Associado com a conta na VIACREDI';
          END IF;
        END IF;
        
        vr_rel_dspesqbb := substr(rw_craprej_999.cdpesqbb,56,3) || '    ' ||
                           substr(rw_craprej_999.cdpesqbb,59,4) || ' ' ||
                           substr(rw_craprej_999.cdpesqbb,79,3) || ' ' ||
                           substr(rw_craprej_999.cdpesqbb,90,7) || ' ' ||
                           substr(rw_craprej_999.cdpesqbb,97,3);

        vr_tot_qtregrej := vr_tot_qtregrej + 1;
        vr_tot_vlregrej := vr_tot_vlregrej + rw_craprej_999.vllanmto;
        
        pc_escreve_xml('<linha>');
        pc_escreve_xml('<nrseqdig>' || rw_craprej_999.nrseqdig || '</nrseqdig>');
        pc_escreve_xml('<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta => rw_craprej_999.nrdconta) || '</nrdconta>');
        pc_escreve_xml('<nrdocmto>' || gene0002.fn_mask_contrato(pr_nrcontrato => rw_craprej_999.nrdocmto) || '</nrdocmto>');
        pc_escreve_xml('<cdpesqbb>' || vr_rel_dspesqbb || '</cdpesqbb>');
        pc_escreve_xml('<vllanmto>' || TO_CHAR(nvl(rw_craprej_999.vllanmto,0),'fm99999g999g990d00') || '</vllanmto>');
        pc_escreve_xml('<dscritic>' || vr_dscritic || '</dscritic>');
        pc_escreve_xml('</linha>');
        
      END LOOP;
      
      IF flg_detalhes = 0 THEN
        pc_escreve_xml('<linha/>');
        pc_escreve_xml('</detalhe>');
      END IF;
      
      pc_escreve_xml('<total>');
      pc_escreve_xml('<qtregrec>' || TO_CHAR(vr_tot_qtregrec) || '</qtregrec>');
      pc_escreve_xml('<qtregint>' || TO_CHAR(vr_tot_qtregint) || '</qtregint>');
      pc_escreve_xml('<qtregrej>' || TO_CHAR(vr_tot_qtregrej) || '</qtregrej>');
      pc_escreve_xml('<vlregrec>' || TO_CHAR(vr_tot_vlregrec,'fm99999g999g990d00') || '</vlregrec>');
      pc_escreve_xml('<vlregint>' || TO_CHAR(vr_tot_vlregint,'fm99999g999g990d00') || '</vlregint>');
      pc_escreve_xml('<vlregrej>' || TO_CHAR(vr_tot_vlregrej,'fm99999g999g990d00') || '</vlregrej>');
      pc_escreve_xml('</total>');
        
      pc_escreve_xml('</raiz>',TRUE);

      vr_dsdirarq := vr_dsdireto||'/'||vr_nmarqimp;
      
      vr_cdcritic := 0;

      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/detalhe/linha'                --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl203.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '203'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      vr_assunto := 'Relatorio Integracao Cheques Bancoob';
      
      IF pr_cdcooper = 2 THEN
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => vr_cdprogra    --> Programa conectado
                                  ,pr_des_destino     => 'suporte@viacredi.coop.br,compe@cecred.coop.br' --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_assunto     --> Assunto do e-mail
                                  ,pr_des_corpo       => ''             --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => vr_dsdirarq    --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
      ELSIF pr_cdcooper = 1 THEN                                  
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => vr_cdprogra    --> Programa conectado
                                  ,pr_des_destino     => 'compe@cecred.coop.br,suporte@viacredialtovale.coop.br'  --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_assunto     --> Assunto do e-mail
                                  ,pr_des_corpo       => ''             --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => vr_dsdirarq    --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
      END IF;
      
      /* FIM IMPRESSAO DO RELATORIO CRRL203_99 (CRÍTICA 999)*/
    END IF;
    
    
    --Limpar a craprej 
    BEGIN
      DELETE 
        FROM craprej rej
       WHERE rej.cdcooper = pr_cdcooper
         AND rej.dtrefere = vr_aux_dtauxili;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problemas na exclusao da craprej (Rejeitados)';
        RAISE vr_exc_saida;
    END;    
    
    -- Limpar vr_tab_craprej
    vr_tab_craprej.delete;

    COMMIT; --commit por arquivo processado
  END LOOP;  -- LOOP arquivos RT*
  
  EXCEPTION
    WHEN vr_exc_saida THEN      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 THEN
        -- Buscar a descrição
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;            
      END IF;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
    
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic || sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;

END PC_CRPS250;
/
