create or replace package cecred.tela_manbem is
  /*---------------------------------------------------------------------------------------------------------------
  
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
                          ,pr_cddopcao IN VARCHAR2              --> Tipo da Ação
                          ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto ou Caminhão)
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

  /* Gravação da Alenação Hipotecaria */
  procedure pc_grava_alienacao_hipoteca(par_cdcooper in crapbpr.cdcooper%type,
                                        par_cdoperad in crapbpr.cdoperad%type,
                                        par_nrdconta in crapbpr.nrdconta%type,
                                        par_flgalien in crapbpr.flgalien%type,
                                        par_dtmvtolt in crapbpr.dtmvtolt%type,
                                        par_tpctrato in crapbpr.tpctrpro%type,
                                        par_nrctrato in crapbpr.nrctrpro%type,
                                        par_idseqbem in crapbpr.idseqbem%type,
                                        par_lssemseg in varchar2,
                                        par_tplcrato in number,
                                        par_dscatbem in crapbpr.dscatbem%type,
                                        par_dsbemfin in crapbpr.dsbemfin%type,
                                        par_dscorbem in crapbpr.dscorbem%type,
                                        par_vlmerbem in crapbpr.vlmerbem%type,
                                        par_dschassi in crapbpr.dschassi%type,
                                        par_nranobem in crapbpr.nranobem%type,
                                        par_nrmodbem in crapbpr.nrmodbem%type,
                                        par_tpchassi in crapbpr.tpchassi%type,
                                        par_nrcpfbem in crapbpr.nrcpfbem%type,
                                        par_uflicenc in crapbpr.uflicenc%type,
                                        par_dstipbem in crapbpr.dstipbem%type,
                                        par_dsmarbem in crapbpr.dsmarbem%type,
                                        par_vlfipbem in crapbpr.vlfipbem%type,
                                        par_dstpcomb in crapbpr.dstpcomb%type,
                                        par_nrdplaca in crapbpr.nrdplaca%type,
                                        par_nrrenava in crapbpr.nrrenava%type,
                                        par_ufdplaca in crapbpr.ufdplaca%type,
                                        par_cdcritic out number,
                                        par_dscritic out varchar2);

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

