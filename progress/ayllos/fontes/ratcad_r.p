/* .............................................................................

   Programa: Fontes/ratcad_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Fernando   
   Data    : Setembro/2009                     Ultima Atualizacao: 29/05/2014 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Emitir os Parametros dos itens do rating.      

   Alteracao :
   
            03/03/2010 - Modificado para listar os itens de avaliacao do
                         cooperado, seguido dos itens de avaliacao da
                         operacao. Incluido tabela de classificacao do
                         cooperado. Substituido a palavra RATING da tabela de
                         Classificacao Geral por (Cooperado + Operacao).
                         Realizado alteracoes na procedure 
                         lista_tabela_classificacao.(Fabricio)
                         
           29/05/2014 - Concatena o numero do servidor no endereco do
                        terminal (Tiago-RKAM).
    
............................................................................ */
DEF STREAM str_1.  /*Relatorio*/

{ includes/var_online.i }

/* variaveis para impressao */
DEF   VAR rel_nmrelato AS CHAR    FORMAT "x(40)"    EXTENT 5    NO-UNDO.
DEF   VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF   VAR rel_nrmodulo AS INTE    FORMAT "9"                    NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)"    EXTENT 5
                         INIT ["DEP. A VISTA   ","CAPITAL        ",
                               "EMPRESTIMOS    ","DIGITACAO      ",
                               "GENERICO       "]               NO-UNDO.
DEF   VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF   VAR par_flgrodar AS LOGI    INIT TRUE                     NO-UNDO.
DEF   VAR par_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF   VAR par_flgcance AS LOGI                                  NO-UNDO.
DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF   VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF   VAR aux_contador AS INTE                                  NO-UNDO.

DEF   VAR rel_nmresemp AS CHAR                                  NO-UNDO.
DEF   VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF   VAR aux_vlrnota  AS DECI    FORMAT "zzz9.99"              NO-UNDO.
DEF   VAR aux_dspessoa AS CHAR    FORMAT "x(16)"                NO-UNDO.
DEF   VAR aux_dspesso2 AS CHAR    FORMAT "x(12)"                NO-UNDO.
DEF   VAR aux_dsativo  AS CHAR    FORMAT "x(10)"                NO-UNDO.

DEF   VAR aux_risco    AS CHAR    FORMAT "x(02)"                NO-UNDO.
DEF   VAR aux_provisao AS DECI    FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_nota_de  AS DECI    FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_nota_ate AS DECI    FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_parecer  AS CHAR    FORMAT "x(15)"                NO-UNDO.

FORM SKIP(1)
     craprat.nrtopico           
     craprat.dstopico           
     aux_dspessoa
     aux_dsativo  
     WITH NO-BOX DOWN  WIDTH 132 NO-LABELS FRAME f_relat_top.
     
FORM SKIP(1)
     "                  "       AT  1
     "  PESO    NOTA    "       AT 60
     craprai.nritetop           AT  3    
     craprai.dsitetop           
     craprai.pesoitem           AT 60
     SKIP
     WITH NO-BOX DOWN   WIDTH 132 NO-LABELS FRAME f_relat_ite.

FORM craprad.nrseqite   AT 6    
     craprad.dsseqite
     craprad.pesosequ   AT 60
     aux_vlrnota
     SKIP
     WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_relat_seq.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM  aux_risco                  
      aux_nota_de                 
      aux_nota_ate               
      aux_provisao              
      aux_parecer                 
      WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_classificacao_geral.

FORM  aux_risco                  
      aux_nota_de                 
      aux_nota_ate                 
      WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_classificacao_cooperado.

FORM " " AT 1
     " " AT 1
     "\033\105\TABELA : CLASSIFICACAO DO COOPERADO - PESSOA\033\106"  AT 1
     aux_dspesso2                                    
     " " AT 1
     WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_cab_classificacao_cooperado.


