/* ............................................................................

   Programa: Fontes/movgps.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego/Mirtes
   Data    : Julho/2005                         Ultima alteracao: 05/12/2016
 
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Movimentos Guias Previdencia

   Alteracoes: 17/10/2005 - Efetuado acerto campos decimais(Mirtes) 
   
               16/11/2005 - Desabilitada funcao "G"(Mirtes)
               
               17/11/2005 - Criada opcao "A" (Diego).

               28/11/2005 - Alterado para atualizar aux_cdsituac quando
                            compensacao for rodada (Diego).
               
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/pedesenha.p - SQLWorks - 
                            Fernando.
                            
               28/02/2008 - Incluida geracao de arq. para o BANCOOB e campo
                            "Tipo de Contribuinte" na opcao "V";
                          - Reativada a opcao "G" e ajustada para o BANCOOB
                            (Evandro).
               
               10/06/2008 - Gerar agendamento dos codigos 1104, 1457, 1554,
                            1147, 1180, 1490 e 1651 somente nos meses 03,06,09 
                            e 12 (Elton).

               26/06/2008 - Criticar na opcao "G" a data de quitacao no caso
                            de nao ser dia util (Gabriel).
               
               19/08/2008 - Criada Opcao "D" para listar e imprimir todas as
                            guias com agendamento; 
                          - Incluido campo "identificador na opcao "V"; 
                          - Incluido "*" nas guias com pendencias no browse 
                            da opcao "G" (Elton).
               
               17/10/2008 - Adicionada critica para nao deixar fazer a geracao
                            do arquivo de debito automatico (opcao G) no dia ou
                            depois da data de quitacao (Elton).

               04/11/2008 - Trata CTRL-C para relatorios (Martin)
               
               14/11/2008 - Inclusao de totalizadores no Layout
                            
                          - Na opcao B, pegar Forma de captacao da crapgps 
                            (Gabriel).
                            
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               06/05/2011 - Alterada a permissoes de acesso das opcoes
                            da tela (Henrique).
                            
               18/10/2011 - Incluir novos codigos (Gabriel).     
               
               21/05/2012 - Liberar departamento COMPE para acesso a tela
                           (David Kruger).      
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               10/01/2014 - Alterado critica de "15 - Agencia nao cadastrada",
                            "89 - Agencia deve ser informada" para "962 - PA
                            nao cadastrado".
                          - Trocado de Agencia para PA. (Reinert)
                          
               29/05/2014 - Nas procedures p_regera_crawlgp, processa_craplgp e
                            nas opcoes "V" e "X", incluida na clausula where do
                            for each craplgp a condição craplgp.idsicredi = 0.
                                                                       (Carlos)
                                                                       
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               13/03/2015 - Ajuste na opcao "G" para validar apenas se a data
                            de movimento eh maior que a data parametrizada
                            pela tab051 (Adriano).            

               18/04/2016 - Ajustado buscas na LGP para nao trazer GPS's
                            agendadas(nrseqagp) (Guilherme/SUPERO)

               06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                            (Guilherme/SUPERO)
                            
               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................ */

{ includes/var_online.i }

DEF STREAM str_1.

DEF VAR aux_posregis AS RECID                                        NO-UNDO.

DEF      VAR aux_cddopcao AS CHAR                                    NO-UNDO.
DEF      VAR aux_confirma AS CHAR    FORMAT "!"                      NO-UNDO.
DEF      VAR aux_contador AS INT                                     NO-UNDO.
DEF      VAR aux_cdagefim LIKE craplgp.cdagenci                      NO-UNDO.
DEF      VAR aux_nrdcaixa LIKE craplgp.nrdcaixa                      NO-UNDO.
DEF      VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
DEF      VAR aux_flgenvio AS LOG                                     NO-UNDO.
DEF      VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF      VAR aux_flginpes AS INTEGER                                 NO-UNDO.
DEF      VAR aux_nmarqsai AS CHAR    FORMAT "x(40)"                  NO-UNDO.
DEF      VAR aux_cdsequen AS INT                                     NO-UNDO.
DEF      VAR aux_nrremess AS INT                                     NO-UNDO.
DEF      VAR aux_cdagenci AS INT     FORMAT "9999"                   NO-UNDO.
DEF      VAR aux_contadig AS CHAR    FORMAT "x(10)"                  NO-UNDO.
DEF      VAR aux_data     AS CHAR    FORMAT "x(08)"                  NO-UNDO.
DEF      VAR aux_vlrdinss AS DEC                                     NO-UNDO.
DEF      VAR aux_vlrouent AS DEC                                     NO-UNDO.
DEF      VAR aux_vlrjuros AS DEC                                     NO-UNDO.
DEF      VAR aux_vlrtotal AS DEC                                     NO-UNDO.
DEF      VAR aux_anocompe AS CHAR    FORMAT "x(04)"                  NO-UNDO.
DEF      VAR aux_mescompe AS CHAR    FORMAT "x(02)"                  NO-UNDO.
DEF      VAR aux_cdsituac AS INT                                     NO-UNDO.
DEF      VAR aux_nrdahora AS INT                                     NO-UNDO.

DEF      VAR tel_cdidenti LIKE crapcgp.cdidenti                      NO-UNDO.
DEF      VAR aux_verpende AS LOGICAL                                 NO-UNDO.

DEF      VAR aut_flgsenha AS LOGICAL                                 NO-UNDO.
DEF      VAR aut_cdoperad AS CHAR                                    NO-UNDO.

DEF      VAR tel_dtmvtolt AS DATE                                    NO-UNDO.
DEF      VAR tel_cdagenci AS INT     FORMAT "zz9"                    NO-UNDO.
DEF      VAR tel_nrdcaixa LIKE craplgp.nrdcaixa                      NO-UNDO.
DEF      VAR tel_qttitrec AS DECI    FORMAT "zzz,zz9"                NO-UNDO.
DEF      VAR tel_vltitrec AS DECI    FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF      VAR tel_flgenvio AS LOG     FORMAT "Enviados/Nao Enviados"  NO-UNDO.
DEF      VAR tel_flcpfcgc AS LOGICAL FORMAT "Fisica/Juridica"        NO-UNDO.
DEF      VAR tel_nrdhhini AS INT                                     NO-UNDO.
DEF      VAR tel_nrdmmini AS INT                                     NO-UNDO.
DEF      VAR tel_dssituac AS CHAR    FORMAT "x(30)"                  NO-UNDO.
DEF      VAR tel_cddsenha AS CHAR    FORMAT "x(10)"                  NO-UNDO.
DEF      VAR tel_situacao AS INTE                                    NO-UNDO.

DEF      VAR aux_dsobserv AS CHAR                                    NO-UNDO.
DEF      VAR aux_verdbaut AS LOGICAL                                 NO-UNDO.
DEF      VAR h-b1crap82   AS HANDLE                                  NO-UNDO.

 /* variaveis para impressao */
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrmodulo     AS INT     FORMAT "9"                NO-UNDO.
DEF        VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

/* variaveis de totalizador */
DEF        VAR tot_quantida AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tot_vlrdinss AS DEC     FORMAT ">>>>>,>>>,>>9.99"     NO-UNDO.
DEF        VAR tot_vloutent LIKE craplgp.vlrouent                    NO-UNDO.
DEF        VAR tot_vlrjuros LIKE craplgp.vlrjuros                    NO-UNDO.
DEF        VAR tot_vlrtotal LIKE craplgp.vlrtotal                    NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DEF BUFFER crablgp FOR craplgp.

DEFINE TEMP-TABLE crawlgp                                            NO-UNDO  
       FIELD  cdagenci  LIKE craplgp.cdagenci
       FIELD  nrdcaixa  LIKE craplgp.nrdcaixa
       FIELD  nmoperad  LIKE crapope.nmoperad
       FIELD  cdbccxlt  LIKE craplgp.cdbccxlt
       FIELD  nrdolote  LIKE craplgp.nrdolote
       FIELD  vlrdinss  LIKE craplgp.vlrdinss
       FIELD  vlrtotal  LIKE craplgp.vlrtotal
       FIELD  cdidenti  LIKE craplgp.cdidenti
       FIELD  vlrouent  LIKE craplgp.vlrouent
       FIELD  vlrjuros  LIKE craplgp.vlrjuros
       FIELD  mmaacomp  LIKE craplgp.mmaacomp
       FIELD  nrdconta  LIKE crapcgp.nrdconta
       FIELD  nmprimtl  LIKE crapcgp.nmprimtl
       FIELD  cddpagto  LIKE crapcgp.cddpagto
       FIELD  tpcontri  LIKE crapcgp.tpcontri
       INDEX crawlgp1 cdagenci nrdolote vlrdinss.

DEF QUERY q_arquivo FOR crawlgp.

DEF BROWSE b_arquivo QUERY q_arquivo 
    DISP crawlgp.cdagenci COLUMN-LABEL "PA"
         crawlgp.nrdcaixa COLUMN-LABEL "Caixa"
         crawlgp.nmoperad COLUMN-LABEL "Operador"   FORMAT "x(20)"
         crawlgp.cdbccxlt COLUMN-LABEL "Bc/Cx"
         crawlgp.nrdolote COLUMN-LABEL "Lote"
         crawlgp.vlrdinss COLUMN-LABEL "Vlr.INSS   " FORMAT "zzz,zz9.99"
         crawlgp.vlrtotal COLUMN-LABEL "Vlr.Total  " FORMAT "zzz,zz9.99"
         WITH 4 DOWN.


DEFINE TEMP-TABLE crawcgp                                            NO-UNDO
       FIELD cdobserv   AS CHAR FORMAT "x(1)"
       FIELD nmprimtl   LIKE crapcgp.nmprimtl 
       FIELD cdidenti   LIKE crapcgp.cdidenti
       FIELD cddpagto   LIKE crapcgp.cddpagto
       FIELD nrctadeb   LIKE crapcgp.nrctadeb  
       FIELD vlrdinss   AS DEC  FORMAT "zzz,zz9.99"  
       FIELD vloutent   AS DEC  FORMAT "zzz,zz9.99"
       FIELD vlrjuros   AS DEC  FORMAT "zzz,zz9.99"
       FIELD vlrtotal   AS DEC  FORMAT "zzz,zz9.99"
       FIELD dsobserv   AS CHAR FORMAT "x(60)". 

