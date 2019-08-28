/*..............................................................................

    Programa: fontes/prcctl.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Fevereiro/2010                   Ultima atualizacao: 26/05/2018

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Gera e envia arquivos da Compensacao Cecred das 
                cooperativas que possuem o Banco Unificado.
               
    Alteracoes: 01/04/2010 - Passar as funcoes "I" e "G" da PCOMPE para PRCCTL
                             (Guilherme/Supero)
                             
                25/05/2010 - Adaptacoes COMPE Nossa Remessa 
                             (Guilherme,Guilherme/Supero,Ze).
                             
                31/05/2010 - Voltar alteracoes Compe SR ICF e CAF (Guilherme).
                
                01/06/2010 - Na opcao "P" antes de efetuar a baixa da ABBC,
                             verificar se o arquivo ja existe em nosso servidor
                           - Melhorias solicitadas pelo Departamento COMPE.
                           - Acertos para COMPE Sua Remessa (Guilherme).

                17/06/2010 - Incluso campo Data de Referência na geração do 
                             arquivo opção "B", somente para TI.
                             (Jonatas/Supero)

                22/06/2010 - Inclusao da opcao V para mostrar COOPs com arqs
                             pendentes de envio (Guilherme/Supero)
                
                28/06/2010 - Incluir rotina de verificacao de titulos pagos
                             pela Internet Bank - PAC 90 (Ze).
                             
                08/07/2010 - Adicionado scripts para ICF e CAF
                           - Liberado rotinas CCF C-O Relacionamento(Guilherme)

                06/08/2010 - Acertos para a Devolucao (Ze).
                
                12/08/2010 - Alteracao no "E" Enviar para que processe para 
                             todas as cooperativas. Incluido a coop. no browse
                             do Enviar. 
                           - Incluida mensagem no browse da opcao V para que
                             informe quantas cooperativas tem pendencia.
                             (Guilherme/Supero)

               09/09/2010 - Emitir protocolo ao termino da consulta. Protocolo
                            de arquivos DEVOLU enviados e a serem enviados para
                            ABBC. Gera crrl575 (Guilherme/Supero)
                            
               24/09/2010 - Melhoria na rotina pi_imprime_protocolo_devolu (Ze).

               05/10/2010 - Ajuste no protocolo de devolucao (Ze).

               12/11/2010 - Ajuste no protocolo de devolucao (Guilherme/Supero) 
               06/12/2010 - Alteracao nos Parametros da BO 12 - Truncagem (Ze).

               17/12/2010 - Alteracao op. "V" para validar apenas os arquivos
                            processados pela op. "E". (Guilherme/Supero).
                            
               20/01/2011 - Incluido novo parametro na procedure 
                            gerar_arquivos_cecred (Elton).

               26/01/2011 - Inclusao do TCO na emissao do Protocolo
                            (Guilherme/Supero)
                            
               01/02/2011 - Incluir Tratamento para CUSTODIA e DSC CHQ para
                            COMPE imagem (Guilherme).
                            
               26/05/2011 - Acertar leitura do craplcm na devolucao (Magui).
               
               15/07/2011 - Acerto na Opcao C da Opcao DEVOLU e Alerta para
                            devolucoes DEVTCO nao executadas (Ze).

               28/09/2011 - Aplicacao de testes de digitalizacao para cheques
                            da propria cooperativa - Somente Coop. 4 (Ze).
                            
               04/10/2011 - Separar a totalização de cheques em Cooperativas e
                            Terceiros (Isara - RKAM).
                            
               13/02/2012 - Alteracao para que todas as coops possam digitalizar
                            cheques da propria cooperativa (ZE).
                            
               16/04/2012 - Fonte substituido por prcctlp.p (Tiago).
               
               13/06/2012 - Alteracao para que todas as coops possam digitalizar
                            cheques da propria cooperativa (ZE).
                            
               26/07/2012 - Alteracao para incluir devolucoes da alinea 37 (Ze).
               
               27/08/2012 - Alterações referente Projeto TIC (Richard/Supero).
               
               12/09/2012 - Incluido selecao do tipo de devolucao para a
                            funcao DEVOLU. (Fabricio)
                            
               16/10/2012 - Incluido contador de registros na procedure
                            proc_verifica_pac_internet. (Fabricio)
                            
               08/01/2013 - Chamar procedure gerar_compel_altoVale para gerar
                            arquivo da AltoVale do form. 0101 (Ze).
                            
               27/02/2013 - Incluído departamento FINANCEIRO (Diego).

               27/03/2013 - Inclusao tratamento para ICFJUD (Guilherme/Supero)
               
               25/04/2013 - Ajuste na chamada da procedure 
                            reativar arquivos cecred para tratamento de erro
                            (David Kruger).
                            
               23/05/2013 - Ajuste no ICF616 (Ze).
               
               14/06/2013 - Ajuste no ICF (Ze).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
               
               03/01/2014 - Tratamento para Migracao Acredi/Viacredi (Ze).
               
               03/04/2014 - Incluido item DEVDOC na opcao B (Tiago).
               
               01/07/2014 - Incluido parametro para impressao do relatorio
                            (Diego).
                   
               29/10/2014 - Alteração para enviar todos os arquivos de cheque,
                            inclusive dos PAs novos com 3 digitos. (Aline)
                             
               07/11/2014 - Adicionado tratamento para a migracao VIACON.
                            (Reinert)                             
                            
               28/11/2014 - Comentar critica de titulos nao conferem (Ze).
               
               11/12/2014 - Tratado erro na opcao "P" ref. registro crapcop
                            nao disponivel quando informado tel_cdcooper = 0
                            (TODAS) (Diego).
                            
               17/12/2014 - Incluso tratamento para que as leituras da crapcop
                            verifiquem se crapcop.flgativo = TRUE 
                            SoftDesk 235714 (Daniel/Aline). 
                            
               22/12/2014 - Efetuado tratamento na opcao "C" para considerar
                            devolucoes da coop. antiga (Diego).             
               
               03/10/2015 - Corrigido execucao do "DEVDOC" quando a opcao
                            escolhida era "TODAS" pois estava mandando a coop
                            como 0 desta forma nao processando da forma que 
                            deveria (Tiago/Elton SD334046).
                            
               25/11/2015 - Incluido procedure gera_log_execucao para gerar
                            Log quando processo for executado manualmente
                            pra maioria das operacoes (Tiago SD338533).    
       
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).

			   21/06/2016 - Ajuste para utilizar o pacote transabbc ao chamar o script
						    de comunicação com a ABBC, ao invés de deixar o IP fixo
							(Adriano - SD 468880).

               11/10/2016 - Acesso da tela PRCCTL em todas cooperativas SD381526 (Tiago/Elton)

               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)

			   13/01/2017 - Tratamento incorporacao Transposul (Diego).

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

         25/07/2019 - PJ565.1 Permite opçao DEVOLU opçao X

..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF BUFFER crabcop   FOR crapcop.
DEF BUFFER crablcm   FOR craplcm.
   
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprgexe AS CHAR                                           NO-UNDO.
DEF VAR aux_pacinici AS INT                                            NO-UNDO.
DEF VAR aux_pacfinal AS INT                                            NO-UNDO.
DEF VAR aux_totregis AS INT                                            NO-UNDO.
DEF VAR tot_totregis AS INTE                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DEC                                            NO-UNDO.
DEF VAR tot_vlrtotal AS DEC                                            NO-UNDO.
DEF VAR aux_qtarquiv AS INT                                            NO-UNDO.
DEF VAR tot_qtarquiv AS INTE                                           NO-UNDO.
DEF VAR aux_cdbcoenv AS CHAR                                           NO-UNDO.
DEF VAR aux_vldocrcb AS DEC         FORMAT "999,999,999,999.99"        NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.
DEF VAR aux_nrbarras AS INTE                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_arqlista AS CHAR                                           NO-UNDO.
DEF VAR aux_arqdolog AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR        FORMAT "x(150)"                    NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbaixar AS CHAR                                           NO-UNDO.
DEF VAR aux_flghrexe AS LOG                                            NO-UNDO.
DEF VAR aux_mes      AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR        EXTENT 2                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.

DEF VAR aux_qtchdcci AS INT                                            NO-UNDO.
DEF VAR aux_vlchdcci AS DEC                                            NO-UNDO.
DEF VAR aux_qtchdccs AS INT                                            NO-UNDO.
DEF VAR aux_vlchdccs AS DEC                                            NO-UNDO.
DEF VAR aux_qtchdccg AS INT                                            NO-UNDO.
DEF VAR aux_vlchdccg AS DEC                                            NO-UNDO.
DEF VAR aux_qtchdcti AS INT                                            NO-UNDO.
DEF VAR aux_vlchdcti AS DEC                                            NO-UNDO.
DEF VAR aux_qtchdcts AS INT                                            NO-UNDO.
DEF VAR aux_vlchdcts AS DEC                                            NO-UNDO.
DEF VAR aux_qtchdctg AS INT                                            NO-UNDO.
DEF VAR aux_vlchdctg AS DEC                                            NO-UNDO.
DEF VAR aux_nrseqsol AS INT                                            NO-UNDO.

DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR tel_qtdtotal AS INT         FORMAT ">>>,>>9"                   NO-UNDO.
DEF VAR tel_vlrtotal AS DEC         FORMAT ">>>,>>>,>>>,>>>.99"        NO-UNDO.
DEF VAR tel_qtdevolv AS INT                                            NO-UNDO.
DEF VAR tel_qtadevol AS INT                                            NO-UNDO.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_dtrefere AS DATE        FORMAT "99/99/9999"                NO-UNDO.

DEF VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF VAR tel_nmprgexe AS CHAR        FORMAT "x(14)" VIEW-AS COMBO-BOX 
    INNER-LINES 9  NO-UNDO.
DEF VAR tel_cdcooper AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
    INNER-LINES 11  NO-UNDO.
DEF VAR tel_cdagenci AS INT         FORMAT "z9"    INIT 0              NO-UNDO.
DEF VAR tel_flgenvio AS LOG         FORMAT "Enviados/Nao Enviados"     NO-UNDO.
DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.

DEF VAR tel_tpdevolu AS CHAR        FORMAT "X(10)" 
    VIEW-AS COMBO-BOX LIST-ITEMS "VLB",
                                 "Diurna",
                                 "Fraude" 
    INNER-LINES 3 NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.

DEF VAR rel_qtpridev AS INT        INIT 0                              NO-UNDO.
DEF VAR rel_qtsegdev AS INT        INIT 0                              NO-UNDO.
DEF VAR rel_qtgercop AS INT        INIT 0                              NO-UNDO.
DEF VAR tot_qtpridev AS INT        INIT 0                              NO-UNDO.
DEF VAR tot_qtsegdev AS INT        INIT 0                              NO-UNDO.
DEF VAR tot_qtdgeral AS INT        INIT 0                              NO-UNDO.

DEF VAR rel_vlpridev AS DEC        INIT 0                              NO-UNDO.
DEF VAR rel_vlsegdev AS DEC        INIT 0                              NO-UNDO.
DEF VAR rel_vlgercop AS DEC        INIT 0                              NO-UNDO.
DEF VAR tot_vlpridev AS DEC        INIT 0                              NO-UNDO.
DEF VAR tot_vlsegdev AS DEC        INIT 0                              NO-UNDO.
DEF VAR tot_vlrgeral AS DEC        INIT 0                              NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0012 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0154 AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE crawage                                                 NO-UNDO
         FIELD  cdcooper      LIKE crapage.cdcooper
         FIELD  cdagenci      LIKE crapage.cdagenci
         FIELD  nmresage      LIKE crapage.nmresage
         FIELD  nmcidade      LIKE crapage.nmcidade 
         FIELD  cdbandoc      LIKE crapage.cdbandoc
         FIELD  cdbantit      LIKE crapage.cdbantit
         FIELD  cdagecbn      LIKE crapage.cdagecbn
         FIELD  cdbanchq      LIKE crapage.cdbanchq
         FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEFINE TEMP-TABLE tt-titulos                                            NO-UNDO
         FIELD qttitrec       AS INT
         FIELD vltitrec       AS DEC
         FIELD qttitrgt       AS INT
         FIELD vltitrgt       AS DEC
         FIELD qttiterr       AS INT
         FIELD vltiterr       AS DEC
         FIELD qttitprg       AS INT
         FIELD vltitprg       AS DEC
         FIELD qttitcxa       AS INT
         FIELD vltitcxa       AS DEC
         FIELD qttitulo       AS INT
         FIELD vltitulo       AS DEC.
                              
DEFINE TEMP-TABLE tt-compel                                             NO-UNDO
         FIELD qtchdcxi       AS INT
         FIELD qtchdcxs       AS INT
         FIELD qtchdcxg       AS INT
         FIELD qtchdcsi       AS INT
         FIELD qtchdcss       AS INT
         FIELD qtchdcsg       AS INT
         FIELD qtchddci       AS INT
         FIELD qtchddcs       AS INT
         FIELD qtchddcg       AS INT
         FIELD qtchdtti       AS INT
         FIELD qtchdtts       AS INT
         FIELD qtchdttg       AS INT
         FIELD vlchdcxi       AS DEC
         FIELD vlchdcxs       AS DEC
         FIELD vlchdcxg       AS DEC
         FIELD vlchdcsi       AS DEC
         FIELD vlchdcss       AS DEC
         FIELD vlchdcsg       AS DEC
         FIELD vlchddci       AS DEC
         FIELD vlchddcs       AS DEC
         FIELD vlchddcg       AS DEC
         FIELD vlchdtti       AS DEC
         FIELD vlchdtts       AS DEC
         FIELD vlchdttg       AS DEC.

DEFINE TEMP-TABLE tt-doctos                                            NO-UNDO
         FIELD cdagenci       LIKE craptvl.cdagenci
         FIELD cdbccxlt       LIKE craptvl.cdbccxlt
         FIELD nrdolote       LIKE craptvl.nrdolote
         FIELD nrdconta       LIKE craptvl.nrdconta
         FIELD nrdocmto       LIKE craptvl.nrdocmto
         FIELD vldocrcb       LIKE craptvl.vldocrcb.

DEF TEMP-TABLE cratdev        LIKE crapdev.

DEF TEMP-TABLE crawarq                                                 NO-UNDO
    FIELD dscooper AS CHAR
    FIELD tparquiv AS CHAR
    FIELD nmarquiv AS CHAR.

DEF TEMP-TABLE w-arquivos                                              NO-UNDO
    FIELD dscooper AS CHAR
    FIELD tparquiv AS CHAR  
    FIELD dsarquiv AS CHAR.

DEF QUERY q_w-arquivos FOR w-arquivos.

DEF BROWSE b_w-arquivos QUERY q_w-arquivos
    DISPLAY w-arquivos.dscooper COLUMN-LABEL "COOPERATIVA" FORMAT "x(13)"
            w-arquivos.tparquiv COLUMN-LABEL "TIPO"        FORMAT "x(16)"
            w-arquivos.dsarquiv COLUMN-LABEL "DESCRICAO"   FORMAT "x(35)"
    WITH 6 DOWN WIDTH 75 SCROLLBAR-VERTICAL 
           TITLE "Arquivos a serem processados".


DEF TEMP-TABLE w-arq-dir                                               NO-UNDO
    FIELD dscooper AS CHAR  
    FIELD dsmensag AS CHAR.

DEF QUERY q_w-arq-dir FOR w-arq-dir.

DEF BROWSE b_w-arq-dir
     QUERY q_w-arq-dir
   DISPLAY w-arq-dir.dscooper COLUMN-LABEL "COOPERATIVA"  FORMAT "x(14)"
           w-arq-dir.dsmensag COLUMN-LABEL "MENSAGEM"     FORMAT "x(33)"
    WITH 09 DOWN TITLE "Validacao Diretorio /Micros".
                

FUNCTION proc_coop_executando RETURNS LOGICAL (INPUT par_cdcooper AS INTEGER) FORWARD.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03
               LABEL "Opcao" AUTO-RETURN
                HELP "Informe a opcao desejada (E, I, B, C, L, P, V, X)."
            VALIDATE(CAN-DO("B,C,E,I,L,P,V,X",glb_cddopcao),
                              "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prcctl_1.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa"
     tel_cdagenci AT 39 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
     SKIP
     tel_nmprgexe AT 07 LABEL "Processar"
                        HELP "Informe qual tipo de arquivo a processar"
     tel_flgenvio AT 43 LABEL "Opcao"
                  HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     SKIP
     tel_tpdevolu AT 09 LABEL "Devolucao"
                        HELP "Informe o tipo de devolucao a ser gerada"
     tel_dtrefere AT 39 LABEL "Data Referencia"
                        HELP "Informe a data de referencia"
     tel_datadlog AT 10 LABEL "Data Log"
                        HELP "Informe a data para visualizar LOG"
     tel_pesquisa AT 32 LABEL "Pesquisar"
                  HELP "Informe texto a pesquisar (espaco em branco, tudo)."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_prcctl_2.


/* FORM de RESULTADOS da CONSULTA */
FORM "Qtd.               Valor" AT 36 
     SKIP(1)
     tt-titulos.qttitrec AT 13 FORMAT "zzz,zz9" LABEL "Titulos Recebidos"
     tt-titulos.vltitrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     tt-titulos.qttitrgt AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Resgatados"
     tt-titulos.vltitrgt AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP
     tt-titulos.qttiterr AT 09 FORMAT "zzz,zz9-" LABEL "Titulos com Problemas"
     tt-titulos.vltiterr AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)
     tt-titulos.qttitprg AT 02 FORMAT "zzz,zz9-" 
                                      LABEL "Total de Titulos Programados"
     tt-titulos.vltitprg AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP
     tt-titulos.qttitcxa AT 02 FORMAT "zzz,zz9" 
                                      LABEL "Titulos Arrecadados no Caixa"
     tt-titulos.vltitcxa AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     tt-titulos.qttitulo AT 06 FORMAT "zzz,zz9" LABEL "Total dos Titulos do Dia"
     tt-titulos.vltitulo AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     WITH ROW 10 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total_titulo.

