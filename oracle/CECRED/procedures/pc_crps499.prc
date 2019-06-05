create or replace procedure cecred.pc_crps499(pr_cdcooper  in craptab.cdcooper%type,
                     pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                     pr_stprogra out pls_integer,            --> Saída de termino da execução
                     pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                     pr_cdcritic out crapcri.cdcritic%type,
                     pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps499 - Antigo Fontes/crps499.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Novembro/2007                   Ultima atualizacao: 05/06/2019

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 39. Rodar no mensal.
               Estatistica lancamentos BB e Bancoob (relatorio 472).

   Alteracoes: 02/04/2008 - Alterado nomes dos labels (Gabriel).

               12/08/2008 - Unificacao dos Bancos incluido cdcooper na busca da
                            tabela crapage(Guilherme).
               27/10/2008 - Acerto informacao devolucao de cheques(BB/Bancoob)
                            Campo Sr.Devolucao(Mirtes)

               26/08/2009 - Substituicao do campo banco/agencia da COMPE,
                            para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                            (Sidnei - Precise).

               15/10/2009 - Incluido tratamento para Banco CECRED
                            crapcop.cdbcoctl (Guilherme/Supero)
               13/05/2010 - Alterar para o formato 234 col. e colocar as colunas
                            SR COBRANCA e NR COBAN ao final. Inserir as colunas
                            NR TED e SR TED, dividindo o NR DOC e SR DOC de
                            acordo com o tpdoctrf (Guilherme/Supero)

               26/05/2010 - Atualizacao dos historicos CECRED (Ze).

               09/06/2010 - Incluido as colunas "NR TEC" e "SR TEC";
                          - Utilizado na NOSSA REMESSA a condicao de banco de
                            envio "cdbcoenv" para listar as informacoes (Elton).

               18/10/2010 - Valores de Dev. invertidos (Trf. 35050) (Ze).

               29/11/2010 - Desconsiderar mensagens rejeitadas na contabilizacao
                            de TED/TEC(SPB) ref. NOSSA REMESSA (Diego).

               21/03/2011 - Nao comparar contas ITG do crapass com do craplcm
                            quando nossa mensageria (Magui).

               07/04/2011 - Melhoria na selecao de CHQ.DEV.SR e endentacao (Ze)

               20/04/2011 - Alterado para rodar na solicitacao 4 e somente na
                            CECRED lendo todas as coop (Adriano).

               26/07/2011 - Nas colunas SR TEC e SR TED buscar todos os
                            lançamentos: automáticos e manuais.
                          - Incluir o histórico 548 na busca dos lançamentos.
                          - Incluir verificaçao do TED para o histórico 548.
                            (Isara - RKAM)

               05/10/2011 - Incluir os historicos 971 e 977 (Cobranca
                            Registrada Sua Remessa) (Ze).

               14/11/2011 - Ajustes no relatorio crrl472. (Rafael).

               16/03/2012 - Criado os forms abaixo onde os quais irao mostrar
                            os dados do bancoob.
                            - f_qtd_totais_bancoob
                            - f_qtd_geral_bancoob
                            - f_vlr_totais_bancoob
                            - f_vlr_geral_bancoob
                            (Adriano).

               03/07/2012 - Incluido email 'flavia@cecred.coop.br' para o envio
                            do relatorio crrl472 (Tiago).

               04/02/2013 - Alterado para gerar o nome do rel.472 com cdcooper
                            ao invés do nmrescop (Lucas).

               30/07/2013 - Incluido campos para GPS nos totais bancoob
                            (Douglas).

               08/11/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               16/01/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
               
               05/05/2014 - Correção na passagem do parâmetro pr_cdccoper na solicitação
                            de relatórios, pois os pdfs (imprim.p) não estavam sendo gerados
                            em cada coop, mas sim na conectada (Marcos-Supero)
														
							 22/05/2015 - Alterado cursores cr_craplcm7 e cr_craplcm12 por
							              cr_crapcob7 e cr_crapcob12 respectivamente, estes
							              agora buscam informações da tabela crapcob e não 
														mais da craplcm. (Reinert)
               
               12/04/2017 - #642388 Inclusão tratamento no cursor da crapcop para que não seja 
                            executado nas cooperativas inativas (Carlos)

               05/06/2019 - Inclusão de Historico 2973 em cursor que busca lancamentos de chequee de deposito - CECRED (Luis Fagundes/AMCOM) 

............................................................................. */
  -- Buscar os dados das cooperativas
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%type) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
      FROM crapcop
     WHERE cdcooper = NVL(pr_cdcooper, cdcooper)
       AND crapcop.flgativo = 1;
  rw_crapcop     cr_crapcop%rowtype ;
  -- Cursores para relatório BANCOOB
  --- NOSSA REMESSA - DOC ---
  cursor cr_craptvl (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select craptvl.cdagenci,
           count(*) qtde,
           sum(craptvl.vldocrcb) valor
      from craptvl
     where craptvl.cdcooper = pr_cdcooper
       and craptvl.tpdoctrf <> 3 -- doc
       and craptvl.cdbcoenv = 756
       and craptvl.dtmvtolt between pr_dtinimes and pr_dtfimmes
     group by craptvl.cdagenci;
  --- SUA REMESSA - DOC/TEC ---
  cursor cr_craplcm (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           craplcm.cdhistor,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (97,519,319,339,445,345,551,548)
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci,
              craplcm.cdhistor;
  --- NOSSA REMESSA - COBRANCA ---
  cursor cr_craptit (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select craptit.cdagenci,
           count(*) qtde,
           sum(craptit.vldpagto) valor
      from craptit
     where craptit.cdcooper = pr_cdcooper
       and craptit.dtdpagto between pr_dtinimes and pr_dtfimmes
       and craptit.cdbcoenv = 756
       and craptit.tpdocmto = 20
       and craptit.intitcop = 0
       and craptit.flgenvio = 1
     group by craptit.cdagenci;
  --- NOSSA REMESSA - COMPE/CHEQUE ---
  cursor cr_crapchd (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapchd.cdagenci,
           count(*) qtde,
           sum(crapchd.vlcheque) valor
      from crapchd
     where crapchd.cdcooper = pr_cdcooper
       and crapchd.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and crapchd.inchqcop = 0
       and crapchd.cdbcoenv = 756
       and crapchd.flgenvio = 1
     group by crapchd.cdagenci;
  --*** SUA REMESSA  - CHEQUE ***
  cursor cr_craplcm2 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (313,340)
       and nvl(craplcm.nrdctitg, ' ') = ' '
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --- NOSSA REMESSA - DEVOLUCAO ---
  cursor cr_craplcm3 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor = 47
       and craplcm.cdbanchq = 756
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --** SUA REMESSA - DEVOLUCAO **
  cursor cr_craplcm4 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (399,24,27,351)
       and craplcm.dsidenti = 'BCB'
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --- GPS ---
  cursor cr_craplot (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select craplot.cdagenci,
           sum(craplot.qtcompln) qtde,
           sum(craplot.vlinfodb) valor
      from craplot
     where craplot.cdcooper = pr_cdcooper
       and craplot.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplot.cdhistor = 582
       and craplot.cdbccxlt = 11
       and craplot.tplotmov = 30
     group by craplot.cdagenci;
  -- Cursores para relatório CECRED
  --- NOSSA REMESSA - DOC ---
  cursor cr_craptvl2 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type,
                      pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select craptvl.cdagenci,
           count(*) qtde,
           sum(craptvl.vldocrcb) valor
      from craptvl
     where craptvl.cdcooper = pr_cdcooper
       and craptvl.tpdoctrf <> 3 -- doc
       and craptvl.cdbcoenv = pr_cdbcoctl
       and craptvl.dtmvtolt between pr_dtinimes and pr_dtfimmes
     group by craptvl.cdagenci;
  --**** NOSSA REMESSA - TED ****
  cursor cr_craptvl3 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type,
                      pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select craptvl.cdagenci,
           craptvl.dtmvtolt,
           craptvl.nrdconta,
           craptvl.idopetrf,
           count(*) qtde,
           sum(craptvl.vldocrcb) valor
      from craptvl
     where craptvl.cdcooper = pr_cdcooper
       and craptvl.tpdoctrf = 3 -- ted
       and craptvl.cdbcoenv = pr_cdbcoctl
       and craptvl.dtmvtolt between pr_dtinimes and pr_dtfimmes
     group by craptvl.cdagenci,
              craptvl.dtmvtolt,
              craptvl.nrdconta,
              craptvl.idopetrf;
  -- Busca mensagens rejeitadas pela cabine
  cursor cr_craplcm5 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtmvtolt in craplcm.dtmvtolt%type,
                      pr_nrdconta in craplcm.nrdconta%type,
                      pr_idopetrf in craplcm.nrdocmto%type) is
    select count(*)
      from craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdhistor = 887
       and craplcm.nrdconta = pr_nrdconta
       and craplcm.nrdocmto = pr_idopetrf
       and rownum = 1;
  --**** NOSSA REMESSA - TEC ****
  cursor cr_craplcs (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type,
                     pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select crapccs.cdagenci,
           craplcs.dtmvtolt,
           craplcs.nrdconta,
           craplcs.idopetrf,
           count(*) qtde,
           sum(craplcs.vllanmto) valor
      from crapccs,
           craplcs
     where craplcs.cdcooper = pr_cdcooper
       and craplcs.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcs.cdhistor = 827
       and crapccs.cdcooper = pr_cdcooper
       and crapccs.nrdconta = craplcs.nrdconta
     group by crapccs.cdagenci,
              craplcs.dtmvtolt,
              craplcs.nrdconta,
              craplcs.idopetrf;
  -- Busca mensagens rejeitadas pela cabine
  cursor cr_craplcs2 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtmvtolt in craplcs.dtmvtolt%type,
                      pr_nrdconta in craplcs.nrdconta%type,
                      pr_idopetrf in craplcs.nrdocmto%type) is
    select count(*)
      from craplcs
     where craplcs.cdcooper = pr_cdcooper
       and craplcs.dtmvtolt = pr_dtmvtolt
       and craplcs.cdhistor = 887
       and craplcs.nrdconta = pr_nrdconta
       and craplcs.nrdocmto = pr_idopetrf
       and rownum = 1;
  --*** SUA REMESSA - DOC/TEC/TED ***
  cursor cr_craplcm6 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           craplcm.cdhistor,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (575,578,799)
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci,
              craplcm.cdhistor;
  --- NOSSA REMESSA - COBRANCA ---
  cursor cr_craptit2 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type,
                      pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select craptit.cdagenci,
           count(*) qtde,
           sum(craptit.vldpagto) valor
      from craptit
     where craptit.cdcooper = pr_cdcooper
       and craptit.dtdpagto between pr_dtinimes and pr_dtfimmes
       and craptit.cdbcoenv = pr_cdbcoctl
       and craptit.tpdocmto = 20
       and craptit.intitcop = 0 -- (0=outros, 1=cooper.)
       and craptit.flgenvio = 1
     group by craptit.cdagenci;
  --- SUA REMESSA - COBRANCA 085 ---
	CURSOR cr_crapcob7 (pr_cdcooper IN crapcop.cdcooper%TYPE,
											pr_dtinimes IN crapdat.dtmvtolt%TYPE,
											pr_dtfimmes IN crapdat.dtmvtolt%TYPE) IS
	SELECT crapass.cdagenci,
				 COUNT(*) qtde,
				 SUM(crapcob.vldpagto) valor
	FROM crapcob 
			,crapass
			,crapcco
	WHERE crapcob.cdcooper = pr_cdcooper
		AND crapcob.dtdpagto >= pr_dtinimes
		AND crapcob.dtdpagto <= pr_dtfimmes
		AND crapcob.indpagto = 0
		AND crapcob.incobran = 5
		AND crapass.cdcooper = crapcob.cdcooper
		AND crapass.nrdconta = crapcob.nrdconta
		AND crapcco.cdcooper = crapcob.cdcooper
		AND crapcco.nrconven = crapcob.nrcnvcob
		AND crapcco.cddbanco = 85 
	GROUP BY crapass.cdagenci;
  --- NOSSA REMESSA - COMPE/CHEQUE ---
  cursor cr_crapchd2 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type,
                      pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select crapchd.cdagenci,
           count(*) qtde,
           sum(crapchd.vlcheque) valor
      from crapchd
     where crapchd.cdcooper = pr_cdcooper
       and crapchd.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and crapchd.inchqcop = 0
       and crapchd.cdbcoenv = pr_cdbcoctl
       and crapchd.flgenvio = 1
     group by crapchd.cdagenci;
  --*** SUA REMESSA  - CHEQUE ***
  cursor cr_craplcm8 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (524,572)
       and nvl(craplcm.nrdctitg, ' ') = ' '
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --- NOSSA REMESSA - DEVOLUCAO ---
  cursor cr_craplcm9 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor = 47
       and craplcm.cdbanchq = 85
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --** SUA REMESSA - DEVOLUCAO **
  cursor cr_craplcm10 (pr_cdcooper in crapcop.cdcooper%type,
                       pr_dtinimes in crapdat.dtmvtolt%type,
                       pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (399,24,27,351,2973)
       and craplcm.dsidenti = 'CTL'
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  -- Cursores para relatório B.BRASIL
  --- NOSSA REMESSA - DOC ---
  cursor cr_craptvl4 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select craptvl.cdagenci,
           count(*) qtde,
           sum(craptvl.vldocrcb) valor
      from craptvl
     where craptvl.cdcooper = pr_cdcooper
       and craptvl.tpdoctrf <> 3 -- doc
       and craptvl.cdbcoenv = 1
       and craptvl.dtmvtolt between pr_dtinimes and pr_dtfimmes
     group by craptvl.cdagenci;
  --**** NOSSA REMESSA - TED ****
  cursor cr_craptvl5 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type,
                      pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select craptvl.cdagenci,
           count(*) qtde,
           sum(craptvl.vldocrcb) valor
      from craptvl
     where craptvl.cdcooper = pr_cdcooper
       and craptvl.tpdoctrf = 3 -- ted
       and craptvl.cdbcoenv <> pr_cdbcoctl
       and craptvl.dtmvtolt between pr_dtinimes and pr_dtfimmes
     group by craptvl.cdagenci;
  --**** NOSSA REMESSA - TEC ****
  cursor cr_craplcs3 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapccs.cdagenci,
           count(*) qtde,
           sum(craplcs.vllanmto) valor
      from crapccs,
           craplcs
     where craplcs.cdcooper = pr_cdcooper
       and craplcs.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcs.cdhistor = 562
       and crapccs.cdcooper = pr_cdcooper
       and crapccs.nrdconta = craplcs.nrdconta
     group by crapccs.cdagenci;
  --*** SUA REMESSA - DOC/TED ***
  cursor cr_craplcm11 (pr_cdcooper in crapcop.cdcooper%type,
                       pr_dtinimes in crapdat.dtmvtolt%type,
                       pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           craplcm.cdhistor,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (651,314)
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci,
              craplcm.cdhistor;
  --- NOSSA REMESSA - COBAN ---
  cursor cr_crapcbb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtinimes in crapdat.dtmvtolt%type,
                     pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapcbb.cdagenci,
           count(*) qtde,
           sum(crapcbb.valorpag) valor
      from crapcbb
     where crapcbb.cdcooper = pr_cdcooper
       and crapcbb.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and crapcbb.flgrgatv = 1
     group by crapcbb.cdagenci;
  --** NOSSA REMESSA - COBRANCA **
  cursor cr_craptit3 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select craptit.cdagenci,
           count(*) qtde,
           sum(craptit.vldpagto) valor
      from craptit
     where craptit.cdcooper = pr_cdcooper
       and craptit.dtdpagto between pr_dtinimes and pr_dtfimmes
       and craptit.cdbcoenv = 1
       and craptit.tpdocmto = 20
       and craptit.intitcop = 0
       and craptit.flgenvio = 1
     group by craptit.cdagenci;
  --** SUA REMESSA - COBRANCA BB **
	CURSOR cr_crapcob12 (pr_cdcooper in crapcop.cdcooper%TYPE,
 											 pr_dtinimes in crapdat.dtmvtolt%TYPE,
											 pr_dtfimmes in crapdat.dtmvtolt%TYPE) IS
	SELECT crapass.cdagenci,
				 COUNT(*) qtde,
				 SUM(crapcob.vldpagto) valor
	FROM crapcob 
			,crapass
			,crapcco
	WHERE crapcob.cdcooper = pr_cdcooper
		AND crapcob.dtdpagto >= pr_dtinimes
		AND crapcob.dtdpagto <= pr_dtfimmes
		AND crapcob.indpagto = 0
		AND crapcob.incobran = 5
		AND crapass.cdcooper = crapcob.cdcooper
		AND crapass.nrdconta = crapcob.nrdconta
		AND crapcco.cdcooper = crapcob.cdcooper
		AND crapcco.nrconven = crapcob.nrcnvcob
		AND crapcco.cddbanco = 1
	GROUP BY crapass.cdagenci;
  --** NOSSA REMESSA - CHEQUE **
  cursor cr_crapchd3 (pr_cdcooper in crapcop.cdcooper%type,
                      pr_dtinimes in crapdat.dtmvtolt%type,
                      pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapchd.cdagenci,
           count(*) qtde,
           sum(crapchd.vlcheque) valor
      from crapchd
     where crapchd.cdcooper = pr_cdcooper
       and crapchd.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and crapchd.inchqcop = 0
       and crapchd.cdbcoenv = 1
       and crapchd.flgenvio = 1
     group by crapchd.cdagenci;
  --*** SUA REMESSA - CHEQUE ***
  cursor cr_craplcm13 (pr_cdcooper in crapcop.cdcooper%type,
                       pr_dtinimes in crapdat.dtmvtolt%type,
                       pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           crapass.nrdctitg,
           craplcm.nrdctabb,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (50,56,59)
       and craplcm.nrdctabb <> 0
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci,
              crapass.nrdctitg,
              craplcm.nrdctabb;
  --- NOSSSA REMESSA - DEVOLUCAO ---
  cursor cr_craplcm14 (pr_cdcooper in crapcop.cdcooper%type,
                       pr_dtinimes in crapdat.dtmvtolt%type,
                       pr_dtfimmes in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor = 47
       and craplcm.cdbanchq = 1
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --*** SUA REMESSA - DEVOLUCAO ***
  cursor cr_craplcm15 (pr_cdcooper in crapcop.cdcooper%type,
                       pr_dtinimes in crapdat.dtmvtolt%type,
                       pr_dtfimmes in crapdat.dtmvtolt%type,
                       pr_cdbcoctl in crapcop.cdbcoctl%type) is
    select crapass.cdagenci,
           count(*) qtde,
           sum(craplcm.vllanmto) valor
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in (351,399,657,24,27)
       and craplcm.dsidenti = 'BB'
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by crapass.cdagenci;
  --
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       clob;
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  vr_nrcopias      number(1) := 1;
  -- Lista de destinatários do e-mail
  vr_destinatarios varchar2(2000);
  -- PL/Table para armazenar os totais por tipo de relatório e agência
  type typ_totais is record (tprelato     number(1),
                             cdagenci     crapage.cdagenci%type,
                             nmcidade     crapage.nmcidade%type,
                             qtd_nossodoc number(6),
                             vlr_nossodoc number(12,2),
                             qtd_seudoc   number(6),
                             vlr_seudoc   number(12,2),
                             qtd_nossoted number(6),
                             vlr_nossoted number(12,2),
                             qtd_seuted   number(6),
                             vlr_seuted   number(12,2),
                             qtd_nossotec number(6),
                             vlr_nossotec number(12,2),
                             qtd_seutec   number(6),
                             vlr_seutec   number(12,2),
                             qtd_noscoban number(6),
                             vlr_noscoban number(12,2),
                             qtd_nossacob number(6),
                             vlr_nossacob number(12,2),
                             qtd_suacob   number(6),
                             vlr_suacob   number(12,2),
                             qtd_nossarem number(6),
                             vlr_nossarem number(12,2),
                             qtd_suacompe number(6),
                             vlr_suacompe number(12,2),
                             qtd_nossadev number(6),
                             vlr_nossadev number(12,2),
                             qtd_suadevol number(6),
                             vlr_suadevol number(12,2),
                             qtd_gpspagas number(6),
                             vlr_gpspagas number(12,2));
  type typ_tab_totais is table of typ_totais index by varchar2(6);
  vr_totais        typ_tab_totais;
  -- O índice da PL/Table é formado pelos campos tprelato e cdagenci
  vr_ind_totais    varchar2(6);
  vr_ind_acumul    varchar2(6);
  -- Tipo do relatório (1 = BANCOOB; 2 = BB; 3 = CECRED)
  vr_tprelato      number(1);
  -- Variável auxiliar para identificar se os cursores retornam registros
  vr_existe        number(1);
  -- Procedimento que cria o registro da pl/table, caso ainda não exista
  procedure cria_pl_totais (pr_cdcooper in crapage.cdcooper%type,
                            pr_tprelato in number,
                            pr_cdagenci in crapage.cdagenci%type) is
    -- Buscar o nome da cidade da agência
    cursor cr_crapage is
      select crapage.nmcidade
        from crapage
       where crapage.cdcooper = pr_cdcooper
         and crapage.cdagenci = pr_cdagenci;
    -- Índice da pl/table
    vr_ind      varchar2(6) := pr_tprelato||to_char(pr_cdagenci, 'fm00000');
  begin
    if not vr_totais.exists(vr_ind) then
      -- Cria campos básicos da pl/table
      vr_totais(vr_ind).tprelato := pr_tprelato;
      vr_totais(vr_ind).cdagenci := pr_cdagenci;
      -- Busca o nome da cidade
      open cr_crapage;
        fetch cr_crapage into vr_totais(vr_ind).nmcidade;
        if cr_crapage%notfound then
          vr_totais(vr_ind).nmcidade := null;
        end if;
      close cr_crapage;
      -- Inicializa campos de valor e quantidade
      vr_totais(vr_ind).qtd_nossodoc := 0;
      vr_totais(vr_ind).vlr_nossodoc := 0;
      vr_totais(vr_ind).qtd_seudoc   := 0;
      vr_totais(vr_ind).vlr_seudoc   := 0;
      vr_totais(vr_ind).qtd_nossoted := 0;
      vr_totais(vr_ind).vlr_nossoted := 0;
      vr_totais(vr_ind).qtd_seuted   := 0;
      vr_totais(vr_ind).vlr_seuted   := 0;
      vr_totais(vr_ind).qtd_nossotec := 0;
      vr_totais(vr_ind).vlr_nossotec := 0;
      vr_totais(vr_ind).qtd_seutec   := 0;
      vr_totais(vr_ind).vlr_seutec   := 0;
      vr_totais(vr_ind).qtd_noscoban := 0;
      vr_totais(vr_ind).vlr_noscoban := 0;
      vr_totais(vr_ind).qtd_nossacob := 0;
      vr_totais(vr_ind).vlr_nossacob := 0;
      vr_totais(vr_ind).qtd_suacob   := 0;
      vr_totais(vr_ind).vlr_suacob   := 0;
      vr_totais(vr_ind).qtd_nossarem := 0;
      vr_totais(vr_ind).vlr_nossarem := 0;
      vr_totais(vr_ind).qtd_suacompe := 0;
      vr_totais(vr_ind).vlr_suacompe := 0;
      vr_totais(vr_ind).qtd_nossadev := 0;
      vr_totais(vr_ind).vlr_nossadev := 0;
      vr_totais(vr_ind).qtd_suadevol := 0;
      vr_totais(vr_ind).vlr_suadevol := 0;
      vr_totais(vr_ind).qtd_gpspagas := 0;
      vr_totais(vr_ind).vlr_gpspagas := 0;
    end if;
  end;
  -- Função que verifica se o último caracter da conta integração
  -- é um número. Se não for, substitui por 0.
  function f_ver_contaitg (pr_nrdctitg in varchar2) return varchar2 is
  begin
    if pr_nrdctitg is null then
      return('0');
    else
      if substr(pr_nrdctitg, length(pr_nrdctitg), 1) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then
        return(pr_nrdctitg);
      else
        return(substr(pr_nrdctitg, 1, length(pr_nrdctitg) - 1) || '0');
      end if;
    end if;
  end;
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2) is
  begin
    dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS499';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS499',
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
  rw_crapcop := null;
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
  -- Leitura das cooperativas
  for rw_crapcop in cr_crapcop (null) loop
    -- Limpa a pl/table
    vr_totais.delete;
    --******************* BANCOOB **************************************
    vr_tprelato := 1;
    --- NOSSA REMESSA - DOC ---
    for rw_craptvl in cr_craptvl (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptvl.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato, rw_craptvl.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossodoc := vr_totais(vr_ind_totais).qtd_nossodoc + rw_craptvl.qtde;
      vr_totais(vr_ind_totais).vlr_nossodoc := vr_totais(vr_ind_totais).vlr_nossodoc + rw_craptvl.valor;
    end loop;
    --*** NAO HA TED e TEC NOSSA REMESSA E TED SUA REMESSA PARA BANCOOB ***
    --*** SUA REMESSA - DOC/TEC ***
    for rw_craplcm in cr_craplcm (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      if rw_craplcm.cdhistor = 519 or
         rw_craplcm.cdhistor = 551 then
        --** TEC **
        vr_totais(vr_ind_totais).qtd_seutec := vr_totais(vr_ind_totais).qtd_seutec + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seutec := vr_totais(vr_ind_totais).vlr_seutec + rw_craplcm.valor;
      elsif rw_craplcm.cdhistor = 548 then
        --** TED **
        vr_totais(vr_ind_totais).qtd_seuted := vr_totais(vr_ind_totais).qtd_seuted + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seuted := vr_totais(vr_ind_totais).vlr_seuted + rw_craplcm.valor;
      else
        --**DOC**
        vr_totais(vr_ind_totais).qtd_seudoc := vr_totais(vr_ind_totais).qtd_seudoc + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seudoc := vr_totais(vr_ind_totais).vlr_seudoc + rw_craplcm.valor;
      end if;
    end loop;
    --- NOSSA REMESSA - COBRANCA ---
    for rw_craptit in cr_craptit (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptit.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptit.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossacob := vr_totais(vr_ind_totais).qtd_nossacob + rw_craptit.qtde;
      vr_totais(vr_ind_totais).vlr_nossacob := vr_totais(vr_ind_totais).vlr_nossacob + rw_craptit.valor;
    end loop;
    --- NOSSA REMESSA - COMPE/CHEQUE ---
    for rw_crapchd in cr_crapchd (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_crapchd.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapchd.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossarem := vr_totais(vr_ind_totais).qtd_nossarem + rw_crapchd.qtde;
      vr_totais(vr_ind_totais).vlr_nossarem := vr_totais(vr_ind_totais).vlr_nossarem + rw_crapchd.valor;
    end loop;
    --*** SUA REMESSA  - CHEQUE ***
    for rw_craplcm in cr_craplcm2 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_suacompe := vr_totais(vr_ind_totais).qtd_suacompe + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_suacompe := vr_totais(vr_ind_totais).vlr_suacompe + rw_craplcm.valor;
    end loop;
    --- NOSSA REMESSA - DEVOLUCAO ---
    for rw_craplcm in cr_craplcm3 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_suadevol := vr_totais(vr_ind_totais).qtd_suadevol + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_suadevol := vr_totais(vr_ind_totais).vlr_suadevol + rw_craplcm.valor;
    end loop;
    --** SUA REMESSA - DEVOLUCAO **
    for rw_craplcm in cr_craplcm4 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossadev := vr_totais(vr_ind_totais).qtd_nossadev + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_nossadev := vr_totais(vr_ind_totais).vlr_nossadev + rw_craplcm.valor;
    end loop;
    --- GPS ---
    for rw_craplot in cr_craplot (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplot.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplot.cdagenci);
      vr_totais(vr_ind_totais).qtd_gpspagas := vr_totais(vr_ind_totais).qtd_gpspagas + rw_craplot.qtde;
      vr_totais(vr_ind_totais).vlr_gpspagas := vr_totais(vr_ind_totais).vlr_gpspagas + rw_craplot.valor;
    end loop;
    --******************** FIM BANCOOB ************************************
    --********************** CECRED  **************************************
    vr_tprelato := 3;
    --- NOSSA REMESSA - DOC ---
    for rw_craptvl in cr_craptvl2 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia,
                                   rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptvl.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptvl.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossodoc := vr_totais(vr_ind_totais).qtd_nossodoc + rw_craptvl.qtde;
      vr_totais(vr_ind_totais).vlr_nossodoc := vr_totais(vr_ind_totais).vlr_nossodoc + rw_craptvl.valor;
    end loop;
    --**** NOSSA REMESSA - TED ****
    for rw_craptvl in cr_craptvl3 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia,
                                   rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptvl.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptvl.cdagenci);
      -- Desconsidera mensagens que foram rejeitadas pela Cabine
      begin
        open cr_craplcm5 (rw_crapcop.cdcooper,
                          rw_craptvl.dtmvtolt,
                          rw_craptvl.nrdconta,
                          to_number(substr(rw_craptvl.idopetrf, length(rw_craptvl.idopetrf) - 7)));
          fetch cr_craplcm5 into vr_existe;
        close cr_craplcm5;
      exception
        when others then
          vr_existe := 0;
      end;
      -- Se não encontrou registro, acumula os valores
      if vr_existe = 0 then
        vr_totais(vr_ind_totais).qtd_nossoted := vr_totais(vr_ind_totais).qtd_nossoted + rw_craptvl.qtde;
        vr_totais(vr_ind_totais).vlr_nossoted := vr_totais(vr_ind_totais).vlr_nossoted + rw_craptvl.valor;
      end if;
    end loop;
    --**** NOSSA REMESSA - TEC ****
    for rw_craplcs in cr_craplcs (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia,
                                  rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcs.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcs.cdagenci);
      -- Desconsidera mensagens que foram rejeitadas pela Cabine
      begin
        open cr_craplcs2 (rw_crapcop.cdcooper,
                          rw_craplcs.dtmvtolt,
                          rw_craplcs.nrdconta,
                          to_number(substr(rw_craplcs.idopetrf, length(rw_craplcs.idopetrf) - 7)));
          fetch cr_craplcs2 into vr_existe;
        close cr_craplcs2;
      exception
        when others then
          vr_existe := 0;
      end;
      -- Se não encontrou registro, acumula os valores
      if vr_existe = 0 then
        vr_totais(vr_ind_totais).qtd_nossotec := vr_totais(vr_ind_totais).qtd_nossotec + rw_craplcs.qtde;
        vr_totais(vr_ind_totais).vlr_nossotec := vr_totais(vr_ind_totais).vlr_nossotec + rw_craplcs.valor;
      end if;
    end loop;
    --*** SUA REMESSA - DOC/TEC/TED ***
    for rw_craplcm in cr_craplcm6 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      if rw_craplcm.cdhistor = 575 then
        --**DOC**
        vr_totais(vr_ind_totais).qtd_seudoc := vr_totais(vr_ind_totais).qtd_seudoc + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seudoc := vr_totais(vr_ind_totais).vlr_seudoc + rw_craplcm.valor;
      elsif rw_craplcm.cdhistor = 799 then
        --** TEC **
        vr_totais(vr_ind_totais).qtd_seutec := vr_totais(vr_ind_totais).qtd_seutec + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seutec := vr_totais(vr_ind_totais).vlr_seutec + rw_craplcm.valor;
      else
        --** TED **
        vr_totais(vr_ind_totais).qtd_seuted := vr_totais(vr_ind_totais).qtd_seuted + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seuted := vr_totais(vr_ind_totais).vlr_seuted + rw_craplcm.valor;
      end if;
    end loop;
    --- NOSSA REMESSA - COBRANCA ---
    for rw_craptit in cr_craptit2 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia,
                                   rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptit.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptit.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossacob := vr_totais(vr_ind_totais).qtd_nossacob + rw_craptit.qtde;
      vr_totais(vr_ind_totais).vlr_nossacob := vr_totais(vr_ind_totais).vlr_nossacob + rw_craptit.valor;
    end loop;
    --- SUA REMESSA - COBRANCA 085 ---
    FOR rw_crapcob in cr_crapcob7 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) LOOP
      vr_ind_totais := vr_tprelato||to_char(rw_crapcob.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapcob.cdagenci);
      vr_totais(vr_ind_totais).qtd_suacob := vr_totais(vr_ind_totais).qtd_suacob + rw_crapcob.qtde;
      vr_totais(vr_ind_totais).vlr_suacob := vr_totais(vr_ind_totais).vlr_suacob + rw_crapcob.valor;
    END LOOP;
    --- NOSSA REMESSA - COMPE/CHEQUE ---
    for rw_crapchd in cr_crapchd2 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia,
                                   rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_crapchd.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapchd.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossarem := vr_totais(vr_ind_totais).qtd_nossarem + rw_crapchd.qtde;
      vr_totais(vr_ind_totais).vlr_nossarem := vr_totais(vr_ind_totais).vlr_nossarem + rw_crapchd.valor;
    end loop;
    --*** SUA REMESSA - CHEQUE ***
    for rw_craplcm in cr_craplcm8 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_suacompe := vr_totais(vr_ind_totais).qtd_suacompe + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_suacompe := vr_totais(vr_ind_totais).vlr_suacompe + rw_craplcm.valor;
    end loop;
    --- NOSSA REMESSA - DEVOLUCAO ---
    for rw_craplcm in cr_craplcm9 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_suadevol := vr_totais(vr_ind_totais).qtd_suadevol + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_suadevol := vr_totais(vr_ind_totais).vlr_suadevol + rw_craplcm.valor;
    end loop;
    --** SUA REMESSA - DEVOLUCAO **
    for rw_craplcm in cr_craplcm10 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossadev := vr_totais(vr_ind_totais).qtd_nossadev + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_nossadev := vr_totais(vr_ind_totais).vlr_nossadev + rw_craplcm.valor;
    end loop;
    --********************* FIM  CECRED *************************************
    --************************* B.BRASIL ************************************
    vr_tprelato := 2;
    --- NOSSA REMESSA - DOC ---
    for rw_craptvl in cr_craptvl4 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptvl.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptvl.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossodoc := vr_totais(vr_ind_totais).qtd_nossodoc + rw_craptvl.qtde;
      vr_totais(vr_ind_totais).vlr_nossodoc := vr_totais(vr_ind_totais).vlr_nossodoc + rw_craptvl.valor;
    end loop;
    --**** NOSSA REMESSA - TED ****
    for rw_craptvl in cr_craptvl5 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia,
                                   rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptvl.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptvl.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossoted := vr_totais(vr_ind_totais).qtd_nossoted + rw_craptvl.qtde;
      vr_totais(vr_ind_totais).vlr_nossoted := vr_totais(vr_ind_totais).vlr_nossoted + rw_craptvl.valor;
    end loop;
    --**** NOSSA REMESSA - TEC ****
    for rw_craplcs in cr_craplcs3 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcs.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcs.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossotec := vr_totais(vr_ind_totais).qtd_nossotec + rw_craplcs.qtde;
      vr_totais(vr_ind_totais).vlr_nossotec := vr_totais(vr_ind_totais).vlr_nossotec + rw_craplcs.valor;
    end loop;
    --*** SUA REMESSA - DOC/TED ***
    for rw_craplcm in cr_craplcm11 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      if rw_craplcm.cdhistor = 651 then
        --** TED **
        vr_totais(vr_ind_totais).qtd_seuted := vr_totais(vr_ind_totais).qtd_seuted + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seuted := vr_totais(vr_ind_totais).vlr_seuted + rw_craplcm.valor;
      else
        --**DOC**
        vr_totais(vr_ind_totais).qtd_seudoc := vr_totais(vr_ind_totais).qtd_seudoc + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_seudoc := vr_totais(vr_ind_totais).vlr_seudoc + rw_craplcm.valor;
      end if;
    end loop;
    --- NOSSA REMESSA - COBAN ---
    for rw_crapcbb in cr_crapcbb (rw_crapcop.cdcooper,
                                  rw_crapdat.dtinimes,
                                  rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_crapcbb.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapcbb.cdagenci);
      vr_totais(vr_ind_totais).qtd_noscoban := vr_totais(vr_ind_totais).qtd_noscoban + rw_crapcbb.qtde;
      vr_totais(vr_ind_totais).vlr_noscoban := vr_totais(vr_ind_totais).vlr_noscoban + rw_crapcbb.valor;
    end loop;
    --** NOSSA REMESSA - COBRANCA **
    for rw_craptit in cr_craptit3 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craptit.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craptit.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossacob := vr_totais(vr_ind_totais).qtd_nossacob + rw_craptit.qtde;
      vr_totais(vr_ind_totais).vlr_nossacob := vr_totais(vr_ind_totais).vlr_nossacob + rw_craptit.valor;
    end loop;
    --- SUA REMESSA - COBRANCA BB ---
    for rw_crapcob in cr_crapcob12 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_crapcob.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapcob.cdagenci);
      vr_totais(vr_ind_totais).qtd_suacob := vr_totais(vr_ind_totais).qtd_suacob + rw_crapcob.qtde;
      vr_totais(vr_ind_totais).vlr_suacob := vr_totais(vr_ind_totais).vlr_suacob + rw_crapcob.valor;
    end loop;
    --** NOSSA REMESSA - CHEQUE **
    for rw_crapchd in cr_crapchd3 (rw_crapcop.cdcooper,
                                   rw_crapdat.dtinimes,
                                   rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_crapchd.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_crapchd.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossarem := vr_totais(vr_ind_totais).qtd_nossarem + rw_crapchd.qtde;
      vr_totais(vr_ind_totais).vlr_nossarem := vr_totais(vr_ind_totais).vlr_nossarem + rw_crapchd.valor;
    end loop;
    --*** SUA REMESSA - CHEQUE ***
    for rw_craplcm in cr_craplcm13 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia) loop
      if rw_craplcm.nrdctabb = f_ver_contaitg(rw_craplcm.nrdctitg) then
        vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
        -- Inclui informações na PL/Table
        cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
        vr_totais(vr_ind_totais).qtd_suacompe := vr_totais(vr_ind_totais).qtd_suacompe + rw_craplcm.qtde;
        vr_totais(vr_ind_totais).vlr_suacompe := vr_totais(vr_ind_totais).vlr_suacompe + rw_craplcm.valor;
      end if;
    end loop;
    --- NOSSSA REMESSA - DEVOLUCAO ---
    for rw_craplcm in cr_craplcm14 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_suadevol := vr_totais(vr_ind_totais).qtd_suadevol + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_suadevol := vr_totais(vr_ind_totais).vlr_suadevol + rw_craplcm.valor;
    end loop;
    --*** SUA REMESSA - DEVOLUCAO ***
    for rw_craplcm in cr_craplcm15 (rw_crapcop.cdcooper,
                                    rw_crapdat.dtinimes,
                                    rw_crapdat.dtultdia,
                                    rw_crapcop.cdbcoctl) loop
      vr_ind_totais := vr_tprelato||to_char(rw_craplcm.cdagenci, 'fm00000');
      -- Inclui informações na PL/Table
      cria_pl_totais(rw_crapcop.cdcooper, vr_tprelato,  rw_craplcm.cdagenci);
      vr_totais(vr_ind_totais).qtd_nossadev := vr_totais(vr_ind_totais).qtd_nossadev + rw_craplcm.qtde;
      vr_totais(vr_ind_totais).vlr_nossadev := vr_totais(vr_ind_totais).vlr_nossadev + rw_craplcm.valor;
    end loop;
    --********************* FIM  B.BRASIL *************************************
    -- Inclui registro zerado para os 3 tipos, pois é necessário gerar
    -- a linha de total no relatório, mesmo que não existam informações.
    cria_pl_totais(rw_crapcop.cdcooper, 1,  0);
    cria_pl_totais(rw_crapcop.cdcooper, 2,  0);
    cria_pl_totais(rw_crapcop.cdcooper, 3,  0);
    -- Faz a leitura da pl/table e acumula o total, agrupando por vr_tprelato,
    -- e colocando o total no registro com agência 0.
    vr_ind_totais := vr_totais.first;
    while vr_ind_totais is not null loop
      vr_ind_acumul := vr_totais(vr_ind_totais).tprelato||'00000';
      vr_totais(vr_ind_acumul).qtd_nossodoc := vr_totais(vr_ind_acumul).qtd_nossodoc + vr_totais(vr_ind_totais).qtd_nossodoc;
      vr_totais(vr_ind_acumul).vlr_nossodoc := vr_totais(vr_ind_acumul).vlr_nossodoc + vr_totais(vr_ind_totais).vlr_nossodoc;
      vr_totais(vr_ind_acumul).qtd_seudoc   := vr_totais(vr_ind_acumul).qtd_seudoc   + vr_totais(vr_ind_totais).qtd_seudoc  ;
      vr_totais(vr_ind_acumul).vlr_seudoc   := vr_totais(vr_ind_acumul).vlr_seudoc   + vr_totais(vr_ind_totais).vlr_seudoc  ;
      vr_totais(vr_ind_acumul).qtd_nossoted := vr_totais(vr_ind_acumul).qtd_nossoted + vr_totais(vr_ind_totais).qtd_nossoted;
      vr_totais(vr_ind_acumul).vlr_nossoted := vr_totais(vr_ind_acumul).vlr_nossoted + vr_totais(vr_ind_totais).vlr_nossoted;
      vr_totais(vr_ind_acumul).qtd_seuted   := vr_totais(vr_ind_acumul).qtd_seuted   + vr_totais(vr_ind_totais).qtd_seuted  ;
      vr_totais(vr_ind_acumul).vlr_seuted   := vr_totais(vr_ind_acumul).vlr_seuted   + vr_totais(vr_ind_totais).vlr_seuted  ;
      vr_totais(vr_ind_acumul).qtd_nossotec := vr_totais(vr_ind_acumul).qtd_nossotec + vr_totais(vr_ind_totais).qtd_nossotec;
      vr_totais(vr_ind_acumul).vlr_nossotec := vr_totais(vr_ind_acumul).vlr_nossotec + vr_totais(vr_ind_totais).vlr_nossotec;
      vr_totais(vr_ind_acumul).qtd_seutec   := vr_totais(vr_ind_acumul).qtd_seutec   + vr_totais(vr_ind_totais).qtd_seutec  ;
      vr_totais(vr_ind_acumul).vlr_seutec   := vr_totais(vr_ind_acumul).vlr_seutec   + vr_totais(vr_ind_totais).vlr_seutec  ;
      vr_totais(vr_ind_acumul).qtd_noscoban := vr_totais(vr_ind_acumul).qtd_noscoban + vr_totais(vr_ind_totais).qtd_noscoban;
      vr_totais(vr_ind_acumul).vlr_noscoban := vr_totais(vr_ind_acumul).vlr_noscoban + vr_totais(vr_ind_totais).vlr_noscoban;
      vr_totais(vr_ind_acumul).qtd_nossacob := vr_totais(vr_ind_acumul).qtd_nossacob + vr_totais(vr_ind_totais).qtd_nossacob;
      vr_totais(vr_ind_acumul).vlr_nossacob := vr_totais(vr_ind_acumul).vlr_nossacob + vr_totais(vr_ind_totais).vlr_nossacob;
      vr_totais(vr_ind_acumul).qtd_suacob   := vr_totais(vr_ind_acumul).qtd_suacob   + vr_totais(vr_ind_totais).qtd_suacob  ;
      vr_totais(vr_ind_acumul).vlr_suacob   := vr_totais(vr_ind_acumul).vlr_suacob   + vr_totais(vr_ind_totais).vlr_suacob  ;
      vr_totais(vr_ind_acumul).qtd_nossarem := vr_totais(vr_ind_acumul).qtd_nossarem + vr_totais(vr_ind_totais).qtd_nossarem;
      vr_totais(vr_ind_acumul).vlr_nossarem := vr_totais(vr_ind_acumul).vlr_nossarem + vr_totais(vr_ind_totais).vlr_nossarem;
      vr_totais(vr_ind_acumul).qtd_suacompe := vr_totais(vr_ind_acumul).qtd_suacompe + vr_totais(vr_ind_totais).qtd_suacompe;
      vr_totais(vr_ind_acumul).vlr_suacompe := vr_totais(vr_ind_acumul).vlr_suacompe + vr_totais(vr_ind_totais).vlr_suacompe;
      vr_totais(vr_ind_acumul).qtd_nossadev := vr_totais(vr_ind_acumul).qtd_nossadev + vr_totais(vr_ind_totais).qtd_nossadev;
      vr_totais(vr_ind_acumul).vlr_nossadev := vr_totais(vr_ind_acumul).vlr_nossadev + vr_totais(vr_ind_totais).vlr_nossadev;
      vr_totais(vr_ind_acumul).qtd_suadevol := vr_totais(vr_ind_acumul).qtd_suadevol + vr_totais(vr_ind_totais).qtd_suadevol;
      vr_totais(vr_ind_acumul).vlr_suadevol := vr_totais(vr_ind_acumul).vlr_suadevol + vr_totais(vr_ind_totais).vlr_suadevol;
      vr_totais(vr_ind_acumul).qtd_gpspagas := vr_totais(vr_ind_acumul).qtd_gpspagas + vr_totais(vr_ind_totais).qtd_gpspagas;
      vr_totais(vr_ind_acumul).vlr_gpspagas := vr_totais(vr_ind_acumul).vlr_gpspagas + vr_totais(vr_ind_totais).vlr_gpspagas;
      vr_ind_totais := vr_totais.next(vr_ind_totais);
    end loop;
    -- Geração do arquivo XML para a cooperativa
    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl472 nmrescop="'||to_char(rw_crapcop.cdcooper, 'fm99') || ' - ' || rw_crapcop.nmrescop||'">');
    -- Veriável para controle de quebra
    vr_tprelato := 0;
    -- Leitura da PL/Table e geração do arquivo XML
    vr_ind_totais := vr_totais.first;
    while vr_ind_totais is not null loop
      -- Verifica se mudou a seguradora para incluir a quebra
      if vr_totais(vr_ind_totais).tprelato <> vr_tprelato then
        -- Se não era a primeira quebra, fecha a tag antes de incluir o próximo tipo
        if vr_tprelato <> 0 then
          pc_escreve_xml('</tipo>');
        end if;
        -- Inclui a descrição do tipo de relatório
        if vr_totais(vr_ind_totais).tprelato = 1 then
          pc_escreve_xml('<tipo tprelato="BANCOOB">');
        elsif vr_totais(vr_ind_totais).tprelato = 2 then
          pc_escreve_xml('<tipo tprelato="B.BRASIL">');
        elsif vr_totais(vr_ind_totais).tprelato = 3 then
          pc_escreve_xml('<tipo tprelato="AILOS">');
        end if;
        -- Inclui os totais (primeiro registro de cada tprelato)
        pc_escreve_xml('<tot_qtd_nossodoc>'||to_char(vr_totais(vr_ind_totais).qtd_nossodoc, 'fm999G990')||'</tot_qtd_nossodoc>'||
                       '<tot_qtd_nossoted>'||to_char(vr_totais(vr_ind_totais).qtd_nossoted, 'fm999G990')||'</tot_qtd_nossoted>'||
                       '<tot_qtd_seudoc  >'||to_char(vr_totais(vr_ind_totais).qtd_seudoc  , 'fm999G990')||'</tot_qtd_seudoc  >'||
                       '<tot_qtd_seuted  >'||to_char(vr_totais(vr_ind_totais).qtd_seuted  , 'fm999G990')||'</tot_qtd_seuted  >'||
                       '<tot_qtd_nossotec>'||to_char(vr_totais(vr_ind_totais).qtd_nossotec, 'fm999G990')||'</tot_qtd_nossotec>'||
                       '<tot_qtd_seutec  >'||to_char(vr_totais(vr_ind_totais).qtd_seutec  , 'fm999G990')||'</tot_qtd_seutec  >'||
                       '<tot_qtd_nossarem>'||to_char(vr_totais(vr_ind_totais).qtd_nossarem, 'fm999G990')||'</tot_qtd_nossarem>'||
                       '<tot_qtd_suacompe>'||to_char(vr_totais(vr_ind_totais).qtd_suacompe, 'fm999G990')||'</tot_qtd_suacompe>'||
                       '<tot_qtd_nossadev>'||to_char(vr_totais(vr_ind_totais).qtd_nossadev, 'fm999G990')||'</tot_qtd_nossadev>'||
                       '<tot_qtd_suadevol>'||to_char(vr_totais(vr_ind_totais).qtd_suadevol, 'fm999G990')||'</tot_qtd_suadevol>'||
                       '<tot_qtd_nossacob>'||to_char(vr_totais(vr_ind_totais).qtd_nossacob, 'fm999G990')||'</tot_qtd_nossacob>'||
                       '<tot_qtd_gpspagas>'||to_char(vr_totais(vr_ind_totais).qtd_gpspagas, 'fm999G990')||'</tot_qtd_gpspagas>'||
                       '<tot_qtd_suacob  >'||to_char(vr_totais(vr_ind_totais).qtd_suacob  , 'fm999G990')||'</tot_qtd_suacob  >'||
                       '<tot_qtd_noscoban>'||to_char(vr_totais(vr_ind_totais).qtd_noscoban, 'fm999G990')||'</tot_qtd_noscoban>'||
                       '<tot_vlr_nossodoc>'||to_char(vr_totais(vr_ind_totais).vlr_nossodoc, 'fm999G999G990D00')||'</tot_vlr_nossodoc>'||
                       '<tot_vlr_nossoted>'||to_char(vr_totais(vr_ind_totais).vlr_nossoted, 'fm999G999G990D00')||'</tot_vlr_nossoted>'||
                       '<tot_vlr_seudoc  >'||to_char(vr_totais(vr_ind_totais).vlr_seudoc  , 'fm999G999G990D00')||'</tot_vlr_seudoc  >'||
                       '<tot_vlr_seuted  >'||to_char(vr_totais(vr_ind_totais).vlr_seuted  , 'fm999G999G990D00')||'</tot_vlr_seuted  >'||
                       '<tot_vlr_nossotec>'||to_char(vr_totais(vr_ind_totais).vlr_nossotec, 'fm999G999G990D00')||'</tot_vlr_nossotec>'||
                       '<tot_vlr_seutec  >'||to_char(vr_totais(vr_ind_totais).vlr_seutec  , 'fm999G999G990D00')||'</tot_vlr_seutec  >'||
                       '<tot_vlr_nossarem>'||to_char(vr_totais(vr_ind_totais).vlr_nossarem, 'fm999G999G990D00')||'</tot_vlr_nossarem>'||
                       '<tot_vlr_suacompe>'||to_char(vr_totais(vr_ind_totais).vlr_suacompe, 'fm999G999G990D00')||'</tot_vlr_suacompe>'||
                       '<tot_vlr_nossadev>'||to_char(vr_totais(vr_ind_totais).vlr_nossadev, 'fm999G999G990D00')||'</tot_vlr_nossadev>'||
                       '<tot_vlr_suadevol>'||to_char(vr_totais(vr_ind_totais).vlr_suadevol, 'fm999G999G990D00')||'</tot_vlr_suadevol>'||
                       '<tot_vlr_nossacob>'||to_char(vr_totais(vr_ind_totais).vlr_nossacob, 'fm999G999G990D00')||'</tot_vlr_nossacob>'||
                       '<tot_vlr_gpspagas>'||to_char(vr_totais(vr_ind_totais).vlr_gpspagas, 'fm999G999G990D00')||'</tot_vlr_gpspagas>'||
                       '<tot_vlr_suacob  >'||to_char(vr_totais(vr_ind_totais).vlr_suacob  , 'fm999G999G990D00')||'</tot_vlr_suacob  >'||
                       '<tot_vlr_noscoban>'||to_char(vr_totais(vr_ind_totais).vlr_noscoban, 'fm999G999G990D00')||'</tot_vlr_noscoban>');
        -- Atualiza variável do controle de quebra
        vr_tprelato := vr_totais(vr_ind_totais).tprelato;
        -- Passa ao próximo registro da pl/table
        vr_ind_totais := vr_totais.next(vr_ind_totais);
        continue;
      end if;
      -- Incluir o detalhamento das informações
      pc_escreve_xml('<agencia cdagenci="'||vr_totais(vr_ind_totais).cdagenci||'">'||
                       '<nmcidade    >'||substr(vr_totais(vr_ind_totais).nmcidade, 1, 13)    ||'</nmcidade    >'||
                       '<qtd_nossodoc>'||to_char(vr_totais(vr_ind_totais).qtd_nossodoc, 'fm999G990')||'</qtd_nossodoc>'||
                       '<qtd_nossoted>'||to_char(vr_totais(vr_ind_totais).qtd_nossoted, 'fm999G990')||'</qtd_nossoted>'||
                       '<qtd_seudoc  >'||to_char(vr_totais(vr_ind_totais).qtd_seudoc  , 'fm999G990')||'</qtd_seudoc  >'||
                       '<qtd_seuted  >'||to_char(vr_totais(vr_ind_totais).qtd_seuted  , 'fm999G990')||'</qtd_seuted  >'||
                       '<qtd_nossotec>'||to_char(vr_totais(vr_ind_totais).qtd_nossotec, 'fm999G990')||'</qtd_nossotec>'||
                       '<qtd_seutec  >'||to_char(vr_totais(vr_ind_totais).qtd_seutec  , 'fm999G990')||'</qtd_seutec  >'||
                       '<qtd_nossarem>'||to_char(vr_totais(vr_ind_totais).qtd_nossarem, 'fm999G990')||'</qtd_nossarem>'||
                       '<qtd_suacompe>'||to_char(vr_totais(vr_ind_totais).qtd_suacompe, 'fm999G990')||'</qtd_suacompe>'||
                       '<qtd_nossadev>'||to_char(vr_totais(vr_ind_totais).qtd_nossadev, 'fm999G990')||'</qtd_nossadev>'||
                       '<qtd_suadevol>'||to_char(vr_totais(vr_ind_totais).qtd_suadevol, 'fm999G990')||'</qtd_suadevol>'||
                       '<qtd_nossacob>'||to_char(vr_totais(vr_ind_totais).qtd_nossacob, 'fm999G990')||'</qtd_nossacob>'||
                       '<qtd_gpspagas>'||to_char(vr_totais(vr_ind_totais).qtd_gpspagas, 'fm999G990')||'</qtd_gpspagas>'||
                       '<qtd_suacob  >'||to_char(vr_totais(vr_ind_totais).qtd_suacob  , 'fm999G990')||'</qtd_suacob  >'||
                       '<qtd_noscoban>'||to_char(vr_totais(vr_ind_totais).qtd_noscoban, 'fm999G990')||'</qtd_noscoban>'||
                       '<vlr_nossodoc>'||to_char(vr_totais(vr_ind_totais).vlr_nossodoc, 'fm999G999G990D00')||'</vlr_nossodoc>'||
                       '<vlr_nossoted>'||to_char(vr_totais(vr_ind_totais).vlr_nossoted, 'fm999G999G990D00')||'</vlr_nossoted>'||
                       '<vlr_seudoc  >'||to_char(vr_totais(vr_ind_totais).vlr_seudoc  , 'fm999G999G990D00')||'</vlr_seudoc  >'||
                       '<vlr_seuted  >'||to_char(vr_totais(vr_ind_totais).vlr_seuted  , 'fm999G999G990D00')||'</vlr_seuted  >'||
                       '<vlr_nossotec>'||to_char(vr_totais(vr_ind_totais).vlr_nossotec, 'fm999G999G990D00')||'</vlr_nossotec>'||
                       '<vlr_seutec  >'||to_char(vr_totais(vr_ind_totais).vlr_seutec  , 'fm999G999G990D00')||'</vlr_seutec  >'||
                       '<vlr_nossarem>'||to_char(vr_totais(vr_ind_totais).vlr_nossarem, 'fm999G999G990D00')||'</vlr_nossarem>'||
                       '<vlr_suacompe>'||to_char(vr_totais(vr_ind_totais).vlr_suacompe, 'fm999G999G990D00')||'</vlr_suacompe>'||
                       '<vlr_nossadev>'||to_char(vr_totais(vr_ind_totais).vlr_nossadev, 'fm999G999G990D00')||'</vlr_nossadev>'||
                       '<vlr_suadevol>'||to_char(vr_totais(vr_ind_totais).vlr_suadevol, 'fm999G999G990D00')||'</vlr_suadevol>'||
                       '<vlr_nossacob>'||to_char(vr_totais(vr_ind_totais).vlr_nossacob, 'fm999G999G990D00')||'</vlr_nossacob>'||
                       '<vlr_gpspagas>'||to_char(vr_totais(vr_ind_totais).vlr_gpspagas, 'fm999G999G990D00')||'</vlr_gpspagas>'||
                       '<vlr_suacob  >'||to_char(vr_totais(vr_ind_totais).vlr_suacob  , 'fm999G999G990D00')||'</vlr_suacob  >'||
                       '<vlr_noscoban>'||to_char(vr_totais(vr_ind_totais).vlr_noscoban, 'fm999G999G990D00')||'</vlr_noscoban>'||
                     '</agencia>');
      vr_ind_totais := vr_totais.next(vr_ind_totais);
    end loop;
    if vr_tprelato <> 0 then
      pc_escreve_xml('</tipo>');
    end if;
    pc_escreve_xml('</crrl472>');
    -- Geração do relatório
    -- Busca do diretório base da cooperativa
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    -- Nome base do arquivo é crrl472
    vr_nom_arquivo := 'crrl472_'||to_char(rw_crapcop.cdcooper)||'.lst';
    -- Buscar a lista de destinatários
    vr_destinatarios := gene0001.fn_param_sistema('CRED',
                                                  rw_crapcop.cdcooper,
                                                  'CRRL472_EMAIL');
    -- A solicitação de relatório deve gerar o arquivo LST e copiá-lo para a pasta "converte",
    -- deve copiar o arquivo crrl416.lst para crrl416.doc e enviar por e-mail, e deve
    -- excluir os arquivos lst e doc originais, mantendo apenas a cópia na pasta "salvar".
    gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper, --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crrl472/tipo',      --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl472.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 234,
                                pr_sqcabrel  => 1,                   --> Sequencia do relatorio (cabrel 1..5)
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '234dh',            --> Nome do formulário para impressão
                                pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                                pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                      pr_cdcooper => rw_crapcop.cdcooper,
                                                                      pr_nmsubdir => '/converte'),    --> Diretórios a copiar o relatório
                                pr_dsextcop  => 'lst',               --> Extensão para cópia do relatório aos diretórios
                                pr_dsmailcop => vr_destinatarios,    --> Emails para envio do relatório
                                pr_dsassmail => 'Estatistica lancamentos BB/Bancoob - '||upper(rw_crapcop.nmrescop),    --> Assunto do e-mail que enviará o relatório
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
  end loop;
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
end;
/