FORM " " AT 1
     " " AT 1
     "\033\105\TABELA : CLASSIFICACAO GERAL - PESSOA\033\106"  AT 1
     aux_dspesso2 
     "\033\105\(COOPERADO + OPERACAO)\033\106"                                    
     " " AT 1
     WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_cab_classificacao_geral.

FORM "Aguarde... Imprimindo Parametros Rating!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.

CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.

IF   FRAME-VALUE = tel_dscancel   THEN
     DO:
         RETURN.
     END.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 363.

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

ASSIGN aux_risco = " ".

FOR  EACH craprat WHERE craprat.cdcooper = glb_cdcooper     NO-LOCK,

     EACH craprai WHERE craprai.cdcooper = glb_cdcooper     AND
                        craprai.nrtopico = craprat.nrtopico NO-LOCK,

     EACH craprad WHERE craprad.cdcooper = glb_cdcooper     AND
                        craprad.nrtopico = craprat.nrtopico AND 
                        craprad.nritetop = craprai.nritetop NO-LOCK
          BREAK BY craprat.inpessoa
                   BY craprat.intopico
                      BY craprat.nrtopico
                         BY craprai.nritetop 
                            BY craprad.nrseqite.
                   
          IF   FIRST-OF(craprat.nrtopico)  THEN
               DO:
                  IF  craprat.inpessoa = 1 THEN 
                      ASSIGN aux_dspessoa = "Pessoa Fisica".
                  ELSE 
                      ASSIGN aux_dspessoa = "Pessoa Juridica".
                                
                  IF  craprat.flgativo = YES THEN
                      ASSIGN aux_dsativo = "Ativo".
                  ELSE
                      ASSIGN aux_dsativo = "Inativo".
                                             
                  IF craprat.intopico = 1 THEN
                    DISPLAY STREAM str_1 "\033\105\AVALIACAO DO COOPERADO\033\106" AT 1.
                  ELSE
                    DISPLAY STREAM str_1 "\033\105\AVALIACAO DA OPERACAO\033\106"  AT 1.
                      
                  DISPLAY STREAM str_1
                          craprat.nrtopico
                          craprat.dstopico
                          aux_dspessoa     
                          aux_dsativo
                          WITH FRAME f_relat_top.     
               END.   
          
          IF   FIRST-OF(craprai.nritetop)   THEN
               DISPLAY STREAM str_1
                       craprai.nritetop
                       craprai.dsitetop
                       craprai.pesoitem
                       WITH FRAME f_relat_ite.     

          ASSIGN aux_vlrnota = craprai.pesoitem * craprad.pesosequ.

          DISPLAY STREAM str_1
                  craprad.pesosequ
                  craprad.nrseqite
                  craprad.dsseqite
                  aux_vlrnota
                  WITH FRAME f_relat_seq.

          DOWN STREAM str_1 WITH FRAME f_relat_seq.

          IF   LAST-OF(craprat.inpessoa)  THEN
            DO:
                RUN lista_tabela_classificacao(INPUT "PROVISAOTL", 0).
                RUN lista_tabela_classificacao(INPUT "PROVISAOCL", 1).
            END.

END.
         
OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrdevias = 1
       par_flgrodar = TRUE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.       
{ includes/impressao.i }