FORM "----- Inferior ----- ----- Superior ----- ------- Total ------" AT 16
     SKIP(1)
     "Caixa:"     AT  9
     tt-compel.qtchdcxi AT 16 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcxi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdcxs AT 37 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcxs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdcxg AT 58 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcxg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Custodia:"  AT  6
     tt-compel.qtchdcsi AT 16 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcsi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdcss AT 37 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcss AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdcsg AT 58 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdcsg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Desconto:"  AT  6
     tt-compel.qtchddci AT 16 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchddci AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchddcs AT 37 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchddcs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchddcg AT 58 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchddcg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "Cooperativa:"  AT 3
     aux_qtchdcci    AT 16 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdcci    AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     aux_qtchdccs    AT 37 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdccs    AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     aux_qtchdccg    AT 58 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdccg    AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Terceiros:"   AT 5
     aux_qtchdcti   AT 16 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdcti   AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     aux_qtchdcts   AT 37 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdcts   AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     aux_qtchdctg   AT 58 FORMAT "zzzz9"          NO-LABEL
     aux_vlchdctg   AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "TOTAL GERAL:" AT 3
     tt-compel.qtchdtti AT 16 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdtti AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdtts AT 37 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdtts AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tt-compel.qtchdttg AT 58 FORMAT "zzzz9"          NO-LABEL
     tt-compel.vlchdttg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     WITH ROW 11 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_total_compel.

FORM tel_qtdtotal       LABEL "Quantidade Total" 
     tel_vlrtotal AT 34 LABEL "Valor Total"
     WITH ROW 20 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_totais_doctos.

FORM tel_qtdevolv       LABEL "Devolucao Normal" 
     tel_qtadevol AT 34 LABEL "Devolucao Condicional"
     WITH ROW 13 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_total_devolu.


FORM SKIP(1)
     b_w-arq-dir AT  3 HELP "Use as SETAS para navegar e <F4> para sair"
     SKIP(1)
     WITH NO-LABEL ROW 6 CENTERED  OVERLAY NO-BOX WITH FRAME f_valida_dir.


FORM SKIP(1)
     aux_dsdsenha AT  3 LABEL "Senha" FORMAT "x(15)" BLANK
                        HELP "Informe a senha da Intranet BANCOOB"
                        VALIDATE(aux_dsdsenha <> "","003 - Senha errada.")
     SKIP(1)
     WITH ROW 11 WIDTH 28 CENTERED OVERLAY TITLE "Senha Intranet BANCOOB"
          SIDE-LABEL FRAME f_senha_bancoob.

FORM SKIP(1)
     b_w-arquivos AT  3 HELP "Pressione DELETE para excluir / F4 para sair"
     SKIP(2)
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prcctl_browse.

FORM SKIP
     "PROTOCOLO DE ARQUIVOS GERADOS OU A SEREM GERADOS - "    AT 10
     glb_dtmvtolt       FORMAT "99/99/9999"
     SKIP(3)
     "QUANTIDADE DE CHEQUES"        AT 30
     "-------------------------"    AT 28
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_devolu_cab_1.


FORM "COOPERATIVA"                  AT  1
     "1a DEVOLU"                    AT 23
     "2a DEVOLU"                    AT 44
     "TOTAL"                        AT 67 SKIP
     "---------------"              AT  1
     "-------------------"          AT 18
     "-------------------"          AT 39
     "-------------------"          AT 60
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_devolu_cab_2.

FORM aux_nmrescop                   AT  1 FORMAT "x(15)"
     rel_qtpridev                   AT 18 FORMAT "zzz9"
     rel_vlpridev                   AT 24 FORMAT "zz,zzz,zz9.99"
     rel_qtsegdev                   AT 39 FORMAT "zzz9"
     rel_vlsegdev                   AT 45 FORMAT "zz,zzz,zz9.99"
     rel_qtgercop                   AT 60 FORMAT "zzz9"
     rel_vlgercop                   AT 66 FORMAT "zz,zzz,zz9.99"
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_protocolo_devolu.

FORM SKIP
     "---------------"              AT  1
     "-------------------"          AT 18
     "-------------------"          AT 39
     "-------------------"          AT 60 SKIP
     "TOTAL"                        AT  1
     tot_qtpridev                   AT 18 FORMAT "zzz9"
     tot_vlpridev                   AT 24 FORMAT "zz,zzz,zz9.99"
     tot_qtsegdev                   AT 39 FORMAT "zzz9"
     tot_vlsegdev                   AT 45 FORMAT "zz,zzz,zz9.99"
     tot_qtdgeral                   AT 60 FORMAT "zzz9"
     tot_vlrgeral                   AT 66 FORMAT "zz,zzz,zz9.99"
     SKIP(2)
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_protocolo_devolu_tot.


DEF QUERY q_doctos FOR tt-doctos
                  FIELDS(cdagenci cdbccxlt nrdolote 
                         nrdconta nrdocmto vldocrcb).
                                     
DEF BROWSE b_doctos QUERY q_doctos 
    DISP  tt-doctos.cdagenci    COLUMN-LABEL "PA"
          tt-doctos.cdbccxlt    COLUMN-LABEL "BANCO/CAIXA"
          tt-doctos.nrdolote    COLUMN-LABEL "Lote"
          tt-doctos.nrdconta    COLUMN-LABEL "Conta"
          tt-doctos.nrdocmto    COLUMN-LABEL "Docto"
          tt-doctos.vldocrcb    COLUMN-LABEL "Valor"               
          WITH 6 DOWN.

DEF FRAME f_doctos_browse
          SKIP(1)
          b_doctos    HELP  "Pressione <F4> ou <END> p/finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 09.


ON RETURN OF tel_nmprgexe DO:
  
  tel_nmprgexe = tel_nmprgexe:SCREEN-VALUE.

  /*--- Inicializa com todas as agencias --*/
  EMPTY TEMP-TABLE crawage.
  
  IF  INT(tel_cdcooper) = 0  THEN 
      DO:
          FOR EACH crapage NO-LOCK:
               CREATE crawage.
               ASSIGN crawage.cdcooper = crapage.cdcooper
                      crawage.cdagenci = crapage.cdagenci
                      crawage.nmresage = crapage.nmresage
                      crawage.cdcomchq = crapage.cdcomchq
                      crawage.cdbantit = crapage.cdbantit
                      crawage.cdbandoc = crapage.cdbandoc
                      crawage.nmcidade = crapage.nmcidade 
                      crawage.cdagecbn = crapage.cdagecbn
                      crawage.cdbanchq = crapage.cdbanchq.
          END.
      END.
  ELSE 
      DO:
          FOR EACH crapage WHERE 
                   crapage.cdcooper = INT(tel_cdcooper) NO-LOCK:
              CREATE crawage.
              ASSIGN crawage.cdcooper = crapage.cdcooper
                     crawage.cdagenci = crapage.cdagenci
                     crawage.nmresage = crapage.nmresage
                     crawage.cdcomchq = crapage.cdcomchq
                     crawage.cdbantit = crapage.cdbantit
                     crawage.cdbandoc = crapage.cdbandoc
                     crawage.nmcidade = crapage.nmcidade 
                     crawage.cdagecbn = crapage.cdagecbn
                     crawage.cdbanchq = crapage.cdbanchq.
          END.
      END.
  APPLY "GO".
END.

ON RETURN OF tel_cdcooper DO:

  ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
         aux_contador = 0
         tel_nmprgexe:SCREEN-VALUE = ""
         tel_nmprgexe = "".

   IF INT(tel_cdcooper) = 0 THEN 
      ASSIGN tel_nmprgexe:LIST-ITEMS = "COMPEL,DEVOLU,DOCTOS,TITULO,CAF,CCF,"
                                     + "CONTRA-ORDEM,CUSTODIA,"
                                     + "FAC/ROC,RELACIONAMENTO,"
                                     + "TIC,ICFJUD,DEVDOC".
   ELSE
      ASSIGN tel_nmprgexe:LIST-ITEMS = "COMPEL,DEVOLU,DOCTOS,TITULO," + 
                                       "CAF,CCF,CONTRA-ORDEM,FAC/ROC," +
                                       "TIC,DEVDOC".

  APPLY "GO".

END.

ON RETURN OF tel_tpdevolu DO:

    ASSIGN tel_tpdevolu = tel_tpdevolu:SCREEN-VALUE.
    
    IF   tel_tpdevolu = "VLB" THEN
         ASSIGN aux_nrseqsol = 4.
    ELSE
    IF   tel_tpdevolu = "Diurna" THEN
         ASSIGN aux_nrseqsol = 5.
    ELSE
         ASSIGN aux_nrseqsol = 6.

    APPLY "GO".
END.


/* Alimenta SELECTION-LIST de COOPERATIVAS */
FOR EACH crapcop 
    WHERE crapcop.cdcooper <> 3
      AND crapcop.flgativo = TRUE
      NO-LOCK BY crapcop.dsdircop:

    IF   crapcop.cdbcoctl <> 85 THEN   /* Execucao apenas para 85*/
         NEXT. 

    IF   aux_contador = 0 THEN
         ASSIGN aux_nmcooper = "TODAS,0," + CAPS(crapcop.dsdircop) + "," +
                               STRING(crapcop.cdcooper)
                aux_contador = 1.
    ELSE
          ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                             + "," + STRING(crapcop.cdcooper).
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

ON "DELETE" OF b_w-arquivos IN FRAME f_prcctl_browse
    DO:
        IF   NOT AVAILABLE w-arquivos  THEN
             RETURN.

        DELETE w-arquivos.

        ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_w-arquivos").

        CLOSE QUERY q_w-arquivos.
        
        OPEN QUERY q_w-arquivos FOR EACH w-arquivos BY w-arquivos.tparquiv
                                                    BY w-arquivos.dscooper.

        REPOSITION q_w-arquivos TO ROW aux_ultlinha.
    END.

