DECLARE
    vr_tipo_saida VARCHAR2(100);
    rw_craptab   btch0001.cr_craptab%ROWTYPE;
    vr_endereco  VARCHAR2(100);    
    vr_login     VARCHAR2(100);
    vr_senha     VARCHAR2(100);

    vr_dsdircop  VARCHAR2(50);
    vr_nmdircop  VARCHAR2(100);
    vr_nmarquiv  VARCHAR2(100);
    vr_xml_temp  VARCHAR2(32726) := ''; --> Temp xml/csv 
    vr_clob      CLOB; --> Clob buffer do xml gerado
    vr_seqtran   INTEGER;
    vr_linha_txt VARCHAR2(32600);
    vr_dtdcorte DATE;
    vr_dtfimvig DATE;
    vr_cdcooper  crapcop.cdcooper%TYPE;
    vr_nrsequen  NUMBER(10);
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    
    pr_cdcritic INTEGER;
    pr_dscritic VARCHAR(2000);
    vr_cdsexotl crapass.cdsexotl%type;
    vr_nrcpfcgc crapass.nrcpfcgc%type;
    vr_nmprimtl crapass.nmprimtl%type;
    vr_dtnasctl crapass.dtnasctl%type;
    vr_cdagenci crapass.cdagenci%type;
    
    vr_sald_cpf_tot NUMBER := 0;
    
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'JB_ARQPRST';
    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;

    vr_saldodevedor    NUMBER:=0;
    vr_saldodevempr    NUMBER:=0;
    vr_vlminimo NUMBER;
    vr_pgtosegu  NUMBER;
    vr_vlprodvl  NUMBER;
    vr_dstextab  craptab.dstextab%TYPE; --> Busca na craptab

    vr_flgvincu INTEGER;

    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro

    vr_exc_erro        EXCEPTION;
    vr_exc_saida  EXCEPTION;
    
        -- Definicao do tipo de array para nome origem do módulo
    TYPE typ_tab_prefixo IS VARRAY(16) OF VARCHAR2(5);
    -- Vetor de memória com as origens do módulo
    vr_vet_prefixo typ_tab_prefixo := typ_tab_prefixo('CEVIA'
                                                     ,'CECOO'
                                                     ,''
                                                     ,''
                                                     ,'CECRI'
                                                     ,'CREFI'
                                                     ,'CRERE'
                                                     ,'CRELE'
                                                     ,'CETRA'
                                                     ,'CREDM'
                                                     ,'CREFO'
                                                     ,'CREVI'
                                                     ,'CECIV'
                                                     ,'CRERO'
                                                     ,''
                                                     ,'CEALT');

    
     -- Ultima parcela do financiamento
    CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                     ,pr_nrdconta IN crappep.nrdconta%TYPE
                     ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
      SELECT MAX(p.dtvencto) dtvencto
        FROM crappep p
       WHERE p.cdcooper = pr_cdcooper
         AND p.nrdconta = pr_nrdconta
         AND p.nrctremp = pr_nrctremp;
    rw_crappep cr_crappep%ROWTYPE;


     -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
            ,c.dsdircop
        FROM crapcop c
       WHERE c.flgativo = 1 -- Somente ativas
         AND c.cdcooper <> 3 -- nao será gerado para central
       ORDER BY c.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor de email
    CURSOR cr_crapcem(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT e.dsdemail
        FROM crapcem e
       WHERE e.cdcooper = pr_cdcooper
         AND e.nrdconta = pr_nrdconta;
    rw_crapcem cr_crapcem%ROWTYPE;

      -- Dados Cooperado
   CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT
            DECODE(pass.cdsexotl, 1, '2', 2, '1', '0') cdsexotl -- sexo
            ,pass.nrcpfcgc
            ,pass.nmprimtl
            ,pass.dtnasctl
            ,pass.cdagenci
      FROM crapass pass
      WHERE pass.cdcooper = pr_cdcooper
      AND   pass.nrdconta = pr_nrdconta;

       -- Cursor de telefone
    CURSOR cr_craptfc(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT (f.nrdddtfc||f.nrtelefo) nrtelefo -- Telefone Residencial
        FROM craptfc f
       WHERE f.cdcooper = pr_cdcooper
         AND f.nrdconta = pr_nrdconta
         AND f.tptelefo(+) IN (1, 2, 4)
       ORDER BY f.tptelefo ASC;
    rw_craptfc cr_craptfc%ROWTYPE;
    
   /*   -- Cursor saldo devedor por cpf
    CURSOR cr_tbseg_prestamista_saldo(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc IN tbseg_prestamista.nrcpfcgc%TYPE) IS
      SELECT SUM(vldevatu)
        FROM tbseg_prestamista p
       WHERE p.cdcooper = pr_cdcooper
           AND p.nrcpfcgc = pr_nrcpfcgc;
    rw_tbseg_prestamista_saldo cr_tbseg_prestamista_saldo%ROWTYPE;
*/


     -- Cursor principal prestamista
     CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_dtdcorte DATE) IS
          SELECT seg.cdcooper
                 ,seg.nrdconta
                 ,seg.nrctrseg
                 ,s.dsendres -- Endereço
                 ,s.nmbairro -- Bairro
                 ,s.nmcidade -- Cidade
                 ,s.cdufresd -- UF
                 ,s.nrcepend -- CEP
                 ,s.dtdebito -- Referencia cobranca
                 ,s.nrfonres nrtelefo -- Telefone Residencial
                 ,e.nrctremp --emprestimo vinculado
                  FROM crapepr e, crawseg s, crapseg seg, craplcr l
          WHERE e.cdcooper = pr_cdcooper
            -- AND e.nrdconta = 7132069
            AND seg.cdsitseg = 1 -- contratos em aberto
            AND l.flgsegpr = 1 --flg prestamista
            AND s.cdcooper = e.cdcooper
            AND s.nrdconta = e.nrdconta
            AND s.nrctrato = e.nrctremp
            AND seg.nrdconta = e.nrdconta
            AND seg.nrctrseg = s.nrctrseg
            AND l.cdlcremp = e.cdlcremp
            AND seg.dtmvtolt <= pr_dtdcorte;
     rw_prestamista cr_prestamista%ROWTYPE;
     
     -- Cursor principal prestamista
        CURSOR cr_prestamista_gerar_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT p.idseqtra
                ,p.cdcooper
                ,p.nrdconta
                ,p.nrctrseg
                ,p.tpregist
                ,p.cdapolic
                ,p.nrcpfcgc
                ,p.nmprimtl
                ,p.dtnasctl
                ,p.cdsexotl
                ,p.dsendres
                ,p.dsdemail
                ,p.nmbairro
                ,p.nmcidade
                ,p.cdufresd
                ,p.nrcepend
                ,p.nrtelefo
                ,p.dtdevend
                ,p.dtinivig
                ,p.nrctremp
                ,p.cdcobran
                ,p.cdadmcob
                ,p.tpfrecob
                ,p.tpsegura
                ,p.cdprodut
                ,p.cdplapro
                ,p.vlprodut
                ,p.tpcobran
                ,p.vlsdeved
                ,p.vldevatu
                ,p.dtrefcob
                ,p.dtfimvig
                ,p.dtdenvio
            FROM tbseg_prestamista p
           WHERE p.cdcooper = pr_cdcooper;
        rw_prestamista_gerar_arquivo cr_prestamista_gerar_arquivo%ROWTYPE;
     
    /*
    --calcula o saldo devedor TOTAL com base no cpf e cooperativa
    PROCEDURE pc_calcula_saldo_devedor_cpf(pr_cdcooper IN crapass.cdcooper%type
                                          ,pr_nrdconta IN crapass.nrdconta%type
                                          ,pr_sald_cpf_tot OUT NUMBER) IS

     -- Dados Cooperado
     CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT
               pass.nrcpfcgc
              ,pass.nmprimtl
              ,pass.dtnasctl
              ,pass.cdagenci
              ,pass.nrdconta
        FROM crapass pass
        WHERE pass.cdcooper = pr_cdcooper
        AND   pass.nrdconta = pr_nrdconta; 
        rw_crapass cr_crapass%ROWTYPE;
        
      
       -- Cursor saldo devedor por cpf
      CURSOR cr_tbseg_prestamista_saldo(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrcpfcgc IN tbseg_prestamista.nrcpfcgc%TYPE) IS
        SELECT SUM(vldevatu) vldevatu
          FROM tbseg_prestamista p
         WHERE p.cdcooper = pr_cdcooper
             AND p.nrcpfcgc = pr_nrcpfcgc;
      rw_tbseg_prestamista_saldo cr_tbseg_prestamista_saldo%ROWTYPE;  
        
      -- Tratamento de erros
      vr_exc_erro        EXCEPTION; 
      
      vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
        
      BEGIN
        
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          CLOSE cr_crapass;
      
      OPEN cr_tbseg_prestamista_saldo(pr_cdcooper => pr_cdcooper
                   ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_tbseg_prestamista_saldo INTO rw_tbseg_prestamista_saldo;
          CLOSE cr_tbseg_prestamista_saldo;
      
      pr_sald_cpf_tot := rw_tbseg_prestamista_saldo.vldevatu;
          
      EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        END IF;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro ao calcular saldo devedor: ' || SQLERRM, chr(13)),chr(10));

    END pc_calcula_saldo_devedor_cpf;
    */
      -- Função que retorna o saldo devedor para utilização no seguro de vida prestamista
    PROCEDURE pc_saldo_devedor(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                              ,pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da conta
                              ,pr_nrctremp     IN crawepr.nrctremp%TYPE  --> Número do contrato
                              ,pr_cdagenci     IN crapage.cdagenci%TYPE  --> Código da agencia
                              ,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                              ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> Código do Operador
                              ,pr_nmdatela     IN craptel.nmdatela%TYPE  --> Nome da Tela
                              ,pr_idorigem     IN INTEGER                --> Identificador de Origem
                              ,pr_flgvincu     IN INTEGER DEFAULT 0      --> Flag de controle para qual cursor principal usar
                              ,pr_flg_saldo_cpf IN INTEGER DEFAULT 0     --> Flag que indica (0 = saldo devedor do contrato, 1 = saldo devedor da pessoa)
                              ,pr_saldodevedor OUT NUMBER                --> Valor do saldo devedor total
                              ,pr_saldodevempr OUT NUMBER                --> Valor do saldo devedor somente dos empréstimos efetivador
                              ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic     OUT VARCHAR2                            ) IS
     /* .............................................................................

         Programa: fn_saldo_devedor
         Sistema : Seguros - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Márcio (Mouts)
         Data    : Agosto/2018.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Função que retorna o saldo devedor para utilização no seguro de vida prestamista.

         Alteracoes: 23/03/2020 - Adicionado tratamento para tbseg_prestamista, buscando somente saldo devedor dos contratos que ainda nao tem certificado,
                                  para inclusao na tabela e geracao de txt para CHUBB. PRJ0015011 (Darlei Zillmer/ Supero)

      ............................................................................. */
  -- ler todos os contratos não liquidados onde a linha de crédito possui o flag de seguro prestamista
      CURSOR cr_crapepr IS
        SELECT
              ce.nrctremp
          FROM
              crapepr ce,
              craplcr cl
         WHERE
              ce.cdcooper = pr_cdcooper
          AND ce.nrdconta = pr_nrdconta
          AND ce.inliquid <> 1 -- não liquidado
          AND cl.cdcooper = ce.cdcooper
          AND cl.cdlcremp = ce.cdlcremp
          AND cl.flgsegpr = 1;

      -- Ler o valor da proposta de contrato atual para somar ao valor do saldo devedor
      CURSOR cr_crawepr IS
        SELECT
               c.vlemprst
          FROM
               crawepr c
         WHERE
               c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = pr_nrctremp
           and not exists (select 1 -- Garantir que somente proposta não efetivada esteja no saldo -- Paulo 12/09
                             from crapepr e -- Emprestimos efetivados
                            where e.cdcooper = c.cdcooper
                              and e.nrdconta = c.nrdconta
                              and e.nrctremp = c.nrctremp);



      -- Tratamento de erros
      vr_exc_erro        EXCEPTION;

      rw_crapdat             BTCH0001.cr_crapdat%ROWTYPE;
      vr_des_reto            VARCHAR2(3) := '';
      vr_tab_erro            GENE0001.typ_tab_erro;
      vr_inusatab            BOOLEAN :=FALSE;
      vr_dstextab            VARCHAR2(400);
      vr_total_saldo_devedor NUMBER:=0;
      vr_vltotpre            NUMBER;--:=0;
      vr_qtprecal            NUMBER:=0;
      vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
      -- PRJ0015011
      vr_dtdcorte        DATE;

    BEGIN
      -- Calendario da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      --Verificar se usa tabela juros
      vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'TAXATABELA'
                                                ,pr_tpregist => 0);
      -- Se a primeira posição do campo dstextab for diferente de zero
      IF vr_dstextab IS NOT NULL AND substr(vr_dstextab,1,1) = 0 THEN
        vr_inusatab:= FALSE;
      ELSE
        vr_inusatab:= TRUE;
      END IF;

        FOR rw_crapepr IN cr_crapepr LOOP
          -- Buscar o saldo devedor atualizado do contrato
          
          IF (pr_flg_saldo_cpf = 1) THEN
          --pr_nrctremp = 0 para buscar pelo cdcooper + nrdconta
          EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => pr_cdcooper             --> Cooperativa conectada
                                        ,pr_cdagenci => pr_cdagenci             --> Codigo da agencia
                                        ,pr_nrdcaixa => pr_nrdcaixa             --> Numero do caixa
                                        ,pr_cdoperad => pr_cdoperad             --> Codigo do operador
                                        ,pr_nmdatela => pr_nmdatela             --> Nome datela conectada
                                        ,pr_idorigem => pr_idorigem             --> Indicador da origem da chamada
                                        ,pr_nrdconta => pr_nrdconta             --> Conta do associado
                                        ,pr_idseqttl => 1                       --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat            --> Vetor com dados de parametro (CRAPDAT)
                                        ,pr_nrctremp => 0                       --> Numero contrato emprestimo
                                        ,pr_cdprogra => 'SEGU0003'            --> Programa conectado
                                        ,pr_inusatab => vr_inusatab             --> Indicador de utilizacão da tabela
                                        ,pr_flgerlog => 'N'                     --> Gerar log S/N
                                        ,pr_vlsdeved => vr_total_saldo_devedor  --> Saldo devedor calculado
                                        ,pr_vltotpre => vr_vltotpre             --> Valor total das prestacães
                                        ,pr_qtprecal => vr_qtprecal             --> Parcelas calculadas
                                        ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);           --> Tabela com possives erros
            
          ELSE
           
          EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => pr_cdcooper             --> Cooperativa conectada
                                        ,pr_cdagenci => pr_cdagenci             --> Codigo da agencia
                                        ,pr_nrdcaixa => pr_nrdcaixa             --> Numero do caixa
                                        ,pr_cdoperad => pr_cdoperad             --> Codigo do operador
                                        ,pr_nmdatela => pr_nmdatela             --> Nome datela conectada
                                        ,pr_idorigem => pr_idorigem             --> Indicador da origem da chamada
                                        ,pr_nrdconta => pr_nrdconta             --> Conta do associado
                                        ,pr_idseqttl => 1                       --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat            --> Vetor com dados de parametro (CRAPDAT)
                                        ,pr_nrctremp => rw_crapepr.nrctremp     --> Numero contrato emprestimo
                                        ,pr_cdprogra => 'SEGU0003'            --> Programa conectado
                                        ,pr_inusatab => vr_inusatab             --> Indicador de utilizacão da tabela
                                        ,pr_flgerlog => 'N'                     --> Gerar log S/N
                                        ,pr_vlsdeved => vr_total_saldo_devedor  --> Saldo devedor calculado
                                        ,pr_vltotpre => vr_vltotpre             --> Valor total das prestacães
                                        ,pr_qtprecal => vr_qtprecal             --> Parcelas calculadas
                                        ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);           --> Tabela com possives erros
          END IF;
         
          -- Se houve retorno de erro
          IF vr_des_reto = 'NOK' THEN
            -- Extrair o codigo e critica de erro da tabela de erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            -- Limpar tabela de erros
            vr_tab_erro.DELETE;
            RAISE vr_exc_erro;
          END IF;
        END LOOP;


      pr_saldodevempr := vr_total_saldo_devedor; --Somente o Saldo devedor - Sem proposta

      -- Buscar o valor da proposta de emprestimo e somar ao saldo devedor
      FOR rw_crawepr IN cr_crawepr LOOP
        vr_total_saldo_devedor:=vr_total_saldo_devedor + rw_crawepr.vlemprst;
      END LOOP;

      pr_saldodevedor:= vr_total_saldo_devedor;


  EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        END IF;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro ao calcular saldo devedor: ' || SQLERRM, chr(13)),chr(10));

    END pc_saldo_devedor;


  BEGIN

   vr_dtdcorte := to_date(gene0001.fn_param_sistema('CRED', 0,'DATA_CORTE_PRESTAMISTA'), 'DD/MM/RRRR');
   vr_nrsequen := fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
   
   --para cada cooperativa...
   FOR rw_crapcop IN cr_crapcop LOOP
      vr_cdcooper := rw_crapcop.cdcooper; -- Para log em caso de exceção imprevista

      -- Calendario da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
                                           
      vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/coop
                                         pr_cdcooper => rw_crapcop.cdcooper);
       
        
      vr_nmarquiv := vr_vet_prefixo(rw_crapcop.cdcooper) || '_' ||
                     REPLACE(to_char(rw_crapdat.dtmvtolt, 'YYYY/MM/DD'), '/', '') || '_' ||
                     gene0002.fn_mask(vr_nrsequen, '99999') || 'MOV.txt';
                     
       -- Leitura da sequencia na tab
       rw_craptab.dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper,
                                                          pr_nmsistem => 'CRED',
                                                          pr_tptabela => 'USUARI',
                                                          pr_cdempres => 11,
                                                          pr_cdacesso => 'SEGPRESTAM',
                                                          pr_tpregist => 0);

       -- Dados da conexao FTP
       vr_endereco := SUBSTR(rw_craptab.dstextab,107,16); --16   
       vr_login    := SUBSTR(rw_craptab.dstextab,124,6);  --6
       vr_senha    := SUBSTR(rw_craptab.dstextab,131,7);  --7  
      
      --nesse laço insere na tbseg_prestamista
      FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_dtdcorte => vr_dtdcorte) LOOP

         -- Buscar data de Nascimento e Tipo de Pessoa - Proposta
        OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_prestamista.nrctremp);
        FETCH cr_crapass
         INTO  vr_cdsexotl,
               vr_nrcpfcgc,
               vr_nmprimtl,
               vr_dtnasctl,
               vr_cdagenci;
        CLOSE cr_crapass;

        OPEN cr_crappep(pr_cdcooper => rw_crapcop.cdcooper
                   ,pr_nrdconta => rw_prestamista.nrdconta
                   ,pr_nrctremp => rw_prestamista.nrctremp);
        FETCH cr_crappep INTO rw_crappep;
        CLOSE cr_crappep;
        vr_dtfimvig := rw_crappep.dtvencto;

         OPEN cr_craptfc(pr_cdcooper => rw_crapcop.cdcooper
                   ,pr_nrdconta => rw_prestamista.nrdconta);
          FETCH cr_craptfc INTO rw_craptfc;
          CLOSE cr_craptfc;

        -- Se a proposta nao estiver efetivada, rodar a rotina para calculo do saldo devedor
        
        --efetiva a consulta do saldo pela pessoa (flg_saldo_cpf = 1)
        pc_saldo_devedor(pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => rw_prestamista.nrdconta,
                         pr_nrctremp => rw_prestamista.nrctremp,
                         pr_cdagenci => vr_cdagenci,
                         pr_nrdcaixa => 1,
                         pr_cdoperad => 1,
                         pr_nmdatela => 'ATENDA',
                         pr_idorigem => 1,
                         pr_flg_saldo_cpf => 1,
                         pr_saldodevedor => vr_saldodevedor,
                         pr_saldodevempr => vr_saldodevempr,
                         pr_flgvincu => vr_flgvincu,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro; -- encerra programa
         END IF;

         -- Leitura dos valores de mínimo e máximo
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper,
                                                  pr_nmsistem => 'CRED',
                                                  pr_tptabela => 'USUARI',
                                                  pr_cdempres => 11,
                                                  pr_cdacesso => 'SEGPRESTAM',
                                                  pr_tpregist => 0);
        -- Se não encontrar
        IF vr_dstextab IS NULL THEN
          vr_vlminimo := 0;
        ELSE
          vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
          vr_pgtosegu := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
          vr_vlprodvl := vr_saldodevedor * vr_pgtosegu; -- Produto – Valor
        END IF;
        
        
       /* --calcula o saldo devedor total do cpf
        pc_calcula_saldo_devedor_cpf(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_nrdconta => rw_prestamista.nrdconta
                                    ,pr_sald_cpf_tot => vr_sald_cpf_tot)
                                    */

         --tudo que se encaixe na regra de saldo devedor
         IF vr_saldodevedor > vr_vlminimo THEN
           
            --busca saldo devedor do contrato.
            pc_saldo_devedor(pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => rw_prestamista.nrdconta,
                         pr_nrctremp => rw_prestamista.nrctremp,
                         pr_cdagenci => vr_cdagenci,
                         pr_nrdcaixa => 1,
                         pr_cdoperad => 1,
                         pr_nmdatela => 'ATENDA',
                         pr_idorigem => 1,
                         pr_saldodevedor => vr_saldodevedor,
                         pr_saldodevempr => vr_saldodevempr,
                         pr_flgvincu => vr_flgvincu,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro; -- encerra programa
             END IF;

             BEGIN
               INSERT INTO tbseg_prestamista (
               cdcooper
               ,nrdconta
               ,nrctrseg
               ,tpregist
               ,cdapolic
               ,nrcpfcgc
               ,nmprimtl
               ,dtnasctl
               ,cdsexotl
               ,dsendres
               ,dsdemail
               ,nmbairro
               ,nmcidade
               ,cdufresd
               ,nrcepend
               ,nrtelefo
               ,dtdevend
               ,dtinivig
               ,nrctremp
               ,cdcobran
               ,cdadmcob
               ,tpfrecob
               ,tpsegura
               ,cdprodut
               ,cdplapro
               ,vlprodut
               ,tpcobran
               ,vlsdeved
               ,vldevatu
               ,dtrefcob
               ,dtfimvig
               ,dtdenvio
              ) VALUES (
                rw_prestamista.cdcooper
               ,rw_prestamista.nrdconta
               ,rw_prestamista.nrctrseg
               ,1 -- tipo adesao
               ,vr_nrsequen -- apolice
               ,vr_nrcpfcgc -- cpf
               ,vr_nmprimtl -- nome
               ,vr_dtnasctl -- data de nasc
               ,vr_cdsexotl -- sexo
               ,rw_prestamista.dsendres -- Endereço
               ,rw_crapcem.dsdemail -- email
               ,rw_prestamista.nmbairro -- Bairro
               ,rw_prestamista.nmcidade -- Cidade
               ,rw_prestamista.cdufresd -- UF
               ,rw_prestamista.nrcepend -- CEP
               ,nvl(rw_prestamista.nrtelefo, rw_craptfc.nrtelefo) -- Telefone Residencial --x
               ,SYSDATE                 -- data da venda
               ,SYSDATE                 -- inicio da vigencia
               ,rw_prestamista.nrctremp -- Emprestimo vinculado
               ,10                      -- Meio de cobranca (fixo 10 - Software Express)
               ,''                      --BY ou BC -- Cód.Administr.Cobrança
               ,'M'                     -- Frequência Cobrança  Mensal: M
               ,'MI'                    -- Tipo Segurado  Titular: MI
               ,'BCV012'                -- codigo
               ,1                       -- plano
               ,vr_vlprodvl             -- valor
               ,'O'                     -- Tipo de cobranca (fixo O - Online)
               ,vr_saldodevedor          -- Saldo Devedor
               ,vr_saldodevedor          -- Saldo devedor atualizado, atualizar o valor a cada endosso
               ,rw_prestamista.dtdebito -- Data referencia para cobranca
               ,vr_dtfimvig
               ,rw_crapdat.dtmvtolt     -- Envio mensal dos endossos
              );
 
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir tbseg_prestamista - ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

         END IF;


      END LOOP; --Loop prestamista

      COMMIT;

      --nesse laço gera arquivo (sera enviado tudo como adesao)
      FOR rw_prestamista_gerar_arquivo IN cr_prestamista_gerar_arquivo(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_seqtran := 1;
          
          vr_linha_txt := '';
          -- informacoes para impressao
          vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); -- Sequencial Transação
          vr_linha_txt := vr_linha_txt || LPAD( 1 , 2, 0); -- Tipo Registro
          vr_linha_txt := vr_linha_txt || 'BZBCC' || LPAD(rw_prestamista_gerar_arquivo.cdapolic, 10, 0); -- Nº Apólice / Certificado
          vr_linha_txt := vr_linha_txt || RPAD(rw_prestamista_gerar_arquivo.nrcpfcgc, 14, ' '); -- CPF / CNPJ - sem formatacao
          vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); -- Cód.Empregado
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_acento(rw_prestamista_gerar_arquivo.nmprimtl)), 70, ' '); -- Nome completo do cliente
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(to_date(rw_prestamista_gerar_arquivo.dtnasctl), 'RRRR-MM-DD'), 10, 0); -- Data Nascimento
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista_gerar_arquivo.cdsexotl, 2, 0); -- Sexo
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_acento(rw_prestamista_gerar_arquivo.dsendres)), 60, ' '); -- Endereço
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_acento(rw_prestamista_gerar_arquivo.nmbairro)), 30, ' '); -- Bairro
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_acento(rw_prestamista_gerar_arquivo.nmcidade)), 30, ' '); -- Cidade
          vr_linha_txt := vr_linha_txt || rw_prestamista_gerar_arquivo.cdufresd; -- UF
          vr_linha_txt := vr_linha_txt || RPAD(rw_prestamista_gerar_arquivo.nrcepend, 10, ' '); -- CEP
          vr_linha_txt := vr_linha_txt ||
                          RPAD(gene0002.fn_mask(rw_prestamista_gerar_arquivo.nrtelefo, '(99)99999-9999'), 15, ' '); -- Telefone Residencial
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Comercial
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Celular
          IF rw_prestamista_gerar_arquivo.dsdemail IS NOT NULL THEN 
            vr_linha_txt := vr_linha_txt || RPAD('Y', 1, ' '); -- E-mail Fulfillment
          ELSE 
            vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); -- E-mail Fulfillment
          END IF;
          vr_linha_txt := vr_linha_txt || RPAD(rw_prestamista_gerar_arquivo.dsdemail, 50, ' '); -- E-mail
          vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' '); -- Cód.Campanha
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Vendedor
          vr_linha_txt := vr_linha_txt || LPAD( rw_prestamista_gerar_arquivo.nrctrseg, 30, ' '); -- Nº Proposta
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(to_date(rw_prestamista_gerar_arquivo.dtdevend), 'RRRR-MM-DD'), 10, 0); -- Data Transação (Data da venda) / Data Cancelamento
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(to_date(rw_prestamista_gerar_arquivo.dtinivig), 'RRRR-MM-DD'), 10, 0); -- Inicio Vigência
          vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' '); -- Razão Cancelam/Suspensão
          --  Referencia 1 50 pos - Contratos vinculados
                                                          
          --1 contrato para cada adesão
          vr_linha_txt := vr_linha_txt || LPAD(nvl(rw_prestamista_gerar_arquivo.nrctremp, 0), 10, 0); -- Referencia 6 - nrctremp
          
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##2
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##3
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##4
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##5
          
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista_gerar_arquivo.cdcooper, 50, 0); -- Referencia 7 - Cooperativa
          vr_linha_txt := vr_linha_txt || LPAD('0', 50, 0); -- Referencia 3 - Nº da Sorte
          vr_linha_txt := vr_linha_txt || rw_prestamista_gerar_arquivo.cdcobran; -- Meio Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(nvl(rw_prestamista_gerar_arquivo.cdadmcob, ' '), 3, ' '); -- Cód.Administr.Cobrança BY e BC
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód. Banco
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Agência
          vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' '); -- Cód.Admin.Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Nº Conta Corrente
          vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' '); -- Validade Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Data Cobrança          
          vr_linha_txt := vr_linha_txt || RPAD(rw_prestamista_gerar_arquivo.tpfrecob, 2, ' '); -- Frequência Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(rw_prestamista_gerar_arquivo.tpsegura, 2, ' '); -- Tipo Segurado
          vr_linha_txt := vr_linha_txt || rw_prestamista_gerar_arquivo.cdprodut; -- Produto - Cód.Produto
          vr_linha_txt := vr_linha_txt || rw_prestamista_gerar_arquivo.cdplapro; -- Produto - Plano
          
          vr_linha_txt := vr_linha_txt || LPAD(replace(rw_prestamista_gerar_arquivo.vlprodut, ',', '.'), 12, 0); -- Produto – Valor
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista_gerar_arquivo.tpcobran, 1, ' '); -- Tipo de Cobrança
          vr_linha_txt := vr_linha_txt || LPAD(replace(rw_prestamista_gerar_arquivo.vldevatu, ',', '.'), 30, 0); -- Valor do Saldo Devedor Atualizado
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(to_date(rw_prestamista_gerar_arquivo.dtrefcob), 'RRRR-MM-DD'), 10, 0); -- Data Referência para Cobrança
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(to_date(rw_prestamista_gerar_arquivo.dtfimvig), 'RRRR-MM-DD'), 10, 0); -- Data final de vigência contrato
          --        vr_linha_txt := vr_linha_txt || chr(13);
          
          -- Opcionais nao enviados
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Data/Hora Autorização – SITEF
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 1 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 2 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 3 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 4 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');-- PSD 5 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 6 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 7 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 8 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 9 – Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' '); -- Código Identificador do Cartão de Crédito (cardHash) – Software Express
          vr_linha_txt := vr_linha_txt || LPAD(' ', 15, ' '); -- authorizerId
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 1 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 1 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 1 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 2 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 2 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 2 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 3 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 3 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 3 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 4 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 4 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 4 - Porcentagem
          -- Opcionais nao enviados
          
          vr_linha_txt := vr_linha_txt || chr(13);
          
          -- escreve linha no arquivo xml
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                                  pr_texto_completo => vr_xml_temp,
                                  pr_texto_novo     => vr_linha_txt);
        
          vr_seqtran := vr_seqtran + 1;
                                              
      END LOOP;
      
       -- Encerrar o Clob
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                                pr_texto_completo => vr_xml_temp,
                                pr_texto_novo     => ' ',
                                pr_fecha_xml      => TRUE);
      
        -- Grava arquivo de contas alteradas
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper,                       --> Cooperativa conectada
                                            pr_cdprogra  => 'ATENDA',                          --> Programa chamador - utilizamos apenas um existente 
                                            pr_dtmvtolt  => trunc(SYSDATE),                    --> Data do movimento atual
                                            pr_dsxml     => vr_clob,                           --> Arquivo XML de dados
                                            pr_dsarqsaid => vr_nmdircop || '/arq/' || vr_nmarquiv, --> Path/Nome do arquivo PDF gerado
                                            pr_flg_impri => 'N',                               --> Chamar a impressão (Imprim.p)
                                            pr_flg_gerar => 'S',                               --> Gerar o arquivo na hora
                                            pr_flgremarq => 'N',                               --> remover arquivo apos geracao
                                            pr_nrcopias  => 1,                                 --> Número de cópias para impressão
                                            pr_des_erro  => vr_dscritic);                      --> Retorno de Erro
      
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := vr_dscritic || ' Cooperativa: ' || vr_cdcooper;
          RAISE vr_exc_saida;
        END IF;
        
       ESMS0001.pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv,      --> Nome arquivo a enviar
                                         pr_idoperac => 'E',              --> Envio de arquivo
                                         pr_nmdireto => vr_nmdircop,      --> Diretório do arquivo a enviar
                                         pr_idenvseg => 'S',              --> Indicador de utilizacao de protocolo seguro (SFTP)
                                         pr_ftp_site => vr_endereco,      --> Site de acesso ao FTP
                                         pr_ftp_user => vr_login,         --> Usuário para acesso ao FTP
                                         pr_ftp_pass => vr_senha,         --> Senha para acesso ao FTP
                                         pr_ftp_path => 'prestamista',    --> Pasta no FTP para envio do arquivo
                                         pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || vr_cdcooper || ' - ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        
        -- Mover o arquivo processado para a pasta "salvar" 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdircop||'/salvar',
                                    pr_typ_saida   => vr_tipo_saida,
                                    pr_des_saida   => vr_dscritic);
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || vr_cdcooper || ' - ' ||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
          
        
        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
        dbms_lob.freetemporary(vr_clob);
      
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        cecred.pc_log_programa(pr_dstiplog   => 'F',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => vr_cdcooper,
                               pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_idprglog   => vr_idprglog);
        
        COMMIT;
                                                   
   END LOOP; -- Loop crapcop
   

   
 ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  EXCEPTION
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
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pr_dscritic := vr_dscritic;

      ROLLBACK;
  END;    
