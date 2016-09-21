CREATE OR REPLACE PROCEDURE CECRED.pc_crps265(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                      ,
                                       pr_flgresta IN PLS_INTEGER --> Flag 0/1 para utilizar restart na chamada
                                      ,
                                       pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                      ,
                                       pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                      ,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,
                                       pr_dscritic OUT VARCHAR2) IS
  --> Texto de erro/critica encontrada
  /* ..........................................................................

     Programa: pc_crps265 (antigo Fontes/crps265.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Edson
     Data    : Maio/99.                            Ultima atualizacao: 02/08/2016

     Dados referentes ao programa:

     Frequencia: Diario (Batch).
     Objetivo  : Emitir boletim de caixa (cash dispenser) (214).
                 Atende solicitacao 2.

     Alteracoes: 19/07/99 - Alterado para chamar a rotina de impressao (Edson).

                 25/01/2000 - Alterado p/chamar a rotina de impressao (Deborah).

                 10/04/2001 - Alterado para listar os saldos dos caixas (Edson).

                 03/06/2002 - Incluir numeros de lacres (Margarete).

                 10/07/2002 - Acerto na leitura do crapbcx (Deborah).

                 26/09/2002 - Alterado para nao imprimir boletim com situacao de
                              cash igual a 5 - INATIVO (Edson).

                 06/11/2002 - Alterado para nao listar os caixas com saldo zerado
                              ha mais de 10 dias (Edson).

                 04/06/2004 - Incluir subtotal por caixas no PAC (Margarete).

                 29/09/2004 - Gravacao de dados na tabela gnsldcx do banco
                              generico, para relatorios gerenciais (Junior).

                 14/12/2004 - Acerto no indice da tabela gnsldcx, para gravacao
                              dos dados dos caixas eletronicos (Junior).

                 01/03/2005 - Imprimir tambem o relatorio 411 (Evandro).

                 09/03/2005 - Ajustes no laytou do relatorio 411 (Edson).

                 24/05/2005 - Gerar relatorio 386 (Evandro).

                 03/06/2005 - Imprimir resumo geral no relatorio 386 (Evandro).

                 21/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 03/10/2005 - Alterado para imprimir apenas 1 copia do relatorio
                              411 para  CredCrea (Diego).

                 30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).

                 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                 03/04/2006 - Corrigir rotina de impressao de relatorios por
                              agencia (Junior).

                 17/05/2006 - Alterado numero de vias do relatorio crrl411
                              para Viacredi (Diego).

                 17/07/2006 - Inicializar variaveis rel_qttot7.. e rel_vltot7..
                              para crrl386 (David).

                 18/12/2006 - Somente listar PAC's ativos (Elton).

                 06/02/2007 - Colocar sinal no campo de saldo final (Edson).

                 19/10/2007 - Incluido campo Situacao do Cash (Gabriel).

                 22/04/2008 - Alterar para novo sistema de CASH - FOTON (Ze).

                 09/06/2008 - Incluído o mecanismo de pesquisa no "find" na
                              tabela CRAPHIS para buscar primeiro pela chave de
                              acesso (craphis.cdcooper = glb_cdcooper) e após
                              pelo código do histórico "craphis.cdhistor".
                            - Kbase IT Solutions - Paulo Ricardo Maciel.

                 01/07/2008 - Ajustados os "finds" que utilizam as tabelas
                              genericas "GN" para que efetue a busca pela
                              variavel "glb_cdcooper".
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                 07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).

                 11/05/2009 - Alteracao CDOPERAD (Kbase).

                 09/09/2009 - Verificar se operador registrado no log esta
                              cadastrado na crapope - NOT AVAIL - (David).

                 02/10/2009 - Aumento do campo nrterfin (Diego).

                 11/06/2010 - Tratamento para o sistema TAA e para nao
                              mostrar PAC 90 e 91 (Evandro).

                 24/08/2010 - Ajuste na verificacao do saldo, nao tratar valor
                              rejeitado separadamente do recolhimento (Evandro).

                 28/10/2010 - Inclusão dos históricos 918(Saque) e 920(Estorno)
                              devido ao TAA compartilhado (Henrique).

                 16/12/2010 - Zerar as variaveis de saque e estorno do TAA
                              compartilhado (Evandro).

                 28/12/2010 - Na verificacao dos saques e estornos, utilizar a
                              cooperativa do terminal (cdcoptfn) (Evandro).

                 28/02/2011 - Tratamento para contabilizar o saldo de TAAs que
                              nao tem movimentacao no dia, para fechar com o
                              saldo contabil (Evandro).

                 13/06/2012 - Eliminar EXTENT vldmovto (Evandro).

                 05/07/2013 - Cnversão Progress >> Oracle PL/SQL (Daniel - Supero)

                 09/08/2013 - Troca da busca do mes por extenso com to_char para
                              utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                 08/10/2013 - Alteração nos tratamentos de critica e saídas
                              de rotinas ( Renato - Supero )

                 05/11/2013 - Ajustes dos padrões ( Marcos - Supero )

                 11/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                            - Alterado totalizador de 99 para 999. (Reinert)

                 05/02/2014 - Ajustes para impressao da data de diferença no
                              dia ( Andrino - RKAM )

                 17/06/2014 - Ajustes para impressao de Operadores cadastrados com letras Maiusculas/Minusculas
                              SD-163013 ( Vanessa Klein )

			     24/09/2014 - Ajustar montagem do XML para tratar caracteres especiais, conforme
						      problema relatado no SoftDesk 204230. (Renato - Supero)

                 02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                              (Jaison/Anderson)

  ............................................................................. */

  -- Calendário
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1 from crapcop where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%rowtype;

  -- Leitura dos terminais financeiros da cooperativa
  cursor cr_craptfn(pr_cdcooper in craptfn.cdcooper%type) is
    select lpad(craptfn.cdagenci, 3, '0') || ' - ' ||
           nvl(crapage.nmresage, 'NAO CADASTRADO') dsagenci,
           decode(crapage.cdccuage,
                  null,
                  null,
                  lpad(crapage.cdccuage, 4, '0')) dscodctb,
           substr(crapope.cdoperad || ' - ' ||
                  nvl(crapope.nmoperad, 'NAO CADASTRADO'),
                  1,
                  40) nmoperad,
           substr('CASH - ' || rpad(crapope.cdoperad, 10, ' ') || '-' ||
                  nvl(crapope.nmoperad, 'NAO CADASTRADO'),
                  1,
                  36) nmoperad2,
           craptfn.nrterfin || ' - ' || upper(craptfn.nmterfin) dsterfin,
           craptfn.cdagenci,
           craptfn.cdoperad,
           craptfn.nrterfin,
           craptfn.nmterfin,
           craptfn.cdsitfin,
           decode(craptfn.cdsitfin,
                  1,
                  'Caixa ABERTO',
                  2,
                  'Caixa FECHADO',
                  3,
                  'Caixa BLOQUEADO',
                  4,
                  'Caixa SUPRIDO',
                  5,
                  'Caixa RECOLHIDO',
                  6,
                  'Caixa DESBLOQUEADO',
                  7,
                  'Caixa EM TRANSPORTE',
                  'Caixa BLOQUEADO') dssitfin,
           craptfn.nrdlacre##1,
           craptfn.nrdlacre##2,
           craptfn.nrdlacre##5,
           craptfn.flsistaa,
           crapage.cdcxaage
      from crapope, crapage, craptfn
     where craptfn.cdcooper = pr_cdcooper
       and craptfn.cdsitfin < 8
       and crapage.cdcooper(+) = craptfn.cdcooper
       and crapage.cdagenci(+) = craptfn.cdagenci
       and crapope.cdcooper(+) = craptfn.cdcooper
       and crapope.cdoperad(+) = craptfn.cdoperad
     order by craptfn.nrterfin;
  -- Leitura do saldo do terminal financeiro na data do movimento
  cursor cr_crapstf(pr_cdcooper in crapstf.cdcooper%type,
                    pr_dtmvtolt in crapstf.dtmvtolt%type,
                    pr_nrterfin in crapstf.nrterfin%type) is
    select nrterfin, dtmvtolt, vldsdini, vldsdfin
      from crapstf
     where cdcooper = pr_cdcooper
       and dtmvtolt = pr_dtmvtolt
       and nrterfin = pr_nrterfin;
  rw_crapstf        cr_crapstf%rowtype;
  rw_crapstf_buffer cr_crapstf%rowtype;
  -- Leitura do saldo do terminal financeiro na data mais recente
  cursor cr_crapstf2(pr_cdcooper in crapstf.cdcooper%type,
                     pr_nrterfin in crapstf.nrterfin%type) is
    select nrterfin, dtmvtolt, vldsdfin
      from crapstf
     where cdcooper = pr_cdcooper
       and nrterfin = pr_nrterfin
       and rownum = 1
     order by dtmvtolt desc;
  rw_crapstf2 cr_crapstf2%rowtype;
  -- Busca informações cadastradas para os históricos
  cursor cr_craphis(pr_cdcooper in craphis.cdcooper%type) is
    select craphis.cdhistor,
           craphis.nrctacrd,
           craphis.nrctadeb,
           craphis.cdhstctb,
           craphis.dshistor
      from craphis
     where craphis.cdcooper = pr_cdcooper
       and craphis.cdhistor in (316, -- SAQUE CARTAO
                                705, -- SUPRIM(CASH E ENTRE CXAS)
                                706, -- RECOLHIM(CASH E ENTRE CXAS)
                                767, -- ESTORNO SAQUE
                                918, -- SAQUE TAA
                                920); -- EST.SAQUE TAA
  -- Busca os lançamentos e valores para cada histórico
  cursor cr_crapltr(pr_cdcooper in crapltr.cdcooper%type,
                    pr_dtmvtolt in crapltr.dtmvtolt%type,
                    pr_nrterfin in crapltr.nrterfin%type) is
    select crapltr.cdhistor,
           sum(crapltr.vllanmto) vllanmto,
           count(crapltr.vllanmto) qtlanmto
      from crapltr
     where crapltr.cdcoptfn = pr_cdcooper
       and crapltr.dtmvtolt = pr_dtmvtolt
       and crapltr.nrterfin = pr_nrterfin
       and crapltr.cdhistor in (316, -- SAQUE CARTAO
                                918) -- SAQUE TAA
     group by crapltr.cdhistor
    union
    select crapltr.cdhistor,
           sum(crapltr.vllanmto) vllanmto,
           count(crapltr.vllanmto) qtlanmto
      from crapltr
     where crapltr.cdcooper = pr_cdcooper
       and crapltr.dtmvtolt = pr_dtmvtolt
       and crapltr.nrterfin = pr_nrterfin
       and crapltr.cdhistor in (767, -- ESTORNO SAQUE
                                920) -- EST.SAQUE TAA
     group by crapltr.cdhistor;
  -- Buscar o total no log de operações do terminal financeiro
  cursor cr_craplfn(pr_cdcooper in craplfn.cdcooper%type,
                    pr_dtmvtolt in craplfn.dtmvtolt%type,
                    pr_nrterfin in craplfn.nrterfin%type) is
    select sum(decode(craplfn.tpdtrans, 4, craplfn.vltransa, 0)) vlsuprim,
           sum(decode(craplfn.tpdtrans, 5, craplfn.vltransa, 0)) vlrecolh
      from craplfn
     where craplfn.cdcooper = pr_cdcooper
       and craplfn.dtmvtolt = pr_dtmvtolt
       and craplfn.nrterfin = pr_nrterfin;
  rw_craplfn cr_craplfn%rowtype;
  -- Buscar o log de operações do terminal financeiro
  cursor cr_craplfn2(pr_cdcooper in craplfn.cdcooper%type,
                     pr_dtmvtolt in craplfn.dtmvtolt%type,
                     pr_nrterfin in craplfn.nrterfin%type) is
    select nvl(crapope.nmoperad, 'NAO CADASTRADO') nmoperad,
           craplfn.cdoperad,
           craplfn.dttransa,
           gene0002.fn_calc_hora(craplfn.hrtransa) hrtransa,
           craplfn.vltransa,
           decode(craplfn.tpdtrans,
                  1,
                  'ABERTURA',
                  2,
                  'FECHAMENTO',
                  3,
                  'BLOQUEIO',
                  4,
                  'SUPRIMENTO',
                  5,
                  'RECOLHIMENTO') dsoperac
      from crapope, craplfn
     where craplfn.cdcooper = pr_cdcooper
       and craplfn.dtmvtolt = pr_dtmvtolt
       and craplfn.nrterfin = pr_nrterfin
       and crapope.cdcooper(+) = craplfn.cdcooper
       and crapope.cdoperad(+) = craplfn.cdoperad
     order by craplfn.cdoperad, craplfn.dttransa, craplfn.hrtransa;
  -- Busca detalhada do saldo do terminal
  cursor cr_crapstd(pr_cdcooper in craplfn.cdcooper%type,
                    pr_dtmvtolt in craplfn.dtmvtolt%type,
                    pr_nrterfin in craplfn.nrterfin%type) is
    select nvl(sum(decode(crapstd.cdhistor, 316, crapstd.vldmovto, 0)), 0) vldmo316,
           nvl(sum(decode(crapstd.cdhistor, 767, crapstd.vldmovto, 0)), 0) vldmo767,
           nvl(sum(decode(crapstd.cdhistor, 918, crapstd.vldmovto, 0)), 0) vldmo918,
           nvl(sum(decode(crapstd.cdhistor, 920, crapstd.vldmovto, 0)), 0) vldmo920
      from crapstd
     where crapstd.cdcooper = pr_cdcooper
       and crapstd.dtmvtolt = pr_dtmvtolt
       and crapstd.nrterfin = pr_nrterfin;
  rw_crapstd cr_crapstd%rowtype;
  -- Saldo dos caixas por PAC
  cursor cr_crapbcx(pr_cdcooper in crapbcx.cdcooper%type,
                    pr_dtmvtolt in crapbcx.dtmvtolt%type) is
    select crapbcx.cdagenci,
           lpad(crapbcx.cdagenci, 3, '0') || ' - ' ||
           nvl(crapage.nmresage, 'NAO CADASTRADO') dsagenci,
           crapbcx.cdopecxa,
           substr(rpad(crapbcx.cdopecxa, 10, ' ') || '-' || nvl(crapope.nmoperad, 'NAO CADASTRADO'),1, 36) nmoperad,
           crapbcx.dtmvtolt,
           crapbcx.nrdcaixa,
           crapbcx.vldsdfin
      from crapope, crapage, crapbcx
     where (crapbcx.cdcooper, crapbcx.dtmvtolt, crapbcx.cdagenci,
            crapbcx.nrdcaixa) in
           (select crapbcx2.cdcooper,
                   max(crapbcx2.dtmvtolt) dtmvtolt,
                   crapbcx2.cdagenci,
                   crapbcx2.nrdcaixa
              from crapbcx crapbcx2
             where crapbcx2.cdcooper = pr_cdcooper
               and crapbcx2.cdagenci not in (90, 91)
             group by crapbcx2.cdcooper,
                      crapbcx2.cdagenci,
                      crapbcx2.nrdcaixa)
       and crapbcx.nrseqdig =
           (select max(crapbcx3.nrseqdig)
              from crapbcx crapbcx3
             where crapbcx3.cdcooper = crapbcx.cdcooper
               and crapbcx3.dtmvtolt = crapbcx.dtmvtolt
               and crapbcx3.cdagenci = crapbcx.cdagenci
               and crapbcx3.nrdcaixa = crapbcx.nrdcaixa)
       and (crapbcx.vldsdfin <> 0 or crapbcx.dtmvtolt >= (pr_dtmvtolt -    10))
       and crapage.cdcooper = crapbcx.cdcooper
       and crapage.cdagenci = crapbcx.cdagenci
       and crapage.insitage in (1,3) -- 1-Ativo ou 3-Temporariamente Indisponivel
       and crapope.cdcooper(+) = crapbcx.cdcooper
       -- Alterado SD 163013
       and upper(crapope.cdoperad(+)) = upper(crapbcx.cdopecxa)
     order by crapbcx.cdagenci, crapbcx.nrdcaixa;
  -- Caixas com diferença na data (crrl411)
  cursor cr_craplcx(pr_cdcooper in craplcx.cdcooper%type,
                    pr_dtmvtolt in craplcx.dtmvtolt%type) is
    select craplcx.cdagenci,
           craplcx.nrdcaixa,
           craplcx.cdhistor,
           craplcx.dtmvtolt,
           craplcx.cdhistor || '-' ||
           nvl(craphis.dshistor, '*** NAO CADASTRADO ***') dshistor,
           craplcx.cdopecxa,
           craplcx.cdopecxa || '-' ||
           nvl(crapope.nmoperad, '*** NAO CADASTRADO ***') nmoperad,
           craplcx.dsdcompl,
           craplcx.vldocmto
      from crapope, craphis, craplcx
     where craplcx.cdcooper = pr_cdcooper
       and craplcx.dtmvtolt = pr_dtmvtolt
       and craplcx.cdhistor in (701, 702, 733, 734)
       and craphis.cdcooper(+) = craplcx.cdcooper
       and craphis.cdhistor(+) = craplcx.cdhistor
       and crapope.cdcooper(+) = craplcx.cdcooper
       and crapope.cdoperad(+) = craplcx.cdopecxa
     order by craplcx.cdagenci, craplcx.nrdcaixa;
  -- Resumo de caixas com diferença na data (crrl411)
  cursor cr_craplcx_resumo(pr_cdcooper in craplcx.cdcooper%type,
                           pr_dtmvtolt in craplcx.dtmvtolt%type) is
    select historicos.cdhistor || '-' ||
           nvl(craphis.dshistor, '*** NAO CADASTRADO ***') dshistor,
           count(craplcx.cdhistor) qtdocmto,
           nvl(sum(craplcx.vldocmto), 0) vldocmto
      from craphis,
           craplcx,
           (select 701 cdhistor
              from dual
            union
            select 702 cdhistor
              from dual
            union
            select 733 cdhistor
              from dual
            union
            select 734 cdhistor
              from dual) historicos
     where craplcx.cdcooper(+) = pr_cdcooper
       and craplcx.dtmvtolt(+) = pr_dtmvtolt
       and craplcx.cdhistor(+) = historicos.cdhistor
       and craphis.cdcooper(+) = pr_cdcooper
       and craphis.cdhistor(+) = historicos.cdhistor
     group by historicos.cdhistor,
              nvl(craphis.dshistor, '*** NAO CADASTRADO ***')
     order by historicos.cdhistor;
  -- Agências com diferença no período (crrl386)
  cursor cr_craplcx_per(pr_cdcooper in craplcx.cdcooper%type,
                        pr_dtiniper in craplcx.dtmvtolt%type,
                        pr_dtfimper in craplcx.dtmvtolt%type) is
    select distinct craplcx.cdagenci
      from craplcx
     where craplcx.cdcooper = pr_cdcooper
       and craplcx.dtmvtolt between pr_dtiniper and pr_dtfimper
       and craplcx.cdhistor in (701, 702, 733, 734)
     order by 1;
  -- Caixas com diferença no período, por PAC (crrl386)
  cursor cr_craplcx_per_pac(pr_cdcooper in craplcx.cdcooper%type,
                            pr_dtiniper in craplcx.dtmvtolt%type,
                            pr_dtfimper in craplcx.dtmvtolt%type,
                            pr_cdagenci in craplcx.cdagenci%type) is
    select craplcx.nrdcaixa,
           craplcx.cdhistor,
           to_char(craplcx.dtmvtolt, 'dd') dia,
           craplcx.cdhistor || '-' ||
           nvl(craphis.dshistor, '*** NAO CADASTRADO ***') dshistor,
           craplcx.cdopecxa,
           craplcx.cdopecxa || '-' ||
           nvl(crapope.nmoperad, '*** NAO CADASTRADO ***') nmoperad,
           craplcx.dsdcompl,
           craplcx.vldocmto
      from crapope, craphis, craplcx
     where craplcx.cdcooper = pr_cdcooper
       and craplcx.dtmvtolt between pr_dtiniper and pr_dtfimper
       and craplcx.cdagenci = pr_cdagenci
       and craplcx.cdhistor in (701, 702, 733, 734)
       and craphis.cdcooper(+) = craplcx.cdcooper
       and craphis.cdhistor(+) = craplcx.cdhistor
       and crapope.cdcooper(+) = craplcx.cdcooper
       and crapope.cdoperad(+) = craplcx.cdopecxa
     order by to_char(craplcx.dtmvtolt, 'dd'),
              craplcx.nrdcaixa,
              craplcx.cdhistor,
              craplcx.vldocmto;
  -- Resumo de caixas com diferença no período por PAC (crrl386)
  cursor cr_craplcx_per_pac_res(pr_cdcooper in craplcx.cdcooper%type,
                                pr_dtiniper in craplcx.dtmvtolt%type,
                                pr_dtfimper in craplcx.dtmvtolt%type,
                                pr_cdagenci in craplcx.cdagenci%type) is
    select historicos.cdhistor || '-' ||
           nvl(craphis.dshistor, '*** NAO CADASTRADO ***') dshistor,
           count(craplcx.cdhistor) qtdocmto,
           nvl(sum(craplcx.vldocmto), 0) vldocmto
      from craphis,
           craplcx,
           (select 701 cdhistor
              from dual
            union
            select 702 cdhistor
              from dual
            union
            select 733 cdhistor
              from dual
            union
            select 734 cdhistor
              from dual) historicos
     where craplcx.cdcooper(+) = pr_cdcooper
       and craplcx.dtmvtolt(+) between pr_dtiniper and pr_dtfimper
       and craplcx.cdagenci(+) = pr_cdagenci
       and craplcx.cdhistor(+) = historicos.cdhistor
       and craphis.cdcooper(+) = pr_cdcooper
       and craphis.cdhistor(+) = historicos.cdhistor
     group by historicos.cdhistor,
              nvl(craphis.dshistor, '*** NAO CADASTRADO ***')
     order by historicos.cdhistor;
  -- Resumo de caixas com diferença no período GERAL (crrl386_99)
  cursor cr_craplcx_per_pac_res2(pr_cdcooper in craplcx.cdcooper%type,
                                 pr_dtiniper in craplcx.dtmvtolt%type,
                                 pr_dtfimper in craplcx.dtmvtolt%type) is
    select historicos.cdhistor || '-' ||
           nvl(craphis.dshistor, '*** NAO CADASTRADO ***') dshistor,
           count(craplcx.cdhistor) qtdocmto,
           nvl(sum(craplcx.vldocmto), 0) vldocmto
      from craphis,
           craplcx,
           (select 701 cdhistor
              from dual
            union
            select 702 cdhistor
              from dual
            union
            select 733 cdhistor
              from dual
            union
            select 734 cdhistor
              from dual) historicos
     where craplcx.cdcooper(+) = pr_cdcooper
       and craplcx.dtmvtolt(+) between pr_dtiniper and pr_dtfimper
       and craplcx.cdhistor(+) = historicos.cdhistor
       and craphis.cdcooper(+) = pr_cdcooper
       and craphis.cdhistor(+) = historicos.cdhistor
     group by historicos.cdhistor,
              nvl(craphis.dshistor, '*** NAO CADASTRADO ***')
     order by historicos.cdhistor;

  -- PL/Table com informações de caixa
  type typ_crawcxa is record(
    vr_cdagenci crapage.cdagenci%type,
    vr_dsagenci varchar2(21),
    vr_cdoperad crapope.cdoperad%type,
    vr_nmoperad varchar2(36),
    vr_vldsdfin crapbcx.vldsdfin%type,
    vr_nrdcaixa crapbcx.nrdcaixa%type,
    vr_dtmvtolt crapbcx.dtmvtolt%type,
    vr_tpdcaixa number(1));
  -- Definição da tabela para armazenar informações de caixa
  type typ_tab_crawcxa is table of typ_crawcxa index by varchar2(11);
  -- Instância da tabela. O índice será o código da agência || tipo caixa || número caixa.
  vr_tab_crawcxa typ_tab_crawcxa;
  -- Variavel para leitura da pl/table
  vr_ind_crawcxa varchar2(11);

  -- Código do programa
  vr_cdprogra crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt crapdat.dtmvtolt%type;
  vr_dtmvtopr crapdat.dtmvtopr%type;
  vr_dtiniper crapdat.dtmvtolt%type;
  -- Variáveis utilizadas no processamento do relatório crrl214
  vr_nrdebsaq  craphis.nrctadeb%type;
  vr_nrcrdsaq  crapage.cdcxaage%type;
  vr_nrhstsaq  craphis.cdhstctb%type;
  vr_nrdebsup  crapage.cdcxaage%type;
  vr_nrcrdsup  craphis.nrctacrd%type;
  vr_nrhstsup  craphis.cdhstctb%type;
  vr_nrdebrec  craphis.nrctadeb%type;
  vr_nrcrdrec  crapage.cdcxaage%type;
  vr_nrhstrec  craphis.cdhstctb%type;
  vr_nrdebest  craphis.nrctadeb%type;
  vr_nrcrdest  crapage.cdcxaage%type;
  vr_nrhstest  craphis.cdhstctb%type;
  vr_dshstest  craphis.dshistor%type;
  vr_nrdebsaqm craphis.nrctadeb%type;
  vr_nrcrdsaqm crapage.cdcxaage%type;
  vr_nrhstsaqm craphis.cdhstctb%type;
  vr_nrdebestm craphis.nrctadeb%type;
  vr_nrcrdestm crapage.cdcxaage%type;
  vr_nrhstestm craphis.cdhstctb%type;
  vr_dshstestm craphis.dshistor%type;
  vr_qtautent  number(10);
  vr_vldsaque  crapltr.vllanmto%type;
  vr_vldestor  crapltr.vllanmto%type;
  vr_vldsaquem crapltr.vllanmto%type;
  vr_vldestorm crapltr.vllanmto%type;
  vr_vlcredit  crapltr.vllanmto%type;
  vr_vldebito  crapltr.vllanmto%type;
  vr_regexist  boolean;

  -- Variável para guardar o texto complementar - Tratamento para relatório
  vr_dsdcompl  VARCHAR2(2000);
  -- Variável para armazenar as informações em XML
  vr_des_xml clob;
  -- Variáveis para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  vr_nrcopias      number(1);
  -- Críticas
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Procedimeto para cópia das informações ao CLOB de dados
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_output    in number default 0) is
  begin
    dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    if pr_output = 1 then
      btch0001.pc_gera_log_batch(1,
                                 1, -- Processo normal
                                 pr_des_dados,
                                 'CRPS265');
    end if;
  end;

  -- Procediemnto para execução do relatório
  PROCEDURE pc_executa_relatorio(pr_dsxmlnode IN VARCHAR2, --> Nó base do XML para leitura dos dados
                                 pr_dsjasper  IN VARCHAR2, --> Arquivo de layout do iReport
                                 pr_sqcabrel  IN NUMBER, --> Sequencia do relatório a ser executado
                                 pr_nrcopias  IN NUMBER) IS --> Número de cópias a serem impressas
  BEGIN
    -- Chamada do iReport para gerar o arquivo de saída
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper, --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra, --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt, --> Data do movimento atual
                                pr_dsxml     => vr_des_xml, --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => pr_dsxmlnode, --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => pr_dsjasper, --> Arquivo de layout do iReport
                                pr_dsparams  => null, --> Enviar como parâmetro apenas a agência
                                pr_dsarqsaid => vr_nom_diretorio || '/' ||
                                                vr_nom_arquivo || '.lst', --> Arquivo final com código da agência
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 80,
                                pr_sqcabrel  => pr_sqcabrel,
                                pr_flg_impri => 'S', --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '80col', --> Nome do formulário para impressão
                                pr_nrcopias  => pr_nrcopias, --> Número de cópias para impressão
                                pr_des_erro  => vr_dscritic); --> Saída com erro
    -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
    IF vr_dscritic IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' --> ' || vr_dscritic);
    END IF;
  END;