/**** Opcao "D" ****/
DEF QUERY q_debito FOR crawcgp.

DEF BROWSE  b_debito QUERY q_debito
    DISPLAY crawcgp.cdobserv  NO-LABEL
            crawcgp.cdidenti  COLUMN-LABEL "Identificador"
            crawcgp.cddpagto  COLUMN-LABEL "Codigo"
            crawcgp.nrctadeb  COLUMN-LABEL "Conta/dv"
            crawcgp.vlrdinss  COLUMN-LABEL "Vlr.INSS"
            crawcgp.vloutent  COLUMN-LABEL "Outras Ent."
            crawcgp.vlrjuros  COLUMN-LABEL "ATM/Multa/Juros"
            crawcgp.vlrtotal  COLUMN-LABEL "Valor Total"
            crawcgp.dsobserv  COLUMN-LABEL "Irregularidades" 
            WITH SCROLLBAR-VERTICAL 6 DOWN  WIDTH 76  NO-BOX .
                        
FORM SKIP(1) b_debito   
             HELP "Pressione <END> p/ imprimir e sair ou <SETAS> p/ navegar."
             SKIP
             WITH  ROW 8 CENTERED TITLE "Listagem de Guias com Agendamento" 
             OVERLAY FRAME f_rel_debito.

/** Opcao "G" **/
DEF QUERY q_crapcgp FOR crawcgp FIELDS(nrctadeb
                                       nmprimtl
                                       cdidenti
                                       cddpagto
                                       vlrdinss
                                       vloutent
                                       vlrjuros 
                                       vlrtotal).

DEF BROWSE  b_crapcgp QUERY q_crapcgp 
    DISPLAY crawcgp.cdobserv    NO-LABEL  
            crawcgp.nrctadeb    COLUMN-LABEL "Conta"
            crawcgp.nmprimtl    COLUMN-LABEL "Nome"    FORMAT "x(15)"
            crawcgp.cdidenti    COLUMN-LABEL "Identificador"
            crawcgp.cddpagto    COLUMN-LABEL "Cd.Pgto"
            crawcgp.vlrtotal    COLUMN-LABEL "Vlr.Total"
            
            WITH 5 DOWN.
                      
DEF FRAME f_movgpsg  
          SKIP(1)
          b_crapcgp  
    HELP  "Pressione <F4>ou<END> p/finalizar " 
          SKIP(1)
          "(*) Guias com Pendencias."
          WITH NO-BOX CENTERED OVERLAY ROW 7.
          
FORM    crawcgp.cdobserv  NO-LABEL
        crawcgp.cdidenti  COLUMN-LABEL "Identificador"
        crawcgp.cddpagto  COLUMN-LABEL "Codigo"
        crawcgp.nrctadeb  COLUMN-LABEL "Conta/dv"
        crawcgp.vlrdinss  COLUMN-LABEL "Vlr.INSS"
        crawcgp.vloutent  COLUMN-LABEL "Outras Ent."
        crawcgp.vlrjuros  COLUMN-LABEL "ATM/Multa/Juros"
        crawcgp.vlrtotal  COLUMN-LABEL "Valor Total"
        crawcgp.dsobserv  COLUMN-LABEL "Irregularidades"  FORMAT "x(42)"
        WITH DOWN WIDTH 132  FRAME f_imprim_d.         

FORM    SKIP(1)
        "Quantidade"
        tot_quantida  NO-LABEL
        "Total"       AT 27
        tot_vlrdinss  AT 33 NO-LABEL FORMAT ">>>,>>>,>>9.99"
        tot_vloutent  AT 49 NO-LABEL FORMAT ">>>,>>9.99"
        tot_vlrjuros  AT 61 NO-LABEL FORMAT ">>>,>>>,>>9.99"
        tot_vlrtotal  AT 77 NO-LABEL FORMAT ">>>,>>9.99"
        WITH COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABELS FRAME f_imprim_total_d.
        
FORM SKIP(1)
     "Arquivo Gerado "
     SKIP(1)
     "ATENCAO - Utilizar Tela LANDEB               "
     SKIP (1)
     aux_nmarqsai FORMAT "x(40)"
     WITH NO-LABELS OVERLAY CENTERED ROW 10 FRAME f_arq_gerado. 

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A, C, B, D, G, R, V ou X)."
                       VALIDATE(CAN-DO("A,C,B,D,G,R,V,X",glb_cddopcao),
                                     "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_movgps.

FORM tel_dtmvtolt AT 1 LABEL "Referencia"  FORMAT "99/99/9999"
                       HELP  "Informe a data de referencia do movimento."
     tel_cdagenci      LABEL "         PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
                 VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper  AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0
                                     ,"962 - PA nao cadastrado.")
     tel_nrdcaixa      LABEL "Caixa"
                 HELP "Entre com o numero do Caixa  ou 0 para todos os Caixa"
     WITH ROW 6 COLUMN 20 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM tel_dtmvtolt AT 1 LABEL " Referencia"  FORMAT "99/99/9999"
                       HELP "Informe a data de referencia do movimento."
     tel_cdagenci      LABEL " PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
                 VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper  AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0
                                     ,"962 - PA nao cadastrado.")
     tel_nrdcaixa      LABEL "Caixa"
                 HELP "Entre com o numero do Caixa  ou 0 para todos os Caixa"  
     tel_flgenvio      LABEL "  Opcao"
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY  NO-BOX  FRAME f_refere_v.

FORM tel_cdidenti LABEL "Identificador" 
     WITH OVERLAY SIDE-LABELS ROW 8 COLUMN 14 NO-BOX FRAME f_cdidenti. 

FORM "Qtd.               Valor" AT 36 
     SKIP(1)
     tel_qttitrec AT 12 FORMAT "zzz,zz9" LABEL  "Guias  Recebidas"
     tel_vltitrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     WITH ROW 8 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.
     
FORM "(A) - Alterar horario da transmissao de guias" SKIP
     "(C) - Consultar" SKIP
     "(B) - Gerar arquivos" SKIP
     "(R) - Relatorio" SKIP                      
     "(D) - Relatorio de debito autorizado" SKIP 
     "(V) - Visualizar os lotes" SKIP     
     "(X) - Reativar Registros para Envio" SKIP
     "(G) - Gera Arq. Debito Automatico - BANCOOB"  SKIP
     WITH SIZE 64 BY 10 CENTERED OVERLAY ROW 8 
     TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.
     
FORM crapcgp.nrdconta           LABEL "Conta/Dv"
     crapcgp.nmprimtl   AT 30   LABEL "Nome"   FORMAT "x(35)"
     SKIP
     craplgp.cdidenti           LABEL "Identificador "
     crapcgp.tpcontri   AT 36   LABEL "Tipo Contrib."
     SKIP
     craplgp.mmaacomp   AT  1   LABEL "Competencia" 
     crapcgp.cddpagto   AT 36   LABEL "Cd.Pgto"
     SKIP
     craplgp.vlrouent   AT  1   LABEL "Vlr.Outros"
     craplgp.vlrjuros   AT 36   LABEL "Vlr.Juros"  
     SKIP
     craplgp.vlrdinss           LABEL "Vlr.INSS  "  
     craplgp.vlrtotal   AT 36   LABEL "Vlr.Total"
     WITH ROW 16 WIDTH 76 CENTERED NO-BOX SIDE-LABELS OVERLAY
     FRAME f_dados_movgpsv.
     
FORM crawlgp.nrdconta           LABEL "Conta/Dv"
     crawlgp.nmprimtl   AT 30   LABEL "Nome"   FORMAT "x(35)"
     crawlgp.cdidenti           LABEL "Identificador "
     crawlgp.mmaacomp   AT  1   LABEL "Competencia" 
     crawlgp.cddpagto   AT 36   LABEL "Cd.Pgto"
     crawlgp.vlrouent   AT  1   LABEL "Vlr.Outros"
     crawlgp.vlrjuros   AT 36   LABEL "Vlr.Juros"  
     SKIP
     crawlgp.vlrdinss           LABEL "Vlr.INSS  "  
     crawlgp.vlrtotal   AT 36   LABEL "Vlr.Total"
     WITH ROW 16 WIDTH 76 CENTERED NO-BOX SIDE-LABELS OVERLAY
     FRAME f_dados_arquivo.

FORM tel_flcpfcgc    AT  5 LABEL "Tipo de Pessoa"
                           HELP "Informe (F)isica ou (J)uridica."
     tel_dtmvtolt    AT 35 LABEL "Data de Quitacao"   FORMAT "99/99/9999"
     WITH ROW 6 NO-BOX COLUMN 12 SIDE-LABELS OVERLAY FRAME f_gera_txt.


FORM tel_flcpfcgc    AT  5 LABEL "Tipo de Pessoa"
                           HELP "Informe (F)isica ou (J)uridica."
      WITH ROW 6 NO-BOX  COLUMN 12 SIDE-LABELS OVERLAY FRAME f_opcao_d.


FORM b_arquivo AT 3 
     HELP "Use SETAS p/Navegar e <F4> p/Sair. Pressione <ENTER> p/Excluir!"    
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_arquivo.     
     
FORM aux_confirma    AT 1 LABEL "Iniciar Nova Selecao?     " 
                     HELP "Entre com a opcao S/N."
     WITH ROW 13 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_regera.
     
FORM tel_cdagenci       LABEL " PA  "
                        HELP "Entre com o numero do PA "
                        VALIDATE( tel_cdagenci <> 0 , 
                                         "962 - PA nao cadastrado.")
     tel_cddsenha BLANK LABEL "         Senha"
                        HELP "Entre com a senha do PA "
     SKIP(3)
     tel_nrdhhini AT  1 LABEL "Limite para digitacao dos titulos" 
                        FORMAT "99" AUTO-RETURN
                        HELP "Entre com a hora limite (12:00 a 20:00)."
     ":"          AT 38 
     tel_nrdmmini AT 39 NO-LABEL FORMAT "99" 
                        HELP "Entre com os minutos (0 a 59)."
     "Horas"
     SKIP(1)
     tel_dssituac AT 9 LABEL "Situacao do(s) arquivo(s)"
     WITH ROW 11 COLUMN 9 NO-BOX OVERLAY SIDE-LABELS FRAME f_fechamento.


