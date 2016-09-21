
/* ..........................................................................

   Programa: Fontes/titulo_r2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Julho/2010                   Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de conferencia pagamento titulos via TAA
               Adaptacao do fontes/titulo_r1.p
                                    
   Alteracoes: 06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
   
............................................................................. */

DEF STREAM str_3.

DEFINE TEMP-TABLE crawage                                            NO-UNDO  
       FIELD  cdagenci  LIKE crapage.cdagenci
       FIELD  nmresage  LIKE crapage.nmresage
       FIELD  cdbantit  LIKE crapage.cdbantit.

DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_flgenvio AS LOGICAL                              NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.

DEF VAR aux_vltitulo AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qttitulo AS INTEGER                                      NO-UNDO.
DEF VAR aux_descrica AS CHAR                                         NO-UNDO.

{ includes/var_online.i }

DEF TEMP-TABLE crattit                                               NO-UNDO
    FIELD cdbanco   AS INT     FORMAT "zz9"
    FIELD nrdconta  AS INT     FORMAT "zzzz,zzz,9"
    FIELD qttitulo  AS INT     FORMAT "zzzz9"
    FIELD vltitulo  AS DECIMAL FORMAT "zzz,zz9.99"
    FIELD inpessoa  AS INT.
    
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR pac_dsdtraco AS CHAR    FORMAT "x(77)"                     NO-UNDO.

DEF   VAR pac_qtdlotes AS INT     FORMAT "zz,zz9"                    NO-UNDO.
DEF   VAR pac_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR tot_qtdlotes AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.
                                                             
DEF   VAR ger_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR ger_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR lot_nmoperad AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR tel_dsdlinha AS CHAR                                       NO-UNDO.
DEF   VAR tel_dscodbar AS CHAR    FORMAT "x(44)"                     NO-UNDO.

DEF   VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"                NO-UNDO.
DEF   VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"               NO-UNDO.
DEF   VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"               NO-UNDO.
DEF   VAR tel_nrcampo4 AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR tel_nrcampo5 AS DECIMAL FORMAT "zzzzzzzzzzz999"            NO-UNDO.

DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgabert AS LOGICAL                                    NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR                                  NO-UNDO.

DEF VAR tot_pac_qttitulo AS INT     FORMAT "zzzz9".
DEF VAR tot_pac_vltitulo AS DECIMAL FORMAT "zzz,zz9.99". 
DEF VAR tot_ger_qttitulo AS INT     FORMAT "zzzz9".
DEF VAR tot_ger_vltitulo AS DECIMAL FORMAT "zzz,zz9.99".
DEF VAR tot_ger_qttit    AS INT     FORMAT "zzzz9".
DEF VAR tot_ger_vltit    AS DECIMAL FORMAT "zzz,zz9.99".

DEF VAR aux_nmpessoa AS CHAR FORMAT "x(8)"   NO-UNDO.
DEF VAR aux_vlpessoa AS INT  FORMAT "99,999" NO-UNDO.
DEF VAR aux_vlpesfis AS INT  FORMAT "99,999" NO-UNDO.
DEF VAR aux_vlpesjur AS INT  FORMAT "99,999" NO-UNDO.
DEF VAR aux_cdbanco  AS INT  FORMAT "999"    NO-UNDO.
DEF VAR aux_cdagenci AS INT  FORMAT "99999"  NO-UNDO.
DEF VAR aux_nmbanco  AS CHAR FORMAT "x(13)"  NO-UNDO.
DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)"   NO-UNDO.

FORM  crapass.cdagenci      AT 2  LABEL "PA"
      crattit.nrdconta    AT 5  LABEL "Conta/dv"
      crapass.nmprimtl      AT 16 LABEL "Nome Cooperado" FORMAT "x(39)"
      aux_nmbanco           AT 56 LABEL "Banco"          FORMAT "x(03)"
      crattit.qttitulo    AT 62 LABEL "Qtdade"
      crattit.vltitulo    AT 69 LABEL "Vlr.Total"
      WITH NO-LABELS NO-BOX  WIDTH 80 DOWN FRAME f_titulo.
 