BEGIN
  vr_cdprogra := 'CRPS265';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS265',
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1 -- Fixo
                           ,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN
    -- Envio de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat
    into rw_crapdat;
  if btch0001.cr_crapdat%notfound then
    -- Fechar o cursor pois haverá raise
    close btch0001.cr_crapdat;
    vr_cdcritic := 1;
    -- Envio de log de erro
    RAISE vr_exc_saida;
  else
    -- Atribuir a data do movimento
    vr_dtmvtolt := rw_crapdat.dtmvtolt;/*to_date('09/01/2014', 'dd/mm/rrrr');*/
    -- Atribuir a proxima data do movimento
    vr_dtmvtopr := rw_crapdat.dtmvtopr;
  end if;
  close btch0001.cr_crapdat;

  -- Buscar os dados da cooperativa
  open cr_crapcop(pr_cdcooper);
  fetch cr_crapcop
    into rw_crapcop;
  if cr_crapcop%notfound then
    close cr_crapcop;
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  end if;
  close cr_crapcop;
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  --
  -- EMISSÃO DO RELATÓRIO CRRL214
  --
  -- Nome base do arquivo é crrl214
  vr_nom_arquivo := 'crrl214';
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps265>');
  -- Leitura dos terminais financeiros da cooperativa
  for rw_craptfn in cr_craptfn(pr_cdcooper) loop
    -- Inicializa variáveis
    vr_qtautent := 0;
    vr_vlcredit := 0;
    vr_vldebito := 0;
    --
    vr_nrdebsaq := 0;
    vr_nrcrdsaq := 0;
    vr_nrhstsaq := 0;
    --
    vr_nrdebsup := 0;
    vr_nrcrdsup := 0;
    vr_nrhstsup := 0;
    --
    vr_nrdebrec := 0;
    vr_nrcrdrec := 0;
    vr_nrhstrec := 0;
    --
    vr_nrdebest := 0;
    vr_nrcrdest := 0;
    vr_nrhstest := 0;
    vr_dshstest := 0;
    --
    vr_nrdebsaqm := 0;
    vr_nrcrdsaqm := 0;
    vr_nrhstsaqm := 0;
    --
    vr_nrdebestm := 0;
    vr_nrcrdestm := 0;
    vr_nrhstestm := 0;
    vr_dshstestm := 0;
    --
    vr_vldsaque  := 0;
    vr_vldestor  := 0;
    vr_vldsaquem := 0;
    vr_vldestorm := 0;
    -- Busca o saldo do terminal financeiro
    open cr_crapstf(pr_cdcooper, vr_dtmvtolt, rw_craptfn.nrterfin);
    fetch cr_crapstf
      into rw_crapstf;
    if cr_crapstf%notfound then
      -- Não existe o saldo no dia.
      pc_escreve_xml('<terminal nrterfin="' || rw_craptfn.nrterfin || '">' ||
                     '<movimento>*** TAA ' || rw_craptfn.nrterfin ||
                     ' - SEM MOVIMENTACAO ***</movimento>' ||
                     '</terminal>');
      -- Criar o registro com o valor do saldo anterior para fechar com o saldo contabil
      open cr_crapstf2(pr_cdcooper, rw_craptfn.nrterfin);
      fetch cr_crapstf2
        into rw_crapstf2;
      if cr_crapstf2%found then
        -- Inserir na PL/Table
        vr_ind_crawcxa := lpad(rw_craptfn.cdagenci, 5, '0') || '2' ||
                          lpad(rw_crapstf2.nrterfin, 5, '0');
        vr_tab_crawcxa(vr_ind_crawcxa).vr_tpdcaixa := 2;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_cdagenci := rw_craptfn.cdagenci;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_dsagenci := rw_craptfn.dsagenci;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_cdoperad := rw_craptfn.cdoperad;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_nmoperad := rw_craptfn.nmoperad2;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_nrdcaixa := rw_crapstf2.nrterfin;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_vldsdfin := rw_crapstf2.vldsdfin;
        vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt := rw_crapstf2.dtmvtolt;
      end if;
      close cr_crapstf2;
      close cr_crapstf;
      continue;
    end if;
    close cr_crapstf;
    -- Leitura dos dados dos históricos
    for rw_craphis in cr_craphis(pr_cdcooper) loop
      if rw_craphis.cdhistor = 316 then
        vr_nrdebsaq := rw_craphis.nrctadeb;
        vr_nrcrdsaq := rw_craptfn.cdcxaage;
        vr_nrhstsaq := rw_craphis.cdhstctb;
      elsif rw_craphis.cdhistor = 705 then
        vr_nrdebsup := rw_craptfn.cdcxaage;
        vr_nrcrdsup := rw_craphis.nrctacrd;
        vr_nrhstsup := rw_craphis.cdhstctb;
      elsif rw_craphis.cdhistor = 706 then
        vr_nrdebrec := rw_craphis.nrctadeb;
        vr_nrcrdrec := rw_craptfn.cdcxaage;
        vr_nrhstrec := rw_craphis.cdhstctb;
      elsif rw_craphis.cdhistor = 767 then
        vr_nrdebest := rw_craphis.nrctadeb;
        vr_nrcrdest := rw_craptfn.cdcxaage;
        vr_nrhstest := rw_craphis.cdhstctb;
        vr_dshstest := rw_craphis.dshistor;
      elsif rw_craphis.cdhistor = 918 then
        vr_nrdebsaqm := rw_craphis.nrctadeb;
        vr_nrcrdsaqm := rw_craptfn.cdcxaage;
        vr_nrhstsaqm := rw_craphis.cdhstctb;
      elsif rw_craphis.cdhistor = 920 then
        vr_nrdebestm := rw_craphis.nrctadeb;
        vr_nrcrdestm := rw_craptfn.cdcxaage;
        vr_nrhstestm := rw_craphis.cdhstctb;
        vr_dshstestm := rw_craphis.dshistor;
      end if;
    end loop;
    -- Leitura dos lançamentos do terminal
    for rw_crapltr in cr_crapltr(pr_cdcooper,
                                 vr_dtmvtolt,
                                 rw_craptfn.nrterfin) loop
      -- A quantidade de lançamentos é independente do histórico
      vr_qtautent := vr_qtautent + rw_crapltr.qtlanmto;
      --
      if rw_crapltr.cdhistor = 316 then
        vr_vldsaque := rw_crapltr.vllanmto;
      elsif rw_crapltr.cdhistor = 767 then
        vr_vldestor := rw_crapltr.vllanmto;
      elsif rw_crapltr.cdhistor = 918 then
        vr_vldsaquem := rw_crapltr.vllanmto;
      elsif rw_crapltr.cdhistor = 920 then
        vr_vldestorm := rw_crapltr.vllanmto;
      end if;
    end loop;
    -- Leitura dos logs de operações do terminal financeiro
    open cr_craplfn(pr_cdcooper, vr_dtmvtolt, rw_craptfn.nrterfin);
    fetch cr_craplfn
      into rw_craplfn;
    close cr_craplfn;
    -- Sumarizar créditos e débitos
    vr_vlcredit := vr_vlcredit + nvl(rw_craplfn.vlsuprim, 0) +
                   nvl(vr_vldestor, 0) + nvl(vr_vldestorm, 0);
    vr_vldebito := vr_vldebito + nvl(rw_craplfn.vlrecolh, 0) +
                   nvl(vr_vldsaque, 0) + nvl(vr_vldsaquem, 0);
    -- Incluir no arquivo XML as informações do terminal
    pc_escreve_xml('<terminal nrterfin="' || rw_craptfn.nrterfin || '">' ||
                   -- CABEÇALHO
                   '<movimento>S</movimento>' || '<dtmvtolt>' ||
                   to_char(rw_crapstf.dtmvtolt, 'dd/mm/yyyy') ||
                   '</dtmvtolt>' || '<dsterfin>' || rw_craptfn.dsterfin ||
                   '</dsterfin>' || '<dsagenci>' || rw_craptfn.dsagenci ||
                   '</dsagenci>' || '<dscodctb>' || rw_craptfn.dscodctb ||
                   '</dscodctb>' || '<qtautent>' || vr_qtautent ||
                   '</qtautent>' || '<nrdlacre1>' ||
                   rw_craptfn.nrdlacre##1 || '</nrdlacre1>' ||
                   '<nrdlacre2>' || rw_craptfn.nrdlacre##2 ||
                   '</nrdlacre2>' || '<nrdlacre5>' ||
                   rw_craptfn.nrdlacre##5 || '</nrdlacre5>' ||
                   '<nmoperad>' || rw_craptfn.nmoperad || '</nmoperad>' ||
                   '<dssitfin>' || rw_craptfn.dssitfin || '</dssitfin>' ||
                   '<vldsdini>' ||
                   to_char(nvl(rw_crapstf.vldsdini, 0), 'fm99G999G990d00') ||
                   '</vldsdini>' || '<vldsdfin>' ||
                   to_char(nvl(rw_crapstf.vldsdfin, 0), 'fm99G999G990d00') ||
                   '</vldsdfin>' ||
                   -- ENTRADAS
                   '<nrdebsup>' || lpad(vr_nrdebsup, 4, '0') ||
                   '</nrdebsup>' || '<nrcrdsup>' ||
                   lpad(vr_nrcrdsup, 4, '0') || '</nrcrdsup>' ||
                   '<nrhstsup>' || lpad(vr_nrhstsup, 4, '0') ||
                   '</nrhstsup>' || '<vlsuprim>' ||
                   to_char(nvl(rw_craplfn.vlsuprim, 0), 'fm99G999G990d00') ||
                   '</vlsuprim>' || '<dshstest>' || vr_dshstest ||
                   '</dshstest>' || '<nrdebest>' ||
                   lpad(vr_nrdebest, 4, '0') || '</nrdebest>' ||
                   '<nrcrdest>' || lpad(vr_nrcrdest, 4, '0') ||
                   '</nrcrdest>' || '<nrhstest>' ||
                   lpad(vr_nrhstest, 4, '0') || '</nrhstest>' ||
                   '<vldestor>' ||
                   to_char(nvl(vr_vldestor, 0), 'fm99G999G990d00') ||
                   '</vldestor>' || '<dshstestm>' || vr_dshstestm ||
                   '</dshstestm>' || '<nrdebestm>' ||
                   lpad(vr_nrdebestm, 4, '0') || '</nrdebestm>' ||
                   '<nrcrdestm>' || lpad(vr_nrcrdestm, 4, '0') ||
                   '</nrcrdestm>' || '<nrhstestm>' ||
                   lpad(vr_nrhstestm, 4, '0') || '</nrhstestm>' ||
                   '<vldestorm>' ||
                   to_char(nvl(vr_vldestorm, 0), 'fm99G999G990d00') ||
                   '</vldestorm>' || '<vlcredit>' ||
                   to_char(nvl(vr_vlcredit, 0), 'fm99G999G990d00') ||
                   '</vlcredit>' ||
                   -- SAIDAS
                   '<nrdebrec>' || lpad(vr_nrdebrec, 4, '0') ||
                   '</nrdebrec>' || '<nrcrdrec>' ||
                   lpad(vr_nrcrdrec, 4, '0') || '</nrcrdrec>' ||
                   '<nrhstrec>' || lpad(vr_nrhstrec, 4, '0') ||
                   '</nrhstrec>' || '<vlrecolh>' ||
                   to_char(nvl(rw_craplfn.vlrecolh, 0), 'fm99G999G990d00') ||
                   '</vlrecolh>' || '<nrdebsaq>' ||
                   lpad(vr_nrdebsaq, 4, '0') || '</nrdebsaq>' ||
                   '<nrcrdsaq>' || lpad(vr_nrcrdsaq, 4, '0') ||
                   '</nrcrdsaq>' || '<nrhstsaq>' ||
                   lpad(vr_nrhstsaq, 4, '0') || '</nrhstsaq>' ||
                   '<vldsaque>' ||
                   to_char(nvl(vr_vldsaque, 0), 'fm99G999G990d00') ||
                   '</vldsaque>' || '<nrdebsaqm>' ||
                   lpad(vr_nrdebsaqm, 4, '0') || '</nrdebsaqm>' ||
                   '<nrcrdsaqm>' || lpad(vr_nrcrdsaqm, 4, '0') ||
                   '</nrcrdsaqm>' || '<nrhstsaqm>' ||
                   lpad(vr_nrhstsaqm, 4, '0') || '</nrhstsaqm>' ||
                   '<vldsaquem>' ||
                   to_char(nvl(vr_vldsaquem, 0), 'fm99G999G990d00') ||
                   '</vldsaquem>' || '<vldebito>' ||
                   to_char(nvl(vr_vldebito, 0), 'fm99G999G990d00') ||
                   '</vldebito>');
    -- Detalhamento do log de operação do dia
    for rw_craplfn2 in cr_craplfn2(pr_cdcooper,
                                   vr_dtmvtolt,
                                   rw_craptfn.nrterfin) loop
      -- Incluir informações detalhadas no XML
      pc_escreve_xml('<operacao nrterope="' || rw_craptfn.nrterfin || '">' ||
                     '<dttransa>' ||
                     to_char(rw_craplfn2.dttransa, 'dd/mm/yyyy') ||
                     '</dttransa>' || '<hrtransa>' || rw_craplfn2.hrtransa ||
                     '</hrtransa>' || '<dsoperac>' || rw_craplfn2.dsoperac ||
                     '</dsoperac>' || '<nmoperad>' ||
                     substr(rw_craplfn2.nmoperad, 1, 27) || '</nmoperad>' ||
                     '<vltransa>' ||
                     to_char(rw_craplfn2.vltransa, 'fm99G999G990d00') ||
                     '</vltransa>' || '</operacao>');
      vr_regexist := true;
    end loop;
    -- Registro de saldo do dia anterior
    open cr_crapstf(pr_cdcooper, vr_dtmvtopr, rw_craptfn.nrterfin);
    fetch cr_crapstf
      into rw_crapstf_buffer;
    if cr_crapstf%notfound and rw_craptfn.flsistaa = 0 then
      -- Não eencontrou informação
      pc_escreve_xml('<msgdifer>STF DO DIA SEGUINTE NAO ENCONTRADO</msgdifer>');
      close cr_crapstf;
      continue;
    else
      -- Busca as movimentações detalhadas
      open cr_crapstd(pr_cdcooper,
                      rw_crapstf.dtmvtolt,
                      rw_crapstf.nrterfin);
      fetch cr_crapstd
        into rw_crapstd;
      -- Verifica se os valores fecham
      if (rw_crapstd.vldmo316 <> vr_vldsaque or
         rw_crapstd.vldmo918 <> vr_vldsaquem or
         rw_crapstd.vldmo767 <> vr_vldestor or
         rw_crapstd.vldmo920 <> vr_vldestorm or
         (nvl(rw_crapstf.vldsdini, 0) + rw_craplfn.vlsuprim + vr_vldestor +
         vr_vldestorm - rw_craplfn.vlrecolh - vr_vldsaque - vr_vldsaquem) <>
         nvl(rw_crapstf.vldsdfin, 0)) or
         (rw_craptfn.flsistaa = 0 and
         nvl(rw_crapstf.vldsdfin, 0) <> nvl(rw_crapstf_buffer.vldsdini, 0)) then
        -- Existe diferença no terminal
        pc_escreve_xml('<msgdifer>** CASH DISPENSER COM DIFERENCA NO SALDO - VERIFICAR!!! **</msgdifer>');
      else
        pc_escreve_xml('<msgdifer></msgdifer>');
      end if;
      close cr_crapstd;
    end if;
    close cr_crapstf;
    -- Inserir na PL/Table
    vr_ind_crawcxa := lpad(rw_craptfn.cdagenci, 5, '0') || '2' ||
                      lpad(rw_crapstf.nrterfin, 5, '0');
    vr_tab_crawcxa(vr_ind_crawcxa).vr_tpdcaixa := 2;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_cdagenci := rw_craptfn.cdagenci;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_dsagenci := rw_craptfn.dsagenci;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_cdoperad := rw_craptfn.cdoperad;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_nmoperad := rw_craptfn.nmoperad2;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_nrdcaixa := rw_crapstf.nrterfin;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_vldsdfin := rw_crapstf.vldsdfin;
    if rw_crapstf.dtmvtolt = vr_dtmvtolt then
      vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt := null;
    else
      vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt := rw_crapstf.dtmvtolt;
    end if;
    -- Gravacao de dados no banco GENERICO - Relatorios Gerenciais
    begin
      insert into gnsldcx
        (cdcooper, cdagenci, dtmvtolt, nrterfin, tpdcaixa, vldsdfin)
      values
        (pr_cdcooper,
         rw_craptfn.cdagenci,
         vr_dtmvtolt,
         rw_craptfn.nrterfin,
         2,
         rw_crapstf.vldsdfin);
    exception
      when dup_val_on_index then
        begin
          update gnsldcx
             set vldsdfin = rw_crapstf.vldsdfin
           where cdcooper = pr_cdcooper
             and cdagenci = rw_craptfn.cdagenci
             and dtmvtolt = vr_dtmvtolt
             and nrterfin = rw_craptfn.nrterfin
             and tpdcaixa = 2;
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao atualizar gnsldcx tipo 2: ' || sqlerrm;
            raise vr_exc_saida;
        end;
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao inserir gnsldcx tipo 2: ' || sqlerrm;
        raise vr_exc_saida;
    end;
    -- Fecha a TAG do terminal
    pc_escreve_xml('</terminal>');
  end loop;
  -- Tratamento do saldo dos caixas por PAC
  for rw_crapbcx in cr_crapbcx(pr_cdcooper, vr_dtmvtolt) loop
    -- Inserir na PL/Table
    vr_ind_crawcxa := lpad(rw_crapbcx.cdagenci, 5, '0') || '1' ||
                      lpad(rw_crapbcx.nrdcaixa, 5, '0');
    vr_tab_crawcxa(vr_ind_crawcxa).vr_tpdcaixa := 1;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_cdagenci := rw_crapbcx.cdagenci;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_dsagenci := rw_crapbcx.dsagenci;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_cdoperad := rw_crapbcx.cdopecxa;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_nmoperad := rw_crapbcx.nmoperad;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_nrdcaixa := rw_crapbcx.nrdcaixa;
    vr_tab_crawcxa(vr_ind_crawcxa).vr_vldsdfin := rw_crapbcx.vldsdfin;
    if rw_crapbcx.dtmvtolt = vr_dtmvtolt then
      vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt := null;
    else
      vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt := rw_crapbcx.dtmvtolt;
    end if;
    -- Gravacao de dados no banco GENERICO - Relatorios Gerenciais
    begin
      insert into gnsldcx
        (cdcooper, cdagenci, dtmvtolt, nrterfin, tpdcaixa, vldsdfin)
      values
        (pr_cdcooper,
         rw_crapbcx.cdagenci,
         vr_dtmvtolt,
         rw_crapbcx.nrdcaixa,
         1,
         rw_crapbcx.vldsdfin);
    exception
      when dup_val_on_index then
        begin
          update gnsldcx
             set vldsdfin = rw_crapbcx.vldsdfin
           where cdcooper = pr_cdcooper
             and cdagenci = rw_crapbcx.cdagenci
             and dtmvtolt = vr_dtmvtolt
             and nrterfin = rw_crapbcx.nrdcaixa
             and tpdcaixa = 1;
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao atualizar gnsldcx tipo 1: ' || sqlerrm;
            raise vr_exc_saida;
        end;
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao inserir gnsldcx tipo 1: ' || sqlerrm;
        raise vr_exc_saida;
    end;
  end loop;
  -- Leitura da PL/Table para gerar a seção de totais do relatório
  vr_ind_crawcxa := vr_tab_crawcxa.first;
  pc_escreve_xml('<saldocaixas>');
  while vr_ind_crawcxa is not null loop
    -- Incluir informações de saldo de caixas no XML
    pc_escreve_xml('<agencia dsagenci_saldo="' || vr_tab_crawcxa(vr_ind_crawcxa)
                   .vr_dsagenci || '">' || '<dtrefere_saldo>' ||
                   to_char(vr_dtmvtolt, 'dd/mm/yyyy') ||
                   '</dtrefere_saldo>' || '<tpdcaixa_saldo>' || vr_tab_crawcxa(vr_ind_crawcxa)
                   .vr_tpdcaixa || '</tpdcaixa_saldo>' ||
                   '<nrdcaixa_saldo>' || vr_tab_crawcxa(vr_ind_crawcxa)
                   .vr_nrdcaixa || '</nrdcaixa_saldo>' ||
                   '<dtmvtolt_saldo>' ||
                   to_char(vr_tab_crawcxa(vr_ind_crawcxa).vr_dtmvtolt,
                           'dd/mm/yyyy') || '</dtmvtolt_saldo>' ||
                   '<nmoperad_saldo>' || vr_tab_crawcxa(vr_ind_crawcxa)
                   .vr_nmoperad || '</nmoperad_saldo>' ||
                   '<vldsdfin_char_saldo>' ||
                   to_char(vr_tab_crawcxa(vr_ind_crawcxa).vr_vldsdfin,
                           'fm99G999G990d00') || '</vldsdfin_char_saldo>' ||
                   '<vldsdfin_saldo>' || vr_tab_crawcxa(vr_ind_crawcxa)
                   .vr_vldsdfin || '</vldsdfin_saldo>' || '</agencia>');
    vr_ind_crawcxa := vr_tab_crawcxa.next(vr_ind_crawcxa);
  end loop;
  pc_escreve_xml('</saldocaixas>');
  pc_escreve_xml('</crps265>');
  -- Chamada do iReport para gerar o arquivo de saída
  pc_executa_relatorio('/crps265', --> Nó base do XML para leitura dos dados
                       'crrl214.jasper', --> Arquivo de layout do iReport
                       1, --> Sequencia do relatório
                       1); --> Numero de copias
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  --
  -- EMISSÃO DO RELATÓRIO CRRL411
  --
  -- Nome base do arquivo é crrl411
  vr_nom_arquivo := 'crrl411';
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps265 dtmvtolt="' ||
                 to_char(vr_dtmvtolt, 'dd/mm/yyyy') || '">');
  -- Leitura dos caixas com diferença
  for rw_craplcx in cr_craplcx(pr_cdcooper, vr_dtmvtolt) loop

    -- Tratar a tag dsdcompl para evitar erros quando informado caracteres inválidos
    IF INSTR(rw_craplcx.dsdcompl,'>') > 0 OR
       INSTR(rw_craplcx.dsdcompl,'<') > 0 OR
       INSTR(rw_craplcx.dsdcompl,'&') > 0 THEN
      -- Inclui as tag de CDATA
      vr_dsdcompl := '<![CDATA['||rw_craplcx.dsdcompl||']]>';
    ELSE
      -- Escreve apenas a informação
      vr_dsdcompl := rw_craplcx.dsdcompl;
    END IF;

    -- Incluir informações de diferenças de caixa no XML
    pc_escreve_xml('<diferenca>' || '<cdagenci>' || rw_craplcx.cdagenci ||
                   '</cdagenci>' || '<nrdcaixa>' || rw_craplcx.nrdcaixa ||
                   '</nrdcaixa>' || '<nmoperad>' ||
                   substr(rw_craplcx.nmoperad, 1, 27) || '</nmoperad>' ||
                   '<vldocmto>' ||
                   to_char(rw_craplcx.vldocmto, 'fm999G990d00') ||
                   '</vldocmto>' || '<dshistor>' || rw_craplcx.dshistor ||
                   '</dshistor>' || '<dsdcompl>' || vr_dsdcompl ||
                   '</dsdcompl>' || '</diferenca>');
  end loop;
  -- Resumo dos caixas com diferença
  for rw_craplcx_resumo in cr_craplcx_resumo(pr_cdcooper, vr_dtmvtolt) loop
    -- Incluir resumo de diferenças de caixa no XML
    pc_escreve_xml('<resumo>' || '<dshistor>' ||
                   rw_craplcx_resumo.dshistor || '</dshistor>' ||
                   '<qtdocmto>' || rw_craplcx_resumo.qtdocmto ||
                   '</qtdocmto>' || '<vldocmto>' ||
                   to_char(rw_craplcx_resumo.vldocmto, 'fm9G999G990d00') ||
                   '</vldocmto>' || '</resumo>');
  end loop;
  pc_escreve_xml('</crps265>');
  -- Definir o número de cópias
  if pr_cdcooper in (6, 7) then
    vr_nrcopias := 1;
  elsif pr_cdcooper = 1 then
    vr_nrcopias := 3;
  else
    vr_nrcopias := 4;
  end if;
  -- Chamada do iReport para gerar o arquivo de saída
  pc_executa_relatorio('/crps265', --> Nó base do XML para leitura dos dados
                       'crrl411.jasper', --> Arquivo de layout do iReport
                       2, --> Sequencia do relatório
                       vr_nrcopias); --> Número de cópias
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  --
  -- EMISSÃO DO RELATÓRIO CRRL386 POR PAC
  --
  vr_dtiniper := trunc(vr_dtmvtolt, 'mm');
  -- Busca as agências com diferença
  for rw_craplcx_per in cr_craplcx_per(pr_cdcooper,
                                       vr_dtiniper,
                                       vr_dtmvtolt) loop
    -- Nome base do arquivo é crrl386
    vr_nom_arquivo := 'crrl386_' || lpad(rw_craplcx_per.cdagenci, 3, '0');
    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps265 pac="' ||
                   rw_craplcx_per.cdagenci || '" mes_ref="' ||
                   trim(gene0001.vr_vet_nmmesano(to_char(vr_dtmvtolt, 'MM'))) || '/' ||
                   to_char(vr_dtmvtolt, 'yyyy') || '">');
    -- Leitura e processamento das diferenças para cada agência
    for rw_craplcx_per_pac in cr_craplcx_per_pac(pr_cdcooper,
                                                 vr_dtiniper,
                                                 vr_dtmvtolt,
                                                 rw_craplcx_per.cdagenci) loop

      -- Tratar a tag dsdcompl para evitar erros quando informado caracteres inválidos
      IF INSTR(rw_craplcx_per_pac.dsdcompl,'>') > 0 OR
         INSTR(rw_craplcx_per_pac.dsdcompl,'<') > 0 OR
         INSTR(rw_craplcx_per_pac.dsdcompl,'&') > 0 THEN
        -- Inclui as tag de CDATA
        vr_dsdcompl := '<![CDATA['||rw_craplcx_per_pac.dsdcompl||']]>';
      ELSE
        -- Escreve apenas a informação
        vr_dsdcompl := rw_craplcx_per_pac.dsdcompl;
      END IF;

      -- Incluir informações de diferenças de caixa no XML
      pc_escreve_xml('<diferenca>' || '<dia>' || rw_craplcx_per_pac.dia ||
                     '</dia>' || '<nrdcaixa>' ||
                     rw_craplcx_per_pac.nrdcaixa || '</nrdcaixa>' ||
                     '<nmoperad>' ||
                     substr(rw_craplcx_per_pac.nmoperad, 1, 23) ||
                     '</nmoperad>' || '<vldocmto>' ||
                     to_char(rw_craplcx_per_pac.vldocmto, 'fm999G990d00') ||
                     '</vldocmto>' || '<dshistor>' ||
                     rw_craplcx_per_pac.dshistor || '</dshistor>' ||
                     '<dsdcompl>' || vr_dsdcompl ||
                     '</dsdcompl>' || '</diferenca>');
    end loop;
    -- Resumo dos caixas com diferença
    for rw_craplcx_per_pac_res in cr_craplcx_per_pac_res(pr_cdcooper,
                                                         vr_dtiniper,
                                                         vr_dtmvtolt,
                                                         rw_craplcx_per.cdagenci) loop
      -- Incluir resumo de diferenças de caixa no XML
      pc_escreve_xml('<resumo>' || '<dshistor>' ||
                     rw_craplcx_per_pac_res.dshistor || '</dshistor>' ||
                     '<qtdocmto>' || rw_craplcx_per_pac_res.qtdocmto ||
                     '</qtdocmto>' || '<vldocmto>' ||
                     to_char(rw_craplcx_per_pac_res.vldocmto,
                             'fm9G999G990d00') || '</vldocmto>' ||
                     '</resumo>');
    end loop;
    pc_escreve_xml('</crps265>');
    -- Chamada do iReport para gerar o arquivo de saída
    pc_executa_relatorio('/crps265', --> Nó base do XML para leitura dos dados
                         'crrl386.jasper', --> Arquivo de layout do iReport
                         3, --> Sequencia do relatório
                         1); --> Número de cópias
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
  end loop;
  --
  -- EMISSÃO DO RELATÓRIO CRRL386 GERAL (RESUMO)
  --
  -- Nome base do arquivo é crrl386
  vr_nom_arquivo := 'crrl386_' ||
                    gene0001.fn_param_sistema('CRED',
                                              pr_cdcooper,
                                              'SUFIXO_RELATO_TOTAL');
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps265 pac="99" mes_ref="' ||
                 trim(gene0001.vr_vet_nmmesano(to_char(vr_dtmvtolt, 'MM'))) || '/' ||
                 to_char(vr_dtmvtolt, 'yyyy') || '">');
  -- Resumo dos caixas com diferença no período, para todas as agências
  for rw_craplcx_per_pac_res in cr_craplcx_per_pac_res2(pr_cdcooper,
                                                        vr_dtiniper,
                                                        vr_dtmvtolt) loop
    -- Incluir resumo de diferenças de caixa no XML
    pc_escreve_xml('<resumo>' || '<dshistor>' ||
                   rw_craplcx_per_pac_res.dshistor || '</dshistor>' ||
                   '<qtdocmto>' || rw_craplcx_per_pac_res.qtdocmto ||
                   '</qtdocmto>' || '<vldocmto>' ||
                   to_char(rw_craplcx_per_pac_res.vldocmto,
                           'fm9G999G990d00') || '</vldocmto>' ||
                   '</resumo>');
  end loop;
  pc_escreve_xml('</crps265>');
  -- Chamada do iReport para gerar o arquivo de saída
  pc_executa_relatorio('/crps265', --> Nó base do XML para leitura dos dados
                       'crrl386.jasper', --> Arquivo de layout do iReport
                       3, --> Sequencia do relatório
                       1); --> Número de cópias
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

  -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END;
/