DEF QUERY q_craplgp FOR craplgp
                 FIELDS(cdagenci
                        nrdcaixa
                        cdbccxlt
                        cdopecxa
                        nrdolote
                        vlrdinss
                        vlrjuros
                        vlrouent
                        vlrtotal
                        mmaacomp
                        cdidenti
                        cddpagto 
                        flgenvio),
                        crapope
                  FIELDS(nmoperad),
                         crapcgp.        
                                     
DEF BROWSE b_craplgp QUERY q_craplgp 
    DISP craplgp.cdagenci COLUMN-LABEL "PA"
         craplgp.nrdcaixa COLUMN-LABEL "Caixa"
         crapope.nmoperad COLUMN-LABEL "Operador"   FORMAT "x(20)"
         craplgp.cdbccxlt COLUMN-LABEL "Bc/Cx"
         craplgp.nrdolote COLUMN-LABEL "Lote"
         craplgp.vlrdinss COLUMN-LABEL "Vlr.INSS   " FORMAT "zzz,zz9.99"
         craplgp.vlrtotal COLUMN-LABEL "Vlr.Total  " FORMAT "zzz,zz9.99"
         WITH 4 DOWN.

DEF FRAME f_movgpsv  
          SKIP(1)
          b_craplgp  
    HELP  "Pressione <F4>ou<END> p/finalizar " 
          WITH NO-BOX CENTERED OVERLAY ROW 7.


ON VALUE-CHANGED OF b_craplgp
   DO:   
       FIND crapcgp WHERE crapcgp.cdcooper = glb_cdcooper     AND
                          crapcgp.cdidenti = craplgp.cdidenti AND
                          crapcgp.cddpagto = craplgp.cddpagto  
                          NO-LOCK NO-ERROR.
                           
       DISPLAY  crapcgp.nrdconta  crapcgp.nmprimtl                             
                craplgp.cdidenti  crapcgp.cddpagto   
                craplgp.vlrdinss  craplgp.vlrouent
                craplgp.vlrjuros  craplgp.vlrtotal
                craplgp.mmaacomp  crapcgp.tpcontri
                WITH  FRAME f_dados_movgpsv.
   END.

ON VALUE-CHANGED OF b_arquivo
   DO:
       IF  AVAIL crawlgp THEN
           aux_posregis = RECID(crawlgp).

       DISPLAY  crawlgp.nrdconta  crawlgp.nmprimtl                             
                crawlgp.cdidenti  crawlgp.cddpagto   
                crawlgp.vlrdinss  crawlgp.vlrouent
                crawlgp.vlrjuros  crawlgp.vlrtotal
                crawlgp.mmaacomp
                WITH  FRAME f_dados_arquivo.
   END.

ON RETURN OF b_arquivo
   DO:
       IF  AVAIL crawlgp THEN
           aux_posregis = RECID(crawlgp).

       IF   glb_cddopcao = "B"   THEN
            DO:
                IF   AVAILABLE  crawlgp  THEN
                     DO:
                         aux_confirma = "N".
                         MESSAGE COLOR NORMAL
                                 "Deseja realmente excluir este registro ?"
                         UPDATE aux_confirma.
                     END.
                                   
                IF   CAPS(aux_confirma) = "S"   THEN
                     DO:
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE COLOR NORMAL "Aguarde! Excluindo Registro...".
                         
                         FIND crawlgp WHERE RECID(crawlgp) = aux_posregis
                                            EXCLUSIVE-LOCK NO-ERROR.
                              
                         IF  AVAIL crawlgp THEN
                             DELETE crawlgp.
                     END.
                         
                
                OPEN QUERY q_arquivo FOR EACH crawlgp NO-LOCK
                                         BY crawlgp.cdagenci
                                            BY crawlgp.nrdolote
                                               BY crawlgp.vlrdinss.
                     
                ENABLE b_arquivo WITH FRAME f_arquivo.
           
                IF   AVAILABLE crawlgp THEN 
                
                     DISPLAY  crawlgp.nrdconta  crawlgp.nmprimtl               
                              crawlgp.cdidenti  crawlgp.cddpagto   
                              crawlgp.vlrdinss  crawlgp.vlrouent
                              crawlgp.vlrjuros  crawlgp.vlrtotal                
                              crawlgp.mmaacomp
                              WITH  FRAME f_dados_arquivo.
                
                HIDE MESSAGE NO-PAUSE.
               
                MESSAGE "Pressione <ENTER> p/Excluir!".                    
            END.
   END.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtolt = glb_dtmvtolt.

