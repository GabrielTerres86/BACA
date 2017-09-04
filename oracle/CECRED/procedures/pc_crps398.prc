CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS398 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                                    ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                                    ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                                    ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                                    ,pr_dscritic OUT varchar2) IS          --> Texto de erro/critica encontrada
  BEGIN

  /* .............................................................................

   Programa: pc_crps398                     Antigo: Fontes/crps398.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : julho/2004                     Ultima atualizacao: 24/04/2017
   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Gerar arquivo com saldo devedor dos emprestimos/Cred.Liquid.
               Solicitacao : 2
               Ordem do programa na solicitacao = .
               Exclusividade = 2(Cadeia 1)

   Alteracoes: Separar relatorio /PAC(utilizar no IMPREL)(Mirtes)
               20/09/2004 - Utilizar numero de conta dos avalistas do
                            crapepr(Contratos Antigos crawepr<>crapepr)(Mirtes).

               22/09/2004 - Listar as cartas com SOLICITACAO em atraso (que ja
                            deveriam ter sido solicitadas) a 5 ou mais dias
                            (Evandro).

               26/10/2004 - Emitir rel.369 na quarta-feira(tambem)
                            e nao listar mais inclusao SPC  se devedor ja
                            incluso(Mirtes)

               01/11/2004 - Inclusao do Nro do CPF(Mirtes).

               10/12/2004 - Verificado se Avalistas ja Inclusos no SPC(Mirtes)

               22/03/2005 - Totalizacao de cartas em atraso no final do
                            relatorio(Rosangela - tarefa 2959)

               01/07/2005 - Alimentado campo cdcooper da tabela crapcdv (Diego).

               01/09/2005 - Somente calcular saldo emprestimo quando nao for
                            processo mensal(Mirtes)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               15/12/2005 - Tratamento leitura crabass (Mirtes)

               17/02/2006 - Unificacao dos bancos - SQLWorks - Fernando.

               16/10/2007 - Usar includes/crps398.i p/ calc dos dias(Guilherme).

               23/10/2007 - Postar relatorio 362 na Intranet (Guilehrme).

               23/11/2007 - Nao criar "crapcdv" se emprestimo estiver em
                            prejuizo (Diego).

               04/02/2009 - Alterado FORMAT do campo CPF e incluidas colunas
                            Dt.Ctrato. , Ult.Pagto. , A Regularizar (Diego).

               30/03/2009 - Efetuados acertos nas colunas Ult.Pagto. e
                            A Regularizar;
                          - Incluidas colunas Devol.AR e Ident. no item de
                            inclusoes no SPC do relatorio 362 (Diego).

               22/04/2009 - Criar relatorio crrl362_99 - relacao com todos os
                            PACs (Fernando).

               27/05/2009 - Incluida coluna "Lin" nos relatorios e corrigido
                            calculo da variavel aux_qtmesdec (Diego).

               18/08/2010 - Atualizar automaticamente os campos de recebimentos
                            de AR para as cooperat. que estão com a opção "NAO"
                            em tab032. (Irlan).

               25/10/2010 - Alteracao para gerar relatorio em txt
                            (GATI-Sandro)

               15/02/2011 - Inclusao para gerar txt para Acredicoop;
                          - Alteracao para mover arquivos para diretorio
                            salvar (GATI - Eder).

               23/11/2012 - Alterado para tratar o novo emprestimo no include
                            crps398.i incluido rotina para calculo de dias em
                            atraso. (Oscar)

               23/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                            inpessoa (Marcos-Supero)

               28/05/2013 - Alteração de indices temp table w-relat e alteracao
                            de ordenacao. (Jean)

               31/10/2013 - Ajustar format no frame f_relat_atraso (David).

               01/11/2013 - Alterado totalizador de 99 para 999.
                          - Alterado de PAC para PA.(Reinert)

               22/01/2014 - Incluir VALIDATE crapcdv (Lucas R.)

               31/01/2014 - Remover a chamada da include lelem.i (James)

               20/02/2014 - Ajuste na ordenacao do relatorio para igualar
                            ao relatorio do Oracle (James)
                            
               22/06/2016 - Correcao para o uso correto do indice da CRAPTAB 
                            nesta rotina.(Carlos Rafael Tanholi).

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps398 */

       --Definicao do tipo de registro para insert crapsld
       TYPE typ_reg_crapsld IS
         RECORD (dtdsdclq crapsld.dtdsdclq%TYPE
                ,vlsddisp crapsld.vlsddisp%TYPE
                ,vlsdchsl crapsld.vlsdchsl%TYPE
                ,qtddsdev crapsld.qtddsdev%TYPE
                ,vlsdbloq crapsld.vlsdbloq%TYPE
                ,vlsdblpr crapsld.vlsdblpr%TYPE
                ,vlsdblfp crapsld.vlsdblfp%TYPE);

       --Definicao do tipo de registro para insert crapepr
       TYPE typ_reg_crapepr IS
         RECORD (dtultpag crapepr.dtultpag%TYPE
                ,inliquid crapepr.inliquid%TYPE
                ,vlsdeved crapepr.vlsdeved%TYPE
                ,nrctaav1 crapepr.nrctaav1%TYPE
                ,nrctaav2 crapepr.nrctaav2%TYPE
                ,cdlcremp crapepr.cdlcremp%TYPE
                ,dtdpagto crapepr.dtdpagto%TYPE
                ,dtmvtolt crapepr.dtmvtolt%TYPE
                ,txjuremp crapepr.txjuremp%TYPE
                ,vljuracu crapepr.vljuracu%TYPE
                ,qtprecal crapepr.qtprecal%TYPE
                ,qtpreemp crapepr.qtpreemp%TYPE
                ,flgpagto crapepr.flgpagto%TYPE
                ,qtmesdec crapepr.qtmesdec%TYPE
                ,vlpreemp crapepr.vlpreemp%TYPE
                ,qtprepag crapepr.qtprepag%TYPE
                ,qtlcalat crapepr.qtlcalat%TYPE);

       --Definicao do tipo de registro para insert crawepr
       TYPE typ_reg_crawepr IS
         RECORD (nmdaval1 crawepr.nmdaval1%TYPE
                ,nmdaval2 crawepr.nmdaval2%TYPE
                ,nrctaav1 crawepr.nrctaav1%TYPE
                ,nrctaav2 crawepr.nrctaav2%TYPE
                ,dtdpagto crawepr.dtdpagto%TYPE);

       --Definicao do tipo de registro para insert crapavt
       TYPE typ_reg_crapavt IS
         RECORD (nrcpfcgc crapavt.nrcpfcgc%TYPE,
                 nmdavali crapavt.nmdavali%TYPE);

       --Definicao do tipo de registro para insert crapass
       TYPE typ_reg_crapass IS
         RECORD (inadimpl crapass.inadimpl%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,nrcpfcgc crapass.nrcpfcgc%TYPE
                ,inpessoa crapass.inpessoa%TYPE);

       --Definicao do tipo de registro para dias do pagamento por empresa
       TYPE typ_reg_craptab IS
         RECORD (mensal INTEGER
                ,horas  INTEGER);

       --Definicao do tipo de tabela para o relatorio
       TYPE typ_reg_relat IS
         RECORD (tpdcarta  INTEGER
                ,nrdconta  INTEGER
                ,vlsdeved  NUMBER
                ,nomedes1  crapass.nmprimtl%TYPE
                ,nrcpfcgc  crawepr.dscpfav1%TYPE
                ,tpctrato  INTEGER
                ,qtdiatra  INTEGER
                ,cdagenci  INTEGER
                ,dtdevoar  DATE
                ,tipodeve  VARCHAR2(100)
                ,vlpreapg  NUMBER
                ,cdlcremp  INTEGER
                ,dtdpagto  DATE
                ,dtmvtolt  DATE
                ,dtultsol  DATE
                ,nrctremp  NUMBER);



       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(20);
       TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY VARCHAR2(20);
       TYPE typ_tab_crapavt IS TABLE OF typ_reg_crapavt INDEX BY VARCHAR2(22);
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY PLS_INTEGER;
       TYPE typ_tab_relat   IS TABLE OF typ_reg_relat   INDEX BY VARCHAR2(111);
       TYPE typ_tab_craplcr IS TABLE OF NUMBER          INDEX BY PLS_INTEGER;

       --Definicao dos tipos de carta
       TYPE typ_tab_dstpcarta IS VARRAY(5) OF VARCHAR2(20);

       --Definicao das tabelas de memoria
       vr_tab_crapsld      typ_tab_crapsld;
       vr_tab_crapepr      typ_tab_crapepr;
       vr_tab_crawepr      typ_tab_crawepr;
       vr_tab_crapavt      typ_tab_crapavt;
       vr_tab_crapass      typ_tab_crapass;
       vr_tab_craplcr      typ_tab_craplcr;
       vr_tab_crapttl      typ_tab_craplcr;
       vr_tab_crapjur      typ_tab_craplcr;
       vr_tab_craptab      typ_tab_craptab;
       vr_tab_relat        typ_tab_relat;
       vr_tab_dstpcarta    typ_tab_dstpcarta:= typ_tab_dstpcarta
                                             ('1a. Carta Devedor',
                                              '2a. Carta Devedor',
                                              '1a  Carta Avalista',
                                              '2a. Carta Avalista',
                                              'Inclusao SPC');

       --Cursores da rotina crps398

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar informacoes do cadastro de devedores
       CURSOR cr_crapcdv (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
         SELECT crapcdv.cdorigem
               ,crapcdv.dtultpag
               ,crapcdv.nrdconta
               ,crapcdv.nrctremp
               ,crapcdv.ROWID
         FROM  crapcdv crapcdv
         WHERE crapcdv.cdcooper = pr_cdcooper
         AND   crapcdv.dtliquid IS NULL
         AND   crapcdv.cdorigem IN (1,3)
         ORDER BY crapcdv.cdcooper,crapcdv.dtliquid,crapcdv.progress_recid;

       --Selecionar informacoes do cadastro de devedores
       CURSOR cr_crapcdv_last (pr_cdcooper IN crapsld.cdcooper%TYPE
                              ,pr_nrdconta IN crapcdv.nrdconta%TYPE
                              ,pr_nrctremp IN crapcdv.nrctremp%TYPE
                              ,pr_cdorigem IN crapcdv.cdorigem%TYPE) IS
         SELECT crapcdv.dtliquid
               ,crapcdv.rowid
         FROM crapcdv
         WHERE crapcdv.cdcooper = pr_cdcooper
         AND  crapcdv.nrdconta  = pr_nrdconta
         AND  crapcdv.nrctremp  = pr_nrctremp
         AND  crapcdv.cdorigem  = pr_cdorigem
         ORDER BY crapcdv.progress_recid DESC;
       rw_crapcdv_last cr_crapcdv_last%ROWTYPE;

       --Selecionar informacoes do saldo das aplicacoes
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
         SELECT crapsld.nrdconta
               ,crapsld.dtdsdclq
               ,crapsld.vlsddisp
               ,crapsld.vlsdchsl
               ,crapsld.vlsdbloq
               ,crapsld.vlsdblpr
               ,crapsld.vlsdblfp
               ,crapsld.qtddsdev
         FROM crapsld crapsld
         WHERE crapsld.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE) IS
         SELECT crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.dtultpag
               ,crapepr.inliquid
               ,crapepr.vlsdeved
               ,crapepr.nrctaav1
               ,crapepr.nrctaav2
               ,crapepr.cdlcremp
               ,crapepr.dtdpagto
               ,crapepr.dtmvtolt
               ,crapepr.txjuremp
               ,crapepr.vljuracu
               ,crapepr.qtprecal
               ,crapepr.qtpreemp
               ,crapepr.flgpagto
               ,crapepr.qtmesdec
               ,crapepr.vlpreemp
               ,crapepr.qtprepag
         FROM crapepr crapepr
         WHERE crapepr.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos emprestimos crawepr
       CURSOR cr_crawepr (pr_cdcooper IN crapepr.cdcooper%TYPE) IS
         SELECT crawepr.nrdconta
               ,crawepr.nrctremp
               ,crawepr.nmdaval1
               ,crawepr.nmdaval2
               ,crawepr.nrctaav1
               ,crawepr.nrctaav2
               ,crawepr.dtdpagto
         FROM crawepr crawepr
         WHERE crawepr.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos avalistas dos emprestimos
       CURSOR cr_crapavt (pr_cdcooper IN crapepr.cdcooper%TYPE) IS
         SELECT crapavt.nrdconta
               ,crapavt.nrctremp
               ,crapavt.nrcpfcgc
               ,crapavt.nmdavali
               ,Row_Number() OVER (PARTITION BY crapavt.nrdconta, crapavt.nrctremp ORDER BY crapavt.nrdconta, crapavt.nrctremp) nrseqava
          FROM crapavt
         WHERE crapavt.cdcooper = pr_cdcooper
           AND crapavt.tpctrato = 1;

       --Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr_risco (pr_cdcooper IN crapepr.cdcooper%TYPE
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE
                               ,pr_inliquid IN crapepr.inliquid%TYPE
                               ,pr_inprejuz IN crapepr.inprejuz%TYPE) IS
         SELECT crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.dtultpag
         FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
         AND   crapepr.nrdconta = pr_nrdconta
         AND   crapepr.inliquid = pr_inliquid
         AND   crapepr.inprejuz = pr_inprejuz;

       --Selecionar informacoes dos associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT /*+ index (crapass crapass##crapass7) */
                crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.vllimcre
               ,crapass.inadimpl
               ,crapass.inpessoa
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos cadastros de cartas de emprestimos em atraso CL
       CURSOR cr_crapcdv_assoc (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT crapass.inadimpl
               ,crapass.nmprimtl
               ,crapass.nrcpfcgc
               ,crapass.cdagenci
               ,crapass.inpessoa
               ,crapass.cdtipsfx
               ,crapcdv.dtemdev1
               ,crapcdv.dtemdev2
               ,crapcdv.dtemavl2
               ,crapcdv.cdorigem
               ,crapcdv.dtardeve
               ,crapcdv.dtar1avl
               ,crapcdv.dtar2avl
               ,crapcdv.nrdconta
               ,crapcdv.nrctremp
               ,crapcdv.dtspcav1
               ,crapcdv.dtspcav2
               ,crapcdv.vlsdeved
               ,crapcdv.qtdiatra
               ,crapcdv.dtslavl2
               ,crapcdv.dtslavl1
               ,crapcdv.dtsldev1
               ,crapcdv.dtmvtolt
               ,crapcdv.rowid
         FROM crapcdv, crapass
         WHERE crapcdv.cdcooper = pr_cdcooper
         AND   crapcdv.dtliquid IS NULL
         AND   crapcdv.flgenvio = 1
         AND   crapass.cdcooper = crapcdv.cdcooper
         AND   crapass.nrdconta = crapcdv.nrdconta;

       --Selecionar informacoes das linhas de credito
       CURSOR cr_craplcr (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT craplcr.cdlcremp
               ,craplcr.txdiaria
         FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos titulares
       CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapttl.nrdconta
               ,crapttl.cdempres
         FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.idseqttl = 1;

       --Selecionar informacoes das pessoas juridicas
       CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapjur.nrdconta
               ,crapjur.cdempres
         FROM crapjur
         WHERE crapjur.cdcooper = pr_cdcooper;

       --Selecionar informacoes da data de pagamento por empresa
       CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                         ,pr_nmsistem IN craptab.nmsistem%TYPE
                         ,pr_tptabela IN craptab.tptabela%TYPE
                         ,pr_cdempres IN craptab.cdempres%TYPE
                         ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
         SELECT craptab.tpregist
               ,craptab.dstextab
         FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
         AND   UPPER(craptab.nmsistem) = pr_nmsistem
         AND   UPPER(craptab.tptabela) = pr_tptabela
         AND   craptab.cdempres = pr_cdempres
         AND   UPPER(craptab.cdacesso) = pr_cdacesso;

       --Variaveis Locais
       vr_dia1cardve   INTEGER;
       vr_dia2cardve   INTEGER;
       vr_dia2carave   INTEGER;
       vr_diaspcempr   INTEGER;
       vr_dia1cardvc   INTEGER;
       vr_dia2cardvc   INTEGER;
       vr_diaspccl     INTEGER;
       vr_flgenvar     BOOLEAN;
       vr_dias         INTEGER;
       vr_qtdiasar     INTEGER;
       vr_qtprecal     INTEGER;
       vr_tpdcarta     INTEGER;
       vr_tipodeve     INTEGER;
       vr_dtininar     DATE;
       vr_vlutiliz     NUMBER:= 0;
       vr_vlsddisp     NUMBER:= 0;
       vr_vlbloque     NUMBER:= 0;
       vr_vlsrisco     NUMBER:= 0;
       vr_vldivida     NUMBER:= 0;
       vr_vllimcre     NUMBER:= 0;
       vr_vlsdeved     NUMBER:= 0;
       vr_nrcpfcgc     crawepr.dscpfav1%TYPE;
       vr_stininar     VARCHAR2(12);
       vr_nomedes1     VARCHAR2(100);

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;
       vr_dscritic     VARCHAR2(4000);

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_crapepr      VARCHAR2(20);
       vr_index_crawepr      VARCHAR2(20);
       vr_index_crapavt      VARCHAR2(22);
       vr_index_crapepr_aval VARCHAR2(20);
       vr_index_relat        VARCHAR2(111);

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;

       --Variaveis de retorno para select generico
       vr_dstextab_carta craptab.dstextab%TYPE;

       --Variaveis de Excecao
       vr_exc_undo  EXCEPTION;
       vr_exc_saida EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapsld.DELETE;
         vr_tab_crapepr.DELETE;
         vr_tab_crawepr.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_craplcr.DELETE;
         vr_tab_crapttl.DELETE;
         vr_tab_crapjur.DELETE;
         vr_tab_relat.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps398.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

       --Atualização recebimento AR
       PROCEDURE pc_atualiza_recebimento_ar (pr_flgenvar      IN BOOLEAN
                                            ,pr_dtemdev2      IN crapcdv.dtemdev2%TYPE
                                            ,pr_dtardeve      IN crapcdv.dtardeve%TYPE
                                            ,pr_dtininar      IN crapcdv.dtardeve%TYPE
                                            ,pr_dtemavl2      IN crapcdv.dtemavl2%TYPE
                                            ,pr_dtar1avl      IN crapcdv.dtar1avl%TYPE
                                            ,pr_dtar2avl      IN crapcdv.dtar2avl%TYPE
                                            ,pr_qtdiasar      IN INTEGER
                                            ,pr_crapcdv_rowid IN ROWID
                                            ,pr_des_erro      OUT VARCHAR2) IS

         -- Variavel de Erro e de Exceção
         vr_des_erro VARCHAR2(2000);
         vr_exc_erro EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

         --Se nao foi enviado AR
         IF NOT pr_flgenvar THEN
           --Se a data do envio 2 ar
           IF  pr_dtemdev2 IS NOT NULL THEN  /*AR da segunda carta do devedor*/
             --Se a data de recebimento do AR
             IF pr_dtardeve IS NULL THEN
               --Se a data do movimento menos dias maior data emissao dev 2
               IF ((rw_crapdat.dtmvtolt - pr_qtdiasar) >= pr_dtemdev2) AND
                   (pr_dtemdev2 >= pr_dtininar) THEN
                 --Atualizar tabela crapcdv
                 BEGIN
                   UPDATE crapcdv SET crapcdv.dtardeve = rw_crapdat.dtmvtolt
                   WHERE crapcdv.ROWID = pr_crapcdv_rowid;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_des_erro:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                     RAISE vr_exc_erro;
                 END;
               END IF;
             END IF;
           END IF; --pr_dtemdev2 IS NOT NULL

           --Se a data de emissao do aviso 2 nao for nula
           IF pr_dtemavl2 IS NOT NULL THEN

             IF pr_dtar1avl IS NULL THEN /*AR da seg. carta do Prim. Aval*/
               IF ((rw_crapdat.dtmvtolt - pr_qtdiasar) >= pr_dtemavl2) AND
                   (pr_dtemavl2 >= pr_dtininar) THEN
                 --Atualizar tabela crapcdv
                 BEGIN
                   UPDATE crapcdv SET crapcdv.dtar1avl = rw_crapdat.dtmvtolt
                   WHERE crapcdv.ROWID = pr_crapcdv_rowid;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_des_erro:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                     RAISE vr_exc_erro;
                 END;
               END IF;
             END IF; --pr_dtar1avl IS NULL

             /*AR da seg. carta do Seg. Aval*/
             IF pr_dtar2avl IS NULL THEN
               IF (rw_crapdat.dtmvtolt - pr_qtdiasar) >= pr_dtemavl2 AND
                  (pr_dtemavl2 >= pr_dtininar) THEN
                 --Atualizar tabela crapcdv
                 BEGIN
                   UPDATE crapcdv SET crapcdv.dtar2avl = rw_crapdat.dtmvtolt
                   WHERE crapcdv.ROWID = pr_crapcdv_rowid;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_des_erro:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                     RAISE vr_exc_erro;
                 END;
               END IF;
             END IF; --pr_dtar2avl IS NULL
           END IF; --pr_dtemavl2 IS NOT NULL
         END IF; --IF not
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro := vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro na execução da rotina pc_crps398.pc_atualiza_recebimento_ar. '||sqlerrm;
       END;

       --Procedure para verificar os calculos a regularizar
       PROCEDURE pc_calculo_a_regularizar (pr_nrdconta     IN crapcdv.nrdconta%TYPE
                                          ,pr_vlpreapg     OUT number
                                          ,pr_des_erro     OUT varchar2) IS

         -- Verificar se existe aviso de débito em conta corrente não processado
         CURSOR cr_crapavs(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapavs.nrdconta%TYPE
                          ,pr_dtrefere IN crapavs.dtrefere%TYPE) IS
           SELECT 'S'
           FROM crapavs
           WHERE crapavs.cdcooper = pr_cdcooper
           AND   crapavs.nrdconta = pr_nrdconta
           AND   crapavs.cdhistor = 108
           AND   crapavs.dtrefere = pr_dtrefere --> Ultimo dia mes anterior
           AND   crapavs.tpdaviso = 1
           AND   crapavs.flgproce = 0; --> Não processado


         --Variaveis Locais
         vr_dtinipag     DATE;
         vr_dtrefavs     DATE;
         vr_qtmesdec     NUMBER;
         vr_vlprepag     NUMBER;
         vr_flghaavs     CHAR(1);
         vr_qtprecal     NUMBER(25,4);

         -- Variavel de Erro e de Exceção
         vr_des_erro     VARCHAR2(2000);
         vr_exc_erro     EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

          -- Povoar variáveis para o calculo com os valores do empréstimo
         vr_vlprepag := 0;
         vr_vlsdeved := NVL(vr_tab_crapepr(vr_index_crapepr).vlsdeved,0);

         --Se emprestimo estiver ativo
         IF vr_tab_crapepr(vr_index_crapepr).inliquid = 0 THEN
           vr_qtprecal:= vr_tab_crapepr(vr_index_crapepr).qtprecal;
         ELSE
           vr_qtprecal:= vr_tab_crapepr(vr_index_crapepr).qtpreemp;
         END IF;

         -- Acumular a quantidade calculada
         IF vr_tab_crapepr(vr_index_crapepr).inliquid = 0 THEN
            vr_qtprecal := Nvl(vr_qtprecal,0) + Nvl(vr_tab_crapepr(vr_index_crapepr).qtlcalat,0);
         ELSE
            vr_qtprecal := Nvl(vr_qtprecal,0) + 0;
         END IF;

         -- Verificar se existe cadastro complementar de empréstimo
         IF NOT vr_tab_crawepr.EXISTS(vr_index_crapepr) THEN
           -- Utilizamos a informação complementar
           vr_dtinipag:= vr_tab_crapepr(vr_index_crapepr).dtdpagto;
         ELSE
           -- Utilizamos da tabela padrão
           vr_dtinipag:= vr_tab_crawepr(vr_index_crapepr).dtdpagto;
         END IF;

         -- Para empréstimos de debito em conta
         IF vr_tab_crapepr(vr_index_crapepr).flgpagto = 0 THEN
           -- Se a parcela vence no mês corrente
           IF To_Number(to_char(rw_crapdat.dtmvtolt,'YYYYMM')) = To_Number(To_Char(vr_tab_crapepr(vr_index_crapepr).dtdpagto,'YYYYMM')) THEN
             -- Se ainda não foi pago no mes
             IF vr_tab_crapepr(vr_index_crapepr).dtdpagto <= rw_crapdat.dtmvtolt AND
                To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')) = To_Number(To_Char(rw_crapdat.dtmvtopr,'MM')) THEN
               -- Incrementar a quantidade de parcelas
               vr_qtmesdec:= vr_tab_crapepr(vr_index_crapepr).qtmesdec + 1;
             ELSE
               -- Consideramos a quantidade já calculadao
               vr_qtmesdec:= vr_tab_crapepr(vr_index_crapepr).qtmesdec;
             END IF;
           -- Se foi paga no mês corrente
           ELSE
             IF To_Number(To_Char(rw_crapdat.dtmvtolt,'YYYYMM')) = To_Number(To_Char(vr_tab_crapepr(vr_index_crapepr).dtmvtolt,'YYYYMM')) THEN
               -- Se for um contrato do mês
               IF To_Number(To_Char(vr_dtinipag,'YYYYMM')) = To_Number(To_Char(rw_crapdat.dtmvtolt,'YYYYMM')) AND
                  To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')) = To_Number(To_Char(rw_crapdat.dtmvtopr,'MM')) THEN
                 -- Devia ter pago a primeira no mes do contrato
                 vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec + 1;
               ELSE
                 -- Paga a primeira somente no mes seguinte
                 vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec;
               END IF;
             ELSE
               -- Se a parcela vai vencer OU foi paga no mês corrEnte
               IF ((vr_tab_crapepr(vr_index_crapepr).dtdpagto < rw_crapdat.dtmvtolt AND
                    To_Number(To_Char(vr_tab_crapepr(vr_index_crapepr).dtdpagto,'DD')) <=
                    To_Number(To_Char(rw_crapdat.dtmvtolt,'DD'))) OR
                    vr_tab_crapepr(vr_index_crapepr).dtdpagto > rw_crapdat.dtmvtolt) AND
                    To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')) = To_Number(To_Char(rw_crapdat.dtmvtopr,'MM')) THEN
                 -- Incrementar a quantidade de parcelas
                 vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec + 1;
               ELSE
                 -- Consideramos a quantidade já calculadao
                 vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec;
               END IF;
             END IF;
           END IF;
         ELSE --> Para desconto em folha
           -- Para contratos do Mes
           IF to_Number(To_Char(vr_tab_crapepr(vr_index_crapepr).dtmvtolt,'YYYYMM')) =
              to_Number(To_Char(rw_crapdat.dtmvtolt,'YYYYMM')) THEN
             -- Ainda nao atualizou o qtmesdec
             vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec;
           ELSE
             -- Verificar se existe aviso de débito em conta corrente não processado
             vr_flghaavs := 'N';
             --Determinar a data de referencia como ultimo dia mes anterior
             vr_dtrefavs:= Last_Day(Add_Months(rw_crapdat.dtmvtolt,-1));

             OPEN cr_crapavs(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_dtrefere => vr_dtrefavs);
             --Popular valor encontrado na variavel
             FETCH cr_crapavs INTO vr_flghaavs;
             --Se nao encontrou
             IF cr_crapavs%NOTFOUND THEN
               vr_flghaavs:= 'N';
             END IF;
             --Fechar Cursor
             CLOSE cr_crapavs;
             -- Se nao encontrar e for virada de mes
             IF vr_flghaavs = 'N' AND
                To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')) = To_Number(To_Char(rw_crapdat.dtmvtopr,'MM')) THEN
               -- Utilizar a quantidade já calculada
               vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec + 1;
             ELSE
               -- Nao adicionar mes
               vr_qtmesdec := vr_tab_crapepr(vr_index_crapepr).qtmesdec;
             END IF;
           END IF;
         END IF;

         -- Garantir que a quantidade decorrida não seja negativa
         IF vr_qtmesdec < 0 THEN
           vr_qtmesdec := 0;
         END IF;

         -- Se a quantidade calculada for superior a quantidade de meses decorridos
         -- E a data do pagamento já venceu
         -- E for um empréstimo de débito em conta
         IF vr_tab_crapepr(vr_index_crapepr).qtprecal > vr_tab_crapepr(vr_index_crapepr).qtmesdec
         AND vr_tab_crapepr(vr_index_crapepr).dtdpagto <= rw_crapdat.dtmvtolt
         AND vr_tab_crapepr(vr_index_crapepr).flgpagto = 0 THEN
           -- Calcular o atraso com base no valor do empréstimo - o que foi pago
           pr_vlpreapg:= Nvl(vr_tab_crapepr(vr_index_crapepr).vlpreemp,0) - Nvl(vr_vlprepag,0);
           -- Garantir que o valor não fique negativo
           IF pr_vlpreapg < 0 THEN
             pr_vlpreapg := 0;
           END IF;
         ELSE
           -- Se a diferença de meses decorridos e qtde calculada
           -- for superior a zero
           IF (Nvl(vr_qtmesdec,0) - Nvl(vr_qtprecal,0)) > 0 THEN
             -- Valor do atraso é essa diferença * valor da parcela
             pr_vlpreapg:= (Nvl(vr_qtmesdec,0) - Nvl(vr_qtprecal,0)) * vr_tab_crapepr(vr_index_crapepr).vlpreemp;
           ELSE
             -- Não há atraso
             pr_vlpreapg:= 0;
           END IF;
         END IF;
         -- Se a Qtde de meses decorridos for superior a qtde de parcelas do empréstimo
         -- OU Se o valor do atraso for superior ao devedor
         IF Nvl(vr_qtmesdec,0) > Nvl(vr_tab_crapepr(vr_index_crapepr).qtpreemp,0) THEN
           -- Considerar como atraso o saldo devedor calculado
           pr_vlpreapg := Nvl(vr_vlsdeved,0);
         ELSE
           IF Nvl(pr_vlpreapg,0) > Nvl(vr_vlsdeved,0) THEN
             pr_vlpreapg:= Nvl(vr_vlsdeved,0);
           END IF;
         END IF;
         -- Garantir que o valor do atraso não seja negativo
         IF pr_vlpreapg < 0 THEN
           pr_vlpreapg := 0;
         END IF;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro na execução da rotina pc_crps398.pc_calculo_a_regularizar. '||sqlerrm;
       END;


       --Procedure para gravar dados do relatorio
       PROCEDURE pc_cria_relat (pr_tpdcarta     IN INTEGER
                               ,pr_nrdconta     IN crapcdv.nrdconta%TYPE
                               ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                               ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                               ,pr_nomedes1     IN crapass.nmprimtl%TYPE
                               ,pr_nrcpfcgc     IN crawepr.dscpfav1%TYPE
                               ,pr_cdorigem     IN crapcdv.cdorigem%TYPE
                               ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                               ,pr_cdagenci     IN crapass.cdagenci%TYPE
                               ,pr_tipodeve     IN INTEGER
                               ,pr_dtar1avl     IN crapcdv.dtar1avl%TYPE
                               ,pr_dtardeve     IN crapcdv.dtardeve%TYPE
                               ,pr_dtar2avl     IN crapcdv.dtar2avl%TYPE
                               ,pr_dtslavl2     IN crapcdv.dtslavl2%TYPE
                               ,pr_dtslavl1     IN crapcdv.dtslavl1%TYPE
                               ,pr_dtsldev1     IN crapcdv.dtsldev1%TYPE
                               ,pr_dtmvtolt     IN crapcdv.dtmvtolt%TYPE
                               ,pr_des_erro     OUT varchar2) IS

         --Variaveis
         vr_vlpreapg    NUMBER;
         vr_des_erro    VARCHAR2(2000);

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

         --Montar indice da tabela memoria para ordenar por agencia, tipo carta,
         --conta associado, contrato e nome associado
         vr_index_relat:= LPad(pr_cdagenci,10,'0')||
                          LPad(pr_tpdcarta,10,'0')||
                          LPad(pr_nrdconta,10,'0')||
                          LPad(pr_cdorigem,10,'0')||
                          LPad(Nvl(pr_nrctremp,0),10,'0')||
                          RPad(pr_nomedes1,60,' ')||
                          pr_tpdcarta;

         --Popular tabela de memoria
         vr_tab_relat(vr_index_relat).tpdcarta:= pr_tpdcarta;
         vr_tab_relat(vr_index_relat).nrdconta:= pr_nrdconta;
         vr_tab_relat(vr_index_relat).vlsdeved:= pr_vlsdeved;
         vr_tab_relat(vr_index_relat).nomedes1:= pr_nomedes1;
         vr_tab_relat(vr_index_relat).nrcpfcgc:= pr_nrcpfcgc;
         vr_tab_relat(vr_index_relat).tpctrato:= pr_cdorigem;
         vr_tab_relat(vr_index_relat).qtdiatra:= pr_qtdiatra;
         vr_tab_relat(vr_index_relat).cdagenci:= pr_cdagenci;

         --SPC
         IF pr_tpdcarta = 5 THEN
           IF pr_tipodeve = 1  THEN
             vr_tab_relat(vr_index_relat).dtdevoar:= pr_dtardeve;
             vr_tab_relat(vr_index_relat).tipodeve:= 'Devedor';
           ELSIF  pr_tipodeve = 2  THEN
             vr_tab_relat(vr_index_relat).dtdevoar:= pr_dtar1avl;
             vr_tab_relat(vr_index_relat).tipodeve:= '1.Aval.';
           ELSE
             vr_tab_relat(vr_index_relat).dtdevoar:= pr_dtar2avl;
             vr_tab_relat(vr_index_relat).tipodeve:= '2.Aval.';
           END IF;
         END IF;

         --Se a origem for Conta
         IF pr_cdorigem = 1  THEN /* CL */
           vr_tab_relat(vr_index_relat).vlpreapg:= pr_vlsdeved;
         ELSE
           /* Emprestimos */

           --Montar indice para acesso na crapepr
           vr_index_crapepr:= LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0');

           vr_tab_relat(vr_index_relat).nrctremp:= pr_nrctremp;
           vr_tab_relat(vr_index_relat).cdlcremp:= vr_tab_crapepr(vr_index_crapepr).cdlcremp;
           vr_tab_relat(vr_index_relat).dtdpagto:= vr_tab_crapepr(vr_index_crapepr).dtdpagto;
           vr_tab_relat(vr_index_relat).dtmvtolt:= vr_tab_crapepr(vr_index_crapepr).dtmvtolt;

           --Inicializar valor a pagar
           vr_vlpreapg:= 0;
           --Verifica se tem saldo a regularizar
           pc_calculo_a_regularizar (pr_nrdconta => pr_nrdconta
                                    ,pr_vlpreapg => vr_vlpreapg
                                    ,pr_des_erro => vr_des_erro);
           --Se ocorreu erro
           IF trim(vr_des_erro) IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

           --Atribuir valores calculados para a tabela temporaria
           vr_tab_relat(vr_index_relat).vlpreapg:= vr_vlpreapg;
         END IF;

         /* pega a ultima data de solicitacao, se nao houver pega a data de geracao */

         --Se a data solitacao aviso 2
         IF pr_dtslavl2 IS NULL THEN
           --Se data solicitacao aviso 1 for nula
           IF pr_dtslavl1 IS NULL THEN
             --Se data solicit. devolucao 1
             IF pr_dtsldev1 IS NULL THEN
               vr_tab_relat(vr_index_relat).dtultsol:= pr_dtmvtolt;
             ELSE
               vr_tab_relat(vr_index_relat).dtultsol:= pr_dtsldev1;
             END IF;
           ELSE
             vr_tab_relat(vr_index_relat).dtultsol:= pr_dtslavl1;
           END IF;
         ELSE
           vr_tab_relat(vr_index_relat).dtultsol:= pr_dtslavl2;
         END IF;

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro na execução da rotina pc_crps398.pc_avalista. '||sqlerrm;
       END;


       --Procedure para processar avalistas
       PROCEDURE pc_avalista (pr_tipo         IN INTEGER
                             ,pr_nrdconta     IN crapcdv.nrdconta%TYPE
                             ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                             ,pr_dtspcav1     IN crapcdv.dtspcav1%TYPE
                             ,pr_dtspcav2     IN crapcdv.dtspcav2%TYPE
                             ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                             ,pr_cdorigem     IN crapcdv.cdorigem%TYPE
                             ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                             ,pr_cdagenci     IN crapass.cdagenci%TYPE
                             ,pr_tipodeve     IN INTEGER
                             ,pr_dtar1avl     IN crapcdv.dtar1avl%TYPE
                             ,pr_dtardeve     IN crapcdv.dtardeve%TYPE
                             ,pr_dtar2avl     IN crapcdv.dtar2avl%TYPE
                             ,pr_dtslavl2     IN crapcdv.dtslavl2%TYPE
                             ,pr_dtslavl1     IN crapcdv.dtslavl1%TYPE
                             ,pr_dtsldev1     IN crapcdv.dtsldev1%TYPE
                             ,pr_dtmvtolt     IN crapcdv.dtmvtolt%TYPE
                             ,pr_tpdcarta     IN INTEGER
                             ,pr_nomedes1     IN OUT crapass.nmprimtl%TYPE
                             ,pr_nrcpfcgc     IN OUT crawepr.dscpfav1%TYPE
                             ,pr_des_erro     OUT varchar2) IS

         --Variaveis locais
         vr_nrdconta_aux        INTEGER;
         -- Variaveis de Erro e Exceção
         vr_des_erro VARCHAR2(2000);
         vr_exc_erro EXCEPTION;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

         --Montar indice para acesso as tabelas de memoria
         vr_index_crapepr_aval:= LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0');

         /* AVALISTA 1 */
         IF pr_tipo IN (0,1) THEN
           --Atribuir a conta que acessa a crapass
           vr_nrdconta_aux:= vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1;

           IF (vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 <> 0 AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 IS NOT NULL AND
               vr_tab_crawepr(vr_index_crapepr_aval).nmdaval1 =  ' ') OR
              (vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 <> 0 AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 IS NOT NULL AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 = vr_tab_crawepr(vr_index_crapepr_aval).nrctaav1) THEN
             --Verificar os dados do associado
             IF vr_tab_crapass(vr_nrdconta_aux).inpessoa <> 3 THEN
               IF pr_tpdcarta = 5 AND vr_tab_crapass(vr_nrdconta_aux).inadimpl > 0 THEN
                 NULL;
               ELSE
                 --Retornar nome primeiro titular
                 pr_nomedes1:= vr_tab_crapass(vr_nrdconta_aux).nmprimtl;
                 --Retornar cpf primeiro titular
                 pr_nrcpfcgc:= GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta_aux).nrcpfcgc,vr_tab_crapass(vr_nrdconta_aux).inpessoa);

                 --Gravar cria relatorio
                 pc_cria_relat (pr_tpdcarta => pr_tpdcarta
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_vlsdeved => pr_vlsdeved
                               ,pr_nomedes1 => pr_nomedes1
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_cdorigem => pr_cdorigem
                               ,pr_qtdiatra => pr_qtdiatra
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_tipodeve => pr_tipodeve
                               ,pr_dtar1avl => pr_dtar1avl
                               ,pr_dtardeve => pr_dtardeve
                               ,pr_dtar2avl => pr_dtar2avl
                               ,pr_dtslavl2 => pr_dtslavl2
                               ,pr_dtslavl1 => pr_dtslavl1
                               ,pr_dtsldev1 => pr_dtsldev1
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_des_erro => vr_des_erro);
                 --Se ocorreu erro
                 IF trim(vr_des_erro) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;
               END IF;
             END IF;
           ELSE
             --Se o nome do avalista 1 nao for nulo
             IF vr_tab_crawepr(vr_index_crapepr_aval).nmdaval1 <> ' ' THEN
               --Se a data de SPC aviso 1 estiver preenchida e for tipo 5
               IF pr_dtspcav1 IS NOT NULL AND pr_tpdcarta = 5  THEN /* Ja incluso SPC */
                 NULL;
               ELSE
                 --Retornar nome avalista 1
                 pr_nomedes1:= '';
                 pr_nrcpfcgc:= 0;
                 -- Verifica se o avalista 1, eh cooperado, caso for, vamos pegar o cpf/cnpj da conta
                 IF vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 > 0 THEN
                   pr_nrcpfcgc := GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta_aux).nrcpfcgc,vr_tab_crapass(vr_nrdconta_aux).inpessoa);
                   pr_nomedes1 := vr_tab_crapass(vr_nrdconta_aux).nmprimtl;
                 ELSE -- Avalista 1
                   vr_index_crapavt := LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0')||'01';
                   -- Verifica se o contrato possui avalista 1 cadastrado
                   IF vr_tab_crapavt.EXISTS(vr_index_crapavt) THEN
                     -- Formata o CPF informado na tela do avalista 1
                     pr_nrcpfcgc := GENE0002.fn_mask_cpf_cnpj(vr_tab_crapavt(vr_index_crapavt).nrcpfcgc,1);
                     pr_nomedes1 := vr_tab_crapavt(vr_index_crapavt).nmdavali;
                   END IF;
                 END IF;

                 --Gravar cria relatorio
                 pc_cria_relat (pr_tpdcarta => pr_tpdcarta
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_vlsdeved => pr_vlsdeved
                               ,pr_nomedes1 => pr_nomedes1
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_cdorigem => pr_cdorigem
                               ,pr_qtdiatra => pr_qtdiatra
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_tipodeve => pr_tipodeve
                               ,pr_dtar1avl => pr_dtar1avl
                               ,pr_dtardeve => pr_dtardeve
                               ,pr_dtar2avl => pr_dtar2avl
                               ,pr_dtslavl2 => pr_dtslavl2
                               ,pr_dtslavl1 => pr_dtslavl1
                               ,pr_dtsldev1 => pr_dtsldev1
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_des_erro => vr_des_erro);
                 --Se ocorreu erro
                 IF trim(vr_des_erro) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;
               END IF;
             END IF;
           END IF;
         END IF;

         /* AVALISTA 2 */
         IF pr_tipo IN (0,2) THEN
           --Atribuir a conta que acessa a crapass
           vr_nrdconta_aux:= vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2;

           IF (vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 <> 0 AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 IS NOT NULL AND
               vr_tab_crawepr(vr_index_crapepr_aval).nmdaval2 =  ' ') OR
              (vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 <> 0 AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 IS NOT NULL AND
               vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 = vr_tab_crawepr(vr_index_crapepr_aval).nrctaav2) THEN
             --Verificar os dados do associado
             IF vr_tab_crapass(vr_nrdconta_aux).inpessoa <> 3 THEN
               IF pr_tpdcarta = 5 AND vr_tab_crapass(vr_nrdconta_aux).inadimpl > 0 THEN
                 NULL;
               ELSE
                 --Retornar nome primeiro titular
                 pr_nomedes1:= vr_tab_crapass(vr_nrdconta_aux).nmprimtl;
                 --Retornar cpf primeiro titular
                 pr_nrcpfcgc:= GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta_aux).nrcpfcgc,vr_tab_crapass(vr_nrdconta_aux).inpessoa);

                 --Gravar cria relatorio
                 pc_cria_relat (pr_tpdcarta => pr_tpdcarta
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_vlsdeved => pr_vlsdeved
                               ,pr_nomedes1 => pr_nomedes1
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_cdorigem => pr_cdorigem
                               ,pr_qtdiatra => pr_qtdiatra
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_tipodeve => pr_tipodeve
                               ,pr_dtar1avl => pr_dtar1avl
                               ,pr_dtardeve => pr_dtardeve
                               ,pr_dtar2avl => pr_dtar2avl
                               ,pr_dtslavl2 => pr_dtslavl2
                               ,pr_dtslavl1 => pr_dtslavl1
                               ,pr_dtsldev1 => pr_dtsldev1
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_des_erro => vr_des_erro);
                 --Se ocorreu erro
                 IF trim(vr_des_erro) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;
               END IF;
             END IF;
           ELSE
             --Se o nome do avalista 1 nao for nulo
             IF vr_tab_crawepr(vr_index_crapepr_aval).nmdaval2 <> ' ' THEN
               --Se a data de SPC aviso 1 estiver preenchida e for tipo 5
               IF pr_dtspcav2 IS NOT NULL AND pr_tpdcarta = 5  THEN /* Ja incluso SPC */
                 NULL;
               ELSE
                 --Retornar nome avalista 2
                 pr_nomedes1:= '';
                 pr_nrcpfcgc:= 0;
                 -- Verifica se o avalista 2, eh cooperado, caso for, vamos pegar o cpf/cnpj da conta
                 IF vr_tab_crapepr(vr_index_crapepr_aval).nrctaav2 > 0 THEN
                   pr_nrcpfcgc := GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta_aux).nrcpfcgc,vr_tab_crapass(vr_nrdconta_aux).inpessoa);
                   pr_nomedes1 := vr_tab_crapass(vr_nrdconta_aux).nmprimtl;
                 ELSE -- Avalista 2
                   -- Indice da tabela de memoria
                   vr_index_crapavt := LPad(pr_nrdconta,10,'0')||LPad(pr_nrctremp,10,'0');
                   -- Vamos verificar se existe o primeiro avalista
                   IF vr_tab_crapepr(vr_index_crapepr_aval).nrctaav1 > 0 OR vr_tab_crawepr(vr_index_crapepr_aval).nmdaval1 = ' ' THEN
                     vr_index_crapavt := vr_index_crapavt||'01';
                   ELSE -- Senão a sequencia é 2
                     vr_index_crapavt := vr_index_crapavt||'02';
                   END IF;
                   -- Verifica se o contrato possui avalista 2 cadastrado
                   IF vr_tab_crapavt.EXISTS(vr_index_crapavt) THEN
                     -- Formata o CPF informado na tela do avalista 2
                     pr_nrcpfcgc := GENE0002.fn_mask_cpf_cnpj(vr_tab_crapavt(vr_index_crapavt).nrcpfcgc,1);
                     pr_nomedes1 := vr_tab_crapavt(vr_index_crapavt).nmdavali;
                   END IF;
                 END IF;

                 --Gravar cria relatorio
                 pc_cria_relat (pr_tpdcarta => pr_tpdcarta
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_vlsdeved => pr_vlsdeved
                               ,pr_nomedes1 => pr_nomedes1
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_cdorigem => pr_cdorigem
                               ,pr_qtdiatra => pr_qtdiatra
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_tipodeve => pr_tipodeve
                               ,pr_dtar1avl => pr_dtar1avl
                               ,pr_dtardeve => pr_dtardeve
                               ,pr_dtar2avl => pr_dtar2avl
                               ,pr_dtslavl2 => pr_dtslavl2
                               ,pr_dtslavl1 => pr_dtslavl1
                               ,pr_dtsldev1 => pr_dtsldev1
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_des_erro => vr_des_erro);
                 --Se ocorreu erro
                 IF trim(vr_des_erro) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;
               END IF;
             END IF;
           END IF;
         END IF;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro na execução da rotina pc_crps398.pc_avalista. '||pr_nrdconta||Chr(10)||sqlerrm;
       END;


       --Geração do relatório crrl362
       PROCEDURE pc_imprime_crrl362 (pr_des_erro OUT VARCHAR2) IS

         --Tipo de tabela local
         TYPE typ_tab_crrl362 IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
         --Vetor para agencias com dados para relatorio crrl362
         vr_tab_crrl362 typ_tab_crrl362;

         --Variaveis Locais
         vr_cdagenci  INTEGER;
         vr_dsorigem  VARCHAR2(2);
         vr_imprimspc VARCHAR2(1);
         vr_pula      BOOLEAN;
         vr_flgarqtx  BOOLEAN:= FALSE;
         vr_des_erro  VARCHAR2(2000);

          --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_nom_direto     VARCHAR2(100);
         vr_nom_direto_txt VARCHAR2(100);
         vr_nom_direto_cp  VARCHAR2(100);
         vr_nom_arquivo    VARCHAR2(100);
         vr_dstpdcarta     VARCHAR2(100);
         vr_comando        VARCHAR2(100);
         vr_nmarqtxt       VARCHAR2(20):= 'crrl362.txt';
         vr_typ_saida      VARCHAR2(4000);
         vr_setlinha       VARCHAR2(4000);
         vr_input_file     utl_file.file_type;

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

         --Limpar tabela agencias
         vr_tab_crrl362.DELETE;

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         vr_nom_direto_txt := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => '/arq'); --> Utilizaremos o rl


         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl362><agencias>');

         --Acessar primeiro registro da tabela de memoria
         vr_index_relat:= vr_tab_relat.FIRST;
         WHILE vr_index_relat IS NOT NULL  LOOP
           BEGIN
             --Atribuir o codigo da agencia
             vr_cdagenci:= vr_tab_relat(vr_index_relat).cdagenci;
             -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
             IF vr_index_relat = vr_tab_relat.FIRST OR vr_cdagenci <> vr_tab_relat(vr_tab_relat.PRIOR(vr_index_relat)).cdagenci THEN

               -- Adicionar o nó da agência e já iniciar o de aplicações
               pc_escreve_xml('<agencia cdagenci="'||vr_cdagenci||'">');

               --Criar arquivo de dados crrl362.txt uma unica vez
               IF vr_flgarqtx = FALSE THEN

                 -- Tenta abrir o arquivo de log em modo gravacao
                 gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto_txt --> Diretório do arquivo
                                         ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                         ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                         ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                         ,pr_des_erro => vr_des_erro);  --> Erro
                 IF trim(vr_des_erro) IS NOT NULL THEN
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                 END IF;

                 vr_setlinha:= 'PA;Conta/DV;Contrato;Lin;Org;ATR;Saldo Dev.;' ||
                               'Destinatario;CPF;Dt.Ctrato;Ult.Vcto;A Regular.;' ||
                               'Devol.AR;Ident.';
                 --Escrever o cabecalho no arquivo
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto para escrita

                 --Atribuir true para não criar novamente arquivo
                 vr_flgarqtx:= TRUE;
               END IF;
             END IF;

             vr_pula:= FALSE;
             --Determinar a origem
             IF vr_tab_relat(vr_index_relat).tpctrato = 1 THEN
               vr_dsorigem:= 'CL';
             ELSE
               IF vr_tab_relat(vr_index_relat).tpctrato = 3 THEN
                 IF Nvl(vr_tab_relat(vr_index_relat).vlpreapg,0) = 0 THEN
                   vr_pula:= TRUE;
                 ELSE
                   vr_dsorigem:= 'EP';
                 END IF;
               END IF;
             END IF;

             IF NOT vr_pula THEN

               --Popular vetor com agencias que possuem dados para relatorio crrl362
               vr_tab_crrl362(vr_tab_relat(vr_index_relat).cdagenci):= 1;

               --Nao imprimir informacao spc
               vr_imprimspc:= 'N';
               --Se for tipo de carta 5 escreve no arquivo txt
               IF vr_tab_relat(vr_index_relat).tpdcarta = 5 THEN

                 --Determinar se imprime colunas spc
                 vr_imprimspc:= 'S';
                 --Montar linha de dados para arquivo txt
                 vr_setlinha:= LPad(vr_tab_relat(vr_index_relat).cdagenci,2,' ') ||';'||
                               LPad(GENE0002.fn_mask_conta(vr_tab_relat(vr_index_relat).nrdconta),10,' ') ||';'||
                               RPad(vr_tab_relat(vr_index_relat).nrctremp,8,' ') ||';'||
                               RPad(vr_tab_relat(vr_index_relat).cdlcremp,8,' ') ||';'||
                               vr_dsorigem ||';'||
                               LPad(vr_tab_relat(vr_index_relat).qtdiatra,4,'0') ||';'||
                               LPad(To_Char(vr_tab_relat(vr_index_relat).vlsdeved,'999g990d00'),15,' ') ||' ;'||
                               RPad(vr_tab_relat(vr_index_relat).nomedes1,70,' ') ||';'||
                               RPad(vr_tab_relat(vr_index_relat).nrcpfcgc,35,' ') ||';'||
                               To_Char(vr_tab_relat(vr_index_relat).dtmvtolt,'DD/MM/RRRR') ||';'||
                               To_Char(vr_tab_relat(vr_index_relat).dtdpagto,'DD/MM/RRRR') ||';'||
                               LPad(To_Char(vr_tab_relat(vr_index_relat).vlpreapg,'999g990d00'),15,' ') ||';'||
                               To_Char(vr_tab_relat(vr_index_relat).dtdevoar,'DD/MM/RRRR') ||';'||
                               vr_tab_relat(vr_index_relat).tipodeve;
                 --Escrever a string no arquivo
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto para escrita
               END IF; -- tpdcarta = 5

               --Determinar a descricao do tipo de carta
               vr_dstpdcarta:= 'PA - '||vr_cdagenci||'   '||vr_tab_dstpcarta(vr_tab_relat(vr_index_relat).tpdcarta);
               --Montar tag da conta para arquivo XML
               pc_escreve_xml
               ('<conta>
                  <cdagenci>'||vr_cdagenci||'</cdagenci>
                  <tpdcarta>'||vr_tab_relat(vr_index_relat).tpdcarta||'</tpdcarta>
                  <dstpdcarta>'||vr_dstpdcarta||'</dstpdcarta>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_relat(vr_index_relat).nrdconta)||'</nrdconta>
                  <nrctremp>'||vr_tab_relat(vr_index_relat).nrctremp||'</nrctremp>
                  <cdlcremp>'||vr_tab_relat(vr_index_relat).cdlcremp||'</cdlcremp>
                  <dsorigem>'||vr_dsorigem||'</dsorigem>
                  <qtdiatra>'||vr_tab_relat(vr_index_relat).qtdiatra||'</qtdiatra>
                  <vlsdeved>'||To_Char(vr_tab_relat(vr_index_relat).vlsdeved,'999g990d00')||'</vlsdeved>
                  <nomedes1>'||SubStr(vr_tab_relat(vr_index_relat).nomedes1,1,27)||'</nomedes1>
                  <nrcpfcgc>'||vr_tab_relat(vr_index_relat).nrcpfcgc||'</nrcpfcgc>
                  <dtmvtolt>'||To_Char(vr_tab_relat(vr_index_relat).dtmvtolt,'DD/MM/RR')||'</dtmvtolt>
                  <dtdpagto>'||To_Char(vr_tab_relat(vr_index_relat).dtdpagto,'DD/MM/RR')||'</dtdpagto>
                  <vlpreapg>'||To_Char(vr_tab_relat(vr_index_relat).vlpreapg,'999g990d00')||'</vlpreapg>
                  <dtdevoar>'||To_Char(vr_tab_relat(vr_index_relat).dtdevoar,'DD/MM/RR')||'</dtdevoar>
                  <tipodeve>'||vr_tab_relat(vr_index_relat).tipodeve||'</tipodeve>
                  <spc>'||vr_imprimspc||'</spc>
               </conta>');

             END IF; --vr_pula

             IF vr_index_relat = vr_tab_relat.LAST OR vr_cdagenci <> vr_tab_relat(vr_tab_relat.NEXT(vr_index_relat)).cdagenci THEN
               --Finalizar tag contas e agencia
               pc_escreve_xml('</agencia>');
             END IF;

             --Encontrar o proximo registro da tabela de memoria
             vr_index_relat:= vr_tab_relat.NEXT(vr_index_relat);
           EXCEPTION
             WHEN vr_exc_pula THEN
               NULL;
             WHEN vr_exc_erro THEN
               RAISE vr_exc_erro;
             WHEN OTHERS THEN
               --Montar mensagem erro
               vr_des_erro:= 'Erro ao gerar relatório crrl362. '||sqlerrm;
               RAISE vr_exc_erro;
           END;
         END LOOP;

         --Finalizar tags do relatorio
         pc_escreve_xml('</agencias></crrl362>');

         /* Percorrer todas as agencias submetendo o xml dessa agencia */

         --Acessar primeiro registro da tabela de memoria
         vr_index_relat:= vr_tab_relat.FIRST;
         WHILE vr_index_relat IS NOT NULL  LOOP

           --Atribuir o codigo da agencia
           vr_cdagenci:= vr_tab_relat(vr_index_relat).cdagenci;

           --Gerar o arquivo somente uma vez por agencia e se tiver dados
           IF vr_tab_crrl362.EXISTS(vr_cdagenci) AND
              (vr_index_relat = vr_tab_relat.FIRST OR
              vr_cdagenci <> vr_tab_relat(vr_tab_relat.PRIOR(vr_index_relat)).cdagenci) THEN
             --Determinar o nome do arquivo que será gerado
             vr_nom_arquivo := 'crrl362_'||To_Char(vr_cdagenci,'fm009');

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl362/agencias/agencia[@cdagenci='||vr_cdagenci||']/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl362.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Enviar como parâmetro apenas o titulo
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                        ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                        ,pr_nrcopias  => 1                   --> Número de cópias
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro
             -- Testar se houve erro
             IF trim(vr_des_erro) IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_erro;
             END IF;
           END IF;
           --Encontrar o proximo registro da tabela de memoria
           vr_index_relat:= vr_tab_relat.NEXT(vr_index_relat);
         END LOOP;

         /* Gerar relatorio crrl362_99.lst */

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl362/agencias/agencia/conta' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl362.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Enviar como parâmetro apenas o titulo
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||'crrl362_'
                                                                  ||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Testar se houve erro
         IF trim(vr_des_erro) IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

         --Fechar Arquivo de dados
         BEGIN
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
         EXCEPTION
           WHEN OTHERS THEN
             -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
             vr_des_erro := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
             RAISE vr_exc_erro;
         END;

         --Se gerou arquivo crrl362.txt
         IF vr_flgarqtx THEN

           --Se for cooperativa viacredi ou creditextil
           IF pr_cdcooper IN (1,2) THEN

             --Recuperar o diretorio micros de destino
             vr_nom_direto_cp:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_COPIA_CRRL362');

             --Copiar arquivos convertendo para DOS
             vr_comando:= 'ux2dos ' ||vr_nom_direto_txt||'/'||vr_nmarqtxt ||' > '||vr_nom_direto_cp||'/'||vr_nmarqtxt;
             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_setlinha);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_des_erro:= 'Não foi possível executar comando ux2dos> '||vr_comando||' '||vr_setlinha;
                RAISE vr_exc_erro;
              END IF;

             --Mover arquivos para a salvar
             vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => '/salvar'); --> Utilizaremos o rl


             vr_comando:= 'mv ' ||vr_nom_direto_txt||'/'||vr_nmarqtxt ||' '||vr_nom_direto;
             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_setlinha);
              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                vr_des_erro:= 'Não foi possível executar comando unix. '||vr_comando||' '||vr_setlinha;
                RAISE vr_exc_erro;
              END IF;

           END IF;
         END IF;

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl362. '||sqlerrm;
       END;


       --Geração do relatório crrl369 - cartas com solicitação em atraso
       PROCEDURE pc_imprime_crrl369 (pr_des_erro OUT VARCHAR2) IS

         --Variaveis Locais
         vr_cdagenci  INTEGER;
         vr_dsorigem  VARCHAR2(2);
         vr_des_erro  VARCHAR2(2000);

          --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_nom_direto     VARCHAR2(100);
         vr_nom_arquivo    VARCHAR2(100);
         vr_dstpdcarta     VARCHAR2(100);

       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= ' ';

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl


         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl369><contas>');
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl369';

         --Acessar primeiro registro da tabela de memoria
         vr_index_relat:= vr_tab_relat.FIRST;
         WHILE vr_index_relat IS NOT NULL  LOOP
           --Atribuir o codigo da agencia
           vr_cdagenci:= vr_tab_relat(vr_index_relat).cdagenci;

           --Determinar a origem
           IF vr_tab_relat(vr_index_relat).tpctrato = 1   THEN
             vr_dsorigem:= 'CL';
           ELSIF vr_tab_relat(vr_index_relat).tpctrato = 3 THEN
             vr_dsorigem:= 'EP';
           END IF;

           --Determinar a descricao do tipo de carta
           vr_dstpdcarta:= 'PA - '||vr_tab_relat(vr_index_relat).cdagenci||'   '||
                           vr_tab_dstpcarta(vr_tab_relat(vr_index_relat).tpdcarta);

           --Montar tag da conta para arquivo XML
           pc_escreve_xml
               ('<conta>
                  <cdagenci>'||vr_tab_relat(vr_index_relat).cdagenci||'</cdagenci>
                  <tpdcarta>'||vr_tab_relat(vr_index_relat).tpdcarta||'</tpdcarta>
                  <dstpdcarta>'||vr_dstpdcarta||'</dstpdcarta>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_relat(vr_index_relat).nrdconta)||'</nrdconta>
                  <nrctremp>'||vr_tab_relat(vr_index_relat).nrctremp||'</nrctremp>
                  <cdlcremp>'||vr_tab_relat(vr_index_relat).cdlcremp||'</cdlcremp>
                  <dsorigem>'||vr_dsorigem||'</dsorigem>
                  <qtdiatra>'||vr_tab_relat(vr_index_relat).qtdiatra||'</qtdiatra>
                  <vlsdeved>'||To_Char(vr_tab_relat(vr_index_relat).vlsdeved,'999g990d00')||'</vlsdeved>
                  <nomedes1>'||SubStr(vr_tab_relat(vr_index_relat).nomedes1,1,30)||'</nomedes1>
                  <nrcpfcgc>'||vr_tab_relat(vr_index_relat).nrcpfcgc||'</nrcpfcgc>
                  <dtultsol>'||To_Char(vr_tab_relat(vr_index_relat).dtultsol,'DD/MM/RR')||'</dtultsol>
               </conta>');

           --Encontrar o proximo registro da tabela de memoria
           vr_index_relat:= vr_tab_relat.NEXT(vr_index_relat);
         END LOOP;

         -- Finalizar o agrupador de agencias
         pc_escreve_xml('</contas></crrl369>');

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl369/contas/conta' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl369.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Enviar como parâmetro apenas o titulo
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Testar se houve erro
         IF trim(vr_des_erro) IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl369. '||sqlerrm;
       END;
     ---------------------------------------
     -- Inicio Bloco Principal pc_crps398
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS398';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS398'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1 -- Fixo
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela de memoria de saldos diarios
       FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
         --Popular vetor de memoria
         vr_tab_crapsld(rw_crapsld.nrdconta).dtdsdclq:= rw_crapsld.dtdsdclq;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp:= rw_crapsld.vlsddisp;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl:= rw_crapsld.vlsdchsl;
         vr_tab_crapsld(rw_crapsld.nrdconta).qtddsdev:= rw_crapsld.qtddsdev;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq:= rw_crapsld.vlsdbloq;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr:= rw_crapsld.vlsdblpr;
         vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp:= rw_crapsld.vlsdblfp;
       END LOOP;

       --Carregar tabela de emprestimos
       FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper) LOOP
         --Montar indice para tabela memoria
         vr_index_crapepr:= LPad(rw_crapepr.nrdconta,10,'0')||LPad(rw_crapepr.nrctremp,10,'0');
         vr_tab_crapepr(vr_index_crapepr).dtultpag:= rw_crapepr.dtultpag;
         vr_tab_crapepr(vr_index_crapepr).inliquid:= rw_crapepr.inliquid;
         vr_tab_crapepr(vr_index_crapepr).vlsdeved:= rw_crapepr.vlsdeved;
         vr_tab_crapepr(vr_index_crapepr).nrctaav1:= rw_crapepr.nrctaav1;
         vr_tab_crapepr(vr_index_crapepr).nrctaav2:= rw_crapepr.nrctaav2;
         vr_tab_crapepr(vr_index_crapepr).cdlcremp:= rw_crapepr.cdlcremp;
         vr_tab_crapepr(vr_index_crapepr).dtdpagto:= rw_crapepr.dtdpagto;
         vr_tab_crapepr(vr_index_crapepr).dtmvtolt:= rw_crapepr.dtmvtolt;
         vr_tab_crapepr(vr_index_crapepr).txjuremp:= rw_crapepr.txjuremp;
         vr_tab_crapepr(vr_index_crapepr).vljuracu:= rw_crapepr.vljuracu;
         vr_tab_crapepr(vr_index_crapepr).qtprecal:= rw_crapepr.qtprecal;
         vr_tab_crapepr(vr_index_crapepr).qtpreemp:= rw_crapepr.qtpreemp;
         vr_tab_crapepr(vr_index_crapepr).flgpagto:= rw_crapepr.flgpagto;
         vr_tab_crapepr(vr_index_crapepr).qtmesdec:= rw_crapepr.qtmesdec;
         vr_tab_crapepr(vr_index_crapepr).vlpreemp:= rw_crapepr.vlpreemp;
         vr_tab_crapepr(vr_index_crapepr).qtprepag:= rw_crapepr.qtprepag;
       END LOOP;

       --Carregar tabela de emprestimos crawepr
       FOR rw_crawepr IN cr_crawepr (pr_cdcooper => pr_cdcooper) LOOP
         --Montar indice para tabela memoria
         vr_index_crawepr:= LPad(rw_crawepr.nrdconta,10,'0')||LPad(rw_crawepr.nrctremp,10,'0');
         vr_tab_crawepr(vr_index_crawepr).nmdaval1:= rw_crawepr.nmdaval1;
         vr_tab_crawepr(vr_index_crawepr).nmdaval2:= rw_crawepr.nmdaval2;
         vr_tab_crawepr(vr_index_crawepr).nrctaav1:= rw_crawepr.nrctaav1;
         vr_tab_crawepr(vr_index_crawepr).nrctaav2:= rw_crawepr.nrctaav2;
         vr_tab_crawepr(vr_index_crawepr).dtdpagto:= rw_crawepr.dtdpagto;
       END LOOP;

       --Carregar tabela de emprestimos crapavt
       FOR rw_crapavt IN cr_crapavt (pr_cdcooper => pr_cdcooper) LOOP
         --Montar indice para tabela memoria
         vr_index_crapavt:= LPad(rw_crapavt.nrdconta,10,'0')||LPad(rw_crapavt.nrctremp,10,'0')||LPad(rw_crapavt.nrseqava,2,'0');
         vr_tab_crapavt(vr_index_crapavt).nrcpfcgc := rw_crapavt.nrcpfcgc;
         vr_tab_crapavt(vr_index_crapavt).nmdavali := rw_crapavt.nmdavali;
       END LOOP;

       --Carregar tabela de memoria de associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).inadimpl:= rw_crapass.inadimpl;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc:= rw_crapass.nrcpfcgc;
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
       END LOOP;

       --Carregar tabela de memoria de linhas de credito
       FOR rw_craplcr IN cr_craplcr (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craplcr(rw_craplcr.cdlcremp):= rw_craplcr.txdiaria;
       END LOOP;

       --Carregar tabela de memoria de titulares
       FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapttl(rw_crapttl.nrdconta):= rw_crapttl.cdempres;
       END LOOP;

       --Carregar tabela de memoria de pessoas juridicas
       FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapjur(rw_crapjur.nrdconta):= rw_crapjur.cdempres;
       END LOOP;

       --Carregar tabela de memoria dos dias de pagamento por empresa
       FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 0
                                    ,pr_cdacesso => 'DIADOPAGTO') LOOP
         vr_tab_craptab(rw_craptab.tpregist).mensal:= To_Number(SubStr(rw_craptab.dstextab,4,2));
         vr_tab_craptab(rw_craptab.tpregist).horas:= To_Number(SubStr(rw_craptab.dstextab,7,2));
       END LOOP;

       --Selecionar informacoes dos dias para as cartas
       vr_dstextab_carta:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'USUARI'
                                                     ,pr_cdempres => 11
                                                     ,pr_cdacesso => 'DIASCARTAS'
                                                     ,pr_tpregist => 1);

       --Se encontrou valor para os dias
       IF trim(vr_dstextab_carta) IS NOT NULL THEN
         vr_dia1cardve:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,1,3));
         vr_dia2cardve:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,5,3));
         vr_dia2carave:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,9,3));
         vr_diaspcempr:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,13,3));
         vr_dia1cardvc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,17,3));
         vr_dia2cardvc:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,21,3));
         vr_diaspccl  := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,25,3));

         IF UPPER(SUBSTR(vr_dstextab_carta,37,3)) = 'NAO' THEN
           vr_flgenvar:= FALSE;
         ELSE
           vr_flgenvar:= TRUE;
         END IF;
         --Se nao deve enviar aviso recebimento
         IF NOT vr_flgenvar THEN
           --Atribuir dias aviso recebimento
           vr_qtdiasar:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_carta,41,3));
           vr_stininar:= SUBSTR(vr_dstextab_carta,45,10);
           vr_dtininar:= TO_DATE(SUBSTR(vr_stininar, 1,2) || '/' ||
                                 SUBSTR(vr_stininar, 4,2) || '/' ||
                                 SUBSTR(vr_stininar, 7,4),'DD/MM/YYYY');
         END IF;
       END IF;

       /*--- Atualizar Saldo Devedores ---*/

       FOR rw_crapcdv IN cr_crapcdv (pr_cdcooper => pr_cdcooper) LOOP
         --Verificar se existe saldo diario
         IF rw_crapcdv.cdorigem = 1 AND vr_tab_crapsld.EXISTS(rw_crapcdv.nrdconta) THEN
           --Se a data data credito liquidacao for nula ou diferente ultimo pagamento
           IF vr_tab_crapsld(rw_crapcdv.nrdconta).dtdsdclq IS NULL OR
              vr_tab_crapsld(rw_crapcdv.nrdconta).dtdsdclq <> rw_crapcdv.dtultpag THEN
             --Atualizar data liquidacao
             BEGIN
               UPDATE crapcdv SET crapcdv.dtliquid = rw_crapdat.dtmvtolt
               WHERE crapcdv.ROWID = rw_crapcdv.ROWID;
             EXCEPTION
               WHEN OTHERS THEN
                 --Montar Mensagem erro
                 vr_dscritic:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
           END IF;
         ELSE
           --Montar indice acesso para crapepr
           vr_index_crapepr:= LPad(rw_crapcdv.nrdconta,10,'0')||LPad(rw_crapcdv.nrctremp,10,'0');
           IF rw_crapcdv.cdorigem = 3 AND vr_tab_crapepr.EXISTS(vr_index_crapepr) THEN
             --Se a data do ultimo pagamento for diferente ou for liquidado ou saldo devedor =0
             IF vr_tab_crapepr(vr_index_crapepr).dtultpag <> rw_crapcdv.dtultpag OR
                vr_tab_crapepr(vr_index_crapepr).inliquid = 1 OR
                vr_tab_crapepr(vr_index_crapepr).vlsdeved = 0 THEN
               --Atualizar data liquidacao
               BEGIN
                 UPDATE crapcdv SET crapcdv.dtliquid = vr_tab_crapepr(vr_index_crapepr).dtultpag
                 WHERE crapcdv.ROWID = rw_crapcdv.ROWID;
               EXCEPTION
                 WHEN OTHERS THEN
                   --Montar Mensagem erro
                   vr_dscritic:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
             END IF;
           END IF;
         END IF;
       END LOOP; --rw_crapcdv

       /*------ Gerar Base Dividas -----*/

       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         --Zerar variaveis
         vr_vlutiliz:= 0;
         vr_vldivida:= 0;

         /* Saldo Conta Corrente */
         vr_vlsddisp:= Nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp,0) +
                       Nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl,0);
         --Se o valor disponivel for negativo
         IF vr_vlsddisp < 0 THEN

           --Valor bloqueado recebe bloqueado + bloq. praca + bloq. fora praca
           vr_vlbloque:= Nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsdbloq,0) +
                         Nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsdblpr,0) +
                         Nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsdblfp,0);
           --Zerar valor risco e da divida
           vr_vlsrisco:= 0;
           vr_vldivida:= 0;
           --Valor limite recebe o limite do associado
           vr_vllimcre:= rw_crapass.vllimcre;
           --Valor da divida recebe valor disponivel * -1
           vr_vldivida:= vr_vlsddisp * -1;

           --Se o valor da dívida e o limite forem > 0
           IF vr_vldivida > 0 AND vr_vllimcre > 0 THEN
             --Se o valor da divida < limite
             IF vr_vldivida < vr_vllimcre THEN
               --Valor risco recebe valor divida
               vr_vlsrisco:= vr_vldivida;
               --Zerar valor divida
               vr_vldivida:= 0;
             ELSE
               --Valor risco recebe valor limite credito
               vr_vlsrisco:= vr_vllimcre;
               --Valor divida recebe divida menos limite
               vr_vldivida:= vr_vldivida - vr_vllimcre;
             END IF;
           END IF;

           --Se o valor da dívida e o valor bloqueado forem > 0
           IF vr_vldivida > 0 AND vr_vlbloque > 0 THEN
             --Se o valor da divida < bloqueado
             IF vr_vldivida < vr_vlbloque THEN
               --Valor risco recebe valor divida
               vr_vlsrisco:= vr_vldivida;
               --Zerar valor divida
               vr_vldivida:= 0;
             ELSE
               --Valor risco recebe valor bloqueado
               vr_vlsrisco:= vr_vlbloque;
               --Valor divida recebe divida menos bloqueado
               vr_vldivida:= vr_vldivida - vr_vlbloque;
             END IF;
           END IF;

           --Se o valor da dívida > 0 e a data liquidacao nao for nula
           IF vr_vldivida > 0 AND vr_tab_crapsld(rw_crapass.nrdconta).dtdsdclq IS NOT NULL THEN

             /* Primeira carta CL  */
             IF vr_tab_crapsld(rw_crapass.nrdconta).qtddsdev >= vr_dia1cardvc THEN
               --Selecionar ultimo cadastro devedor
               OPEN cr_crapcdv_last (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_nrctremp => rw_crapass.nrdconta
                                    ,pr_cdorigem => 1);
               FETCH cr_crapcdv_last INTO rw_crapcdv_last;
               IF cr_crapcdv_last%NOTFOUND OR rw_crapcdv_last.dtliquid IS NOT NULL THEN
                 BEGIN
                   INSERT INTO crapcdv (crapcdv.nrdconta
                                       ,crapcdv.nrctremp
                                       ,crapcdv.cdorigem
                                       ,crapcdv.dtmvtolt
                                       ,crapcdv.flgenvio
                                       ,crapcdv.cdcooper
                                       ,crapcdv.vlsdeved
                                       ,crapcdv.dtultpag
                                       ,crapcdv.qtdiatra)
                   VALUES              (nvl(rw_crapass.nrdconta,0)
                                       ,nvl(rw_crapass.nrdconta,0)
                                       ,1
                                       ,rw_crapdat.dtmvtolt
                                       ,1
                                       ,pr_cdcooper
                                       ,nvl(vr_vldivida,0)
                                       ,vr_tab_crapsld(rw_crapass.nrdconta).dtdsdclq
                                       ,nvl(vr_tab_crapsld(rw_crapass.nrdconta).qtddsdev,0));
                 EXCEPTION
                   WHEN OTHERS THEN
                     --Fechar Cursor
                     CLOSE cr_crapcdv_last;

                     vr_dscritic := 'Erro ao inserir tabela crapcdv. '||SQLERRM;
                     RAISE vr_exc_saida;
                 END;
               ELSE
                 --Atualizar tabela crapcdv
                 BEGIN
                   UPDATE crapcdv SET crapcdv.vlsdeved = nvl(vr_vldivida,0)
                                     ,crapcdv.dtultpag = vr_tab_crapsld(rw_crapass.nrdconta).dtdsdclq
                                     ,crapcdv.qtdiatra = vr_tab_crapsld(rw_crapass.nrdconta).qtddsdev
                   WHERE crapcdv.ROWID = rw_crapcdv_last.ROWID;
                 EXCEPTION
                   WHEN OTHERS THEN
                     --Fechar Cursor
                     CLOSE cr_crapcdv_last;
                     vr_dscritic := 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                     RAISE vr_exc_saida;
                 END;
               END IF;
               --Fechar Cursor
               CLOSE cr_crapcdv_last;
             END IF;
           END IF;
         END IF;

         /*------Risco Emprestimos ---------------------------------*/
         FOR rw_crapepr IN cr_crapepr_risco (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta
                                            ,pr_inliquid => 0
                                            ,pr_inprejuz => 0) LOOP

           --Executar rotina verificação dias atraso
           EMPR0001.pc_calc_dias_atraso (pr_cdcooper   => pr_cdcooper
                                        ,pr_cdprogra   => vr_cdprogra
                                         ,pr_nrdconta   => rw_crapepr.nrdconta
                                        ,pr_nrctremp   => rw_crapepr.nrctremp
                                        ,pr_rw_crapdat => rw_crapdat
                                        ,pr_inusatab   => FALSE
                                        ,pr_vlsdeved   => vr_vlsdeved
                                        ,pr_qtprecal   => vr_qtprecal
                                        ,pr_qtdiaatr   => vr_dias
                                        ,pr_cdcritic   => vr_cdcritic
                                        ,pr_des_erro   => vr_dscritic);
           --Se ocorreu erro
           IF trim(vr_dscritic) IS NOT NULL THEN
             --Levantar Exceção
             RAISE vr_exc_saida;
           END IF;
           --Se a quantidade de dias >= vr_dia1cardve
           IF  vr_dias >= vr_dia1cardve THEN  /* 1 Carta Emprestimo */
             --Selecionar ultimo cadastro devedor
             OPEN cr_crapcdv_last (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_crapepr.nrdconta
                                  ,pr_nrctremp => rw_crapepr.nrctremp
                                  ,pr_cdorigem => 3);
             FETCH cr_crapcdv_last INTO rw_crapcdv_last;
             IF cr_crapcdv_last%NOTFOUND OR rw_crapcdv_last.dtliquid IS NOT NULL THEN
               BEGIN
                 INSERT INTO crapcdv (crapcdv.nrdconta
                                     ,crapcdv.nrctremp
                                     ,crapcdv.cdorigem
                                     ,crapcdv.dtmvtolt
                                     ,crapcdv.flgenvio
                                     ,crapcdv.cdcooper
                                     ,crapcdv.vlsdeved
                                     ,crapcdv.dtultpag
                                     ,crapcdv.qtdiatra)
                 VALUES              (nvl(rw_crapepr.nrdconta,0)
                                     ,nvl(rw_crapepr.nrctremp,0)
                                     ,3
                                     ,rw_crapdat.dtmvtolt
                                     ,1
                                     ,pr_cdcooper
                                     ,nvl(vr_vlsdeved,0)
                                     ,rw_crapepr.dtultpag
                                     ,nvl(vr_dias,0));
               EXCEPTION
                 WHEN OTHERS THEN
                   --Fechar Cursor
                   CLOSE cr_crapcdv_last;
                   vr_dscritic:= 'Erro ao inserir tabela crapcdv. '||SQLERRM;
                   RAISE vr_exc_saida;
               END;
             ELSE
               --Atualizar tabela crapcdv
               BEGIN
                 UPDATE crapcdv SET crapcdv.vlsdeved = nvl(vr_vlsdeved,0)
                                   ,crapcdv.dtultpag = rw_crapepr.dtultpag
                                   ,crapcdv.qtdiatra = nvl(vr_dias,0)
                 WHERE crapcdv.ROWID = rw_crapcdv_last.ROWID;
               EXCEPTION
                 WHEN OTHERS THEN
                   --Fechar Cursor
                   CLOSE cr_crapcdv_last;
                   vr_dscritic:= 'Erro ao atualizar tabela crapcdv. '||SQLERRM;
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapcdv_last;
           END IF;
         END LOOP; --rw_crapepr
       END LOOP;  --rw_crapass


       /*-- Emissao Relatorio - Cartas a serem Enviadas / Atualizadas --*/
       FOR rw_crapcdv IN cr_crapcdv_assoc (pr_cdcooper => pr_cdcooper) LOOP

         --Executar atualização data recebimento AR
         pc_atualiza_recebimento_ar (pr_flgenvar      => vr_flgenvar
                                    ,pr_dtemdev2      => rw_crapcdv.dtemdev2
                                    ,pr_dtardeve      => rw_crapcdv.dtardeve
                                    ,pr_dtininar      => vr_dtininar
                                    ,pr_dtemavl2      => rw_crapcdv.dtemavl2
                                    ,pr_dtar1avl      => rw_crapcdv.dtar1avl
                                    ,pr_dtar2avl      => rw_crapcdv.dtar2avl
                                    ,pr_qtdiasar      => vr_qtdiasar
                                    ,pr_crapcdv_rowid => rw_crapcdv.rowid
                                    ,pr_des_erro      => vr_dscritic);

         --Se ocorreu erro
         IF trim(vr_dscritic) IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;

         vr_tpdcarta:= 0;
         vr_tipodeve:= 0;

         --Se a data de devolucao 1, devolucao 2 e aviso 2 forem nulas
         IF rw_crapcdv.dtemdev1 IS NULL  AND
            rw_crapcdv.dtemdev2 IS NULL  AND
            rw_crapcdv.dtemavl2 IS NULL THEN
           vr_tpdcarta:= 1;
         END IF;

         --Se a data de devolucao 1 nao for nula e a devolucao 2 e aviso 2 forem nulas
         IF  rw_crapcdv.dtemdev1 IS NOT NULL AND
             rw_crapcdv.dtemdev2 IS NULL AND
             rw_crapcdv.dtemavl2 IS NULL THEN
           --Se a origem for conta
           IF  rw_crapcdv.cdorigem = 1 THEN
             --Se a data do movimento menos devolucao 1 for > dia 2 AR
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev1) >= vr_dia2cardvc THEN
               vr_tpdcarta:= 2;
             END IF;
           ELSE
             --Se a data do movimento menos devolucao 1 for > dia 2 AR
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev1) >= vr_dia2cardve THEN
               vr_tpdcarta:= 2;
             END IF;
           END IF;
         END IF;

         --Se a origem for Emprestimos e as data de devolucao 1 e devolucao 2 nao forem nulas
         --e aviso 2 for nula
         IF rw_crapcdv.cdorigem = 3 AND
            rw_crapcdv.dtemdev1 IS NOT NULL AND
            rw_crapcdv.dtemdev2 IS NOT NULL AND
            rw_crapcdv.dtemavl2 IS NULL THEN
           --Se a data do movimento menos devolucao 2 for > dia 2 AR
            IF (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev2) >= vr_dia2carave THEN
              vr_tpdcarta:= 4;
            END IF;
         END IF;

         /* 2 CARTA AVALISTAS */
         IF vr_tpdcarta = 4  AND
            rw_crapcdv.cdorigem = 3 THEN

           --Executar avalistas 1 e 2
           pc_avalista (pr_tipo         => 0 --> todos
                       ,pr_nrdconta     => rw_crapcdv.nrdconta
                       ,pr_nrctremp     => rw_crapcdv.nrctremp
                       ,pr_dtspcav1     => rw_crapcdv.dtspcav1
                       ,pr_dtspcav2     => rw_crapcdv.dtspcav2
                       ,pr_vlsdeved     => rw_crapcdv.vlsdeved
                       ,pr_cdorigem     => rw_crapcdv.cdorigem
                       ,pr_qtdiatra     => rw_crapcdv.qtdiatra
                       ,pr_cdagenci     => rw_crapcdv.cdagenci
                       ,pr_tipodeve     => vr_tipodeve
                       ,pr_dtar1avl     => rw_crapcdv.dtar1avl
                       ,pr_dtardeve     => rw_crapcdv.dtardeve
                       ,pr_dtar2avl     => rw_crapcdv.dtar2avl
                       ,pr_dtslavl2     => rw_crapcdv.dtslavl2
                       ,pr_dtslavl1     => rw_crapcdv.dtslavl1
                       ,pr_dtsldev1     => rw_crapcdv.dtsldev1
                       ,pr_dtmvtolt     => rw_crapcdv.dtmvtolt
                       ,pr_tpdcarta     => vr_tpdcarta
                       ,pr_nomedes1     => vr_nomedes1
                       ,pr_nrcpfcgc     => vr_nrcpfcgc
                       ,pr_des_erro     => vr_dscritic);
           --Se ocorreu erro
           IF trim(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
         END IF;

         /*-- AR do Devedor --*/
         --Se a data AR devedor nao for nula e origem = Emprestimos
         IF rw_crapcdv.dtardeve IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
           /* Somente SPC se nao incluso */
           IF  rw_crapcdv.inadimpl = 0 THEN
             --Se data movimento menos data recebimento AR >= qtd dias
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtardeve) >= vr_diaspcempr THEN
               vr_tpdcarta:= 5;
             END IF;
           END IF;
         END IF;

         --Se a data AR devedor nao for nula e origem = Conta
         IF rw_crapcdv.dtardeve IS NOT NULL AND rw_crapcdv.cdorigem = 1 THEN
           /* Somente SPC se nao incluso */
           IF  rw_crapcdv.inadimpl = 0 THEN
             --Se data movimento menos data recebimento AR >= qtd dias
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtardeve) >= vr_diaspccl THEN
               vr_tpdcarta:= 5;
             END IF;
           END IF;
         END IF;

         --Atribuir nome destinatario e cpf
         vr_nomedes1:= rw_crapcdv.nmprimtl;
         vr_nrcpfcgc:= GENE0002.fn_mask_cpf_cnpj(rw_crapcdv.nrcpfcgc,rw_crapcdv.inpessoa);

         /* 2 CARTA DEVEDOR */
         IF  vr_tpdcarta = 2  THEN

           pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                         ,pr_nrdconta => rw_crapcdv.nrdconta
                         ,pr_nrctremp => rw_crapcdv.nrctremp
                         ,pr_vlsdeved => rw_crapcdv.vlsdeved
                         ,pr_nomedes1 => vr_nomedes1
                         ,pr_nrcpfcgc => vr_nrcpfcgc
                         ,pr_cdorigem => rw_crapcdv.cdorigem
                         ,pr_qtdiatra => rw_crapcdv.qtdiatra
                         ,pr_cdagenci => rw_crapcdv.cdagenci
                         ,pr_tipodeve => vr_tipodeve
                         ,pr_dtar1avl => rw_crapcdv.dtar1avl
                         ,pr_dtardeve => rw_crapcdv.dtardeve
                         ,pr_dtar2avl => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                         ,pr_des_erro => vr_dscritic);
           --Se ocorreu erro
           IF trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;
           --Se a origem for emprestimo
           IF  rw_crapcdv.cdorigem = 3  THEN
             vr_tpdcarta:= 3; --avalistas
             pc_avalista (pr_tipo      => 0 --> Todos
                         ,pr_nrdconta  => rw_crapcdv.nrdconta
                         ,pr_nrctremp  => rw_crapcdv.nrctremp
                         ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                         ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                         ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                         ,pr_cdorigem  => rw_crapcdv.cdorigem
                         ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                         ,pr_cdagenci  => rw_crapcdv.cdagenci
                         ,pr_tipodeve  => vr_tipodeve
                         ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                         ,pr_dtardeve  => rw_crapcdv.dtardeve
                         ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                         ,pr_tpdcarta  => vr_tpdcarta
                         ,pr_nomedes1  => vr_nomedes1
                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                         ,pr_des_erro  => vr_dscritic);
             --Se ocorreu erro
             IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;
         END IF;

         /* Inclusao SPC DEVEDOR */
         IF vr_tpdcarta = 5 THEN

           vr_tipodeve:= 1;
           pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                         ,pr_nrdconta => rw_crapcdv.nrdconta
                         ,pr_nrctremp => rw_crapcdv.nrctremp
                         ,pr_vlsdeved => rw_crapcdv.vlsdeved
                         ,pr_nomedes1 => vr_nomedes1
                         ,pr_nrcpfcgc => vr_nrcpfcgc
                         ,pr_cdorigem => rw_crapcdv.cdorigem
                         ,pr_qtdiatra => rw_crapcdv.qtdiatra
                         ,pr_cdagenci => rw_crapcdv.cdagenci
                         ,pr_tipodeve => vr_tipodeve
                         ,pr_dtar1avl => rw_crapcdv.dtar1avl
                         ,pr_dtardeve => rw_crapcdv.dtardeve
                         ,pr_dtar2avl => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                         ,pr_des_erro => vr_dscritic);
           --Se ocorreu erro
           IF trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;
         END IF;

         /* 1 CARTA DEVEDOR */
         IF  vr_tpdcarta = 1 THEN

           pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                         ,pr_nrdconta => rw_crapcdv.nrdconta
                         ,pr_nrctremp => rw_crapcdv.nrctremp
                         ,pr_vlsdeved => rw_crapcdv.vlsdeved
                         ,pr_nomedes1 => vr_nomedes1
                         ,pr_nrcpfcgc => vr_nrcpfcgc
                         ,pr_cdorigem => rw_crapcdv.cdorigem
                         ,pr_qtdiatra => rw_crapcdv.qtdiatra
                         ,pr_cdagenci => rw_crapcdv.cdagenci
                         ,pr_tipodeve => vr_tipodeve
                         ,pr_dtar1avl => rw_crapcdv.dtar1avl
                         ,pr_dtardeve => rw_crapcdv.dtardeve
                         ,pr_dtar2avl => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                         ,pr_des_erro => vr_dscritic);
           --Se ocorreu erro
           IF trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;
         END IF;

         /*--- AR dos Avalistas ---*/
         IF rw_crapcdv.dtar1avl IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
           IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtar1avl) >= vr_diaspcempr THEN

             vr_tpdcarta:= 5;
             vr_tipodeve:= 2;
             pc_avalista (pr_tipo      => 1 --> Avalista 1
                         ,pr_nrdconta  => rw_crapcdv.nrdconta
                         ,pr_nrctremp  => rw_crapcdv.nrctremp
                         ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                         ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                         ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                         ,pr_cdorigem  => rw_crapcdv.cdorigem
                         ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                         ,pr_cdagenci  => rw_crapcdv.cdagenci
                         ,pr_tipodeve  => vr_tipodeve
                         ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                         ,pr_dtardeve  => rw_crapcdv.dtardeve
                         ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                         ,pr_tpdcarta  => vr_tpdcarta
                         ,pr_nomedes1  => vr_nomedes1
                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                         ,pr_des_erro  => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;
         END IF;

         --Se a data 2 ar avalista nao for nula e for emprestimo
         IF  rw_crapcdv.dtar2avl IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
           IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtar2avl) >= vr_diaspcempr THEN
             vr_tpdcarta:= 5;
             vr_tipodeve:= 3;

             pc_avalista (pr_tipo      => 2 --> Avalista 2
                         ,pr_nrdconta  => rw_crapcdv.nrdconta
                         ,pr_nrctremp  => rw_crapcdv.nrctremp
                         ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                         ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                         ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                         ,pr_cdorigem  => rw_crapcdv.cdorigem
                         ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                         ,pr_cdagenci  => rw_crapcdv.cdagenci
                         ,pr_tipodeve  => vr_tipodeve
                         ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                         ,pr_dtardeve  => rw_crapcdv.dtardeve
                         ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                         ,pr_tpdcarta  => vr_tpdcarta
                         ,pr_nomedes1  => vr_nomedes1
                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                         ,pr_des_erro  => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;
         END IF;
       END LOOP;

       --Executar relatório crrl362 - relação de cartas a serem solicitadas
       pc_imprime_crrl362 (pr_des_erro => vr_dscritic);
       --Se retornou erro
       IF trim(vr_dscritic) IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
       END IF;

       --Zerar tabelas de memoria auxiliar do relatorio
       vr_tab_relat.DELETE;

       /* geracao das cartas com solicitacao atrasada */

       /* verifica se e o ultimo dia da semana, se for executa (ou quarta-feira)*/

       IF pr_cdcooper = 1 AND
         (To_Char(rw_crapdat.dtmvtolt,'D') = 4 OR To_Char(rw_crapdat.dtmvtolt,'D') > To_Char(rw_crapdat.dtmvtopr,'D')) THEN

         FOR rw_crapcdv IN cr_crapcdv_assoc (pr_cdcooper => pr_cdcooper) LOOP

           --Zerar o tipo de carta
           vr_tpdcarta:= 0;

           --Se a data de devolucao 1, devolucao 2 e aviso 2 forem nulas
           IF rw_crapcdv.dtemdev1 IS NULL  AND
              rw_crapcdv.dtemdev2 IS NULL  AND
              rw_crapcdv.dtemavl2 IS NULL THEN
             --Se a data do movimento menos data comunicacao >= 5
             IF (rw_crapdat.dtmvtolt - rw_crapcdv.dtmvtolt) >= 5 THEN
               --1a. Carta Devedor
               vr_tpdcarta:= 1;
             END IF;
           END IF;

           --Se a data de devolucao 1 nao for nula e a devolucao 2 e aviso 2 forem nulas
           IF  rw_crapcdv.dtemdev1 IS NOT NULL AND
               rw_crapcdv.dtemdev2 IS NULL AND
               rw_crapcdv.dtemavl2 IS NULL THEN
             --Se a origem for conta
             IF  rw_crapcdv.cdorigem = 1 THEN
               --Se a data do movimento menos devolucao 1 for > dia 2 AR
               IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev1) >= (vr_dia2cardvc + 5) THEN
                 --2a. Carta Devedor
                 vr_tpdcarta:= 2;
               END IF;
             ELSE
               --Se a data do movimento menos devolucao 1 for > dia 2 AR
               IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev1) >= (vr_dia2cardve + 5) THEN
                 --2a. Carta Devedor
                 vr_tpdcarta:= 2;
               END IF;
             END IF;
           END IF;

           --Se a origem for Emprestimos e as data de devolucao 1 e devolucao 2 nao forem nulas
           --e aviso 2 for nula
           IF rw_crapcdv.cdorigem = 3 AND
              rw_crapcdv.dtemdev1 IS NOT NULL AND
              rw_crapcdv.dtemdev2 IS NOT NULL AND
              rw_crapcdv.dtemavl2 IS NULL THEN
             --Se a data do movimento menos devolucao 2 for > dia 2 AR
              IF (rw_crapdat.dtmvtolt - rw_crapcdv.dtemdev2) >= (vr_dia2carave + 5) THEN
                --2a. Carta Avalista
                vr_tpdcarta:= 4;
              END IF;
           END IF;

           /*-- AR do Devedor --*/

           --Se a data AR devedor nao for nula e origem = Emprestimos
           IF rw_crapcdv.dtardeve IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
             /* Somente SPC se nao incluso */
             IF  rw_crapcdv.inadimpl = 0 THEN
               --Se data movimento menos data recebimento AR >= qtd dias
               IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtardeve) >= (vr_diaspcempr + 5) THEN
                 --Inclusao SPC
                 vr_tpdcarta:= 5;
               END IF;
             END IF;
           END IF;

           --Se a data AR devedor nao for nula e origem = Conta
           IF rw_crapcdv.dtardeve IS NOT NULL AND rw_crapcdv.cdorigem = 1 THEN
             /* Somente SPC se nao incluso */
             IF  rw_crapcdv.inadimpl = 0 THEN
               --Se data movimento menos data recebimento AR >= qtd dias
               IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtardeve) >= (vr_diaspccl + 5) THEN
                 --Inclusao SPC
                 vr_tpdcarta:= 5;
               END IF;
             END IF;
           END IF;

           --Atribuir nome destinatario e cpf
           vr_nomedes1:= rw_crapcdv.nmprimtl;
           vr_nrcpfcgc:= GENE0002.fn_mask_cpf_cnpj(rw_crapcdv.nrcpfcgc,rw_crapcdv.inpessoa);

           /* 2 CARTA DEVEDOR */
           IF  vr_tpdcarta = 2  THEN
             pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                           ,pr_nrdconta => rw_crapcdv.nrdconta
                           ,pr_nrctremp => rw_crapcdv.nrctremp
                           ,pr_vlsdeved => rw_crapcdv.vlsdeved
                           ,pr_nomedes1 => vr_nomedes1
                           ,pr_nrcpfcgc => vr_nrcpfcgc
                           ,pr_cdorigem => rw_crapcdv.cdorigem
                           ,pr_qtdiatra => rw_crapcdv.qtdiatra
                           ,pr_cdagenci => rw_crapcdv.cdagenci
                           ,pr_tipodeve => vr_tipodeve
                           ,pr_dtar1avl => rw_crapcdv.dtar1avl
                           ,pr_dtardeve => rw_crapcdv.dtardeve
                           ,pr_dtar2avl => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                           ,pr_des_erro => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
             --Se a origem for emprestimo
             IF  rw_crapcdv.cdorigem = 3  THEN
               vr_tpdcarta:= 3; --1 carta avalistas
               pc_avalista (pr_tipo      => 0 --> Todos
                           ,pr_nrdconta  => rw_crapcdv.nrdconta
                           ,pr_nrctremp  => rw_crapcdv.nrctremp
                           ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                           ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                           ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                           ,pr_cdorigem  => rw_crapcdv.cdorigem
                           ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                           ,pr_cdagenci  => rw_crapcdv.cdagenci
                           ,pr_tipodeve  => vr_tipodeve
                           ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                           ,pr_dtardeve  => rw_crapcdv.dtardeve
                           ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                           ,pr_tpdcarta  => vr_tpdcarta
                           ,pr_nomedes1  => vr_nomedes1
                           ,pr_nrcpfcgc  => vr_nrcpfcgc
                           ,pr_des_erro  => vr_dscritic);
               --Se ocorreu erro
               IF trim(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
               END IF;
             END IF;
           END IF;

           /* 2 CARTA AVALISTAS */
           IF  vr_tpdcarta = 4 AND rw_crapcdv.cdorigem = 3 THEN
             pc_avalista (pr_tipo      => 0 --> Todos
                         ,pr_nrdconta  => rw_crapcdv.nrdconta
                         ,pr_nrctremp  => rw_crapcdv.nrctremp
                         ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                         ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                         ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                         ,pr_cdorigem  => rw_crapcdv.cdorigem
                         ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                         ,pr_cdagenci  => rw_crapcdv.cdagenci
                         ,pr_tipodeve  => vr_tipodeve
                         ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                         ,pr_dtardeve  => rw_crapcdv.dtardeve
                         ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                         ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                         ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                         ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                         ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                         ,pr_tpdcarta  => vr_tpdcarta
                         ,pr_nomedes1  => vr_nomedes1
                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                         ,pr_des_erro  => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;

           /* Inclusao SPC DEVEDOR */
           IF vr_tpdcarta = 5 THEN
             pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                           ,pr_nrdconta => rw_crapcdv.nrdconta
                           ,pr_nrctremp => rw_crapcdv.nrctremp
                           ,pr_vlsdeved => rw_crapcdv.vlsdeved
                           ,pr_nomedes1 => vr_nomedes1
                           ,pr_nrcpfcgc => vr_nrcpfcgc
                           ,pr_cdorigem => rw_crapcdv.cdorigem
                           ,pr_qtdiatra => rw_crapcdv.qtdiatra
                           ,pr_cdagenci => rw_crapcdv.cdagenci
                           ,pr_tipodeve => vr_tipodeve
                           ,pr_dtar1avl => rw_crapcdv.dtar1avl
                           ,pr_dtardeve => rw_crapcdv.dtardeve
                           ,pr_dtar2avl => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                           ,pr_des_erro => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;

           /* 1 CARTA DEVEDOR */
           IF  vr_tpdcarta = 1 THEN
             pc_cria_relat (pr_tpdcarta => vr_tpdcarta
                           ,pr_nrdconta => rw_crapcdv.nrdconta
                           ,pr_nrctremp => rw_crapcdv.nrctremp
                           ,pr_vlsdeved => rw_crapcdv.vlsdeved
                           ,pr_nomedes1 => vr_nomedes1
                           ,pr_nrcpfcgc => vr_nrcpfcgc
                           ,pr_cdorigem => rw_crapcdv.cdorigem
                           ,pr_qtdiatra => rw_crapcdv.qtdiatra
                           ,pr_cdagenci => rw_crapcdv.cdagenci
                           ,pr_tipodeve => vr_tipodeve
                           ,pr_dtar1avl => rw_crapcdv.dtar1avl
                           ,pr_dtardeve => rw_crapcdv.dtardeve
                           ,pr_dtar2avl => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2 => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1 => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1 => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt => rw_crapcdv.dtmvtolt
                           ,pr_des_erro => vr_dscritic);
             --Se ocorreu erro
             IF trim(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
             END IF;
           END IF;

           /*--- AR dos Avalistas ---*/
           IF rw_crapcdv.dtar1avl IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtar1avl) >= (vr_diaspcempr + 5) THEN
               vr_tpdcarta:= 5;
               pc_avalista (pr_tipo      => 1 --> Avalista 1
                           ,pr_nrdconta  => rw_crapcdv.nrdconta
                           ,pr_nrctremp  => rw_crapcdv.nrctremp
                           ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                           ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                           ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                           ,pr_cdorigem  => rw_crapcdv.cdorigem
                           ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                           ,pr_cdagenci  => rw_crapcdv.cdagenci
                           ,pr_tipodeve  => vr_tipodeve
                           ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                           ,pr_dtardeve  => rw_crapcdv.dtardeve
                           ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                           ,pr_tpdcarta  => vr_tpdcarta
                           ,pr_nomedes1  => vr_nomedes1
                           ,pr_nrcpfcgc  => vr_nrcpfcgc
                           ,pr_des_erro  => vr_dscritic);
               --Se ocorreu erro
               IF trim(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
               END IF;
             END IF;
           END IF;

           --Se a data 2 ar avalista nao for nula e for emprestimo
           IF  rw_crapcdv.dtar2avl IS NOT NULL AND rw_crapcdv.cdorigem = 3 THEN
             IF  (rw_crapdat.dtmvtolt - rw_crapcdv.dtar2avl) >= (vr_diaspcempr + 5) THEN
               vr_tpdcarta:= 5;
               pc_avalista (pr_tipo      => 2 --> Avalista 2
                           ,pr_nrdconta  => rw_crapcdv.nrdconta
                           ,pr_nrctremp  => rw_crapcdv.nrctremp
                           ,pr_dtspcav1  => rw_crapcdv.dtspcav1
                           ,pr_dtspcav2  => rw_crapcdv.dtspcav2
                           ,pr_vlsdeved  => rw_crapcdv.vlsdeved
                           ,pr_cdorigem  => rw_crapcdv.cdorigem
                           ,pr_qtdiatra  => rw_crapcdv.qtdiatra
                           ,pr_cdagenci  => rw_crapcdv.cdagenci
                           ,pr_tipodeve  => vr_tipodeve
                           ,pr_dtar1avl  => rw_crapcdv.dtar1avl
                           ,pr_dtardeve  => rw_crapcdv.dtardeve
                           ,pr_dtar2avl  => rw_crapcdv.dtar2avl
                           ,pr_dtslavl2  => rw_crapcdv.dtslavl2
                           ,pr_dtslavl1  => rw_crapcdv.dtslavl1
                           ,pr_dtsldev1  => rw_crapcdv.dtsldev1
                           ,pr_dtmvtolt  => rw_crapcdv.dtmvtolt
                           ,pr_tpdcarta  => vr_tpdcarta
                           ,pr_nomedes1  => vr_nomedes1
                           ,pr_nrcpfcgc  => vr_nrcpfcgc
                           ,pr_des_erro  => vr_dscritic);
               --Se ocorreu erro
               IF trim(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
               END IF;
             END IF;
           END IF;
         END LOOP;
       END IF;

       --Gerando relatorio Cartas com Solicitacao em atraso
       pc_imprime_crrl369 (pr_des_erro => vr_dscritic);
       --Se retornou erro
       IF trim(vr_dscritic) IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas código
         IF nvl(vr_cdcritic,0) > 0 AND trim(vr_dscritic) IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
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
END pc_crps398;
/
