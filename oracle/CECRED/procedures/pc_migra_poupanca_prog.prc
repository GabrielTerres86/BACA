create or replace procedure cecred.pc_migra_poupanca_prog (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Data proxima do processo
                        pr_vlsdrdpp  in craprpp.vlsdrdpp%type,          --> Valor de saldo da RPP
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_dscritic out varchar2) is                    --> Descrição do erro encontrado
BEGIN
/* ...........................................................................

   Programa: PC_MIGRACAO_POUPANCA
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Outubro/2018.                       Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : Cancelamento e Migração das Poupanças Programadas para Aplicação Programada
               As contas da Poupança serão "setadas" como canceladas
*/
  DECLARE
    -- Local variables here
  
    -- Constantes
    -- Rever valores
  
    vr_exc_erro EXCEPTION;
    vr_cdcritic          pls_integer;
    vr_dscritic          VARCHAR2(4000) := NULL;
    vr_tmp_agora         date;
  
    vr_nraplica    craprac.nraplica%type;
    vr_nrseqdig    craplot.nrseqdig%type;
    vr_nrseqlrg    craplrg.nrseqdig%type;
    vr_tmp_craplot lote0001.cr_craplot_sem_lock%ROWTYPE;
    vr_nrseqted    crapmat.nrseqted%type; -- Recuperar a sequence da conta "poupanca"
    vr_codproduto        PLS_INTEGER := 0; -- Código da aplicação programada default
	vr_tentativa         PLS_INTEGER := 0;
    vr_cdbccxlt    craprpp.cdbccxlt%type;
    
    vr_total_procs   PLS_INTEGER := 0;
    vr_total_erros   PLS_INTEGER := 0;
    vr_erro_sit_lock PLS_INTEGER := 0; -- lock na tabela de lotes
    vr_erro_sit_lote PLS_INTEGER := 0; -- inclusao de lote
    vr_erro_sit_insP PLS_INTEGER := 0; -- Inclusao RPP
    vr_erro_sit_altP PLS_INTEGER := 0; -- Alteracao RPP
    vr_erro_outros   PLS_INTEGER := 0; -- Outros
  
    vr_flgcreci craplrg.flgcreci%type := 1;
    
    -- Temp Table
    vr_tab_care APLI0005.typ_tab_care;

    -- Cursores
    CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdagenci craplot.cdagenci%TYPE) IS
      Select 1
        From craplot
       where cdcooper = pr_cdcooper
         and dtmvtolt = pr_dtmvtolt
         and cdagenci = pr_cdagenci
         and cdbccxlt = 200 -- fixo
         and nrdolote = 1537; -- fixo
    rw_craplot cr_craplot%ROWTYPE;

    -- Informações da poupança programada
    cursor cr_craprpp (pr_rowid in varchar2) is
      select /*+ NOPARALLEL */
             craprpp.vlsdrdpp,
             craprpp.cdsecext,
             craprpp.dtiniper,
             craprpp.dtfimper,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.vlabdiof,
             craprpp.cdbccxlt,
             craprpp.cdsitrpp,
             craprpp.cdcooper,
             craprpp.tpemiext,
             craprpp.dtcalcul,
             craprpp.dtvctopp,
             craprpp.cdopeori,
             craprpp.cdageori,
             craprpp.cdagenci,
             craprpp.dtdebito,
             craprpp.dtmvtolt,
             craprpp.dtinsori,
             craprpp.vlabcpmf,
             craprpp.vlprerpp,
             craprpp.dtrnirpp,
             craprpp.cdprodut
        from craprpp
       where craprpp.rowid = pr_rowid;
    rw_craprpp     cr_craprpp%rowtype;
  
    -- Informações da poupança programada migrada na fase 1
    cursor cr_craprppmig (pr_cdcooper in craprpp.cdcooper%TYPE,
                  pr_nrdconta in craprpp.nrdconta%TYPE,
                  pr_cdprodut in craprpp.cdprodut%TYPE,
                  pr_dtvctopp in craprpp.dtvctopp%TYPE,
                  pr_vlprerpp in craprpp.vlprerpp%TYPE) is
      select craprpp.vlsdrdpp,
             craprpp.dtiniper,
             craprpp.dtfimper,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.cdbccxlt,
             craprpp.cdagenci,
             craprpp.dtmvtolt,
             craprpp.cdprodut
      from
      (
      select craprpp.vlsdrdpp,
             craprpp.dtiniper,
             craprpp.dtfimper,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.cdbccxlt,
             craprpp.cdagenci,
             craprpp.dtmvtolt,
             craprpp.cdprodut,
         DECODE(craprpp.dtvctopp ,pr_dtvctopp, 0, 1) indtvctopp,
         DECODE(craprpp.vlprerpp ,pr_vlprerpp, 0, 1) invlprerpp
        from craprpp
       where craprpp.cdcooper = pr_cdcooper
       and craprpp.nrdconta = pr_nrdconta
       and craprpp.cdprodut = pr_cdprodut
       order by indtvctopp, invlprerpp, craprpp.nrctrrpp desc
       ) craprpp
       where rownum <= 1;
       
    rw_craprppmig     cr_craprppmig%rowtype;

    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         and (crapass.dtelimin is not null or crapass.dtdemiss is not null);
    rw_crapass cr_crapass%ROWTYPE;   
  
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_dstextab IN craptab.dstextab%TYPE) IS
      SELECT tab.dstextab
            ,tab.tpregist
            ,rowid
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
         AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
         AND tab.cdempres = pr_cdempres
         AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
         AND to_number(SUBSTR(tab.dstextab,1,7)) = pr_dstextab;
    rw_craptab cr_craptab%ROWTYPE;

  BEGIN

    -- Recuperar código da nova aplicação programada
    apli0008.pc_buscar_apl_prog_padrao(pr_cdprodut => vr_codproduto);

    -- Buscar informações da poupança programada
    open cr_craprpp (pr_rpp_rowid);
      fetch cr_craprpp into rw_craprpp;
    close cr_craprpp;

      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_craprpp.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        vr_flgcreci := 0;
      END IF; 
      CLOSE cr_crapass;

    IF ((pr_cdprogra = 'CRPS156') AND  (pr_vlsdrdpp > 0) AND (vr_flgcreci = 1)) THEN
        -- Buscar informações da poupança programada migrada
        open cr_craprppmig (pr_cdcooper, rw_craprpp.nrdconta, vr_codproduto, rw_craprpp.dtvctopp, rw_craprpp.vlprerpp);
          fetch cr_craprppmig into rw_craprppmig;
         IF cr_craprppmig%NOTFOUND THEN

              -- Recuperar próximo número RPP
              vr_nrseqted := cecred.fn_sequence(pr_nmtabela => 'CRAPMAT',
                                            pr_nmdcampo => 'NRRDCAPP',
                                            pr_dsdchave => pr_cdcooper,
                                            pr_flgdecre => 'N');
              vr_cdbccxlt := 200;
              
              LOOP 
                -- Cursor Implicito
                Select max(nrseqdig) + 1
                  into vr_nrseqdig
                  from craprpp
                 where cdcooper = pr_cdcooper
                   and dtmvtolt = pr_dtmvtolt
                   and cdagenci = rw_craprpp.cdagenci
                   and cdbccxlt = 200 -- fixo
                   and nrdolote = 1537; -- fixo
              
                If vr_nrseqdig is null Then
                  vr_nrseqdig := 1;
                End If;  
                           
                BEGIN
                  Insert into craprpp
                    (nrctrrpp,
                     cdsitrpp,
                     cdcooper,
                     cdageass,
                     cdagenci,
                     tpemiext,
                     dtcalcul,
                     dtvctopp,
                     cdopeori,
                     cdageori,
                     dtinsori,
                     dtrnirpp,
                     dtiniper,
                     dtfimper,
                     dtinirpp,
                     dtdebito,
                     flgctain,
                     nrdolote,
                     cdbccxlt,
                     cdsecext,
                     nrdconta,
                     vlprerpp,
                     dtimpcrt,
                     indebito,
                     nrseqdig,
                     dtmvtolt,
                     dtaltrpp,
                     vlabcpmf,
                     vlabdiof,
                     cdprodut,
                     dsfinali)
                  VALUES
                    (vr_nrseqted,
                     rw_craprpp.cdsitrpp,
                     rw_craprpp.cdcooper,
                     rw_craprpp.cdagenci,
                     rw_craprpp.cdagenci,
                     rw_craprpp.tpemiext,
                     rw_craprpp.dtcalcul,
                     rw_craprpp.dtvctopp,
                     rw_craprpp.cdopeori,
                     rw_craprpp.cdageori,
                     rw_craprpp.dtinsori, -- Mantendo a data original da RPP nao do novo produto
                     rw_craprpp.dtrnirpp,
                     rw_craprpp.dtiniper,
                     rw_craprpp.dtfimper,
                     pr_dtmvtolt,
                     rw_craprpp.dtdebito,
                     1,
                     1537,
                     vr_cdbccxlt,
                     rw_craprpp.cdsecext,
                     rw_craprpp.nrdconta,
                     rw_craprpp.vlprerpp,
                     null, -- Contrato não foi impresso da Apl. Prog.
                     0,
                     vr_nrseqdig,
                     pr_dtmvtolt,
                     pr_dtmvtolt, -- Alteracao do Plano
                     rw_craprpp.vlabcpmf,
                     rw_craprpp.vlabdiof,
                     vr_codproduto, -- Produto AP Default
                     ' ');
                EXCEPTION
                      When DUP_VAL_ON_INDEX then
                         vr_tentativa := vr_tentativa + 1;
                         if vr_tentativa > 6 then
                            vr_dscritic := 'Erro na insercao idx RPP: '||pr_cdcooper||' '||rw_craprpp.nrdconta||' '||vr_codproduto||' '||rw_craprpp.dtvctopp||' '||rw_craprpp.vlprerpp||' '||sqlerrm;
                            raise vr_exc_erro;
                         end if;
                         -- aguardar 1 seg. antes de tentar novamente
                         sys.dbms_lock.sleep(1); 
                         continue;
                      When Others Then
                            vr_dscritic := 'Erro na insercao RPP: '||pr_cdcooper||' '||rw_craprpp.nrdconta||' '||vr_codproduto||' '||rw_craprpp.dtvctopp||' '||rw_craprpp.vlprerpp||' '||sqlerrm;
                            raise vr_exc_erro;
                END;
                EXIT;
             END LOOP;
        ELSE
            vr_nrseqted := rw_craprppmig.nrctrrpp;
            vr_cdbccxlt := rw_craprppmig.cdbccxlt;
        END IF;
        close cr_craprppmig;
      
          -- Inserir nova aplicação 
          -- Leitura de carencias do produto informado
          apli0005.pc_obtem_carencias(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_cdprodut => vr_codproduto   -- Codigo do Produto 
                                 ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                 ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                 ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto    

           IF vr_dscritic is not null THEN
               raise vr_exc_erro;
           END IF;
           apli0005.pc_cadastra_aplic(pr_cdcooper => pr_cdcooper,
                                      pr_cdoperad => '1',
                                      pr_nmdatela => 'CRPS145',
                                      pr_idorigem => 5,
                                      pr_nrdconta => rw_craprpp.nrdconta,
                                      pr_idseqttl => 1,
                                      pr_nrdcaixa => vr_cdbccxlt,
                                      pr_dtmvtolt => pr_dtmvtolt,
                                      pr_cdprodut => vr_codproduto,
                                      pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                                      pr_dtvencto => pr_dtmvtolt + vr_tab_care(1).qtdiaprz,
                                      pr_qtdiacar => vr_tab_care(1).qtdiacar,
                                      pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                                      pr_vlaplica => pr_vlsdrdpp,
                                      pr_iddebcti => 1,
                                      pr_idorirec => 0,
                                      pr_idgerlog => 1,
                                      pr_nrctrrpp => vr_nrseqted, -- Número da RPP
                                      pr_nraplica => vr_nraplica,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
           IF vr_dscritic is not null THEN
               vr_dscritic := 'Conta: '|| rw_craprpp.nrdconta || ' Plano: ' || vr_nrseqted || ' - ' || vr_dscritic;
               raise vr_exc_erro;
           END IF;

           OPEN cr_craptab(  pr_cdcooper => pr_cdcooper
                            ,pr_nmsistem => 'CRED'
                            ,pr_tptabela => 'BLQRGT'
                            ,pr_cdempres => 00
                            ,pr_cdacesso => gene0002.fn_mask(rw_craprpp.nrdconta,'9999999999')
                            ,pr_dstextab => rw_craprpp.nrctrrpp );
            FETCH cr_craptab INTO rw_craptab;
            IF cr_craptab%FOUND THEN
              /* Se tem bloqueio, migra ele tambem */
              
              BEGIN
                UPDATE craptab
                   SET dstextab = lpad(vr_nrseqted,7,'0') || substr(dstextab,8,length(dstextab))
                 WHERE rowid = rw_craptab.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                   CLOSE cr_craptab;
                   vr_dscritic := 'Erro migrando bloqueio - Conta: '|| rw_craprpp.nrdconta || ' Plano: ' || vr_nrseqted || ' - ' || SQLERRM;
                   RAISE vr_exc_erro; 
              END; 
              
            END IF;   
            CLOSE cr_craptab;

    ELSE
             
      IF ((pr_cdprogra = 'CRPS148') AND  (pr_vlsdrdpp > 0)) THEN 

         vr_nrseqlrg := fn_sequence('CRAPLOT'
                                   ,'NRSEQDIG'
                                   ,  pr_cdcooper||';'
                                   ||to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||'999;'  --cdagenci
                                   ||'400;'  --cdbccxlt
                                   ||'999'); --nrdolote
         Begin
           INSERT INTO
           craplrg
           (
           nrdconta
           ,nraplica
           ,cdcooper
           ,vllanmto
           ,flgcreci
           ,hrtransa
           ,dtresgat
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,cdoperad
           ,nrdocmto
           ,nrseqdig
           ,idautblq
           ,inresgat
           ,tpaplica
           ,tpresgat)
           VALUES
           (
           rw_craprpp.nrdconta
           ,rw_craprpp.nrctrrpp
           ,pr_cdcooper
           ,pr_vlsdrdpp
           ,vr_flgcreci
           ,-1
           ,pr_dtmvtolt
           ,pr_dtmvtolt
           ,999
           ,400
           ,999
           ,'1'
           ,rw_craprpp.nrctrrpp
           ,vr_nrseqlrg
           ,1
               ,0
           ,4
           ,2);
      Exception
        When Others Then
          vr_dscritic := 'Erro inclusao CRAPLRG: '||' '||pr_vlsdrdpp||' '||sqlerrm;
          raise vr_exc_erro;
      End;
     END IF;
      
         lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                   , pr_dtmvtolt => pr_dtmvtolt
                                   , pr_cdagenci => rw_craprpp.cdagenci
                                   , pr_cdbccxlt => 200
                                   , pr_nrdolote => 1537
                                   , pr_cdoperad => '1'
                                   , pr_nrdcaixa => 0
                                   , pr_tplotmov => 14
                                   , pr_cdhistor => 0
                                   , pr_craplot  => vr_tmp_craplot
                                   , pr_dscritic => vr_dscritic);     
        IF vr_dscritic is not null THEN
          vr_dscritic := 'Erro migrando pc_insere_lote: '||vr_dscritic; -- Mensagem unica e conhecida para este script
          raise vr_exc_erro;
        END IF;
        
          -- Atualiza RPP dizendo que foi processada
          -- Não utiliza o cursor 
          Begin
            Update craprpp
               Set cdprodut = -2 -- Indica que foi processada com sucesso e que possui como novo número de contrato seu valor positivo
                  ,cdsitrpp = 3 -- Coloca a aplicacao como cancelada
                  ,dtrnirpp = null -- Impede que a poupança seja reativada automaticamente
             Where rowid = pr_rpp_rowid;
          Exception
            When Others Then
              vr_dscritic := 'Erro na atualizacao RPP: '||sqlerrm;
              raise vr_exc_erro;
          end;
       END IF;
        Exception
          -- RPP
          When vr_exc_erro Then
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := vr_dscritic;
          When Others Then
            pr_cdcritic := 0;
              pr_dscritic := 'Erro ao fazer a migracao de poupanca programada para a conta '||rw_craprpp.nrdconta||': '||sqlerrm;
        END; -- RPP
end pc_migra_poupanca_prog; 
/