ASSIGN glb_cddopcao = "B"
       glb_cdcritic = 0
       tel_dtrefere = glb_dtmvtolt
       aux_nmarqlog = "log/prcctl_" +
                      STRING(YEAR(glb_dtmvtolt),"9999") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   HIDE b_w-arquivos IN FRAME f_prcctl_browse.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN 
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_prcctl_1.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO:    /*   F4 OU FIM   */
        RUN fontes/novatela.p.
        IF   CAPS(glb_nmdatela) <> "PRCCTL"  THEN DO:
             HIDE FRAME f_prcctl_1.
             HIDE FRAME f_prcctl_2.
             HIDE FRAME f_moldura.
             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.
             HIDE MESSAGE NO-PAUSE.
             RETURN.
        END.
        ELSE
             NEXT.
   END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF (glb_cdcooper <> 3                      AND
       glb_cddopcao <> "B"                    AND
	   glb_cddopcao <> "L"                    AND
	   glb_cddopcao <> "C")                      OR
      (glb_cddepart <> 20  AND   /* TI"                  */
       glb_cddepart <>  8  AND   /* COORD.ADM/FINANCEIRO */
       glb_cddepart <> 11  AND   /* FINANCEIRO           */
       glb_cddepart <>  9  AND   /* COORD.PRODUTOS       */
       glb_cddepart <>  6  AND   /* CONTABILIDADE        */
       glb_cddepart <>  4 )THEN  /* COMPE                */
        DO:
            BELL.
            MESSAGE "Operador sem autorizacao para processar arquivos"
                    "do Banco AILOS".
            NEXT.
        END.
     
   CASE glb_cddopcao:

        WHEN "B" THEN DO:       /*   Gerar  Arquivo   */

             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.
             HIDE MESSAGE NO-PAUSE.
             
             HIDE tel_flgenvio tel_datadlog
                  tel_tpdevolu tel_dtrefere tel_pesquisa IN FRAME f_prcctl_2.

             CLEAR FRAME f_prcctl_2.

             VIEW tel_nmprgexe IN FRAME f_prcctl_2.
             VIEW tel_cdagenci IN FRAME f_prcctl_2.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_cdcooper WITH FRAME f_prcctl_2.
                UPDATE tel_nmprgexe WITH FRAME f_prcctl_2.

				IF glb_cdcooper <> 3        AND
				   tel_nmprgexe <> "DEVOLU" AND
				   tel_nmprgexe <> "DEVDOC" THEN
				DO:
				  MESSAGE tel_nmprgexe + ", deve ser executada na cooperativa AILOS".
				  NEXT.
				END.

                IF tel_nmprgexe = "COMPEL"
                OR tel_nmprgexe = "TITULO"
                OR tel_nmprgexe = "DOCTOS" THEN
                   UPDATE tel_cdagenci WITH FRAME f_prcctl_2.
                ELSE
                   HIDE tel_cdagenci tel_flgenvio IN FRAME f_prcctl_2.

                IF  (tel_nmprgexe  = "RELACIONAMENTO" OR
                     tel_nmprgexe  = "CUSTODIA")      
                    AND
                    INT(tel_cdcooper) <> 0 THEN DO:
                    MESSAGE "Para " + tel_nmprgexe + ", deve ser selecionada TODAS"
                            "cooperativas".
                    NEXT.
                END.
                
                IF tel_nmprgexe:SCREEN-VALUE = "DEVOLU" THEN
                DO:
                    VIEW tel_tpdevolu IN FRAME f_prcctl_2.
                    UPDATE tel_tpdevolu WITH FRAME f_prcctl_2.
                END.

                /* Alteração Data Referencia para TI - Jonatas*/  
                IF  glb_cddepart = 20 /* TI */          AND 
                    NOT CAN-DO("CUSTODIA",tel_nmprgexe) AND 
                    NOT CAN-DO("TIC",tel_nmprgexe)      AND 
                    NOT CAN-DO("DEVDOC",tel_nmprgexe) THEN 
                    DO:
                        VIEW tel_dtrefere IN FRAME f_prcctl_2.
                        UPDATE tel_dtrefere WITH FRAME f_prcctl_2. 
                        
                        IF tel_dtrefere = ? THEN DO:
                            MESSAGE "Você deve informar uma data de referência".
                            NEXT.
                        END.
                    END.
                ELSE
                   ASSIGN tel_dtrefere = glb_dtmvtolt.
                
                                
                IF tel_nmprgexe = ? THEN DO:
                   MESSAGE "Voce deve selecionar uma funcao em Processar".
                   NEXT.
                END.

                LEAVE.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                NEXT.

             IF   tel_cdagenci = 0 THEN
                  ASSIGN aux_pacfinal = 9999.
             ELSE
                  ASSIGN aux_pacfinal = tel_cdagenci.


             /*   Verifica se os titulos e faturas pagos tiveram os seus 
                  devidos debitos efetuados nas contas   */

             IF   tel_cdagenci = 90 THEN
                  DO:
                      IF   INT(tel_cdcooper) = 0 THEN  /* TODAS */
                           DO:
                                FOR EACH crapcop 
                                   WHERE crapcop.cdcooper <> 3
                                     AND crapcop.flgativo = TRUE
                                     NO-LOCK:
                                    
                                    glb_cdcritic = 0.

                                    RUN proc_verifica_pac_internet(
                                                     INPUT crapcop.cdcooper).
              
                                    IF   glb_cdcritic <> 0   THEN
                                         LEAVE.
                                END.                       
                                
                                IF   glb_cdcritic <> 0   THEN
                                     NEXT.
                           END.
                      ELSE
                           DO:
                               glb_cdcritic = 0.

                               RUN proc_verifica_pac_internet(
                                                    INPUT tel_cdcooper).

                               IF   glb_cdcritic <> 0   THEN
                                    NEXT.
                           END.
                  END.
                  
             MESSAGE "Aguarde... Gerando arquivo(s)...".

             /* Criar solicitacao para estes tipos de programas */
             IF  CAN-DO("RELACIONAMENTO,CCF,CONTRA-ORDEM,CUSTODIA",tel_nmprgexe)  THEN
                 DO TRANSACTION:
                     /* Limpa solicitacao se existente */
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 199             AND
                                crapsol.dtrefere = tel_dtrefere   
                                NO-LOCK NO-ERROR.
                                
                     IF  AVAILABLE crapsol  THEN
                          DO:
                              FIND CURRENT crapsol EXCLUSIVE-LOCK.
                              DELETE crapsol.
                          END.

                   CREATE crapsol. 
                   ASSIGN crapsol.nrsolici = 199
                          crapsol.dtrefere = tel_dtrefere
                          crapsol.nrseqsol = 1
                          crapsol.cdempres = 11
                          crapsol.dsparame = ""
                          crapsol.insitsol = 1
                          crapsol.nrdevias = 0
                          crapsol.cdcooper = glb_cdcooper.
                   VALIDATE crapsol.
                 END.
             
             CASE tel_nmprgexe:

                 WHEN "RELACIONAMENTO" THEN DO:
                     RUN fontes/crps532.p.
                 END.

                 WHEN "CCF" THEN DO:
                     RUN fontes/crps549.p. 
                 END.
                 
                 WHEN "CONTRA-ORDEM" THEN DO:
                     RUN fontes/crps561.p.
                 END.

                 WHEN "CUSTODIA" THEN DO:
                     RUN fontes/crps588.p.
                 END.

                 WHEN "ICFJUD" THEN DO:
                     /* Instancia a BO */
                     RUN sistema/generico/procedures/b1wgen0154.p 
                         PERSISTENT SET h-b1wgen0154.
    
                     IF   NOT VALID-HANDLE(h-b1wgen0154)  THEN
                          DO:
                            glb_nmdatela = "PRCCTL".
                            BELL.
                            MESSAGE
                            "Handle invalido para BO b1wgen0154.".
                            IF   glb_conta_script = 0 THEN
                                 PAUSE 3 NO-MESSAGE.
                            RETURN.
                          END.

                     RUN gerar_icf604 IN h-b1wgen0154(INPUT  glb_cdcooper,
                                                      INPUT  tel_dtrefere,
                                                      OUTPUT aux_dsmsgerr).
                     DELETE PROCEDURE h-b1wgen0154.

                     IF  aux_dsmsgerr <> "" THEN DO:
                         MESSAGE aux_dsmsgerr.
                         PAUSE 2 NO-MESSAGE.
                     END.

                 END.

                 WHEN "COMPEL" OR
                 WHEN "DOCTOS" OR
                 WHEN "TITULO" OR 
                 WHEN "TIC"    THEN DO:

                     ASSIGN tot_qtarquiv = 0 
                            tot_totregis = 0 
                            tot_vlrtotal = 0.

                     HIDE MESSAGE NO-PAUSE.
                     
                     IF INT(tel_cdcooper) = 0 THEN DO: /* TODAS */

                         FOR EACH crapcop 
                            WHERE crapcop.cdcooper <> 3
                              AND crapcop.flgativo = TRUE NO-LOCK:
                             
                             RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                   INPUT "Inicio execucao",
                                                   INPUT crapcop.cdcooper,
                                                   INPUT "").                        

                             /* Instancia a BO */
                             RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                             IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                                  DO:
                                    glb_nmdatela = "PRCCTL".
                                    BELL.
                                    MESSAGE
                                    "Handle invalido para BO b1wgen0012.".

                                    RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                          INPUT "Handle invalido para BO b1wgen0012.",
                                                          INPUT crapcop.cdcooper,
                                                          INPUT "").

                                    RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                          INPUT "Fim execucao",
                                                          INPUT crapcop.cdcooper,
                                                          INPUT "").

                                    IF   glb_conta_script = 0 THEN
                                         PAUSE 3 NO-MESSAGE.
                                    RETURN.
                                  END.
                             
                             RUN gerar_arquivos_cecred
                                 IN h-b1wgen0012(INPUT  tel_nmprgexe,
                                                 INPUT  tel_dtrefere,
                                                 INPUT  crapcop.cdcooper,
                                                 INPUT  tel_cdagenci,
                                                 INPUT  aux_pacfinal,
                                                 INPUT  glb_cdoperad,
                                                 INPUT  "PRCCTL",
                                                 INPUT  0,   /* nrdolote */
                                                 INPUT  0,   /* nrdcaixa */
                                                 INPUT  "",  /* cdbccxlt */
                                                 OUTPUT glb_cdcritic,
                                                 OUTPUT aux_qtarquiv,
                                                 OUTPUT aux_totregis,
                                                 OUTPUT aux_vlrtotal).

                             ASSIGN tot_qtarquiv = tot_qtarquiv + aux_qtarquiv
                                    tot_totregis = tot_totregis + aux_totregis
                                    tot_vlrtotal = tot_vlrtotal + aux_vlrtotal.
                             
                             IF   crapcop.cdcooper = 16       AND
                                  tel_nmprgexe     = "COMPEL" THEN
                                  DO:
                                      RUN gerar_compel_altoVale
                                          IN h-b1wgen0012(
                                                 INPUT  tel_dtrefere,
                                                 INPUT  crapcop.cdcooper,
                                                 INPUT  glb_cdoperad,
                                                 OUTPUT glb_cdcritic,
                                                 OUTPUT aux_qtarquiv,
                                                 OUTPUT aux_totregis,
                                                 OUTPUT aux_vlrtotal).

                                      ASSIGN tot_qtarquiv = tot_qtarquiv + 
                                                            aux_qtarquiv
                                             tot_totregis = tot_totregis + 
                                                            aux_totregis
                                             tot_vlrtotal = tot_vlrtotal + 
                                                            aux_vlrtotal.
                                  END.
                             
                             DELETE PROCEDURE h-b1wgen0012.
                             
                             IF   tel_nmprgexe <> "TIC" THEN
                                   RUN gera_relatorios (INPUT crapcop.cdcooper,
                                                        INPUT tel_dtrefere).
                         
                             RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                   INPUT "Fim execucao",
                                                   INPUT crapcop.cdcooper,
                                                   INPUT "").                        
                                  
                         END.

                     END.
                     ELSE DO:

                         RUN gera_log_execucao(INPUT tel_nmprgexe,
                                               INPUT "Inicio execucao",
                                               INPUT tel_cdcooper,
                                               INPUT "").                        

                         /* Instancia a BO */
                         RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                         IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                              DO:
                                  glb_nmdatela = "PRCCTL".
                                  BELL.
                                  MESSAGE 
                                  "Handle invalido para BO b1wgen0012.".

                                  RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                        INPUT "Handle invalido para BO b1wgen0012.",
                                                        INPUT tel_cdcooper,
                                                        INPUT "").  

                                  RUN gera_log_execucao(INPUT tel_nmprgexe,
                                                        INPUT "Fim execucao",
                                                        INPUT tel_cdcooper,
                                                        INPUT "").                        

                                  IF   glb_conta_script = 0 THEN
                                       PAUSE 3 NO-MESSAGE.
                                  RETURN.
                              END.
                         
                         RUN gerar_arquivos_cecred
                                 IN h-b1wgen0012(INPUT  tel_nmprgexe,
                                                 INPUT  tel_dtrefere,
                                                 INPUT  INT(tel_cdcooper),
                                                 INPUT  tel_cdagenci,
                                                 INPUT  aux_pacfinal,
                                                 INPUT  glb_cdoperad,
                                                 INPUT  "PRCCTL",
                                                 INPUT  0,   /* nrdolote */
                                                 INPUT  0,   /* nrdcaixa */
                                                 INPUT  "",  /* cdbccxlt */
                                                 OUTPUT glb_cdcritic,
                                                 OUTPUT aux_qtarquiv,
                                                 OUTPUT aux_totregis,
                                                 OUTPUT aux_vlrtotal).

                         ASSIGN tot_qtarquiv = tot_qtarquiv + aux_qtarquiv
                                tot_totregis = tot_totregis + aux_totregis
                                tot_vlrtotal = tot_vlrtotal + aux_vlrtotal.
                         
                         
                         IF   INT(tel_cdcooper) = 16       AND
                              tel_nmprgexe      = "COMPEL" THEN
                              DO:
                                  RUN gerar_compel_altoVale IN h-b1wgen0012(
                                                 INPUT  tel_dtrefere,
                                                 INPUT  INT(tel_cdcooper),
                                                 INPUT  glb_cdoperad,
                                                 OUTPUT glb_cdcritic,
                                                 OUTPUT aux_qtarquiv,
                                                 OUTPUT aux_totregis,
                                                 OUTPUT aux_vlrtotal).

                                  ASSIGN tot_qtarquiv = tot_qtarquiv + 
                                                        aux_qtarquiv
                                         tot_totregis = tot_totregis + 
                                                        aux_totregis
                                         tot_vlrtotal = tot_vlrtotal + 
                                                        aux_vlrtotal.
                              END.
                         
                         DELETE PROCEDURE h-b1wgen0012.
                         
                         IF   tel_nmprgexe <> "TIC" THEN
                              RUN gera_relatorios (INPUT INT(tel_cdcooper),
                                                   INPUT tel_dtrefere).

                         RUN gera_log_execucao(INPUT tel_nmprgexe,
                                               INPUT "Fim execucao",
                                               INPUT tel_cdcooper,
                                               INPUT "").                        

                     END.

                     IF   glb_cdcritic > 0   THEN
                          DO:
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              PAUSE 2 NO-MESSAGE.
                          END.

                 END.

                 WHEN "DEVOLU" THEN
                      DO:
                          IF   INT(tel_cdcooper) = 0 THEN   /* Todas Coops */
                               DO:
                                   FOR EACH crapcop 
                                      WHERE crapcop.cdcooper <> 3
                                        AND crapcop.flgativo = TRUE NO-LOCK:

                                       RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                             INPUT "Inicio execucao",
                                                             INPUT crapcop.cdcooper,
                                                             INPUT "").                        

									   IF proc_coop_executando(crapcop.cdcooper) THEN
									      DO:										  
											   RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
																	 INPUT "Cooperativa nao finalizou o processo",
																	 INPUT crapcop.cdcooper,
																	 INPUT "").                        			
																	 
											   RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
																	 INPUT "Fim execucao",
																	 INPUT crapcop.cdcooper,
																	 INPUT "").
																	 
									           NEXT.
										  END.

                                       FIND crapsol WHERE 
                                            crapsol.cdcooper = 
                                                        crapcop.cdcooper    AND
                                            crapsol.dtrefere = tel_dtrefere AND
                                            crapsol.nrsolici = 78           AND
                                            crapsol.nrseqsol = aux_nrseqsol
                                            NO-LOCK NO-ERROR.
                                       
                                       IF   AVAILABLE crapsol THEN
                                            DO:
                                                glb_cdcritic = 138.
                                                RUN fontes/critic.p.
                                                BELL.
                                                MESSAGE glb_dscritic +
                                                      STRING(crapcop.nmrescop).

                                                RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                                      INPUT glb_dscritic + STRING(crapcop.nmrescop),
                                                                      INPUT crapcop.cdcooper,
                                                                      INPUT "").                        

                                                RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                                      INPUT "Fim execucao",
                                                                      INPUT crapcop.cdcooper,
                                                                      INPUT "").

                                                glb_cdcritic = 0.
                                                PAUSE 5 NO-MESSAGE.
                                                NEXT.
                                            END.
                                                
                                       DO TRANSACTION:
 
                                          CREATE crapsol.
                                          ASSIGN crapsol.cdcooper =
                                                         crapcop.cdcooper
                                                 crapsol.nrsolici = 78
                                                 crapsol.dtrefere = tel_dtrefere
                                                 crapsol.cdempres = 11
                                                 crapsol.dsparame = ""
                                                 crapsol.insitsol = 1
                                                 crapsol.nrdevias = 1
                                                 crapsol.nrseqsol = 
                                                         aux_nrseqsol.
                                          VALIDATE crapsol.
                                       END.
     
                                       IF  crapcop.cdcooper <> glb_cdcooper THEN
									       DO:
                                       
                                       DO TRANSACTION:
                                          CREATE crapsol.
                                          ASSIGN crapsol.cdcooper = glb_cdcooper
                                                 crapsol.nrsolici = 78
                                                 crapsol.dtrefere = tel_dtrefere
                                                 crapsol.cdempres = 11
                                                 crapsol.dsparame = ""
                                                 crapsol.insitsol = 1
                                                 crapsol.nrdevias = 1
                                                 crapsol.nrseqsol = 
                                                                 aux_nrseqsol.
                                          VALIDATE crapsol NO-ERROR.
                                       END.
                                       
											END.
                                       
                                       IF tel_tpdevolu = "VLB" THEN
                                           RUN fontes/crps264.p 
                                                      (INPUT crapcop.cdcooper,
                                                       INPUT 4).
                                       ELSE
                                       IF tel_tpdevolu = "Diurna" THEN
                                           RUN fontes/crps264.p
                                                       (INPUT crapcop.cdcooper,
                                                        INPUT 5).
                                       ELSE
                                           RUN fontes/crps264.p
                                                       (INPUT crapcop.cdcooper,
                                                        INPUT 6).
                                               
                                       DO TRANSACTION:                          
                                           
                                          FIND crapsol WHERE 
                                            crapsol.cdcooper = glb_cdcooper AND
                                            crapsol.dtrefere = tel_dtrefere AND
                                            crapsol.nrsolici = 78           AND
                                            crapsol.nrseqsol = aux_nrseqsol
                                            EXCLUSIVE-LOCK NO-ERROR.

                                          IF  AVAILABLE crapsol THEN
                                              DELETE crapsol.
                                       END.

                                       RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                             INPUT "Fim execucao",
                                                             INPUT crapcop.cdcooper,
                                                             INPUT "").
                                   END.
                               END.
                          ELSE            /* Para 1 coop. selecionada */
                               DO:

								   IF proc_coop_executando(INTE(tel_cdcooper)) THEN
								      DO:
											MESSAGE "Processo da cooperativa nao finalizado.".
											PAUSE 2 NO-MESSAGE.
											NEXT.
									  END.

                                   RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                         INPUT "Inicio execucao",
                                                         INPUT tel_cdcooper,
                                                         INPUT "").                        
                                    
                                   FIND crapsol WHERE 
                                        crapsol.cdcooper = INT(tel_cdcooper) AND
                                        crapsol.dtrefere = tel_dtrefere      AND
                                        crapsol.nrsolici = 78                AND
                                        crapsol.nrseqsol = aux_nrseqsol
                                        NO-LOCK NO-ERROR.
                                       
                                   IF   AVAILABLE crapsol THEN
                                        DO:
                                            glb_cdcritic = 138.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic.

                                            RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                                  INPUT glb_dscritic,
                                                                  INPUT tel_cdcooper,
                                                                  INPUT "").                        

                                            RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                                  INPUT "Fim execucao",
                                                                  INPUT tel_cdcooper,
                                                                  INPUT "").                       

                                            glb_cdcritic = 0.
                                            PAUSE 5 NO-MESSAGE.
                                            NEXT.
                                        END.

                                   DO TRANSACTION:
                                      CREATE crapsol.
                                      ASSIGN crapsol.cdcooper = 
                                                    INT(tel_cdcooper)
                                             crapsol.nrsolici = 78
                                             crapsol.dtrefere = tel_dtrefere
                                             crapsol.cdempres = 11
                                             crapsol.dsparame = ""
                                             crapsol.insitsol = 1
                                             crapsol.nrdevias = 1
                                             crapsol.nrseqsol = aux_nrseqsol.
                                      VALIDATE crapsol NO-ERROR.
                                   END.
                                   
								   IF INTE(tel_cdcooper) <> glb_cdcooper THEN
								   DO:
                                   DO TRANSACTION:
                                          CREATE crapsol.
                                          ASSIGN crapsol.cdcooper = glb_cdcooper
                                                 crapsol.nrsolici = 78
                                                 crapsol.dtrefere = tel_dtrefere
                                                 crapsol.cdempres = 11
                                                 crapsol.dsparame = ""
                                                 crapsol.insitsol = 1
                                                 crapsol.nrdevias = 1
                                                 crapsol.nrseqsol = 
                                                                 aux_nrseqsol.
                                          VALIDATE crapsol NO-ERROR.
                                       END.
                                   END.
                                       IF tel_tpdevolu = "VLB" THEN
                                           RUN fontes/crps264.p 
                                                      (INPUT INT(tel_cdcooper),
                                                       INPUT 4).
                                       ELSE
                                       IF tel_tpdevolu = "Diurna" THEN
                                       DO:
                                           RUN fontes/crps264.p
                                                       (INPUT INT(tel_cdcooper),
                                                        INPUT 5).
                                       END.
                                       ELSE
                                           RUN fontes/crps264.p
                                                       (INPUT INT(tel_cdcooper),
                                                        INPUT 6). 
                                       
                                       DO TRANSACTION:
                                  
                                          FIND crapsol WHERE 
                                            crapsol.cdcooper = glb_cdcooper AND
                                            crapsol.dtrefere = tel_dtrefere AND
                                            crapsol.nrsolici = 78           AND
                                            crapsol.nrseqsol = aux_nrseqsol
                                            EXCLUSIVE-LOCK NO-ERROR.

                                          IF  AVAILABLE crapsol THEN
                                              DELETE crapsol.
                                       END.

                                       RUN gera_log_execucao(INPUT "DEVOLUCAO " + tel_tpdevolu,
                                                             INPUT "Fim execucao",
                                                             INPUT tel_cdcooper,
                                                             INPUT "").                        

                               END. 
                      END.
                 
                 WHEN "DEVDOC" THEN DO:

                    IF  INT(tel_cdcooper) = 0 THEN  /* TODAS */
                    DO:
                        
                        FOR EACH crapcop 
                           WHERE crapcop.flgativo = TRUE NO-LOCK:

                            RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                  INPUT "Inicio execucao",
                                                  INPUT crapcop.cdcooper,
                                                  INPUT "").                        
                          
						    IF proc_coop_executando(crapcop.cdcooper) THEN
							   DO:
									RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
														  INPUT "Processo da cooperativa nao finalizado",
														  INPUT crapcop.cdcooper,
														  INPUT "").                        

									RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
														  INPUT "Fim execucao",
														  INPUT crapcop.cdcooper,
														  INPUT "").

									NEXT.
							   END.

                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                            
                            RUN STORED-PROCEDURE pc_crps680 NO-ERROR
                               (INPUT crapcop.cdcooper,
                                INPUT "PRCCTL",
                                INPUT INT(STRING(glb_flgresta,"1/0")),
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT 0, 
                                OUTPUT "").
                            
                            IF  ERROR-STATUS:ERROR  THEN DO:
                                DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                    ASSIGN aux_msgerora = aux_msgerora + 
                                           ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                                END.
                                    
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                  " - " + glb_cdprogra + "' --> '"  +
                                             "Erro ao executar Stored Procedure: '" +
                                             aux_msgerora + "' >> log/proc_message.log").

                                RETURN.
                            END.
                            
                            CLOSE STORED-PROCEDURE pc_crps680.
                            
                            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                            
                            ASSIGN glb_cdcritic = 0
                                   glb_dscritic = ""
                                   glb_cdcritic = pc_crps680.pr_cdcritic WHEN pc_crps680.pr_cdcritic <> ?
                                   glb_dscritic = pc_crps680.pr_dscritic WHEN pc_crps680.pr_dscritic <> ?
                                   glb_stprogra = IF pc_crps680.pr_stprogra = 1 THEN TRUE ELSE FALSE
                                   glb_infimsol = IF pc_crps680.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
                            
                            
                            IF  glb_cdcritic <> 0   OR
                                glb_dscritic <> ""  THEN
                                DO:
                                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"                    +
                                    "Erro ao rodar: " + STRING(glb_cdcritic)      + " " + 
                                    "'" + glb_dscritic + "'" + " >> log/proc_message.log").

                                    RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                          INPUT "Cooperativa: " + crapcop.nmrescop + " - " + glb_dscritic,
                                                          INPUT crapcop.cdcooper,
                                                          INPUT "").                        

                                    RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                          INPUT "Fim execucao",
                                                          INPUT crapcop.cdcooper,
                                                          INPUT "").

                                    MESSAGE "Cooperativa:" crapcop.nmrescop "-" glb_dscritic.

                                    RETURN. 
                                END.

                            RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                  INPUT "Fim execucao",
                                                  INPUT crapcop.cdcooper,
                                                  INPUT "").
                        END.

                        BELL.
                        MESSAGE "Processo finalizado com sucesso.".
                        /* READKEY. */
                        PAUSE 2 NO-MESSAGE.
                    END.
                    ELSE
                    DO:

					    IF  proc_coop_executando(INTE(tel_cdcooper)) THEN
						    DO:
								MESSAGE "Processo da cooperativa nao finalizado.".
								RETURN.
							END.

                        RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                              INPUT "Inicio execucao",
                                              INPUT tel_cdcooper,
                                              INPUT "").

                        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_crps680 NO-ERROR
                           (INPUT INT(tel_cdcooper),
                            INPUT "PRCCTL",
                            INPUT INT(STRING(glb_flgresta,"1/0")),
                            OUTPUT 0,
                            OUTPUT 0,
                            OUTPUT 0, 
                            OUTPUT "").

                        IF  ERROR-STATUS:ERROR  THEN DO:
                            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                ASSIGN aux_msgerora = aux_msgerora + 
                                       ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                            END.

                            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                              " - " + glb_cdprogra + "' --> '"  +
                                         "Erro ao executar Stored Procedure: '" +
                                         aux_msgerora + "' >> log/proc_message.log").
                            RETURN.
                        END.

                        CLOSE STORED-PROCEDURE pc_crps680.

                        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

                        ASSIGN glb_cdcritic = 0
                               glb_dscritic = ""
                               glb_cdcritic = pc_crps680.pr_cdcritic WHEN pc_crps680.pr_cdcritic <> ?
                               glb_dscritic = pc_crps680.pr_dscritic WHEN pc_crps680.pr_dscritic <> ?
                               glb_stprogra = IF pc_crps680.pr_stprogra = 1 THEN TRUE ELSE FALSE
                               glb_infimsol = IF pc_crps680.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


                        IF  glb_cdcritic <> 0   OR
                            glb_dscritic <> ""  THEN
                            DO:
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"                    +
                                "Erro ao rodar: " + STRING(glb_cdcritic)      + " " + 
                                "'" + glb_dscritic + "'" + " >> log/proc_message.log").

                                FIND crapcop WHERE crapcop.cdcooper = INT(tel_cdcooper) NO-LOCK NO-ERROR.

                                RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                      INPUT "Cooperativa: " + crapcop.nmrescop + " - " + glb_dscritic,
                                                      INPUT crapcop.cdcooper,
                                                      INPUT "").                        

                                RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                                      INPUT "Fim execucao",
                                                      INPUT crapcop.cdcooper,
                                                      INPUT "").

                                MESSAGE "Cooperativa:" crapcop.nmrescop "-" glb_dscritic.
                                RETURN.
                            END.

                        RUN gera_log_execucao(INPUT "DEVOLUCAO DOC",
                                              INPUT "Fim execucao",
                                              INPUT tel_cdcooper,
                                              INPUT "").                        

                        BELL.
                        MESSAGE "Processo finalizado com sucesso.".
                        PAUSE 2 NO-MESSAGE.
                    END.
                         
                 END.

                 OTHERWISE DO:
                     HIDE MESSAGE NO-PAUSE.
                     MESSAGE "Opcao 'B' nao disponivel para " 
                              tel_nmprgexe ".".
                     NEXT.
                 END.

             END CASE.

             /* Limpar solicitacao feita anteriormente */
             IF  CAN-DO("RELACIONAMENTO,CCF,CONTRA-ORDEM,CUSTODIA",
                        tel_nmprgexe)  THEN
                 DO TRANSACTION:
                     /* Limpa solicitacao se existente */
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 199             AND
                                crapsol.dtrefere = tel_dtrefere   
                                NO-LOCK NO-ERROR.
                                
                     IF  AVAILABLE crapsol  THEN
                          DO:
                              FIND CURRENT crapsol EXCLUSIVE-LOCK.
                              DELETE crapsol.
                          END.
                 END. /* Fim TRANSACTION */

             HIDE MESSAGE NO-PAUSE.
             
             CASE tel_nmprgexe:
                  WHEN "COMPEL" THEN
                       MESSAGE "Foi(ram) gravado(s) " 
                               STRING(tot_qtarquiv,"zzz9") +
                               " arquivo(s) - com o valor total: " + 
                               STRING(tot_vlrtotal / 100, "zzz,zzz,zz9.99").

                  WHEN "DOCTOS" THEN
                       MESSAGE "PROCESSANDO.. Foi(ram) gravado(s)"
                               STRING(tot_qtarquiv,"zzz9") +
                               " arquivo(s) -" tot_totregis "DOC(s)".

                  WHEN "TITULO" THEN
                       MESSAGE "Foi(ram) gravado(s)" STRING(tot_qtarquiv,
                                                            "zzz9") +
                               " arquivo(s) -" tot_totregis "titulo(s)".

                  WHEN "DEVOLU" THEN
                       MESSAGE "Foi(ram) executada(s) a(s) devolucao(oes)".

             END CASE.

             IF   glb_cdcritic > 0   THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      PAUSE 2 NO-MESSAGE.
                  END.
        END. /** END do WHEN "B" **/
    
    
        WHEN "C" THEN DO: /** CONSULTAR **/

             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.
             HIDE MESSAGE NO-PAUSE.

             VIEW tel_nmprgexe tel_dtrefere IN FRAME f_prcctl_2.
             HIDE tel_datadlog tel_tpdevolu tel_pesquisa IN FRAME f_prcctl_2.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_cdcooper WITH FRAME f_prcctl_2.

                IF INT(tel_cdcooper) = 0 THEN DO:
                   MESSAGE "Para Consulta, deve ser selecionada uma " +
                           "cooperativa".
                   NEXT.
                END.

                UPDATE tel_nmprgexe WITH FRAME f_prcctl_2.

                IF tel_nmprgexe = ? THEN DO:
                   MESSAGE "Voce deve selecionar uma funcao em Processar".
                   NEXT.
                END.

                IF  tel_nmprgexe = "CCF"            OR
                    tel_nmprgexe = "CONTRA-ORDEM"   OR
                    tel_nmprgexe = "RELACIONAMENTO" OR
                    tel_nmprgexe = "DEVOLU"         THEN
                    LEAVE.
                ELSE
                    UPDATE tel_cdagenci WITH FRAME f_prcctl_2.
                    UPDATE tel_flgenvio WITH FRAME f_prcctl_2.
                    UPDATE tel_dtrefere WITH FRAME f_prcctl_2.

                LEAVE.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  NEXT.

             IF   tel_cdagenci = 0 THEN
                  ASSIGN aux_pacfinal = 9999.
             ELSE
                  ASSIGN aux_pacfinal = tel_cdagenci.

             IF   tel_flgenvio THEN       /* Enviados */
                  ASSIGN aux_cdbcoenv = "85".
             ELSE                         /* Nao Enviados */
                  ASSIGN aux_cdbcoenv = "0".

             CASE tel_nmprgexe:
                  WHEN "COMPEL" THEN 
                        DO:
                            ASSIGN aux_qtchdcci = 0
                                   aux_vlchdcci = 0
                                   aux_qtchdccs = 0
                                   aux_vlchdccs = 0
                                   aux_qtchdccg = 0
                                   aux_vlchdccg = 0
                                   aux_qtchdcti = 0 
                                   aux_vlchdcti = 0  
                                   aux_qtchdcts = 0 
                                   aux_vlchdcts = 0 
                                   aux_qtchdctg = 0 
                                   aux_vlchdctg = 0.
                                   
                            RUN consultar_compel.
                            
                            FIND LAST tt-compel NO-LOCK NO-ERROR.

                            DISPLAY tt-compel.qtchdcxi tt-compel.vlchdcxi
                                    tt-compel.qtchdcxs tt-compel.vlchdcxs
                                    tt-compel.qtchdcxg tt-compel.vlchdcxg
                                    tt-compel.qtchdcsi tt-compel.vlchdcsi
                                    tt-compel.qtchdcss tt-compel.vlchdcss
                                    tt-compel.qtchdcsg tt-compel.vlchdcsg
                                    tt-compel.qtchddci tt-compel.vlchddci
                                    tt-compel.qtchddcs tt-compel.vlchddcs
                                    tt-compel.qtchddcg tt-compel.vlchddcg
                                    aux_qtchdcci aux_vlchdcci
                                    aux_qtchdccs aux_vlchdccs
                                    aux_qtchdccg aux_vlchdccg
                                    aux_qtchdcti aux_vlchdcti
                                    aux_qtchdcts aux_vlchdcts
                                    aux_qtchdctg aux_vlchdctg
                                    tt-compel.qtchdtti tt-compel.vlchdtti
                                    tt-compel.qtchdtts tt-compel.vlchdtts
                                    tt-compel.qtchdttg tt-compel.vlchdttg
                               WITH FRAME f_total_compel.
                        END.

                  WHEN "DOCTOS" THEN 
                        DO:
                            EMPTY TEMP-TABLE tt-doctos.

                            /* Instancia a BO */
                            RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                            IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                                 DO:
                                  glb_nmdatela = "PRCCTL".
                                  BELL.
                                  MESSAGE 
                                  "Handle invalido para BO b1wgen0012.".
                                  IF   glb_conta_script = 0 THEN
                                       PAUSE 3 NO-MESSAGE.
                                  RETURN.
                                 END.                            
                            
                            RUN consultar_doctos IN h-b1wgen0012(
                                                 INPUT  tel_dtrefere,
                                                 INPUT  INT(tel_cdcooper),
                                                 INPUT  tel_cdagenci,
                                                 INPUT  aux_pacfinal,
                                                 INPUT  aux_cdbcoenv,
                                                 INPUT  tel_flgenvio,
                                                 INPUT  YES,
                                                 OUTPUT TABLE tt-doctos).
                            
                            DELETE PROCEDURE h-b1wgen0012.
                            
                            ASSIGN aux_vldocrcb = 0.

                            CLOSE QUERY q_doctos.
                            
                            OPEN QUERY q_doctos
                                 FOR EACH tt-doctos NO-LOCK
                                          BY tt-doctos.cdagenci
                                          BY tt-doctos.nrdolote
                                          BY tt-doctos.vldocrcb.
                            ENABLE b_doctos WITH FRAME f_doctos_browse.

                            DO aux_contador = 1 TO NUM-RESULTS("q_doctos"):
                               ASSIGN aux_vldocrcb = aux_vldocrcb +
                                      tt-doctos.vldocrcb.
                               QUERY q_doctos:GET-NEXT().
                            END.

                            ASSIGN tel_qtdtotal = NUM-RESULTS("q_doctos")
                                   tel_vlrtotal = aux_vldocrcb.

                            DISPLAY tel_qtdtotal tel_vlrtotal 
                                    WITH FRAME f_totais_doctos.

                            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                            HIDE FRAME f_doctos_browse.
                            HIDE FRAME f_totais_doctos.

                            HIDE MESSAGE NO-PAUSE.
                        END.

                  WHEN "TITULO" THEN 
                        DO:
                            /* Instancia a BO */
                            RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                            IF NOT VALID-HANDLE(h-b1wgen0012)  THEN
                              DO:
                                  glb_nmdatela = "PRCCTL".
                                  BELL.
                                  MESSAGE 
                                  "Handle invalido para BO b1wgen0012.".
                                  IF   glb_conta_script = 0 THEN
                                       PAUSE 3 NO-MESSAGE.
                                  RETURN.
                              END.
                            
                            EMPTY TEMP-TABLE tt-titulos.

                            RUN consultar_titulos IN h-b1wgen0012(
                                                  INPUT  tel_dtrefere,
                                                  INPUT  INT(tel_cdcooper),
                                                  INPUT  tel_cdagenci,
                                                  INPUT  aux_pacfinal,
                                                  INPUT  aux_cdbcoenv,
                                                  INPUT  tel_flgenvio,
                                                  OUTPUT TABLE tt-titulos).

                            DELETE PROCEDURE h-b1wgen0012.
                            
                            FIND LAST tt-titulos NO-LOCK NO-ERROR.
             
                            DISPLAY tt-titulos.qttitrec tt-titulos.vltitrec
                                    tt-titulos.qttitrgt tt-titulos.vltitrgt
                                    tt-titulos.qttiterr tt-titulos.vltiterr
                                    tt-titulos.qttitprg tt-titulos.vltitprg
                                    tt-titulos.qttitcxa tt-titulos.vltitcxa
                                    tt-titulos.qttitulo tt-titulos.vltitulo
                                    WITH FRAME f_total_titulo.
                        END.

                  WHEN "DEVOLU" THEN 
                        DO:
                            /* Instancia a BO */
                            RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                            IF NOT VALID-HANDLE(h-b1wgen0012)  THEN
                              DO:
                                  glb_nmdatela = "PRCCTL".
                                  BELL.
                                  MESSAGE 
                                  "Handle invalido para BO b1wgen0012.".
                                  IF   glb_conta_script = 0 THEN
                                       PAUSE 3 NO-MESSAGE.
                                  RETURN.
                              END.                            
                            
                            RUN consultar_devolu IN h-b1wgen0012(
                                                 INPUT  INT(tel_cdcooper),
                                                 INPUT  tel_dtrefere,
                                                 OUTPUT tel_qtdevolv,
                                                 OUTPUT tel_qtadevol).

                            DELETE PROCEDURE h-b1wgen0012.

                            DISPLAY tel_qtdevolv tel_qtadevol
                            WITH FRAME f_total_devolu.


                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                               ASSIGN aux_confirma = "N".
                               RUN fontes/critic.p.
                               glb_cdcritic = 0.
                               BELL.
                               MESSAGE COLOR NORMAL
                                  "Listar Protocolo Devolucao? (S/N):" 
                                       UPDATE aux_confirma.
                               LEAVE.
                            END.  /*  Fim do DO WHILE TRUE  */

                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                 DO:
                                     glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     glb_cdcritic = 0.
                                     NEXT.
                                 END.
                            
                             IF   aux_confirma = "S" THEN
                                 RUN pi_imprime_protocolo_devolu.

                        END. 

                  OTHERWISE
                      MESSAGE "Nao disponivel para esta opcao!"  
                              "[" tel_nmprgexe "]".

             END CASE.

             IF   glb_cdcritic > 0   THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      PAUSE 2 NO-MESSAGE.
                  END.

        END. /** FIM do WHEN "C" **/
    
    
        WHEN "E" THEN DO:          /*  Envio dos Arquivos  */

             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.
       
             HIDE MESSAGE NO-PAUSE.

             HIDE tel_flgenvio tel_nmprgexe
                  tel_cdagenci tel_tpdevolu
                  tel_datadlog tel_dtrefere tel_pesquisa IN FRAME f_prcctl_2.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_cdcooper WITH FRAME f_prcctl_2.
                LEAVE.
             END.
             
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  NEXT.

             MESSAGE "Aguarde... Carregando arquivo(s)...".

             RUN carrega_tabela_envio.

             HIDE MESSAGE NO-PAUSE.

             CLOSE QUERY q_w-arquivos.
             
             OPEN QUERY q_w-arquivos FOR EACH w-arquivos NO-LOCK
                                              BY w-arquivos.tparquiv
                                              BY w-arquivos.dscooper.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_w-arquivos WITH FRAME f_prcctl_browse.
                LEAVE.
             END.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.
             END.

             IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                 aux_confirma <> "S"                 THEN
                 DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0.
                     CLOSE QUERY q_w-arquivos. 
                     NEXT.
                 END.

             CLOSE QUERY q_w-arquivos.

             MESSAGE "Aguarde... enviando arquivo(s)...".
             
             ASSIGN aux_arqlista = "".

             FOR EACH w-arquivos NO-LOCK,
                 EACH crawarq WHERE crawarq.dscooper = w-arquivos.dscooper AND
                                    crawarq.tparquiv = w-arquivos.tparquiv 
                                    NO-LOCK:            

                 ASSIGN aux_nrbarras = NUM-ENTRIES(crawarq.nmarquiv,"/")
                        aux_nmarquiv = ENTRY(aux_nrbarras,crawarq.nmarquiv,"/")
                        aux_arqdolog = aux_arqdolog + aux_nmarquiv + ",".
                        aux_arqlista = aux_arqlista + crawarq.nmarquiv + ",".
             END.

             /* Remove a virgula do fim da string */
             ASSIGN aux_arqlista = SUBSTR(aux_arqlista,1,
                                   LENGTH(aux_arqlista) - 1).
                    aux_arqdolog = SUBSTR(aux_arqdolog,1,
                                   LENGTH(aux_arqdolog) - 1).               

             IF   aux_arqlista = ""  THEN DO:
                  ASSIGN glb_cdcritic = 239.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  ASSIGN glb_cdcritic = 0.
             END.
             ELSE DO aux_contador = 1 TO NUM-ENTRIES(aux_arqlista,","):

                 UNIX SILENT VALUE('/usr/local/cecred/bin/ftpabbc_envia.pl' +
                                    ' --arquivo="' +
                                   ENTRY(aux_contador,aux_arqlista,",") + '"').

             END.                  
             
             MESSAGE "Processo de envio concluido.".
             
             PAUSE 2 NO-MESSAGE.
             
        END. /** END do WHEN "E" **/

        WHEN "X" THEN DO: /** REATIVAR Registros **/

             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.

             HIDE MESSAGE NO-PAUSE.

             VIEW tel_nmprgexe tel_cdagenci IN FRAME f_prcctl_2.
             HIDE tel_flgenvio tel_datadlog tel_tpdevolu
                  tel_dtrefere tel_pesquisa IN FRAME f_prcctl_2.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_cdcooper WITH FRAME f_prcctl_2.
                UPDATE tel_nmprgexe WITH FRAME f_prcctl_2.

                IF tel_nmprgexe = ? THEN DO:
                   MESSAGE "Voce deve selecionar uma funcao em Processar".
                   NEXT.
                END.

                IF  CAN-DO("CCF,CONTRA-ORDEM,RELACIONAMENTO,CAF" +
                           ",FAC/ROC,CUSTODIA" ,tel_nmprgexe)  THEN DO:
                   MESSAGE "Nao disponivel para esta opcao! [" tel_nmprgexe "]".
                   NEXT.
                END.

                IF tel_nmprgexe:SCREEN-VALUE = "DEVOLU" THEN
                DO:
                    HIDE tel_cdagenci IN FRAME f_prcctl_2.
                    VIEW tel_tpdevolu IN FRAME f_prcctl_2.
                    UPDATE tel_tpdevolu WITH FRAME f_prcctl_2.
                    ASSIGN tel_cdagenci = 0.
                    LEAVE.
                END.
                ELSE
                DO:
                UPDATE tel_cdagenci WITH FRAME f_prcctl_2.
                LEAVE.
                END.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  NEXT.

             MESSAGE "Aguarde ...".

             IF INT(tel_cdcooper) = 0 THEN DO: /* TODAS */
                 FOR EACH crapcop 
                    WHERE crapcop.cdcooper <> 3
                      AND crapcop.flgativo = TRUE NO-LOCK:
                     /* Instancia a BO */
                     RUN sistema/generico/procedures/b1wgen0012.p 
                         PERSISTENT SET h-b1wgen0012.
   
                     IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                          DO:
                             glb_nmdatela = "PRCCTL".
                             BELL.
                             MESSAGE 
                                  "Handle invalido para BO b1wgen0012.".
                             IF   glb_conta_script = 0 THEN
                                  PAUSE 3 NO-MESSAGE.
                             RETURN.
                          END.
                    
                     RUN reativar_arquivos_cecred
                         IN h-b1wgen0012(INPUT  tel_nmprgexe,
                                         INPUT  crapcop.cdcooper,
                                         INPUT  glb_dtmvtolt,
                                         INPUT  tel_cdagenci,
                                         INPUT  TRUE,/* True = DOC */
                                         INPUT  0,   /* Todos DOC  */
                                         INPUT  "PRCCTL",
                                         INPUT  0,
                                         INPUT  0,
                                         INPUT  0,
                                         INPUT  tel_tpdevolu,
                                         OUTPUT glb_cdcritic).
                                         
                     DELETE PROCEDURE h-b1wgen0012.    
                     
                     IF glb_cdcritic > 0 THEN
                        LEAVE.
                        
                 END.

                 IF   glb_cdcritic <> 0   THEN
                      NEXT.

             END.
             ELSE DO:
                 /* Instancia a BO */
                 RUN sistema/generico/procedures/b1wgen0012.p 
                                 PERSISTENT SET h-b1wgen0012.
   
                 IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                      DO:
                         glb_nmdatela = "PRCCTL".
                         BELL.
                         MESSAGE  "Handle invalido para BO b1wgen0012.".
                         IF   glb_conta_script = 0 THEN
                              PAUSE 3 NO-MESSAGE.
                         RETURN.
                      END.                 
                 
                 RUN reativar_arquivos_cecred
                     IN h-b1wgen0012(INPUT  tel_nmprgexe,
                                     INPUT  INT(tel_cdcooper),
                                     INPUT  glb_dtmvtolt,
                                     INPUT  tel_cdagenci,
                                     INPUT  TRUE,/* True = DOC */
                                     INPUT  0,   /* Todos DOC  */
                                     INPUT  "PRCCTL",
                                     INPUT  0,
                                     INPUT  0,
                                     INPUT  0,
                                     INPUT  tel_tpdevolu,
                                     OUTPUT glb_cdcritic).
                                     
                 DELETE PROCEDURE h-b1wgen0012.

                 IF glb_cdcritic > 0 THEN
                    NEXT.
                    
             END.

             MESSAGE "Movimentos atualizados.".
             PAUSE 1 NO-MESSAGE.
                                               
        END. /** END do WHEN "X" **/

        WHEN "I" THEN DO: /* IMPORTAR */

             HIDE FRAME f_total_titulo.
             HIDE FRAME f_total_compel.
             HIDE FRAME f_total_doctos.
             HIDE FRAME f_total_devolu.
             HIDE FRAME f_doctos_browse.
             HIDE FRAME f_prcctl_browse.
             HIDE MESSAGE NO-PAUSE.

             HIDE tel_flgenvio tel_cdagenci
                  tel_datadlog tel_dtrefere
                  tel_tpdevolu tel_pesquisa IN FRAME f_prcctl_2.

             VIEW tel_nmprgexe IN FRAME f_prcctl_2.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_cdcooper WITH FRAME f_prcctl_2.
                UPDATE tel_nmprgexe WITH FRAME f_prcctl_2.

                IF tel_nmprgexe = ? THEN DO:
                   MESSAGE "Voce deve selecionar uma funcao em Processar".
                   NEXT.
                END.

                IF  CAN-DO("CUSTODIA" ,tel_nmprgexe)  THEN DO:
                   MESSAGE "Nao disponivel para esta opcao! [" tel_nmprgexe "]".
                   NEXT.
                END.                

                IF  INT(tel_cdcooper) <> 0
                AND (tel_nmprgexe = "CAF"         OR
                     tel_nmprgexe = "RELACIONAMENTO" OR
                     tel_nmprgexe = "CONTRA-ORDEM"   OR
                     tel_nmprgexe = "CCF"            OR
                     tel_nmprgexe = "ICFJUD")  THEN DO:
                    MESSAGE "Importacao de " + tel_nmprgexe + 
                            " somente para TODAS Cooperativas.".
                    NEXT.
                END.

                LEAVE.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  NEXT.

             MESSAGE "Aguarde importando o(s) arquivo(s) ...".
             
             /* Criar solicitacao para estes tipos de programas */
             IF  CAN-DO("RELACIONAMENTO,CCF,CONTRA-ORDEM,CAF",
                        tel_nmprgexe)  THEN
                 DO  TRANSACTION:
                     /* Limpa solicitacao se existente */
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 200            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.

                     IF  AVAILABLE crapsol  THEN DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.                     
                     
                     CREATE crapsol. 
                     ASSIGN crapsol.nrsolici = 200
                            crapsol.dtrefere = glb_dtmvtolt
                            crapsol.nrseqsol = 1
                            crapsol.cdempres = 11
                            crapsol.dsparame = ""
                            crapsol.insitsol = 1
                            crapsol.nrdevias = 0
                            crapsol.cdcooper = glb_cdcooper.
                     VALIDATE crapsol.
                 END. /* Fim TRANSACTION */                 
                 
             CASE tel_nmprgexe:
    
                 WHEN "RELACIONAMENTO" THEN
                 DO:
                     /* executar o script que busca os arquivos */
                     UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                                       "ftpabbc_recebe_icf_d.pl").
                                       
                     RUN fontes/crps556.p.
                 END.                     
    
                 WHEN "CCF" THEN
                     RUN fontes/crps550.p.
    
                  WHEN "CONTRA-ORDEM" THEN
                      RUN fontes/crps562.p.

                 WHEN "CAF" THEN
                 DO:                        
                     /* executar o script que busca os arquivos */
                     UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                                       "ftpabbc_recebe_caf_d.pl").
                                       
                     RUN fontes/crps564.p. /* CAF501 */

                     RUN fontes/crps565.p. /* CAF502 */
                 END.    

                 WHEN "ICFJUD" THEN DO:
                     
                     aux_dsarquiv = 
                          "ICF614" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                          "ICF616" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                          "ICF674" + STRING(DAY(glb_dtmvtoan),"99") + ".RET," +
                          "ICF676" + STRING(DAY(glb_dtmvtoan),"99") + ".RET".

                     UNIX SILENT VALUE(
                          "/usr/local/cecred/bin/ftpabbc_ICF.pl -recebe " +
                          "-srv transabbc -usr 085 -pass cbba085 " +
                          "-arq '" + STRING(aux_dsarquiv,"x(51)") + "' " +
                          "-dir_local /usr/coop/cecred/integra " +
                          "-dir_remoto /ICF").

                     /* Instancia a BO */
                     RUN sistema/generico/procedures/b1wgen0154.p 
                         PERSISTENT SET h-b1wgen0154.
    
                     IF   NOT VALID-HANDLE(h-b1wgen0154)  THEN
                          DO:
                            glb_nmdatela = "PRCCTL".
                            BELL.
                            MESSAGE
                            "Handle invalido para BO b1wgen0154.".
                            IF   glb_conta_script = 0 THEN
                                 PAUSE 3 NO-MESSAGE.
                            RETURN.
                          END.

                     /* IMPORTAR 616 */
                     RUN importar_icf616 IN h-b1wgen0154(INPUT  glb_dtmvtolt,
                                                         INPUT  glb_dtmvtoan,
                                                         OUTPUT aux_dsmsgerr).

                     IF  aux_dsmsgerr <> "" THEN DO:
                         MESSAGE "ICF616 - " aux_dsmsgerr.
                         PAUSE 2 NO-MESSAGE.
                     END.

                     /* IMPORTAR 614 - GERAR 606 */
                     RUN importar_icf614 IN h-b1wgen0154(INPUT  glb_cdcooper,
                                                         INPUT  glb_dtmvtolt,
                                                         INPUT  glb_dtmvtoan,
                                                         INPUT  glb_cdoperad,
                                                         OUTPUT aux_dsmsgerr).

                     IF  aux_dsmsgerr <> "" THEN DO:
                         MESSAGE "ICF614 - " aux_dsmsgerr.
                         PAUSE 2 NO-MESSAGE.
                     END.
                     
                     /* IMPORTAR 674 */
                     RUN icf_validar_retorno
                         IN h-b1wgen0154(INPUT "ICF674",
                                         INPUT glb_dtmvtolt,
                                         INPUT glb_dtmvtoan,
                                         OUTPUT aux_dsmsgerr).

                     IF  aux_dsmsgerr <> "" THEN DO:
                         MESSAGE "ICF674 - " aux_dsmsgerr.
                         PAUSE 2 NO-MESSAGE.
                     END.

                     /* IMPORTAR 676 */
                     RUN icf_validar_retorno
                         IN h-b1wgen0154(INPUT "ICF676",
                                         INPUT glb_dtmvtolt,
                                         INPUT glb_dtmvtoan,
                                         OUTPUT aux_dsmsgerr).

                     IF  aux_dsmsgerr <> "" THEN DO:
                         MESSAGE "ICF676 - " aux_dsmsgerr.
                         PAUSE 2 NO-MESSAGE.
                     END.

                     DELETE PROCEDURE h-b1wgen0154.

                 END.


                 WHEN "FAC/ROC" THEN DO:

                     RUN gera_log_execucao(INPUT tel_nmprgexe,
                                           INPUT "Inicio execucao",
                                           INPUT glb_cdcooper,
                                           INPUT "TODAS").                        

                     /* criar solicitacao para FAC/ROC */
                     DO  TRANSACTION:
                         /* Limpa solicitacao se existente */
                         FIND FIRST crapsol WHERE 
                                    crapsol.cdcooper = glb_cdcooper AND 
                                    crapsol.nrsolici = 1            AND
                                    crapsol.dtrefere = glb_dtmvtolt   
                                    NO-LOCK NO-ERROR.

                         IF  AVAILABLE crapsol  THEN DO:
                             FIND CURRENT crapsol EXCLUSIVE-LOCK.
                             DELETE crapsol.
                         END.                     
                         
                         CREATE crapsol. 
                         ASSIGN crapsol.nrsolici = 1
                                crapsol.dtrefere = glb_dtmvtolt
                                crapsol.nrseqsol = 1
                                crapsol.cdempres = 11
                                crapsol.dsparame = ""
                                crapsol.insitsol = 1
                                crapsol.nrdevias = 0
                                crapsol.cdcooper = glb_cdcooper.
                         VALIDATE crapsol.
                     END. /* Fim TRANSACTION */   


                     /* executar o script que busca os arquivos */
                       
                     UNIX SILENT VALUE("/usr/local/cecred/bin/" +
                                       "ftpabbc_recebe_facroc_d.pl").
                                                          
                     /* Executa FAC */
                     RUN fontes/crps543.p.
                     /* Executa ROC */
                     RUN fontes/crps544.p.


                     /* Limpa solicitacao se existente */
                     DO  TRANSACTION:
                         FIND FIRST crapsol WHERE 
                                    crapsol.cdcooper = glb_cdcooper  AND 
                                    crapsol.nrsolici = 1             AND
                                    crapsol.dtrefere = glb_dtmvtolt   
                                    NO-LOCK NO-ERROR.

                         IF  AVAILABLE crapsol  THEN DO:
                             FIND CURRENT crapsol EXCLUSIVE-LOCK.
                             DELETE crapsol.
                         END.             
                     END. /* Fim do TRANSACTION */

                     RUN gera_log_execucao(INPUT tel_nmprgexe,
                                           INPUT "Fim execucao",
                                           INPUT glb_cdcooper,
                                           INPUT "TODAS").                        

                 END.

                 OTHERWISE DO:
                     MESSAGE "Nao disponivel para esta opcao!"
                             "[" tel_nmprgexe "]".
                     NEXT.
                 END.
    
             END CASE.

             /* Criar solicitacao para estes tipos de programas */
             IF  CAN-DO("RELACIONAMENTO,CCF,CONTRA-ORDEM,CAF",
                        tel_nmprgexe)  THEN
                 DO  TRANSACTION:
                     /* Limpa solicitacao se existente */
                     FIND FIRST crapsol WHERE 
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 200            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
                     IF  AVAILABLE crapsol  THEN
                         DO:
                             FIND CURRENT crapsol EXCLUSIVE-LOCK.
                             DELETE crapsol.
                         END.             
                 END. /* Fim do TRANSACTION */
                 
             MESSAGE "Processo de Importacao para " tel_nmprgexe " concluido!".
             PAUSE 2 NO-MESSAGE.

        END. /** END do WHEN "I" **/

        WHEN "P" THEN DO:

            HIDE FRAME f_total_titulo.
            HIDE FRAME f_total_compel.
            HIDE FRAME f_total_doctos.
            HIDE FRAME f_total_devolu.
            HIDE FRAME f_doctos_browse.
            HIDE FRAME f_prcctl_browse.
            HIDE MESSAGE NO-PAUSE.

            HIDE tel_flgenvio tel_cdagenci                      
                 tel_nmprgexe tel_tpdevolu
                 tel_datadlog tel_pesquisa IN FRAME f_prcctl_2. 
                                                                  
            VIEW tel_cdcooper tel_dtrefere IN FRAM f_prcctl_2.               

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_cdcooper WITH FRAME f_prcctl_2.

               IF INT(tel_cdcooper) = 0 THEN DO:
                   MESSAGE "Deve ser selecionada uma cooperativa".
                   NEXT.
                END.
               
               UPDATE tel_dtrefere WITH FRAME f_prcctl_2.

               LEAVE.
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO:  /* F4 OU FIM */
                HIDE tel_dtrefere IN FRAM f_prcctl_2.
                NEXT.
            END.

            HIDE MESSAGE NO-PAUSE.

            /* Monta o nome do protocolo/busca do ftp o arquivo */
            /* Nome do arquivo PAAAAMDD.PRN                  */
            /* Onde:                                         */
            /* AAAA - Número da agência                      */
            /* M - Mês                                       */
            /* DD - Dia                                      */
            
            IF   MONTH(tel_dtrefere) > 9 THEN
                 CASE MONTH(tel_dtrefere):
                      WHEN 10 THEN aux_mes = "O".
                      WHEN 11 THEN aux_mes = "N".
                      WHEN 12 THEN aux_mes = "D".
                 END CASE.
            ELSE
                 aux_mes = STRING(MONTH(tel_dtrefere),"9").

            FIND FIRST crapcop NO-LOCK
                 WHERE crapcop.cdcooper = INT(tel_cdcooper) NO-ERROR.

            IF   crapcop.cdcooper = 3 THEN
                 ASSIGN aux_nmbaixar = "PRTICF" + STRING(DAY(tel_dtrefere),"99") +
                                       ".PRN"
                        aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop +
                                       "/log/protocolos-abbc/" + aux_nmbaixar.
            ELSE
                  ASSIGN aux_nmbaixar = "P" + STRING(crapcop.cdagectl,"9999")     +
                                        aux_mes +  STRING(DAY(tel_dtrefere),"99") +
                                        ".PRN"
                         aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop +
                                        "/log/protocolos-abbc/" + aux_nmbaixar.
                        
            /* Busca o Protocolo do ftp da ABBC */
            UNIX SILENT VALUE('/usr/local/cecred/bin/' + 
                              'ftpabbc_recebe_protocol.pl' +
                              ' --arquivo="' + aux_nmbaixar + '"').
                
            IF  SEARCH(aux_nmarqlog) = ?   THEN  
                DO:
                    MESSAGE "Protocolo do dia " +
                            STRING(tel_dtrefere,"99/99/9999") +
                            " nao encontrado.".
                    PAUSE 1 NO-MESSAGE.
                    RETURN.
                END.

            RUN proc_visualiza_protocolo.

        END. /** END do WHEN "P" **/

        WHEN "L" THEN DO:

            RUN pi_opcao_l.

        END. /** END do WHEN "L" **/

        WHEN "V" THEN DO:

            RUN pi_opcao_v.

        END. /** END do WHEN "L" **/

   END CASE.

