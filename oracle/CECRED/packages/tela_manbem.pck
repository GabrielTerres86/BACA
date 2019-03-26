create or replace package cecred.tela_manbem is
  /*--------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANBEM
      Autor   : Daniel Dallagnese
      Data    : Julho/2017                   Ultima Atualização: 
  
      Dados referentes ao programa:
  
      Objetivo  : Package genérica contendo validações e manipulação de dados de bens.
                  Será utilizada pelas telas de empréstimos e de aditivos.
  
      Alterações: 
      
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Rotina para geração de LOG das alterações de Bens
  procedure pc_gera_log(par_cdcooper in number,
                        par_cdoperad in varchar2,
                        par_nmdatela in varchar2,
                        par_dtmvtolt in date,
                        par_cddopcao in varchar2,
                        par_nrdconta in number,
                        par_nrctremp in number,
                        par_nraditiv in number,
                        par_cdaditiv in number,
                        par_flgpagto in boolean,
                        par_dtdpagto in date,
                        par_nrctagar in number,
                        par_tpaplica in number,
                        par_nraplica in number,
                        par_dsbemfin in varchar2,
                        par_nrrenava in number,
                        par_tpchassi in number,
                        par_dschassi in varchar2,
                        par_nrdplaca in varchar2,
                        par_ufdplaca in varchar2,
                        par_dscorbem in varchar2,
                        par_nranobem in number,
                        par_nrmodbem in number,
                        par_uflicenc in varchar2,
                        par_nmdgaran in varchar2,
                        par_nrcpfgar in number,
                        par_nrdocgar in varchar2,
                        par_nrpromis in varchar2,
                        par_vlpromis in number,
                        par_tpproapl in number,
                        par_tpctrato in number,
                        par_idgaropc in number,
                        par_dsorigem in varchar2,
                        par_dscritic in varchar2,
                        par_dstransa in varchar2);
  
                                    
  --> Buscar bens da Proposta de Empréstimo
  PROCEDURE pc_busca_bens_proposta 
                          (pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                          ,pr_tpctrato   IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                           -------> OUT <--------
                          ,pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2);     --> Erros do processo     
  
  -- Substituição de Bem
  procedure pc_substitui_bem(par_cdcooper in crapbpr.cdcooper%type,
                             par_nrdconta in crapbpr.nrdconta%type,
                             par_nrctremp in crapbpr.nrctrpro%type,
                             par_idseqbem IN OUT crapbpr.idseqbem%type,
                             par_cdoperad in crapbpr.cdoperad%type,
                             par_dscatbem in crapbpr.dscatbem%type,
                             par_dtmvtolt in crapbpr.dtmvtolt%type,
                             par_dsbemfin in crapbpr.dsbemfin%type,
                             par_nmdatela in varchar2,
                             par_cddopcao in varchar2,
                             par_tplcrato IN NUMBER,
                             par_uladitiv in number,
                             par_cdaditiv in number,
                             par_flgpagto in boolean,
                             par_dtdpagto in date,
                             par_tpctrato in number,
                             par_dschassi in crapbpr.dschassi%type,
                             par_nrdplaca in crapbpr.nrdplaca%type,
                             par_dscorbem in crapbpr.dscorbem%type,
                             par_nranobem in crapbpr.nranobem%type,
                             par_nrmodbem in crapbpr.nrmodbem%type,
                             par_nrrenava in crapbpr.nrrenava%type,
                             par_tpchassi in crapbpr.tpchassi%type,
                             par_ufdplaca in crapbpr.ufdplaca%type,
                             par_uflicenc in crapbpr.uflicenc%type,
                             par_nrcpfcgc in crapbpr.nrcpfbem%type,
                             par_vlmerbem in crapbpr.vlmerbem%type,
                             par_dstipbem in crapbpr.dstipbem%type,
                             par_dsmarbem in crapbpr.dsmarbem%type,
                             par_vlfipbem in crapbpr.vlfipbem%type,
                             par_dstpcomb in crapbpr.dstpcomb%type,
                             par_dsorigem in varchar2,
                             par_idseqnov OUT crapbpr.idseqbem%type,
                             par_cdcritic out number,
                             par_dscritic out varchar2);
  
  
  /**************************************************************************
   Validar os bens cadastrado na proposta de emprestimo com linha
   de credito do tipo alienacao.
  **************************************************************************/
  procedure pc_valida_dados_alienacao(par_cdcooper in number,
                                      par_cddopcao in varchar2,
                                      par_nmdatela IN VARCHAR2,
                                      par_cdoperad IN VARCHAR2,
                                      par_nrdconta in number,
                                      par_nrctremp in number,
                                      par_dscorbem in varchar2,
                                      par_nrdplaca in varchar2,
                                      par_idseqbem in number,
                                      par_dscatbem in varchar2,
                                      par_dstipbem in varchar2,
                                      par_dsbemfin in varchar2,
                                      par_vlmerbem in number,
                                      par_tpchassi in number,
                                      par_dschassi in varchar2,
                                      par_ufdplaca in varchar2,
                                      par_uflicenc in varchar2,
                                      par_nrrenava in number,
                                      par_nranobem in number,
                                      par_nrmodbem in number,
                                      par_nrcpfbem in number,
                                      par_vlemprst in number,
                                      par_nmdcampo out varchar2,
                                      par_flgsenha out number,
                                      par_dsmensag out varchar2,
                                      par_cdcritic out number,
                                      par_dscritic out varchar2);
  
  --> Validar dados do bem para Alienação
  PROCEDURE pc_valida_dados_alienacao_web 
                          (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do contrato
                          ,pr_tpctrato IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                          ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                          ,pr_cddopcao IN VARCHAR2              --> Tipo da Ação
                          ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto, Caminhao ou Outros Veiculos)
                          ,pr_dstipbem in varchar2 --> Tipo do Bem (Usado/Zero KM)
                          ,pr_nrmodbem in varchar2 --> Ano Modelo
                          ,pr_nranobem in varchar2 --> Ano Fabricação
                          ,pr_dsbemfin in varchar2 --> Modelo bem financiado
                          ,pr_vlrdobem in varchar2 --> Valor do bem
                          ,pr_tpchassi in varchar2 --> Tipo Chassi
                          ,pr_dschassi in varchar2 --> Chassi
                          ,pr_dscorbem in varchar2 --> Cor
                          ,pr_ufdplaca in varchar2 --> UF Placa
                          ,pr_nrdplaca in varchar2 --> Placa
                          ,pr_nrrenava in varchar2 --> Renavam
                          ,pr_uflicenc in varchar2 --> UF Licenciamento
                          ,pr_nrcpfcgc in varchar2 --> CPF Interveniente
                          ,pr_idseqbem IN VARCHAR2 --> Sequencia do bem em substituição                          
                           -------> OUT <--------
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  /* Gravação dos Bens da Proposta */
  procedure pc_grava_bem_proposta(par_cdcooper in crapbpr.cdcooper%TYPE
                                 ,par_nmdatela IN craptel.nmdatela%TYPE
                                 ,par_cdoperad in crapbpr.cdoperad%TYPE
                                 ,par_nrdconta in crapbpr.nrdconta%TYPE
                                 ,par_flgalien in crapbpr.flgalien%TYPE
                                 ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE
                                 ,par_tpctrato in crapbpr.tpctrpro%TYPE
                                 ,par_nrctrato in crapbpr.nrctrpro%TYPE
                                 ,par_idseqbem in crapbpr.idseqbem%TYPE
                                 ,par_lssemseg in VARCHAR2
                                 ,par_tplcrato in NUMBER
                                 ,par_dscatbem in crapbpr.dscatbem%TYPE
                                 ,par_dsbemfin in crapbpr.dsbemfin%TYPE
                                 ,par_dscorbem in crapbpr.dscorbem%TYPE
                                 ,par_vlmerbem in crapbpr.vlmerbem%TYPE
                                 ,par_dschassi in crapbpr.dschassi%TYPE
                                 ,par_nranobem in crapbpr.nranobem%TYPE
                                 ,par_nrmodbem in crapbpr.nrmodbem%TYPE
                                 ,par_tpchassi in crapbpr.tpchassi%TYPE
                                 ,par_nrcpfbem in crapbpr.nrcpfbem%TYPE
                                 ,par_uflicenc in crapbpr.uflicenc%TYPE
                                 ,par_dstipbem in crapbpr.dstipbem%TYPE
                                 ,par_dsmarbem in crapbpr.dsmarbem%TYPE
                                 ,par_vlfipbem in crapbpr.vlfipbem%TYPE
                                 ,par_dstpcomb in crapbpr.dstpcomb%TYPE
                                 ,par_nrdplaca in crapbpr.nrdplaca%TYPE
                                 ,par_nrrenava in crapbpr.nrrenava%TYPE
                                 ,par_ufdplaca in crapbpr.ufdplaca%TYPE
                                 ,par_flperapr OUT VARCHAR2
                                 ,par_cdcritic out NUMBER
                                 ,par_dscritic out varchar2);
  
  /* Criação do Interveniente Garantidor quando preenchido em tela */
  procedure pc_cria_interveniente(par_cdcooper in crapavt.cdcooper%type,
                                  par_nrdconta in crapavt.nrdconta%type,
                                  par_nrctremp in crapavt.nrctremp%type,
                                  par_nrcpfcgc in crapavt.nrcpfcgc%type,
                                  par_inpessoa IN crapavt.inpessoa%TYPE,
                                  par_nmdavali in crapavt.nmdavali%type,
                                  par_nrcpfcjg in crapavt.nrcpfcjg%type,
                                  par_nmconjug in crapavt.nmconjug%type,
                                  par_tpdoccjg in crapavt.tpdoccjg%type,
                                  par_nrdoccjg in crapavt.nrdoccjg%type,
                                  par_tpdocava in crapavt.tpdocava%type,
                                  par_nrdocava in crapavt.nrdocava%type,
                                  par_dsendres1 in crapavt.dsendres##1%type,
                                  par_dsendres2 in crapavt.dsendres##2%type,
                                  par_nrfonres in crapavt.nrfonres%type,
                                  par_dsdemail in crapavt.dsdemail%type,
                                  par_nmcidade in crapavt.nmcidade%type,
                                  par_cdufresd in crapavt.cdufresd%type,
                                  par_nrcepend in crapavt.nrcepend%type,
                                  par_cdnacion in crapavt.cdnacion%type,
                                  par_nrendere in crapavt.nrendere%type,
                                  par_complend in crapavt.complend%type,
                                  par_nrcxapst in crapavt.nrcxapst%type,
                                        par_cdcritic out number,
                                        par_dscritic out varchar2);

  /* Gravação da Alenação Hipotecaria  */
  procedure pc_grava_alienacao_hipoteca(par_cdcooper IN crapbpr.cdcooper%TYPE
                                       ,par_cdoperad IN crapbpr.cdoperad%TYPE
                                       ,par_nrdconta IN crapbpr.nrdconta%TYPE
                                       ,par_dtmvtolt IN crapbpr.dtmvtolt%TYPE
                                       ,par_tpctrato IN crapbpr.tpctrpro%TYPE
                                       ,par_nrctrato IN crapbpr.nrctrpro%TYPE
                                       ,par_flsohbem IN VARCHAR2
                                       ,par_cddopcao IN VARCHAR2
                                       ,par_xmlalien IN OUT NOCOPY CLOB
                                       ,par_flperapr OUT VARCHAR2
                                       ,par_cdcritic OUT NUMBER
                                       ,par_dscritic OUT varchar2);

  /* Acionamento via tela das informações de Gravação dos Bens */
  procedure pc_grava_alienac_hipotec_web(par_nrdconta in crapbpr.nrdconta%TYPE --> Conta
                                        ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE --> Data
                                        ,par_tpctrato in crapbpr.tpctrpro%TYPE --> Tp Contrato
                                        ,par_nrctrato in crapbpr.nrctrpro%TYPE --> Contrato
                                        ,par_cddopcao IN VARCHAR2         --> Tipo da Ação
                                        ,par_dsdalien IN VARCHAR2         --> Lista de Bens
                                        ,par_dsinterv IN VARCHAR2         --> Lista de Intervenientes
                                        ,pr_xmllog    in VARCHAR2         --> XML com informacoes de LOG
                                        ,pr_cdcritic  out PLS_INTEGER     --> Codigo da critica
                                        ,pr_dscritic  out VARCHAR2        --> Descricao da critica
                                        ,pr_retxml  in out nocopy xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  out VARCHAR2        --> Nome do campo com erro
                                        ,pr_des_erro  out varchar2);      --> Erros do processo
  
  /* Gravação da Alenação Hipotecaria chamando via Progress */
  procedure pc_grava_alienacao_hipot_prog(par_cdcooper in crapbpr.cdcooper%TYPE
                                         ,par_cdoperad in crapbpr.cdoperad%TYPE
                                         ,par_nrdconta in crapbpr.nrdconta%TYPE
                                         ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE
                                         ,par_tpctrato in crapbpr.tpctrpro%TYPE
                                         ,par_nrctrato in crapbpr.nrctrpro%TYPE
                                         ,par_cddopcao IN VARCHAR2                                         
                                         ,par_dsdalien IN VARCHAR2
                                         ,par_dsinterv IN VARCHAR2
                                         ,par_flperapr OUT VARCHAR2
                                         ,par_cdcritic out NUMBER
                                         ,par_dscritic out varchar2);                                  

  /* Acionamento da criação do Interveniente Garantidor a patir de tela */
  procedure pc_cria_interveniente_web(pr_nrdconta  in varchar2,
                                      pr_nrctremp  in varchar2,
                                      pr_tpctrato  in varchar2,
                                      pr_nrcpfcgc  in varchar2,
                                      pr_nmdavali  in varchar2,
                                      pr_nrcpfcjg  in varchar2,
                                      pr_nmconjug  in varchar2,
                                      pr_tpdoccjg  in varchar2,
                                      pr_nrdoccjg  in varchar2,
                                      pr_tpdocava  in varchar2,
                                      pr_nrdocava  in VARCHAR2,
                                      pr_dsendres1 in VARCHAR2,
                                      pr_dsendres2 in varchar2,
                                      pr_nrfonres  in varchar2,
                                      pr_dsdemail  in varchar2,
                                      pr_nmcidade  in varchar2,
                                      pr_cdufresd  in varchar2,
                                      pr_nrcepend  in varchar2,
                                      pr_cdnacion  in varchar2,
                                      pr_nrendere  in varchar2,
                                      pr_complend  in varchar2,
                                      pr_nrcxapst  in varchar2,
                                      pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                      pr_cdcritic out pls_integer, --> Codigo da critica
                                      pr_dscritic out varchar2, --> Descricao da critica
                                      pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                      pr_nmdcampo out varchar2, --> Nome do campo com erro
                                      pr_des_erro out varchar2); --> Erros do processo
  
  /* Validação de Interveniente Garantidor */
  procedure pc_valida_interv(par_nrctaava in number,
                             par_nrcepend in crapdne.nrceplog%type,
                             par_dsendrel in crapdne.nmextlog%type,
                             par_nmdavali in crapavt.nmdavali%type,
                             par_nrcpfcgc in crapavt.nrcpfcgc%type,
                             par_tpdocava in crapavt.tpdocava%type,
                             par_nrdocava in crapavt.nrdocava%type,
                             par_nmconjug in crapavt.nmconjug%type,
                             par_nrcpfcjg in crapavt.nrcpfcjg%type,
                             par_tpdoccjg in crapavt.tpdoccjg%type,
                             par_nrdoccjg in crapavt.nrdoccjg%type,
                             par_cdnacion in crapavt.cdnacion%type,
                             par_nmdcampo out varchar2,
                             par_cdcritic out varchar2,
                             par_dscritic out varchar2);
  
  /* Acionamento da validação de Interveniente Garantidor via tela */
  procedure pc_valida_interv_web(pr_nrctaava in varchar2,
                                 pr_nrcepend in varchar2,
                                 pr_dsendrel in varchar2,
                                 pr_nmdavali in varchar2,
                                 pr_nrcpfcgc in varchar2,
                                 pr_tpdocava in varchar2,
                                 pr_nrdocava in varchar2,
                                 pr_nmconjug in varchar2,
                                 pr_nrcpfcjg in varchar2,
                                 pr_tpdoccjg in varchar2,
                                 pr_nrdoccjg in VARCHAR2,
                                 pr_cdnacion in VARCHAR2,
                                 pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                 pr_cdcritic out pls_integer, --> Codigo da critica
                                 pr_dscritic out varchar2, --> Descricao da critica
                                 pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                 pr_nmdcampo out varchar2, --> Nome do campo com erro
                                 pr_des_erro out varchar2); --> Erros do processo
  
  /* Checar se o CPF está em alguma conta ativa do sistema */
  procedure pc_cpf_cadastrado_web(pr_nrdconta in crapavt.nrdconta%type,
                                  pr_nrctremp in crapavt.nrctremp%type,
                                  pr_tpctrato IN crapavt.tpctrato%TYPE,
                                  pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                                  pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                  pr_cdcritic out pls_integer, --> Codigo da critica
                                  pr_dscritic out varchar2, --> Descricao da critica
                                  pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                  pr_nmdcampo out varchar2, --> Nome do campo com erro
                                  pr_des_erro out varchar2); --> Erros do processo