VIEW FRAME f_moldura.
PAUSE(0).
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               PAUSE.
               glb_cdcritic = 0.
           END.

      VIEW FRAME f_helpopcao.
      PAUSE(0).

      UPDATE glb_cddopcao  WITH FRAME f_movgps. 

      IF (glb_cddepart <> 18     AND  /* SUPORTE */
          glb_cddepart <> 20     AND  /* TI      */
          glb_cddepart <>  4 )   AND  /* COMPE   */
         (glb_cddopcao =  "A"    OR
          glb_cddopcao =  "B"    OR
          glb_cddopcao =  "X"    OR
          glb_cddopcao =  "G")   THEN
        DO:
            glb_cdcritic = 36.
            NEXT.
        END.
        

      HIDE FRAME f_helpopcao NO-PAUSE.    
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "MOVGPS"  THEN
                 DO:
                     HIDE FRAME f_movgps.
                     HIDE FRAME f_total.  
                     HIDE FRAME f_refere.
                     HIDE FRAME f_moldura.
                     
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.


   IF   glb_cddopcao = "V"   THEN
        DO:
           ASSIGN tel_cdidenti = 0. 
           DISPLAY tel_cdidenti WITH FRAME f_cdidenti.
           
           HIDE FRAME f_refere.
           HIDE FRAME f_total.   
  
           VIEW FRAME f_cdidenti.
           
           UPDATE tel_dtmvtolt 
                  tel_cdagenci 
                  tel_nrdcaixa 
                  tel_flgenvio WITH FRAME f_refere_v.

           UPDATE tel_cdidenti WITH FRAME f_cdidenti.
           
           ASSIGN aux_flgenvio = tel_flgenvio.
           ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                 THEN 9999
                                 ELSE tel_cdagenci.

           ASSIGN aux_nrdcaixa = IF tel_nrdcaixa = 0 
                                 THEN 9999
                                 ELSE tel_nrdcaixa.
           
           
           IF  tel_cdidenti = 0 THEN     /** Para listar todas as guias **/
               DO:
                   OPEN QUERY q_craplgp 
           
                   FOR EACH craplgp WHERE 
                                    craplgp.cdcooper  = glb_cdcooper    AND
                                    craplgp.dtmvtolt  = tel_dtmvtolt    AND 
                                    craplgp.cdagenci >= tel_cdagenci    AND
                                    craplgp.cdagenci <= aux_cdagefim    AND
                                    craplgp.nrdcaixa >= tel_nrdcaixa    AND
                                    craplgp.nrdcaixa <= aux_nrdcaixa    AND
                                    craplgp.flgenvio  = aux_flgenvio    AND 
                                    craplgp.idsicred  = 0               AND
                                    craplgp.nrseqagp  = 0
                                AND craplgp.flgativo  = YES             NO-LOCK,
                              FIRST crapope
                              WHERE crapope.cdcooper        = glb_cdcooper
                                AND UPPER(crapope.cdoperad) = UPPER(craplgp.cdopecxa)   NO-LOCK,
                            FIRST crapcgp WHERE
                                  crapcgp.cdcooper  = glb_cdcooper      AND
                                  crapcgp.cdidenti  = craplgp.cdidenti  AND 
                                  crapcgp.cddpagto  = craplgp.cddpagto  NO-LOCK
                                  BY craplgp.cdagenci
                                     BY craplgp.nrdolote
                                        BY craplgp.vlrdinss.
                   END.
           ELSE
               DO:
                  OPEN QUERY q_craplgp 
           
                  FOR EACH craplgp WHERE 
                                  craplgp.cdcooper  = glb_cdcooper      AND
                                  craplgp.dtmvtolt  = tel_dtmvtolt      AND 
                                  craplgp.cdagenci >= tel_cdagenci      AND
                                  craplgp.cdagenci <= aux_cdagefim      AND
                                  craplgp.nrdcaixa >= tel_nrdcaixa      AND
                                  craplgp.nrdcaixa <= aux_nrdcaixa      AND
                                  craplgp.flgenvio  = aux_flgenvio      AND
                                  craplgp.cdidenti  = tel_cdidenti      AND
                                  craplgp.nrseqagp  = 0
                              AND craplgp.flgativo = YES                NO-LOCK,
                            FIRST crapope WHERE 
                                  crapope.cdcooper  = glb_cdcooper      AND
                                  crapope.cdoperad  = craplgp.cdopecxa  NO-LOCK,
                            FIRST crapcgp WHERE
                                  crapcgp.cdcooper  = glb_cdcooper      AND
                                  crapcgp.cdidenti  = craplgp.cdidenti  AND 
                                  crapcgp.cddpagto  = craplgp.cddpagto  NO-LOCK
                                  BY craplgp.cdagenci
                                     BY craplgp.nrdolote
                                        BY craplgp.vlrdinss.
               END.

           ENABLE b_craplgp WITH FRAME f_movgpsv.
                             
           IF   AVAILABLE craplgp THEN 
                             
                DISPLAY  crapcgp.nrdconta  crapcgp.nmprimtl               
                         craplgp.cdidenti  crapcgp.cddpagto   
                         craplgp.vlrdinss  craplgp.vlrouent
                         craplgp.vlrjuros  craplgp.vlrtotal                
                         craplgp.mmaacomp  crapcgp.tpcontri
                         WITH  FRAME f_dados_movgpsv.
                                   
           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                        
           HIDE FRAME f_movgpsv.
           HIDE FRAME f_dados_movgpsv.
             
           HIDE MESSAGE NO-PAUSE.
        END.
   ELSE              
   IF   glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_nrdcaixa = 0.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               VIEW FRAME f_moldura.
               VIEW FRAME f_movgps.
                   
               UPDATE tel_dtmvtolt 
                      tel_cdagenci 
                      tel_nrdcaixa 
                      tel_flgenvio WITH FRAME f_refere_v.
                      
               ASSIGN aux_flgenvio = tel_flgenvio.
              
               RUN processa_craplgp.

               aux_confirma = "N".
            
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         
                  MESSAGE COLOR NORMAL
                          "Deseja listar os LOTES referentes a pesquisa(S/N)?:"
                          UPDATE aux_confirma.
                  LEAVE.
                         
               END. /* fim do DO WHILE */
                            
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"                  THEN
                    NEXT.

               DO ON STOP UNDO, LEAVE:
                  RUN fontes/movgps_r.p (INPUT tel_dtmvtolt, 
                                         INPUT tel_cdagenci, 
                                         INPUT tel_nrdcaixa,
                                         INPUT 1,
                                         INPUT tel_flgenvio,
                                         INPUT tel_flgenvio, 
                                         INPUT TABLE crawlgp).
               END.                          
            END. /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN                              /*  Relatorio  */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_total. 

            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0 
                   tel_nrdcaixa = 0.
          
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               VIEW FRAME f_moldura.
               VIEW FRAME f_movgps.
               
               UPDATE tel_dtmvtolt
                      tel_cdagenci 
                      tel_nrdcaixa WITH FRAME f_refere.

               DO ON STOP UNDO, LEAVE:
                  RUN fontes/movgps_r.p (INPUT tel_dtmvtolt, 
                                         INPUT tel_cdagenci,
                                         INPUT tel_nrdcaixa,
                                         INPUT 1,
                                         INPUT "NO",
                                         INPUT "YES",
                                         INPUT TABLE crawlgp).
               END.                          
            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "D"   THEN
        DO:
              EMPTY TEMP-TABLE crawcgp.
              
              HIDE FRAME f_refere.
              HIDE FRAME f_refere_v.
              HIDE FRAME f_total.
              
              UPDATE tel_flcpfcgc WITH FRAME f_opcao_d.    
              
              IF  tel_flcpfcgc = TRUE   THEN
                  ASSIGN aux_flginpes = 1.
              ELSE
                  ASSIGN aux_flginpes = 2.
              
              FOR EACH crapcgp WHERE
                               crapcgp.cdcooper = glb_cdcooper AND
                               crapcgp.flgdbaut = TRUE         AND
                               crapcgp.flgrgatv = TRUE         AND
                               crapcgp.inpessoa = aux_flginpes NO-LOCK:
                               
                  CREATE crawcgp.
                  ASSIGN crawcgp.cdidenti = crapcgp.cdidenti
                         crawcgp.cddpagto = crapcgp.cddpagto
                         crawcgp.nrctadeb = crapcgp.nrctadeb
                         crawcgp.vlrdinss = crapcgp.vlrdinss
                         crawcgp.vloutent = crapcgp.vloutent
                         crawcgp.vlrjuros = crapcgp.vlrjuros 
                         crawcgp.vlrtotal = crapcgp.vlrdinss + 
                                            crapcgp.vloutent + crapcgp.vlrjuros.
                                
                  RUN verifica_pendencias.               
                                  
              END. 
              
              OPEN QUERY q_debito
                   FOR EACH crawcgp.
                    
              ENABLE b_debito WITH FRAME f_rel_debito.
              
              /*** Imprime listagem gerada na tela ***/
              RUN imprime_d. 
              
        END.
   ELSE 
   IF   glb_cddopcao = "G"   THEN
        DO:
            IF   crapcop.cdcrdarr = 0   THEN
                 DO:
                     MESSAGE "Creden.Arrecadacoes nao cadastrado"
                             "(Tela CADCOP).".
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.
                 
            IF   crapcop.cdagebcb = 0   THEN
                 DO:
                     MESSAGE "Agencia Bancoob nao cadastrada (Tela CADCOP).".
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.
            
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_total.
            
            tel_dtmvtolt = ?.
            DISPLAY tel_dtmvtolt WITH FRAME f_gera_txt.
            
            UPDATE tel_flcpfcgc WITH FRAME f_gera_txt.
            
            IF   tel_flcpfcgc = TRUE   THEN
                 ASSIGN aux_flginpes = 1.
            ELSE
                 ASSIGN aux_flginpes = 2.
                           
            /* Busca e monta a data de quitacao */
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "GPSAGEBCOB"   AND
                               craptab.tpregist = aux_flginpes
                               NO-LOCK NO-ERROR.
                               
            /* Se nao encontrar ou o dia nao estiver cadastrado */
            IF   NOT AVAILABLE craptab                      OR
                 INT(SUBSTRING(craptab.dstextab,1,2)) = 0   THEN
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     BELL.
                     PAUSE 3 NO-MESSAGE.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
                 
            
            tel_dtmvtolt = DATE(MONTH(glb_dtmvtolt),
                                INT(SUBSTRING(craptab.dstextab,1,2)),
                                YEAR(glb_dtmvtolt)).
                                
            DISPLAY tel_dtmvtolt WITH FRAME f_gera_txt.
            

            IF   (LOOKUP(STRING(WEEKDAY(tel_dtmvtolt)),"1,7") <> 0)   OR
                 (CAN-FIND(crapfer WHERE
                           crapfer.cdcooper = glb_cdcooper            AND
                           crapfer.dtferiad = tel_dtmvtolt))          THEN
                 DO:                     
                     MESSAGE "Data de quitacao nao permitida. "  + 
                             "Escolha nova data atraves da TAB051.".
                     BELL.
                     PAUSE 4 NO-MESSAGE.         
                     NEXT.
                 END.       
                                
            /* Verifica se o arquivo ja foi gerado no mes */
            IF   DATE(SUBSTRING(craptab.dstextab,4,10)) <> ?   THEN
                 DO:
                     MESSAGE "O arquivo ja foi gerado no mes atual.".
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.
                 
            FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper
                               NO-LOCK NO-ERROR.
            
            EMPTY TEMP-TABLE crawcgp.
            
            FOR EACH crapcgp WHERE crapcgp.cdcooper = glb_cdcooper     AND
                                   crapcgp.flgdbaut = YES              AND
                                   crapcgp.flgrgatv = YES              AND
                                   crapcgp.inpessoa = aux_flginpes
                                   NO-LOCK: 
                                      
                 CREATE crawcgp.
                 ASSIGN crawcgp.nrctadeb = crapcgp.nrctadeb 
                        crawcgp.nmprimtl = crapcgp.nmprimtl
                        crawcgp.cdidenti = crapcgp.cdidenti
                        crawcgp.cddpagto = crapcgp.cddpagto 
                        crawcgp.vlrtotal = crapcgp.vlrdinss + 
                                           crapcgp.vloutent + crapcgp.vlrjuros.
                                        
                  RUN verifica_pendencias.

            END.
            
            OPEN QUERY q_crapcgp
                 FOR EACH crawcgp.
                                        
            ENABLE b_crapcgp WITH FRAME f_movgpsg.
            
            IF   NOT AVAILABLE crawcgp  THEN
                 DO:
                     HIDE FRAME f_movgpsg.
                     NEXT.
                 END.    

            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
            
            
            HIDE FRAME f_movgpsg.
            HIDE FRAME f_dados_movgpsg.
             
            HIDE MESSAGE NO-PAUSE.

            IF  glb_dtmvtolt > tel_dtmvtolt THEN
                DO:
                    MESSAGE "O arquivo so pode ser gerado antes " +
                            "da data de quitacao.".
                    BELL.
                    PAUSE 4 NO-MESSAGE.  
                    NEXT.
                END.
            
            IF  aux_verpende = TRUE THEN
                DO:           
                    MESSAGE  "Geracao de agendamento cancelada. "  + 
                             "Verifique as irregularidades na opcao 'D'.".
                    BELL.
                    PAUSE.
                    LEAVE.
                END.         
            
            RUN confirma.
            IF   aux_confirma = "S"   THEN
                 DO:
                     ASSIGN aux_nmarqimp = "GUIAS-INSS-" +
                                           TRIM(STRING(tel_flcpfcgc,
                                                       "F/J")) +
                                           ".txt".

                     OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).
           
                     EMPTY TEMP-TABLE crawlgp.
                     
                     FOR EACH crapcgp WHERE crapcgp.cdcooper = glb_cdcooper AND
                                            crapcgp.flgdbaut = YES          AND
                                            crapcgp.flgrgatv = YES          AND
                                            crapcgp.inpessoa = aux_flginpes
                                            EXCLUSIVE-LOCK  
                                            BREAK BY crapcgp.cdidenti 
                                                     BY crapcgp.nrctadeb:
                         
             IF  CAN-DO("1848,1937,1953,1104,1457,1554,1147,1180,1490,1651",
                                    STRING(crapcgp.cddpagto))            AND
                             (MONTH(glb_dtmvtolt) <> 03                  AND 
                              MONTH(glb_dtmvtolt) <> 06                  AND 
                              MONTH(glb_dtmvtolt) <> 09                  AND 
                              MONTH(glb_dtmvtolt) <> 12)                 THEN
                              NEXT.
                         
                         ASSIGN 
                          aux_vlrtotal = aux_vlrtotal     + crapcgp.vlrdinss +
                                         crapcgp.vloutent + crapcgp.vlrjuros.
                         
                         IF LAST-OF(crapcgp.nrctadeb) THEN
                            DO:
                                PUT STREAM str_1
                                    crapcgp.nrctadeb  FORMAT "zzzzzzz9"  " "
                                    crapcgp.cdidenti 
                                    FORMAT "zzzzzzzzzzzzzz9" " "
                                    aux_vlrtotal 
                                    SKIP.
                                ASSIGN aux_vlrtotal = 0.
                            END.
                         
                         CREATE crawlgp.
                         ASSIGN crawlgp.cdagenci = 0
                                crawlgp.nrdcaixa = 0
                                crawlgp.nmoperad = ""
                                crawlgp.cdbccxlt = 0
                                crawlgp.nrdolote = 0
                                crawlgp.vlrdinss = crapcgp.vlrdinss
                                crawlgp.vlrtotal = crapcgp.vlrdinss +
                                                   crapcgp.vloutent +
                                                   crapcgp.vlrjuros 
                                crawlgp.cdidenti = crapcgp.cdidenti
                                crawlgp.vlrouent = crapcgp.vloutent 
                                crawlgp.vlrjuros = crapcgp.vlrjuros 
                                crawlgp.mmaacomp =
                                            INT(SUBSTR(STRING(crapdat.dtultdma,
                                                       "99/99/9999"),4,2) +
                                                SUBSTR(STRING(crapdat.dtultdma,
                                                "99/99/9999"),7,4))
                                crawlgp.nrdconta = crapcgp.nrdconta  
                                crawlgp.nmprimtl = crapcgp.nmprimtl
                                crawlgp.cddpagto = crapcgp.cddpagto
                                crawlgp.tpcontri = crapcgp.tpcontri.

                                /** Zera campos apos execucao da opcao "G" **/
                                ASSIGN  crapcgp.vloutent = 0
                                        crapcgp.vlrjuros = 0.
                                           
                     END.

                     OUTPUT STREAM str_1 CLOSE.
                     
                     RUN proc_gera_arquivo_bancoob.
                     
                     UNIX SILENT VALUE("ux2dos < arq/" +  aux_nmarqimp +
                                       ' | tr -d "\032"' +
                                       " > /micros/" + crapcop.dsdircop + "/" +
                                       aux_nmarqimp + " 2>/dev/null").
                                       
                     /* Atualiza a data de geracao do arquivo */
                     DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
                        DO aux_contador = 1 TO 10:

                           FIND craptab WHERE craptab.cdcooper = glb_cdcooper
                                          AND craptab.nmsistem = "CRED"
                                          AND craptab.tptabela = "GENERI"
                                          AND craptab.cdempres = 0
                                          AND craptab.cdacesso = "GPSAGEBCOB"
                                          AND craptab.tpregist = aux_flginpes
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE craptab   THEN
                                IF   LOCKED craptab   THEN
                                     DO:
                                        RUN sistema/generico/procedures/b1wgen9999.p
                                        PERSISTENT SET h-b1wgen9999.
                                        
                                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                             INPUT "banco",
                                                             INPUT "craptab",
                                                             OUTPUT par_loginusr,
                                                             OUTPUT par_nmusuari,
                                                             OUTPUT par_dsdevice,
                                                             OUTPUT par_dtconnec,
                                                             OUTPUT par_numipusr).
                                        
                                        DELETE PROCEDURE h-b1wgen9999.
                                        
                                        ASSIGN aux_dadosusr = 
                                        "077 - Tabela sendo alterada p/ outro terminal.".
                                        
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        MESSAGE aux_dadosusr.
                                        PAUSE 3 NO-MESSAGE.
                                        LEAVE.
                                        END.
                                        
                                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                      " - " + par_nmusuari + ".".
                                        
                                        HIDE MESSAGE NO-PAUSE.
                                        
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        MESSAGE aux_dadosusr.
                                        PAUSE 5 NO-MESSAGE.
                                        LEAVE.
                                        END.
                                        
                                        NEXT.
                                      END.
                                ELSE
                                     DO:
                                         glb_cdcritic = 55.
                                         LEAVE.
                                     END.    
                           ELSE
                                glb_cdcritic = 0.

                           LEAVE.

                        END.  /*  Fim do DO .. TO  */

                        IF   glb_cdcritic > 0 THEN
                             RETURN.
                             
                        ASSIGN SUBSTRING(craptab.dstextab,4,10) =
                                         STRING(glb_dtmvtolt,"99/99/9999").

                     END. /* TRANSACTION */
                     
                     ASSIGN aux_nmarqsai = "/micros/" + crapcop.dsdircop +
                                           "/" + aux_nmarqimp.
                     DISPLAY aux_nmarqsai WITH FRAME f_arq_gerado. 
                     PAUSE 4 NO-MESSAGE.
                     HIDE FRAME f_arq_gerado.
                 END.
        END.
   ELSE
   IF   glb_cddopcao = "B"   THEN
        DO:
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_nrdcaixa = 0.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               VIEW FRAME f_moldura.
               VIEW FRAME f_movgps.
                   
               UPDATE tel_dtmvtolt 
                      tel_cdagenci 
                      tel_nrdcaixa 
                      WITH FRAME f_refere.
                      
               ASSIGN aux_flgenvio = NO.
               ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                     THEN 9999
                                     ELSE tel_cdagenci.

               ASSIGN aux_nrdcaixa = IF tel_nrdcaixa = 0 
                                     THEN 9999
                                     ELSE tel_nrdcaixa.

               RUN p_regera_crawlgp.

               OPEN QUERY q_arquivo FOR EACH crawlgp NO-LOCK 
                                     BY crawlgp.cdagenci
                                        BY crawlgp.nrdolote
                                           BY crawlgp.vlrdinss.
           
               ENABLE b_arquivo WITH FRAME f_arquivo.
            
               IF   AVAILABLE crawlgp THEN 
                    
                    DISPLAY  crawlgp.nrdconta  crawlgp.nmprimtl             
                             crawlgp.cdidenti  crawlgp.cddpagto   
                             crawlgp.vlrdinss  crawlgp.vlrouent
                             crawlgp.vlrjuros  crawlgp.vlrtotal            
                             crawlgp.mmaacomp
                             WITH  FRAME f_dados_arquivo.
                                    
               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                        
               HIDE FRAME f_arquivo.
               HIDE FRAME f_dados_arquivo.
             
               HIDE MESSAGE NO-PAUSE.
               
               IF   AVAILABLE crawlgp  THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           aux_confirma = "N".
                           MESSAGE COLOR NORMAL "Deseja Gerar Arquivo? (S/N):" 
                           UPDATE aux_confirma.
                           LEAVE.
                        END.
               
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S" THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                                 NEXT.
                             END.
                    END.
               ELSE
                    NEXT.
               
               /*---- Controle de 1 operador utilizando  tela --*/             
                  
               FIND  craptab WHERE
                     craptab.cdcooper = glb_cdcooper      AND       
                     craptab.nmsistem = "CRED"            AND
                     craptab.tptabela = "GENERI"          AND
                     craptab.cdempres = crapcop.cdcooper  AND         
                     craptab.cdacesso = "MOVGPS"          AND
                     craptab.tpregist = 1                 NO-LOCK NO-ERROR.
           
               IF  NOT AVAIL craptab THEN 
                   DO:
                      CREATE craptab.
                      ASSIGN craptab.nmsistem = "CRED"      
                             craptab.tptabela = "GENERI"          
                             craptab.cdempres = crapcop.cdcooper        
                             craptab.cdacesso = "MOVGPS"                
                             craptab.tpregist = 1  
                             craptab.cdcooper = crapcop.cdcooper.
                      RELEASE craptab.    
                   END.
            
               DO  WHILE TRUE:

                   FIND  craptab WHERE
                         craptab.cdcooper = glb_cdcooper      AND       
                         craptab.nmsistem = "CRED"            AND
                         craptab.tptabela = "GENERI"          AND
                         craptab.cdempres = crapcop.cdcooper  AND              
                         craptab.cdacesso = "MOVGPS"          AND
                         craptab.tpregist = 1                 NO-LOCK NO-ERROR.
                 
                   IF  NOT AVAIL craptab THEN 
                       DO:
                          MESSAGE 
                          "Controle nao cad.(Avise Inform) Processo Cancelado!".
                          PAUSE MESSAGE
                          "Tecle <entra> para voltar `a tela de identificacao!".
                          BELL.
                          LEAVE.
                       END.
                  
                   IF  craptab.dstextab <> " "   AND
                       TRIM(craptab.dstextab) <> glb_cdoperad   THEN
                       DO:
                           MESSAGE
                           "Processo sendo utilizado pelo Operador " +
                           TRIM(SUBSTR(craptab.dstextab,1,20)).
                           PAUSE MESSAGE
                           "Peca liberacao Coordenador ou Aguarde......".
                           RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                   INPUT 2, 
                                                   OUTPUT aut_flgsenha,
                                                   OUTPUT aut_cdoperad).
                                                                              
                           IF   aut_flgsenha    THEN
                                LEAVE.
                             
                           NEXT.
                    
                       END.

                       LEAVE.
               END.
            
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                                  craptab.nmsistem = "CRED"               AND
                                  craptab.tptabela = "GENERI"             AND
                                  craptab.cdempres = crapcop.cdcooper     AND
                                  craptab.cdacesso = "MOVGPS"             AND
                                  craptab.tpregist = 1  
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
               IF  AVAIL craptab THEN     
                   DO:
                       ASSIGN craptab.dstextab = glb_cdoperad.
                       RELEASE craptab.
                   END.
               
               IF  crapcop.cdcrdarr = 0  THEN
                   DO:
                       RUN proc_gera_arquivo_bb.
                     
                       IF   glb_cdcritic > 0   THEN
                            DO:
                                RUN atualiza_controle_operador.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT.
                            END.
                   END.
               ELSE
                   DO:
                       IF   crapcop.cdagebcb = 0   THEN
                            DO:
                                MESSAGE "Agencia Bancoob nao cadastrada"
                                        "(Tela CADCOP).".
                                PAUSE 3 NO-MESSAGE.
                                NEXT.
                            END.
                 
                       RUN proc_gera_arquivo_bancoob.
                 
                       IF   glb_cdcritic > 0   THEN
                            DO:
                                RUN atualiza_controle_operador.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT.
                            END.
                   END.
                
               DO ON STOP UNDO, LEAVE:
                  RUN fontes/movgps_r.p (INPUT tel_dtmvtolt, 
                                         INPUT tel_cdagenci, 
                                         INPUT tel_nrdcaixa,
                                         INPUT 2, /* tipo relatorio */
                                         INPUT tel_flgenvio,
                                         INPUT tel_flgenvio,
                                         INPUT TABLE crawlgp).
               END.
               
               RUN atualiza_lancamentos.

               PAUSE 2 NO-MESSAGE.
            
               HIDE MESSAGE NO-PAUSE.

               MESSAGE "Movtos atualizados         ".

               RUN atualiza_controle_operador.
            
               MESSAGE "Arquivo Gerado  - Transmita Arquivo!!!".
 
               PAUSE 2 NO-MESSAGE.               
               LEAVE.
            END.
        END.
   ELSE
   IF   glb_cddopcao = "X"   THEN     /* Volta Sit.Enviados p/Nao enviados */
        DO:
            VIEW FRAME f_moldura.
            VIEW FRAME f_movgps.
                   
            UPDATE tel_dtmvtolt 
                   tel_cdagenci 
                   WITH FRAME f_refere.

            ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                  THEN 9999
                                  ELSE tel_cdagenci.

              
            OPEN QUERY q_craplgp 
           
            FOR EACH craplgp WHERE
                     craplgp.cdcooper  = glb_cdcooper AND
                     craplgp.dtmvtolt  = tel_dtmvtolt AND
                     craplgp.cdagenci >= tel_cdagenci AND
                     craplgp.cdagenci <= aux_cdagefim AND
                     craplgp.flgenvio  = YES          AND
                     craplgp.idsicred  = 0            AND
                     craplgp.nrseqagp  = 0
                 AND craplgp.flgativo  = YES          NO-LOCK,
                     FIRST crapope WHERE 
                           crapope.cdcooper = glb_cdcooper     AND 
                           crapope.cdoperad = craplgp.cdopecxa NO-LOCK,
                     FIRST crapcgp WHERE
                           crapcgp.cdcooper = glb_cdcooper     AND
                           crapcgp.cdidenti = craplgp.cdidenti AND
                           crapcgp.cddpagto = craplgp.cddpagto NO-LOCK
                           BY craplgp.cdagenci
                              BY craplgp.nrdolote
                                 BY craplgp.vlrdinss.
           
            ENABLE b_craplgp WITH FRAME f_movgpsv.
           
            IF   AVAILABLE craplgp THEN 
                
                 DISPLAY  crapcgp.nrdconta  crapcgp.nmprimtl               
                          craplgp.cdidenti  crapcgp.cddpagto   
                          craplgp.vlrdinss  craplgp.vlrouent
                          craplgp.vlrjuros  craplgp.vlrtotal                
                          craplgp.mmaacomp  crapcgp.tpcontri
                          WITH  FRAME f_dados_movgpsv.
                                   
            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                        
            HIDE FRAME f_movgpsv.
            HIDE FRAME f_dados_movgpsv.
             
            HIDE MESSAGE NO-PAUSE.
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                aux_confirma = "N".

                glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                glb_cdcritic = 0.
                LEAVE.

            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S" THEN
                DO:
                   glb_cdcritic = 79.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   glb_cdcritic = 0.
                   NEXT.
                END.

            RUN atualiza_lancamentos_regerar.
   
            MESSAGE "Movtos atualizados         ".
            MESSAGE "                           ".
 
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
 
            UPDATE tel_cdagenci 
                   tel_cddsenha       
                   WITH FRAME f_fechamento.
            
            FIND crapage WHERE
                 crapage.cdcooper = glb_cdcooper     AND   
                 crapage.cdagenci = tel_cdagenci     NO-LOCK NO-ERROR.
          
            IF   NOT AVAIL crapage THEN
                 DO:
                     glb_cdcritic = 962. /*  PA nao cadastrado. */
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
  
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:

                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                     craptab.nmsistem = "CRED"        AND
                                     craptab.tptabela = "GENERI"      AND
                                     craptab.cdempres = 00            AND
                                     craptab.cdacesso = "HRGUIASGPS"  AND
                                     craptab.tpregist = tel_cdagenci
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptab   THEN
                       IF   LOCKED craptab   THEN
                            DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                     INPUT "banco",
                                                     INPUT "craptab",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                               
                                NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 55.
                                LEAVE.
                            END.    
                            
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN aux_cdsituac = INT(SUBSTR(craptab.dstextab,1,1))
                      aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))
                      tel_dssituac = IF aux_cdsituac = 0 
                                        THEN "NAO PROCESSADO(S)" 
                                        ELSE IF aux_cdsituac = 1 
                                                THEN "PROCESSADO(S)" 
                                                ELSE "SITUACAO ERRADA"
                      tel_situacao = aux_cdsituac
                      tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),1,2))
                      tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),4,2)).

               DISPLAY tel_dssituac 
                       WITH FRAME f_fechamento.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.
                  
                  UPDATE tel_nrdhhini tel_nrdmmini 
                         WITH FRAME f_fechamento.

                  IF   tel_nrdhhini < 10 OR tel_nrdhhini > 20 THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.

                  IF   tel_nrdmmini > 59  THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.

                  IF   tel_nrdhhini = 20 AND tel_nrdmmini > 0 THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.
                  
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               ASSIGN aux_nrdahora = (tel_nrdhhini * 3600) + (tel_nrdmmini * 60)
                      craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                                         STRING(aux_nrdahora,"99999") 

                      glb_cdcritic = 0.

            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_fechamento NO-PAUSE.
        END.   
