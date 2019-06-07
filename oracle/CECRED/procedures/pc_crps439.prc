create or replace procedure cecred.pc_crps439(pr_cdcooper  in craptab.cdcooper%type,
                                       pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                       pr_stprogra out pls_integer,            --> Saída de termino da execução
                                       pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                       pr_cdcritic out crapcri.cdcritic%type,
                                       pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps439 - Antigo fontes/crps439.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Marco/2005                       Ultima atualizacao: 19/11/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001
               Ordem na solicitacao = 50.
               Processar as solicitacoes de geracao dos debitos de seguro.
               Emite relatorio 416

   Alteracoes: 08/04/2005 - Alteracao na formatacao do relatorio de 132 para 80
                            colunas (Julio)

               03/05/2005 - Alterado para listar as alteracoes conforme a data
                            de digitacao e efetuar o debito um dia util apos
                            a data de debito caso a data de debito seja um
                            domingo ou feriado. (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/10/2005 - Alterado o e-mail do Jean para a Mary (Julio)

               24/10/2005 - Alterada a extensao do relatorio de .lst para
                            .doc, pois .lst estava sendo barrado pelo filtro
                            do servidor da Addmakler (Julio)

               24/11/2005 - Tratamento para planos de seguro com parcelas
                            variaveis ou unica. (Julio)

               06/12/2005 - Alteracao de e-mail da Mary para o Jean (Julio)

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               14/12/2005 - Ajustes no controle indebito (Julio)

               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               03/04/2006 - Alteracao na critica 200 para o LOG (Julio)

               21/06/2006 - Preparar relatorio para seguradora CHUBB (Julio)

               06/07/2006 - Nao deixar lancar valores negativos (Julio).

               13/07/2006 - Ajustes para debitos de seguros cancelados (Julio)

               19/07/2006 - Atualizacao do FIND crapavs. Antes estava prvisto
                            para seguros vinculados a folha. Isto nao esta mais
                            sendo utilizado. (Julio)

               28/08/2006 - Somente listar no log, seguros com valores
                            negativos (Julio)

               08/01/2007 - Enviado arquivo .doc para ADDmakler e arquivo .lst
                            para diretorio "rl" (Elton).

               22/05/2007 - Incluido envio do relatorio 416 para os emails
                            rene.bnu@addmakler.com.br e
                            pedro.bnu@addmakler.com.br (Guilherme).

               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               08/08/2008 - Gerar/Enviar novo arquivo(str_2) (Diego).
                          - Enviar e-mail a josianes.bnu@addmakler.com.br
                            (Gabriel).

               20/10/2008 - Gerar arquivo(str_2) somente se Parametro Seguro
                            Chubb estiver cadastrado na TAB049 (Diego).

               14/11/2008 - Alterado para buscar numero do lote(str_2) atraves
                            da craptab, e incrementar sequencia (Diego).

               29/01/2009 - Enviar e-mail somente p/ aylloscecred@addmakler.
                            com.br (Gabriel).

               10/03/2009 - Enviar arquivo crrl416.doc para demais emails:
                            egoncalves@chubb.com galmeida@chubb.com (Diego).

               03/12/2009 - Inclusao do PAC do Seguro no relatorio apresentado
                            (GATI - Eder)

               16/05/2011 - Desconsiderar do relatório, seguros contratados e
                            cancelados no mesmo dia (Diego).

               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)

               16/09/2011 - Incluidos campos de tipos de movimento, motivo de
                            cancelamento, RG, crapseg.flgclabe e
                            crapseg.nmbenvid[1] nos Detalhes. Retirados
                            tratamentos referente a endosso.
                            Incluido no relatorio crrl416 listagem de
                            seguros renovados. (Gati - Oliver)

               04/10/2011 - Incluido tratamento para endereco de
                            correspondencia (Diego).

               21/12/2011 - Corrigido warnings (Tiago).

               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por
                            cecredseguros@cecred.coop.br (Daniele).

               09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               19/09/2013 - Incluir o campo complemento no relatorio que e
                            enviado para a Chubb (James).

               06/01/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               24/01/2014 - Incluir VALIDATE crapavs, craplot, craplcm (Lucas R)

               29/01/2014 - Incluir ordenacao no for each crapseg e incluido
                            campo na ordenacao da cratseg (Lucas R.)

               20/02/2014 - Alterações de 01/2014 convertidas para Oracle. A alteração do dia
                            24/01 não é necessária. A do dia 29/01 já havia sido implementada
                            quando o programa foi convertido. (Daniel - Supero)

               03/07/2014 - Alterado o layout do arquivo de remessa para que seja adicionado o
                            número do endereço em uma posicao especifica do arquivo.
                            (Douglas - Chamado 160602)

               12/08/2014 - Alterar a variável vr_nmcidade, para vr_dscidduf, para não causar
                            erro. Este ajuste se fez necessário devido a erro no processo diário
                            na tentativa de atribuição da descrição "BALNEARIO ARROIO DO SUL/SC"
                            para a variável.  (Renato - Supero)

               30/09/2014 - Alteracoes para correcao do layout do arquivo de Remessa. Os Campos de
                            cidade e estado causavam erro de posicionamento quando nulos.
                            Ajuste na procedure gera_avs para corrigir valor do campo nrdocmto.
                            (Alisson - AMcom).

               29/01/2015 - Alterado layout do arquivo enviado para a seguradora CHUBB para inclusão
                            das datas de vencimentos das parcelas do seguro SD243733 (Odirlei-AMcom)


               12/03/2015 - Ajuste na inicalização dos campos de endereço do seguro, para que não apresente
                            falha ao montar o layout do arquivo enviado a seguradora (Odirlei-AMcom)
               
               13/04/2015 - Ajuste na validação de daa limite do cancelamento, para que não seja debitado 
                            se o cancelamento ocorrer no mesmo dia da criação do seguro SD-275054 (Odirlei-AMcom)             
                            
               12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							(Adriano - P339).

               04/07/2017 - Ajustes para antecipar o debito dos seguros que caem no fim do mes e que esta
                            data nao é um dia util (Tiago/Thiago #680197)                         
                            
               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)                            

               30/04/2018 - P450 - Implementação da procedure de controle de débito em contas com atraso por inadimplência;
                            Cancelamento automático de seguro para debitos não efetuados;
                            Envio de mensagens para cooperados que tiveram seguros cancelados por inadimplência.
                            Marcel Kohls (AMcom)
                            
               19/11/2018 - PRB0040434 Tratamento para gerar o arquivo RM somente no batch (Carlos)

			   13/03/2019 - Remoção da atualização da capa de lote para seguros
							Alcemir Mouts

               05/06/2019 - Remoção de caracteres especiais e alteração de layout do arquivo RM.
                            Alcemir Jr. (INC0016878).

               ............................................................................. */
  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;
	
  -- Buscar informações de seguros residenciais que ainda não foram debitados no mês
  CURSOR cr_crapseg (pr_cdcooper in crapseg.cdcooper%TYPE,
                     pr_nrctares in crapseg.nrdconta%TYPE,
                     pr_dtmvtolt in crapseg.dtmvtolt%TYPE,
                     pr_dtprdebi in crapseg.dtmvtolt%TYPE) IS 
    select crapseg.cdsegura,
           crapseg.tpplaseg,
           crapseg.cdsitseg,
           crapseg.nrdconta,
           crapseg.vlpreseg,
           crapseg.tpseguro,
           crapseg.dtcancel,
           crapseg.nrctrseg,
           crapseg.dtinivig,
           crapseg.qtparcel,
           crapseg.dtdebito,
           crapseg.flgunica,
           crapseg.qtprepag,
           crapseg.dtprideb,
           crapseg.vlpremio,
           crapseg.vlprepag,
           crapseg.dtultpag,
           crapseg.dtmvtolt,
           crapseg.dtfimvig,
           crapseg.rowid,
           sld.qtddsdev
      from crapseg, crapsld sld
     where crapseg.cdcooper = pr_cdcooper
       and crapseg.nrdconta > pr_nrctares
       and crapseg.tpseguro >= 11
       and crapseg.indebito = 0
       and (   crapseg.dtdebito <= pr_dtprdebi
            or crapseg.dtprideb = pr_dtmvtolt)
       AND sld.cdcooper  = crapseg.cdcooper
       AND sld.nrdconta  = crapseg.nrdconta
     order by dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrctrseg;
  rw_crapseg     cr_crapseg%rowtype;
	
  -- Buscar informações da seguradora
  cursor cr_crapcsg (pr_cdcooper in crapcsg.cdcooper%type,
                     pr_cdsegura in crapcsg.cdsegura%type) is
    select crapcsg.cdhstcas##2,
           crapcsg.nmsegura
      from crapcsg
     where crapcsg.cdcooper = pr_cdcooper
       and crapcsg.cdsegura = pr_cdsegura;
  rw_crapcsg     cr_crapcsg%rowtype;
	
  -- Buscar informações dos planos de seguro
  cursor cr_craptsg (pr_cdcooper in craptsg.cdcooper%type,
                     pr_tpplaseg in craptsg.tpplaseg%type,
                     pr_tpseguro in craptsg.tpseguro%type,
                     pr_cdsegura in craptsg.cdsegura%type) is
    select craptsg.ddcancel,
           craptsg.flgunica,
           craptsg.inplaseg
      from craptsg
     where craptsg.cdcooper = pr_cdcooper
       and craptsg.tpplaseg = pr_tpplaseg
       and craptsg.tpseguro = pr_tpseguro
       and craptsg.cdsegura = pr_cdsegura;
  rw_craptsg     cr_craptsg%rowtype;
	
  -- Buscar informações do associado
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select crapass.cdagenci,
           crapass.inpessoa,
           crapass.nmprimtl,
           crapass.nrcpfcgc,
           org.cdorgao_expedidor cdoedptl,
           crapass.dtemdptl,
           crapass.dtnasctl,
           crapass.cdsecext
      from crapass,
           tbgen_orgao_expedidor org
     where crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = pr_nrdconta
       AND crapass.idorgexp = org.idorgao_expedidor(+);
  rw_crapass     cr_crapass%rowtype;
	
  -- Buscar informações de seguros
  cursor cr_crawseg (pr_cdcooper in crawseg.cdcooper%type,
                     pr_cdsegura in crawseg.cdsegura%type,
                     pr_nrdconta in crawseg.nrdconta%type,
                     pr_nrctrseg in crawseg.nrctrseg%type) is
    select crawseg.rowid,
           crawseg.vlpreseg,
           crawseg.dsendres,
           crawseg.nrendres,
           crawseg.nmbairro,
           crawseg.nmcidade,
           crawseg.nrcepend,
           crawseg.complend,
           crawseg.cdufresd
      from crawseg
     where crawseg.cdcooper = pr_cdcooper
       and crawseg.cdsegura = pr_cdsegura
       and crawseg.nrdconta = pr_nrdconta
       and crawseg.nrctrseg = pr_nrctrseg;
  rw_crawseg     cr_crawseg%rowtype;
	
  -- Capa dos lotes
  cursor cr_craplot (pr_cdcooper in craplot.cdcooper%type,
                     pr_dtmvtopr in craplot.dtmvtolt%type,
                     pr_cdagenci in craplot.cdagenci%type,
                     pr_cdbccxlt in craplot.cdbccxlt%type,
                     pr_nrdolote in craplot.nrdolote%type) is
    select co.rowid,
           co.dtmvtolt,
           co.cdagenci,
           co.cdbccxlt,
           co.nrdolote,
           co.nrseqdig
      from craplot co
     where co.cdcooper = pr_cdcooper
       and co.dtmvtolt = pr_dtmvtopr
       and co.cdagenci = pr_cdagenci
       and co.cdbccxlt = pr_cdbccxlt
       and co.nrdolote = pr_nrdolote;
  rw_craplot     cr_craplot%rowtype;
	
  -- Buscar informações de seguros
  cursor cr_crapseg2 (pr_cdcooper in crapseg.cdcooper%type,
                      pr_dtmvtolt in crapseg.dtmvtolt%type) is
    select crapseg.rowid,
           crapseg.nrdconta,
           crapseg.cdsegura,
           crapseg.dtcancel,
           crapseg.nrctrseg,
           crapseg.tpplaseg,
           crapseg.cdsitseg,
           crapseg.vlpreseg,
           crapseg.tpseguro,
           crapseg.dtinivig,
           crapseg.dtfimvig,
           crapseg.cdagenci,
           crapseg.cdmotcan,
           crapseg.flgclabe,
           crapseg.nmbenvid##1,
           crapseg.tpendcor,
           crapseg.dtprideb,
           crapseg.dtdebito
      from crapseg
     where crapseg.cdcooper = pr_cdcooper
       and (   crapseg.dtmvtolt = pr_dtmvtolt
            or crapseg.dtcancel = pr_dtmvtolt)
       and nvl(crapseg.dtmvtolt, to_date('31122999','ddmmyyyy')) <> nvl(crapseg.dtcancel, to_date('31122999','ddmmyyyy'))
       and crapseg.tpseguro >= 11;
			 
  -- Cadastro do titular da conta
  cursor cr_crapttl (pr_cdcooper in crapttl.cdcooper%type,
                     pr_nrdconta in crapttl.nrdconta%type) is
    select crapttl.nrdocttl
      from crapttl
     where crapttl.cdcooper = pr_cdcooper
       and crapttl.nrdconta = pr_nrdconta
       and crapttl.idseqttl = 1
       and crapttl.tpdocttl = 'CI';
  rw_crapttl     cr_crapttl%rowtype;
	
  -- Buscar o telefone fixo ou celular
  cursor cr_craptfc (pr_cdcooper in craptfc.cdcooper%type,
                     pr_nrdconta in craptfc.nrdconta%type) is
    select craptfc.nrtelefo
      from craptfc
     where craptfc.cdcooper = pr_cdcooper
       and craptfc.nrdconta = pr_nrdconta
       and craptfc.tptelefo in (1,2)
     order by craptfc.progress_recid;
  rw_craptfc     cr_craptfc%rowtype;
	
  -- Buscar o e-mail do titular
  cursor cr_crapcem (pr_cdcooper in crapcem.cdcooper%type,
                     pr_nrdconta in crapcem.nrdconta%type) is
    select crapcem.dsdemail
      from crapcem
     where crapcem.cdcooper = pr_cdcooper
       and crapcem.nrdconta = pr_nrdconta
       and crapcem.idseqttl = 1
     order by crapcem.progress_recid;
  rw_crapcem     cr_crapcem%rowtype;
	
  -- Buscar o endereço de correspondência
  cursor cr_crapenc (pr_cdcooper in crapenc.cdcooper%type,
                     pr_nrdconta in crapenc.nrdconta%type,
                     pr_tpendass in crapenc.tpendass%type) is
    select crapenc.nrcepend,
           crapenc.nmcidade,
           crapenc.nmbairro,
           crapenc.cdufende,
           crapenc.dsendere,
           crapenc.complend,
           crapenc.nrendere
      from crapenc
     where crapenc.cdcooper = pr_cdcooper
       and crapenc.nrdconta = pr_nrdconta
       and crapenc.tpendass = pr_tpendass;
  rw_crapenc     cr_crapenc%rowtype;
  --
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  rw_craptab       btch0001.cr_craptab%rowtype;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);
  -- Variáveis para controle de reprocesso
  vr_dsrestar      crapres.dsrestar%type;
  vr_nrctares      crapres.nrdconta%type;
  vr_inrestar      number(1);
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       clob;
  vr_des_txt       varchar2(32700);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  vr_nrcopias      number(1) := 1;
  -- Variáveis auxiliares para o arquivo texto
  vr_nrsequen      number(5);
  vr_contareg      number(5);
  vr_nmcidaux      varchar2(20);
  vr_sigestad      varchar2(2);
  -- Lista de destinatários do e-mail
  vr_destinatarios varchar2(2000);
  -- Variáveis para auxiliar o processamento
  vr_vlpreseg      crapseg.vlpreseg%type;
  vr_flgeravs      boolean;
  vr_lcm_cdhistor  craplcm.cdhistor%type;
  vr_lcm_nrdocmto  craplcm.nrdocmto%type;
  vr_lcm_nrseqdig  craplcm.nrseqdig%type;
  vr_lcm_vllanmto  craplcm.vllanmto%type;
  vr_indebito      crapseg.indebito%type;
  vr_dtdebito      crapseg.dtdebito%type;
  vr_dtprdebi      crapseg.dtdebito%type;
  vr_retornos      LANC0001.typ_reg_retorno; -- Retornos da procedure "pc_gerar_lancamento_conta"
  vr_incrineg      INTEGER;      -- Indicador de crítica do negócio
  vr_dtfimvig      DATE;         -- Data de fim da vigência do seguro (para fins de cancelamento automático)
  vr_dsseguro      varchar2(50);
  vr_rowid_log     rowid;
  -- PL/Table para armazenar os dados do seguro
  type typ_cratseg is record (tpregist  number(1),
                              nrdconta  crapass.nrdconta%type,
                              nrctrseg  crapseg.cdsegura%type,
                              tpplaseg  crapseg.tpplaseg%type,
                              cdagenci  crapass.cdagenci%type,
                              nmprimtl  crapass.nmprimtl%type,
                              vlpreseg  crapseg.vlpreseg%type,
                              cdsegura  crapseg.cdsegura%type,
                              dtinivig  crapseg.dtinivig%type,
                              dtfimvig  crapseg.dtfimvig%type,
                              dtcancel  crapseg.dtcancel%type,
                              nrcpfcgc  crapass.nrcpfcgc%type,
                              nrdocptl  crapass.nrdocptl%type,
                              cdoedptl  tbgen_orgao_expedidor.cdorgao_expedidor%TYPE,
                              dtemdptl  crapass.dtemdptl%type,
                              dtnasctl  crapass.dtnasctl%type,
                              dsendres  crawseg.dsendres%type,
                              nmbairro  crawseg.nmbairro%type,
                              nmcidade  varchar2(50), --crawseg.nmcidade%type, RENATO: Erro...
                              nrcepend  crawseg.nrcepend%type,
                              cdageseg  crapseg.cdagenci%type,
                              cdmotcan  crapseg.cdmotcan%type,
                              flgclabe  crapseg.flgclabe%type,
                              nmbenvid  crapseg.nmbenvid##1%type,
                              tpendcor  crapseg.tpendcor%type,
                              complend  crawseg.complend%type,
                              nrendres  crawseg.nrendres%type,
                              inpessoa  crapass.inpessoa%TYPE,
                              dtprideb  crapseg.dtprideb%TYPE,
                              dtdebito  crapseg.dtdebito%TYPE);

  type typ_tab_cratseg is table of typ_cratseg index by varchar2(54);
  vr_cratseg       typ_tab_cratseg;
  -- O índice da pl/table é formado pelos campos cdsegura, dtinivig, tpregist, cdagenci, nrdconta e nrctrseg, garantindo a ordenação do relatório
  vr_ind_cratseg   varchar2(54);
  -- Variáveis para auxiliar a manipulação da pl/table
  vr_cdsegura      crapseg.cdsegura%type;
  vr_dtinivig      crapseg.dtinivig%type;
  vr_tpregist      number(1);
  vr_dsendres      crawseg.dsendres%type;
  vr_nmbairro      crawseg.nmbairro%type;
  vr_nmcidade      crawseg.nmcidade%type;
  vr_dscidduf      VARCHAR2(50); -- descrição da cidade / UF

  /*
  cidade que causou erro foi: BALNEARIO ARROIO DA SILVA

  Retornado pelo cursor cr_crawseg
  parametros: pr_cdcooper = 5
              cdsegura    = 5011
              nrdconta    = 85154
              nrctrseg    = 85154
        */
  vr_nrcepend      crawseg.nrcepend%type;
  vr_complend      crawseg.complend%type;
  vr_nrendres      crawseg.nrendres%type;
  vr_nrseqdig      craplot.nrseqdig%type; -- REMOCAO LOTE
  
  -- PL/Table para armazenar o resumo
  type typ_arquivo is record (tpdlinha  number(1),
                              dsdlinha  varchar2(1000));
  type typ_tab_arquivo is table of typ_arquivo index by binary_integer;
  vr_arquivo       typ_tab_arquivo;
  vr_ind_arquivo   binary_integer;
  -- Variáveis para processamento do resumo
  vr_nrcpfcgc      varchar2(11);
  vr_nrdocptl      varchar2(12);
  vr_dtemdptl      varchar2(8);
  vr_cdoedptl      tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
  vr_cdufresd      varchar2(2);
  vr_tpmovmto      number(1);
  vr_cdmovmto      varchar2(2);
  vr_dtcancel      varchar2(8);
  vr_nrtelefo      varchar2(28);
  vr_dsdemail      crapcem.dsdemail%type;
  vr_flgclabe      varchar2(1);
  vr_tab_retorno   lanc0001.typ_reg_retorno;

  -- Objetos para armazenar as variáveis da notificação
  vr_variaveis_notif  NOTI0001.typ_variaveis_notif;

  -- Procedimento para gerar avisos de débito em conta corrente
  procedure gera_avs (pr_cdcooper in crapavs.cdcooper%type,
                      pr_nrdconta in crapavs.nrdconta%type,
                      pr_dtmvtolt in crapavs.dtrefere%type,
                      pr_cdhistor in crapavs.cdhistor%type,
                      pr_cdagenci in crapavs.cdagenci%type,
                      pr_cdsecext in crapavs.cdsecext%type,
                      pr_nrdocmto in crapavs.nrdocmto%type,
                      pr_nrseqdig in crapavs.nrseqdig%type,
                      pr_vllanmto in crapavs.vllanmto%type,
                      pr_cdcritic in out crapcri.cdcritic%type,
                      pr_dscritic in out varchar2) is

    cursor cr_crapavs  (pr_cdcooper in crapavs.cdcooper%type,
                        pr_nrdconta in crapavs.nrdconta%type,
                        pr_dtmvtolt in crapavs.dtrefere%type,
                        pr_cdhistor in crapavs.cdhistor%type,
                        pr_cdagenci in crapavs.cdagenci%type,
                        pr_cdsecext in crapavs.cdsecext%type,
                        pr_nrdocmto in crapavs.nrdocmto%type) is
      select rowid
        from crapavs
       where crapavs.cdcooper = pr_cdcooper
         and crapavs.nrdconta = pr_nrdconta
         and crapavs.dtrefere = pr_dtmvtolt
         and crapavs.cdhistor = pr_cdhistor
         and crapavs.cdempres = 0
         and crapavs.cdagenci = pr_cdagenci
         and crapavs.cdsecext = pr_cdsecext
         and crapavs.dtdebito = pr_dtmvtolt
         and crapavs.nrdocmto = pr_nrdocmto
         and crapavs.tpdaviso = 2;
    rw_crapavs     cr_crapavs%rowtype;
    vr_nrdocmto    number;
  begin
    --Montar Numero Documento
    vr_nrdocmto:= pr_nrdocmto;

    --Loop do documento
    While True Loop
      -- Verifica se já existe aviso para os parâmetros informados
      open cr_crapavs (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt,
                       pr_cdhistor => pr_cdhistor,
                       pr_cdagenci => pr_cdagenci,
                       pr_cdsecext => pr_cdsecext,
                       pr_nrdocmto => vr_nrdocmto);
      fetch cr_crapavs into rw_crapavs;
      if cr_crapavs%notfound then
        -- Fechar Cursor
        close cr_crapavs;
        -- Gera o aviso
        begin
          insert into crapavs
                 (cdagenci,
                  cdempres,
                  cdhistor,
                  cdsecext,
                  dtdebito,
                  dtmvtolt,
                  dtrefere,
                  insitavs,
                  nrdconta,
                  nrdocmto,
                  nrseqdig,
                  tpdaviso,
                  vldebito,
                  vlestdif,
                  vllanmto,
                  flgproce,
                  cdcooper)
          values (pr_cdagenci,
                  0,
                  pr_cdhistor,
                  pr_cdsecext,
                  pr_dtmvtolt,
                  pr_dtmvtolt,
                  pr_dtmvtolt,
                  0,
                  pr_nrdconta,
                  vr_nrdocmto,
                  pr_nrseqdig,
                  2,
                  0,
                  0,
                  pr_vllanmto,
                  0,
                  pr_cdcooper);
          --Sair do Loop
          Exit;
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao incluir aviso de débito: '||sqlerrm;
        end;
      else
        -- Fechar Cursor
        close cr_crapavs;
        --Multiplica documento por 10
        vr_nrdocmto:= vr_nrdocmto * 10;
      end if;
    End Loop;
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS439';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS439',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;
  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;

  -- Buscar informações de reprocesso
  btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              vr_cdcritic,
                              vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;

  IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> TO_CHAR(rw_crapdat.dtmvtopr,'MM') THEN
     vr_dtprdebi := TRUNC(rw_crapdat.dtmvtopr,'MM') - 1;
  ELSE
     vr_dtprdebi := rw_crapdat.dtmvtolt;
  END if;

  --
  -- Gera débito das parcelas normais ou cota única
  FOR rw_crapseg in cr_crapseg (pr_cdcooper => pr_cdcooper
                               ,pr_nrctares => vr_nrctares
                               ,pr_dtmvtolt => vr_dtmvtolt
                               ,pr_dtprdebi => vr_dtprdebi) LOOP
    
    -- Busca informações da seguradora
    open cr_crapcsg (pr_cdcooper,
                     rw_crapseg.cdsegura);
      fetch cr_crapcsg into rw_crapcsg;
      if cr_crapcsg%notfound then
        -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
        close cr_crapcsg;
        vr_cdcritic := 556; -- Plano Inexistente
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        continue;
      end if;
    close cr_crapcsg;
    -- Busca informações de planos de seguros
    open cr_craptsg (pr_cdcooper,
                     rw_crapseg.tpplaseg,
                     rw_crapseg.tpseguro,
                     rw_crapseg.cdsegura);
      fetch cr_craptsg into rw_craptsg;
      if cr_craptsg%notfound then
        -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
        close cr_craptsg;
        vr_cdcritic := 200; -- Plano Inexistente
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        continue;
      end if;
      -- Verifica se o seguro está cancelado
      if rw_crapseg.cdsitseg = 2 and
         -- Verificar data limite de cancelamento
         (rw_crapseg.dtcancel <= to_date(lpad(rw_craptsg.ddcancel,2,'0')||to_char(vr_dtmvtolt, 'mmyyyy'), 'ddmmyyyy')
          OR
          -- ou se foi cancelado no mesmo dia da criação, nestes casos não precisa debitar
          rw_crapseg.dtcancel = rw_crapseg.dtmvtolt  
         ) then
        -- Fecha o cursor e passa ao próximo registro do loop
        close cr_craptsg;
        continue;
      end if;
    close cr_craptsg;

    -- Busca informações do associado
    open cr_crapass (pr_cdcooper,
                     rw_crapseg.nrdconta);
      fetch cr_crapass into rw_crapass;
      if cr_crapass%notfound then
        -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
        close cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Conta: '||gene0002.fn_mask(rw_crapseg.nrdconta, 'zzzz,zzz,9');
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        continue;
      end if;
    close cr_crapass;
    -- Verifica se é parcela única
    if rw_craptsg.flgunica = 1 then
      vr_vlpreseg := rw_crapseg.vlpreseg;
    else
      open cr_crawseg (pr_cdcooper,
                       rw_crapseg.cdsegura,
                       rw_crapseg.nrdconta,
                       rw_crapseg.nrctrseg);
        fetch cr_crawseg into rw_crawseg;
        if cr_crawseg%found then
          if rw_crawseg.vlpreseg <> rw_crapseg.vlpreseg    and
             rw_crapseg.dtinivig >= to_date('10'||to_char(vr_dtmvtolt, 'mmyyyy'), 'ddmmyyyy') then
            vr_vlpreseg := rw_crawseg.vlpreseg;
          else
            vr_vlpreseg := rw_crapseg.vlpreseg;
          end if;
          -- Atualiza informações na CRAWSEG
          begin
            update crawseg
               set crawseg.vlpreseg = rw_crapseg.vlpreseg,
                   crawseg.dtinivig = rw_crapseg.dtinivig,
                   crawseg.tpplaseg = rw_crapseg.tpplaseg
             where crawseg.rowid = rw_crawseg.rowid;
          exception
            when others then
              --fechar cursor
              close cr_crawseg;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAWSEG para a conta '||rw_crapseg.nrdconta||': '||sqlerrm;
              raise vr_exc_saida;
          end;
        end if;
      close cr_crawseg;
    end if;
    -- Debita a diferenca de centavos a mais na ultima parcela
    if rw_craptsg.flgunica = 0 and
       rw_craptsg.inplaseg = 2 and
       rw_crapseg.qtparcel = (rw_crapseg.qtprepag + 1) then
      vr_vlpreseg := rw_crapseg.vlpremio - rw_crapseg.vlprepag;
    end if;
    -- Verifica se o valor do prêmio é negativo ou zero, e descarta o registro
    if vr_vlpreseg <= 0 then
      if vr_vlpreseg < 0   then
        -- Gera mensagem de erro no log e passa ao próximo registro do loop
        vr_cdcritic := 91;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Conta: '||gene0002.fn_mask(rw_crapseg.nrdconta, 'zzzz,zzz,9')||' - Valor: '||gene0002.fn_mask(rw_crapseg.nrdconta, 'zzz,zz9.99-');
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      end if;
      continue;
    end if;

    -- Gera lançamento em depósito a vista
  BEGIN
    vr_lcm_cdhistor := rw_crapcsg.cdhstcas##2;
    vr_lcm_nrdocmto := rw_crapseg.nrctrseg;
    vr_lcm_nrseqdig := nvl(rw_craplot.nrseqdig,0) + 1;
    vr_lcm_vllanmto := vr_vlpreseg;

	  -- REMOCAO LOTE 
    -- APENAS CRIAR LOTE CASO NÃO EXISTA 
		    	
    -- Posiciona a capa de lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
            pr_dtmvtopr => vr_dtmvtolt,
            pr_cdagenci => 1,
            pr_cdbccxlt => 100,
            pr_nrdolote => 4151);
    FETCH cr_craplot
    INTO rw_craplot;

    IF cr_craplot%NOTFOUND THEN
    		
        --Criar lote
        BEGIN
        INSERT INTO craplot
          (craplot.cdcooper
          ,craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.tplotmov
          ,craplot.cdoperad
          ,craplot.cdhistor
          ,craplot.dtmvtopg
          ,craplot.nrseqdig
          ,craplot.qtcompln
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.vlcompdb
          ,craplot.vlinfodb)
        VALUES
          (pr_cdcooper
          ,vr_dtmvtolt
          ,1
          ,100
          ,4151
          ,1
          ,'1'  -- root
          ,rw_crapcsg.cdhstcas##2
          ,vr_dtmvtolt
          ,0  -- craplot.nrseqdig
          ,0  -- craplot.qtcompln
          ,0  -- craplot.qtinfoln
          ,0  -- craplot.vlcompcr
          ,0  -- craplot.vlinfocr
          ,0  -- craplot.vlcompdb
          ,0) -- craplot.vlinfodb
          ;
        EXCEPTION
        WHEN Dup_Val_On_Index THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Lote ja cadastrado.';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
			  vr_dscritic := 'Erro ao inserir na tabela de lotes. ' ||sqlerrm;
          RAISE vr_exc_saida;
        END;
    		
    END IF;

    CLOSE cr_craplot;
        									 
    --debita apenas se qtde de dias devedor < 60
    IF rw_crapseg.qtddsdev < 60 THEN
      -- atribuir sequencia de lancamento
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||pr_cdcooper||';'
                                   ||to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||'1;'
                                   ||'100;'
                                   ||'4151');
                                 
      LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1 --rw_craplot.cdagenci
                                        , pr_cdbccxlt => 100 --rw_craplot.cdbccxlt
                                        , pr_cdhistor => rw_crapcsg.cdhstcas##2 -- Historico para debito
										                    , pr_nrseqdig => vr_nrseqdig
                                        , pr_dtmvtolt => vr_dtmvtolt
                                        , pr_cdpesqbb => to_char(rw_crapseg.cdsegura)
                                        , pr_nrdconta => rw_crapseg.nrdconta
                                        , pr_nrdctabb => rw_crapseg.nrdconta
                                        , pr_nrdctitg => gene0002.fn_mask(rw_crapseg.nrdconta, '99999999')
                                        , pr_nrdocmto => rw_crapseg.nrctrseg
                                        , pr_nrdolote => 4151 --rw_craplot.nrdolote
                                        , pr_cdcooper => pr_cdcooper
                                        , pr_vllanmto => vr_vlpreseg
                                        , pr_inprolot => 0   -- não processa o lote na própria procedure REMOCAO LOTE
                                        , pr_tplotmov => 1
                                        , pr_tab_retorno => vr_tab_retorno
                                        , pr_incrineg => vr_incrineg
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);
    ELSE
      vr_cdcritic := 1134; -- nao foi possivel realizar debito 
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
	  vr_incrineg := 1;
    END IF;

    if vr_cdcritic = 92 then -- se critica = Lançamento já existe, então
     
      -- atribuir sequencia de lancamento
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||pr_cdcooper||';'
                                   ||to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||'1;'
                                   ||'100;'
                                   ||'4151');
                                 
      --- lançar novamente somente incrementando o nr doc
      --- feito isso pois o debitador executa esse programa várias vezes ao dia e se tiver duas parcelas 
      --- atrasadas, pode ocorrer de na segunda execução do dia, debitar a segunda parcela atrasada e nesse caso 
      --- dá o erro.
              LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1 --rw_craplot.cdagenci
                                        , pr_cdbccxlt => 100 --rw_craplot.cdbccxlt
                                        , pr_cdhistor => rw_crapcsg.cdhstcas##2 -- Historico para debito
										                    , pr_nrseqdig => vr_nrseqdig
                                        , pr_dtmvtolt => vr_dtmvtolt
                                        , pr_cdpesqbb => to_char(rw_crapseg.cdsegura)
                                        , pr_nrdconta => rw_crapseg.nrdconta
                                        , pr_nrdctabb => rw_crapseg.nrdconta
                                        , pr_nrdctitg => gene0002.fn_mask(rw_crapseg.nrdconta, '99999999')
                                        , pr_nrdocmto => rw_crapseg.nrctrseg+1
                                        , pr_nrdolote => 4151 --rw_craplot.nrdolote
                                        , pr_cdcooper => pr_cdcooper
                                        , pr_vllanmto => vr_vlpreseg
                                        , pr_inprolot => 0   -- não processa o lote na própria procedure REMOCAO LOTE
                                        , pr_tplotmov => 1
                                        , pr_tab_retorno => vr_tab_retorno
                                        , pr_incrineg => vr_incrineg
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);					
  end if;    
    																
	IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
		IF vr_incrineg = 0 THEN -- Erro de sistema/BD
			RAISE vr_exc_saida;
		ELSE -- Não foi possível debitar (crítica de negócio)
          IF (rw_crapseg.tpseguro = 3) THEN
            vr_dtfimvig := rw_crapdat.dtmvtolt;
          ELSE
            vr_dtfimvig := rw_crapseg.dtfimvig;
          END IF;

          update crapseg
             set crapseg.dtfimvig = vr_dtfimvig, -- Data de fim de vigencia do seguro
                 crapseg.dtcancel = rw_crapdat.dtmvtolt, -- Data de cancelamento
                 crapseg.cdsitseg = 2, -- Situacao do seguro: 2 - Cancelado
                 crapseg.cdmotcan = 12, -- cancelamento por inadimplencia (SEGU0001)
                 crapseg.cdopeexc = 1,
                 crapseg.cdageexc = 1,
                 crapseg.dtinsexc = rw_crapdat.dtmvtolt,
                 crapseg.cdopecnl = 1
           where crapseg.rowid = rw_crapseg.rowid;

          CASE rw_crapseg.tpseguro
            WHEN 1 THEN vr_dsseguro := 'Residencial';
            WHEN 11 THEN vr_dsseguro:= 'Residencial';
            WHEN 2 THEN vr_dsseguro := 'Auto';
            WHEN 3 THEN vr_dsseguro := 'de Vida';
            WHEN 4 THEN vr_dsseguro := 'Prestamista';
            ELSE vr_dsseguro := '';
          END CASE;

          -- gera mensagem de aviso para o cooperado
          GENE0003.pc_gerar_mensagem
								 (pr_cdcooper => pr_cdcooper
								 ,pr_nrdconta => rw_crapseg.nrdconta
								 ,pr_idseqttl => 1          -- Primeiro titular da conta
								 ,pr_cdprogra => 'CRPS439'  -- Programa
								 ,pr_inpriori => 0          -- prioridade
								 ,pr_dsdmensg => 'Cooperado, seu seguro '||vr_dsseguro||' foi cancelado por falta de pagamento. Dúvidas consulte seu posto de atendimento' -- corpo da mensagem
								 ,pr_dsdassun => 'Aviso sobre seu seguro'         -- Assunto
								 ,pr_dsdremet => rw_crapcop.nmrescop --nome cooperativa remetente
								 ,pr_dsdplchv => 'emprestimo'
								 ,pr_cdoperad => 1
								 ,pr_cdcadmsg => 0
								 ,pr_dscritic => vr_dscritic);

          -- gera log do envio da mensagem
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => '1'
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => 'AIMARO' --vr_dsorigem
                              ,pr_dstransa => 'Envio de mensagem de cancelamento de seguro por inadimplencia'
                              ,pr_dttransa => trunc(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'crps439'
                              ,pr_nrdconta => rw_crapseg.nrdconta
                              ,pr_nrdrowid => vr_rowid_log
                              );
                      
          -- cria notificação push
          vr_variaveis_notif('#descseguro') := vr_dsseguro;
       
          NOTI0001.pc_cria_notificacao( pr_cdorigem_mensagem => 8
                                       ,pr_cdmotivo_mensagem => 7
                                       --,pr_dhenvio => SYSDATE   --OPCIONAL: Só passa para agendamento, não precisa passar para SYSDATE
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_crapseg.nrdconta
                                       ,pr_idseqttl => 1        --OPCIONAL: Se não passar a notificação é gerada para todos os titulares/operadores da conta.
                                       ,pr_variaveis => vr_variaveis_notif);

          -- proximo registro
          CONTINUE;
        END IF;
    END IF;													
					
	IF rw_craplot.rowid IS NULL  THEN
		-- Posiciona a capa de lote
		OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
										pr_dtmvtopr => vr_dtmvtolt,
										pr_cdagenci => 1,
										pr_cdbccxlt => 100,
										pr_nrdolote => 4151);
		FETCH cr_craplot
		INTO rw_craplot;

		IF cr_craplot%NOTFOUND THEN
			-- Fechar o cursor pois haverá raise
			CLOSE cr_craplot;
			-- Montar mensagem de crítica
			-- 1172 - Registro de lote não encontrado.
			vr_cdcritic := 1172;
			RAISE vr_exc_saida;
		END IF;
		
		CLOSE cr_craplot;
	END IF;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir lançamento em depósito a vista: '||sqlerrm;
        raise vr_exc_saida;
    end;

    -- Atualizar dados para update da crapseg
    rw_crapseg.vlprepag:= nvl(rw_crapseg.vlprepag,0) + vr_vlpreseg;
    rw_crapseg.qtprepag:= nvl(rw_crapseg.qtprepag,0) + 1;
    rw_crapseg.dtultpag:= vr_dtmvtolt;

    -- So atualiza INDEBITO se nao estiver pagando no mes seg. ao que deveria,
    -- ou se for parcela única, ou se tiver pago todas as parcelas
    if trunc(rw_crapseg.dtdebito, 'mm') = trunc(vr_dtmvtolt, 'mm') or
       (rw_crapseg.dtprideb = vr_dtmvtolt and rw_crapseg.dtprideb <> rw_crapseg.dtdebito) or
       rw_crapseg.flgunica = 1 or
       (rw_crapseg.qtprepag >= rw_crapseg.qtparcel) then
      vr_indebito := 1;
    else
      vr_indebito := 0;
    end if;
    -- Define a data do próximo débito se não for parcela única, se a data atual for anterior a data do movimento e se não for a última parcela
    if rw_crapseg.flgunica = 0 and
       to_number(to_char(rw_crapseg.dtdebito, 'yyyymm')) <= to_number(to_char(vr_dtmvtolt, 'yyyymm')) and
       rw_crapseg.qtprepag < rw_crapseg.qtparcel then
      vr_dtdebito := add_months(rw_crapseg.dtdebito, 1);
    else
      vr_dtdebito := rw_crapseg.dtdebito;
    end if;
    -- Atualiza cadastro do seguro
    begin
      update crapseg
      set  vlprepag = rw_crapseg.vlprepag,
           qtprepag = rw_crapseg.qtprepag,
           dtultpag = rw_crapseg.dtultpag,
           indebito = vr_indebito,
           dtdebito = vr_dtdebito
      where rowid = rw_crapseg.rowid;
    exception
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao atualizar o cadastro do seguro: ' || sqlerrm;
        raise vr_exc_saida;
    end;
    --
    vr_flgeravs := true;

    -- Se possuir controle de restart
    if vr_inrestar <> 0 then
      -- Atualiza controle de reprocesso
      begin
        update crapres
           set crapres.nrdconta = rw_crapseg.nrdconta,
               crapres.dsrestar = to_char(rw_crapseg.nrctrseg)
        where crapres.cdcooper = pr_cdcooper
        and crapres.cdprogra = vr_cdprogra;
        if sql%rowcount = 0 then
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(151);
          --
          raise vr_exc_saida;
        end if;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
          raise vr_exc_saida;
      end;
    end if;
    -- Caso seja necessário, gera avisos de débito em conta corrente
    if vr_flgeravs then
      gera_avs (pr_cdcooper,
                rw_crapseg.nrdconta,
                vr_dtmvtolt,
                vr_lcm_cdhistor,
                rw_crapass.cdagenci,
                rw_crapass.cdsecext,
                vr_lcm_nrdocmto,
                vr_lcm_nrseqdig,
                vr_lcm_vllanmto,
                vr_cdcritic,
                vr_dscritic);
      -- Se houve erro, gera exceção
      if vr_cdcritic <> 0 or
         vr_dscritic is not null then
        raise vr_exc_saida;
      end if;
    end if;
    
  end loop; -- FIM -> Gera debito das parcelas normais ou cota unica

    -- Salvar as informações já processadas
    commit;
  
  -- Busca informações de seguros
  for rw_crapseg2 in cr_crapseg2 (pr_cdcooper,
                                  vr_dtmvtolt) loop
    -- Busca informações do associado
    open cr_crapass (pr_cdcooper,
                     rw_crapseg2.nrdconta);
      fetch cr_crapass into rw_crapass;
      if cr_crapass%notfound then
        -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
        close cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Conta: '||gene0002.fn_mask(rw_crapseg2.nrdconta, 'zzzz,zzz,9');
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        continue;
      end if;
    close cr_crapass;
    -- Se for pessoa física, busca o número da carteira de identidade
    rw_crapttl.nrdocttl := rpad(' ',12,' ');
    if rw_crapass.inpessoa = 1 then
      open cr_crapttl (pr_cdcooper,
                       rw_crapseg2.nrdconta);
        fetch cr_crapttl into rw_crapttl;
      close cr_crapttl;
    end if;
    -- Inicializa variáveis
    vr_tpregist := 0;
    vr_dsendres := ' ';
    vr_nmbairro := ' ';
    vr_dscidduf := ' ';
    vr_nrcepend := 0;
    vr_complend := ' ';
    vr_nrendres := 0;
    -- Busca informações do seguro
    open cr_crawseg (pr_cdcooper,
                     rw_crapseg2.cdsegura,
                     rw_crapseg2.nrdconta,
                     rw_crapseg2.nrctrseg);
      fetch cr_crawseg into rw_crawseg;
      if cr_crawseg%found then
        if rw_crapseg2.dtcancel = vr_dtmvtolt  then
          vr_tpregist := 3; -- Cancelado
        elsif rw_crapseg2.cdsitseg = 1 then
          vr_tpregist := 1; -- Inclusao
        elsif rw_crapseg2.cdsitseg = 3 then
          vr_tpregist := 2; -- Renovado
        end if;
        -- Verifica se existe endereço, e inclui os campos na pl/table
        if trim(rw_crawseg.dsendres) is not null then
          vr_dsendres := trim(rw_crawseg.dsendres);
          vr_nmbairro := rw_crawseg.nmbairro;
          vr_dscidduf := trim(rw_crawseg.nmcidade) || '/' || rw_crawseg.cdufresd;
          vr_nrcepend := rw_crawseg.nrcepend;
          vr_complend := rw_crawseg.complend;
          vr_nrendres := trim(to_char(rw_crawseg.nrendres));
        end if;
      end if;
    close cr_crawseg;
    -- Cria registro na pl/table
    -- O índice vai garantir a ordenação do relatório
    vr_ind_cratseg := to_char(rw_crapseg2.cdsegura, 'fm0000000000')||
                      to_char(rw_crapseg2.dtinivig, 'yyyymmdd')||
                      to_char(vr_tpregist, 'fm0')||
                      to_char(rw_crapseg2.cdagenci, 'fm00000')||
                      to_char(rw_crapseg2.nrdconta, 'fm0000000000')||
                      to_char(rw_crapseg2.nrctrseg, 'fm0000000000')||
                      lpad(cr_crapseg2%rowcount,10,'0');
    --
    vr_cratseg(vr_ind_cratseg).nrdconta := rw_crapseg2.nrdconta;
    vr_cratseg(vr_ind_cratseg).cdsegura := rw_crapseg2.cdsegura;
    vr_cratseg(vr_ind_cratseg).tpplaseg := rw_crapseg2.tpplaseg;
    vr_cratseg(vr_ind_cratseg).cdagenci := rw_crapass.cdagenci;
    vr_cratseg(vr_ind_cratseg).nmprimtl := rw_crapass.nmprimtl;
    vr_cratseg(vr_ind_cratseg).nrctrseg := rw_crapseg2.nrctrseg;
    vr_cratseg(vr_ind_cratseg).vlpreseg := rw_crapseg2.vlpreseg;
    vr_cratseg(vr_ind_cratseg).dtinivig := rw_crapseg2.dtinivig;
    vr_cratseg(vr_ind_cratseg).dtfimvig := rw_crapseg2.dtfimvig;
    vr_cratseg(vr_ind_cratseg).dtcancel := rw_crapseg2.dtcancel;
    vr_cratseg(vr_ind_cratseg).nrcpfcgc := rw_crapass.nrcpfcgc;
    vr_cratseg(vr_ind_cratseg).nrdocptl := rw_crapttl.nrdocttl;
    vr_cratseg(vr_ind_cratseg).cdoedptl := rw_crapass.cdoedptl;
    vr_cratseg(vr_ind_cratseg).dtemdptl := rw_crapass.dtemdptl;
    vr_cratseg(vr_ind_cratseg).dtnasctl := rw_crapass.dtnasctl;
    vr_cratseg(vr_ind_cratseg).cdageseg := rw_crapseg2.cdagenci;
    vr_cratseg(vr_ind_cratseg).cdmotcan := rw_crapseg2.cdmotcan;
    vr_cratseg(vr_ind_cratseg).flgclabe := rw_crapseg2.flgclabe;
    vr_cratseg(vr_ind_cratseg).nmbenvid := rw_crapseg2.nmbenvid##1;
    vr_cratseg(vr_ind_cratseg).tpendcor := rw_crapseg2.tpendcor;
    vr_cratseg(vr_ind_cratseg).tpregist := vr_tpregist;
    vr_cratseg(vr_ind_cratseg).dsendres := gene0007.fn_caract_acento(vr_dsendres);
    vr_cratseg(vr_ind_cratseg).nmbairro := gene0007.fn_caract_acento(vr_nmbairro);
    vr_cratseg(vr_ind_cratseg).nmcidade := gene0007.fn_caract_acento(vr_dscidduf);
    vr_cratseg(vr_ind_cratseg).nrcepend := gene0007.fn_caract_acento(vr_nrcepend);
    vr_cratseg(vr_ind_cratseg).complend := gene0007.fn_caract_acento(vr_complend);
    vr_cratseg(vr_ind_cratseg).nrendres := gene0007.fn_caract_acento(vr_nrendres);
    vr_cratseg(vr_ind_cratseg).inpessoa := rw_crapass.inpessoa;
    vr_cratseg(vr_ind_cratseg).dtprideb := rw_crapseg2.dtprideb;
    vr_cratseg(vr_ind_cratseg).dtdebito := rw_crapseg2.dtdebito;
  end loop;
  -- Busca parâmetro do seguro
  rw_craptab.dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'SEGPRESTAM'
                                                  ,pr_tpregist => 0);

  -- INICIO DA IMPRESSAO DO RELATORIO
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Geração do XML para o crrl416.lst
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<?xml version="1.0" encoding="utf-8"?><crrl416>');
  -- Inicialização das variáveis de controle de quebra
  vr_cdsegura := 0;
  vr_dtinivig := to_date('01011901','ddmmyyyy');
  vr_tpregist := 0;
  -- Inicialização do contador de registros do arquivo TXT
  vr_contareg := 0;
  -- Leitura da PL/Table e geração do arquivo XML
  vr_ind_cratseg := vr_cratseg.first;
  while vr_ind_cratseg is not null loop
    -- Verifica se mudou a seguradora para incluir a quebra
    if vr_cratseg(vr_ind_cratseg).cdsegura <> vr_cdsegura then
      -- Busca o nome da seguradora. Se não encontrar, gera erro e descarta o registro.
      open cr_crapcsg (pr_cdcooper,
                       vr_cratseg(vr_ind_cratseg).cdsegura);
        fetch cr_crapcsg into rw_crapcsg;
        if cr_crapcsg%notfound then
          -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
          close cr_crapcsg;
          vr_cdcritic := 556; -- Plano Inexistente
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratato
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
          continue;
        end if;
      close cr_crapcsg;
      -- Se não era a primeira seguradora, fecha as tags antes de incluir a próxima seguradora
      if vr_cdsegura <> 0 then
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</vigencia_tipo></seguradora>');
      end if;
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<seguradora cdsegura="SEGURADORA: '||lpad(to_char(vr_cratseg(vr_ind_cratseg).cdsegura, 'fm999G999G999'), 11, ' ')||'  -  '||rw_crapcsg.nmsegura||'">');
      -- Define o texto para o tipo de registro e vigência, e inclui no arquivo
      if vr_cratseg(vr_ind_cratseg).tpregist = 1 then
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="NOVAS PROPOSTAS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
      elsif vr_cratseg(vr_ind_cratseg).tpregist = 2 then
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="RENOVADOS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
      elsif vr_cratseg(vr_ind_cratseg).tpregist = 3 then
        gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="CANCELAMENTOS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
      end if;
        -- Atualiza variáveis de controle de quebra
      vr_cdsegura := vr_cratseg(vr_ind_cratseg).cdsegura;
      vr_dtinivig := vr_cratseg(vr_ind_cratseg).dtinivig;
      vr_tpregist := vr_cratseg(vr_ind_cratseg).tpregist;
    else
      -- Verifica se mudou a data ou o tipo para incluir a quebra
      if vr_cratseg(vr_ind_cratseg).dtinivig <> vr_dtinivig or
         vr_cratseg(vr_ind_cratseg).tpregist <> vr_tpregist then
        -- Se não era a primeira data ou tipo, fecha a tag antes de incluir a próxima data ou tipo
        if vr_tpregist <> 0 then
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</vigencia_tipo>');
        end if;
        -- Define o texto para o tipo de registro e vigência, e inclui no arquivo
        if vr_cratseg(vr_ind_cratseg).tpregist = 1 then
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="NOVAS PROPOSTAS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
        elsif vr_cratseg(vr_ind_cratseg).tpregist = 2 then
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="RENOVADOS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
        elsif vr_cratseg(vr_ind_cratseg).tpregist = 3 then
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<vigencia_tipo vigtipo="CANCELAMENTOS: --> INICIO VIGENCIA('||to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'dd/mm/yyyy')||')">');
        end if;
        -- Atualiza variáveis de controle de quebra
        vr_dtinivig := vr_cratseg(vr_ind_cratseg).dtinivig;
        vr_tpregist := vr_cratseg(vr_ind_cratseg).tpregist;
      end if;
    end if;
    -- Final do controle de quebra
    -- Incluir o detalhamento das informações
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,
                   '<seguro>'||
                   '<tpregist>'||vr_cratseg(vr_ind_cratseg).tpregist||'</tpregist>'||
                   '<nrdconta>'||gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta, 'zzzz.zz9.9')||'</nrdconta>'||
                   '<nrctrseg>'||gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrctrseg, 'zzzzzzzzz9')||'</nrctrseg>'||
                   '<tpplaseg>'||gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).tpplaseg, '999')||'</tpplaseg>'||
                   '<cdagenci>'||gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).cdagenci, 'zz9')||'</cdagenci>'||
                   '<cdageseg>'||gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).cdageseg, 'zz9')||'</cdageseg>'||
                   '<nmprimtl>'||substr(vr_cratseg(vr_ind_cratseg).nmprimtl, 1, 40)||'</nmprimtl>'||
                   '<vlpreseg>'||to_char(vr_cratseg(vr_ind_cratseg).vlpreseg, '99G990D00')||'</vlpreseg>');
    if vr_cratseg(vr_ind_cratseg).tpregist <> 3 then
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,
                     '<nrcpfcgc>'||to_char(vr_cratseg(vr_ind_cratseg).nrcpfcgc)||'</nrcpfcgc>'||
                     '<nrdocptl>'||SUBSTR(vr_cratseg(vr_ind_cratseg).nrdocptl,1,15)||'</nrdocptl>'||
                     '<cdoedptl>'||vr_cratseg(vr_ind_cratseg).cdoedptl||'</cdoedptl>'||
                     '<dtnasctl>'||to_char(vr_cratseg(vr_ind_cratseg).dtnasctl, 'dd/mm/yyyy')||'</dtnasctl>'||
                     '<dtemdptl>'||to_char(vr_cratseg(vr_ind_cratseg).dtemdptl, 'dd/mm/yyyy')||'</dtemdptl>'||
                     '<dsendres>'||substr(vr_cratseg(vr_ind_cratseg).dsendres, 1, 60)||'</dsendres>'||
                     '<nmbairro>'||substr(vr_cratseg(vr_ind_cratseg).nmbairro, 1, 15)||'</nmbairro>'||
                     '<nmcidade>'||substr(vr_cratseg(vr_ind_cratseg).nmcidade, 1, 26)||'</nmcidade>'||
                     '<nrcepend>'||vr_cratseg(vr_ind_cratseg).nrcepend||'</nrcepend>'||
                     '<nrendres>'||vr_cratseg(vr_ind_cratseg).nrendres||'</nrendres>');
    end if;
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</seguro>');
    -- Geração de informações para o resumo
    if substr(rw_craptab.dstextab, 85, 2) <> ' ' then
      -- Se for pessoa física, busca o número da carteira de identidade
      if vr_cratseg(vr_ind_cratseg).inpessoa = 1 then
        vr_nrcpfcgc := gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrcpfcgc,'99999999999');
        vr_nrdocptl := rpad(vr_cratseg(vr_ind_cratseg).nrdocptl, 12, ' ');
        vr_dtemdptl := to_char(vr_cratseg(vr_ind_cratseg).dtemdptl,'ddmmyyyy');
        vr_cdoedptl := rpad(nvl(vr_cratseg(vr_ind_cratseg).cdoedptl,' '), 6, ' ');
      else
        vr_nrcpfcgc := rpad('0',11,'0');
        vr_nrdocptl := rpad(' ',12,' ');
        vr_dtemdptl := rpad(' ',8,' ');
        vr_cdoedptl := rpad(' ',6,' ');
      end if;
      --
      vr_cdmovmto := ' ';
      -- Define o tipo de movimento
      if vr_cratseg(vr_ind_cratseg).tpregist = 3 then
        vr_tpmovmto := 2;  -- Cancelamento
        vr_cdmovmto := to_char(vr_cratseg(vr_ind_cratseg).cdmotcan);
      elsif   vr_cratseg(vr_ind_cratseg).tpregist = 2 then
        vr_tpmovmto := 3;  -- Renovacao
      else
        vr_tpmovmto := 1;  -- Inclusao
      end if;
      -- Define a data de cancelamento
      if vr_cratseg(vr_ind_cratseg).dtcancel is not null then
        vr_dtcancel := to_char(vr_cratseg(vr_ind_cratseg).dtcancel, 'ddmmyyyy');
      else
        vr_dtcancel := lpad(' ',8,' ');
      end if;
      -- Busca numero do telefone (Residencial ou Celular)
      open cr_craptfc (pr_cdcooper,
                       vr_cratseg(vr_ind_cratseg).nrdconta);
        fetch cr_craptfc into rw_craptfc;
        if cr_craptfc%found then
          vr_nrtelefo := to_char(rw_craptfc.nrtelefo);
        else
          vr_nrtelefo := ' ';
        end if;
      close cr_craptfc;
      -- Busca endereço de e-mail
      open cr_crapcem (pr_cdcooper,
                       vr_cratseg(vr_ind_cratseg).nrdconta);
        fetch cr_crapcem into rw_crapcem;
        if cr_crapcem%found then
          vr_dsdemail := rw_crapcem.dsdemail;
        else
          vr_dsdemail := ' ';
        end if;
      close cr_crapcem;
      -- Define o endereço de correspondência
      vr_nrcepend := 0;
      vr_nmcidade := ' ';
      vr_nmbairro := ' ';
      vr_cdufresd := ' ';
      vr_dsendres := ' ';
      vr_complend := ' ';
      vr_nrendres := null;
      Case vr_cratseg(vr_ind_cratseg).tpendcor
        When 1 Then
          -- Local do Risco (utilizar o endereço segurado)
          vr_nrcepend := vr_cratseg(vr_ind_cratseg).nrcepend;
          vr_nmcidade := substr(rpad(substr(vr_cratseg(vr_ind_cratseg).nmcidade, 1, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')-1), 20, ' '), 1, 20);
          vr_nmbairro := vr_cratseg(vr_ind_cratseg).nmbairro;
          vr_cdufresd := substr(vr_cratseg(vr_ind_cratseg).nmcidade, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')+1, 2);
          vr_dsendres := vr_cratseg(vr_ind_cratseg).dsendres;
          vr_complend := vr_cratseg(vr_ind_cratseg).complend;
          vr_nrendres := vr_cratseg(vr_ind_cratseg).nrendres;
        When 2 Then
          -- Busca o endereço residencial
          open cr_crapenc (pr_cdcooper,
                           vr_cratseg(vr_ind_cratseg).nrdconta,
                           10);
          fetch cr_crapenc into rw_crapenc;
          if cr_crapenc%found then
            vr_nrcepend := rw_crapenc.nrcepend;
            vr_nmcidade := rw_crapenc.nmcidade;
            vr_nmbairro := rw_crapenc.nmbairro;
            vr_cdufresd := rw_crapenc.cdufende;
            vr_dsendres := rw_crapenc.dsendere;
            vr_complend := rw_crapenc.complend;
            vr_nrendres := rw_crapenc.nrendere;
          end if;
          close cr_crapenc;
        When 3 Then
          -- Busca o endereço comercial
          open cr_crapenc (pr_cdcooper,
                           vr_cratseg(vr_ind_cratseg).nrdconta,
                           9);
          fetch cr_crapenc into rw_crapenc;
          if cr_crapenc%found then
            vr_nrcepend := rw_crapenc.nrcepend;
            vr_nmcidade := rw_crapenc.nmcidade;
            vr_nmbairro := rw_crapenc.nmbairro;
            vr_cdufresd := rw_crapenc.cdufende;
            vr_dsendres := rw_crapenc.dsendere;
            vr_complend := rw_crapenc.complend;
            vr_nrendres := rw_crapenc.nrendere;
          end if;
          close cr_crapenc;
        Else NULL;
      end Case;
      -- Converte o flag de número para texto para incluir no relatório
      if vr_cratseg(vr_ind_cratseg).flgclabe = 1 then
        vr_flgclabe := 'S';
      else
        vr_flgclabe := 'N';
      end if;

      -- Cria a linha de detalhe na pl/table - A primeira linha nesse ponto deve ter indice 2
      IF vr_arquivo.EXISTS(2) THEN
        vr_ind_arquivo := vr_arquivo.last + 1;
      ELSE
         vr_ind_arquivo := 2;
      END IF;

      -- Montar Nome Cidade e sigla do Estado
      IF trim(vr_cratseg(vr_ind_cratseg).nmcidade) IS NOT NULL AND
         length(trim(vr_cratseg(vr_ind_cratseg).nmcidade)) > 2 AND
         instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/') > 0  THEN
        vr_nmcidaux:= rpad(nvl(substr(vr_cratseg(vr_ind_cratseg).nmcidade, 1, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')-1),' '),20,' '); -- cidade
        vr_sigestad:= rpad(nvl(substr(vr_cratseg(vr_ind_cratseg).nmcidade, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')+1,2),' '),2,' ');
      ELSE
        vr_nmcidaux:= rpad(' ',20,' ');
        vr_sigestad:= rpad(' ',2,' ');
      END IF;
      
      IF TRIM(vr_cdmovmto) IS NOT NULL THEN
        vr_cdmovmto := lpad(vr_cdmovmto,2,0);
      ELSE
        vr_cdmovmto := '  '; 
      END IF;
      -- vai incluir as linhas intermediárias do arquivo
      vr_arquivo(vr_ind_arquivo).tpdlinha := 2;
      vr_arquivo(vr_ind_arquivo).dsdlinha := to_char(vr_dtmvtolt, 'ddmmyyyy')||
                                             '0000000001'||
                                             substr(rw_craptab.dstextab,59,25)||
                                             gene0002.fn_mask(vr_tpmovmto,'99')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'999999999999')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrctrseg,'99999999')||
                                             '00'||
                                             '000000000000'||
                                             to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'ddmmyyyy')||
                                             to_char(vr_cratseg(vr_ind_cratseg).dtfimvig, 'ddmmyyyy')||
                                             vr_dtcancel||  -- cancelamento
                                             vr_cdmovmto||
                                             rpad(' ', 19, ' ')||
                                             vr_nrcpfcgc||
                                             rpad(vr_cratseg(vr_ind_cratseg).nmprimtl, 60, ' ')||
                                             to_char(vr_cratseg(vr_ind_cratseg).dtnasctl, 'ddmmyyyy')||
                                             rpad(vr_nrdocptl, 12, ' ')||
                                             vr_dtemdptl||
                                             substr(vr_cdoedptl,1,6)||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'9999999999')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrcepend,'99999999')||
                                             rpad(vr_cratseg(vr_ind_cratseg).dsendres, 50, ' ')||
                                             rpad(vr_cratseg(vr_ind_cratseg).nrendres, 10, ' ')||
                                             rpad(nvl(vr_cratseg(vr_ind_cratseg).nmbairro,' '), 60, ' ')||
                                             vr_nmcidaux||                 -- cidade
                                             vr_sigestad||                 -- uf
                                             rpad(vr_nrtelefo, 10, ' ')||
                                             gene0002.fn_mask(vr_nrcepend,'99999999')||
                                             rpad(gene0007.fn_caract_acento(vr_dsendres), 50, ' ')||
                                             rpad(gene0007.fn_caract_acento(vr_nrendres), 10, ' ')||
                                             rpad(gene0007.fn_caract_acento(nvl(vr_nmbairro,' ')), 60, ' ')||
                                             rpad(gene0007.fn_caract_acento(nvl(vr_nmcidade,' ')), 20, ' ')||   -- cidade
                                             rpad(gene0007.fn_caract_acento(nvl(vr_cdufresd,' ')), 02, ' ')||   -- uf
                                             rpad(gene0007.fn_caract_acento(nvl(vr_nrtelefo,' ')), 10, ' ')||
                                             rpad(gene0007.fn_caract_acento(nvl(vr_dsdemail,' ')), 20, ' ')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'9999999999')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).cdagenci,'999')||
                                             vr_flgclabe||
                                             rpad(vr_cratseg(vr_ind_cratseg).nmbenvid, 200, ' ')||
                                             gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).tpplaseg,'999')||
                                             rpad(vr_cratseg(vr_ind_cratseg).complend, 40, ' ')||
                                             rpad(gene0007.fn_caract_acento(vr_complend), 38,' ');
      -- Ajuste layout --SD243733
      -- se for cancelamento não deve enviar as datas de vencimento das parcelas
      IF trim(vr_dtcancel) IS NOT NULL THEN
        vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                               lpad(' ',96,' ');
      ELSE
        vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                               to_char(vr_cratseg(vr_ind_cratseg).dtprideb, 'ddmmyyyy')|| -- 1º vencimento
                                               to_char(vr_cratseg(vr_ind_cratseg).dtdebito, 'ddmmyyyy');  -- 2º vencimento
        -- calcular demais vencimentos 3º ao 12º
        FOR i IN 1..10 LOOP
          vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                                 to_char(add_months(vr_cratseg(vr_ind_cratseg).dtdebito,i), 'ddmmyyyy');
        END LOOP;
      END IF;
      -- Fim Ajuste layout --SD243733
      -- finalizar linha
      vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||';'||chr(10);
      vr_contareg := vr_contareg + 1;

    end if;
    -- Passa ao próximo registro da pl/table
    vr_ind_cratseg := vr_cratseg.next(vr_ind_cratseg);
  end loop;
  -- Fecha TAGs abertas no XML
  if vr_cdsegura <> 0 then
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</vigencia_tipo></seguradora>');
  end if;
  gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</crrl416>',true);
  -- Verifica se gerou informação no arquivo e se está no batch
  if vr_cdsegura <> 0 AND rw_crapdat.inproces <> 1 then
    -- Geração do relatório
    -- Nome base do arquivo é crrl416
    vr_nom_arquivo := 'crrl416';
    -- Buscar a lista de destinatários
    vr_destinatarios := gene0001.fn_param_sistema('CRED',
                                                  pr_cdcooper,
                                                  'CRRL416_EMAIL');
    -- Nao encontrou destinatarios
    if trim(vr_destinatarios) IS NULL then
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi encontrado parametro CRRL416_EMAIL com email dos destinatarios.';
      raise vr_exc_saida;
    end if;

    -- A solicitação de relatório deve gerar o arquivo LST e copiá-lo para a pasta "salvar",
    -- deve copiar o arquivo crrl416.lst para crrl416.doc e enviar por e-mail, e deve
    -- excluir os arquivos lst e doc originais, mantendo apenas a cópia na pasta "salvar".
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crrl416/seguradora/vigencia_tipo/seguro',      --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl416.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,                   --> Sequencia do relatorio (cabrel 1..5)
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '132col',            --> Nome do formulário para impressão
                                pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                                pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                      pr_cdcooper => pr_cdcooper,
                                                                      pr_nmsubdir => '/salvar'),    --> Diretórios a copiar o relatório
                                pr_dsextcop  => 'lst',               --> Extensão para cópia do relatório aos diretórios
                                pr_dsmailcop => vr_destinatarios,    --> Emails para envio do relatório
                                pr_dsassmail => 'ACOMPANHAMENTO SEGURO CASA '||rw_crapcop.nmrescop,    --> Assunto do e-mail que enviará o relatório
                                pr_fldosmail => 'S',                 --> Conversar anexo para DOS antes de enviar
                                pr_dscmaxmail => ' | tr -d "\032"',  --> Complemento do comando converte-arquivo
                                pr_dsextmail => 'doc',               --> Extensão para envio do relatório
                                pr_flgremarq => 'N',                 --> Flag para remover o arquivo após cópia/email
                                pr_des_erro  => vr_dscritic);        --> Saída com erro
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    -- Testar se houve erro
    if vr_dscritic is not null then
      -- Gerar exceção
      vr_cdcritic := 0;
      raise vr_exc_saida;
    end if;
    -- Se não for da cooperativa 3, gera arquivo texto
    if substr(rw_craptab.dstextab, 85, 2) <> ' ' then
      vr_nrsequen := to_number(substr(rw_craptab.dstextab, 88, 5)) + 1;
      vr_contareg := vr_contareg + 2; -- Header e Trailer
      -- Header
      vr_ind_arquivo := 1; -- vai ser a primeira linha do arquivo
      vr_arquivo(vr_ind_arquivo).tpdlinha := 1;
      vr_arquivo(vr_ind_arquivo).dsdlinha := gene0002.fn_mask(vr_nrsequen, '99999') ||
                                             to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                                             substr(rw_craptab.dstextab, 59, 25) ||
                                             gene0002.fn_mask(vr_contareg, '99999') || chr(10);
      -- Trailer
      vr_ind_arquivo := vr_arquivo.last + 1; -- vai ser a última linha do arquivo
      vr_arquivo(vr_ind_arquivo).tpdlinha := 3;
      vr_arquivo(vr_ind_arquivo).dsdlinha := gene0002.fn_mask(vr_nrsequen, '99999') ||
                                             to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                                             substr(rw_craptab.dstextab, 59, 25) ||
                                             gene0002.fn_mask(vr_contareg, '99999')|| chr(10);
      -- Inicializar o CLOB
      vr_des_xml := null;
      vr_des_txt := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Leitura da pl/table e geração do arquivo texto
      for i in 1..vr_arquivo.last loop
        --Se for a ultima linha
        if i = vr_arquivo.last then
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_arquivo(i).dsdlinha,true);
        else
          gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_arquivo(i).dsdlinha,false);
        end if;
      end loop;
      -- Nome do arquivo
      vr_nom_arquivo := 'RM' ||
                        gene0002.fn_mask(vr_nrsequen, '99999') ||
                        substr(rw_craptab.dstextab, 85, 2) ||
                        to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                        gene0002.fn_mask(vr_contareg, '99999') ||'.txt';
      -- Buscar a lista de destinatários
      vr_destinatarios := gene0001.fn_param_sistema('CRED',
                                                    pr_cdcooper,
                                                    'CRRL416_EMAIL_RESUMO');
      -- Nao encontrou destinatarios
      if trim(vr_destinatarios) IS NULL then
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi encontrado parametro CRRL416_EMAIL_RESUMO com email dos destinatarios.';
        raise vr_exc_saida;
      end if;
      -- Envia o arquivo por e-mail e move para o diretório "salvar"
      gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                          pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                          pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                          pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                          pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                          pr_flg_impri => 'N',                 --> Chamar a impressão (Imprim.p)
                                          pr_flg_gerar => 'N',                 --> Gerar o arquivo na hora
                                          pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                                pr_cdcooper => pr_cdcooper,
                                                                                pr_nmsubdir => '/salvar'),    --> Diretórios a copiar o relatório
                                          pr_dsextcop  => 'txt',               --> Extensão para cópia do relatório aos diretórios
                                          pr_dsmailcop => vr_destinatarios,    --> Emails para envio do relatório
                                          pr_dsassmail => 'ACOMPANHAMENTO SEGURO CASA '||rw_crapcop.nmrescop,    --> Assunto do e-mail que enviará o relatório
                                          pr_dsextmail => 'txt',               --> Extensão para envio do relatório
                                          pr_fldosmail => 'S',                 --> Conversar anexo para DOS antes de enviar
                                          pr_dscmaxmail => ' | tr -d "\032"',  --> Complemento do comando converte-arquivo
                                          pr_flgremarq => 'S',                 --> Flag para remover o arquivo após cópia/email
                                          pr_des_erro  => vr_dscritic);        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      -- Atualiza sequencia (posições 88 a 92 do string)
      begin
        update craptab set craptab.dstextab = substr(craptab.dstextab, 1, 87)||
                           gene0002.fn_mask(vr_nrsequen, '99999')||
                           substr(craptab.dstextab, 93)
        where craptab.cdcooper = pr_cdcooper
        and craptab.nmsistem = 'CRED'
        and craptab.tptabela = 'USUARI'
        and craptab.cdempres = 11
        and craptab.cdacesso = 'SEGPRESTAM'
        and craptab.tpregist = 0;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar sequencia: '||sqlerrm;
          raise vr_exc_saida;
      end;
    end if;
  end if;
  -- Eliminar controle de reprocesso
  btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_dscritic);
  if vr_dscritic is not null then
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --
  commit;
exception
  when vr_exc_fimprg then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    commit;
  when vr_exc_saida then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
END;
/