PROCEDURE lista_tabela_classificacao:

    DEF   INPUT PARAMETER par_cdacesso LIKE craptab.cdacesso        NO-UNDO.
    DEF   INPUT PARAMETER par_setaFrame AS INT                      NO-UNDO. 
    DEF   VAR aux_dsdrisco AS CHAR    FORMAT "x(02)"    EXTENT 20   NO-UNDO.
    DEF   VAR aux_percentu AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
    DEF   VAR aux_notadefi AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
    DEF   VAR aux_notatefi AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
    DEF   VAR aux_parecefi AS CHAR    FORMAT "x(15)"    EXTENT 20   NO-UNDO.
    DEF   VAR aux_notadeju AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
    DEF   VAR aux_notateju AS DECI    FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
    DEF   VAR aux_pareceju AS CHAR    FORMAT "x(15)"    EXTENT 20   NO-UNDO.
    
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = par_cdacesso NO-LOCK:
                             
        ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
               aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3))
               aux_percentu[aux_contador] = DEC(SUBSTR(craptab.dstextab,1,6))

               aux_notadefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,27,6))
               aux_notatefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,34,6))
               aux_parecefi[aux_contador] = SUBSTR(craptab.dstextab,41,15)

               aux_notadeju[aux_contador] = DEC(SUBSTR(craptab.dstextab,56,6))
               aux_notateju[aux_contador] = DEC(SUBSTR(craptab.dstextab,62,6))
               aux_pareceju[aux_contador] = SUBSTR(craptab.dstextab,70,15).
    END. 

    IF  craprat.inpessoa = 1 THEN    
        ASSIGN aux_dspesso2 = "\033\105\FISICA\033\106".
    ELSE        
        ASSIGN aux_dspesso2 = "\033\105\JURIDICA\033\106".
    
    IF par_setaFrame = 0 THEN /* avaliacao do cooperado */
        DO:
            DISPLAY STREAM str_1
                           aux_dspesso2 
                           WITH FRAME f_cab_classificacao_cooperado.
    
            DOWN STREAM str_1 WITH FRAME f_cab_classificacao_cooperado.

            DISPLAY STREAM str_1 
            "RISCO"    @ aux_risco                  
            "NOTA "    @ aux_nota_de                 
            " "        @ aux_nota_ate                  
            WITH FRAME f_classificacao_cooperado.
    
            DOWN STREAM str_1 WITH FRAME f_classificacao_cooperado.
        END.
    ELSE /* avaliacao geral (cooperado + operacao) */
        DO:
            DISPLAY STREAM str_1
                           aux_dspesso2
                           WITH FRAME f_cab_classificacao_geral.
                           
            DOWN STREAM str_1 WITH FRAME f_cab_classificacao_geral.

            DISPLAY STREAM str_1 
            "RISCO"    @ aux_risco                  
            "NOTA "    @ aux_nota_de                 
            " "        @ aux_nota_ate               
            "PROVISAO" @ aux_provisao              
            " "        @  aux_parecer                 
            WITH FRAME f_classificacao_geral.
    
            DOWN STREAM str_1 WITH FRAME f_classificacao_geral.
        END.
    
    ASSIGN aux_contador = 1.
    
    DO  WHILE aux_contador LE 20:
        
        IF  aux_dsdrisco[aux_contador] = " " THEN LEAVE.
        
        ASSIGN aux_risco    = aux_dsdrisco[aux_contador]
               aux_provisao = aux_percentu[aux_contador].
        
        IF  craprat.inpessoa = 1 THEN
            ASSIGN aux_nota_de  = aux_notadefi[aux_contador]
                   aux_nota_ate = aux_notatefi[aux_contador]
                   aux_parecer  = aux_parecefi[aux_contador].
        ELSE
            ASSIGN aux_nota_de  = aux_notadeju[aux_contador]
                   aux_nota_ate = aux_notateju[aux_contador]
                   aux_parecer  = aux_pareceju[aux_contador].
    
        IF par_setaFrame = 0 THEN /* avaliacao do cooperado */
        DO:
            DISPLAY STREAM str_1 
                    aux_risco                  
                    aux_nota_de                 
                    aux_nota_ate                 
                    WITH FRAME f_classificacao_cooperado.

            DOWN STREAM str_1 WITH FRAME f_classificacao_cooperado.
        END.
        ELSE /* avaliacao geral (cooperado + operacao) */
        DO:
            DISPLAY STREAM str_1 
                    aux_risco                  
                    aux_nota_de                 
                    aux_nota_ate               
                    aux_provisao              
                    aux_parecer                 
                    WITH FRAME f_classificacao_geral.

            DOWN STREAM str_1 WITH FRAME f_classificacao_geral.
        END.

        ASSIGN aux_contador = aux_contador + 1.
    END.
    
    IF par_setaFrame = 1 THEN
        PAGE STREAM str_1.

END PROCEDURE.



/*...........................................................................*/