END. /* FIM - DO WHILE TRUE */

/*............................................................................*/

PROCEDURE pi_opcao_l:

    HIDE FRAME f_total_titulo.
    HIDE FRAME f_total_compel.
    HIDE FRAME f_total_doctos.
    HIDE FRAME f_total_devolu.
    HIDE FRAME f_doctos_browse.
    HIDE FRAME f_prcctl_browse.
    HIDE MESSAGE NO-PAUSE.

    ASSIGN tel_pesquisa = "".

    
    HIDE tel_flgenvio IN FRAME f_prcctl_2. 
    HIDE tel_cdagenci 
         tel_nmprgexe
         tel_cdcooper
         tel_dtrefere IN FRAME f_prcctl_2. 
                                                          
    VIEW tel_datadlog tel_pesquisa IN FRAM f_prcctl_2.               

    ASSIGN tel_datadlog = glb_dtmvtolt.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE tel_datadlog WITH FRAME f_prcctl_2.
       UPDATE tel_pesquisa WITH FRAME f_prcctl_2.
       LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */
        HIDE tel_datadlog tel_pesquisa IN FRAM f_prcctl_2.
        NEXT.
    END.

    ASSIGN aux_nmarqimp = "log/prcctl_" +
                          STRING(YEAR(tel_datadlog),"9999") +
                          STRING(MONTH(tel_datadlog),"99") +
                          STRING(DAY(tel_datadlog),"99") + ".log".

    IF   SEARCH(aux_nmarqimp) = ?   THEN DO:
         MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA DATA!".
         PAUSE 1 NO-MESSAGE.
         RETURN.
    END.


    ASSIGN aux_nomedarq[1] = "log/arquivo_tel1".
            
    IF   TRIM(tel_pesquisa) = ""   THEN 
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nomedarq[1]).
    ELSE 
         UNIX SILENT VALUE ("grep -i '" + tel_pesquisa + "' " + aux_nmarqimp + 
                            " > "   + aux_nomedarq[1] + " 2> /dev/null").

    aux_nmarqimp = aux_nomedarq[1].
            
    /* Verifica se o arquivo esta vazio e critica */
    INPUT STREAM str_2 THROUGH VALUE( "wc -m " +
                                       aux_nmarqimp + " 2> /dev/null") 
                                     NO-ECHO.

    SET STREAM str_2 aux_tamarqui FORMAT "x(30)".

    IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
        DO:
             BELL. 
             MESSAGE "Nenhuma ocorrencia encontrada.".
             INPUT STREAM str_2 CLOSE.
             NEXT.
        END.

    INPUT STREAM str_2 CLOSE.



    ASSIGN tel_cddopcao = "T".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.

   IF   tel_cddopcao = "T"   THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
   ELSE
   IF   tel_cddopcao = "I"   THEN
        DO:
            /* somente para o includes/impressao.i */
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }
        END.
   ELSE
        DO:
           glb_cdcritic = 14.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           NEXT.
        END.

   /* apaga arquivos temporarios */
   IF   aux_nomedarq[1] <> ""   THEN
       UNIX SILENT VALUE ("rm " + aux_nomedarq[1] + " 2> /dev/null").

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_opcao_v:

    DEF    VAR aux_qtdcoops   AS INT                     NO-UNDO.
    DEF    VAR aux_contarqs   AS INT                     NO-UNDO.
    
    ASSIGN aux_qtdcoops = 0
           aux_nmarqlog = "log/prcctl_" +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".


    EMPTY TEMP-TABLE w-arq-dir.

    FOR EACH crabcop NO-LOCK:
    
       CREATE w-arq-dir.
       ASSIGN w-arq-dir.dscooper = CAPS(crabcop.dsdircop).

       aux_contarqs = 0.

       DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

           aux_contarqs = aux_contarqs + 1.
           RUN pi_opcao_v_busca_arqs (INPUT aux_contarqs).

           
           INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + 
                                             " 2> /dev/null") NO-ECHO.
                                                                                   
           /**** Verifica se ha arquivos a importar *****/
           DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
         
             SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
                                      
             ASSIGN aux_contador = aux_contador + 1.
             
             IF  aux_contador > 0 THEN DO:
    
                 ASSIGN w-arq-dir.dsmensag = "Ha arquivos pendentes de envio!"
                        aux_qtdcoops = aux_qtdcoops + 1.
                        
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - Coop:" + STRING(crabcop.cdcooper,"99") +
                                   " - Processar:VERIFICA ARQUIVOS - " +
                                   CAPS(crabcop.dsdircop) + "' --> '"  +
                                   "Existe arquivo pendente para Envio  >> "
                                    + aux_nmarqlog).
    
                 LEAVE.
             END.
             ELSE ASSIGN w-arq-dir.dsmensag = "".

             IF  aux_contarqs = 6 THEN
                 LEAVE.
                                                         
          END.  /*  Fim do DO WHILE TRUE  */
        
         INPUT STREAM str_1 CLOSE.
         
         IF  aux_contador > 0 THEN DO:
             ASSIGN aux_contador = 0.
             LEAVE.
         END.

         IF  aux_contarqs = 6 THEN
                 LEAVE.

       END. /* END do WHILE TRUE contaarqs */

    END. /* END do FOR EACH crabcop */
    
    OPEN QUERY q_w-arq-dir
      FOR EACH w-arq-dir NO-LOCK.

    MESSAGE "Existem" aux_qtdcoops
            "cooperativas com arquivos pendentes de envio".
    
    ENABLE b_w-arq-dir WITH FRAME f_valida_dir.

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

    HIDE FRAME f_valida_dir. 
    
    HIDE MESSAGE NO-PAUSE.


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_opcao_v_busca_arqs:
    DEF INPUT PARAM par_contarqs AS INT                               NO-UNDO.


    CASE par_contarqs:

        WHEN 1 THEN aux_nmarquiv = "/micros/"   + crabcop.dsdircop +
                                   "/abbc/1" + STRING(crabcop.cdagectl,"9999")
                                   + "*.0*".
        WHEN 2 THEN aux_nmarquiv = "/micros/"   + crabcop.dsdircop +
                                   "/abbc/2" + STRING(crabcop.cdagectl,"9999")
                                   + "*.*".
        WHEN 3 THEN aux_nmarquiv = "/micros/"   + crabcop.dsdircop +
                                   "/abbc/8" + STRING(crabcop.cdagectl,"9999")
                                   + "*.*".
        WHEN 4 THEN aux_nmarquiv = "/micros/"   + crabcop.dsdircop +
                                   "/abbc/3" + STRING(crabcop.cdagectl,"9999")
                                   + "*.*".
        WHEN 5 THEN aux_nmarquiv = "/micros/"   + crabcop.dsdircop +
                                   "/abbc/1" + STRING(crabcop.cdagectl,"9999")
                                   + "*.DV*".
        WHEN 6 THEN aux_nmarquiv = "/micros/cecred/abbc/ICF" +
                                   STRING(crabcop.cdbcoctl,"999") + "*.REM".
    END CASE.