END.

/*  ........................................................................  */


PROCEDURE processa_craplgp:

   ASSIGN tel_qttitrec = 0
          tel_vltitrec = 0.

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.
   ASSIGN aux_nrdcaixa = IF tel_nrdcaixa = 0 
                         THEN 9999
                         ELSE tel_nrdcaixa.
                      
   FOR EACH craplgp WHERE craplgp.cdcooper  = glb_cdcooper   AND
                          craplgp.dtmvtolt  = tel_dtmvtolt   AND 
                          craplgp.cdagenci >= tel_cdagenci   AND
                          craplgp.cdagenci <= aux_cdagefim   AND     
                          craplgp.nrdcaixa >= tel_nrdcaixa   AND
                          craplgp.nrdcaixa <= aux_nrdcaixa   AND
                          craplgp.flgenvio  = aux_flgenvio   AND 
                          craplgp.idsicred  = 0              AND
                          craplgp.nrseqagp  = 0
                      AND craplgp.flgativo  = YES            NO-LOCK:
     
       ASSIGN tel_qttitrec = tel_qttitrec + 1
              tel_vltitrec = tel_vltitrec + craplgp.vlrtotal. 
                
   
   END.  /*  Fim do FOR EACH  */

   DISPLAY tel_qttitrec           
           tel_vltitrec
           WITH FRAME f_total.
   
