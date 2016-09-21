/* ..........................................................................

   Programa: Fontes/conbdc_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Novembro/2004.                  Ultima atualizacao: 20/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir rel.Borderos que tiverem o percentual de cheques
               excedidos no contrato.(Relatorio 377)
               
   Alteracoes: 20/09/2005 - Alterado para fazer leitura tbm do codigo da
                            cooperativa na tabela crapabc, e modificado FIND
                            FIRST para FIND na tabela crapcop.cdcooper =       
                            glb_cdcooper (Diego). 

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               22/01/2007 - Substituido formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).
               
               10/01/2011 - Alterado o format de 40 para 50 no campo nmprimtl
                            (Kbase - Gilnei).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               26/11/2013 - Alterado aux_linha1 de "CPF/CGC" para "CPF/CNPJ".
                            (Reinert).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               20/06/2016 - Alteracao das descricoes das restricoes, campo
                            dsrestri do FOR EACH da gera_movtos_pesquisa.
                            (Jaison/James)

............................................................................. */
DEF STREAM str_1.
                     
DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.

{ includes/var_online.i }

DEF   VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF   VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.

DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                     NO-UNDO.

DEF   VAR res_nrctremp AS INT                                        NO-UNDO.
DEF   VAR res_dslinhas AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR aux_cdagefim LIKE craptvl.cdagenci                         NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_vltotemi AS DEC                                        NO-UNDO.
DEF   VAR aux_percentu AS DEC                                        NO-UNDO.

DEF  VAR aux_vltotcdb AS DEC                                   NO-UNDO.
DEF  VAR aux_qtdevchq AS INTE                                  NO-UNDO.
DEF  VAR aux_vlutlcpf AS DEC                                   NO-UNDO.
DEF  VAR aux_dscpfcgc AS CHAR    FORMAT "x(14)"                NO-UNDO.

DEF  VAR aux_linha1   AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF  VAR aux_linha2   AS CHAR    FORMAT "x(14)"                NO-UNDO.
DEF  var aux_linha3   AS CHAR    FORMAT "x"                    NO-UNDO.
DEF  VAR aux_linha4   AS CHAR    FORMAT "x(78)"                NO-UNDO.


DEF    TEMP-TABLE w_movtos                                     NO-UNDO 
           FIELD nrdconta LIKE crapass.nrdconta
           FIELD nrborder LIKE crapbdc.nrborder
           FIELD vllimite LIKE craplim.vllimite
           FIELD percentu AS DEC  
           FIELD cdagenci LIKE crapass.cdagenci
           FIELD dtlibbdc LIKE crapbdc.dtlibbdc
           FIELD insitbdc LIKE crapbdc.insitbdc
           FIELD vltotcdb   AS DEC
           FIELD nrcpfcgc LIKE crapabc.nrcpfcgc
           FIELD qtdevchq   AS INTE
           FIELD dsrestri   AS CHAR FORMAT "x(90)"
           FIELD vlutlcpf   AS DEC
           INDEX w_movtos1
                 cdagenci
                 nrdconta
                 nrborder.

FORM  "                         "               
      aux_linha1
      aux_linha2
      aux_linha3
      aux_linha4
      WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_linha.

FORM 
"PA  DATA            CONTA NOME                                               BORDERO        LIMITE" aux_linha3 SKIP
"--- ---------- ---------- -------------------------------------------------- ------- -------------"
 WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_cab.


FORM  w_movtos.cdagenci   
      w_movtos.dtlibbdc    FORMAT "99/99/9999"    
      w_movtos.nrdconta   
      crapass.nmprimtl    
      w_movtos.nrborder    FORMAT "zzzzzz9"
      w_movtos.vllimite    FORMAT "zz,zzz,zz9.99"
      WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_relat.

      
/* Busca dados da cooperativa */

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
       glb_cdrelato[1] = 377.
       
ASSIGN aux_cdagefim    = IF par_cdagenci = 0  
                         THEN 9999
                         ELSE par_cdagenci.
                         
{ includes/cabrel132_1.i }

aux_nmarqimp = "rl/O377_" + STRING(TIME,"99999") + ".lst".

HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... Imprimindo relatorio!".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 aux_linha3 WITH FRAME f_cab.
      

RUN gera_movtos_pesquisa.