END PROCEDURE.

/*............................................................................*/

PROCEDURE consultar_compel:

    EMPTY TEMP-TABLE tt-compel.
    CREATE tt-compel.
    
    FOR EACH crapchd WHERE crapchd.cdcooper  = INT(tel_cdcooper)          AND
                           crapchd.dtmvtolt  = tel_dtrefere               AND
                           crapchd.cdagenci >= tel_cdagenci               AND
                           crapchd.cdagenci <= aux_pacfinal               AND
                           CAN-DO(aux_cdbcoenv,STRING(crapchd.cdbcoenv))  AND
                           crapchd.flgenvio  = tel_flgenvio
                           NO-LOCK,
        EACH crawage WHERE crawage.cdcooper = crapchd.cdcooper
                       AND crawage.cdagenci = crapchd.cdagenci NO-LOCK
                           BREAK BY crawage.cdagenci:

        IF   crapchd.tpdmovto <> 1   AND
             crapchd.tpdmovto <> 2   THEN
             NEXT.
            
       IF   NOT CAN-DO("0,2",STRING(crapchd.insitchq))  THEN  
            NEXT.
       
       IF   CAN-DO("11,500",STRING(crapchd.cdbccxlt))   THEN      /*  CAIXA  */
            DO:
                ASSIGN tt-compel.qtchdcxg = tt-compel.qtchdcxg + 1
                       tt-compel.vlchdcxg = tt-compel.vlchdcxg +
                                            crapchd.vlcheque.

                IF   crapchd.tpdmovto = 1   THEN 
                     DO:
                         ASSIGN tt-compel.qtchdcxs = tt-compel.qtchdcxs + 1
                                tt-compel.vlchdcxs = tt-compel.vlchdcxs +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtts = tt-compel.qtchdtts + 1
                                tt-compel.vlchdtts = tt-compel.vlchdtts +
                                                     crapchd.vlcheque.
                     END.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     DO:
                         ASSIGN tt-compel.qtchdcxi = tt-compel.qtchdcxi + 1
                                tt-compel.vlchdcxi = tt-compel.vlchdcxi +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtti = tt-compel.qtchdtti + 1
                                tt-compel.vlchdtti = tt-compel.vlchdtti +
                                                     crapchd.vlcheque.
                     END.
            END.
       ELSE
       IF   CAN-DO("600",STRING(crapchd.cdbccxlt))   THEN       /*  CUSTODIA  */
            DO:
                ASSIGN tt-compel.qtchdcsg = tt-compel.qtchdcsg + 1
                       tt-compel.vlchdcsg = tt-compel.vlchdcsg +
                                            crapchd.vlcheque.

                IF   crapchd.tpdmovto = 1   THEN   
                     DO:
                         ASSIGN tt-compel.qtchdcss = tt-compel.qtchdcss + 1
                                tt-compel.vlchdcss = tt-compel.vlchdcss +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtts = tt-compel.qtchdtts + 1
                                tt-compel.vlchdtts = tt-compel.vlchdtts +
                                                     crapchd.vlcheque.
                     END.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     DO:
                         ASSIGN tt-compel.qtchdcsi = tt-compel.qtchdcsi + 1
                                tt-compel.vlchdcsi = tt-compel.vlchdcsi +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtti = tt-compel.qtchdtti + 1
                                tt-compel.vlchdtti = tt-compel.vlchdtti +
                                                     crapchd.vlcheque.
                     END.
            END.
       ELSE
       IF   CAN-DO("700",STRING(crapchd.cdbccxlt))   THEN      /*  DESC. CHQ  */
            DO:
                ASSIGN tt-compel.qtchddcg = tt-compel.qtchddcg + 1
                       tt-compel.vlchddcg = tt-compel.vlchddcg +
                                            crapchd.vlcheque.

                IF   crapchd.tpdmovto = 1   THEN   
                     DO:
                         ASSIGN tt-compel.qtchddcs = tt-compel.qtchddcs + 1
                                tt-compel.vlchddcs = tt-compel.vlchddcs +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtts = tt-compel.qtchdtts + 1
                                tt-compel.vlchdtts = tt-compel.vlchdtts +
                                                     crapchd.vlcheque.
                     END.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     DO:
                         ASSIGN tt-compel.qtchddci = tt-compel.qtchddci + 1
                                tt-compel.vlchddci = tt-compel.vlchddci +
                                                     crapchd.vlcheque
                                tt-compel.qtchdtti = tt-compel.qtchdtti + 1
                                tt-compel.vlchdtti = tt-compel.vlchdtti +
                                                     crapchd.vlcheque.
                     END.
            END.

       IF   CAN-DO("11,500,600,700",STRING(crapchd.cdbccxlt)) THEN
            DO:
                IF   crapchd.tpdmovto = 1 THEN  /* Superior */
                     DO:
                         IF   crapchd.inchqcop = 0 THEN
                              ASSIGN aux_qtchdcts = aux_qtchdcts + 1
                                     aux_vlchdcts = aux_vlchdcts + 
                                                    crapchd.vlcheque.
                         ELSE
                         IF   crapchd.inchqcop = 1 THEN
                              ASSIGN aux_qtchdccs = aux_qtchdccs + 1
                                     aux_vlchdccs = aux_vlchdccs +
                                                    crapchd.vlcheque.
                     END.
                ELSE
                     IF   crapchd.tpdmovto = 2 THEN  /* Inferior */
                          DO:
                              IF   crapchd.inchqcop = 0 THEN
                                   ASSIGN aux_qtchdcti = aux_qtchdcti + 1
                                          aux_vlchdcti = aux_vlchdcti + 
                                                         crapchd.vlcheque.
                              ELSE
                              IF   crapchd.inchqcop = 1 THEN
                                   ASSIGN aux_qtchdcci = aux_qtchdcci + 1
                                          aux_vlchdcci = aux_vlchdcci +
                                                         crapchd.vlcheque.
                          END.
                          
                /* Cheque de Terceiros */
                IF   crapchd.inchqcop = 0 THEN
                     ASSIGN aux_qtchdctg = aux_qtchdctg + 1                 
                            aux_vlchdctg = aux_vlchdctg + crapchd.vlcheque. 
                ELSE /* Cheque da Cooperativa */                           
                     ASSIGN aux_qtchdccg = aux_qtchdccg + 1
                            aux_vlchdccg = aux_vlchdccg + crapchd.vlcheque.
            END.
       
       ASSIGN tt-compel.qtchdttg = tt-compel.qtchdttg + 1
              tt-compel.vlchdttg = tt-compel.vlchdttg + crapchd.vlcheque.

    END.  /*  Fim do FOR EACH  --  Leitura do craptit  */

    IF   tt-compel.qtchdttg <>
        (tt-compel.qtchdcxg + tt-compel.qtchdcsg + tt-compel.qtchddcg)   OR
         tt-compel.vlchdttg <>
        (tt-compel.vlchdcxg + tt-compel.vlchdcsg + tt-compel.vlchddcg)   THEN
        DO:
            MESSAGE "ERRO - Informe o CPD ==> Qtd: "
                    STRING(tt-compel.qtchdcxg + tt-compel.qtchdcsg +
                           tt-compel.qtchddcg,"zzz,zz9-")
                    " Valor: " 
                    STRING(tt-compel.vlchdcxg + tt-compel.vlchdcsg +
                           tt-compel.vlchddcg,"zzz,zzz,zz9.99-") .
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE carrega_tabela_envio.

    EMPTY TEMP-TABLE crawarq.
    EMPTY TEMP-TABLE w-arquivos.

    FOR EACH crapcop 
        WHERE crapcop.cdcooper <> 3 
          AND crapcop.flgativo = TRUE NO-LOCK:

        /*** Procura arquivos CHEQUES ***/
        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                              "/abbc/1" + STRING(crapcop.cdagectl,"9999") +
                              "*.*"
               aux_tparquiv = "COMPEL".

        RUN verifica_arquivos.
        
        /*** Procura arquivos TITULOS ***/
        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                              "/abbc/2" + STRING(crapcop.cdagectl,"9999") +
                              "*.*"
               aux_tparquiv = "TITULOS". 
            
        RUN verifica_arquivos.

        /*** Procura arquivos TITULOS ***/
        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                              "/abbc/8" + STRING(crapcop.cdagectl,"9999") +
                              "*.*"
               aux_tparquiv = "TITULOS". 
            
        RUN verifica_arquivos.
        
        IF  crapcop.cdcooper = 1 THEN
            DO:
                /*VIACON*/
                FOR EACH crabcop WHERE crabcop.cdcooper = 1 OR
                                       crabcop.cdcooper = 4 NO-LOCK:                
                    /*** Procura arquivos DOCs ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                          "/abbc/3" + STRING(crabcop.cdagectl,"9999") +
                                          "*.*"
                           aux_tparquiv = "DOCTOS".
                       
                    RUN verifica_arquivos.
                       
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                          "/abbc/1" + STRING(crabcop.cdagectl,"9999") +
                                          "*.DV*"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.                    
    
                    /*** Procura arquivos DEVOLU ***/
                    ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                          "/abbc/5" + STRING(crabcop.cdagectl,"9999") +
                                          "*.DVS"
                           aux_tparquiv = "DEVOLU".
                       
                    RUN verifica_arquivos.

                END.

            END.
        ELSE IF  crapcop.cdcooper = 13 THEN
                DO:
                    /*SCRCRED CREDIMILSUL*/
                    FOR EACH crabcop WHERE crabcop.cdcooper = 13 OR
                                           crabcop.cdcooper = 15 NO-LOCK:                
                        /*** Procura arquivos DOCs ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/3" + STRING(crabcop.cdagectl,"9999") +
                                              "*.*"
                               aux_tparquiv = "DOCTOS".
                           
                        RUN verifica_arquivos.
                           
                        /*** Procura arquivos DEVOLU ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/1" + STRING(crabcop.cdagectl,"9999") +
                                              "*.DV*"
                               aux_tparquiv = "DEVOLU".
                           
                        RUN verifica_arquivos.                    
        
                        /*** Procura arquivos DEVOLU ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/5" + STRING(crabcop.cdagectl,"9999") +
                                              "*.DVS"
                               aux_tparquiv = "DEVOLU".
                           
                        RUN verifica_arquivos.
    
                    END.
    
                END.
		ELSE IF  crapcop.cdcooper = 9 THEN
                DO:
                    /*TRANSPOCRED TRANSULCRED*/
                    FOR EACH crabcop WHERE crabcop.cdcooper = 9 OR
                                           crabcop.cdcooper = 17 NO-LOCK:                
                        /*** Procura arquivos DOCs ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/3" + STRING(crabcop.cdagectl,"9999") +
                                              "*.*"
                               aux_tparquiv = "DOCTOS".
                           
                        RUN verifica_arquivos.
                           
                        /*** Procura arquivos DEVOLU ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/1" + STRING(crabcop.cdagectl,"9999") +
                                              "*.DV*"
                               aux_tparquiv = "DEVOLU".
                           
                        RUN verifica_arquivos.                    
        
                        /*** Procura arquivos DEVOLU ***/
                        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                              "/abbc/5" + STRING(crabcop.cdagectl,"9999") +
                                              "*.DVS"
                               aux_tparquiv = "DEVOLU".
                           
                        RUN verifica_arquivos.
    
                    END.
    
                END.
        ELSE
            DO:

                /*** Procura arquivos DOCs ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                      "/abbc/3" + STRING(crapcop.cdagectl,"9999") +
                                      "*.*"
                       aux_tparquiv = "DOCTOS".
                   
                RUN verifica_arquivos.
                   
                /*** Procura arquivos DEVOLU ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                      "/abbc/1" + STRING(crapcop.cdagectl,"9999") +
                                      "*.DV*"
                       aux_tparquiv = "DEVOLU".
                   
                RUN verifica_arquivos.                    

                /*** Procura arquivos DEVOLU ***/
                ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                                      "/abbc/5" + STRING(crapcop.cdagectl,"9999") +
                                      "*.DVS"
                       aux_tparquiv = "DEVOLU".
                   
                RUN verifica_arquivos.

            END.

        /*** Procura arquivos CUSTODIA ***/
        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/abbc/C" + 
                              STRING(crapcop.cdagectl,"9999") +
                              "*.001"
               aux_tparquiv = "CUSTODIA ESTOQ".
           
        RUN verifica_arquivos.
        
        /*** Procura arquivos CUSTODIA ***/
        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/abbc/C" + 
                              STRING(crapcop.cdagectl,"9999") +
                              "*.002"
               aux_tparquiv = "CUSTODIA COMPE".
           
        RUN verifica_arquivos.

        /*** Procura aruivos TIC604***/
        ASSIGN aux_nmarquiv = "/micros/"   + crapcop.dsdircop + 
                              "/abbc/1" + STRING(crapcop.cdagectl,"9999") + 
                              "*.C*"
               aux_tparquiv = "TIC". 
        
        RUN verifica_arquivos.

    END.


    /*** TIPO RELACIONAMENTO ***/
    IF   INT(tel_cdcooper) = 0 THEN 
         tel_cdcooper = "3".
        
    FIND crapcop WHERE crapcop.cdcooper = INT(tel_cdcooper) NO-LOCK NO-ERROR.
        
    /*** Procura arquivos ICF(RELACIONAMENTO) ***/
    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/ICF" +
                          STRING(crapcop.cdbcoctl,"999") + "01.REM"
           aux_tparquiv = "RELACIONAMENTO"
           tel_cdcooper = "0".
           
    RUN verifica_arquivos.


    /*** TIPO ICF604 ***/
    ASSIGN tel_cdcooper = "3".

    FIND crapcop WHERE crapcop.cdcooper = INT(tel_cdcooper) NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/i2" +
                          STRING(crapcop.cdbcoctl,"999") + "*.REM"
           aux_tparquiv = "ICFJUD-604"
           tel_cdcooper = "0".
           
    RUN verifica_arquivos.



    /*** TIPO ICF606 ***/
    ASSIGN tel_cdcooper = "3".

    FIND crapcop WHERE crapcop.cdcooper = INT(tel_cdcooper) NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/micros/cecred/abbc/i3" +
                           STRING(crapcop.cdbcoctl,"999") + "*.REM"
           aux_tparquiv = "ICFJUD-606"
           tel_cdcooper = "0".
           
    RUN verifica_arquivos.
  
        
    ASSIGN aux_tparquiv = "".

    FOR EACH crawarq NO-LOCK BREAK BY crawarq.tparquiv
                                      BY crawarq.dscooper:
    
        IF   FIRST-OF(crawarq.tparquiv)  OR
             FIRST-OF(crawarq.dscooper)  THEN
             DO:
                 IF   crawarq.tparquiv = "TITULOS"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO TITULOS COMPENSAVEIS".
                 ELSE
                 IF   crawarq.tparquiv = "COMPEL"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO COMPENSACAO ELETRONICA".
                 ELSE
                 IF   crawarq.tparquiv = "DOCTOS"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DOCTOS".
                 ELSE
                 IF   crawarq.tparquiv = "DEVOLU"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DE DEVOLUCAO DE CHEQUES".
                 ELSE
                 IF   crawarq.tparquiv = "RELACIONAMENTO"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ARQUIVO DE RELACIONAMENTO ICF".
                 ELSE
                 IF   crawarq.tparquiv = "CUSTODIA ESTOQ"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ESTOQUE TOTAL DE CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "CUSTODIA COMPE"  THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "CHEQUES A COMPENSAR EM CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "TIC" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "TIC - TROCA INFORM. DE CUSTODIA".
                 ELSE
                 IF   crawarq.tparquiv = "ICFJUD-604" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ICFJUD - REQUISICAO INFORMACOES".
                 ELSE
                 IF   crawarq.tparquiv = "ICFJUD-606" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "ICFJUD - RESPOSTA INFORMACOES".
                 ELSE
                 IF   crawarq.tparquiv = "DEVDOC" THEN
                      ASSIGN aux_tparquiv = crawarq.tparquiv
                             aux_dsarquiv = "DEVOLUCAO DE DOC".
                 
                 CREATE w-arquivos.
                 ASSIGN w-arquivos.tparquiv = aux_tparquiv
                        w-arquivos.dsarquiv = aux_dsarquiv
                        w-arquivos.dscooper = crawarq.dscooper.
             END.
    END.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE verifica_arquivos:

    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null")
          NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".
       
       /*** Verifica se o arquivo esta vazio e o remove ***/
       INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                        " 2> /dev/null") NO-ECHO.

       SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
             
       IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0  THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

       INPUT STREAM str_2 CLOSE.
                
       DO TRANSACTION:         

          /*Verificar a extensao qdo for DOCTOS - se for numerica eh doctos mesmo
            se for DVS entao eh DEVOLUCAO DE DOC*/
          IF  aux_tparquiv = "DOCTOS"                                  AND
              SUBSTR(aux_nmarquiv,LENGTH(aux_nmarquiv) - 2,3) = "DVS"  THEN
              DO:
                  ASSIGN aux_tparquiv = "DEVDOC".
              END.                                       

          CREATE crawarq.
          ASSIGN crawarq.dscooper = IF   aux_tparquiv = "RELACIONAMENTO" THEN
                                         "AILOS"
                                    ELSE crapcop.nmrescop
                 crawarq.tparquiv = aux_tparquiv
                 crawarq.nmarquiv = aux_nmarquiv.
       END.
    END.  /*  Fim do DO WHILE TRUE  */
    
    INPUT STREAM str_1 CLOSE.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE proc_visualiza_protocolo:

    DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
    DEF VAR tel_dsimprim AS CHAR     FORMAT "x(8)" INIT "Imprimir"    NO-UNDO.
    DEF VAR tel_dscancel AS CHAR     FORMAT "x(8)" INIT "Cancelar"    NO-UNDO.
    DEF VAR par_flgrodar AS LOGI                                      NO-UNDO.
    DEF VAR par_flgfirst AS LOGI                                      NO-UNDO.
    DEF VAR par_flgcance AS LOGI                                      NO-UNDO.
    DEF VAR aux_flgescra AS LOGICAL                                   NO-UNDO.
    DEF VAR aux_contador AS INT      FORMAT "z,zz9"                   NO-UNDO.

    DEF BUTTON btn-ok     LABEL "Sair".
    DEF VAR edi_protocol  AS CHAR VIEW-AS EDITOR SIZE 225 BY 15 PFCOLOR 0.

    DEF FRAME fra_protocol 
              edi_protocol  HELP "Pressione <F4> ou <END> para finalizar" 
              WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX
                   NO-LABELS OVERLAY.

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ENABLE edi_protocol  WITH FRAME fra_protocol.
       DISPLAY edi_protocol WITH FRAME fra_protocol.
       ASSIGN edi_protocol:READ-ONLY IN FRAME fra_protocol = YES.

       IF   edi_protocol:INSERT-FILE(aux_nmarqlog)   THEN
            DO:
                ASSIGN edi_protocol:CURSOR-LINE IN FRAME fra_protocol = 1.
                WAIT-FOR GO OF edi_protocol IN FRAME fra_protocol. 
            END.
  
    END.  /*  Fim do DO WHILE TRUE  */

    HIDE MESSAGE NO-PAUSE.

    ASSIGN aux_confirma = "N".
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "Imprimir Protocolo da data" STRING(tel_dtrefere,"99/99/9999") 
               "?" "(S)im/(N)ao:"  UPDATE aux_confirma.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */   
    
    IF   aux_confirma = "S"  THEN
         DO:
             /*** nao necessario ao programa somente para nao dar erro 
                  de compilacao na rotina de impressao ****/
             FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                  NO-LOCK NO-ERROR.

             ASSIGN par_flgrodar = TRUE
                    aux_nmarqimp = aux_nmarqlog
                    glb_nmformul = "132col".

             HIDE FRAME fra_protocol NO-PAUSE.
             { includes/impressao.i }

             HIDE MESSAGE NO-PAUSE.
         END.

    ASSIGN edi_protocol:SCREEN-VALUE = "".
    CLEAR FRAME fra_protocol ALL.
    HIDE FRAME fra_protocol NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE gera_relatorios:

  DEF INPUT PARAM par_cdcooper AS INT            NO-UNDO.
  DEF INPUT PARAM par_dtrefere AS DATE           NO-UNDO.

  DEF         VAR aux_lgparam1 AS LOG            NO-UNDO.
  DEF         VAR aux_lgparam2 AS LOG            NO-UNDO.

  IF glb_cddopcao = "B" THEN
      ASSIGN aux_lgparam1 = TRUE
             aux_lgparam2 = TRUE.
     /*param2: ao chegar nesse ponto o flgenvio da tabela
               ja foi alterado para TRUE, porem no programa
               original, ele somente alterava para TRUE apos
               a emissao do relatorio */
  ELSE
      ASSIGN aux_lgparam1 = FALSE
             aux_lgparam2 = tel_flgenvio.

  IF tel_nmprgexe = "DOCTOS" THEN
      DO ON STOP UNDO, LEAVE:
        RUN fontes/prcctl_rd.p (INPUT par_cdcooper,
                                INPUT par_dtrefere, 
                                INPUT tel_cdagenci,
                                INPUT aux_lgparam2,   
                                INPUT "D",
                                INPUT " ",
                                INPUT TABLE crawage,
                                INPUT TRUE). /* Efetua impressao */ 
        PAUSE 1 NO-MESSAGE.
      END.
  ELSE
  IF tel_nmprgexe = "COMPEL" THEN 
      DO ON STOP UNDO, LEAVE:
         RUN fontes/prcctl_rc.p(INPUT par_cdcooper,
                                INPUT par_dtrefere,
                                INPUT tel_cdagenci,
                                INPUT 0,
                                INPUT 0,
                                INPUT aux_lgparam1,
                                INPUT TABLE crawage,
                                INPUT aux_lgparam2,
                                INPUT aux_lgparam2,
                                INPUT TRUE). /* Efetua impressao */ 
         PAUSE 1 NO-MESSAGE.
      END.
  ELSE /* Titulo */
      DO ON STOP UNDO, LEAVE:
        RUN fontes/prcctl_rt.p (INPUT par_cdcooper,
                                INPUT par_dtrefere,
                                INPUT tel_cdagenci,
                                INPUT 0,
                                INPUT 0,
                                INPUT aux_lgparam1,
                                INPUT TABLE crawage,
                                INPUT aux_lgparam2,
                                INPUT aux_lgparam2,
                                INPUT TRUE). /* Efetua impressao */ 
        PAUSE 1 NO-MESSAGE.
      END.