END PROCEDURE.


PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE p_regera_crawlgp:
                   
  EMPTY TEMP-TABLE crawlgp.

  FOR EACH craplgp WHERE
           craplgp.cdcooper  = glb_cdcooper   AND 
           craplgp.dtmvtolt  = tel_dtmvtolt   AND
           craplgp.cdagenci >= tel_cdagenci   AND
           craplgp.cdagenci <= aux_cdagefim   AND
           craplgp.nrdcaixa >= tel_nrdcaixa   AND
           craplgp.nrdcaixa <= aux_nrdcaixa   AND
           craplgp.flgenvio  = aux_flgenvio   AND 
           craplgp.idsicred  = 0              AND
           craplgp.nrseqagp  = 0
       AND craplgp.flgativo  = YES            NO-LOCK,
                   FIRST crapope WHERE 
                         crapope.cdcooper = glb_cdcooper        AND
                         crapope.cdoperad = craplgp.cdopecxa    NO-LOCK,
                   FIRST crapcgp WHERE
                         crapcgp.cdcooper = glb_cdcooper        AND
                         crapcgp.cdidenti = craplgp.cdidenti    AND
                         crapcgp.cddpagto = craplgp.cddpagto    NO-LOCK:

      FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                         crapage.cdagenci = craplgp.cdagenci
                         NO-LOCK NO-ERROR.
      CREATE crawlgp.
      ASSIGN crawlgp.cdagenci = craplgp.cdagenci
             crawlgp.nrdcaixa = craplgp.nrdcaixa
             crawlgp.nmoperad = crapope.nmoperad
             crawlgp.cdbccxlt = craplgp.cdbccxlt
             crawlgp.nrdolote = craplgp.nrdolote
             crawlgp.vlrdinss = craplgp.vlrdinss
             crawlgp.vlrtotal = craplgp.vlrtotal
             crawlgp.cdidenti = craplgp.cdidenti
             crawlgp.vlrouent = craplgp.vlrouent
             crawlgp.vlrjuros = craplgp.vlrjuros
             crawlgp.mmaacomp = craplgp.mmaacomp
             crawlgp.nrdconta = crapcgp.nrdconta
             crawlgp.nmprimtl = crapcgp.nmprimtl
             crawlgp.cddpagto = crapcgp.cddpagto
             crawlgp.tpcontri = crapcgp.tpcontri.
                    
  END.
  
  HIDE FRAME f_regera NO-PAUSE.
            
END PROCEDURE.