FOR EACH w_movtos NO-LOCK , 
    FIRST crapage WHERE crapage.cdcooper = glb_cdcooper         AND
                        crapage.cdagenci = w_movtos.cdagenci    NO-LOCK,
    FIRST crapass WHERE crapass.cdcooper = glb_cdcooper         AND
                        crapass.nrdconta = w_movtos.nrdconta    NO-LOCK 
                        BREAK BY w_movtos.cdagenci
                                 BY w_movtos.dtlibbdc
                                    BY w_movtos.nrdconta 
                                       BY w_movtos.nrborder 
                                          BY w_movtos.nrcpfcgc
                                             BY w_movtos.dsrestri:
       
     IF   LINE-COUNTER(str_1) > 80  THEN
          DO:
             PAGE STREAM str_1.
                       
             DISPLAY STREAM str_1 aux_linha3   WITH FRAME f_cab.
          END.

     IF  FIRST-OF(w_movtos.cdagenci) OR
         FIRST-OF(w_movtos.dtlibbdc) OR
         FIRST-OF(w_movtos.nrdconta) OR
         FIRST-OF(w_movtos.nrborder) THEN
         DO:
            DISPLAY STREAM str_1
                           " " @ w_movtos.cdagenci   
                           " " @ w_movtos.dtlibbdc
                           " " @ w_movtos.nrdconta
                           " " @ crapass.nmprimtl
                           " " @ w_movtos.nrborder
                           " " @ w_movtos.vllimite
                           WITH FRAME f_relat.
            DOWN STREAM str_1 WITH FRAME f_relat.              
 
            DISPLAY STREAM str_1  
                           w_movtos.cdagenci    
                           w_movtos.dtlibbdc    
                           w_movtos.nrdconta    
                           crapass.nmprimtl
                           w_movtos.nrborder    
                           w_movtos.vllimite    
                           WITH FRAME f_relat.  
            DOWN STREAM str_1 WITH FRAME f_relat.  
            
         END.
                          
     IF  FIRST-OF(w_movtos.nrcpfcgc)  OR
         FIRST-OF(w_movtos.dsrestri) THEN
         DO:

     IF  w_movtos.dsrestri BEGINS "Perc" THEN
         ASSIGN w_movtos.dsrestri = " "
                w_movtos.dsrestri = 
                "Percentual de cheques do emitente excedido "
                w_movtos.dsrestri =
                TRIM(w_movtos.dsrestri) +  " Vlr. "  +
                TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")) +
                " Perc. " + 
                TRIM(STRING(w_movtos.percentu,"zz9.99")).
     ELSE
     IF  w_movtos.dsrestri BEGINS "Quan" THEN
         ASSIGN w_movtos.dsrestri = " "
                w_movtos.dsrestri = "Quantidade cheques devol. excedido "
                w_movtos.dsrestri =                  
                TRIM(w_movtos.dsrestri) + " Vlr. " +
                TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")) +
                " Qtd. " + 
                TRIM(STRING(w_movtos.qtdevchq,"zzz9")).
     ELSE
     IF  w_movtos.dsrestri BEGINS "Valor maximo por contrato excedido." THEN
         ASSIGN w_movtos.dsrestri =
                           TRIM(w_movtos.dsrestri) + " Vlr. " +
                           TRIM(STRING(w_movtos.vltotcdb,"zz,zzz,zz9.99")).
     ELSE
     IF  w_movtos.dsrestri BEGINS "Valor maximo permitido por emitente excedido."  THEN
         ASSIGN w_movtos.dsrestri =
                           TRIM(w_movtos.dsrestri) + " Vlr. " +
                           TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")).

    IF   LENGTH(TRIM(STRING(w_movtos.nrcpfcgc))) > 11   THEN
         DO:
             ASSIGN aux_dscpfcgc = STRING(w_movtos.nrcpfcgc,"99999999999999")
                    aux_dscpfcgc = STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
         END.
    ELSE
         DO:
            ASSIGN glb_nrcalcul = w_movtos.nrcpfcgc.
            
            RUN fontes/cpffun.p.
           
            IF   glb_stsnrcal   THEN
                 ASSIGN aux_dscpfcgc = STRING(w_movtos.nrcpfcgc,"99999999999")
                        aux_dscpfcgc = STRING(aux_dscpfcgc,"xxx.xxx.xxx-xx").
            ELSE
                ASSIGN aux_dscpfcgc = STRING(w_movtos.nrcpfcgc,"99999999999999")
                       aux_dscpfcgc = STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
         END.        

     
         ASSIGN aux_linha1 = "CPF/CNPJ - "
                aux_linha2 = aux_dscpfcgc
                aux_linha3 = " "
                aux_linha4 = w_movtos.dsrestri.
         DISPLAY  STREAM str_1 
                  aux_linha1
                  aux_linha2                
                  aux_linha3
                  aux_linha4  WITH FRAME f_linha.
         DOWN WITH FRAME f_linha. 

     END.       
   END.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