END PROCEDURE.



PROCEDURE proc_verifica_pac_internet:
    
    /* Verifica se os titulos e faturas pagos tiveram os seus devidos debitos
       efetuados nas contas */
      
    DEF INPUT PARAM par_cdcooper AS INTEGER                          NO-UNDO.

    DEF         VAR aux_qtlanmto AS INTEGER                          NO-UNDO.
    DEF         VAR aux_vllanmto AS DECIMAL                          NO-UNDO.
    
    DEF         VAR lcm_qtlanmto AS INTEGER                          NO-UNDO.
    DEF         VAR lcm_vllanmto AS DECIMAL                          NO-UNDO.

    DEF         VAR aux_contador AS INTEGER                          NO-UNDO.

    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper   AND
                           craplcm.dtmvtolt = tel_dtrefere   AND
                           craplcm.cdagenci = 90             AND
                           craplcm.cdbccxlt = 11             AND
                           craplcm.nrdolote = 11000 + 900    AND
                           craplcm.cdhistor = 508            NO-LOCK
                           BREAK BY craplcm.nrdconta
                                   BY SUBSTRING(craplcm.cdpesqbb,1,36):

        IF   FIRST-OF(SUBSTRING(craplcm.cdpesqbb,1,36))   THEN
             ASSIGN aux_qtlanmto = 0 
                    aux_vllanmto = 0
                    lcm_qtlanmto = 0
                    lcm_vllanmto = 0.
        
        ASSIGN lcm_qtlanmto = lcm_qtlanmto + 1
               lcm_vllanmto = lcm_vllanmto + craplcm.vllanmto
               aux_contador = aux_contador + 1.

        MESSAGE "Verificando debitos de titulos e faturas (" + 
                 STRING(aux_contador) + ")... Cooperativa: " + 
                 STRING(par_cdcooper).
       
        IF   LAST-OF(SUBSTRING(craplcm.cdpesqbb,1,36))   THEN
             DO:
                 /* Titulos */
                 IF   craplcm.cdpesqbb BEGINS
                      "INTERNET - PAGAMENTO ON-LINE - BANCO"   THEN
                      DO:
                          /* Desconsidera estornos */
                          FOR EACH crablcm WHERE
                                   crablcm.cdcooper = par_cdcooper       AND
                                   crablcm.dtmvtolt = tel_dtrefere       AND
                                   crablcm.cdagenci = 90                 AND
                                   crablcm.cdbccxlt = 11                 AND
                                   crablcm.nrdolote = 11000 + 900        AND
                                   crablcm.cdhistor = 570                AND
                                   crablcm.nrdconta = craplcm.nrdconta
                                   NO-LOCK:
                          
                              IF   crablcm.cdpesqbb BEGINS
                                   "INTERNET - ESTORNO PAGAMENTO " +
                                   "ON-LINE - BANCO"    THEN
                                   ASSIGN lcm_qtlanmto = lcm_qtlanmto - 1
                                          lcm_vllanmto = lcm_vllanmto -
                                                             crablcm.vllanmto.
                          END.
                          
                          FOR EACH craptit WHERE
                                   craptit.cdcooper = par_cdcooper   AND
                                   craptit.dtmvtolt = tel_dtrefere   AND
                                   craptit.cdagenci = 90             AND
                                   craptit.cdbccxlt = 11             AND
                                   craptit.nrdolote = 16000 + 900    AND
                                   craptit.nrdconta = craplcm.nrdconta
                                   NO-LOCK:
                          
                              ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                                     aux_vllanmto = aux_vllanmto +
                                                    craptit.vldpagto.
                          END.
                   /*     IF   aux_qtlanmto <> lcm_qtlanmto   THEN
                               DO:
                                  MESSAGE "Titulos nao conferem com"
                                           "lancamentos - Conta/DV: "
                                           craplcm.nrdconta.
                                  glb_cdcritic = 139.
                                  RETURN.
                               END.    */
                      
                      END.
             END. /* Fim LAST-OF */

        HIDE MESSAGE NO-PAUSE.
   END.                          