END tela_manbem;
/
create or replace package body cecred.tela_manbem is

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANBEM
      Autor   : Daniel Dallagnese
      Data    : Julho/2017                   Ultima Atualização: 
  
      Dados referentes ao programa:
  
      Objetivo  : Package genérica contendo validações e manipulação de dados de bens.
                  Será utilizada pelas telas de empréstimos e de aditivos.
  
      Alterações: 
      
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Vetor com os atributos de alienação conforme posição
  TYPE typ_tab_atributos_alienacao IS VARRAY(19) OF VARCHAR2(100);
  vr_vet_atrib_alienac typ_tab_atributos_alienacao 
                       := typ_tab_atributos_alienacao('dscatbem'
                                                     ,'dsbemfin'
                                                     ,'dscorbem'
                                                     ,'vlmerbem'
                                                     ,'dschassi'
                                                     ,'nranobem'
                                                     ,'nrmodbem'
                                                     ,'nrdplaca'
                                                     ,'nrrenava'
                                                     ,'tpchassi'
                                                     ,'ufdplaca'
                                                     ,'nrcpfbem'
                                                     ,'uflicenc'
                                                     ,'dstipbem'
                                                     ,'idseqbem'
                                                     ,'cdcoplib'
                                                     ,'dsmarbem'
                                                     ,'vlfipbem'
                                                     ,'dstpcomb');
  
  -- Vetor com os atributos de interveniente conforme posição
  TYPE typ_tab_atributos_intervenient IS VARRAY(19) OF VARCHAR2(100);
  vr_vet_atrib_interv typ_tab_atributos_intervenient 
                       := typ_tab_atributos_intervenient('nrcpfcgc'
                                                        ,'nmdavali'
                                                        ,'nrcpfcjg'
                                                        ,'nmconjug'
                                                        ,'tpdoccjg'
                                                        ,'nrdoccjg'
                                                        ,'tpdocava'
                                                        ,'nrdocava'
                                                        ,'dsendres1'
                                                        ,'dsendres2'
                                                        ,'nrfonres'
                                                        ,'dsdemail'
                                                        ,'nmcidade'
                                                        ,'cdufresd'
                                                        ,'nrcepend'
                                                        ,'cdnacion'
                                                        ,'nrendere'
                                                        ,'complend'
                                                        ,'nrcxapst');                                                     
  
  -- Rotina para geração de LOG das alterações de Bens
  procedure pc_gera_log(par_cdcooper in number,
                        par_cdoperad in varchar2,
                        par_nmdatela in varchar2,
                        par_dtmvtolt in date,
                        par_cddopcao in varchar2,
                        par_nrdconta in number,
                        par_nrctremp in number,
                        par_nraditiv in number,
                        par_cdaditiv in number,
                        par_flgpagto in boolean,
                        par_dtdpagto in date,
                        par_nrctagar in number,
                        par_tpaplica in number,
                        par_nraplica in number,
                        par_dsbemfin in varchar2,
                        par_nrrenava in number,
                        par_tpchassi in number,
                        par_dschassi in varchar2,
                        par_nrdplaca in varchar2,
                        par_ufdplaca in varchar2,
                        par_dscorbem in varchar2,
                        par_nranobem in number,
                        par_nrmodbem in number,
                        par_uflicenc in varchar2,
                        par_nmdgaran in varchar2,
                        par_nrcpfgar in number,
                        par_nrdocgar in varchar2,
                        par_nrpromis in varchar2,
                        par_vlpromis in number,
                        par_tpproapl in number,
                        par_tpctrato in number,
                        par_idgaropc in number,
                        par_dsorigem in varchar2,
                        par_dscritic in varchar2,
                        par_dstransa in varchar2) is
    v_rowid       ROWID;
    v_nrsequex      number := 0;
    v_nrsequex_aux  varchar2(5);
    v_dsctrato      varchar2(30);
    v_dadant        varchar2(30);
    v_inresaut      number;
    v_permingr      number;
    v_inaplpro      number;
    v_inpoupro      number;
    v_nrctater      number;
    v_inaplter      number;
    v_inpouter      number;
    v_cdcritic      number := 0;
    v_dscritic      varchar2(4000) := null;
  begin
    if v_rowid is null then
      gene0001.pc_gera_log(pr_cdcooper => par_cdcooper,
                           pr_cdoperad => par_cdoperad,
                           pr_dscritic => par_dscritic,
                           pr_dsorigem => par_dsorigem,
                           pr_dstransa => par_dstransa,
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS')),
                           pr_idseqttl => 1,
                           pr_nmdatela => par_nmdatela,
                           pr_nrdconta => par_nrdconta,
                           pr_nrdrowid => v_rowid);
    end if;
    --
    v_nrsequex := v_nrsequex + 1;
    --
    if par_cddopcao <> 'X' then
      v_nrsequex_aux := to_char(v_nrsequex);
    else
      v_nrsequex_aux := null;
    end if;
    --
    if par_cddopcao = 'I' then
        /* Item - dtmvtolt */
        gene0001.pc_gera_log_item(v_rowid,
                                       'dtmvtolt' || to_char(v_nrsequex),
                                       to_char(par_dtmvtolt, 'dd/mm/yyyy'),
                                       null);
    end if;
    /* Item - nrdconta */
    gene0001.pc_gera_log_item(v_rowid,
                                   'nrdconta' || v_nrsequex_aux,
                                   to_char(par_nrdconta),
                                   null);
    /* Item - tpctrato */
    if par_tpctrato = 1 then
      v_dsctrato := 'Lim. Cred';
    elsif par_tpctrato = 2 then
      v_dsctrato := 'Lim. Dsc. Chq.';
    elsif par_tpctrato = 3 then
      v_dsctrato := 'Lim. Dsc. Tit.';
    else
      v_dsctrato := 'Emp.Fin.';
    end if;
    gene0001.pc_gera_log_item(v_rowid,
                                   'tpctrato',
                                   to_char(par_tpctrato) || v_dsctrato,
                                   null);
    /* Item - nrctremp */
    gene0001.pc_gera_log_item(v_rowid,
                                   'nrctremp' || v_nrsequex_aux,
                                   to_char(par_nrctremp),
                                   null);
    /* Opcao X nao tem esses itens */
    if par_cddopcao <> 'X' then
      /* Item - nraditiv */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nraditiv' || v_nrsequex,
                                     to_char(par_nraditiv),
                                     null);
      /* Item - cdaditiv */
      gene0001.pc_gera_log_item(v_rowid,
                                     'cdaditiv' || v_nrsequex,
                                     to_char(par_cdaditiv),
                                     null);
    end if;
    /* Item cdaditiv  1 */
    if par_cdaditiv = 1 THEN
      /* */
      if par_flgpagto then
        v_dadant := 'Folha de Pagto';
      else
        v_dadant := 'Conta Corrente';
      end if;
      /* Item - flgpagto */
      gene0001.pc_gera_log_item(v_rowid,
                                     'flgpagto' || to_char(v_nrsequex),
                                     to_char(v_dadant),
                                     null);
      /* Item - dtdpagto */
      gene0001.pc_gera_log_item(v_rowid,
                                     'dtdpagto' || to_char(v_nrsequex),
                                     to_char(par_dtdpagto),
                                     null);
    end if;
    /* Item cdaditiv  2 e 3 */
    if par_cdaditiv in (2, 3) then
      /* Item cdaditiv  3 */
      if par_cdaditiv = 3 then
        /* Item - nrctagar */
        gene0001.pc_gera_log_item(v_rowid,
                                       'nrctagar' || to_char(v_nrsequex),
                                       to_char(par_nrctagar),
                                       null);
      end if;
      /* Item - tpaplica */
      gene0001.pc_gera_log_item(v_rowid,
                                     'tpaplica' || to_char(v_nrsequex),
                                     to_char(par_tpaplica),
                                     null);
      /* Item - nraplica */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nraplica' || to_char(v_nrsequex),
                                     to_char(par_nraplica),
                                     null);
      /* Item - tpproapl */
      gene0001.pc_gera_log_item(v_rowid,
                                     'tpproapl' || to_char(v_nrsequex),
                                     to_char(par_tpproapl),
                                     null);
    end if;
    /* Item - cdaditiv 5 */
    if par_cdaditiv in (5, 6) then
      /* Item - cdaditiv 6 */
      if par_cdaditiv = 6 then
        /* Item - nmdgaran */
        gene0001.pc_gera_log_item(v_rowid,
                                       'nmdgaran' || to_char(v_nrsequex),
                                       to_char(par_nmdgaran),
                                       null);
        /* Item - nrcpfgar */
        gene0001.pc_gera_log_item(v_rowid,
                                       'nrcpfgar' || to_char(v_nrsequex),
                                       to_char(par_nrcpfgar),
                                       null);
        /* Item - nrdocgar */
        gene0001.pc_gera_log_item(v_rowid,
                                       'nrdocgar' || to_char(v_nrsequex),
                                       to_char(par_nrdocgar),
                                       null);
      end if;
      /* Item - dsbemfin */
      gene0001.pc_gera_log_item(v_rowid,
                                     'dsbemfin' || to_char(v_nrsequex_aux),
                                     to_char(par_dsbemfin),
                                     null);
      /* Item - nrrenava */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrrenava' || to_char(v_nrsequex_aux),
                                     to_char(par_nrrenava),
                                     null);
      /* Item - tpchassi */
      gene0001.pc_gera_log_item(v_rowid,
                                     'tpchassi' || to_char(v_nrsequex_aux),
                                     to_char(par_tpchassi),
                                     null);
      /* Item - dschassi */
      gene0001.pc_gera_log_item(v_rowid,
                                     'dschassi' || to_char(v_nrsequex_aux),
                                     to_char(par_dschassi),
                                     null);
      /* Item - nrdplaca */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrdplaca' || to_char(v_nrsequex_aux),
                                     to_char(par_nrdplaca),
                                     null);
      /* Item - ufdplaca */
      gene0001.pc_gera_log_item(v_rowid,
                                     'ufdplaca' || to_char(v_nrsequex_aux),
                                     to_char(par_ufdplaca),
                                     null);
      /* Item - dscorbem */
      gene0001.pc_gera_log_item(v_rowid,
                                     'dscorbem' || to_char(v_nrsequex_aux),
                                     to_char(par_dscorbem),
                                     null);
      /* Item - nranobem */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nranobem' || to_char(v_nrsequex_aux),
                                     to_char(par_nranobem),
                                     null);
      /* Item - nrmodbem */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrmodbem' || to_char(v_nrsequex_aux),
                                     to_char(par_nrmodbem),
                                     null);
      /* Item - uflicenc */
      gene0001.pc_gera_log_item(v_rowid,
                                     'uflicenc' || to_char(v_nrsequex_aux),
                                     to_char(par_uflicenc),
                                     null);
    end if;
    /* Item - cdaditiv 7 */
    if par_cdaditiv = 7 then
      /* Item - nrcpfcgc */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrcpfcgc' || to_char(v_nrsequex),
                                     to_char(par_nrcpfgar),
                                     null);
      /* Item - nrpromis */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrpromis' || to_char(v_nrsequex),
                                     to_char(par_nrpromis),
                                     null);
      /* Item - vlpromis */
      gene0001.pc_gera_log_item(v_rowid,
                                     'vlpromis' || to_char(v_nrsequex),
                                     to_char(par_vlpromis),
                                     null);
    end if;
    /* Item - cdaditiv 8 */
    if par_cdaditiv = 8 then
      /* Item - nrcpfcgc */
      gene0001.pc_gera_log_item(v_rowid,
                                     'nrcpfcgc' || to_char(v_nrsequex),
                                     to_char(par_nrcpfgar),
                                     null);
      /* Item - vlpromis */
      gene0001.pc_gera_log_item(v_rowid,
                                     'vlpromis' || to_char(v_nrsequex),
                                     to_char(par_vlpromis),
                                     null);
    end if;
    /* Item - cdaditiv 9 */
    if par_cdaditiv = 9 then
      /* Se possui garantia para operacao de credito */
      if par_idgaropc > 0 then
        tela_aditiv.pc_busca_cobert_garopc_prog(par_idgaropc,
                                                v_inresaut,
                                                v_permingr,
                                                v_inaplpro,
                                                v_inpoupro,
                                                v_nrctater,
                                                v_inaplter,
                                                v_inpouter,
                                                v_cdcritic,
                                                v_dscritic);
        if v_dscritic is null and
           v_cdcritic = 0 then
          /* Item – resgate_automatico */
          if v_inresaut = 0 then
            v_dadant := 'Nao';
          else
            v_dadant := 'Sim';
          end if;
          gene0001.pc_gera_log_item(v_rowid,
                                         'ResgateAutomatico',
                                         v_dadant,
                                         null);
          /* Item – perminimo */
          gene0001.pc_gera_log_item(v_rowid,
                                         'Percentual Cobertura Minima',
                                         to_char(v_permingr),
                                         null);
          /* Item – Aplicaçao Propria */
          if v_inaplpro = 0 then
            v_dadant := 'Nao';
          else
            v_dadant := 'Sim';
          end if;
          gene0001.pc_gera_log_item(v_rowid,
                                         'Aplicacao Propria',
                                         v_dadant,
                                         null);
          /* Item – Poupanca Propria */
          if v_inpoupro = 0 then
            v_dadant := 'Nao';
          else
            v_dadant := 'Sim';
          end if;
          gene0001.pc_gera_log_item(v_rowid,
                                         'Poupanca Propria',
                                         v_dadant,
                                         null);
          /* Se possuir conta terceiro */
          if v_nrctater > 0 then
            /* Item – Conta Terceiro */
            gene0001.pc_gera_log_item(v_rowid,
                                           'Conta Terceiro',
                                           to_char(v_nrctater),
                                           null);
            /* Item – Aplicacao Terceiro */
            if v_inaplter = 0 then
              v_dadant := 'Nao';
            else
              v_dadant := 'Sim';
            end if;
            gene0001.pc_gera_log_item(v_rowid,
                                           'Aplicacao Terceiro',
                                           v_dadant,
                                           null);
            /* Item – Poupanca Terceiro */
            if v_inpouter = 0 then
              v_dadant := 'Nao';
            else
              v_dadant := 'Sim';
            end if;
            gene0001.pc_gera_log_item(v_rowid,
                                           'Poupanca Terceiro',
                                           v_dadant,
                                           null);
          end if;
        end if;
      end if;
    end if;
  end;
  
  -- Procedimento para verificar necessidade e alerta na aprovação de aditivos do tipo 5
  PROCEDURE pc_verifica_msg_aprovacao(pr_cdcooper IN crapbpr.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_vlmerbem IN crapbpr.vlmerbem%TYPE --> Valor de mercado do bem
                                     ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                     ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                     ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                     ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    /* .............................................................................
    
       Programa: pc_verifica_msg_aprovacao                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Martini - Envolti
       Data    : Setembro/2018                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar se apresenta mensagem de garantia
    
       Alteracoes:     
    ............................................................................. */
    
    -- Busca dos parâmetros
    vr_solsenha VARCHAR2(1);
    vr_valminim NUMBER;
    -- Busca dos parametros de mensagem da atenda emprestimo
    vr_tipsplit  gene0002.typ_split;
  BEGIN
    -- Default é não pedir senha
    pr_flgsenha := 0;
    
    -- Caso o valor do bem for igual a 0, nao vamos exibir a mensagem
    IF NVL(pr_vlmerbem,0) = 0 THEN
      RETURN;
    END IF;
    
    -- Buscar vetor com proporções de comparação proposta X valor mercado
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => gene0001.fn_param_sistema('CRED',pr_cdcooper,'GESGAR')
                                            ,pr_delimit => ';');
    
    -- Se encontrou informação
    IF vr_tipsplit.count() = 2 THEN
      -- Caso o valor do bem for maior ou igual á 5 vezes, apresenta mensagem em tela
      IF (pr_vlemprst * vr_tipsplit(1)) <= pr_vlmerbem THEN
        pr_dsmensag := 'Atencao! Valor do bem superior ou igual a ' || vr_tipsplit(1) || ' vezes o valor do emprestimo!';
      END IF;
      -- Caso o valor do bem for maior ou igual á 10 vezes, solicita a senha de coordenador
      IF (pr_vlemprst * vr_tipsplit(2)) <= pr_vlmerbem THEN
        pr_dsmensag := 'Atencao! Valor do bem superior ou igual a ' || vr_tipsplit(2) || ' vezes o valor do emprestimo!';
        pr_flgsenha := 1;
      END IF;
    END IF;  
    
    -- Buscar parametros de solicitação de aprovação especificos da ADITIV
    vr_solsenha := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ADITIV_5_APROVA_COORD');
    -- Se pede senha sempre
    IF vr_solsenha = 'S' THEN
      -- Pedir senha e retornar
      pr_flgsenha := 1;
      RETURN;
    -- Se não pede senha nunca  
    ELSIF vr_solsenha = 'N' THEN
      -- Apenas retornar e preserver mensagem e pede senha vistas acima
      RETURN;      
    END IF;
    
    -- Se não existir nenhuma mensagem ainda
    IF pr_dsmensag IS NULL THEN
      -- Pedirá senha apenas quando o valor for abaixo da cobertura minina para, buscar 
      vr_valminim := gene0002.fn_char_para_number(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ADITIV_5_PERC_MIN_COBERT'));
      -- Caso a proporção valor bem / valor saldo devedor for inferior ao parametrizado
      IF vr_valminim > 0 AND (pr_vlmerbem / pr_vlemprst) < (vr_valminim / 100) THEN
        pr_dsmensag := 'Atencao! Valor do bem inferior a ' || to_char(vr_valminim,'fm990d00') || '% do Saldo Devedor!';
        pr_flgsenha := 1;
      END IF;
    END IF;  
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em tela_manbem.pc_verifica_msg_aprovacao: ' || SQLERRM;
  END pc_verifica_msg_aprovacao;
  
  --> Buscar bens da Proposta de Empréstimo
  PROCEDURE pc_busca_bens_proposta 
                          (pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                          ,pr_tpctrato   IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                           -------> OUT <--------
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
                                    
    /* .............................................................................
    
        Programa: pc_busca_bens_proposta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Setembro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em buscar bens da proposta de empréstimo
    
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador do contrato para uso no XML
            
    ---------->> CURSORES <<--------   
    
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = vr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta
        FROM crawepr epr            
       WHERE epr.cdcooper = vr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;      
    
    --> Buscar bens da proposta de emprestimo do cooperado.
    CURSOR cr_crapbpr IS
      SELECT bpr.idseqbem
            ,bpr.dscatbem
            ,bpr.dsmarbem
            ,bpr.dsbemfin
            ,bpr.dschassi
            ,bpr.nrdplaca
            ,bpr.dscorbem
            ,bpr.nranobem
            ,bpr.nrmodbem
            ,bpr.dstpcomb
            ,bpr.vlmerbem
            ,bpr.vlfipbem     
            ,bpr.dstipbem
            ,bpr.nrrenava
            ,bpr.tpchassi
            ,bpr.ufdplaca
            ,bpr.uflicenc
            ,bpr.nrcpfbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = vr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1; --TRUE
    vr_dssitgrv VARCHAR2(50);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Tratar requisição
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                 
  
    -- Validar contrato enviado
    IF pr_tpctrato = 90 THEN
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
      END IF;
      
      --> Validar associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;       
        
      -- Criar cabeçalho do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                              pr_tag_pai  => 'Root',
                              pr_posicao  => 0,
                              pr_tag_nova => 'Bens',
                              pr_tag_cont => NULL,
                              pr_des_erro => vr_dscritic);
        
      --> Buscar bens da proposta de emprestimo do cooperado.
      FOR rw_crapbpr IN cr_crapbpr LOOP
          
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bens',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Bem',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'idseqbem',
                               pr_tag_cont => rw_crapbpr.idseqbem,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dscatbem',
                               pr_tag_cont => rw_crapbpr.dscatbem,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dstipbem',
                               pr_tag_cont => rw_crapbpr.dstipbem,
                               pr_des_erro => pr_dscritic);  

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dsmarbem',
                               pr_tag_cont => rw_crapbpr.dsmarbem,
                               pr_des_erro => pr_dscritic);
                                   
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dsbemfin',
                               pr_tag_cont => rw_crapbpr.dsbemfin,
                               pr_des_erro => pr_dscritic);                       
                                   
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrmodbem',
                               pr_tag_cont => rw_crapbpr.nrmodbem,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dstpcomb',
                               pr_tag_cont => rw_crapbpr.dstpcomb,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nranobem',
                               pr_tag_cont => rw_crapbpr.nranobem,
                               pr_des_erro => pr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'vlfipbem',
                               pr_tag_cont => rw_crapbpr.vlfipbem,
                               pr_des_erro => pr_dscritic);
                                   
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'vlmerbem',
                               pr_tag_cont => rw_crapbpr.vlmerbem,
                               pr_des_erro => pr_dscritic);
        
        -- Buscar situação Gravames
        grvm0001.pc_situac_gravame_bem(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctrpro => pr_nrctremp
                                      ,pr_idseqbem => rw_crapbpr.idseqbem
                                      ,pr_dssituac => vr_dssitgrv
                                      ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dssitgrv',
                               pr_tag_cont => vr_dssitgrv,
                               pr_des_erro => pr_dscritic);                                    

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'tpchassi',
                               pr_tag_cont => rw_crapbpr.tpchassi,
                               pr_des_erro => pr_dscritic);
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dschassi',
                               pr_tag_cont => rw_crapbpr.dschassi,
                               pr_des_erro => pr_dscritic);                               
                                   
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'dscorbem',
                               pr_tag_cont => rw_crapbpr.dscorbem,
                               pr_des_erro => pr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'ufdplaca',
                               pr_tag_cont => rw_crapbpr.ufdplaca,
                               pr_des_erro => pr_dscritic);           

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrdplaca',
                               pr_tag_cont => rw_crapbpr.nrdplaca,
                               pr_des_erro => pr_dscritic);
                                   
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrrenava',
                               pr_tag_cont => rw_crapbpr.nrrenava,
                               pr_des_erro => pr_dscritic);  
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'uflicenc',
                               pr_tag_cont => rw_crapbpr.uflicenc,
                               pr_des_erro => pr_dscritic);    
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Bem',
                               pr_posicao  => vr_contcont,
                               pr_tag_nova => 'nrcpfbem',
                               pr_tag_cont => rw_crapbpr.nrcpfbem,
                               pr_des_erro => pr_dscritic);                                   
                               
        vr_contcont := vr_contcont + 1;          
      END LOOP;
        
    ELSE
      vr_cdcritic := 14; -- 014 - Opcao errada.
      RAISE vr_exc_erro;
    END IF; --> Fim IF pr_cddopcao
    
           
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina de Busca dos Bens da Proposta: ' || SQLERRM;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_busca_bens_proposta;  
  
  -- Substituição de Bem
  procedure pc_substitui_bem(par_cdcooper in crapbpr.cdcooper%type,
                             par_nrdconta in crapbpr.nrdconta%type,
                             par_nrctremp in crapbpr.nrctrpro%type,
                             par_idseqbem IN OUT crapbpr.idseqbem%type,
                             par_cdoperad in crapbpr.cdoperad%type,
                             par_dscatbem in crapbpr.dscatbem%type,
                             par_dtmvtolt in crapbpr.dtmvtolt%type,
                             par_dsbemfin in crapbpr.dsbemfin%type,
                             par_nmdatela in varchar2,
                             par_cddopcao in varchar2,
                             par_tplcrato IN NUMBER,
                             par_uladitiv in number,
                             par_cdaditiv in number,
                             par_flgpagto in boolean,
                             par_dtdpagto in date,
                             par_tpctrato in number,
                             par_dschassi in crapbpr.dschassi%type,
                             par_nrdplaca in crapbpr.nrdplaca%type,
                             par_dscorbem in crapbpr.dscorbem%type,
                             par_nranobem in crapbpr.nranobem%type,
                             par_nrmodbem in crapbpr.nrmodbem%type,
                             par_nrrenava in crapbpr.nrrenava%type,
                             par_tpchassi in crapbpr.tpchassi%type,
                             par_ufdplaca in crapbpr.ufdplaca%type,
                             par_uflicenc in crapbpr.uflicenc%type,
                             par_nrcpfcgc in crapbpr.nrcpfbem%type,
                             par_vlmerbem in crapbpr.vlmerbem%type,
                             par_dstipbem in crapbpr.dstipbem%type,
                             par_dsmarbem in crapbpr.dsmarbem%type,
                             par_vlfipbem in crapbpr.vlfipbem%type,
                             par_dstpcomb in crapbpr.dstpcomb%type,
                             par_dsorigem in varchar2,
                             par_idseqnov OUT crapbpr.idseqbem%type,
                             par_cdcritic OUT number,
                             par_dscritic OUT varchar2) is
    -- Buscar bem a substituir
    cursor cr_crapbpr(pr_tpctrpro crapbpr.tpctrpro%TYPE) is
      select crapbpr.nranobem,
             crapbpr.nrmodbem,
             crapbpr.dscorbem,
             crapbpr.dschassi,
             crapbpr.nrdplaca,
             crapbpr.tpchassi,
             crapbpr.ufdplaca,
             crapbpr.uflicenc,
             crapbpr.nrrenava,
             crapbpr.dsbemfin,
             crapbpr.cdsitgrv,
             crapbpr.rowid
        from crapbpr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and tpctrpro = par_tpctrato
         and nrctrpro = par_nrctremp
         and idseqbem = par_idseqbem;
    v_crapbpr     cr_crapbpr%rowtype;
    v_crapbpr99   cr_crapbpr%rowtype;

    -- Buscar proximo ID Seq Bem para Sustituicao
    cursor cr_crapbpr2 is
      select max(idseqbem)
        from crapbpr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and tpctrpro IN (90,99)
         and nrctrpro = par_nrctremp;

    -- Variaveis genericas
    v_dsrelbem    crapbpr.dsbemfin%type;
    v_flperapr VARCHAR2(1);  
    --
    vr_exc_erro   exception;
  begin
    if par_idseqbem > 0 then
      open cr_crapbpr(par_tpctrato);
        fetch cr_crapbpr into v_crapbpr;
        if cr_crapbpr%notfound then
          par_cdcritic := 55;
          close cr_crapbpr;
          return;
        end if;
      close cr_crapbpr;
      --
      /*** GRAVAMES ***/
      /* Se BEM estiver 'EM PROCESSAMENTO' nao deixa seguir */
      if v_crapbpr.cdsitgrv = 1 then
        par_dscritic := 'Bem em Processamento Gravames! Operacao nao efetuada!';
        return;
      end if;
      /* Log */
      pc_gera_log(par_cdcooper,
                  par_cdoperad,
                  par_nmdatela,
                  par_dtmvtolt,
                  par_cddopcao,
                  par_nrdconta,
                  par_nrctremp,
                  par_uladitiv,
                  par_cdaditiv,
                  par_flgpagto,
                  par_dtdpagto,
                  0, /* nrctagar */
                  0, /* tpaplica */
                  0, /* nraplica */
                  v_crapbpr.dsbemfin,
                  v_crapbpr.nrrenava,
                  v_crapbpr.tpchassi,
                  v_crapbpr.dschassi,
                  v_crapbpr.nrdplaca,
                  v_crapbpr.ufdplaca,
                  v_crapbpr.dscorbem,
                  v_crapbpr.nranobem,
                  v_crapbpr.nrmodbem,
                  v_crapbpr.uflicenc,
                  '', /* nmdgaran */
                  0,  /* nrcpfgar */
                  '', /* nrdocgar */
                  '', /* nrpromis */
                  0,  /* vlpromis */
                  0,
                  par_tpctrato,
                  0,  /* idgaropc */
                  par_dsorigem,
                  par_dscritic,
                  'Substituicao de Bem Alienado em emprestimo.'); /* dstransa */
      
      /** GRAVAMES - Copia BEM para tipo 99 **/
      if (par_cdcooper = 1 and par_dtmvtolt >= to_date('18112014', 'ddmmyyyy')) or
         (par_cdcooper = 4 and par_dtmvtolt >= to_date('23072014', 'ddmmyyyy')) or
         (par_cdcooper = 7 and par_dtmvtolt >= to_date('06102014', 'ddmmyyyy')) or
         (par_cdcooper not in (1, 4, 7) and par_dtmvtolt >= to_date('26022015', 'ddmmyyyy')) then
        -- Checar se já não existe outro bem substituido com o mesmo ID do bem em substituição
        open cr_crapbpr(99);
          fetch cr_crapbpr into v_crapbpr99;
          if cr_crapbpr%found THEN
            -- Vamos gerar novo id para o bem sustituido para evitar duplicação da PK
            open cr_crapbpr2;
            fetch cr_crapbpr2 into par_idseqbem;
            par_idseqbem := nvl(par_idseqbem,0) + 1;
            close cr_crapbpr2;            
          end if;
        close cr_crapbpr;
        -- atualizar o Bem substituido
        BEGIN
          update crapbpr
             set idseqbem = par_idseqbem,
                 tpctrpro = 99,
                 flginclu = 0,
                 flcancel = 0,
                 flgbaixa = 1,
                 dtdbaixa = par_dtmvtolt,
                 tpdbaixa = 'A'
           where rowid = v_crapbpr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            par_dscritic := 'Erro ao atualizar bem sustituido: '||SQLERRM;
            RAISE vr_exc_erro;
        END; 
        /** GRAVAMES - Copia BEM para tipo 99 **/
      end if;
    ELSE
      -- Log apenas de criação
      pc_gera_log(par_cdcooper,
                  par_cdoperad,
                  par_nmdatela,
                  par_dtmvtolt,
                  par_cddopcao,
                  par_nrdconta,
                  par_nrctremp,
                  par_uladitiv,
                  par_cdaditiv,
                  par_flgpagto,
                  par_dtdpagto,
                  0, /* nrctagar */
                  0, /* tpaplica */
                  0, /* nraplica */
                  v_dsrelbem,
                  par_nrrenava,
                  par_tpchassi,
                  par_dschassi,
                  par_nrdplaca,
                  par_ufdplaca,
                  par_dscorbem,
                  par_nranobem,
                  par_nrmodbem,
                  par_uflicenc,
                  '', /* nmdgaran */
                  0,  /* nrcpfgar */
                  '', /* nrdocgar */
                  '', /* nrpromis */
                  0,  /* vlpromis */
                  0,
                  par_tpctrato,
                  0, /* idgaropc */
                  par_dsorigem,
                  par_dscritic,
                  'Incluir aditivo contratual de emprestimo.'); /* dstransa */      
    
    end if; /* IF  par_idseqbem > 0 */
    
    /* Pegar nova sequencia para o bem alienado em Aditivo */
    open cr_crapbpr2;
    fetch cr_crapbpr2 into par_idseqnov;
    par_idseqnov := nvl(par_idseqnov,0) + 1;
    close cr_crapbpr2;
    --
    v_dsrelbem := replace(replace(par_dsbemfin, ';', ','), '|', '-');
    
    -- Inserir o novo Bem
    tela_manbem.pc_grava_bem_proposta(par_cdcooper => par_cdcooper
                                     ,par_nmdatela => 'ADITIV'
                                     ,par_cdoperad => par_cdoperad
                                     ,par_nrdconta => par_nrdconta
                                     ,par_flgalien => 1
                                     ,par_dtmvtolt => par_dtmvtolt
                                     ,par_tpctrato => 90
                                     ,par_nrctrato => par_nrctremp
                                     ,par_idseqbem => par_idseqnov
                                     ,par_lssemseg => tabe0001.fn_busca_dstextab(par_cdcooper,'CRED','USUARI',11,'DISPSEGURO',1)
                                     ,par_tplcrato => par_tplcrato
                                     ,par_dscatbem => par_dscatbem
                                     ,par_dsbemfin => v_dsrelbem
                                     ,par_dscorbem => par_dscorbem
                                     ,par_vlmerbem => par_vlmerbem
                                     ,par_dschassi => par_dschassi
                                     ,par_nranobem => par_nranobem
                                     ,par_nrmodbem => par_nrmodbem
                                     ,par_tpchassi => par_tpchassi
                                     ,par_nrcpfbem => par_nrcpfcgc
                                     ,par_uflicenc => par_uflicenc
                                     ,par_dstipbem => par_dstipbem
                                     ,par_dsmarbem => par_dsmarbem
                                     ,par_vlfipbem => par_vlfipbem
                                     ,par_dstpcomb => par_dstpcomb
                                     ,par_nrdplaca => par_nrdplaca
                                     ,par_nrrenava => par_nrrenava
                                     ,par_ufdplaca => par_ufdplaca
                                     ,par_flperapr => v_flperapr
                                     ,par_cdcritic => par_cdcritic
                                     ,par_dscritic => par_dscritic);
    -- Em caso de erro
    IF par_cdcritic > 0 OR par_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- É necessário atualizar o campo flgokgrv da proposta
    
    

  exception
    when vr_exc_erro then
      if par_cdcritic <> 0 and
         par_dscritic is null then
        par_dscritic := gene0001.fn_busca_critica(pr_cdcritic => par_cdcritic);
      end if;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_MANBEM.PC_SUBSTITUI_BEM: ' || sqlerrm;
  end;
  --
  
  /**************************************************************************
   Validar os bens cadastrado na proposta de emprestimo com linha
   de credito do tipo alienacao.
  **************************************************************************/
  procedure pc_valida_dados_alienacao(par_cdcooper in number,
                                      par_cddopcao in varchar2,
                                      par_nmdatela IN VARCHAR2,
                                      par_cdoperad IN VARCHAR2,
                                      par_nrdconta in number,
                                      par_nrctremp in number,
                                      par_dscorbem in varchar2,
                                      par_nrdplaca in varchar2,
                                      par_idseqbem in number,
                                      par_dscatbem in varchar2,
                                      par_dstipbem in varchar2,
                                      par_dsbemfin in varchar2,
                                      par_vlmerbem in number,
                                      par_tpchassi in number,
                                      par_dschassi in varchar2,
                                      par_ufdplaca in varchar2,
                                      par_uflicenc in varchar2,
                                      par_nrrenava in number,
                                      par_nranobem in number,
                                      par_nrmodbem in number,
                                      par_nrcpfbem in number,
                                      par_vlemprst in number,
                                      par_nmdcampo out varchar2,
                                      par_flgsenha out number,
                                      par_dsmensag out varchar2,
                                      par_cdcritic out number,
                                      par_dscritic out varchar2) is
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.insitapr
        FROM crawepr epr            
       WHERE epr.cdcooper = par_cdcooper
         AND epr.nrdconta = par_nrdconta
         AND epr.nrctremp = par_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Buscar o bem em outro contrato
    cursor cr_crapbpr is
      select crapbpr.nrctrpro
        from crapbpr
       where crapbpr.cdcooper = par_cdcooper
         and crapbpr.nrdconta = par_nrdconta
         and crapbpr.tpctrpro = 90
         and crapbpr.dschassi = par_dschassi
         and crapbpr.cdsitgrv in (0, 1, 3);
    v_crapbpr      cr_crapbpr%rowtype;
    
    -- Buscar os dados do bem a substituir
    cursor cr_crapbpr2 is
      select crapbpr.dscatbem,
             crapbpr.vlmerbem,
             crapbpr.dsbemfin,
             crapbpr.tpchassi,
             crapbpr.dscorbem,
             crapbpr.ufdplaca,
             crapbpr.nrdplaca,
             crapbpr.dschassi,
             crapbpr.nrrenava,
             crapbpr.nranobem,
             crapbpr.nrmodbem,
             crapbpr.nrcpfbem,
             crapbpr.uflicenc,
             crapbpr.dstipbem,
             crapbpr.cdsitgrv
        from crapbpr
       where crapbpr.cdcooper = par_cdcooper
         and crapbpr.nrdconta = par_nrdconta
         and crapbpr.tpctrpro = 90
         and crapbpr.nrctrpro = par_nrctremp
         and crapbpr.idseqbem = par_idseqbem;
    v_crapbpr2     cr_crapbpr2%rowtype;
    
    -- variaveis basicas
    v_flperapr      VARCHAR2(1) := 'N';
    v_ufdplaca      crapbpr.ufdplaca%type := par_ufdplaca;
    v_nrdplaca      crapbpr.nrdplaca%type := par_nrdplaca;
    v_nrrenava      crapbpr.nrrenava%type := par_nrrenava;
    v_uflicenc      crapbpr.uflicenc%type := trim(par_uflicenc);
    v_inpessoa      number;
    v_stsnrcal      boolean;
    v_regtbens      varchar2(32767);
    v_regtbens      varchar2(32767);
    v_cdcritic      number := 0;
    v_dscritic      varchar2(4000) := null;
    vr_exc_erro     exception;
    v_regtBens_atu  varchar2(4000);
    v_regtBens_par  varchar2(4000);
  BEGIN
    -- Validar a proposta quando alteração
    IF par_cddopcao = 'A' THEN
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        v_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
      END IF;

    END IF;
  
    -- 
    if trim(par_dscatbem) is null and
       trim(par_dsbemfin) is not null then
      v_dscritic := 'O campo Categoria e obrigatorio, preencha-o para continuar.';
      par_nmdcampo := 'dscatbem';
      raise vr_exc_erro;
    end if;
    --
    if grvm0001.fn_valida_categoria_alienavel(par_dscatbem) = 'S' then
      if trim(par_dstipbem) is null then
        v_dscritic := 'O campo Tipo Veiculo e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'dstipbem';
        raise vr_exc_erro;
      end if;
    end if;
    --
    if trim(par_dscatbem) is not null and
       trim(par_dsbemfin) is null then
      v_dscritic := 'O campo Modelo e obrigatorio, preencha-o para continuar.';
      par_nmdcampo := 'dsbemfin';
      raise vr_exc_erro;
    end if;
    -- Validar campos para Bens Móveis
    if grvm0001.fn_valida_categoria_alienavel(par_dscatbem) = 'S' then
      if trim(par_dscorbem) is null then
        v_dscritic := 'O campo Cor Classe e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'dscorbem';
        raise vr_exc_erro;
      elsif upper(par_dscorbem) <> par_dscorbem then
        v_dscritic := 'O campo Cor Classe deve ser preenchido com maiusculas, ajuste para continuar.';
        par_nmdcampo := 'dscorbem';
        raise vr_exc_erro;
      elsif par_vlmerbem = 0 then
        v_dscritic := 'O campo Valor de Mercado e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'vlmerbem';
        raise vr_exc_erro;
      elsif trim(par_dschassi) is null then
        v_dscritic := 'O campo Chassi Nr Serie e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      elsif upper(par_dschassi) <> par_dschassi then
        v_dscritic := 'O campo Chassi Nr Serie deve ser preenchido com maiusculas, ajuste para continuar.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      elsif instr(par_dschassi, 'I') > 0 or
            instr(par_dschassi, 'O') > 0 or
            instr(par_dschassi, 'Q') > 0 then
        v_dscritic := 'O campo Chassi Nr Serie não pode conter as letras I, O e Q, ajuste para continuar.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      end if;
      --
      if trim(par_dscatbem) in ('MOTO', 'AUTOMOVEL') and
         length(trim(par_dschassi)) <> 17 then
        v_dscritic := 'Numero do chassi incompleto, verifique.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      end if;
      --
      if trim(par_dscatbem) IN ('CAMINHAO','OUTROS VEICULOS') and
         length(trim(par_dschassi)) > 17 then
        v_dscritic := 'Numero do chassi maior que o tamanho maximo.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      end if;
      --
      if par_tpchassi = 0 then
        v_dscritic := 'O campo Tipo Chassi e obrigatorio, preencha-o para continuar..';
        par_nmdcampo := 'tpchassi';
        raise vr_exc_erro;
      elsif v_uflicenc is null then
        v_uflicenc := 'SC';
        /*
        v_dscritic := 'O campo UF Licenciamento e obrigatorio, preencha-o para continuar..';
        par_nmdcampo := 'uflicenc';
        raise vr_exc_erro;
        */
      end if;
      --
      if par_dstipbem = 'USADO' then
        if trim(par_ufdplaca) is null then
          v_dscritic := 'O campo UF da placa e obrigatorio, preencha-o para continuar.';
          par_nmdcampo := 'ufdplaca';
          raise vr_exc_erro;
        elsif trim(par_nrdplaca) is null then
          v_dscritic := 'O campo Placa e obrigatorio, preencha-o para continuar.';
          par_nmdcampo := 'nrdplaca';
          raise vr_exc_erro;
        elsif par_nrrenava = 0 then
          v_dscritic := 'O campo RENAVAM e obrigatorio, preencha-o para continuar.';
          par_nmdcampo := 'nrrenava';
          raise vr_exc_erro;
        end if;
      else /* quando for carro zero km deixar em branco os campos */
        v_ufdplaca := '';
        v_nrdplaca := '';
        v_nrrenava := 0;
      end if;
      --
      if par_nranobem = 0 then
        v_dscritic := 'O campo Ano Fab. e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'nranobem';
        raise vr_exc_erro;
      elsif par_nrmodbem = 0 then
        v_dscritic := 'O campo Ano Mod. e obrigatorio, preencha-o para continuar.';
        par_nmdcampo := 'nrmodbem';
        raise vr_exc_erro;
      end if;
    end if;
    --
    if trim(par_dscatbem) is not null and
       par_vlmerbem = 0 then
      v_dscritic := 'O campo Valor Mercado e obrigatorio, preencha-o para continuar.';
      par_nmdcampo := 'vlmerbem';
      raise vr_exc_erro;
    end if;
    /*Valida se já existe alguma proposta com o chassi informado pelo coolaborador*/
    if grvm0001.fn_valida_categoria_alienavel(par_dscatbem) = 'S' then
      open cr_crapbpr;
        fetch cr_crapbpr into v_crapbpr;
        if cr_crapbpr%found then
          if v_crapbpr.nrctrpro <> par_nrctremp AND upper(nvl(par_cddopcao,' ')) <> 'A' then
            v_cdcritic := 0;
            v_dscritic := 'Chassi ja existe para outra proposta deste cooperado.';
            par_nmdcampo := 'dschassi';
            close cr_crapbpr;
            raise vr_exc_erro;
          end if;
        end if;
      close cr_crapbpr;
    end if;
    /** GRAVAMES - Nao permitir excluir Bem com sitgrv 1,2 ou 4 **/
    if trim(par_dscatbem) is null AND trim(par_dsbemfin) is null AND par_idseqbem <> 0 then
      open cr_crapbpr2;
        fetch cr_crapbpr2 into v_crapbpr2;
        if cr_crapbpr2%notfound then
          v_cdcritic := 0;
          v_dscritic := 'Bem selecionado para substituicao nao cadastrado!';
          par_nmdcampo := 'dsbemfin';
          close cr_crapbpr2;
          raise vr_exc_erro;
        end if;
      close cr_crapbpr2;
      /** Nao pode alterar nesses Status */
      if v_crapbpr2.cdsitgrv = 1 then
        v_dscritic := ' Bem nao pode ser excluido! [GRAVAMES - Em Processamento]';
        par_nmdcampo := 'dsbemfin';
        raise vr_exc_erro;
      elsif v_crapbpr2.cdsitgrv = 2 then
        v_dscritic := ' Bem nao pode ser excluido! [GRAVAMES - Alienado OK]';
        par_nmdcampo := 'dsbemfin';
        raise vr_exc_erro;
      elsif v_crapbpr2.cdsitgrv = 4 then
        v_dscritic := ' Bem nao pode ser excluido! [GRAVAMES - Quitado]';
        par_nmdcampo := 'dsbemfin';
        raise vr_exc_erro;
      end if;
    end if;
    
    --
    if trim(par_dscatbem) is not null AND trim(par_dscatbem) NOT IN ('MAQUINA DE COSTURA','EQUIPAMENTO') then
      /** GRAVAMES - NAO PERMITIR ALTERAR DETERMINADAS SITUACOES */
      if par_cddopcao = 'A' and
         par_idseqbem <> 0 and
         (grvm0001.fn_valida_categoria_alienavel(par_dscatbem) = 'S') then
        /** Quando 0, significa Bem novo, nao critica */
        open cr_crapbpr2;
          fetch cr_crapbpr2 into v_crapbpr2;
          if cr_crapbpr2%notfound then
            v_cdcritic := 0;
            v_dscritic := 'Bem selecionado para alteracao nao cadastrado!';
            par_nmdcampo := 'dsbemfin';
            close cr_crapbpr2;
            raise vr_exc_erro;
          end if;
        close cr_crapbpr2;
        /** Dados atuais da base */
        v_regtBens_atu := trim(v_crapbpr2.dscatbem)         ||'|'||
                          trim(to_char(v_crapbpr2.vlmerbem)) ||'|'||
                          trim(v_crapbpr2.dsbemfin)         ||'|'||
                          trim(to_char(v_crapbpr2.tpchassi)) ||'|'||
                          trim(v_crapbpr2.dscorbem)         ||'|'||
                          trim(v_crapbpr2.ufdplaca)         ||'|'||
                          trim(v_crapbpr2.nrdplaca)         ||'|'||
                          trim(v_crapbpr2.dschassi)         ||'|'||
                          trim(to_char(v_crapbpr2.nrrenava)) ||'|'||
                          trim(to_char(v_crapbpr2.nranobem)) ||'|'||
                          trim(to_char(v_crapbpr2.nrmodbem)) ||'|'||
                          trim(to_char(v_crapbpr2.nrcpfbem)) ||'|'||
                          trim(v_crapbpr2.uflicenc)         ||'|'||
                          trim(v_crapbpr2.dstipbem);
        /** Dados passados por parametro */
        v_regtBens_par := trim(par_dscatbem)         ||'|'|| 
                          trim(to_char(par_vlmerbem)) ||'|'||
                          trim(par_dsbemfin)         ||'|'||
                          trim(to_char(par_tpchassi)) ||'|'||
                          trim(par_dscorbem)         ||'|'||
                          trim(v_ufdplaca)         ||'|'||
                          trim(replace(v_nrdplaca,'-','')) ||'|'|| 
                          trim(par_dschassi)         ||'|'||
                          trim(to_char(v_nrrenava)) ||'|'||
                          trim(to_char(par_nranobem)) ||'|'||
                          trim(to_char(par_nrmodbem)) ||'|'||
                          trim(to_char(par_nrcpfbem)) ||'|'||
                          trim(v_uflicenc)           ||'|'||
                          trim(par_dstipbem);
        if v_regtbens_par <> v_regtBens_atu then
          /** Nao pode alterar nesses Status */
          if v_crapbpr2.cdsitgrv = 1 then
            v_dscritic := ' GRAVAMES nao pode ser alterado! [Em Processamento]';
            par_nmdcampo := 'dsbemfin';
            raise vr_exc_erro;
          elsif v_crapbpr2.cdsitgrv = 2 then
            v_dscritic := ' GRAVAMES nao pode ser alterado! [Alienado OK]';
            par_nmdcampo := 'dsbemfin';
            raise vr_exc_erro;
          elsif v_crapbpr2.cdsitgrv = 4 then
            v_dscritic := ' GRAVAMES nao pode ser alterado! [Quitado]';
            par_nmdcampo := 'dsbemfin';
            raise vr_exc_erro;
          end if;
        end if;
      end if; /* END - Tratamento GRAVAMES */
      --
      if par_tpchassi not in (1, 2) then
        v_cdcritic := 513;
        par_nmdcampo := 'tpchassi';
        raise vr_exc_erro;
      end if;
      --
      if par_dschassi is null then
        v_dscritic := 'Chassi do bem deve ser informado.';
        par_nmdcampo := 'dschassi';
        raise vr_exc_erro;
      end if;
      --
      if length(to_char(par_nrrenava)) > 11 then
        v_dscritic := 'RENAVAM do veiculo com mais de 11 digitos.';
        par_nmdcampo := 'nrrenava';
        raise vr_exc_erro;
      end if;
      --
      if v_ufdplaca is not null then
        if gene0005.fn_valida_uf(v_ufdplaca) = 0 then
          par_nmdcampo := 'ufdplaca';
          v_cdcritic := 33;
          raise vr_exc_erro;
        end if;
      end if;
      --
      if par_nranobem < 1900 then
        v_cdcritic := 560;
        par_nmdcampo := 'nranobem';
        raise vr_exc_erro;
      end if;
      --
      if par_nrmodbem < 1900 then
        v_cdcritic := 560;
        par_nmdcampo := 'nrmodbem';
        raise vr_exc_erro;
      end if;
      -- Validar CPF do Bem
      if par_nrcpfbem > 0 then
        -- Validação Básica
        gene0005.pc_valida_cpf_cnpj(par_nrcpfbem,
                                    v_stsnrcal,
                                    v_inpessoa);
        if not v_stsnrcal then
          v_cdcritic := 27;
          par_nmdcampo := 'nrcpfbem';
          raise vr_exc_erro;
        end if;
      end if;
    end if; /* END do tratamento de dscatbem */
    --
    if trim(par_dscatbem) is null then
      v_dscritic := 'Deve ser informado pelo menos 1 (um) bem.';
      par_nmdcampo := 'dscatbem';
      raise vr_exc_erro;
    end if;
    -- Validar mensagens de aprovação conforme tela
    IF par_nmdatela IN('ADITIV') THEN
    /* Verifica se apresenta a mensagem de garantia na tela */
      pc_verifica_msg_aprovacao(par_cdcooper
                               ,par_vlmerbem
                               ,par_vlemprst
                               ,par_flgsenha
                               ,par_dsmensag
                               ,v_dscritic);
      if v_dscritic is not null then
        raise vr_exc_erro;
      end if;
    ELSE
      /* Validar da regra da ATENDA */
      empr0001. pc_verifica_msg_garantia(par_cdcooper
                                       ,par_dscatbem
                                       ,par_vlmerbem
                                       ,par_vlemprst
                                       ,par_flgsenha
                                       ,par_dsmensag
                                       ,v_cdcritic
                                       ,v_dscritic);
      if v_cdcritic is not null OR v_dscritic is not null then
      raise vr_exc_erro;
    end if;
      -- Em caso da alteração e proposta já aprovadas
      IF par_cddopcao = 'A' AND rw_crawepr.insitapr = 1 THEN
        -- Checar se o operador tem acesso a permissão especial 
        -- de alterar somente bens sem perca de aprovação
        gene0004.pc_verifica_permissao_operacao(pr_cdcooper => par_cdcooper
                                               ,pr_cdoperad => par_cdoperad
                                               ,pr_idsistem => 1 -- Ayllos
                                               ,pr_nmdatela => 'ATENDA'
                                               ,pr_nmrotina => 'EMPRESTIMOS'
                                               ,pr_cddopcao => 'B'
                                               ,pr_inproces => 1
                                               ,pr_dscritic => v_dscritic
                                               ,pr_cdcritic => v_cdcritic);  
        -- Se retornou critica é pq ele não tem acesso e prosseguiremos com o processo
        -- de checagem de inclusão da mensagem de perca de aprovação
        IF v_dscritic IS NOT NULL OR v_cdcritic <> 0 THEN
          -- Verificar regras de perca de aprovação
          IF par_dstipbem = 'ZERO KM' THEN
            -- Se alterar o chassi a proposta deve perder a aprovação visto que não temos a informação de placa e renavam;
            IF par_dschassi <> v_crapbpr2.dschassi THEN
              v_flperapr := 'S';
    END IF;   
          ELSE -- Veículos usados
            -- Se alterar o chassi a proposta NÃO deve perder aprovação;
            -- Se for alterado a placa, ano modelo ou renavam, a proposta deve perder aprovação
            IF par_ufdplaca <> v_crapbpr2.ufdplaca OR par_nrdplaca <> v_crapbpr2.nrdplaca
            OR par_nrrenava <> v_crapbpr2.nrrenava OR par_nrmodbem <> v_crapbpr2.nranobem THEN
              v_flperapr := 'S';
            END IF;
          END IF;
          -- Se deverá perder a aprovação
          IF v_flperapr = 'S' THEN
            -- Adicionar a mensagem
            par_dsmensag := par_dsmensag ||'<br>'||'A alteração do chassi, placa ou ano  irá retirar a aprovação da proposta.';
          END IF;
        END IF;
      END IF;
    END IF;   
    
  exception
    when vr_exc_erro then
      if v_cdcritic <> 0 and
         v_dscritic is null then
        v_dscritic := gene0001.fn_busca_critica(pr_cdcritic => v_cdcritic);
      end if;
      -- Devolver criticas
      par_cdcritic := v_cdcritic;
      par_dscritic := v_dscritic;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_ADITIV.PC_VALIDA_DADOS_ALIENACAO: ' || SQLERRM; 
  end;

  --> Validar dados do bem para Alienação
  PROCEDURE pc_valida_dados_alienacao_web 
                          (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do contrato
                          ,pr_tpctrato IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                          ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                          ,pr_cddopcao IN VARCHAR2              --> Tipo da Ação
                          ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto, Caminhao ou Outros Veiculos)
                          ,pr_dstipbem in varchar2 --> Tipo do Bem (Usado/Zero KM)
                          ,pr_nrmodbem in varchar2 --> Ano Modelo
                          ,pr_nranobem in varchar2 --> Ano Fabricação
                          ,pr_dsbemfin in varchar2 --> Modelo bem financiado
                          ,pr_vlrdobem in varchar2 --> Valor do bem
                          ,pr_tpchassi in varchar2 --> Tipo Chassi
                          ,pr_dschassi in varchar2 --> Chassi
                          ,pr_dscorbem in varchar2 --> Cor
                          ,pr_ufdplaca in varchar2 --> UF Placa
                          ,pr_nrdplaca in varchar2 --> Placa
                          ,pr_nrrenava in varchar2 --> Renavam
                          ,pr_uflicenc in varchar2 --> UF Licenciamento
                          ,pr_nrcpfcgc in varchar2 --> CPF Interveniente
                          ,pr_idseqbem IN VARCHAR2 --> Sequencia do bem em substituição                          
                           -------> OUT <--------
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
                                    
    /* .............................................................................
    
        Programa: pc_valida_dados_alienacao_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Agosto/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em validar preenchimento dos dados dos Bens em Alienação
    
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
    --> Buscar dados do contrato de emprestimo
    CURSOR cr_crapepr IS
      SELECT epr.vlsdeved
        FROM crapepr epr            
       WHERE epr.cdcooper = vr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    vr_vlsdeved crapepr.vlsdeved%TYPE;    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT wpr.vlemprst
        FROM crawepr wpr            
       WHERE wpr.cdcooper = vr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
         
    --> Buscar dados do contrato de limite
    CURSOR cr_craplim IS
      SELECT lim.vllimite
        FROM craplim lim
       WHERE lim.cdcooper = vr_cdcooper
         AND lim.tpctrlim = pr_tpctrato 
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctremp;
    
    --> SAida da validação
    vr_flgsenha NUMBER;
    vr_dsmensag VARCHAR2(1000);
    vr_numteste NUMBER;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    -- Em caso de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar contrato enviado e retornar valor
    IF pr_nrctremp <> 0 THEN
      IF pr_tpctrato = 90 THEN
        --> Caso chamada oriunda da Aditiv
        IF pr_nmdatela = 'ADITIV' THEN
          --> Validar contrato emprestimo
          OPEN cr_crapepr;
          FETCH cr_crapepr INTO vr_vlsdeved;
          IF cr_crapepr%NOTFOUND THEN
            CLOSE cr_crapepr;
            vr_dscritic := 'Contrato de emprestimo nao encontrado';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_crapepr;
          END IF;
        ELSE
          --> Validar proposta emprestimo
          OPEN cr_crawepr;
          FETCH cr_crawepr INTO vr_vlsdeved;
          IF cr_crawepr%NOTFOUND THEN
            CLOSE cr_crawepr;
            vr_dscritic := 'Proposta de emprestimo nao encontrado';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_crawepr;
          END IF;
        END IF;  
      ELSE
        --> Validar Contrato de Limite
        OPEN cr_craplim;
        FETCH cr_craplim INTO vr_vlsdeved;
        IF cr_craplim%NOTFOUND THEN
          CLOSE cr_craplim;
          vr_dscritic := 'Contrato de Limite nao encontrado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_craplim;
        END IF;
      END IF; 
    ELSE
      vr_dscritic := 'Contrato não enviado!';
      RAISE vr_exc_erro;  
    END IF;  
    
    -- validar ano modelo enviado
    BEGIN
      vr_numteste := to_number(SUBSTR(pr_nrmodbem,1,4));
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Ano Modelo '||SUBSTR(pr_nrmodbem,1,4)||' inválido!';
        pr_nmdcampo := 'nrmodbem';
        RAISE vr_exc_erro; 
    END;
    
    -- validar ano fabricacao enviado
    BEGIN
      vr_numteste := to_number(pr_nranobem);
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Ano Fabricacao '||pr_nranobem||' inválido!';
        pr_nmdcampo := 'nranobem';
        RAISE vr_exc_erro; 
    END;
    
    -- Validar valor enviado
    BEGIN
      vr_numteste := gene0002.fn_char_para_number(pr_vlrdobem);
      IF vr_numteste IS NULL THEN
        vr_dscritic := 'Valor de Mercado '||pr_vlrdobem||' inválido!';
        pr_nmdcampo := 'vlrdobem';
        RAISE vr_exc_erro; 
      END IF;
    END;

    -- Validar tamanho placa enviada
    IF length(pr_ufdplaca) > 2 THEN
      vr_dscritic := 'UF Placa '||pr_ufdplaca||' inválida!';
      pr_nmdcampo := 'ufdplaca';
      RAISE vr_exc_erro; 
    END IF;        
    IF length(pr_nrdplaca) > 8 THEN
      vr_dscritic := 'Placa '||pr_nrdplaca||' inválida!';
      pr_nmdcampo := 'nrdplaca';
      RAISE vr_exc_erro; 
    END IF;            

    -- Validar UF Licenciamento
    IF length(pr_uflicenc) > 2 THEN
      vr_dscritic := 'UF Licenciamento '||pr_uflicenc||' inválido!';
      pr_nmdcampo := 'uflicenc';
      RAISE vr_exc_erro; 
    END IF; 

    -- Validar CPF/CNPJ
    BEGIN
      vr_numteste := to_number(pr_nrcpfcgc);
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'CPF/CNPJ Inverveniente '||pr_nrcpfcgc||' inválido!';
        pr_nmdcampo := 'nrcpfbem';
        RAISE vr_exc_erro; 
    END;    
    
    -- Acionar validação de Bens
    pc_valida_dados_alienacao(par_cdcooper => vr_cdcooper
                             ,par_cddopcao => pr_cddopcao
                             ,par_nmdatela => pr_nmdatela
                             ,par_cdoperad => vr_cdoperad
                             ,par_nrdconta => pr_nrdconta
                             ,par_nrctremp => pr_nrctremp
                             ,par_dscorbem => upper(pr_dscorbem)
                             ,par_nrdplaca => trim(upper(pr_nrdplaca))
                             ,par_idseqbem => pr_idseqbem
                             ,par_dscatbem => upper(pr_dscatbem)
                             ,par_dstipbem => upper(pr_dstipbem)
                             ,par_dsbemfin => upper(pr_dsbemfin)
                             ,par_vlmerbem => gene0002.fn_char_para_number(pr_vlrdobem)
                             ,par_tpchassi => pr_tpchassi
                             ,par_dschassi => upper(pr_dschassi)
                             ,par_ufdplaca => trim(upper(pr_ufdplaca))
                             ,par_uflicenc => upper(pr_uflicenc)
                             ,par_nrrenava => trim(pr_nrrenava)
                             ,par_nranobem => pr_nranobem
                             ,par_nrmodbem => upper(SUBSTR(pr_nrmodbem,1,4)) -- Pode vir o tipo do combustível, portanto removemos caracteres após 4a casa
                             ,par_nrcpfbem => pr_nrcpfcgc
                             ,par_vlemprst => vr_vlsdeved
                             ,par_nmdcampo => pr_nmdcampo
                             ,par_flgsenha => vr_flgsenha
                             ,par_dsmensag => vr_dsmensag
                             ,par_cdcritic => vr_cdcritic
                             ,par_dscritic => vr_dscritic);
    -- Em caso de erro 
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    -- Em caso de retorno da mensagem
    ELSE
      -- Montar a mesma no XML de retorno  
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' 
                                   ||'<Root>'
                                   ||'  <mensagem>' ||vr_dsmensag|| '</mensagem>'
                                   ||'  <aprovaca>' ||vr_flgsenha|| '</aprovaca>'
                                   ||'</Root>');        
    END IF;
           
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_ADITIV.PC_VALIDA_DADOS_ALIENACAO_WEB: ' || sqlerrm;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_valida_dados_alienacao_web;
  
  /* Gravação dos Bens da Proposta */
  procedure pc_grava_bem_proposta(par_cdcooper in crapbpr.cdcooper%TYPE
                                 ,par_nmdatela IN craptel.nmdatela%TYPE
                                 ,par_cdoperad in crapbpr.cdoperad%TYPE
                                 ,par_nrdconta in crapbpr.nrdconta%TYPE
                                 ,par_flgalien in crapbpr.flgalien%TYPE
                                 ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE
                                 ,par_tpctrato in crapbpr.tpctrpro%TYPE
                                 ,par_nrctrato in crapbpr.nrctrpro%TYPE
                                 ,par_idseqbem in crapbpr.idseqbem%TYPE
                                 ,par_lssemseg in VARCHAR2
                                 ,par_tplcrato in NUMBER
                                 ,par_dscatbem in crapbpr.dscatbem%TYPE
                                 ,par_dsbemfin in crapbpr.dsbemfin%TYPE
                                 ,par_dscorbem in crapbpr.dscorbem%TYPE
                                 ,par_vlmerbem in crapbpr.vlmerbem%TYPE
                                 ,par_dschassi in crapbpr.dschassi%TYPE
                                 ,par_nranobem in crapbpr.nranobem%TYPE
                                 ,par_nrmodbem in crapbpr.nrmodbem%TYPE
                                 ,par_tpchassi in crapbpr.tpchassi%TYPE
                                 ,par_nrcpfbem in crapbpr.nrcpfbem%TYPE
                                 ,par_uflicenc in crapbpr.uflicenc%TYPE
                                 ,par_dstipbem in crapbpr.dstipbem%TYPE
                                 ,par_dsmarbem in crapbpr.dsmarbem%TYPE
                                 ,par_vlfipbem in crapbpr.vlfipbem%TYPE
                                 ,par_dstpcomb in crapbpr.dstpcomb%TYPE
                                 ,par_nrdplaca in crapbpr.nrdplaca%TYPE
                                 ,par_nrrenava in crapbpr.nrrenava%TYPE
                                 ,par_ufdplaca in crapbpr.ufdplaca%TYPE
                                 ,par_flperapr OUT VARCHAR2
                                 ,par_cdcritic out NUMBER
                                 ,par_dscritic out varchar2) IS
    /* .............................................................................
    
        Programa: pc_grava_bem_proposta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Setembro/2018.                    Ultima atualizacao: 19/10/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel pro gravar os dados do Bem para Proposta
  
        Observacao: -----
    
        Alteracoes: 19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
  
    ..............................................................................*/                                 
    -- Verificar se o bem jah não existe
    CURSOR cr_crapbpr IS
      select crapbpr.rowid nrrowid
            ,crapbpr.nrdplaca
            ,crapbpr.ufdplaca
            ,crapbpr.nrrenava
            ,crapbpr.nranobem
            ,crapbpr.dschassi
            ,crapbpr.dstipbem
        from crapbpr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and tpctrpro = par_tpctrato
         and nrctrpro = par_nrctrato
         and idseqbem = par_idseqbem;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    -- Variaveis temporárias
    v_flgsegur    crapbpr.flgsegur%type;
    v_nrdplaca    crapbpr.nrdplaca%type;
    v_nrrenava    crapbpr.nrrenava%type;
    v_ufdplaca    crapbpr.ufdplaca%type;
    v_flginclu    crapbpr.flginclu%TYPE := 0;
    v_cdsitgrv    crapbpr.cdsitgrv%TYPE := NULL;
    v_tpinclus    crapbpr.tpinclus%TYPE := ' ';
    --
    vr_exc_erro   exception;
  BEGIN
    
    if gene0002.fn_existe_valor(par_lssemseg, par_dscatbem, ';') = 'S' then
      /* Se a categoria estiver na lista de dispensados do seguro, coloca a
         flag para "Ok" para nao aparecer "Pendente" no relatorio
         28/05/2002 */
      v_flgsegur := 1;
    end if;
    
    -- Bens 0Km não devem possuir placa e renavam
    if par_dstipbem = 'USADO' then
      v_nrdplaca := par_nrdplaca;
      v_nrrenava := par_nrrenava;
      v_ufdplaca := par_ufdplaca;
    else
      v_nrdplaca := ' ';
      v_nrrenava := 0;
      v_ufdplaca := ' ';
    end if;
    
    
    /** GRAVAMES ***/
    if par_tplcrato = 2 AND grvm0001.fn_valida_categoria_alienavel(par_dscatbem) = 'S' THEN
      v_flginclu := 1;
      v_tpinclus := 'A';
      -- Somente mudar situação gravames quando gravação veio da ADITIV
      IF par_nmdatela = 'ADITIV' THEN
      v_cdsitgrv := 0;
      END IF;
    end if;
    
    -- Verificar se o bem jah não existe
    OPEN cr_crapbpr;
    FETCH cr_crapbpr
     INTO rw_crapbpr;
    CLOSE cr_crapbpr;
    
    -- Se bem jah existir
    IF rw_crapbpr.nrrowid IS NOT NULL THEN 
      BEGIN
        update crapbpr
           set flgalien = par_flgalien,
               dtmvtolt = par_dtmvtolt,
               cdoperad = par_cdoperad,
               dscatbem = par_dscatbem,
               nranobem = par_nranobem,
               nrmodbem = par_nrmodbem,
               dscorbem = par_dscorbem,
               dschassi = par_dschassi,
               nrdplaca = v_nrdplaca,
               flgsegur = v_flgsegur,
               tpchassi = par_tpchassi,
               ufdplaca = v_ufdplaca,
               uflicenc = par_uflicenc,
               nrrenava = v_nrrenava,
               nrcpfbem = par_nrcpfbem,
               vlmerbem = par_vlmerbem,
               dsbemfin = par_dsbemfin,
               cdsitgrv = nvl(v_cdsitgrv,cdsitgrv),
               flginclu = v_flginclu,
               tpinclus = v_tpinclus,
               dstipbem = par_dstipbem,
               dsmarbem = par_dsmarbem,
               vlfipbem = par_vlfipbem,
               dstpcomb = par_dstpcomb
         where ROWID = rw_crapbpr.nrrowid;
      EXCEPTION
        WHEN OTHERS THEN
          par_dscritic := 'Erro ao atualizar Bem: '||SQLERRM;
          RAISE vr_exc_erro;
      END;   
      
      -- Veículos zero KM
      IF rw_crapbpr.dstipbem = 'ZERO KM' THEN
        -- Se alterar o chassi a proposta deve perder a aprovação visto que não temos a informação de placa e renavam;
        IF par_dschassi <> rw_crapbpr.dschassi THEN
          par_flperapr := 'S';
        END IF;
      ELSE -- Veículos usados
        -- Se alterar o chassi a proposta NÃO deve perder aprovação;
        -- Se for alterado a placa, ano modelo ou renavam, a proposta deve perder aprovação
        IF v_ufdplaca <> rw_crapbpr.ufdplaca OR v_nrdplaca <> rw_crapbpr.nrdplaca
        OR v_nrrenava <> rw_crapbpr.nrrenava OR par_nrmodbem <> rw_crapbpr.nranobem THEN
          par_flperapr := 'S';
        END IF;
	    END IF;
    ELSE
      BEGIN
        insert into crapbpr(cdcooper,
                            nrdconta,
                            tpctrpro,
                            nrctrpro,
                            flgalien,
                            dtmvtolt,
                            cdoperad,
                            dscatbem,
                            nranobem,
                            nrmodbem,
                            dscorbem,
                            dschassi,
                            nrdplaca,
                            flgsegur,
                            tpchassi,
                            ufdplaca,
                            uflicenc,
                            nrrenava,
                            nrcpfbem,
                            vlmerbem,
                            idseqbem,
                            dsbemfin,
                            cdsitgrv,
                            flginclu,
                            tpinclus,
                            dstipbem,
                            dsmarbem,
                            vlfipbem,
                            dstpcomb)
        values (par_cdcooper,
                par_nrdconta,
                par_tpctrato,
                par_nrctrato,
                par_flgalien,
                par_dtmvtolt,
                par_cdoperad,
                par_dscatbem,
                par_nranobem,
                par_nrmodbem,
                par_dscorbem,
                par_dschassi,
                v_nrdplaca,
                v_flgsegur,
                par_tpchassi,
                v_ufdplaca,
                par_uflicenc,
                v_nrrenava,
                par_nrcpfbem,
                par_vlmerbem,
                par_idseqbem,
                par_dsbemfin,
                nvl(v_cdsitgrv,0),
                v_flginclu,
                v_tpinclus,
                par_dstipbem,
                par_dsmarbem,
                par_vlfipbem,
                par_dstpcomb);
      EXCEPTION
        WHEN OTHERS THEN
          par_dscritic := 'Erro ao inserir Bem: '||SQLERRM;
          RAISE vr_exc_erro;
      END;    
    END IF;
    
  exception
    when vr_exc_erro then
      if par_cdcritic <> 0 and
         par_dscritic is null then
        par_dscritic := gene0001.fn_busca_critica(pr_cdcritic => par_cdcritic);
      end if;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina pc_grava_bem_proposta: ' || sqlerrm;
  END pc_grava_bem_proposta;
  
  /* Gravação da Alenação Hipotecaria  */
  procedure pc_grava_alienacao_hipoteca(par_cdcooper IN crapbpr.cdcooper%TYPE
                                       ,par_cdoperad IN crapbpr.cdoperad%TYPE
                                       ,par_nrdconta IN crapbpr.nrdconta%TYPE
                                       ,par_dtmvtolt IN crapbpr.dtmvtolt%TYPE
                                       ,par_tpctrato IN crapbpr.tpctrpro%TYPE
                                       ,par_nrctrato IN crapbpr.nrctrpro%TYPE
                                       ,par_flsohbem IN VARCHAR2
                                       ,par_cddopcao IN VARCHAR2
                                       ,par_xmlalien IN OUT NOCOPY CLOB
                                       ,par_flperapr OUT VARCHAR2
                                       ,par_cdcritic OUT NUMBER
                                       ,par_dscritic OUT varchar2) is

    /* .............................................................................
    
        Programa: pc_grava_alienacao_hipoteca
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Setembro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel por varrer os dados de alienação e
                    efetuar a gravaçao nas tabelas de Bens e Intervenientes
    
        Observacao: -----
    
        Alteracoes: 
        26/03/2019 - Tratamento do erro oracle (ORA06502), PRB0040687 - ERRO CHASSI E PROPOSTA (Bruno C, Mout'S)

    ..............................................................................*/            
  
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.rowid nrrowid 
            ,lcr.tpctrato
        FROM crawepr epr  
            ,craplcr lcr          
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = par_cdcooper
         AND epr.nrdconta = par_nrdconta
         AND epr.nrctremp = par_nrctrato;
    rw_crawepr cr_crawepr%ROWTYPE;    
    
    -- Buscar proximo ID Seq Bem para Sustituicao
    cursor cr_crapbpr2 is
      select max(idseqbem)
        from crapbpr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and tpctrpro IN (90,99)
         and nrctrpro = par_nrctrato;
    
    -- Buscar os CPFs de Bens que não estão na lista de Intervenientes
    CURSOR cr_cpfbens IS
      SELECT bpr.nrcpfbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = par_cdcooper
         and bpr.nrdconta = par_nrdconta
         and bpr.tpctrpro = 90
         and bpr.nrctrpro = par_nrctrato
         AND nvl(bpr.nrcpfbem,0) <> 0
         AND bpr.flgalien = 1
         aND NOT EXISTS(SELECT 1
                          FROM crapavt avt
                        WHERE avt.cdcooper = bpr.cdcooper
                          AND avt.tpctrato = 9
                          AND avt.nrdconta = bpr.nrdconta
                          AND avt.nrctremp = bpr.nrctrpro
                          AND avt.nrcpfcgc = bpr.nrcpfbem);
    
    -- Buscar os CPFs de Intervenientes que não estão na lista de bens
    CURSOR cr_cpfinterv IS
      SELECT avt.nrcpfcgc
        FROM crapavt avt
       WHERE avt.cdcooper = par_cdcooper
         and avt.nrdconta = par_nrdconta
         and avt.tpctrato = 9
         and avt.nrctremp = par_nrctrato
         AND NOT EXISTS(SELECT 1
                          FROM crapbpr bpr
                         WHERE bpr.cdcooper = avt.cdcooper
                           AND bpr.tpctrpro = 90
                           AND bpr.nrdconta = avt.nrdconta
                           AND bpr.nrctrpro = avt.nrctremp
                           AND bpr.nrcpfbem = avt.nrcpfcgc
                           AND bpr.flgalien = 1);    
    
    -- Lista de Bens e CPFs processados
    vr_aux_listabem VARCHAR2(32767);
    vr_aux_listacpf VARCHAR2(32767);
    -- Auxiliares
    vr_aux_flperapr VARCHAR2(1);
    -- Buscar tipo de pessoa
    vr_stsnrcal   boolean;
    vr_inpessoa   crapass.inpessoa%type;
    
    -- Rowtypes de Bens e Intervenientes
    rw_crapbpr crapbpr%ROWTYPE;
    rw_crapavt crapavt%ROWTYPE;
    
    -- Variáveis para tratamento do XML
    vr_qtddados    NUMBER;
    vr_node_list   XMLDOM.DOMNodeList;
    vr_childlist   XMLDOM.DOMNodeList;
    vr_parser      XMLPARSER.Parser;
    vr_doc         XMLDOM.DOMDocument;
    vr_lenght      NUMBER;
    vr_qtfilhos    NUMBER;
    vr_node_name   VARCHAR2(100);
    vr_item_node   XMLDOM.DOMNode;
    vr_element     XMLDOM.DOMElement;
    
    -- Exceção
    vr_exc_erro   exception;
  BEGIN
    --> Validar emprestimo
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      par_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawepr;
    END IF;
    
    -- Ler o arquivo e gravar o mesmo no CLOB
    vr_qtddados := LENGTH(par_xmlalien);
    
    -- Somente se há informações
    IF vr_qtddados > 0 THEN
      
      -- Varrer o XML de Bens e Intervenientes enviado
      -- Faz o parse do XMLTYPE para o XMLDOM
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,par_xmlalien);

      -- Documento gerado pelo parser
      vr_doc    := xmlparser.getDocument(vr_parser);

      -- libera o parser
      xmlparser.freeParser(vr_parser);

      -- Faz o get de toda a lista de elementos
      vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
      vr_lenght := xmldom.getLength(vr_node_list);

      BEGIN

        -- Percorrer os elementos
        FOR i IN 0..vr_lenght-1 LOOP
          -- Pega o item
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Verifica qual nodo esta sendo lido
          IF LOWER(vr_node_name) = 'root' THEN
            CONTINUE; -- Descer para o próximo filho
          ELSIF vr_node_name IN ('bemalien') THEN
            -- Captura o elemento do nodo
            vr_element := xmldom.makeElement(vr_item_node);
            -- Todos os atributos do nodo
            vr_childlist := xmldom.getChildNodes(vr_item_node);
            vr_qtfilhos := xmldom.getLength(vr_childlist);
            -- Percorrer os elementos
            FOR i IN 0..vr_qtfilhos-1 LOOP
              -- Pega o item
              vr_item_node := xmldom.item(vr_childlist, i);
              -- Captura o elemento do nodo
              vr_element := xmldom.makeElement(vr_item_node);
              -- Captura o nome do nodo
              vr_node_name := LOWER(xmldom.getNodeName(vr_item_node));
              -- Gravar campos comuns
              rw_crapbpr.cdcooper := par_cdcooper;
              rw_crapbpr.nrdconta := par_nrdconta;
              rw_crapbpr.tpctrpro := par_tpctrato;
              rw_crapbpr.nrctrpro := par_nrctrato;
              rw_crapbpr.flgalien := 1;
              rw_crapbpr.dtmvtolt := par_dtmvtolt;              
              -- Verifica o atributo conforme o nome
              IF vr_node_name = 'dscatbem' THEN
                rw_crapbpr.dscatbem := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dsbemfin' THEN
                rw_crapbpr.dsbemfin := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dscorbem' THEN
                rw_crapbpr.dscorbem := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'vlmerbem' THEN
                rw_crapbpr.vlmerbem := gene0002.fn_char_para_number(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'dschassi' THEN
                rw_crapbpr.dschassi := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nranobem' THEN
                rw_crapbpr.nranobem := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'nrmodbem' THEN
                rw_crapbpr.nrmodbem := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'nrdplaca' THEN
                rw_crapbpr.nrdplaca := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrrenava' THEN
                rw_crapbpr.nrrenava := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'tpchassi' THEN
                rw_crapbpr.tpchassi := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'ufdplaca' THEN
                rw_crapbpr.ufdplaca := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrcpfbem' THEN
                rw_crapbpr.nrcpfbem := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'uflicenc' THEN
                rw_crapbpr.uflicenc := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dstipbem' THEN
                rw_crapbpr.dstipbem := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'idseqbem' THEN
                rw_crapbpr.idseqbem := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'dsmarbem' THEN
                rw_crapbpr.dsmarbem := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'vlfipbem' THEN
                rw_crapbpr.vlfipbem := gene0002.fn_char_para_number(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'dstpcomb' THEN
                rw_crapbpr.dstpcomb := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              END IF;
            END LOOP;
            -- Se vazio, utilizaremos o proximo id livre 
            if nvl(rw_crapbpr.idseqbem,0) = 0 then
              -- Se recebemos o próximo livre da lista de 
              open cr_crapbpr2;
              fetch cr_crapbpr2 into rw_crapbpr.idseqbem;
              rw_crapbpr.idseqbem := nvl(rw_crapbpr.idseqbem,0) + 1;
              close cr_crapbpr2;            
            END IF; 
            -- Criar o Bem
            tela_manbem.pc_grava_bem_proposta(par_cdcooper => rw_crapbpr.cdcooper
                                             ,par_nmdatela => 'ATENDA'
                                             ,par_cdoperad => par_cdoperad
                                             ,par_nrdconta => rw_crapbpr.nrdconta
                                             ,par_flgalien => rw_crapbpr.flgalien
                                             ,par_dtmvtolt => rw_crapbpr.dtmvtolt
                                             ,par_tpctrato => rw_crapbpr.tpctrpro
                                             ,par_nrctrato => rw_crapbpr.nrctrpro
                                             ,par_idseqbem => rw_crapbpr.idseqbem
                                             ,par_lssemseg => tabe0001.fn_busca_dstextab(par_cdcooper,'CRED','USUARI',11,'DISPSEGURO',1)
                                             ,par_tplcrato => rw_crawepr.tpctrato
                                             ,par_dscatbem => rw_crapbpr.dscatbem
                                             ,par_dsbemfin => rw_crapbpr.dsbemfin
                                             ,par_dscorbem => rw_crapbpr.dscorbem
                                             ,par_vlmerbem => rw_crapbpr.vlmerbem
                                             ,par_dschassi => rw_crapbpr.dschassi
                                             ,par_nranobem => rw_crapbpr.nranobem
                                             ,par_nrmodbem => rw_crapbpr.nrmodbem
                                             ,par_tpchassi => rw_crapbpr.tpchassi
                                             ,par_nrcpfbem => rw_crapbpr.nrcpfbem
                                             ,par_uflicenc => rw_crapbpr.uflicenc
                                             ,par_dstipbem => rw_crapbpr.dstipbem
                                             ,par_dsmarbem => rw_crapbpr.dsmarbem
                                             ,par_vlfipbem => rw_crapbpr.vlfipbem
                                             ,par_dstpcomb => rw_crapbpr.dstpcomb
                                             ,par_nrdplaca => rw_crapbpr.nrdplaca
                                             ,par_nrrenava => rw_crapbpr.nrrenava
                                             ,par_ufdplaca => rw_crapbpr.ufdplaca
                                             ,par_flperapr => vr_aux_flperapr
                                             ,par_cdcritic => par_cdcritic
                                             ,par_dscritic => par_dscritic);
            -- Se houve erro
            IF par_cdcritic > 0 OR par_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;            
            -- Se este bem perde a aprovação
            IF vr_aux_flperapr = 'S' THEN
              /* Deve perder aprovacao */
              par_flperapr := vr_aux_flperapr;
            END IF;            
            -- Adicionar o Bem na lista de Bens para não excluir
            vr_aux_listabem := vr_aux_listabem || ',' || rw_crapbpr.idseqbem;
          ELSIF par_flsohbem = 'N' AND vr_node_name IN ('interven') THEN
            -- Captura o elemento do nodo
            vr_element := xmldom.makeElement(vr_item_node);
            -- Todos os atributos do nodo
            vr_childlist := xmldom.getChildNodes(vr_item_node);
            vr_qtfilhos := xmldom.getLength(vr_childlist);
            -- Percorrer os elementos
            FOR i IN 0..vr_qtfilhos-1 LOOP
              -- Pega o item
              vr_item_node := xmldom.item(vr_childlist, i);
              -- Captura o elemento do nodo
              vr_element := xmldom.makeElement(vr_item_node);
              -- Captura o nome do nodo
              vr_node_name := LOWER(xmldom.getNodeName(vr_item_node));
              -- Gravar campos comuns
              rw_crapavt.cdcooper := par_cdcooper;
              rw_crapavt.nrdconta := par_nrdconta;
              rw_crapavt.nrctremp := par_nrctrato;
              -- Verifica o atributo conforme o nome
              IF vr_node_name = 'nrcpfcgc' THEN
                rw_crapavt.nrcpfcgc := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'nmdavali' THEN
                rw_crapavt.nmdavali := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrcpfcjg' THEN
                rw_crapavt.nrcpfcjg := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'nmconjug' THEN
                rw_crapavt.nmconjug := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'tpdoccjg' THEN
                rw_crapavt.tpdoccjg := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrdoccjg' THEN
                rw_crapavt.nrdoccjg := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'tpdocava' THEN
                rw_crapavt.tpdocava := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrdocava' THEN
                rw_crapavt.nrdocava := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dsendres1' THEN
                rw_crapavt.dsendres##1 := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dsendres2' THEN
                rw_crapavt.dsendres##2 := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrfonres' THEN
                rw_crapavt.nrfonres := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dsdemail' THEN
                rw_crapavt.dsdemail := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nmcidade' THEN
                rw_crapavt.nmcidade := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'cdufresd' THEN
                rw_crapavt.cdufresd := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'dsdemail' THEN
                rw_crapavt.dsdemail := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
              ELSIF vr_node_name = 'nrcepend' THEN
                rw_crapavt.nrcepend := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'cdnacion' THEN
                rw_crapavt.cdnacion := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'nrendere' THEN
                rw_crapavt.nrendere := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              ELSIF vr_node_name = 'complend' THEN
                rw_crapavt.complend := substr(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)),
                                              1,
                                              47);
              ELSIF vr_node_name = 'nrcxapst' THEN
                rw_crapavt.nrcxapst := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              END IF;
            END LOOP;          
            -- Validar e buscar o tipo de pessoa
            gene0005.pc_valida_cpf_cnpj(rw_crapavt.nrcpfcgc
                                       ,vr_stsnrcal
                                       ,vr_inpessoa);
            if not vr_stsnrcal then
              par_cdcritic := 27;
              raise vr_exc_erro; 
            end if;          
            -- Criar o Interveniente montado com base nos dados do XML
            tela_manbem.pc_cria_interveniente(par_cdcooper  => rw_crapavt.cdcooper
                                             ,par_nrdconta  => rw_crapavt.nrdconta
                                             ,par_nrctremp  => rw_crapavt.nrctremp
                                             ,par_nrcpfcgc  => rw_crapavt.nrcpfcgc
                                             ,par_inpessoa  => vr_inpessoa
                                             ,par_nmdavali  => rw_crapavt.nmdavali
                                             ,par_nrcpfcjg  => rw_crapavt.nrcpfcjg
                                             ,par_nmconjug  => rw_crapavt.nmconjug
                                             ,par_tpdoccjg  => rw_crapavt.tpdoccjg
                                             ,par_nrdoccjg  => rw_crapavt.nrdoccjg
                                             ,par_tpdocava  => rw_crapavt.tpdocava
                                             ,par_nrdocava  => rw_crapavt.nrdocava
                                             ,par_dsendres1 => rw_crapavt.dsendres##1
                                             ,par_dsendres2 => rw_crapavt.dsendres##2
                                             ,par_nrfonres  => rw_crapavt.nrfonres
                                             ,par_dsdemail  => rw_crapavt.dsdemail
                                             ,par_nmcidade  => rw_crapavt.nmcidade
                                             ,par_cdufresd  => rw_crapavt.cdufresd
                                             ,par_nrcepend  => rw_crapavt.nrcepend
                                             ,par_cdnacion  => rw_crapavt.cdnacion
                                             ,par_nrendere  => rw_crapavt.nrendere
                                             ,par_complend  => rw_crapavt.complend
                                             ,par_nrcxapst  => rw_crapavt.nrcxapst
                                             ,par_cdcritic  => par_cdcritic
                                             ,par_dscritic  => par_dscritic);
            -- Se houve erro
            IF par_cdcritic > 0 OR par_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o CPF na lista de CPFs para não excluir
            vr_aux_listacpf := vr_aux_listacpf || ',' || rw_crapavt.nrcpfcgc;

          END IF; -- vr_node_name
        END LOOP;
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => par_cdcooper);
          
          par_dscritic := 'Erro na leitura do XML. Rotina PC_GRAVA_ALIENACAO_HIPOTECA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
    -- Somente na alteração
    IF par_cddopcao = 'A' THEN
      
      -- Limpar os Bens que não foram processados
      BEGIN
        DELETE 
          FROM crapbpr
         WHERE cdcooper = par_cdcooper
           AND nrdconta = par_nrdconta
           AND tpctrpro = par_tpctrato
           AND nrctrpro = par_nrctrato
           AND flgalien = 1
           AND vr_aux_listabem||',' NOT LIKE ('%,'||idseqbem||',%');  -- Somente os que não estão na lista   
      EXCEPTION
        WHEN OTHERS THEN
          par_dscritic := 'Erro ao limpar Bens Alienados: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Limpar os Intervenientes que não foram processados, desde que não seja uma 
      -- requisição de Somente Bens
      IF par_flsohbem = 'N' THEN
        BEGIN
          DELETE 
            FROM crapavt
           WHERE cdcooper = par_cdcooper   
             AND nrdconta = par_nrdconta   
             AND tpctrato = 9              
             AND nrctremp = par_nrctrato
             AND vr_aux_listacpf||',' NOT LIKE ('%,'||nrcpfcgc||',%');  -- Somente os que não estão na lista   
        EXCEPTION
          WHEN OTHERS THEN
            par_dscritic := 'Erro ao limpar intervenientes: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;  
    END IF;
    
    /*
	-- Temos de garantir que os CPFs informados na lista de bens estejam na lista
    -- de CPFs informados na lista de Intervenientes, qualquer diferença irá gerar
    -- erro nas CCBs e no GRAVAME
    FOR rw_cpf IN cr_cpfbens LOOP
      -- Lista de CPFs com erros
      gene0005.pc_valida_cpf_cnpj(rw_cpf.nrcpfbem
                                 ,vr_stsnrcal
                                 ,vr_inpessoa);
      -- Adicionar a lista
      par_dscritic := par_dscritic || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_cpf.nrcpfbem, pr_inpessoa => vr_inpessoa) || ',';
    END LOOP;
    
    -- Se encontrou critica acima:
    IF par_dscritic IS NOT NULL THEN
      par_dscritic := 'O(s) documento(s) '||rtrim(par_dscritic,',')||' foi(ram) relacionados como Interveniene(s) porem nao foi(ram) cadastrado(s)';
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Temos de garantir que os CPFs informados na lista de Intervenientes estejam na lista
    -- de CPFs informados na lista de Bens, qualquer diferença irá gerar
    -- erro nas CCBs e no GRAVAME
    FOR rw_cpf IN cr_cpfinterv LOOP
      -- Lista de CPFs com erros
      gene0005.pc_valida_cpf_cnpj(rw_cpf.nrcpfcgc
                                 ,vr_stsnrcal
                                 ,vr_inpessoa);
      -- Adicionar a lista
      par_dscritic := par_dscritic || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_cpf.nrcpfcgc, pr_inpessoa => vr_inpessoa) || ',';
    END LOOP;
    
    -- Se encontrou critica acima:
    IF par_dscritic IS NOT NULL THEN
      par_dscritic := 'O(s) documento(s) '||rtrim(par_dscritic,',')||' foi(ram) cadastrado(s) como Interveniente(s) porem nao foram relacionados a nenhum Bem';
      RAISE vr_exc_erro;
    END IF;
	*/

    -- Novamente somente na alteração
    IF par_cddopcao = 'A' THEN
      
      -- Para uma requisição de alteração somente de Bens com Perca de Aprovação
      IF par_flperapr = 'S' THEN
        -- Checar se o operador tem acesso a permissão especial 
        -- de alterar somente bens sem perca de aprovação
        gene0004.pc_verifica_permissao_operacao(pr_cdcooper => par_cdcooper
                                               ,pr_cdoperad => par_cdoperad
                                               ,pr_idsistem => 1 -- Ayllos
                                               ,pr_nmdatela => 'ATENDA'
                                               ,pr_nmrotina => 'EMPRESTIMOS'
                                               ,pr_cddopcao => 'B'
                                               ,pr_inproces => 1
                                               ,pr_dscritic => par_dscritic
                                               ,pr_cdcritic => par_cdcritic);  
        -- Se retornou critica, então o operador não tem a permissão especial
        IF par_cdcritic <> 0 THEN
          -- programar aqui a perca de aprovação retornando o texto de que será necessário fazer nova análise de crédito
          BEGIN
            -- Perder a aprovação
            UPDATE crawepr
               SET insitapr = 0
                  ,cdopeapr = NULL
                  ,dtaprova = NULL
                  ,hraprova = 0
                  ,insitest = 0
             WHERE ROWID = rw_crawepr.nrrowid;
          EXCEPTION
            WHEN OTHERS THEN
              par_dscritic := 'Erro ao processar perca da aprovação: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          -- Limpar criticas
          par_cdcritic := NULL;
          par_dscritic := NULL;
        END IF;  
      END IF;
    END IF;  
    
  exception
    when vr_exc_erro then
      if par_cdcritic <> 0 and
         par_dscritic is null then
        par_dscritic := gene0001.fn_busca_critica(pr_cdcritic => par_cdcritic);
      end IF;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina PC_GRAVA_ALIENACAO_HIPOTECA: ' || SQLERRM;
  end; 
  
  
  /* Procedimento generico para receber as listas de bens e intervenientes e transformá-los em XML */
  PROCEDURE pc_converte_lista_xml(par_dsdalien IN VARCHAR2         --> Lista de Bens
                                 ,par_dsinterv IN VARCHAR2         --> Lista de Intervenientes
                                 ,par_xmlalien IN OUT NOCOPY CLOB  --> XML montado
                                 ,pr_dscritic  out VARCHAR2) IS    --> Descricao da critica
                                 
    -- Varchar2 temporário de Envio das Informações
    vr_dstextxml VARCHAR2(32767);
    
    -- variaveis para o split de informações
    vr_lista_princip GENE0002.typ_split; --> Split de caminhos
    vr_lista_interna GENE0002.typ_split; --> Split de caminhos
  BEGIN
    
    -- Criar documento XML
    dbms_lob.createtemporary(par_xmlalien, TRUE);
    dbms_lob.open(par_xmlalien, dbms_lob.lob_readwrite);
    gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                           ,pr_texto_completo => vr_dstextxml
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
    -- Quebrar String de Bens
    vr_lista_princip := GENE0002.fn_quebra_string(par_dsdalien,'|');
    -- Itera sobre o array de Alienações caso exista algum valor
    IF vr_lista_princip.count > 0 THEN
      -- Criaremos a tab bemalien
      gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                             ,pr_texto_completo => vr_dstextxml
                             ,pr_texto_novo     => '<listabem>');
      -- Ler todos os registros do vetor de caminhos
      FOR idxp IN 1..vr_lista_princip.count LOOP
        -- Novamente quebraremos a String, desta vez com ;, pois agora teremos cada campo do objeto de alienação
        vr_lista_interna := GENE0002.fn_quebra_string(vr_lista_princip(idxp),';');
        -- Itera sobre o array de Alienações caso exista algum valor
        IF vr_lista_interna.count > 0 THEN        
          -- Criaremos a tag do Bem
          gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                 ,pr_texto_completo => vr_dstextxml
                                 ,pr_texto_novo     => '<bemalien>');
          -- Para cada coluna
          FOR idxi IN 1..vr_lista_interna.count LOOP
            -- Utilizar no máximo 19 posições que é o tamanho do array de nomes
            IF idxi <= 19 THEN
              -- Enviaremos cada coluna mapeada
              gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                     ,pr_texto_completo => vr_dstextxml
                                     ,pr_texto_novo     => '<'||vr_vet_atrib_alienac(idxi)||'>'
                                                        || vr_lista_interna(idxi)
                                                        || '</'||vr_vet_atrib_alienac(idxi)||'>');
            END IF;
          END LOOP;
          -- Criaremos a tag do Bem
          gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                 ,pr_texto_completo => vr_dstextxml
                                 ,pr_texto_novo     => '</bemalien>');          
        END IF;  
      END LOOP;
      -- Criaremos a tab bemalien
      gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                             ,pr_texto_completo => vr_dstextxml
                             ,pr_texto_novo     => '</listabem>'); 
    END IF;
    
    -- Quebrar String de Intervenientes
    vr_lista_princip := GENE0002.fn_quebra_string(par_dsinterv,'|');
    -- Itera sobre o array de Alienações caso exista algum valor
    IF vr_lista_princip.count > 0 THEN
      -- Criaremos a tab bemalien
      gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                             ,pr_texto_completo => vr_dstextxml
                             ,pr_texto_novo     => '<listainterven>');
      -- Ler todos os registros do vetor de caminhos
      FOR idxp IN 1..vr_lista_princip.count LOOP
        -- Novamente quebraremos a String, desta vez com ;, pois agora teremos cada campo do objeto de alienação
        vr_lista_interna := GENE0002.fn_quebra_string(vr_lista_princip(idxp),';');
        -- Itera sobre o array de Intervenientes caso exista algum valor
        IF vr_lista_interna.count > 0 THEN        
          -- Criaremos a tag do Bem
          gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                 ,pr_texto_completo => vr_dstextxml
                                 ,pr_texto_novo     => '<interven>');
          -- Para cada coluna
          FOR idxi IN 1..vr_lista_interna.count LOOP
            -- Utilizar no máximo 18 posições que é o tamanho do array de nomes
            IF idxi <= 19 THEN
              -- Enviaremos cada coluna mapeada
              gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                     ,pr_texto_completo => vr_dstextxml
                                     ,pr_texto_novo     => '<'||vr_vet_atrib_interv(idxi)||'>'
                                                        || vr_lista_interna(idxi)
                                                        || '</'||vr_vet_atrib_interv(idxi)||'>');
            END IF;                                            
          END LOOP;
          -- Criaremos a tag do Bem
          gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                                 ,pr_texto_completo => vr_dstextxml
                                 ,pr_texto_novo     => '</interven>');          
        END IF;  
      END LOOP;
      -- Criaremos a tab bemalien
      gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                             ,pr_texto_completo => vr_dstextxml
                             ,pr_texto_novo     => '</listainterven>'); 
    END IF;
    
    -- Fechar o XML
    gene0002.pc_escreve_xml(pr_xml            => par_xmlalien
                           ,pr_texto_completo => vr_dstextxml
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);  
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado na rotina pc_converte_lista_xml --> '||SQLERRM;
  END pc_converte_lista_xml;
  
  
  /* Acionamento via tela das informações de Gravação dos Bens */
  procedure pc_grava_alienac_hipotec_web(par_nrdconta in crapbpr.nrdconta%TYPE --> Conta
                                        ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE --> Data
                                        ,par_tpctrato in crapbpr.tpctrpro%TYPE --> Tp Contrato
                                        ,par_nrctrato in crapbpr.nrctrpro%TYPE --> Contrato
                                        ,par_cddopcao IN VARCHAR2         --> Tipo da Ação
                                        ,par_dsdalien IN VARCHAR2         --> Lista de Bens
                                        ,par_dsinterv IN VARCHAR2         --> Lista de Intervenientes
                                        ,pr_xmllog    in VARCHAR2         --> XML com informacoes de LOG
                                        ,pr_cdcritic  out PLS_INTEGER     --> Codigo da critica
                                        ,pr_dscritic  out VARCHAR2        --> Descricao da critica
                                        ,pr_retxml  in out nocopy xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  out VARCHAR2        --> Nome do campo com erro
                                        ,pr_des_erro  out varchar2) is    --> Erros do processo
    -- PArca de aprovação
    vr_flperapr VARCHAR2(1);
    vr_dsmensag VARCHAR2(100);
    -- Variável de críticas
    vr_cdcritic   crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic   varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro   exception;
    -- Variaveis de log
    vr_cdcooper   integer;
    vr_cdoperad   varchar2(100);
    vr_nmdatela   varchar2(100);
    vr_nmeacao    varchar2(100);
    vr_cdagenci   varchar2(100);
    vr_nrdcaixa   varchar2(100);
    vr_idorigem   varchar2(100);    
    
    -- XML de Envio das Informações
    vr_dsclobxml CLOB;
    
  begin
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    -- Em caso de erro
    if vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
    
    -- Criar documento XML com os textos enviados
    pc_converte_lista_xml(par_dsdalien => par_dsdalien --> Lista de Bens
                         ,par_dsinterv => par_dsinterv --> Lista de Intervenientes
                         ,par_xmlalien => vr_dsclobxml --> XML montado
                         ,pr_dscritic  => vr_dscritic);--> Critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Direcionar para a gravacao
    pc_grava_alienacao_hipoteca(par_cdcooper => vr_cdcooper
                               ,par_cdoperad => vr_cdoperad
                               ,par_nrdconta => par_nrdconta
                               ,par_dtmvtolt => par_dtmvtolt
                               ,par_tpctrato => par_tpctrato
                               ,par_nrctrato => par_nrctrato
                               ,par_flsohbem => 'S' --> Somente Bens
                               ,par_cddopcao => par_cddopcao
                               ,par_xmlalien => vr_dsclobxml
                               ,par_flperapr => vr_flperapr
                               ,par_cdcritic => vr_cdcritic
                               ,par_dscritic => vr_dscritic);

    -- Em caso de erro 
    if vr_cdcritic > 0 OR vr_dscritic is not null then
      raise vr_exc_erro;
    ELSE
      -- Se houve perca da aprovação
      IF vr_flperapr = 'S' THEN
        -- Montar mensagem de perca de aprovação conforme esteira estar em contigência ou não
        IF gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA') = '1' THEN
          vr_dsmensag := 'Essa proposta deve ser aprovada na tela CMAPRV';
        ELSE
          vr_dsmensag := 'Essa proposta deve ser enviada para Analise de Credito';
        END IF;                            
        -- Retornar no XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' 
                                   ||'<Root>'
                                   ||'  <aviso>' ||vr_dsmensag|| '</aviso>'
                                   ||'</Root>');
      END IF;
    end if;
  exception
    when vr_exc_erro then
      if vr_cdcritic <> 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      end if;
      --
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina pc_grava_aliena_hipotec: ' || sqlerrm;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  end;
  
  /* Gravação da Alenação Hipotecaria chamando via Progress */
  procedure pc_grava_alienacao_hipot_prog(par_cdcooper in crapbpr.cdcooper%TYPE
                                         ,par_cdoperad in crapbpr.cdoperad%TYPE
                                         ,par_nrdconta in crapbpr.nrdconta%TYPE
                                         ,par_dtmvtolt in crapbpr.dtmvtolt%TYPE
                                         ,par_tpctrato in crapbpr.tpctrpro%TYPE
                                         ,par_nrctrato in crapbpr.nrctrpro%TYPE
                                         ,par_cddopcao IN VARCHAR2
                                         ,par_dsdalien IN VARCHAR2
                                         ,par_dsinterv IN VARCHAR2
                                         ,par_flperapr OUT VARCHAR2
                                         ,par_cdcritic out NUMBER
                                         ,par_dscritic out varchar2) is

    /* .............................................................................
    
        Programa: pc_grava_alienacao_hipot_prog          Antiga - B1wgen0002.p -> grava-alienacao-hipoteca
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Setembro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel por receber dados de Bens e Alienação no Progress
                    para repassar as rotinas convertidas que esperam a lista de Bens e 
                    intervenientes por XML
    
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/            
    -- XML de Envio das Informações
    vr_dsclobxml CLOB;
        
    -- Exceção
    vr_exc_erro   exception;
    vr_dscritic   VARCHAR2(4000);
  BEGIN
  
/*  
IF par_nrdconta = 3043525 THEN  
  
      UPDATE crapbpr 
         SET dscorbem = to_char(SYSDATE,'hh24:mi:ss')
     WHERE crapbpr.cdcooper = 1
       AND crapbpr.nrdconta = 3043525
       AND crapbpr.nrctrpro = 1233756
       AND crapbpr.tpctrpro = 90
       AND crapbpr.flgalien = 1;
       
    par_dscritic := 'teste de saida com erro';
    RAISE vr_exc_erro;
      

END IF;*/
  
    -- Criar documento XML com os textos enviados
    pc_converte_lista_xml(par_dsdalien => par_dsdalien --> Lista de Bens
                         ,par_dsinterv => par_dsinterv --> Lista de Intervenientes
                         ,par_xmlalien => vr_dsclobxml --> XML montado
                         ,pr_dscritic  => vr_dscritic);--> Critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                       
                           
        
    -- Acionar a rotina convertida e que espera um XML completo com bens e intervenientes
    pc_grava_alienacao_hipoteca(par_cdcooper => par_cdcooper
                               ,par_cdoperad => par_cdoperad
                               ,par_nrdconta => par_nrdconta
                               ,par_dtmvtolt => par_dtmvtolt 
                               ,par_tpctrato => par_tpctrato 
                               ,par_nrctrato => par_nrctrato
                               ,par_cddopcao => par_cddopcao
                               ,par_flsohbem => 'N'
                               ,par_xmlalien => vr_dsclobxml 
                               ,par_flperapr => par_flperapr 
                               ,par_cdcritic => par_cdcritic 
                               ,par_dscritic => par_dscritic);
    -- Em caso de erro
    IF par_cdcritic > 0 or par_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  exception
    when vr_exc_erro then
      if par_cdcritic <> 0 and
         par_dscritic is null then
        par_dscritic := gene0001.fn_busca_critica(pr_cdcritic => par_cdcritic);
      end if;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_MANBEM.PC_GRAVA_ALIENACAO_HIPOTECA: ' || sqlerrm;
  end;
  
  /* Criação do Interveniente Garantidor quando preenchido em tela */
  procedure pc_cria_interveniente(par_cdcooper in crapavt.cdcooper%type,
                                  par_nrdconta in crapavt.nrdconta%type,
                                  par_nrctremp in crapavt.nrctremp%type,
                                  par_nrcpfcgc in crapavt.nrcpfcgc%type,
                                  par_inpessoa IN crapavt.inpessoa%TYPE,
                                  par_nmdavali in crapavt.nmdavali%type,
                                  par_nrcpfcjg in crapavt.nrcpfcjg%type,
                                  par_nmconjug in crapavt.nmconjug%type,
                                  par_tpdoccjg in crapavt.tpdoccjg%type,
                                  par_nrdoccjg in crapavt.nrdoccjg%type,
                                  par_tpdocava in crapavt.tpdocava%type,
                                  par_nrdocava in crapavt.nrdocava%type,
                                  par_dsendres1 in crapavt.dsendres##1%type,
                                  par_dsendres2 in crapavt.dsendres##2%type,
                                  par_nrfonres in crapavt.nrfonres%type,
                                  par_dsdemail in crapavt.dsdemail%type,
                                  par_nmcidade in crapavt.nmcidade%type,
                                  par_cdufresd in crapavt.cdufresd%type,
                                  par_nrcepend in crapavt.nrcepend%type,
                                  par_cdnacion in crapavt.cdnacion%type,
                                  par_nrendere in crapavt.nrendere%type,
                                  par_complend in crapavt.complend%type,
                                  par_nrcxapst in crapavt.nrcxapst%type,
                                  par_cdcritic out number,
                                  par_dscritic out varchar2) is
  BEGIN
    DECLARE
      CURSOR cr_crapavt IS
        SELECT ROWID
          FROM crapavt avt
         WHERE avt.cdcooper = par_cdcooper
           AND avt.nrdconta = par_nrdconta
           AND avt.nrcpfcgc = par_nrcpfcgc
           AND avt.nrctremp = par_nrctremp
           AND avt.tpctrato = 9;
      vr_rowid ROWID;
    
  begin
      -- Checar se o avalista já não existe
      OPEN cr_crapavt;
      FETCH cr_crapavt
       INTO vr_rowid;
      CLOSE cr_crapavt;
      -- Se já existir
      IF vr_rowid IS NOT NULL THEN
        UPDATE crapavt
           SET nmdavali = par_nmdavali
              ,inpessoa = par_inpessoa
              ,nrcpfcjg = par_nrcpfcjg
              ,nmconjug = par_nmconjug
              ,tpdoccjg = par_tpdoccjg
              ,nrdoccjg = par_nrdoccjg
              ,tpdocava = par_tpdocava
              ,nrdocava = par_nrdocava
              ,dsendres##1 = par_dsendres1
              ,dsendres##2 = par_dsendres2
              ,nrfonres = par_nrfonres
              ,dsdemail = par_dsdemail
              ,nmcidade = par_nmcidade
              ,cdufresd = par_cdufresd
              ,nrcepend = par_nrcepend
              ,cdnacion = par_cdnacion
              ,nrendere = par_nrendere
              ,complend = par_complend
              ,nrcxapst = par_nrcxapst
         WHERE ROWID = vr_rowid;
      ELSE
        -- Criar o registro 
    insert into crapavt(cdcooper,
                        nrdconta,
                        tpctrato,
                        nrctremp,
                        nrcpfcgc,
                        nmdavali,
                        inpessoa,
                        nrcpfcjg,
                        nmconjug,
                        tpdoccjg,
                        nrdoccjg,
                        tpdocava,
                        nrdocava,
                        dsendres##1,
                        dsendres##2,
                        nrfonres,
                        dsdemail,
                        nmcidade,
                        cdufresd,
                        nrcepend,
                        cdnacion,
                        nrendere,
                        complend,
                        nrcxapst)
    values(par_cdcooper,
           par_nrdconta,
           9,
           par_nrctremp,
           par_nrcpfcgc,
           par_nmdavali,
           par_inpessoa,
           par_nrcpfcjg,
           par_nmconjug,
           par_tpdoccjg,
           par_nrdoccjg,
           par_tpdocava,
           par_nrdocava,
           par_dsendres1,
           par_dsendres2,
           par_nrfonres,
           par_dsdemail,
           par_nmcidade,
           par_cdufresd,
           par_nrcepend,
           par_cdnacion,
           par_nrendere,
           par_complend,
           par_nrcxapst);
      END IF;
    END;
  exception
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_MANBEM.PC_CRIA_INTERVENIENTE: ' || sqlerrm;
  end;

  /* Acionamento da criação do Interveniente Garantidor a patir de tela */
  procedure pc_cria_interveniente_web(pr_nrdconta  in varchar2,
                                      pr_nrctremp  in varchar2,
                                      pr_tpctrato  in varchar2,
                                      pr_nrcpfcgc  in varchar2,
                                      pr_nmdavali  in varchar2,
                                      pr_nrcpfcjg  in varchar2,
                                      pr_nmconjug  in varchar2,
                                      pr_tpdoccjg  in varchar2,
                                      pr_nrdoccjg  in varchar2,
                                      pr_tpdocava  in varchar2,
                                      pr_nrdocava  in VARCHAR2,
                                      pr_dsendres1 in VARCHAR2,
                                      pr_dsendres2 in varchar2,
                                      pr_nrfonres  in varchar2,
                                      pr_dsdemail  in varchar2,
                                      pr_nmcidade  in varchar2,
                                      pr_cdufresd  in varchar2,
                                      pr_nrcepend  in varchar2,
                                      pr_cdnacion  in varchar2,
                                      pr_nrendere  in varchar2,
                                      pr_complend  in varchar2,
                                      pr_nrcxapst  in varchar2,
                                      pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                      pr_cdcritic out pls_integer, --> Codigo da critica
                                      pr_dscritic out varchar2, --> Descricao da critica
                                      pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                      pr_nmdcampo out varchar2, --> Nome do campo com erro
                                      pr_des_erro out varchar2) is --> Erros do processo
    vr_numteste   number;
    -- Variável de críticas
    vr_cdcritic   crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic   varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro   exception;
    -- Variaveis de log
    vr_cdcooper   integer;
    vr_cdoperad   varchar2(100);
    vr_nmdatela   varchar2(100);
    vr_nmeacao    varchar2(100);
    vr_cdagenci   varchar2(100);
    vr_nrdcaixa   varchar2(100);
    vr_idorigem   varchar2(100);
    -- Buscar tipo de pessoa
    vr_stsnrcal   boolean;
    vr_inpessoa   crapass.inpessoa%type;
  begin
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    -- Em caso de erro
    if vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
    --
    begin
      vr_numteste := to_number(pr_nrdconta);
    exception
      when others then 
        vr_dscritic := 'Numero da conta do associado '||pr_nrdconta||' invalido!';
        pr_nmdcampo := 'nrdconta';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrctremp);
    exception
      when others then 
        vr_dscritic := 'Numero do contrato de emprestimo '||pr_nrctremp||' invalido!';
        pr_nmdcampo := 'nrctremp';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcpfcgc);
    exception
      when others then 
        vr_dscritic := 'Numero do CPF/CNPJ do Interveniente Garantidor '||pr_nrcpfcgc||' invalido!';
        pr_nmdcampo := 'nrcpfcgc';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcpfcjg);
    exception
      when others then 
        vr_dscritic := 'CPF do conjuge '||pr_nrcpfcjg||' invalido!';
        pr_nmdcampo := 'nrcpfcjg';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrdocava);
    exception
      when others then 
        vr_dscritic := 'Documento '||pr_nrdocava||' invalido!';
        pr_nmdcampo := 'nrdocava';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrdocava);
    exception
      when others then 
        vr_dscritic := 'Documento Conjuge '||pr_nrdoccjg||' invalido!';
        pr_nmdcampo := 'nrdocava';
        raise vr_exc_erro; 
    end;
    
    --
    begin
      vr_numteste := to_number(pr_nrcepend);
    exception
      when others then 
        vr_dscritic := 'CEP '||pr_nrcepend||' invalido!';
        pr_nmdcampo := 'nrcepend';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrendere);
    exception
      when others then 
        vr_dscritic := 'Numero do endereco '||pr_nrendere||' invalido!';
        pr_nmdcampo := 'nrendere';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcxapst);
    exception
      when others then 
        vr_dscritic := 'Caixa postal '||pr_nrcxapst||' invalida!';
        pr_nmdcampo := 'nrcxapst';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrfonres);
    exception
      when others then 
        vr_dscritic := 'Telefone '||pr_nrfonres||' invalido!';
        pr_nmdcampo := 'nrfonres';
        raise vr_exc_erro; 
    end;
    
    -- Validar e buscar o tipo de pessoa
    gene0005.pc_valida_cpf_cnpj(pr_nrcpfcgc,
                                vr_stsnrcal,
                                vr_inpessoa);
    if not vr_stsnrcal then
      vr_cdcritic := 27;
      pr_nmdcampo := 'nrcpfcgc';
      raise vr_exc_erro; 
    end if;
    
    -- Direcionar para a gravacao
    pc_cria_interveniente(par_cdcooper  => vr_cdcooper,
                          par_nrdconta  => pr_nrdconta,
                          par_nrctremp  => pr_nrctremp,
                          par_nrcpfcgc  => pr_nrcpfcgc,
                          par_nmdavali  => upper(pr_nmdavali),
                          par_nrcpfcjg  => pr_nrcpfcjg,
                          par_inpessoa  => vr_inpessoa,
                          par_nmconjug  => upper(pr_nmconjug),
                          par_tpdoccjg  => pr_tpdoccjg,
                          par_nrdoccjg  => pr_nrdoccjg,
                          par_tpdocava  => pr_tpdocava,
                          par_nrdocava  => pr_nrdocava,
                          par_dsendres1 => upper(pr_dsendres1),
                          par_dsendres2 => upper(pr_dsendres2),
                          par_nrfonres  => pr_nrfonres,
                          par_dsdemail  => upper(pr_dsdemail),
                          par_nmcidade  => upper(pr_nmcidade),
                          par_cdufresd  => upper(pr_cdufresd),
                          par_nrcepend  => pr_nrcepend,
                          par_cdnacion  => pr_cdnacion,
                          par_nrendere  => pr_nrendere,
                          par_complend  => upper(pr_complend),
                          par_nrcxapst  => pr_nrcxapst,
                          par_cdcritic  => pr_cdcritic,
                          par_dscritic  => pr_dscritic);
    -- Em caso de erro 
    if vr_cdcritic > 0 or
       vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
  exception
    when vr_exc_erro then
      if vr_cdcritic <> 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      end if;
      --
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_ADITIV.PC_VALIDA_INTERV_WEB: ' || sqlerrm;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  end;

  /* Validação de Interveniente Garantidor */
  procedure pc_valida_interv(par_nrctaava in number,
                             par_nrcepend in crapdne.nrceplog%type,
                             par_dsendrel in crapdne.nmextlog%type,
                             par_nmdavali in crapavt.nmdavali%type,
                             par_nrcpfcgc in crapavt.nrcpfcgc%type,
                             par_tpdocava in crapavt.tpdocava%type,
                             par_nrdocava in crapavt. nrdocava%type,
                             par_nmconjug in crapavt.nmconjug%type,
                             par_nrcpfcjg in crapavt.nrcpfcjg%type,
                             par_tpdoccjg in crapavt.tpdoccjg%type,
                             par_nrdoccjg in crapavt.nrdoccjg%type,
                             par_cdnacion in crapavt.cdnacion%type,
                             
                             par_nmdcampo out varchar2,
                             par_cdcritic out varchar2,
                             par_dscritic out varchar2) is
    
    /* .............................................................................
    
        Programa: pc_valida_interv
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel D. (Envolti)
        Data    : Setembro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel por validar o preenchimento do Interveniente Garantidor
  
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/     
    
    -- validar CEP 
    cursor cr_crapdne is
      select 1
        from crapdne c
       where c.nrceplog = par_nrcepend
         and rownum = 1;
    v_existe   number(1);
    
    -- Validar Logradouro
    cursor cr_crapdne2 is
      select 1
        from crapdne c
       where c.nrceplog = par_nrcepend
         and (   trim(par_dsendrel) like '%'||trim(c.nmextlog)||'%'
              or trim(par_dsendrel) like '%'||trim(c.nmreslog)||'%')
         and rownum = 1;
    
    -- Validar tipo de pessoa
    vr_stsnrcal   boolean;
    vr_inpessoa   crapass.inpessoa%type;
  begin
    -- Caso CEP informado
    if par_nrcepend <> 0 then
      -- Endereço deve ser informado
      if par_dsendrel is null then
        par_dscritic := 'Endereco deve ser informado.';
        par_nmdcampo := 'nrcepend';
        return;
      end if;
      -- Checar se o CEP existe na tabela
      open cr_crapdne;
        fetch cr_crapdne into v_existe;
        if cr_crapdne%notfound then
          par_dscritic := 'CEP nao cadastrado.';
          par_nmdcampo := 'nrcepend';
          close cr_crapdne;
          return;
        end if;
      close cr_crapdne;
      -- Checar se o endereço é o mesmo do CEP
      open cr_crapdne2;
        fetch cr_crapdne2 into v_existe;
        if cr_crapdne2%notfound then
          par_dscritic := 'Endereco nao pertence ao CEP.';
          par_nmdcampo := 'nrcepend';
          close cr_crapdne2;
          return;
        end if;
      close cr_crapdne2;
    end if;
    
    -- Nome obrigatorio
    if trim(par_nmdavali) is null then
      par_dscritic := 'Nome do interveniente deve ser informado.';
      par_nmdcampo := 'nmdavali';
      return;
    end if;
    
    -- Nacionalidade obrigatoria
    if nvl(trim(par_cdnacion),0) = 0 then
      par_dscritic := 'Nacionalidade do interveniente deve ser informada.';
      par_nmdcampo := 'cdnacion';
      return;
    end if;
    
    -- CPF obrigatorio
    if par_nrcpfcgc is null then
      par_dscritic := 'CPF/CNPJ do interveniente deve ser informado.';
      par_nmdcampo := 'nrcpfcgc';
      return;
    end if;
    
    -- validar o CPF informado
    gene0005.pc_valida_cpf_cnpj(par_nrcpfcgc,
                                vr_stsnrcal,
                                vr_inpessoa);
    if not vr_stsnrcal then
      par_cdcritic := 27;
      par_nmdcampo := 'nrcpfcgc';
      return;
    end if;
    
    -- Para PJ
    if vr_inpessoa = 2 then
      -- PJ
      IF trim(par_tpdocava) is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o tipo de documento do interveniente.';
        par_nmdcampo := 'tpdocava';
        return;
      end if;
      --
      if trim(par_nrdocava) is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o numero do documento do interveniente.';
        par_nmdcampo := 'nrdocava';
        return;
      end if;
      --
      if trim(par_nmconjug) is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o nome do conjuge.';
        par_nmdcampo := 'nmconjug';
        return;
      end if;
      --
      if nvl(trim(par_nrcpfcjg),0) <> 0 then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o CPF do conjuge.';
        par_nmdcampo := 'nrcpfcjg';
        return;
      end if;
      --
      if trim(par_tpdoccjg) is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o tipo de documento do conjuge.';
        par_nmdcampo := 'tpdoccjg';
        return;
      end if;
      --
      if trim(par_nrdoccjg) is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o nimero do documento do conjuge.';
        par_nmdcampo := 'nrdoccjg';
        return;
      end if;
    else
      -- PF
      if trim(par_tpdocava) is null then
        par_dscritic := 'Tipo de documento do interveniente é obrigatorio.';
        par_nmdcampo := 'tpdocava';
        return;
      end if;
      --
      if trim(par_nrdocava) is null then
        par_dscritic := 'Número do documento do interveniente é obrigatorio.';
        par_nmdcampo := 'nrdocava';
        return;
      end if;
      -- Comentadas as validações dos campos de Conjuge conforme solicitação do Télvio
      /*if trim(par_nmconjug) is not null or
         nvl(trim(par_nrcpfcjg),0) <> 0 or
         trim(par_tpdoccjg) is not null or
         nvl(trim(par_nrdoccjg),0) <> 0  then
        -- Se algum dos campos estiver preenchido, todos são obrigatórios
        if trim(par_nmconjug) is null or
           nvl(trim(par_nrcpfcjg),0) = 0 or
           trim(par_tpdoccjg) is null or
           nvl(trim(par_nrdoccjg),0) = 0  then
          par_dscritic := 'Todos os dados do conjuge devem ser informados.';
          par_nmdcampo := 'nrcpfcjg';
          return;
        end if;
        -- validar CPF do conjuge
        gene0005.pc_valida_cpf_cnpj(par_nrcpfcjg,
                                    vr_stsnrcal,
                                    vr_inpessoa);
        if not vr_stsnrcal then
          par_cdcritic := 27;
          par_nmdcampo := 'nrcpfcjg';
          return;
        end if;
      end if;*/
    end if;
  exception
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_MANBEM.PC_VALIDA_INTERV: ' || sqlerrm;
  end;

  /* Acionamento da validação de Interveniente Garantidor via tela */
  procedure pc_valida_interv_web(pr_nrctaava in varchar2,
                                 pr_nrcepend in varchar2,
                                 pr_dsendrel in varchar2,
                                 pr_nmdavali in varchar2,
                                 pr_nrcpfcgc in varchar2,
                                 pr_tpdocava in varchar2,
                                 pr_nrdocava in varchar2,
                                 pr_nmconjug in varchar2,
                                 pr_nrcpfcjg in varchar2,
                                 pr_tpdoccjg in varchar2,
                                 pr_nrdoccjg in VARCHAR2,
                                 pr_cdnacion in VARCHAR2,
                                 pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                 pr_cdcritic out pls_integer, --> Codigo da critica
                                 pr_dscritic out varchar2, --> Descricao da critica
                                 pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                 pr_nmdcampo out varchar2, --> Nome do campo com erro
                                 pr_des_erro out varchar2) is --> Erros do processo
    vr_numteste   number;
    -- Variável de críticas
    vr_cdcritic   crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic   varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro   exception;
    -- Variaveis de log
    vr_cdcooper   integer;
    vr_cdoperad   varchar2(100);
    vr_nmdatela   varchar2(100);
    vr_nmeacao    varchar2(100);
    vr_cdagenci   varchar2(100);
    vr_nrdcaixa   varchar2(100);
    vr_idorigem   varchar2(100);
  begin
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    -- Em caso de erro
    if vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
    -- 
    begin
      vr_numteste := to_number(pr_nrctaava);
    exception
      when others then 
        vr_dscritic := 'Numero da conta do avalista '||pr_nrctaava||' inválido!';
        pr_nmdcampo := 'nrctaava';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcepend);
    exception
      when others then 
        vr_dscritic := 'CEP '||pr_nrctaava||' invalido!';
        pr_nmdcampo := 'nrcepend';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcpfcgc);
    exception
      when others then 
        vr_dscritic := 'CPF '||pr_nrcpfcgc||' invalido!';
        pr_nmdcampo := 'nrcfcgc';
        raise vr_exc_erro; 
    end;
    --
    begin
      vr_numteste := to_number(pr_nrcpfcgc);
    exception
      when others then 
        vr_dscritic := 'Documento '||pr_nrdocava||' invalido!';
        pr_nmdcampo := 'nrdocava';
        raise vr_exc_erro; 
    end;
    
    -- Acionar validação 
    pc_valida_interv(par_nrctaava => pr_nrctaava,
                     par_nrcepend => pr_nrcepend,
                     par_dsendrel => pr_dsendrel,
                     par_nmdavali => pr_nmdavali,
                     par_nrcpfcgc => pr_nrcpfcgc,
                     par_tpdocava => pr_tpdocava,
                     par_nrdocava => pr_nrdocava,
                     par_nmconjug => pr_nmconjug,
                     par_nrcpfcjg => pr_nrcpfcjg,
                     par_tpdoccjg => pr_tpdoccjg,
                     par_nrdoccjg => pr_nrdoccjg,
                     par_cdnacion => pr_cdnacion,
                     par_nmdcampo => pr_nmdcampo,
                     par_cdcritic => pr_cdcritic,
                     par_dscritic => pr_dscritic);
    -- Em caso de erro 
    if vr_cdcritic > 0 or
       vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
  exception
    when vr_exc_erro then
      if vr_cdcritic <> 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      end if;
      --
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_ADITIV.PC_VALIDA_INTERV_WEB: ' || sqlerrm;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  end;

  /* Checar se o CPF está em alguma conta ativa do sistema */
  procedure pc_cpf_cadastrado_web(pr_nrdconta in crapavt.nrdconta%type,
                                  pr_nrctremp in crapavt.nrctremp%type,
                                  pr_tpctrato IN crapavt.tpctrato%TYPE,
                                  pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                                  pr_xmllog   in varchar2, --> XML com informacoes de LOG
                                  pr_cdcritic out pls_integer, --> Codigo da critica
                                  pr_dscritic out varchar2, --> Descricao da critica
                                  pr_retxml   in out nocopy xmltype, --> Arquivo de retorno do XML
                                  pr_nmdcampo out varchar2, --> Nome do campo com erro
                                  pr_des_erro out varchar2) is --> Erros do processo
    -- Variaveis de log
    vr_cdcooper   integer;
    vr_cdoperad   varchar2(100);
    vr_nmdatela   varchar2(100);
    vr_nmeacao    varchar2(100);
    vr_cdagenci   varchar2(100);
    vr_nrdcaixa   varchar2(100);
    vr_idorigem   varchar2(100);
    -- Variável de críticas
    vr_cdcritic   crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic   varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro   exception;
    -- Buscar se existe Interveniente
    cursor cr_crapavt is
      select 1
        from crapavt
       where cdcooper = vr_cdcooper
         and tpctrato = 9
         and nrdconta = pr_nrdconta
         and nrctremp = pr_nrctremp
         and nrcpfcgc = pr_nrcpfcgc;
    vr_indexis number;
    -- Buscar associado com conta ativa
    cursor cr_crapass is
      select 1
        from crapass
       where nrcpfcgc = pr_nrcpfcgc
         AND dtdemiss IS NULL;
  begin
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    -- Em caso de erro
    if vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
    pr_nmdcampo := 'nrcpfbem';
    -- QUando CPF zerado, sai direto da rotina
    IF pr_nrcpfcgc <> 0 THEN
      -- Testar se o CPF está na lista de avalistas ou intervenientes
      open cr_crapavt;
      fetch cr_crapavt into vr_indexis;
      -- Se não encontrar
      if cr_crapavt%notfound then
        close cr_crapavt;
        -- Verificar se o CPF é de algum Cooperado
        open cr_crapass;
          fetch cr_crapass into vr_indexis;
          -- Se não encontrar
          if cr_crapass%notfound then
            close cr_crapass;
            -- Retornar indicação de que não está cadastrado
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Dados EHASSOCIADO="NOK"/></Root>');
            return;
          end if;
        close cr_crapass;
      ELSE
        close cr_crapavt;
      end IF;
    END IF;
    -- Retornar indicação de que está cadastrado
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Dados EHASSOCIADO="OK"/></Root>');
  exception
    when vr_exc_erro then
      if vr_cdcritic <> 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      end if;
      --
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    when others then
      pr_dscritic := 'Erro na rotina TELA_ADITIV.PC_CPF_CADASTRADO_WEB: ' || sqlerrm;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  end;

END tela_manbem;
/