PROCEDURE proc_gera_arquivo_bb:
                           
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "HRGUIASGPS"  AND
                       craptab.tpregist = 000
                       NO-LOCK NO-ERROR NO-WAIT.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RETURN.
         END.    
           
    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Gerando Arquivo (BB)...".
               
    PAUSE 2 NO-MESSAGE.
    
    ASSIGN aux_cdsequen = 1
           aux_nrremess = INT(SUBSTR(craptab.dstextab,18,2))
           aux_cdagenci = INT(SUBSTR(craptab.dstextab,1,5))
           aux_contadig = SUBSTR(craptab.dstextab,7,10).
   
           aux_nmarquiv = "gp" + STRING(DAY(tel_dtmvtolt),"99") + 
                                 STRING(MONTH(tel_dtmvtolt),"99") +
                                 STRING(YEAR(tel_dtmvtolt),"9999") +
                                 STRING(aux_nrremess,"99") + ".rem".
           
    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
    /*   Header do Arquivo    */
    ASSIGN aux_data =  STRING(YEAR(tel_dtmvtolt),"9999") + 
                       STRING(MONTH(tel_dtmvtolt),"99") +
                       STRING(DAY(tel_dtmvtolt),"99").
                                      
    PUT STREAM str_1
               "A"                  FORMAT "x(1)"
               "ART300"             FORMAT "x(6)"
               crapcop.nrdocnpj     FORMAT "99999999999999"
               aux_data             FORMAT "x(8)"       
               "PR"                 FORMAT "x(2)"
               aux_nrremess         FORMAT "99"
               aux_cdagenci         FORMAT "99999"
               aux_contadig         FORMAT "x(10)"            
               "09"              
               crapcop.nmextcop     FORMAT "x(40)"
               "        "           FORMAT "x(8)"
               "032546"          
               "000000000"
               " "                  FORMAT "x(182)"
               aux_cdsequen         FORMAT "99999"
               SKIP.
                         
    FOR EACH crawlgp NO-LOCK,
        FIRST crapcgp WHERE
              crapcgp.cdcooper = glb_cdcooper       AND 
              crapcgp.cdidenti = crawlgp.cdidenti   AND
              crapcgp.cddpagto = crawlgp.cddpagto   NO-LOCK      
              BY crawlgp.cdagenci
                 BY crawlgp.nrdolote
                    BY crawlgp.vlrdinss: 

   
        ASSIGN aux_cdsequen = aux_cdsequen + 1.
   
        /* Detalhe do arquivo */
   
        ASSIGN aux_vlrdinss = crawlgp.vlrdinss * 100
               aux_vlrouent = crawlgp.vlrouent * 100
               aux_vlrjuros = crawlgp.vlrjuros * 100
               aux_vlrtotal = crawlgp.vlrtotal * 100
               aux_anocompe = SUBSTR(STRING(crawlgp.mmaacomp,"999999"),3,4) 
               aux_mescompe = SUBSTR(STRING(crawlgp.mmaacomp,"999999"),1,2) .
        PUT STREAM str_1
                    "S"                       FORMAT "x(1)"
                    aux_data                  FORMAT "x(8)"         
                    crawlgp.cddpagto          FORMAT "9999"
                    aux_anocompe              FORMAT "9999"
                    aux_mescompe              FORMAT "99"
                    crawlgp.cdidenti          FORMAT "99999999999999"
                    aux_vlrdinss              FORMAT "99999999999999999"
                    aux_vlrouent              FORMAT "99999999999999999"
                    aux_vlrjuros              FORMAT "99999999999999999"
                    aux_vlrtotal              FORMAT "99999999999999999"
                    crapcgp.nmprimtl          FORMAT "x(30)"
                    "1"
                    " "                       FORMAT "x(21)"
                    "0000"                    
                    "J"                       FORMAT "x(01)"
                    STRING(crapcop.nrdocnpj,"99999999999999")  FORMAT "x(24)" 
                    " "                       FORMAT "x(113)"
                    aux_cdsequen              FORMAT "99999"
                    SKIP.
    END.

    /* trailer */
  
    /* total de registros + header + trailer */
    ASSIGN aux_cdsequen = aux_cdsequen + 1.

    PUT STREAM str_1
               "Z"                  FORMAT "x(1)"
               aux_cdsequen         FORMAT "999999"
               " "                  FORMAT "x(288)"
               aux_cdsequen         FORMAT "99999"
               SKIP.                    

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                      " > /micros/" + crapcop.dsdircop + 
                      "/compel/" + aux_nmarquiv + " 2>/dev/null").

    UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                      " salvar 2>/dev/null").
 
    DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
       FOR EACH crapage WHERE
                crapage.cdcooper  = glb_cdcooper    AND
                crapage.cdagenci >= tel_cdagenci    AND
                crapage.cdagenci <= aux_cdagefim    NO-LOCK:  
            
           DO aux_contador = 1 TO 10:

              FIND craptab WHERE
                   craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "GENERI"           AND
                   craptab.cdempres = 00                 AND
                   craptab.cdacesso = "HRGUIASGPS"       AND
                   craptab.tpregist = crapage.cdagenci
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
                            
                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                 INPUT "banco",
                                                 INPUT "craptab",
                                                 OUTPUT par_loginusr,
                                                 OUTPUT par_nmusuari,
                                                 OUTPUT par_dsdevice,
                                                 OUTPUT par_dtconnec,
                                                 OUTPUT par_numipusr).
                            
                            DELETE PROCEDURE h-b1wgen9999.
                            
                            ASSIGN aux_dadosusr = 
                            "077 - Tabela sendo alterada p/ outro terminal.".
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                          " - " + par_nmusuari + ".".
                            
                            HIDE MESSAGE NO-PAUSE.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 5 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            NEXT.
                        END.
                   ELSE
                        DO:
                           glb_cdcritic = 55.
                           LEAVE.
                        END.    
                           
              ELSE
                   glb_cdcritic = 0.
               
              LEAVE.

           END.  /*  Fim do DO .. TO  */

           IF   glb_cdcritic > 0 THEN
                RETURN.

           ASSIGN aux_cdsituac = 1
                  aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))
                  
                  craptab.dstextab = STRING(aux_cdsituac,"9") + " " +
                                     STRING(aux_nrdahora,"99999").

           RELEASE craptab.
       END.
       
       /*   Atualiza a sequencia da remessa  */
               
       DO aux_contador = 1 TO 10:

          FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                       craptab.nmsistem = "CRED"                AND
                       craptab.tptabela = "GENERI"              AND
                       craptab.cdempres = 00                    AND
                       craptab.cdacesso = "HRGUIASGPS"          AND
                       craptab.tpregist = 000
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craptab   THEN
               IF   LOCKED craptab   THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                             INPUT "banco",
                                             INPUT "craptab",
                                             OUTPUT par_loginusr,
                                             OUTPUT par_nmusuari,
                                             OUTPUT par_dsdevice,
                                             OUTPUT par_dtconnec,
                                             OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                      " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 55.
                        LEAVE.
                    END.    
          ELSE
               glb_cdcritic = 0.

          LEAVE.

       END.  /*  Fim do DO .. TO  */

       IF   glb_cdcritic > 0 THEN
            RETURN.

       ASSIGN aux_nrremess = aux_nrremess + 1.
       craptab.dstextab = SUBSTR(craptab.dstextab,1,17)  + 
                          STRING(aux_nrremess,"99"). 
                          
    END. /* TRANSACTION */

END PROCEDURE.


PROCEDURE proc_gera_arquivo_bancoob:

    DEF VAR aux_vltotarq    AS DECIMAL                              NO-UNDO.
    DEF VAR aux_cdforcap    AS INTEGER                              NO-UNDO.

    /* Sequencial do arquivo */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "ARQRETINSS"   AND
                       craptab.tpregist = 99
                       NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RETURN.
         END.    
           
    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Gerando Arquivo (BANCOOB)...".
               
    PAUSE 2 NO-MESSAGE.
    
    ASSIGN aux_cdsequen = 1
           aux_nmarquiv = STRING(crapcop.cdagebcb,"9999")  +
                          SUBSTRING(STRING(YEAR(glb_dtmvtolt)),3,2) + 
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99")   +
                          TRIM(craptab.dstextab)           +
                          ".gps".
           
    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
    /* Header do Arquivo */
    PUT STREAM str_1 UNFORMATTED
               "01"
               STRING(aux_cdsequen,"9999999")
               "756"
               "00000001"
               STRING(YEAR(tel_dtmvtolt),"9999")
               STRING(YEAR(glb_dtmvtolt),"9999")
               STRING(MONTH(glb_dtmvtolt),"99")
               STRING(DAY(glb_dtmvtolt),"99")
               "756-DF"
               "FARRSCF10"
               "105"
               FILL("0",98)
               "99"
               SKIP.
               
    IF   glb_cddopcao = "G"   THEN
         aux_cdforcap = 05.
         
    FOR EACH crawlgp NO-LOCK,
        FIRST crapcgp WHERE
              crapcgp.cdcooper = glb_cdcooper       AND 
              crapcgp.cdidenti = crawlgp.cdidenti   AND
              crapcgp.cddpagto = crawlgp.cddpagto   NO-LOCK      
              BY crawlgp.cdagenci
                 BY crawlgp.nrdolote
                    BY crawlgp.vlrdinss: 

        FIND crapgps WHERE crapgps.cddpagto = crawlgp.cddpagto NO-LOCK NO-ERROR.
        
        IF   glb_cddopcao = "B"   THEN
             aux_cdforcap = IF  AVAILABLE crapgps THEN
                                crapgps.cdforcap
                            ELSE 0.

        ASSIGN aux_cdsequen = aux_cdsequen + 1
               aux_vltotarq = aux_vltotarq + crawlgp.vlrtotal.
   
        /* Detalhe do arquivo */
        PUT STREAM str_1 UNFORMATTED
                   "03"
                   STRING(aux_cdsequen,"9999999")
                   STRING(crapcop.cdcrdarr,"99999999")
                   STRING(YEAR(tel_dtmvtolt),"9999")
                   STRING(MONTH(tel_dtmvtolt),"99")
                   STRING(DAY(tel_dtmvtolt),"99")
                   STRING(crawlgp.cddpagto,"9999")          
                   STRING(SUBSTR(STRING(crawlgp.mmaacomp,"999999"),3,4),"9999")
                   STRING(SUBSTR(STRING(crawlgp.mmaacomp,"999999"),1,2),"99")
                   STRING(crawlgp.cdidenti,"99999999999999")
                   STRING(crawlgp.vlrdinss * 100,"99999999999999")
                   STRING(crawlgp.vlrouent * 100,"99999999999999") 
                   STRING(crawlgp.vlrjuros * 100,"99999999999999")
                   STRING(crawlgp.vlrtotal * 100,"99999999999999") 
                   STRING(aux_cdforcap,"99")
                   FILL(" ",10)
                   STRING(crawlgp.tpcontri,"9")
                   FILL(" ",24)
                   "0"
                   "0"
                   "0000"
                   "99"
                   SKIP.
    END.

    /* Trailer do arquivo */
    ASSIGN aux_cdsequen = aux_cdsequen + 1.

    PUT STREAM str_1 UNFORMATTED
               "99"
               STRING(aux_cdsequen,"9999999")
               STRING(aux_cdsequen - 2,"9999999")
               STRING(aux_vltotarq * 100,"999999999999999999")
               FILL("0",114)
               "99"
               SKIP.                    

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                      " > /micros/" + crapcop.dsdircop + 
                      "/bancoob/" + aux_nmarquiv + " 2>/dev/null").

    UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                      " salvar 2>/dev/null").
 
    DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
       IF   glb_cddopcao <> "G"   THEN
            FOR EACH crapage WHERE
                     crapage.cdcooper  = glb_cdcooper        AND
                     crapage.cdagenci >= tel_cdagenci        AND
                     crapage.cdagenci <= aux_cdagefim        NO-LOCK:
            
                DO aux_contador = 1 TO 10:
        
                   FIND craptab WHERE
                        craptab.cdcooper = glb_cdcooper       AND
                        craptab.nmsistem = "CRED"             AND
                        craptab.tptabela = "GENERI"           AND
                        craptab.cdempres = 00                 AND
                        craptab.cdacesso = "HRGUIASGPS"       AND
                        craptab.tpregist = crapage.cdagenci
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                     INPUT "banco",
                                                     INPUT "craptab",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                NEXT.
                             END.
                        ELSE
                             DO:
                                glb_cdcritic = 55.
                                LEAVE.
                             END.    
                   ELSE
                        glb_cdcritic = 0.
               
                   LEAVE.
                END.  /*  Fim do DO .. TO  */

                IF   glb_cdcritic > 0   THEN
                     RETURN.

                ASSIGN aux_cdsituac = 1
                       aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))
                  
                       craptab.dstextab = STRING(aux_cdsituac,"9") + " " +
                                          STRING(aux_nrdahora,"99999").

                RELEASE craptab.
            END.
       
       /* Atualiza o sequencial do arquivo */
       DO aux_contador = 1 TO 10:

          FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "GENERI"       AND
                             craptab.cdempres = 0              AND
                             craptab.cdacesso = "ARQRETINSS"   AND
                             craptab.tpregist = 99
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craptab   THEN
               IF   LOCKED craptab   THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                             INPUT "banco",
                                             INPUT "craptab",
                                             OUTPUT par_loginusr,
                                             OUTPUT par_nmusuari,
                                             OUTPUT par_dsdevice,
                                             OUTPUT par_dtconnec,
                                             OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                      " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 55.
                        LEAVE.
                    END.    
          ELSE
               glb_cdcritic = 0.

          LEAVE.

       END.  /*  Fim do DO .. TO  */

       IF   glb_cdcritic > 0 THEN
            RETURN.

       ASSIGN craptab.dstextab = STRING(INT(craptab.dstextab) + 1).
                        
    END. /* TRANSACTION */