END PROCEDURE. /* Fim proc_verifica_pac_internet */


/* .......................................................................... */

PROCEDURE pi_imprime_protocolo_devolu:

    EMPTY TEMP-TABLE cratdev.
    
    DEF VAR aux_cdcopant AS INT                             NO-UNDO.
    DEF VAR aux_nrctaant AS INT                             NO-UNDO.
    DEF VAR aux_cdageant AS INT                             NO-UNDO.
    
    ASSIGN tot_qtpridev = 0
           tot_vlpridev = 0
           tot_qtsegdev = 0
           tot_vlsegdev = 0
           tot_qtdgeral = 0
           tot_vlrgeral = 0.
    
    ASSIGN aux_nmarqimp = "rlnsv/crrl575_" + STRING(TIME,"99999") + ".lst".

    { includes/cabrel080_1.i }
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.

    DISPLAY STREAM str_1 glb_dtmvtolt
        WITH FRAME f_devolu_cab_1.

    DISPLAY STREAM str_1 "" WITH FRAME f_devolu_cab_2.


    FOR EACH crapcop 
       WHERE crapcop.cdcooper <> 3
         AND crapcop.flgativo = TRUE NO-LOCK:

        FOR EACH crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                               crapdev.cdbanchq = crapcop.cdbcoctl  AND
                               crapdev.insitdev = 1                 AND
                               crapdev.cdhistor <> 46               AND
                               crapdev.cdalinea > 0                 AND
                             ((crapdev.cdpesqui <> ""               AND
                               crapdev.nrdconta = 0)                OR
                               crapdev.cdpesqui = "")               AND
                               crapdev.indevarq <> 0                NO-LOCK:

            IF   crapdev.nrdconta <> 0 THEN
                 DO:
                     RUN verifica_craptco (INPUT  crapdev.cdcooper,
                                           INPUT  crapdev.nrdconta,
                                           INPUT  crapdev.nrcheque,
                                           OUTPUT aux_nrctaant,
                                           OUTPUT aux_cdageant).

                     IF   aux_nrctaant > 0 THEN /* Eh conta migrada */ 
                          FIND LAST gncpchq WHERE 
                                    gncpchq.cdcooper = crapdev.cdcooper AND
                                    gncpchq.dtmvtolt = glb_dtmvtoan     AND
                                    gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                    gncpchq.cdagechq = aux_cdageant     AND
                                    gncpchq.nrctachq = aux_nrctaant     AND
                                    gncpchq.nrcheque = crapdev.nrcheque AND
                                   (gncpchq.cdtipreg = 3                OR
                                    gncpchq.cdtipreg = 4)               AND
                                    gncpchq.vlcheque = crapdev.vllanmto
                                    NO-LOCK NO-ERROR.
                     ELSE
                          FIND LAST gncpchq WHERE 
                                    gncpchq.cdcooper = crapdev.cdcooper AND
                                    gncpchq.dtmvtolt = glb_dtmvtoan     AND
                                    gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                    gncpchq.cdagechq = crapcop.cdagectl AND
                                    gncpchq.nrctachq = crapdev.nrdconta AND
                                    gncpchq.nrcheque = crapdev.nrcheque AND
                                   (gncpchq.cdtipreg = 3                OR
                                    gncpchq.cdtipreg = 4)               AND
                                    gncpchq.vlcheque = crapdev.vllanmto
                                    NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE gncpchq THEN
                          NEXT.

                 END.

            CREATE cratdev.
            BUFFER-COPY crapdev TO cratdev.
        END.
        
        /*** Validacoes TCO **/
        IF   crapcop.cdcooper = 2 THEN
             DO:
                 FOR EACH crapdev WHERE crapdev.cdbanchq = crapcop.cdbcoctl AND
                                        crapdev.insitdev = 1                AND
                                        crapdev.cdhistor <> 46              AND
                                        crapdev.cdalinea > 0                AND
                                        crapdev.cdpesqui = "TCO"            AND
                                        crapdev.indevarq <> 0            
                                        NO-LOCK:
    
                     FIND LAST craplcm WHERE 
                               craplcm.cdcooper = crapdev.cdcooper   AND
                               craplcm.nrdconta = crapdev.nrdctabb   AND
                               craplcm.nrdocmto = crapdev.nrcheque   AND
                               craplcm.nrdctabb = crapdev.nrdconta   AND
                               CAN-DO("521,524,572",STRING(craplcm.cdhistor))
                               USE-INDEX craplcm2 NO-LOCK  NO-ERROR.
    
                     IF   NOT AVAILABLE craplcm THEN
                          NEXT.
    
                     CREATE cratdev.
                     BUFFER-COPY crapdev TO cratdev.
                 END.
             END.

    END.

    

    FOR EACH cratdev NO-LOCK
       BREAK BY cratdev.cdcooper:
     
       IF   FIRST-OF(cratdev.cdcooper) THEN
            ASSIGN rel_qtpridev = 0
                   rel_qtsegdev = 0
                   rel_qtgercop = 0
                   rel_vlpridev = 0
                   rel_vlsegdev = 0
                   rel_vlgercop = 0.
                 
       CASE cratdev.indevarq:
            WHEN 2 THEN ASSIGN rel_qtpridev = rel_qtpridev + 1
                               rel_vlpridev = rel_vlpridev + cratdev.vllanmto.
            WHEN 1 THEN ASSIGN rel_qtsegdev = rel_qtsegdev + 1
                               rel_vlsegdev = rel_vlsegdev + cratdev.vllanmto.
       END CASE.
    
       IF   LAST-OF(cratdev.cdcooper) THEN 
            DO:
                ASSIGN tot_qtpridev = tot_qtpridev + rel_qtpridev
                       tot_qtsegdev = tot_qtsegdev + rel_qtsegdev

                       tot_vlpridev = tot_vlpridev + rel_vlpridev
                       tot_vlsegdev = tot_vlsegdev + rel_vlsegdev
                 
                       rel_qtgercop = rel_qtpridev + rel_qtsegdev
                       rel_vlgercop = rel_vlpridev + rel_vlsegdev.

                FIND FIRST crapcop WHERE crapcop.cdcooper = cratdev.cdcooper
                                         NO-LOCK NO-ERROR.
    
                IF   AVAILABLE crapcop THEN
                     aux_nmrescop = crapcop.nmrescop.
                ELSE aux_nmrescop = "NAO ENCONTRADA".
    
                DISPLAY STREAM str_1  aux_nmrescop  rel_qtpridev
                                      rel_vlpridev  rel_qtsegdev
                                      rel_vlsegdev  rel_qtgercop
                                      rel_vlgercop  
                                      WITH FRAME f_protocolo_devolu.
                DOWN STREAM str_1 WITH FRAME f_protocolo_devolu.
            END.
    END.

    ASSIGN tot_qtdgeral = tot_qtpridev + tot_qtsegdev
           tot_vlrgeral = tot_vlpridev + tot_vlsegdev.

    DISPLAY STREAM str_1 tot_qtpridev   tot_vlpridev   tot_qtsegdev
                         tot_vlsegdev   tot_qtdgeral   tot_vlrgeral
                         WITH FRAME f_protocolo_devolu_tot.
    DOWN STREAM str_1 WITH FRAME f_protocolo_devolu_tot.
    
    OUTPUT STREAM str_1 CLOSE.

    ASSIGN tel_cddopcao = "T".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         NEXT.

    IF   tel_cddopcao = "T"   THEN
         RUN fontes/visrel.p (INPUT aux_nmarqimp).
    ELSE
         IF   tel_cddopcao = "I"   THEN
              DO:
                  /* somente para o includes/impressao.i */
                  FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                           NO-LOCK NO-ERROR.

                  glb_nmformul = "80col".
                  
                  { includes/impressao.i }
              END.
         ELSE
              DO:
                  glb_cdcritic = 14.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  NEXT.
              END.

