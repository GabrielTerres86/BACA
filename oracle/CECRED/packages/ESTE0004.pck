CREATE OR REPLACE PACKAGE CECRED.ESTE0004 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0004
      Sistema  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : ESTE
      Autor    : Paulo Penteado (GFT) 
      Data     : Fevereio/2018.                   Ultima atualizacao: 28/06/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN - Motor de Credito

      Alteracoes: 18/02/2018 Criaçao (Paulo Penteado (GFT))

                  23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
                  Referentes a proposta. (Lindon Carlos Pecile - GFT)

				  30/04/2019 - Chamada JSON variáveis internas (Mario - AMcom)

                  28/06/2019 - P450 - Reposicionado VariaveisInterna abaixo de VariaveisAdicionais no Proponente (Mario - AMcom)   

				  08/08/2019 - Adição do campo segueFluxoAtacado ao retorno 
				               P637 (Darlei / Supero)


  ---------------------------------------------------------------------------------------------------------------*/
  --> Rotina responsavel por montar o objeto json para analise de limite de desconto de títulos
  PROCEDURE pc_gera_json_analise_lim(pr_cdcooper   in crapass.cdcooper%type
                                    ,pr_cdagenci   in crapass.cdagenci%type
                                    ,pr_nrdconta   in crapass.nrdconta%type
                                    ,pr_nrctrlim   in crawlim.nrctrlim%type
                                    ,pr_tpctrlim   in crawlim.tpctrlim%type
                                    ,pr_nrctaav1   in crawlim.nrctaav1%type
                                    ,pr_nrctaav2   in crawlim.nrctaav2%type
                                    ---- OUT ----
                                    ,pr_dsjsonan  out nocopy json             --> Retorno do clob em modelo json com os dados para analise
                                    ,pr_cdcritic  out number                  --> Codigo da critica
                                    ,pr_dscritic  out varchar2                --> Descricao da critica
                                    );
                                
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta_lim(pr_cdcooper in crawepr.cdcooper%type
                                     ,pr_cdagenci in crapage.cdagenci%type
                                     ,pr_cdoperad in crapope.cdoperad%type
                                     ,pr_nrdconta in crawepr.nrdconta%type
                                     ,pr_nrctrlim in crawlim.nrctrlim%type
                                     ,pr_tpctrlim in crawlim.tpctrlim%type
                                     ,pr_nmarquiv in varchar2                --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                     ---- OUT ----
                                     ,pr_proposta out json                   --> Retorno do clob em modelo json da proposta de emprestimo
                                     ,pr_cdcritic out number                 --> Codigo da critica
                                     ,pr_dscritic out varchar2               --> Descricao da critica
                                     );
         