END PROCEDURE.


PROCEDURE atualiza_controle_operador.

  FIND craptab WHERE
       craptab.cdcooper = glb_cdcooper         AND
       craptab.nmsistem = "CRED"               AND       
       craptab.tptabela = "GENERI"             AND
       craptab.cdempres = crapcop.cdcooper     AND       
       craptab.cdacesso = "MOVGPS"             AND
       craptab.tpregist = 1  
       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

  IF   AVAIL craptab THEN      
       DO:
          ASSIGN craptab.dstextab = " ".
          RELEASE craptab.
       END.

END PROCEDURE.

PROCEDURE atualiza_lancamentos.

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando lancamentos gerados ...".

   DO TRANSACTION:
      FOR EACH crawlgp NO-LOCK:
          FIND craplgp WHERE
               craplgp.cdcooper = glb_cdcooper        AND
               craplgp.cdcooper = crapcop.cdcooper    AND   
               craplgp.dtmvtolt = tel_dtmvtolt        AND
               craplgp.cdagenci = crawlgp.cdagenci    AND
               craplgp.cdbccxlt = crawlgp.cdbccxlt    AND
               craplgp.nrdolote = crawlgp.nrdolote    AND
               craplgp.cdidenti = crawlgp.cdidenti    AND         
               craplgp.cddpagto = crawlgp.cddpagto    AND      
               craplgp.mmaacomp = crawlgp.mmaacomp    AND
               craplgp.vlrtotal = crawlgp.vlrtotal    EXCLUSIVE-LOCK.
          ASSIGN craplgp.flgenvio = YES.
      END.     
   END.
   
END PROCEDURE.


PROCEDURE atualiza_lancamentos_regerar:

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando lancamentos gerados ...".

   FOR EACH craplgp WHERE
            craplgp.cdcooper  = glb_cdcooper     AND 
            craplgp.dtmvtolt  = tel_dtmvtolt     AND
            craplgp.cdagenci >= tel_cdagenci     AND
            craplgp.cdagenci <= aux_cdagefim     AND
            craplgp.idsicred  = 0                AND /** GPS Bancoob **/
            craplgp.nrseqagp  = 0                AND
            craplgp.flgenvio  = YES
        AND craplgp.flgativo  = YES              NO-LOCK:
                            
       FIND crablgp WHERE RECID(crablgp) = RECID(craplgp) 
                          EXCLUSIVE-LOCK NO-ERROR.
       IF   AVAIL crablgp THEN
            DO:
                ASSIGN crablgp.flgenvio = FALSE.
                RELEASE crablgp.
            END.
   END.

END PROCEDURE.


PROCEDURE verifica_pendencias:

     FIND FIRST    crapatr  WHERE 
                            crapatr.cdcooper = glb_cdcooper         AND
                            crapatr.cdrefere = crapcgp.cdidenti     AND
                            crapatr.cdhistor = 585                  AND
                            crapatr.dtfimatr = ?                    AND
                            crapatr.nrdconta = crapcgp.nrctadeb  
                            NO-LOCK NO-ERROR.
                  
          IF  NOT AVAIL crapatr THEN
              DO:
                  ASSIGN crawcgp.cdobserv = "*"
                         crawcgp.dsobserv = "Autorizacao nao cadastrada"
                         aux_verpende     = TRUE.
                  NEXT.
              END.    
                  
          RUN  dbo/b1crap82.p PERSISTENT SET h-b1crap82.
          
          RUN  valida-valor-entidades
               /** Parametro agencia 999 p/diferenciar do caixa on-line **/
               IN h-b1crap82(INPUT  STRING(glb_nmrescop),
                             INPUT  999, 
                             INPUT  0,
                             INPUT  DEC(crapcgp.cddpagto),
                             INPUT  crapcgp.vloutent,
                             OUTPUT aux_dsobserv,  
                             OUTPUT aux_verdbaut).
                                  
          IF  aux_verdbaut = TRUE  THEN
              DO: 
                  ASSIGN crawcgp.cdobserv = "*"
                         crawcgp.dsobserv = aux_dsobserv
                         aux_verpende     = TRUE.
              END.
                                 
          IF  aux_verdbaut = FALSE THEN
              DO:    
                  RUN  valida-atm-juros
                      /** Agencia 999 p/diferenciar do caixa on-line **/ 
                      IN h-b1crap82 (INPUT  STRING(glb_nmrescop),
                                     INPUT  999,
                                     INPUT  0,
                                     INPUT  crapcgp.cddpagto,
                                     INPUT  MONTH(glb_dtultdma),
                                     INPUT  YEAR(glb_dtultdma),
                                     INPUT  crapcgp.vlrjuros,
                                     INPUT  crapcgp.inpessoa,
                                     OUTPUT aux_dsobserv,
                                     OUTPUT aux_verdbaut).
                             
                      IF  aux_verdbaut = TRUE  THEN
                          DO: 
                              ASSIGN crawcgp.cdobserv = "*"
                                     crawcgp.dsobserv = aux_dsobserv 
                                     aux_verpende     = TRUE.
                          END.                             
              END.
                         
          DELETE PROCEDURE h-b1crap82.
                 
END PROCEDURE.

PROCEDURE imprime_d:

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                            
    HIDE FRAME f_opcao_d.
    HIDE FRAME f_rel_debito.

    HIDE MESSAGE NO-PAUSE.


    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        aux_confirma = "N".
        MESSAGE COLOR NORMAL "Deseja Imprimir relatorio? (S/N):" 
        UPDATE aux_confirma.
        LEAVE.
    END.
               
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
              glb_cdcritic = 79.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              NEXT.
         END.
        
    IF   aux_confirma = "S"   THEN
         DO:         
             ASSIGN glb_cdcritic    = 0
                    glb_nrdevias    = 1
                    glb_cdempres    = 11
                    glb_cdrelato[1] = 490. 

             INPUT THROUGH basename `tty` NO-ECHO.
             SET aux_nmendter WITH FRAME f_terminal.
             INPUT CLOSE. 

             aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                   aux_nmendter.

             UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

             ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
  
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

             { includes/cabrel132_1.i }

             VIEW STREAM str_1 FRAME f_cabrel132_1.
        
             ASSIGN tot_quantida = 0
                    tot_vlrdinss = 0
                    tot_vloutent = 0
                    tot_vlrjuros = 0
                    tot_vlrtotal = 0.
        
             FOR EACH crawcgp: 
                                               
                 DISP STREAM str_1 crawcgp.cdobserv 
                                   crawcgp.cdidenti 
                                   crawcgp.cddpagto 
                                   crawcgp.nrctadeb
                                   crawcgp.vlrdinss
                                   crawcgp.vloutent
                                   crawcgp.vlrjuros
                                   crawcgp.vlrtotal
                                   crawcgp.dsobserv
                                   WITH FRAME f_imprim_d. 
                   
                 DOWN WITH FRAME f_imprim_d.
                 
                 ASSIGN tot_quantida = tot_quantida + 1
                        tot_vlrdinss = tot_vlrdinss + crawcgp.vlrdinss
                        tot_vloutent = tot_vloutent + crawcgp.vloutent
                        tot_vlrjuros = tot_vlrjuros + crawcgp.vlrjuros
                        tot_vlrtotal = tot_vlrtotal + crawcgp.vlrtotal.
             
             END.
             
             DOWN WITH FRAME f_imprim_d.
             
             /* Totalizadores */      
             DISP STREAM str_1 tot_quantida
                               tot_vlrdinss
                               tot_vloutent
                               tot_vlrjuros
                               tot_vlrtotal
                               WITH FRAME f_imprim_total_d.
                   
                 OUTPUT STREAM str_1 CLOSE.
                 /*somente para poder executar a includes/impressao.i */
                 FIND FIRST crapass WHERE  crapass.cdcooper = glb_cdcooper 
                                           NO-LOCK NO-ERROR.

             { includes/impressao.i }
         END.

END PROCEDURE.