end;
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
    tela_manbem.pc_grava_alienacao_hipoteca(par_cdcooper => par_cdcooper,
                                            par_cdoperad => par_cdoperad,
                                            par_nrdconta => par_nrdconta,
                                            par_flgalien => 1,
                                            par_dtmvtolt => par_dtmvtolt,
                                            par_tpctrato => 90,
                                            par_nrctrato => par_nrctremp,
                                            par_idseqbem => par_idseqnov,
                                            par_lssemseg => tabe0001.fn_busca_dstextab(par_cdcooper,'CRED','USUARI',11,'DISPSEGURO',1),
                                            par_tplcrato => par_tplcrato,
                                            par_dscatbem => par_dscatbem,
                                            par_dsbemfin => v_dsrelbem,
                                            par_dscorbem => par_dscorbem,
                                            par_vlmerbem => par_vlmerbem,
                                            par_dschassi => par_dschassi,
                                            par_nranobem => par_nranobem,
                                            par_nrmodbem => par_nrmodbem,
                                            par_tpchassi => par_tpchassi,
                                            par_nrcpfbem => par_nrcpfcgc,
                                            par_uflicenc => par_uflicenc,
                                            par_dstipbem => par_dstipbem,
                                            par_dsmarbem => par_dsmarbem,
                                            par_vlfipbem => par_vlfipbem,
                                            par_dstpcomb => par_dstpcomb,
                                            par_nrdplaca => par_nrdplaca,
                                            par_nrrenava => par_nrrenava,
                                            par_ufdplaca => par_ufdplaca,
                                            par_cdcritic => par_cdcritic,
                                            par_dscritic => par_dscritic);
    -- Em caso de erro
    IF par_cdcritic > 0 OR par_dscritic IS NOT NULL THEN
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
      par_dscritic := 'Erro nao tratado na rotina TELA_MANBEM.PC_SUBSTITUI_BEM: ' || sqlerrm;
  end;
  --
  
  /**************************************************************************
   Validar os bens cadastrado na proposta de emprestimo com linha
   de credito do tipo alienacao.
  **************************************************************************/
  procedure pc_valida_dados_alienacao(par_cdcooper in number,
                                      par_cddopcao in varchar2,
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
  begin
    if trim(par_dscatbem) is null and
       trim(par_dsbemfin) is not null then
      v_dscritic := 'O campo Categoria e obrigatorio, preencha-o para continuar.';
      par_nmdcampo := 'dscatbem';
      raise vr_exc_erro;
    end if;
    --
    if trim(par_dscatbem) in ('MOTO', 'AUTOMOVEL', 'CAMINHAO') then
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
    if trim(par_dscatbem) in ('MOTO', 'AUTOMOVEL', 'CAMINHAO') then
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
      if trim(par_dscatbem) = 'CAMINHAO' and
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
    if trim(par_dscatbem) in ('MOTO', 'AUTOMOVEL', 'CAMINHAO') then
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
    ELSIF par_idseqbem > 0 then
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
      /** Nao pode substituir nesses Status */
      if v_crapbpr2.cdsitgrv = 1 then
        v_cdcritic := 0;
        v_dscritic := 'Bem a Substituir em Processamento Gravames! Favor selecionar outro bem!';
        par_nmdcampo := 'dsbemfin';
        raise vr_exc_erro;
      end if;
    end if;
    
    --
    if trim(par_dscatbem) is not null AND trim(par_dscatbem) NOT IN ('MAQUINA DE COSTURA','EQUIPAMENTO') then
      /** GRAVAMES - NAO PERMITIR ALTERAR DETERMINADAS SITUACOES */
      if par_cddopcao = 'A' and
         par_idseqbem <> 0 and
         (par_dscatbem like '%AUTOMOVEL%' or
          par_dscatbem like '%MOTO%' or
          par_dscatbem like '%CAMINHAO%') then
        /** Quando 0, significa Bem novo, nao critica */
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
        v_dscritic := 'RENAVAN do veiculo com mais de 11 digitos.';
        par_nmdcampo := 'nrrenava';
        raise vr_exc_erro;
      end if;
      --
      if par_ufdplaca is not null then
        if gene0005.fn_valida_uf(par_ufdplaca) = 0 then
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
    /* Verifica se apresenta a mensagem de garantia na tela */
    empr0001.pc_verifica_msg_garantia(par_cdcooper,
                                      par_dscatbem,
                                      par_vlmerbem,
                                      par_vlemprst,
                                      par_flgsenha,
                                      par_dsmensag,
                                      v_cdcritic,
                                      v_dscritic);
    if v_cdcritic is not null or
       v_dscritic is not null then
      raise vr_exc_erro;
    end if;
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
                          ,pr_cddopcao IN VARCHAR2              --> Tipo da Ação
                          ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto ou Caminhão)
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
      SELECT wpr.vlsdeved
        FROM crapepr wpr            
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
        IF vr_nmdatela = 'ADITIV' THEN
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
    /*BEGIN
      vr_numteste := to_number(pr_vlrdobem);
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Valor de Mercado '||pr_vlrdobem||' inválido!';
        pr_nmdcampo := 'vlrdobem';
        RAISE vr_exc_erro; 
    END;    */

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
                             ,par_nrdconta => pr_nrdconta
                             ,par_nrctremp => pr_nrctremp
                             ,par_dscorbem => upper(pr_dscorbem)
                             ,par_nrdplaca => upper(pr_nrdplaca)
                             ,par_idseqbem => pr_idseqbem
                             ,par_dscatbem => upper(pr_dscatbem)
                             ,par_dstipbem => upper(pr_dstipbem)
                             ,par_dsbemfin => upper(pr_dsbemfin)
                             ,par_vlmerbem => pr_vlrdobem
                             ,par_tpchassi => pr_tpchassi
                             ,par_dschassi => upper(pr_dschassi)
                             ,par_ufdplaca => upper(pr_ufdplaca)
                             ,par_uflicenc => upper(pr_uflicenc)
                             ,par_nrrenava => pr_nrrenava
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
    ELSIF vr_dsmensag IS NOT NULL THEN
      -- Montar a mesma no XML de retorno  
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><mensagem>' ||vr_dsmensag|| '</mensagem></Root>');        
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
  
  
  /* Gravação da Alenação Hipotecaria */
  procedure pc_grava_alienacao_hipoteca(par_cdcooper in crapbpr.cdcooper%type,
                                        par_cdoperad in crapbpr.cdoperad%type,
                                        par_nrdconta in crapbpr.nrdconta%type,
                                        par_flgalien in crapbpr.flgalien%type,
                                        par_dtmvtolt in crapbpr.dtmvtolt%type,
                                        par_tpctrato in crapbpr.tpctrpro%type,
                                        par_nrctrato in crapbpr.nrctrpro%type,
                                        par_idseqbem in crapbpr.idseqbem%type,
                                        par_lssemseg in varchar2,
                                        par_tplcrato in number,
                                        par_dscatbem in crapbpr.dscatbem%type,
                                        par_dsbemfin in crapbpr.dsbemfin%type,
                                        par_dscorbem in crapbpr.dscorbem%type,
                                        par_vlmerbem in crapbpr.vlmerbem%type,
                                        par_dschassi in crapbpr.dschassi%type,
                                        par_nranobem in crapbpr.nranobem%type,
                                        par_nrmodbem in crapbpr.nrmodbem%type,
                                        par_tpchassi in crapbpr.tpchassi%type,
                                        par_nrcpfbem in crapbpr.nrcpfbem%type,
                                        par_uflicenc in crapbpr.uflicenc%type,
                                        par_dstipbem in crapbpr.dstipbem%type,
                                        par_dsmarbem in crapbpr.dsmarbem%type,
                                        par_vlfipbem in crapbpr.vlfipbem%type,
                                        par_dstpcomb in crapbpr.dstpcomb%type,
                                        par_nrdplaca in crapbpr.nrdplaca%type,
                                        par_nrrenava in crapbpr.nrrenava%type,
                                        par_ufdplaca in crapbpr.ufdplaca%type,
                                        par_cdcritic out number,
                                        par_dscritic out varchar2) is
    -- Verificar se o bem jah não existe
    CURSOR cr_crapbpr IS
      select crapbpr.rowid
        from crapbpr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and tpctrpro = par_tpctrato
         and nrctrpro = par_nrctrato
         and idseqbem = par_idseqbem;
    vr_rowid ROWID;
    
    --
    v_flgsegur    crapbpr.flgsegur%type;
    v_nrdplaca    crapbpr.nrdplaca%type;
    v_nrrenava    crapbpr.nrrenava%type;
    v_ufdplaca    crapbpr.ufdplaca%type;
    v_flginclu    crapbpr.flginclu%TYPE := 0;
    v_cdsitgrv    crapbpr.cdsitgrv%TYPE := 0;
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
    if par_tplcrato = 2 AND (par_dscatbem like '%AUTOMOVEL%' OR par_dscatbem like '%MOTO%' OR par_dscatbem like '%CAMINHAO%') THEN
      v_flginclu := 1;
      v_cdsitgrv := 0;
      v_tpinclus := 'A';
      /*
        crawepr.flgokgrv = TRUE.
      */
    end if;
    
    -- Verificar se o bem jah não existe
    OPEN cr_crapbpr;
    FETCH cr_crapbpr
     INTO vr_rowid;
    CLOSE cr_crapbpr;
    
    -- Se bem jah existir
    IF vr_rowid IS NOT NULL THEN 
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
               cdsitgrv = v_cdsitgrv,
               flginclu = v_flginclu,
               tpinclus = v_tpinclus,
               dstipbem = par_dstipbem,
               dsmarbem = par_dsmarbem,
               vlfipbem = par_vlfipbem,
               dstpcomb = par_dstpcomb
         where ROWID = vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          par_dscritic := 'Erro ao atualizar Bem: '||SQLERRM;
          RAISE vr_exc_erro;
      END;   
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
                v_cdsitgrv,
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
  begin
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
    --
    commit;
  exception
    when dup_val_on_index then
      /* Interveniente ja cadastrado - Nao pode ter dois intervenientes*/
                     /* Com o mesmo CPF/CNPJ - Gabriel */
      null;
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
                             par_nrdocava in crapavt.nrdocava%type,
                             par_nmconjug in crapavt.nmconjug%type,
                             par_nrcpfcjg in crapavt.nrcpfcjg%type,
                             par_tpdoccjg in crapavt.tpdoccjg%type,
                             par_nrdoccjg in crapavt.nrdoccjg%type,
                             par_cdnacion in crapavt.cdnacion%type,
                             par_nmdcampo out varchar2,
                             par_cdcritic out varchar2,
                             par_dscritic out varchar2) is
    
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
    if par_nmdavali is null then
      par_dscritic := 'Nome do interveniente deve ser informado.';
      par_nmdcampo := 'nmdavali';
      return;
    end if;
    
    -- Nacionalidade obrigatoria
    if par_cdnacion is null then
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
    
    -- Para PH
    if vr_inpessoa = 2 then
      -- PJ
      if par_tpdocava is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o tipo de documento do interveniente.';
        par_nmdcampo := 'tpdocava';
        return;
      end if;
      --
      if par_nrdocava is not null then
        par_dscritic := 'Para pessoa juridica, nao e permitido informar o numero do documento do interveniente.';
        par_nmdcampo := 'nrdocava';
        return;
      end if;
      --
      if par_nmconjug is not null then
        par_dscritic := 'Para pessoa jurídica, nao e permitido informar o nome do conjuge.';
        par_nmdcampo := 'nmconjug';
        return;
      end if;
      --
      if par_nrcpfcjg is not null then
        par_dscritic := 'Para pessoa jurídica, nao e permitido informar o CPF do conjuge.';
        par_nmdcampo := 'nrcpfcjg';
        return;
      end if;
      --
      if par_tpdoccjg is not null then
        par_dscritic := 'Para pessoa jurídica, nao e permitido informar o tipo de documento do conjuge.';
        par_nmdcampo := 'tpdoccjg';
        return;
      end if;
      --
      if par_nrdoccjg is not null then
        par_dscritic := 'Para pessoa jurídica, nao e permitido informar o nimero do documento do conjuge.';
        par_nmdcampo := 'nrdoccjg';
        return;
      end if;
    else
      -- PF
      if par_tpdocava is null then
        par_dscritic := 'Tipo de documento do interveniente é obrigatorio.';
        par_nmdcampo := 'tpdocava';
        return;
      end if;
      --
      if par_nrdocava is null then
        par_dscritic := 'Número do documento do interveniente é obrigatorio.';
        par_nmdcampo := 'nrdocava';
        return;
      end if;
      --
      if par_nmconjug is not null or
         nvl(par_nrcpfcjg,0) <> 0 or
         par_tpdoccjg is not null or
         nvl(par_nrdoccjg,0) <> 0  then
        -- Se algum dos campos estiver preenchido, todos são obrigatórios
        if par_nmconjug is null or
           nvl(par_nrcpfcjg,0) = 0 or
           par_tpdoccjg is null or
           nvl(par_nrdoccjg,0) = 0  then
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
      end if;
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

end;
/