END PROCEDURE.

PROCEDURE verifica_craptco:

    DEF INPUT  PARAM par_cdcooper  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcheque  LIKE crapdev.nrcheque                NO-UNDO. 
    DEF OUTPUT PARAM par_nrctaant  LIKE crapdev.nrdconta                NO-UNDO.
    DEF OUTPUT PARAM par_cdageant  LIKE crabcop.cdagectl                NO-UNDO.

    ASSIGN par_nrctaant = 0. /* Se retornar 0 nao eh conta incorporada */

    FIND craptco WHERE craptco.cdcooper = par_cdcooper     AND
                       craptco.nrdconta = par_nrdconta     AND
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptco THEN 
        DO:
            /* Busca coop antiga */ 
            FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                               NO-LOCK NO-ERROR.

            IF  AVAIL crabcop THEN
                DO:
                    /* Verifica se eh talao antigo */ 
                    FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper      AND
                                       crapfdc.cdbanchq = 085               AND
                                       crapfdc.cdagechq = crabcop.cdagectl  AND 
                                       crapfdc.nrctachq = craptco.nrctaant  AND
                                       crapfdc.nrcheque = 
                                               INT(SUBSTR(STRING(par_nrcheque,
                                                              "9999999"),1,6))
                                       USE-INDEX crapfdc1
                                       NO-LOCK NO-ERROR NO-WAIT.
              
                    IF  AVAIL(crapfdc) THEN 
                        ASSIGN par_nrctaant = craptco.nrctaant
                               par_cdageant = crabcop.cdagectl.
                END.
        END.

END PROCEDURE.

/* LOG de execuaco dos programas */
PROCEDURE gera_log_execucao:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Manual - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.

FUNCTION proc_coop_executando RETURNS LOGICAL (INPUT par_cdcooper AS INTEGER):

	DEF BUFFER crabdat FOR crapdat.

	FIND crabdat WHERE crabdat.cdcooper = par_cdcooper AND
	                   crabdat.inproces <> 1 NO-LOCK NO-ERROR.

	IF AVAIL(crabdat) THEN
	   DO:
			RETURN TRUE.
	   END.

	RETURN FALSE.
END FUNCTION.

/*............................................................................*/

