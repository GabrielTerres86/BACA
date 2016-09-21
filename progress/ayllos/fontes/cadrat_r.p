/* .............................................................................

   Programa: Fontes/cadrat_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Julho/2004                     Ultima Atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Emitir os Parametros cadrat      

   ALTERACAO : 20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
............................................................................ */
DEF STREAM str_1.  /*Relatorio*/

{ includes/var_online.i }

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
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF   VAR rel_nmresemp AS CHAR                                       NO-UNDO.
DEF   VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.

DEF   VAR aux_vlrnota  AS DEC     FORMAT "zzz9.99"                   NO-UNDO.
DEF   VAR aux_dspessoa AS CHAR    FORMAT "x(16)"                     NO-UNDO.
DEF   VAR aux_dsativo  AS CHAR    FORMAT "x(10)"                     NO-UNDO.

DEF   VAR aux_risco    AS CHAR    FORMAT "x(02)"                NO-UNDO.
DEF   VAR aux_provisao AS DEC     FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_nota_de  AS DEC     FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_nota_ate AS DEC     FORMAT "zz9.99"               NO-UNDO.
DEF   VAR aux_parecer  AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF   VAR aux_dsdrisco AS CHAR    FORMAT "x(02)"    EXTENT 20   NO-UNDO.
DEF   VAR aux_percentu AS DEC     FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF   VAR aux_notadefi AS DEC     FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF   VAR aux_notatefi AS DEC     FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF   VAR aux_parecefi AS CHAR    FORMAT "x(15)"    EXTENT 20   NO-UNDO.
DEF   VAR aux_notadeju AS DEC     FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF   VAR aux_notateju AS DEC     FORMAT "zz9.99"   EXTENT 20   NO-UNDO.
DEF   VAR aux_pareceju AS CHAR    FORMAT "x(15)"    EXTENT 20   NO-UNDO.

FORM SKIP(1)
     craptor.nrtopico           
     craptor.dstopico           
     aux_dspessoa
     aux_dsativo  
     WITH NO-BOX DOWN  WIDTH 132 NO-LABELS FRAME f_relat_top.
     
FORM SKIP(1)
     "                  "       AT  1
     "  PESO    NOTA    "       AT 60
     crapitr.nritetop           AT  3    
     crapitr.dsitetop           
     crapitr.pesoitem           AT 60
     SKIP
     WITH NO-BOX DOWN   WIDTH 132 NO-LABELS FRAME f_relat_ite.

FORM crapsir.nrseqite   AT 6    
     crapsir.dsseqite
     crapsir.pesosequ   AT 60
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
      WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_classificacao.

FORM " " AT 1
     " " AT 1
     "TABELA : CLASSIFICACAO GERAL DO RATING DE PESSOA "  AT 1
     aux_dspessoa                                    
     " " AT 1
     WITH NO-BOX DOWN WIDTH 132 NO-LABELS FRAME f_cab_classificacao.

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

FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND 
                       craptab.tptabela = "GENERI"     AND 
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "PROVISAOCL" NO-LOCK:
                             
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


FOR  EACH craptor WHERE craptor.cdcooper = glb_cdcooper  NO-LOCK,
     EACH crapitr NO-LOCK WHERE crapitr.cdcooper = glb_cdcooper 
                            AND crapitr.nrtopico = craptor.nrtopico,
     EACH crapsir NO-LOCK WHERE crapsir.cdcooper = glb_cdcooper
                            AND crapsir.nrtopico = craptor.nrtopico 
                            AND crapsir.nritetop = crapitr.nritetop
          BREAK BY craptor.inpessoa
                   BY craptor.nrtopico
                      BY crapitr.nritetop 
                         BY crapsir.nrseqite.
                   
          IF   FIRST-OF(craptor.nrtopico)  THEN
               DO:
                  IF  craptor.inpessoa = 1 THEN 
                      ASSIGN aux_dspessoa = "Pessoa Fisica".
                  ELSE 
                      ASSIGN aux_dspessoa = "Pessoa Juridica".
                                
                  IF  craptor.flgativo = YES THEN
                      ASSIGN aux_dsativo = "Ativo".
                  ELSE
                      ASSIGN aux_dsativo = "Inativo".
                      
                  DISPLAY STREAM str_1
                          craptor.nrtopico
                          craptor.dstopico
                          aux_dspessoa     
                          aux_dsativo
                          WITH FRAME f_relat_top.     
               END.   
          
          IF   FIRST-OF(crapitr.nritetop)   THEN
               DISPLAY STREAM str_1
                       crapitr.nritetop
                       crapitr.dsitetop
                       crapitr.pesoitem
                       WITH FRAME f_relat_ite.     

          ASSIGN aux_vlrnota = crapitr.pesoitem * crapsir.pesosequ.
          DISPLAY STREAM str_1
                  crapsir.pesosequ
                  crapsir.nrseqite
                  crapsir.dsseqite
                  aux_vlrnota
                  WITH FRAME f_relat_seq.
          DOWN STREAM str_1 WITH FRAME f_relat_seq.


          IF   LAST-OF(craptor.inpessoa)  THEN
               RUN lista_tabela_classificacao.
               

END.
         
OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrdevias = 1
       par_flgrodar = TRUE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
       
{ includes/impressao.i }


PROCEDURE lista_tabela_classificacao.

IF  craptor.inpessoa = 1 THEN    
    ASSIGN aux_dspessoa = "FISICA".
ELSE
    
    ASSIGN aux_dspessoa = "JURIDICA".

DISPLAY STREAM str_1
        aux_dspessoa 
        WITH FRAME f_cab_classificacao.
DOWN STREAM str_1 WITH FRAME f_cab_classificacao.


DISPLAY STREAM str_1 
        "RISCO"    @ aux_risco                  
        "NOTA "    @ aux_nota_de                 
        " "        @ aux_nota_ate               
        "PROVISAO" @ aux_provisao              
        " "        @  aux_parecer                 
        WITH FRAME f_classificacao.
DOWN STREAM str_1 WITH FRAME f_classificacao.

ASSIGN aux_contador = 1.
DO  WHILE aux_contador LE 20:
    
    IF  aux_dsdrisco[aux_contador] = " " THEN LEAVE.
    
    ASSIGN aux_risco    = aux_dsdrisco[aux_contador]
           aux_provisao = aux_percentu[aux_contador].
    
    IF  craptor.inpessoa = 1 THEN
        ASSIGN aux_nota_de  = aux_notadefi[aux_contador]
               aux_nota_ate = aux_notatefi[aux_contador]
               aux_parecer  = aux_parecefi[aux_contador].
    ELSE
        ASSIGN aux_nota_de  = aux_notadeju[aux_contador]
               aux_nota_ate = aux_notateju[aux_contador]
               aux_parecer  = aux_pareceju[aux_contador].

    DISPLAY STREAM str_1 
            aux_risco                  
            aux_nota_de                 
            aux_nota_ate               
            aux_provisao              
            aux_parecer                 
            WITH FRAME f_classificacao.
    DOWN STREAM str_1 WITH FRAME f_classificacao.
    ASSIGN aux_contador = aux_contador + 1.
END.

PAGE   STREAM str_1.

END PROCEDURE.



/*...........................................................................*/