END ESTE0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0004 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0004
      Sistema  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Paulo Penteado (Gft)
      Data     : Março/2018.                   Ultima atualizacao: 23/03/2018
      
      Dados referentes ao programa:
      Frequencia: Sempre que solicitado
      Objetivo  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes: 23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
                  Referentes a proposta. (Lindon Carlos Pecile - GFT)

                  05/06/2019 - P450 - Adicionada a variavel BiroScore no JSON de envio 
                               a Ibratan (Heckmann - AMcom)

                  13/08/2019 - P450 - Inclusão do modeloRating na pc_gera_json_analise_lim para informar o tipo de calculo que
                               Ibratan deve calcular e retornar do Rating definido na PARRAT
                               Luiz Otavio Olinger Momm - AMCOM

  ---------------------------------------------------------------------------------------------------------------*/
  CURSOR cr_craplim(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                   ) IS
  SELECT lim.vllimite
  FROM   craplim lim
  WHERE  lim.insitlim = 2
  AND    lim.tpctrlim = 3
  AND    lim.nrdconta = pr_nrdconta
  AND    lim.cdcooper = pr_cdcooper;
  rw_craplim cr_craplim%ROWTYPE;
  

  FUNCTION fn_des_tpctrato(pr_tpctrato IN NUMBER) RETURN VARCHAR2 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : fn_des_tpctrato
      Sistema  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CRED
      Autor    : Paulo Penteado (Gft)
      Data     : Abrir/2018.

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descrição do Tipo do contrato de Limite Desconto

      Alteração : 30/04/2018 Criação (Paulo Penteado (GFT)) 

  ---------------------------------------------------------------------------------------------------------------*/
    vr_tpctrato VARCHAR2(100) := NULL;

  BEGIN
    SELECT CASE pr_tpctrato WHEN 1 THEN 'EMPRESTIMO'
                            WHEN 2 THEN 'ALIENACAO FIDUCIARIA'
                            WHEN 3 THEN 'HIPOTECA'
                            WHEN 4 THEN 'APLICACAO FINANCEIRA'
                            ELSE        NULL
           END CASE
    INTO   vr_tpctrato FROM dual;

    RETURN vr_tpctrato;
  EXCEPTION
    WHEN OTHERS THEN
         RETURN NULL;
  END fn_des_tpctrato;


  --> Rotina responsavel por montar o objeto json para analise de limite de desconto de títulos
  PROCEDURE pc_gera_json_analise_lim(pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%type
                                    ,pr_nrdconta   IN crapass.nrdconta%type
                                    ,pr_nrctrlim   IN crawlim.nrctrlim%type
                                    ,pr_tpctrlim   IN crawlim.tpctrlim%type
                                    ,pr_nrctaav1   IN crawlim.nrctaav1%type
                                    ,pr_nrctaav2   IN crawlim.nrctaav2%type
                                    ---- OUT ----
                                    ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                                    ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                    ,pr_dscritic  OUT varchar2                --> Descricao da critica
                                    ) is
  /* ..........................................................................
    
      Programa : pc_gera_json_analise_lim
      Sistema  : 
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT) 
      Data     : Fevereiro/2018.                   Ultima atualizacao: 18/02/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.
    
      Alteraçao : 
                  08/08/2019 - Adição do campo segueFluxoAtacado ao retorno 
				               P637 (Darlei / Supero)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
   -- Buscar quantidade de dias de reaproveitamento     
  CURSOR cr_craprbi IS
    select rbi.qtdiarpv
    from   craprbi rbi
          ,crapass ass
          ,crawlim lim
    where  rbi.cdcooper = pr_cdcooper
    and    rbi.inpessoa = ass.inpessoa
    and    rbi.inprodut = 5
    and    ass.cdcooper = pr_cdcooper
    and    ass.nrdconta = pr_nrdconta
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
  rw_craprbi cr_craprbi%rowtype;
  
  -- Buscar PA do operador de envio da proposta
  CURSOR cr_crapope IS
    select ope.cdpactra
    from   crapope ope
          ,crawlim lim
    where  ope.cdcooper = pr_cdcooper
    and    upper(ope.cdoperad) = upper(lim.cdoperad)
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
  vr_cdpactra crapope.cdpactra%type;
  
  -- Buscar última data de consulta ao bacen
  CURSOR cr_crapopf IS
     SELECT max(opf.dtrefere) dtrefere
        FROM crapopf opf;
  rw_crapopf cr_crapopf%ROWTYPE;
  
  --> Buscar dados do limite
  CURSOR cr_crawlim IS
    select 'LIMITE DESCONTO TITULO' dsoperac
          ,0 flgreneg -- renegociacao: Indicaçao de Operaçao de Renegociaçao 
          ,lim.vllimite
          ,0 vlpreemp
          ,0 qtpreemp
          ,lim.dtinivig
          ,lim.dtfimvig
          ,ldc.cddlinha cdlcremp
          ,ldc.dsdlinha dslcremp
          ,lim.tpctrlim
          ,case when nvl(lim.nrctrmnt,0) = 0 then 'LM'
                else                              'MJ'
           end tpproduto
          ,decode(ldc.tpctrato, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto  (0-Generico/ 1-Aplicacao)
          ,decode(ldc.tpctrato, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato
          ,0 cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
          ,'' dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo
          ,lim.inconcje
          ,lim.idquapro
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,'C' despagto --Tipo do Debito do Emprestimo: C-CONTA F-FOLHA
          ,ldc.txmensal
          ,0 perceto
          ,lim.qtdiavig
          ,lim.cddlinha
          ,lim.idfluata -- P637
          ,lim.cdoperad
    from   crapldc ldc
          ,crapass ass
          ,crawlim lim
    where  ldc.cdcooper = lim.cdcooper
    and    ldc.cddlinha = lim.cddlinha
    and    ldc.tpdescto = lim.tpctrlim
    and    ass.cdcooper = lim.cdcooper
    and    ass.nrdconta = lim.nrdconta
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
    rw_crawlim cr_crawlim%rowtype;
    
    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar dados titular
    CURSOR cr_crapttl(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ttl.dtnasttl
            ,ttl.inhabmen
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;                      
    rw_crapttl cr_crapttl%rowtype;
    
    -- Buscar avalistas terceiros
    CURSOR cr_crapavt(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrlim crapavt.nrctremp%TYPE,
                      pr_tpctrato crapavt.tpctrato%TYPE,
                      pr_dsproftl crapavt.dsproftl%TYPE) IS
      SELECT crapavt.* --> necessario ser todos os campos pois envia como parametro
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctrlim
         AND crapavt.tpctrato = pr_tpctrato
         AND (   pr_dsproftl IS NULL 
               OR ( pr_dsproftl = 'SOCIO' AND dsproftl IN('SOCIO/PROPRIETARIO'
                                                         ,'SOCIO ADMINISTRADOR'
                                                         ,'DIRETOR/ADMINISTRADOR'
                                                         ,'SINDICO'
                                                         ,'ADMINISTRADOR'))
               OR ( pr_dsproftl = 'PROCURADOR' AND dsproftl LIKE UPPER('%PROCURADOR%'))
              );
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar cadastro do Conjuge:
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcje.nrctacje
            ,crapcje.nmconjug
            ,crapcje.nrcpfcjg
            ,crapcje.dtnasccj
            ,crapcje.tpdoccje
            ,crapcje.nrdoccje
            ,crapcje.grescola
            ,crapcje.cdfrmttl
            ,crapcje.cdnatopc
            ,crapcje.cdocpcje
            ,crapcje.tpcttrab
            ,crapcje.dsproftl
            ,crapcje.cdnvlcgo
            ,crapcje.nrfonemp
            ,crapcje.nrramemp
            ,crapcje.cdturnos
            ,crapcje.dtadmemp
            ,crapcje.vlsalari
            ,crapcje.nrdocnpj
            ,crapcje.cdufdcje
       FROM crapcje
      WHERE crapcje.cdcooper = pr_cdcooper
        AND crapcje.nrdconta = pr_nrdconta
        AND crapcje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    --> Buscar representante legal
    CURSOR cr_crapcrl (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcrl.cdcooper
            ,crapcrl.nrctamen
            ,crapcrl.idseqmen
            ,crapcrl.nrdconta
            ,crapcrl.nrcpfcgc
            ,crapcrl.nmrespon
            ,org.cdorgao_expedidor dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapnac.dsnacion
            ,crapcrl.dsnatura
            ,crapcrl.cdcepres
            ,crapcrl.dsendres
            ,crapcrl.nrendres
            ,crapcrl.dscomres
            ,crapcrl.dsbaires
            ,crapcrl.nrcxpost
            ,crapcrl.dscidres
            ,crapcrl.dsdufres
            ,crapcrl.nmpairsp
            ,crapcrl.nmmaersp
            ,crapcrl.tpdeiden
            ,crapcrl.nridenti
            ,crapcrl.cdrlcrsp
        FROM crapcrl,
             crapnac,
             tbgen_orgao_expedidor org
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.cdnacion = crapnac.cdnacion(+)
         AND crapcrl.idorgexp = org.idorgao_expedidor(+);
    
    -- Declarar cursor de participaçoes societárias
    CURSOR cr_crapepa (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cdcooper, 
             nrdconta, 
             nrdocsoc, 
             nrctasoc, 
             nmfansia, 
             nrinsest, 
             natjurid, 
             dtiniatv, 
             qtfilial, 
             qtfuncio, 
             dsendweb, 
             cdseteco, 
             cdmodali, 
             cdrmativ, 
             vledvmto, 
             dtadmiss, 
             dtmvtolt, 
             persocio, 
             nmprimtl
        FROM crapepa 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta;
    
    -- Buscar descriçao
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE; 
    
    -- Buscar descriçao
    CURSOR cr_gnrativ ( pr_cdseteco gnrativ.cdseteco%TYPE,
                        pr_cdrmativ gnrativ.cdrmativ%TYPE)IS
      SELECT gnrativ.nmrmativ
        FROM gnrativ
       WHERE gnrativ.cdseteco = pr_cdseteco
         AND gnrativ.cdrmativ = pr_cdrmativ;    
    rw_gnrativ cr_gnrativ%ROWTYPE;
    
    
    -- Buscar os bens em garanita na Proposta
    CURSOR cr_crapbpr IS       
      SELECT crapbpr.dscatbem
            ,crapbpr.vlmerbem
            ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctrlim
         AND crapbpr.tpctrpro = 3
         AND trim(crapbpr.dscatbem) is not NULL;
    
    -- Buscar Saldo de Cotas
    CURSOR cr_crapcot(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vldcotas
        FROM crapcot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;
    
    --> Buscar se a conta é de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS 
                     
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col       
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';         
     
    CURSOR cr_crapprp IS
    SELECT prp.flgdocje
     FROM crapprp prp
    WHERE prp.cdcooper = pr_cdcooper
      AND prp.nrdconta = pr_nrdconta
     AND prp.nrctrato = pr_nrctrlim
     AND prp.tpctrato = 3;
  rw_crapprp cr_crapprp%ROWTYPE;
   
    CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                      ,pr_nrdconta IN crapepr.nrdconta%TYPE
                      ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT nvl(vlpreemp,0)
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;

  
    --Busca Patrimonio referencial da cooperativa 
    CURSOR cr_tbcadast_cooperativa(pr_cdcooper INTEGER) IS
      SELECT vlpatrimonio_referencial
        FROM tbcadast_cooperativa
       WHERE cdcooper = pr_cdcooper;
    rw_tbcadast_cooperativa cr_tbcadast_cooperativa%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    -- Objeto json    
    vr_obj_analise   json      := json();
    vr_obj_conjuge   json      := json();
    vr_obj_avalista  json      := json();
    vr_obj_responsav json      := json();
    vr_obj_socio     json      := json();
    vr_obj_particip  json      := json();
    vr_obj_procurad  json      := json();
    vr_obj_generico  json      := json();
    vr_obj_generic2  json      := json();
    vr_obj_generic4  json      := json(); -- Variáveis internas
    vr_lst_generico  json_list := json_list();
    vr_lst_generic2  json_list := json_list();
    
    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_flgbens       BOOLEAN := FALSE;
    vr_nrdeanos      INTEGER;
    vr_nrdmeses      INTEGER;
    vr_dsdidade      VARCHAR2(100);
    vr_dstextab      craptab.dstextab%TYPE;
    vr_nmseteco      craptab.dstextab%TYPE;
    vr_dsquapro      VARCHAR2(100);
    vr_flgcolab      BOOLEAN;
    vr_cddcargo      tbcadast_colaborador.cdcooper%TYPE;
    vr_qtdiarpv      INTEGER;
    vr_valoriof      NUMBER;
    vr_tab_split     gene0002.typ_split;
    vr_dsliquid      VARCHAR2(1000);
    vr_sum_vlpreemp  crapepr.vlpreemp%TYPE := 0;
    vr_vlpreemp      crapepr.vlpreemp%TYPE;
    vr_txcetano      NUMBER;
    vr_txcetmes      NUMBER;
    vr_vllimati      craplim.vllimite%TYPE;
      
    vr_vlpatref      tbcadast_cooperativa.vlpatrimonio_referencial%TYPE;
    
    vr_cdorigem NUMBER := 0;

  BEGIN
  
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
  
    vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(pr_nrctrlim));
                      
   -- Buscar quantidade de dias de reaproveitamento             
    OPEN cr_craprbi;
    FETCH cr_craprbi INTO rw_craprbi;
    
    -- Se encontrou
    IF cr_craprbi%FOUND THEN
     -- Buscar a coluna e multiplicar por 24 para chegarmos na quantidade de horas de reaproveitamento
     vr_qtdiarpv := rw_craprbi.qtdiarpv * 24;
    ELSE
     -- Se nao encontrar consideramos 168 horas (7 dias)
     vr_qtdiarpv := 168;
    END IF;
    CLOSE cr_craprbi;
  
  -- Buscar PA do operador
  OPEN cr_crapope;
  FETCH cr_crapope INTO vr_cdpactra;
    CLOSE cr_crapope;
  
  OPEN cr_crapopf;
  FETCH cr_crapopf INTO rw_crapopf;
    IF cr_crapopf%NOTFOUND THEN
      CLOSE cr_crapopf;
      vr_dscritic := 'Data Base Bacen-SCR nao encontrada!';
      RAISE vr_exc_erro;
    ELSE
    CLOSE cr_crapopf;
    END IF;
  
    rw_crapass := NULL;
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

   OPEN  cr_craplim(pr_cdcooper
                   ,pr_nrdconta);
   FETCH cr_craplim INTO rw_craplim;
   CLOSE cr_craplim;
  
   -- Montar os atributos de 'configuracoes'
   vr_obj_generico := json();
   vr_obj_generico.put('centroCusto', vr_cdpactra);
   vr_obj_generico.put('dataBaseBacen', to_char(rw_crapopf.dtrefere,'RRRRMM'));
   vr_obj_generico.put('horasReaproveitamento', vr_qtdiarpv);
  
    -- Adicionar o array configuracoes
    vr_obj_analise.put('configuracoes', vr_obj_generico);                  
                  
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawlim;
    FETCH cr_crawlim INTO rw_crawlim;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawlim%NOTFOUND THEN
      CLOSE cr_crawlim;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawlim;
    
    --> indicadoresCliente
    vr_obj_generico := json();
    
    vr_obj_generico.put('cooperativa', pr_cdcooper); 
    vr_obj_generico.put('agenci', pr_cdagenci);

    vr_obj_generico.put('segmentoCodigo' ,5); 
    vr_obj_generico.put('segmentoDescricao' ,'Desconto Titulo Limite');

    vr_obj_generico.put('linhaCreditoCodigo'    ,rw_crawlim.cdlcremp);
    vr_obj_generico.put('linhaCreditoDescricao' ,rw_crawlim.dslcremp);
    --vr_obj_generico.put('finalidadeCodigo'      ,rw_crawlim.cdfinemp);       
    --vr_obj_generico.put('finalidadeDescricao'   ,rw_crawlim.dsfinemp);                

    vr_obj_generico.put('tipoProduto'           ,rw_crawlim.tpproduto);
    
    IF  rw_crawlim.tpctrato > 0 THEN
        vr_obj_generico.put('tipoGarantiaCodigo'   , rw_crawlim.tpctrato );
        vr_obj_generico.put('tipoGarantiaDescricao', rw_crawlim.dsctrato );
    END IF;

	-- P637 - fluxo atacado - 08/08/2019
    vr_obj_generico.put('segueFluxoAtacado'    ,(CASE WHEN rw_crawlim.idfluata=1 THEN TRUE ELSE FALSE END)); 

    vr_obj_generico.put('debitoEm'    ,rw_crawlim.despagto );
    vr_obj_generico.put('liquidacao'  ,rw_crawlim.dsliquid!='0,0,0,0,0,0,0,0,0,0');

    vr_obj_generico.put('valorTaxaMensal', ESTE0001.fn_decimal_ibra(rw_crawlim.txmensal));

    vr_obj_generico.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_crawlim.vllimite));
    vr_obj_generico.put('quantParcela'  , rw_crawlim.qtpreemp);
    vr_obj_generico.put('primeiroVencto', este0002.fn_data_ibra_motor(rw_crawlim.dtfimvig));
    vr_obj_generico.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_crawlim.vlpreemp));

    vr_vllimati := nvl(rw_craplim.vllimite,0);
    IF  vr_vllimati > 0 THEN
        vr_obj_generico.put('valorLimiteAtivo', vr_vllimati);
    END IF;

    --  valor que está sendo marjorado
    IF  rw_crawlim.tpproduto = 'MJ' THEN
        vr_obj_generico.put('valorLimiteMaximoPermitido', rw_crawlim.vllimite - vr_vllimati);
    END IF;
    
    vr_obj_generico.put('renegociacao', nvl(rw_crawlim.flgreneg,0) = 1);

    vr_obj_generico.put('qualificaOperacaoCodigo',rw_crawlim.idquapro );

    CASE rw_crawlim.idquapro
      WHEN 1 THEN vr_dsquapro := 'Operacao normal';
      WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
      WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
      WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
      ELSE vr_dsquapro := ' ';
    END CASE;

    vr_obj_generico.put('qualificaOperacaoDescricao'    ,vr_dsquapro );
         
    IF rw_crawlim.inpessoa = 1 THEN 
      -- Verificar se a conta é de colaborador do sistema Cecred
      vr_cddcargo := NULL;
      OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => rw_crawlim.nrcpfcgc);
      FETCH cr_tbcolab INTO vr_cddcargo;
      IF cr_tbcolab%FOUND THEN 
        vr_flgcolab := TRUE;
      ELSE
        vr_flgcolab := FALSE;
      END IF;
      CLOSE cr_tbcolab; 
              
      vr_obj_generico.put('cooperadoColaborador',vr_flgcolab);
   
   OPEN cr_crapprp;
   FETCH cr_crapprp INTO rw_crapprp;
   CLOSE cr_crapprp;
      vr_obj_generico.put('conjugeCoResponv',nvl(rw_crapprp.flgdocje,0)=1);

    END IF;
    
    -- Efetuar laço para trazer todos os registros 
    FOR rw_crapbpr IN cr_crapbpr LOOP 

      -- Indicar que encontrou
      vr_flgbens := TRUE;
      -- Para cada registro de Bem, criar objeto para a operaçao e enviar suas informaçoes 
      vr_lst_generic2 := json_list();
      vr_obj_generic2 := json();
      vr_obj_generic2.put('categoriaBem',     rw_crapbpr.dscatbem);
      vr_obj_generic2.put('anoGarantia',      rw_crapbpr.nranobem);
      vr_obj_generic2.put('valorGarantia',    ESTE0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
      vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);

      -- Adicionar Bem na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
  
    END LOOP; -- Final da leitura dos Bens

    -- Adicionar o array bemEmGarantia
    IF vr_flgbens THEN
      vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
    ELSE
      -- Verificar se o valor das Cotas é Superior ao da Proposta
      OPEN cr_crapcot(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapcot
       INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Se valor das cotas é superior ao da proposta
      IF NVL(vr_vldcotas,0) > rw_crawlim.vllimite THEN 
        -- Adicionar as cotas  
        vr_lst_generic2 := json_list();
        vr_obj_generic2 := json();
        vr_obj_generic2.put('categoriaBem','COTAS CAPITAL');
        vr_obj_generic2.put('anoGarantia',0);
        vr_obj_generic2.put('valorGarantia',ESTE0001.fn_decimal_ibra(vr_vldcotas));
        vr_obj_generic2.put('bemInterveniente',false);
        -- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
        -- Adicionar as cotas como garantia
        vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
      END IF;
    END IF;  

    vr_obj_generico.put('BiroScore',rati0003.fn_tipo_biro(pr_cdcooper => pr_cdcooper));

    vr_obj_generico.put('operacao', rw_crawlim.dsoperac);
    
    -- Buscar IOF
    vr_valoriof := 0;
    vr_obj_generico.put('IOFValor', este0001.fn_decimal_ibra(nvl(vr_valoriof,0)));

    IF rw_crawlim.dsliquid <> '0,0,0,0,0,0,0,0,0,0' THEN
      vr_tab_split := gene0002.fn_quebra_string(rw_crawlim.dsliquid, ',');
      
      vr_dsliquid := vr_tab_split.FIRST;
          
      vr_sum_vlpreemp := 0;
      
      WHILE vr_dsliquid IS NOT NULL LOOP
        
        IF vr_tab_split(vr_dsliquid) <> '0' THEN
          
          OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_split(vr_dsliquid));
          FETCH cr_crapepr INTO vr_vlpreemp;
          CLOSE cr_crapepr;
          vr_sum_vlpreemp := vr_sum_vlpreemp + vr_vlpreemp;
          
        END IF;
        vr_dsliquid := vr_tab_split.NEXT(vr_dsliquid);    
      END LOOP;
    END IF;
    
    vr_obj_generico.put('valorPrestLiquidacao', ESTE0001.fn_decimal_ibra(vr_sum_vlpreemp));

    -- Buscar Patrimonio referencial da cooperativa 
    OPEN cr_tbcadast_cooperativa(pr_cdcooper);
    FETCH cr_tbcadast_cooperativa INTO vr_vlpatref;
     
    IF cr_tbcadast_cooperativa%NOTFOUND THEN
      vr_vlpatref := 0;
    END IF;
    CLOSE cr_tbcadast_cooperativa;    
    -- Incluir Patrimonio referencial da cooperativa
    vr_obj_generico.put('valorPatrimonioReferencial',ESTE0001.fn_decimal_ibra(vr_vlpatref));

    vr_cdorigem := CASE WHEN rw_crawlim.cdoperad = '996' THEN 3 ELSE 5 END;

    vr_obj_generico.put('canalOrigem',vr_cdorigem);

    /* P450 - Rating modelo calculo */
    vr_obj_generico.put('modeloRating', RATI0003.fn_retorna_modelo_rating(pr_cdcooper));
    
    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);

    este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctrlim  -- P450-LUIZAMCOM - Na producao estava igual a 0
                                    ,pr_flprepon => false
                                    ,pr_tpprodut => 1
                                    ,pr_inPropon => True
                                    ,pr_dsjsonan => vr_obj_generico
                                    ,pr_cdcritic => vr_cdcritic 
                                    ,pr_dscritic => vr_dscritic);
                           
     -- Testar possíveis erros na rotina:
     IF nvl(vr_cdcritic,0) <> 0 OR 
        trim(vr_dscritic) IS NOT NULL THEN 
       RAISE vr_exc_erro;
     END IF;    
       
    -- Adicionar o JSON montado do Proponente no objeto principal
    vr_obj_analise.put('proponente',vr_obj_generico);
    
    
    --> Para Pessoa Fisica iremos buscar seu Conjuge
    IF rw_crapass.inpessoa = 1 THEN 
    
      --> Buscar cadastro do Conjuge
      rw_crapcje := NULL;
      OPEN cr_crapcje( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcje INTO rw_crapcje;
     
      -- Se nao encontrar 
      IF cr_crapcje%NOTFOUND THEN
        -- apenas fechamos o cursor
        CLOSE cr_crapcje;
      ELSE   
        -- Fechar o cursor e enviar 
        CLOSE cr_crapcje;
        --> Se Conjuge for associado:
        IF rw_crapcje.nrctacje <> 0 THEN 

          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapcje.nrctacje
                                          ,pr_nrctremp => 0
                                          ,pr_flprepon => false
                                          ,pr_vlsalari => rw_crapcje.vlsalari
                                          ,pr_tpprodut => 1
                                          ,pr_inPropon => false
                                          ,pr_dsjsonan => vr_obj_conjuge
                                          ,pr_cdcritic => vr_cdcritic 
                                          ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
            
          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento'      ,este0002.fn_mask_cpf_cnpj(NVL(rw_crapcje.nrcpfcjg,0),1));
          vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
          vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);
          
          vr_obj_conjuge.put('dataNascimento' ,este0002.fn_data_ibra_motor(rw_crapcje.dtnasccj));
          
          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;
          
          -- Montar objeto Telefone para Telefone Comercial      
          IF rw_crapcje.nrfonemp <> ' ' THEN 
            vr_lst_generic2 := json_list();
            -- Criar objeto só para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            /*
            IF SUBSTR(rw_crapcje.nrfonemp,1,1) < 8 THEN 
              vr_obj_generico.put('tipo', 'FIXO');
            ELSE
              vr_obj_generico.put('tipo', 'MOVEL');
            END IF;
   */
            
            vr_obj_generico.put('numero', este0002.fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
            -- Adicionar telefone na lista
            vr_lst_generic2.append(vr_obj_generico.to_json_value());
            -- Adicionar o array telefone no objeto Conjuge
            vr_obj_conjuge.put('telefones', vr_lst_generic2);
              
          END IF;     

          -- Montar objeto profissao       
          IF rw_crapcje.dsproftl <> ' ' THEN 
            vr_obj_generico := json();
            vr_obj_generico.put('titulo'   , rw_crapcje.dsproftl);
            vr_obj_conjuge.put ('profissao', vr_obj_generico);
          END IF;     
          
          -- Montar informaçoes Adicionais
          vr_obj_generico := json();
          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN 
            vr_obj_generico.put('escolaridade', rw_crapcje.grescola);
          END IF;
          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN 
            vr_obj_generico.put('cursoSuperiorCodigo'
                               ,rw_crapcje.cdfrmttl);
            vr_obj_generico.put('cursoSuperiorDescricao'
                               ,este0002.fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;
          -- Natureza Ocupaçao
          IF rw_crapcje.cdnatopc <> 0 THEN 
            vr_obj_generico.put('naturezaOcupacao', rw_crapcje.cdnatopc);
          END IF;
          -- Ocupaçao
          IF rw_crapcje.cdocpcje <> 0 THEN 
            vr_obj_generico.put('ocupacaoCodigo'
                               ,rw_crapcje.cdocpcje);
            vr_obj_generico.put('ocupacaoDescricao'
                               ,este0002.fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;
          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN 
            vr_obj_generico.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
          END IF;
          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN 
            vr_obj_generico.put('nivelCargo', rw_crapcje.cdnvlcgo);
          END IF;
          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN 
            vr_obj_generico.put('turno', rw_crapcje.cdturnos);
          END IF;
          -- Data Admissao
          IF rw_crapcje.dtadmemp IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissao', este0002.fn_data_ibra_motor(rw_crapcje.dtadmemp));
          END IF;
          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN 
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;
          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN 
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;
          -- Enviar informaçoes adicionais ao JSON Conjuge
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);        
              
          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);        
        END IF; 
        
      END IF;  
    END IF;

    --> Chamar rorina para calcular o contrato do cet
    CCET0001.pc_calculo_cet_limites( pr_cdcooper  => pr_cdcooper         -- Cooperativa
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt -- Data Movimento
                                    ,pr_cdprogra  => 'ATENDA'            -- Programa chamador
                                    ,pr_nrdconta  => pr_nrdconta         -- Conta/dv
                                    ,pr_inpessoa  => rw_crapass.inpessoa -- Indicativo de pessoa
                                    ,pr_cdusolcr  => 1                   -- Codigo de uso da linha de credito
                                    ,pr_cdlcremp  => rw_crawlim.cddlinha -- Linha de credio
                                    ,pr_tpctrlim  => pr_tpctrlim         --> Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                    ,pr_nrctrlim  => pr_nrctrlim         -- Contrato
                                    ,pr_dtinivig  => nvl(rw_crawlim.dtinivig,rw_crapdat.dtmvtolt) -- Data liberacao
                                    ,pr_qtdiavig  => rw_crawlim.qtdiavig -- Dias de vigencia
                                    ,pr_vlemprst  => rw_crawlim.vllimite -- Valor emprestado
                                    ,pr_txmensal  => rw_crawlim.txmensal -- Taxa mensal
                                    ,pr_txcetano  => vr_txcetano         -- Taxa cet ano
                                    ,pr_txcetmes  => vr_txcetmes         -- Taxa cet mes
                                    ,pr_cdcritic  => vr_cdcritic
                                    ,pr_dscritic  => vr_dscritic);

    vr_obj_generico.put('CETValor', este0001.fn_decimal_ibra(nvl(vr_txcetano,0)));
    
    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS: 
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();
 
    -- Enviar avalista 01 em novo json só para avalistas
    IF nvl(pr_nrctaav1,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;

      este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrctaav1
                                      ,pr_nrctremp => 0
                                      ,pr_flprepon => FALSE
                                      ,pr_tpprodut => 1
                                      ,pr_inPropon => false
                                      ,pr_dsjsonan => vr_obj_avalista
                                      ,pr_cdcritic => vr_cdcritic 
                                      ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    -- Enviar avalista 02 em novo json só para avalistas
    IF nvl(pr_nrctaav2,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrctaav2
                                      ,pr_nrctremp => 0
                                      ,pr_flprepon => FALSE
                                      ,pr_tpprodut => 1
                                      ,pr_dsjsonan => vr_obj_avalista
                                      ,pr_cdcritic => vr_cdcritic 
                                      ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    --> Efetuar laço para retornar todos os registros disponíveis:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta 
                                ,pr_nrctrlim => pr_nrctrlim
                                ,pr_tpctrato => 8
                                ,pr_dsproftl => null) LOOP
                                 
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros 
      este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                      ,pr_dsjsonavt  => vr_obj_avalista
                                      ,pr_cdcritic   => vr_cdcritic 
                                      ,pr_dscritic   => vr_dscritic);
      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF; 
      
      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());
      
      
    END LOOP; --> crapavt                             
    
    -- Enviar novo objeto de avalistas para dentro do objeto principal (Se houve encontro) 
    IF vr_flavalis = true THEN
      vr_obj_analise.put('avalistas' , vr_lst_generico);
    END IF; 
  
    --> Para pessoa física verificaremos necessidade de envio dos responsáveis legais:
    IF rw_crapass.inpessoa = 1 THEN 
      
       -- Buscar dados titular
       OPEN cr_crapttl(pr_cdcooper,pr_nrdconta);
       FETCH cr_crapttl
        INTO rw_crapttl;
       CLOSE cr_crapttl; 
         
       -- Inicializar idade
       vr_nrdeanos := 18;    
       -- Se menor de idade 
       IF rw_crapttl.inhabmen = 0  THEN 
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapttl.dtnasttl
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_nrdeanos => vr_nrdeanos
                                ,pr_nrdmeses => vr_nrdmeses
                                ,pr_dsdidade => vr_dsdidade
                                ,pr_des_erro => vr_dscritic);

         -- Verficia se ocorreram erros
         IF vr_dscritic IS NOT NULL THEN
           vr_nrdeanos := 18;
         END IF;
       END IF;
    
      -- Se menor de idade ou incapaz
      IF vr_nrdeanos < 18 OR rw_crapttl.inhabmen = 2 THEN
      
        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();
        
        --> Efetuar laço para retornar todos os registros disponíveis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que há responsaveis
          vr_flrespvl := true;
          
          --> Se Responsável for associado
          IF rw_crapcrl.nrdconta <> 0 THEN 
            -- Passaremos a conta para montagem dos dados:
            este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapcrl.nrdconta
                                            ,pr_nrctremp => 0
                                            ,pr_flprepon => FALSE
                                            ,pr_tpprodut => 1
                                            ,pr_dsjsonan => vr_obj_responsav
                                            ,pr_cdcritic => vr_cdcritic 
                                            ,pr_dscritic => vr_dscritic); 
            -- Testar possíveis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados básicos encontrados na tabela de responsável legal
           vr_obj_responsav.put('documento'      , este0002.fn_mask_cpf_cnpj(NVL(rw_crapcrl.nrcpfcgc,0),1));
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);
           IF rw_crapcrl.cddosexo = 1 THEN
             vr_obj_responsav.put('sexo','MASCULINO');
           ELSE
             vr_obj_responsav.put('sexo','FEMININO');
           END IF;
           
           IF rw_crapcrl.dtnascin IS NOT NULL THEN 
             vr_obj_responsav.put('dataNascimento' ,este0002.fn_data_ibra_motor(rw_crapcrl.dtnascin));
           END IF;
           
           IF rw_crapcrl.nmmaersp IS NOT NULL THEN 
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
           END IF;
           
           vr_obj_responsav.put('nacionalidade'  ,rw_crapcrl.dsnacion);

           -- Se o Documento for RG
           IF rw_crapcrl.tpdeiden = 'CI' THEN
             vr_obj_responsav.put('rg', rw_crapcrl.nridenti);
             vr_obj_responsav.put('ufRg', rw_crapcrl.cdufiden);
           END IF; 

           -- Montar objeto Endereco
           IF rw_crapcrl.dsendres <> ' ' THEN 
             vr_obj_generico := json();
     
             vr_obj_generico.put('logradouro'  , rw_crapcrl.dsendres);
             vr_obj_generico.put('numero'      , rw_crapcrl.nrendres);
             vr_obj_generico.put('complemento' , rw_crapcrl.dscomres);
             vr_obj_generico.put('bairro'      , rw_crapcrl.dsbaires);
             vr_obj_generico.put('cidade'      , rw_crapcrl.dscidres);
             vr_obj_generico.put('uf'          , rw_crapcrl.dsdufres);
             vr_obj_generico.put('cep'         , rw_crapcrl.cdcepres);

             vr_obj_responsav.put('endereco', vr_obj_generico);
           END IF;     
        
           -- Montar informaçoes Adicionais
           vr_obj_generico := json();
           
           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN 
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN 
             vr_obj_generico.put('estadoCivil', rw_crapcrl.cdestciv);
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN 
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN 
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;
     
           -- Enviar informaçoes adicionais ao JSON Responsavel Leval
           vr_obj_responsav.put('informacoesAdicionais' ,vr_obj_generico);     

           -- Adicionar o responsavel montato na lista de responsaveis
           vr_lst_generico.append(vr_obj_responsav.to_json_value());
         END IF;
          
          
        END LOOP; --> crapcrl  
        
        -- Enviar novo objeto de responsaveis para dentro do objeto principal
        -- (Somente se encontramos)
        IF vr_flrespvl THEN 
          vr_obj_analise.put('representantesLegais' ,vr_lst_generico);    
        END IF;
                
      END IF;
    END IF; -- INPESSOA
    
    --> Para pessoa Jurídica buscaremos os sócios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN
    
      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();
    
      --> Efetuar laço para retornar todos os registros disponíveis:
      FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta 
                                  ,pr_nrctrlim => 0
                                  ,pr_tpctrato => 6
                                  ,pr_dsproftl => 'SOCIO') LOOP 
    
        -- Setar flag para indicar que há sócio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapavt.nrdctato
                                          ,pr_nrctremp => 0
                                          ,pr_flprepon => FALSE
                                          ,pr_tpprodut => 1
                                          ,pr_dsjsonan => vr_obj_socio
                                          ,pr_persocio => rw_crapavt.persocio
                                          ,pr_dtadmsoc => rw_crapavt.dtadmsoc
                                          ,pr_dtvigpro => rw_crapavt.dtvalida
                                          ,pr_cdcritic => vr_cdcritic 
                                          ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());
          null;

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de socios
          este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                          ,pr_dsjsonavt  => vr_obj_socio
                                          ,pr_cdcritic   => vr_cdcritic 
                                          ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis er ros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        END IF;
      
      
      END LOOP; --Fim crapavt
      
      -- Enviar novo objeto de socios para dentro do objeto principal (Se houve encontro) 
      IF vr_flsocios = true THEN      
        vr_obj_analise.put('socios' ,vr_lst_generico); 
      END IF;
       
      --> Busca das participaçoes societárias
      
      -- Inicializar lista de Participaçoes Societárias
      vr_lst_generico := json_list();
      
      --> Efetuar laço para retornar todos os registros disponíveis de participaçoes:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que há participaçoes
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrctasoc > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapepa.nrctasoc
                                          ,pr_nrctremp => 0
                                          ,pr_flprepon => FALSE
                                          ,pr_tpprodut => 1
                                          ,pr_persocio => rw_crapepa.persocio
                                          ,pr_dtadmsoc => rw_crapepa.dtadmiss
                                          ,pr_dtvigpro => to_date('31/12/9999','dd/mm/rrrr')
                                          ,pr_dsjsonan => vr_obj_particip
                                          ,pr_cdcritic => vr_cdcritic 
                                          ,pr_dscritic => vr_dscritic); 
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de Participaçoes
          vr_obj_particip.put('documento'      ,este0002.fn_mask_cpf_cnpj(NVL(rw_crapepa.nrdocsoc,0),2));
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);
          
          IF rw_crapepa.dtiniatv IS NOT NULL THEN 
            vr_obj_particip.put('dataFundacao' ,este0002.fn_data_ibra_motor(rw_crapepa.dtiniatv));
          END IF;
          
          -- Montar informaçoes Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));
          
          IF INSTR(rw_crapepa.dsendweb,'@') > 0 THEN
            vr_obj_generico.put('email', rw_crapepa.dsendweb);
          END IF;
          
          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN 
            --> Buscar descriçao
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;
          
          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcionários
          vr_obj_generico.put('quantFuncionarios', rw_crapepa.qtfuncio);
        
          -- Ramo Atividade
          IF rw_crapepa.cdseteco <> 0 AND rw_crapepa.cdrmativ <> 0 THEN 
              
            OPEN cr_gnrativ (pr_cdseteco => rw_crapepa.cdseteco, 
                             pr_cdrmativ => rw_crapepa.cdrmativ );
            FETCH cr_gnrativ INTO rw_gnrativ;
            CLOSE cr_gnrativ;
            
            vr_obj_generico.put('ramoAtividade', rw_crapepa.cdrmativ ||'-'||rw_gnrativ.nmrmativ);
          END IF;
          
          -- Setor Economico
          IF rw_crapepa.cdseteco <> 0 THEN 
          
            -- Buscar descriçao
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'SETORECONO'
                                                     ,pr_tpregist => rw_crapepa.cdseteco);
            -- Se Encontrou
            IF TRIM(vr_dstextab) IS NOT NULL THEN
              vr_nmseteco := vr_dstextab;
            ELSE
              vr_nmseteco := 'Nao Cadastrado';
            END IF;
            vr_obj_generico.put('setorEconomico', rw_crapepa.cdseteco ||'-'|| vr_nmseteco);
          END IF;

          -- Numero Inscriçao Estadual
          IF rw_crapepa.nrinsest <> 0 THEN   
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;
          
          -- Data de Vigencia Procuraçao
          vr_obj_generico.put('dataVigenciaProcuracao' ,este0002.fn_data_ibra_motor(to_date('31/12/9999','dd/mm/rrrr')));
          
          -- Data de Admissao Procuraçao
          IF rw_crapepa.dtadmiss IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissaoProcuracao' ,este0002.fn_data_ibra_motor(rw_crapepa.dtadmiss));
          END IF;  
           
          -- Percentual Procuraçao
          IF rw_crapepa.persocio IS NOT NULL THEN 
            vr_obj_generico.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(rw_crapepa.persocio));
          END IF;
         
          -- Enviar informaçoes adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);    

          -- Adicionar o responsavel montado na lista de participaçoes
          vr_lst_generico.append(vr_obj_particip.to_json_value());          
          
        END IF;  
        
      END LOOP; --> fim crapepa
      
      -- Enviar novo objeto de participaçoes para dentro do objeto principal (Se houve encontro) 
      IF vr_flpartic = true THEN      
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;
      
    END IF; --> INPESSOA 2   
    
    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar laço para retornar todos os registros disponíveis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta 
                                ,pr_nrctrlim => 0
                                ,pr_tpctrato => 6
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que há sócio
      vr_flprocura := true;
      -- Se socio for associado
      IF rw_crapavt.nrdctato > 0 THEN 
        -- Passaremos a conta para montagem dos dados:
        este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapavt.nrdctato
                                        ,pr_nrctremp => 0
                                        ,pr_flprepon => FALSE
                                        ,pr_tpprodut => 1
                                        ,pr_dsjsonan => vr_obj_procurad
                                        ,pr_cdcritic => vr_cdcritic 
                                        ,pr_dscritic => vr_dscritic); 
        -- Testar possíveis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;  

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados básicos encontrados na tabela de procuradores
        este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                        ,pr_dsjsonavt  => vr_obj_procurad
                                        ,pr_cdcritic   => vr_cdcritic 
                                        ,pr_dscritic   => vr_dscritic);
        -- Testar possíveis erros na rotina:
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;        
        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());
      END IF;
    END LOOP;

    -- Enviar novo objeto de procuradores para dentro do objeto principal (Se houve encontro) 
    IF vr_flprocura = true THEN
      vr_obj_analise.put('procuradores' ,vr_lst_generico);    
    END IF;
    
    pr_dsjsonan := vr_obj_analise;
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN 
      IF SQLCODE < 0 THEN
        -- Caso ocorra exception gerar o código do erro com a linha do erro
        vr_dscritic:= vr_dscritic ||
                      dbms_utility.format_error_backtrace;
                       
      END IF;  

      -- Montar a mensagem final do erro 
      vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (2): ' ||
                     vr_dscritic || ' -- SQLERRM: ' || SQLERRM;
                       
      -- Remover as ASPAS que quebram o texto
      vr_dscritic:= replace(vr_dscritic,'"', '');
      vr_dscritic:= replace(vr_dscritic,'''','');
      -- Remover as quebras de linha
      vr_dscritic:= replace(vr_dscritic,chr(10),'');
      vr_dscritic:= replace(vr_dscritic,chr(13),'');
      
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

  END pc_gera_json_analise_lim;

                                
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta_lim(pr_cdcooper in crawepr.cdcooper%type
                                     ,pr_cdagenci in crapage.cdagenci%type
                                     ,pr_cdoperad in crapope.cdoperad%type
                                     ,pr_nrdconta in crawepr.nrdconta%type
                                     ,pr_nrctrlim in crawlim.nrctrlim%type
                                     ,pr_tpctrlim in crawlim.tpctrlim%type
                                     ,pr_nmarquiv in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                     ---- OUT ----
                                     ,pr_proposta out json                   --> Retorno do clob em modelo json da proposta de emprestimo
                                     ,pr_cdcritic out number                 --> Codigo da critica
                                     ,pr_dscritic out varchar2               --> Descricao da critica
                                     ) is

  cursor cr_crapass is
  select ass.nrdconta
        ,ass.nmprimtl
        ,ass.cdagenci
        ,age.nmextage
        ,ass.inpessoa
        ,decode(ass.inpessoa,1,0,2,1) inpessoa_ibra
        ,ass.nrcpfcgc
        ,ass.dtmvtolt
  from   crapass ass
        ,crapage age
  where  ass.cdcooper = age.cdcooper
  and    ass.cdagenci = age.cdagenci
  and    ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;


  -->    Buscar dados da proposta de emprestimo
  cursor cr_crawlim is  
  select lim.nrctrlim
        ,lim.cdagenci
        ,lim.vllimite
        ,1 qtpreemp
        ,lim.dtpropos dtvencto
        ,lim.vllimite vlpreemp
        ,lim.hrinclus
        ,ldc.cddlinha cdlcremp
        ,ldc.dsdlinha dslcremp
        ,decode(ldc.tpctrato, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto (0-Generico/ 1-Aplicacao)
        ,decode(ldc.tpctrato, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato
        ,0 cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
        ,'' dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo Paulo Penteado (GFT)teste pois parece que nao aceita nulo 
        ,lim.cdoperad
        ,ope.nmoperad
        ,0 instatus
        ,lim.dsnivris
        ,lim.insitapr
		,lim.idfluata -- P637
        ,upper(lim.cdopeapr) cdopeapr
        ,'0,0,0,0,0,0,0,0,0,0' dsliquid
        ,case when nvl(lim.nrctrmnt,0) = 0 then 'LM'
              else                              'MJ'
         end tpproduto
  from   crawlim lim
        ,crapldc ldc
        ,crapope ope
  where  ldc.cdcooper = lim.cdcooper
  and    ldc.cddlinha = lim.cddlinha
  and    ldc.tpdescto = lim.tpctrlim
  and    lim.cdcooper = ope.cdcooper
  and    upper(lim.cdoperad) = upper(ope.cdoperad)
  and    lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%rowtype;

  -->    Selecionar os associados da cooperativa por CPF/CGC
  cursor cr_crapass_cpfcgc(pr_nrcpfcgc crapass.nrcpfcgc%type) is
  select cdcooper
        ,nrdconta
        ,flgcrdpa
  from   crapass
  where  cdcooper = pr_cdcooper
  and    nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
  and    dtelimin is null;

  -->    Buscar valor de propostas pendentes
  cursor cr_crawepr_pend(pr_cdcooper crawepr.cdcooper%TYPE
                        ,pr_nrdconta crawepr.nrdconta%TYPE) is
  select nvl(sum(w.vlemprst),0) vlemprst
  from   crawepr w
    join craplcr l on l.cdlcremp = w.cdlcremp and 
                      l.cdcooper = w.cdcooper
  where  w.cdcooper = pr_cdcooper
  and    w.nrdconta = pr_nrdconta
  and    w.insitapr in(1,3)        -- já estao aprovadas
  and    w.insitest NOT IN(4,5,6)    -- 4 - Expiradas -- 5 - Expiradas por decurso de prazo -- PJ438 - Márcio (Mouts) -- 6 -- Anulada -- Paulo Martins (Mouts) PJ438
  --AND w.nrctremp <> pr_nrctremp -- desconsiderar a proposta que esta sendo enviada no momento
  and   not exists( select 1
                    from   crapepr p
                    where  w.cdcooper = p.cdcooper
                    and    w.nrdconta = p.nrdconta
                    and    w.nrctremp = p.nrctremp);
  rw_crawepr_pend cr_crawepr_pend%rowtype;

  -->    Buscar operador
  cursor cr_crapope is
  select ope.nmoperad
        ,ope.cdoperad
  from   crapope ope
  where  ope.cdcooper        = pr_cdcooper
  and    upper(ope.cdoperad) = upper(pr_cdoperad);
  rw_crapope cr_crapope%rowtype;

  -->    Buscar se a conta é de Colaborador Cecred
  cursor cr_tbcolab is
  select substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
  from   tbcadast_colaborador col
  where  col.cdcooper = pr_cdcooper
  and    col.nrcpfcgc = rw_crapass.nrcpfcgc
  and    col.flgativo = 'A';
  
  vr_flgcolab boolean;
  vr_cddcargo tbcadast_colaborador.cdcooper%type;

  -->    Calculo do faturamento PJ
  cursor cr_crapjfn is
  select vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
        +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
  from   crapjfn
  where  cdcooper = pr_cdcooper
  and    nrdconta = pr_nrdconta;
  rw_crapjfn cr_crapjfn%rowtype;

  -----------> VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic number;
  vr_dscritic varchar2(500);
  vr_exc_erro exception;

  --Tipo de registro do tipo data
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Objeto json da proposta
  vr_obj_proposta json := json();
  vr_obj_agencia  json := json();
  vr_obj_imagem   json := json();
  vr_lst_doctos   json_list := json_list();
  vr_json_valor   json_value;

  -- Variaveis auxiliares
  vr_data_aux     date := null;
  vr_dstextab     craptab.dstextab%type;
  vr_inusatab     boolean;
  vr_vlutiliz     number;
  vr_vlprapne     number;
  vr_vllimdis     number;
  vr_vlparcel     number;
  vr_vldispon     number;

  vr_nmarquiv     varchar2(1000);
  vr_dsiduser     varchar2(100);
  vr_dsprotoc  tbgen_webservice_aciona.dsprotocolo%type;
  vr_dsdirarq  varchar2(1000);
  vr_dscomando varchar2(1000);
  vr_vllimati     craplim.vllimite%TYPE;
  vr_cdorigem NUMBER := 0;

  --- variavel cartoes
  vr_vltotccr NUMBER;

  BEGIN

     --    Verificar se a data existe
     open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     if    btch0001.cr_crapdat%notfound then
           vr_cdcritic:= 1;
           close btch0001.cr_crapdat;
           raise vr_exc_erro;
     end   if;
     close btch0001.cr_crapdat;

     -->   Buscar dados do associado
     open  cr_crapass;
     fetch cr_crapass into rw_crapass;
     if    cr_crapass%notfound then
           close cr_crapass;
           vr_cdcritic := 9;
           raise vr_exc_erro;
     end   if;
     close cr_crapass;

     --> Buscar dados da proposta de emprestimo
     open  cr_crawlim;
     fetch cr_crawlim into rw_crawlim;
     if    cr_crawlim%notfound then
           close cr_crawlim;
           vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
           raise vr_exc_erro;
     end   if;
     close cr_crawlim;

     OPEN  cr_craplim(pr_cdcooper
                     ,pr_nrdconta);
     FETCH cr_craplim INTO rw_craplim;
     CLOSE cr_craplim;

     --> Criar objeto json para agencia da proposta
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', pr_cdagenci);
     vr_obj_proposta.put('PA' ,vr_obj_agencia);
     vr_obj_agencia := json();

     --> Criar objeto json para agencia do cooperado
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
     vr_obj_proposta.put('cooperadoContaPA' ,vr_obj_agencia);

     -- Nr. conta sem o digito
     vr_obj_proposta.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
     -- Somente o digito
     vr_obj_proposta.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));

     vr_obj_proposta.put('cooperadoNome'    , rw_crapass.nmprimtl);

     vr_obj_proposta.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);
     if  rw_crapass.inpessoa = 1 then
         vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
     else
         vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
     end if;
    
     vr_obj_proposta.put('numero'             , rw_crawlim.nrctrlim);
     vr_obj_proposta.put('valor'              , rw_crawlim.vllimite);
     vr_obj_proposta.put('parcelaQuantidade'  , rw_crawlim.qtpreemp);
     vr_obj_proposta.put('parcelaPrimeiroVencimento', este0001.fn_data_ibra(rw_crawlim.dtvencto));
     vr_obj_proposta.put('parcelaValor'       , rw_crawlim.vlpreemp);

     vr_vllimati := nvl(rw_craplim.vllimite,0);
     IF  vr_vllimati > 0 THEN
         vr_obj_proposta.put('valorLimiteAtivo', vr_vllimati);
     END IF;
     
     --  valor que está sendo marjorado
     IF  rw_crawlim.tpproduto = 'MJ' THEN
         vr_obj_proposta.put('valorLimiteMaximoPermitido', rw_crawlim.vllimite - vr_vllimati);
     END IF;

     vr_data_aux := to_date(to_char(rw_crapass.dtmvtolt,'DD/MM/RRRR') ||' '||
                            to_char(to_date(rw_crawlim.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');
     vr_obj_proposta.put('dataHora'           , este0001.fn_datatempo_ibra(vr_data_aux));

     vr_obj_proposta.put('produtoCreditoSegmentoCodigo'    , 5); 
     vr_obj_proposta.put('produtoCreditoSegmentoDescricao' , 'Desconto Titulo Limite');   

     vr_obj_proposta.put('linhaCreditoCodigo'    ,rw_crawlim.cdlcremp);
     vr_obj_proposta.put('linhaCreditoDescricao' ,rw_crawlim.dslcremp);
     --vr_obj_proposta.put('finalidadeCodigo'      ,rw_crawlim.cdfinemp);       
     --vr_obj_proposta.put('finalidadeDescricao'   ,rw_crawlim.dsfinemp);      

     vr_obj_proposta.put('tipoProduto'           ,rw_crawlim.tpproduto);
     
     IF  rw_crawlim.tpctrato > 0 THEN
         vr_obj_proposta.put('tipoGarantiaCodigo'   , rw_crawlim.tpctrato );
         vr_obj_proposta.put('tipoGarantiaDescricao', rw_crawlim.dsctrato );
     END IF;

	 -- P637 - fluxo atacado - 08/08/2019
     vr_obj_proposta.put('segueFluxoAtacado'    ,(CASE WHEN rw_crawlim.idfluata=1 THEN TRUE ELSE FALSE END)); 
     
     --    Buscar dados do operador
     open  cr_crapope;
     fetch cr_crapope into rw_crapope;
     if    cr_crapope%notfound then
           close cr_crapope;
           vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
           raise vr_exc_erro;
     end   if;
     close cr_crapope;

     vr_obj_proposta.put('loginOperador'         ,lower(rw_crapope.cdoperad));
     vr_obj_proposta.put('nomeOperador'          ,rw_crapope.nmoperad );

     --  Vazio se for CDC
     --IF  rw_crawepr.inlcrcdc = 0 THEN
     --    /* Se estiver zerado é pq nao houve Parecer de Credito - ou seja - oriundo do Motor de Crédito */
     --    IF  NVL(rw_crawlim.instatus, 0) = 0 THEN
     --        /* Se reprovado no Motor */
     --        IF  rw_crawepr.cdopeapr = 'MOTOR' AND rw_crawepr.insitapr = 2 THEN
     --            /*Fixo 3-Nao Conceder*/
     --            rw_crawepr.instatus := 3;
     --        ELSE
     --            /*Fixo 2-Analise Manual*/
     --            rw_crawepr.instatus := 2;
     --        END IF;
     --    END IF;
     --    /*1-pre-aprovado, 2-analise manual, 3-nao conceder */
     --    vr_obj_proposta.put('parecerPreAnalise', rw_crawepr.instatus);
     --ELSE
     --    /* Zerado para CDC */
         vr_obj_proposta.put('parecerPreAnalise', 0);
     --END IF;


     --if  rw_crawlim.inlcrcdc = 0 then
        -- retorna o limite dos cartoes do cooperado para todas as contas (usando a cada0004.lista_cartoes)
        ccrd0001.pc_retorna_limite_cooperado(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_vllimtot => vr_vltotccr);
     
         -- Verificar se usa tabela juros
         vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'TAXATABELA'
                                                  ,pr_tpregist => 0);
         -- Se a primeira posiçao do campo dstextab for diferente de zero
         vr_inusatab := substr(vr_dstextab,1,1) != '0';

         -- Busca endividamento do cooperado
         rati0001.pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                          ,pr_cdagenci   => pr_cdagenci     --> Código da agencia
                                          ,pr_nrdcaixa   => 0               --> Número do caixa
                                          ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                                          ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                          ,pr_dsliquid   => rw_crawlim.dsliquid --> Lista de contratos a liquidar
                                          ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                          ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                          ,pr_inusatab   => vr_inusatab     --> Indicador de utilizaçao da tabela de juros
                                          ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                          ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                                          ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                          ,pr_dscritic   => vr_dscritic);   --> Saída de erro
         --  Se houve erro
         if  nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
             raise vr_exc_erro;
         end if;

         vr_vllimdis := 0.0;
         vr_vlprapne := 0.0;
         for rw_crapass_cpfcgc in cr_crapass_cpfcgc(pr_nrcpfcgc => rw_crapass.nrcpfcgc) 
         loop
             rw_crawepr_pend := null;
             open  cr_crawepr_pend(pr_cdcooper => rw_crapass_cpfcgc.cdcooper
                                  ,pr_nrdconta => rw_crapass_cpfcgc.nrdconta);
             fetch cr_crawepr_pend into rw_crawepr_pend;
             close cr_crawepr_pend;

             vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne;

             --> Selecionar o saldo disponivel do pre-aprovado da conta em questao  da carga ativa
             if  rw_crapass_cpfcgc.flgcrdpa = 1 then                 -- Calcular o pre-aprovado disponível
                 empr0002.pc_calc_pre_aprovad_sint_cta(pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_vlparcel => vr_vlparcel
                                                      ,pr_vldispon => vr_vldispon
                                                      ,pr_dscritic => vr_dscritic);
                 IF vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_erro;
                 END IF;
                 -- Incrementar o disponível
                 vr_vllimdis := nvl(vr_vldispon, 0) + vr_vllimdis;
             end if;
         end loop;

         vr_obj_proposta.put('endividamentoContaValor'     ,vr_vlutiliz + vr_vltotccr);
         vr_obj_proposta.put('propostasPendentesValor'     ,vr_vlprapne );
         vr_obj_proposta.put('limiteCooperadoValor'        ,nvl(vr_vllimdis,0) );

         -- Busca PDF gerado pela análise automática do Motor
         vr_dsprotoc := este0001.fn_protocolo_analise_auto(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctremp => pr_nrctrlim);

         vr_obj_proposta.put('protocoloPolitica'          ,vr_dsprotoc);

		 -- Tratativa exclusiva para ambiente de homologacao, não deve existir o parametro "URI_WEBSRV_ESTEIRA_HOMOL"
		 -- em ambiente produtivo
		 IF (trim(gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL')) IS NOT NULL) THEN
		   vr_obj_proposta.put('ambienteTemp','true');
		   vr_obj_proposta.put('urlRetornoTemp', gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') );
		 END IF;

         -- Copiar parâmetro
         vr_nmarquiv := pr_nmarquiv;

         --  Caso nao tenhamos recebido o PDF
         if  vr_nmarquiv is null then
             -- Gerar ID aleatório
             vr_dsiduser := dbms_random.string('A', 27);

             dsct0002.pc_gera_impressao_limite(pr_cdcooper => pr_cdcooper
                                              ,pr_cdagecxa => pr_cdagenci
                                              ,pr_nrdcaixa => 0
                                              ,pr_cdopecxa => pr_cdoperad
                                              ,pr_nmdatela => 'ATENDA'
                                              ,pr_idorigem => 1 --Ayllos
                                              ,pr_tpctrlim => pr_tpctrlim
                                              ,pr_nrdconta => rw_crapass.nrdconta
                                              ,pr_idseqttl => 1
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                              ,pr_inproces => rw_crapdat.inproces
                                              ,pr_idimpres => 3 --Gerar impressao da proposta do limite de desconto de titulo
                                              ,pr_nrctrlim => pr_nrctrlim
                                              ,pr_dsiduser => vr_dsiduser
                                              ,pr_flgemail => 0
                                              ,pr_flgerlog => 0
                                              ,pr_nmarqpdf => vr_nmarquiv
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic );

             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '/rl');
             
             --  Se o arquivo nao existir, Remover o conteudo do nome do arquivo para nao enviar
             if  not gene0001.fn_exis_arquivo(vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_nmarquiv := null;
             end if;
         end if;

         if  vr_nmarquiv is not null then
             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;
     
             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' , este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData', '');
             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             --  Caso o PDF tenha sido gerado nesta rotina, Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
             if  vr_nmarquiv <> nvl(pr_nmarquiv,' ') then
                 gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||vr_nmarquiv);
             end if;
         end if;

         --  Se encontrou PDF de análise Motor
         if  vr_dsprotoc is not null then
             -- Diretorio para salvar
             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                                 ,pr_cdcooper => 3
                                                 ,pr_nmsubdir => '/log/webservices');

             -- Utilizar o protocolo para nome do arquivo
             vr_nmarquiv := vr_dsprotoc || '.pdf';

             -- Comando para download
             vr_dscomando := gene0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

             -- Substituir o caminho do arquivo a ser baixado
             vr_dscomando := replace(vr_dscomando, '[local-name]', vr_dsdirarq || '/' || vr_nmarquiv);

             -- Substiruir a URL para Download
             vr_dscomando := replace(vr_dscomando, '[remote-name]', gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')||
                                                                    gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')||
                                                                    '_result/' || vr_dsprotoc || '/pdf');

             -- Executar comando para Download
             gene0001.pc_oscommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_dscomando);


             -- Se NAO encontrou o arquivo
             if  not gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
                 raise vr_exc_erro;
             end if;

             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      ,'RESULTADO_POLITICA');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' ,este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData','');

             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
             gene0001.pc_oscommand_shell(pr_des_comando => 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv);
         end if;

         -- Incluiremos os documentos ao json principal
         vr_obj_proposta.put('documentos',vr_lst_doctos);

     --else -- caso for CDC, enviar vazio
     --    vr_obj_proposta.put('endividamentoContaValor'     ,'');
     --    vr_obj_proposta.put('propostasPendentesValor'     ,'');
     --    vr_obj_proposta.put('endividamentoContaValor'     ,'');
     --end if;

     vr_obj_proposta.put('contratoNumero'     ,rw_crawlim.nrctrlim);

     -- Verificar se a conta é de colaborador do sistema Cecred
     vr_cddcargo := null;
     open  cr_tbcolab;
     fetch cr_tbcolab into vr_cddcargo;
     if    cr_tbcolab%found then
           vr_flgcolab := true;
     else
           vr_flgcolab := false;
     end   if;
     close cr_tbcolab;

     -- Enviar tag indicando se é colaborador
     vr_obj_proposta.put('cooperadoColaborador',vr_flgcolab);

     --  Enviar o cargo somente se colaborador
     if  vr_flgcolab then
         vr_obj_proposta.put('codigoCargo',vr_cddcargo);
     end if;

     -- Enviar nivel de risco no momento da criacao
     vr_obj_proposta.put('classificacaoRisco',rw_crawlim.dsnivris);

     -- Enviar flag se a proposta é de renogociaçao
     vr_obj_proposta.put('renegociacao',(rw_crawlim.dsliquid != '0,0,0,0,0,0,0,0,0,0'));

     --  BUscar faturamento se pessoa Juridica
     if  rw_crapass.inpessoa = 2 then
      -- Buscar faturamento
         open  cr_crapjfn;
         fetch cr_crapjfn into rw_crapjfn;
         close cr_crapjfn;
         vr_obj_proposta.put('faturamentoAnual',rw_crapjfn.vltotfat);
     end if;

     vr_cdorigem := CASE WHEN rw_crawlim.cdoperad = '996' THEN 3 ELSE 5 END;
   
     vr_obj_proposta.put('canalCodigo', vr_cdorigem);
     vr_obj_proposta.put('canalDescricao',gene0001.vr_vet_des_origens(vr_cdorigem));

     -- Devolver o objeto criado
     pr_proposta := vr_obj_proposta;

  EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          end if;

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

     when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Nao foi possivel montar objeto proposta: '||sqlerrm;

END pc_gera_json_proposta_lim;
  
END ESTE0004;
/