FORM  
      "Total do PA"           AT   44             
      tot_pac_qttitulo        AT   63               NO-LABEL
      tot_pac_vltitulo        AT   69               NO-LABEL
      SKIP(1)
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot_pac.

FORM  SKIP(1)
      "Total Geral"           AT   35               
      aux_nmpessoa            AT   47
      tot_ger_qttitulo        AT   63               NO-LABEL
      tot_ger_vltitulo        AT   69               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot_ger.

FORM  SKIP(1)
      "TOTAL GERAL RELATORIO" AT   34               
      tot_ger_qttitulo        AT   63               NO-LABEL
      tot_ger_vltitulo        AT   69               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot_ger_rel.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1)
     WITH NO-BOX FRAME f_linha.
    
FORM tel_dsdlinha       FORMAT "x(56)"          LABEL "Linha digitavel"
     craptit.vldpagto FORMAT "zzzzzz,zz9.99"  LABEL "Valor Pago"
     craptit.nrseqdig FORMAT "zzzz9"          LABEL "Seq."
     WITH COLUMN 4 NO-LABEL NO-BOX DOWN FRAME f_lanctos.

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
          glb_cdrelato[3] = 565
          pac_dsdtraco    = FILL("-",77).

   { includes/cabrel080_3.i }

   /*  Gerenciamento da impressao  */

   aux_nmarqimp = "rl/O565_" + STRING(TIME,"99999") + ".lst".
       
   HIDE MESSAGE NO-PAUSE.

   MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

   HIDE MESSAGE NO-PAUSE.

   IF   tel_cddopcao = "I" THEN
        DO:
             INPUT THROUGH basename `tty` NO-ECHO.

             SET aux_nmendter WITH FRAME f_terminal.

             INPUT CLOSE.
             
             aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                   aux_nmendter.

             UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").



             MESSAGE "AGUARDE... Imprimindo relatorio!".

             OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

             PUT STREAM str_3 CONTROL "\022\024\033\120" NULL.

             PUT STREAM str_3 CONTROL "\0330\033x0" NULL.
         END.
   ELSE
         OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

   VIEW STREAM str_3 FRAME f_cabrel080_3.

   EMPTY TEMP-TABLE crattit.

   FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper         AND
                          craptit.dtdpagto = par_dtmvtolt         AND
                          CAN-DO("2,4",STRING(craptit.insittit))  AND
                          craptit.tpdocmto = 20                   AND
                          craptit.cdagenci = 91                   AND
                          craptit.flgenvio = par_flgenvio         AND
                          craptit.intitcop = 0                    NO-LOCK
      ,EACH crapass WHERE crapass.cdcooper = craptit.cdcooper     AND
                          crapass.nrdconta = craptit.nrdconta NO-LOCK:
        
        ASSIGN aux_cdbanco  = INT(substr(dscodbar, 1, 3))
               aux_cdagenci = INT(substr(dscodbar, 4, 5)).

        FIND FIRST crattit WHERE crattit.cdbanco  = aux_cdbanco  AND 
                                 crattit.nrdconta = craptit.nrdconta 
                                 NO-LOCK NO-ERROR.
        IF AVAIL crattit THEN
           DO:
                 ASSIGN crattit.vltitulo = crattit.vltitulo + craptit.vldpagto
                        crattit.qttitulo = crattit.qttitulo + 1.
           END.
           ELSE DO:
                CREATE crattit.
                ASSIGN crattit.cdbanco  = aux_cdbanco
                       crattit.nrdconta = craptit.nrdconta
                       crattit.qttitulo = 1
                       crattit.vltitulo = craptit.vldpagto
                       crattit.inpessoa = crapass.inpessoa.
           END.
          
   END.  /*  Fim do FOR EACH  */    

   FOR EACH crattit NO-LOCK
      ,EACH crapass WHERE crapass.cdcooper = glb_cdcooper         AND
                          crapass.nrdconta = crattit.nrdconta NO-LOCK
                          BREAK BY crapass.inpessoa
                                BY crapass.cdagenci
                                BY crapass.nrdconta:

       ASSIGN aux_nmbanco = STRING(crattit.cdbanco).  

       DISPLAY STREAM str_3  
               crapass.cdagenci  
               crattit.nrdconta
               crapass.nmprimtl
               aux_nmbanco     
               crattit.qttitulo
               crattit.vltitulo
               WITH FRAME f_titulo.
            
       DOWN STREAM str_3 WITH FRAME f_titulo.
       
       ASSIGN tot_pac_qttitulo = tot_pac_qttitulo + crattit.qttitulo
              tot_pac_vltitulo = tot_pac_vltitulo + crattit.vltitulo
              tot_ger_qttitulo = tot_ger_qttitulo + crattit.qttitulo
              tot_ger_vltitulo = tot_ger_vltitulo + crattit.vltitulo.

       IF   LINE-COUNTER(str_3) > 80  THEN
            PAGE STREAM str_3.
 
       IF   LAST-OF(crapass.cdagenci)   THEN
            DO:
                DISPLAY STREAM str_3 
                        tot_pac_qttitulo
                        tot_pac_vltitulo
                        WITH FRAME f_tot_pac.
       
                ASSIGN tot_pac_qttitulo = 0
                       tot_pac_vltitulo = 0.
            END.
        
       IF   LAST-OF(crapass.inpessoa)   THEN
            DO:
                DISPLAY STREAM str_3 
                        aux_nmpessoa
                        tot_ger_qttitulo
                        tot_ger_vltitulo
                        WITH FRAME f_tot_ger.
                        
                IF   crapass.inpessoa = 1   THEN
                     ASSIGN tot_ger_qttit = tot_ger_qttitulo
                            tot_ger_vltit = tot_ger_vltitulo
                            tot_ger_qttitulo = 0
                            tot_ger_vltitulo = 0.
                ELSE 
                     DO:
                        ASSIGN tot_ger_qttitulo = 
                                        tot_ger_qttitulo + tot_ger_qttit
                               tot_ger_vltitulo = 
                                        tot_ger_vltitulo + tot_ger_vltit.
                     
                        DISPLAY STREAM str_3 
                                tot_ger_qttitulo
                                tot_ger_vltitulo
                                WITH FRAME f_tot_ger_rel.
                     END.                   

                DISPLAY STREAM str_3
                               SKIP(4)
                               "____________________________" AT 5
                               "____________________________" AT 40 SKIP
                               "         Operador           " AT 5
                               "       Cooperativa          " AT 40 SKIP(2)
                               WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.
       END.
   END.  /* FOR EACH crattit */

   IF   tel_cddopcao = "I" THEN
        DO:
              PUT STREAM str_3 CONTROL "\022\024\033\120" NULL.

              PUT STREAM str_3 CONTROL "\0330\033x0" NULL.
        END.

   OUTPUT  STREAM str_3 CLOSE.
   /*************** Visualizar / Imprimir ***********/
   IF   tel_cddopcao = "I" THEN
            DO:
                ASSIGN glb_nmformul = ""
                       glb_nrcopias = 1
                       glb_nmarqimp = aux_nmarqimp.

                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  
                           NO-LOCK NO-ERROR.
              
                { includes/impressao.i }

                HIDE MESSAGE NO-PAUSE.

                MESSAGE "Impressao Concluida !".
            END.    
       ELSE
       IF   tel_cddopcao = "T" THEN
            DO:
                RUN fontes/visrel.p (INPUT aux_nmarqimp). 
            END.

/* .......................................................................... */