MESSAGE "Retire o relatorio da impressora!".


PROCEDURE gera_movtos_pesquisa.

   /*FOR EACH w_movtos:
       DELETE w_movtos.
   END.*/
     
   EMPTY TEMP-TABLE w_movtos.   
      
   FOR EACH   crapbdc WHERE crapbdc.cdcooper  = glb_cdcooper AND
                            crapbdc.dtlibbdc <> ?            AND
                            crapbdc.dtlibbdc >= par_dtmvtolt NO-LOCK, 
       FIRST  crapass WHERE crapass.cdcooper  = glb_cdcooper     AND
                            crapass.nrdconta  = crapbdc.nrdconta AND
                            crapass.cdagenci >= par_cdagenci     AND
                            crapass.cdagenci <= aux_cdagefim     NO-LOCK,
        
      FIRST  craplim WHERE craplim.cdcooper   = glb_cdcooper       AND
                           craplim.nrdconta   = crapass.nrdconta   AND
                           craplim.nrctrlim   = crapbdc.nrctrlim   AND
                           craplim.tpctrlim   = 2                  AND
                           craplim.insitlim   = 2                  NO-LOCK:

       /* Valor maximo por contrato excedido */
       aux_vltotcdb = 0.
       
       FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                              crapcdb.nrdconta = crapbdc.nrdconta   AND
                              crapcdb.insitchq = 2                  AND
                              crapcdb.dtlibera > crapbdc.dtlibbdc   NO-LOCK:
           
            aux_vltotcdb = aux_vltotcdb + crapcdb.vlcheque.
       END.
           
               
       FOR EACH crapabc WHERE 
                crapabc.cdcooper = glb_cdcooper                           AND
                crapabc.nrborder = crapbdc.nrborder                       AND
                crapabc.nrdconta = crapass.nrdconta                       AND
                crapabc.nrcpfcgc > 0                                      AND
              ((crapabc.dsrestri = "Valor maximo permitido por emitente excedido."            OR
                crapabc.dsrestri = "Percentual de cheques do emitente excedido no contrato."  OR
                crapabc.dsrestri = "Valor maximo por contrato excedido."  OR
                crapabc.dsrestri = "Quantidade maxima de cheques devolvidos por emitente excedida"))
                NO-LOCK    
                BREAK BY crapabc.nrcpfcgc:
               
            IF  FIRST-OF(crapabc.nrcpfcgc) THEN
                DO:
                   
                   ASSIGN aux_vlutlcpf = 0.
                 
                   FOR EACH crapcdb WHERE
                            crapcdb.cdcooper = glb_cdcooper       AND
                            crapcdb.nrborder = crapbdc.nrborder   AND
                            crapcdb.nrdconta = crapbdc.nrdconta   AND
                            crapcdb.dtdevolu = ?                  AND
                            crapcdb.nrcpfcgc = crapabc.nrcpfcgc   NO-LOCK:
                        ASSIGN aux_vlutlcpf =
                               aux_vlutlcpf + crapcdb.vlcheque.    
                   END.
 
                   aux_qtdevchq = 0.
                   FOR EACH crapcec WHERE crapcec.cdcooper = glb_cdcooper AND
                                          crapcec.nrcpfcgc = crapabc.nrcpfcgc
                                          NO-LOCK :
                       ASSIGN aux_qtdevchq   = aux_qtdevchq +
                                               crapcec.qtchqdev.
                   END.
                END.    
               
                ASSIGN aux_percentu = 
                       ((aux_vlutlcpf / craplim.vllimite) * 100).
      
                CREATE w_movtos.
                ASSIGN w_movtos.nrdconta = crapass.nrdconta
                       w_movtos.nrborder = crapbdc.nrborder
                       w_movtos.vllimite = craplim.vllimite
                       w_movtos.percentu = aux_percentu
                       w_movtos.cdagenci = crapass.cdagenci
                       w_movtos.dtlibbdc = crapbdc.dtlibbdc
                       w_movtos.insitbdc = crapbdc.insitbdc
                       w_movtos.vltotcdb = aux_vltotcdb
                       w_movtos.nrcpfcgc = crapabc.nrcpfcgc
                       w_movtos.qtdevchq = aux_qtdevchq
                       w_movtos.dsrestri = crapabc.dsrestri
                       w_movtos.vlutlcpf = aux_vlutlcpf.
          END. /* for each crapabc */
   END.

END PROCEDURE.




/* .......................................................................... */


