/* ..........................................................................

   Programa: Fontes/titulo_r1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei - Precise
   Data    : Fevereiro/2008                   Ultima atualizacao: 17/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de conferencia pagamento titulos via Internet
                                    
   Alteracoes: 28/02/2008 - Listar total do valor dos titulos acima do valor
                            parametrizado(Guilherme).

               06/05/2008 - Listar total p/ PF e PJ (Guilherme).       
                     
               04/11/2008 - Bloqueio da tecla "f4" (Martin)      

               28/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de TITULO (cdagetit e
                            cdbantit) - (Sidnei - Precise).
                            
               24/03/2010 - Alterado para Impressao da Compe CECRED (Ze).
               
               07/07/2010 - Retirar bloqueio do F4/END, pois estava travando a
                            tela TITULO (Guilherme).
                            
               08/09/2010 - Inclusao dos campos Numero de autenticacao, 
                            Descricao do cedente. Alem de alterar o relatorio 
                            de 80 para 132 col (Adriano/Eduardo).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               13/11/2014 - (Chamado 217240) Ateracao no formato da tab045, 
                            retirado uso do substr por entry (Tiago Castro - RKAM).
                        
               04/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    

               17/03/2015 - Ajustado format e tipo das variaveis que faziam
                            atribuicao de valores da tab "LIMINTERNT"
                            SD253911 - (Tiago/Gielow)
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
DEF VAR aux_descrica AS CHAR                                         NO-UNDO.

{ includes/var_online.i }

DEF TEMP-TABLE crattit                                               NO-UNDO
    FIELD cdbanco   AS INT     FORMAT "zz9"
    FIELD nrdconta  AS INT     FORMAT "zzzz,zzz,9"
    FIELD vltitulo  AS DECIMAL FORMAT "zzz,zz9.99"
    FIELD inpessoa  AS INT
    FIELD nrautdoc  AS INT     FORMAT "zzz,zz9" 
    FIELD dscedent  AS CHAR    FORMAT "x(40)".  

DEF TEMP-TABLE crattot                                               NO-UNDO
    FIELD nrdconta  AS INT     FORMAT "zzzz,zzz,9"
    FIELD inpessoa  AS INT
    FIELD vltitulo  AS DECIMAL FORMAT "zzz,zz9.99".
    
DEF TEMP-TABLE b-crattit                                             NO-UNDO
    FIELD cdbanco   AS INT     FORMAT "zz9"
    FIELD nrdconta  AS INT     FORMAT "zzzz,zzz,9"
    FIELD vltitulo  AS DECIMAL FORMAT "zzz,zz9.99"
    FIELD inpessoa  AS INT
    FIELD nrautdoc  AS INT     FORMAT "zzz,zz9"      
    FIELD dscedent  AS CHAR    FORMAT "x(40)".       
             
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.

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
DEF VAR aux_vlpessoa AS DECI  FORMAT "999,999,999.99" NO-UNDO.
DEF VAR aux_vlpesfis AS DECI  FORMAT "999,999,999.99" NO-UNDO.
DEF VAR aux_vlpesjur AS DECI  FORMAT "999,999,999.99" NO-UNDO.
DEF VAR aux_cdbanco  AS INT  FORMAT "999"    NO-UNDO.
DEF VAR aux_cdagenci AS INT  FORMAT "99999"  NO-UNDO.
DEF VAR aux_nmbanco  AS CHAR FORMAT "x(13)"  NO-UNDO.
DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)"   NO-UNDO.
DEF VAR aux_nrautdoc LIKE craptit.nrautdoc   NO-UNDO.
DEF VAR aux_dscedent LIKE crappro.dscedent   NO-UNDO.


FORM "Remessa Internet" AT 1 SKIP(1)
     "Pessoa"           AT 1 
     aux_nmpessoa
     "acima de: "
     aux_vlpessoa       FORMAT ">>>,>>>,>>9.99" SKIP(1)
     WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_cab_pessoa.

FORM  crapass.cdagenci      AT 1  LABEL "PA"
      b-crattit.nrdconta    AT 5  LABEL "Conta/dv"
      crapass.nmprimtl      AT 16 LABEL "Nome Cooperado" FORMAT "x(39)"
      aux_nmbanco           AT 56 LABEL "Banco"          FORMAT "x(03)"
      b-crattit.vltitulo    AT 62 LABEL "Vlr.Total"
      b-crattit.nrautdoc    AT 73 LABEL "Autentic."
      b-crattit.dscedent    AT 83 LABEL "Descricao Beneficiario" FORMAT "x(50)"
      WITH NO-LABELS NO-BOX  WIDTH 132 DOWN FRAME f_titulo.
 
FORM  "Total do PA"          AT   16             
      "=>  Quantidade"        AT   39
      tot_pac_qttitulo        AT   54               NO-LABEL
      "Valor"                 AT   64
      tot_pac_vltitulo        AT   72               NO-LABEL
      SKIP(1)
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_tot_pac.

FORM  SKIP(1)
      "Total Geral"           AT   16               
      aux_nmpessoa            AT   28
      "=>  Quantidade"        AT   39
      tot_ger_qttitulo        AT   54               NO-LABEL
      "Valor"                 AT   64
      tot_ger_vltitulo        AT   72               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_tot_ger.

FORM  SKIP(1)
      "TOTAL GERAL RELATORIO" AT   16               
      "=>  Quantidade"        AT   39
      tot_ger_qttitulo        AT   54               NO-LABEL
      "Valor"                 AT   64
      tot_ger_vltitulo        AT   72               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_tot_ger_rel.

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
    
FORM tel_dsdlinha     FORMAT "x(56)"          LABEL "Linha digitavel"
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
          glb_cdrelato[3] = 475
          pac_dsdtraco    = FILL("-",77).

   { includes/cabrel132_3.i }

   /*  Gerenciamento da impressao  */

   aux_nmarqimp = "rl/O475_" + STRING(TIME,"99999") + ".lst".
       
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

   VIEW STREAM str_3 FRAME f_cabrel132_3.

   EMPTY TEMP-TABLE crattit.

   /* Valores de valor minimo para exibicao do relatorio */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "LIMINTERNT"   AND
                      craptab.tpregist = 1              
                      NO-LOCK NO-ERROR.      
                 
   IF   AVAILABLE craptab   THEN
        ASSIGN aux_vlpesfis = DECIMAL(ENTRY(4,craptab.dstextab,";")). 
   ELSE
        ASSIGN aux_vlpesfis = 0.
        
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "LIMINTERNT"   AND
                      craptab.tpregist = 2              
                      NO-LOCK NO-ERROR.
   IF   AVAILABLE craptab   THEN                   
        ASSIGN aux_vlpesjur = DECIMAL(ENTRY(4,craptab.dstextab,";")).
   ELSE 
        ASSIGN aux_vlpesjur = 0.
   

   FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper         AND
                          craptit.dtdpagto = par_dtmvtolt         AND
                          CAN-DO("2,4",STRING(craptit.insittit))  AND
                          craptit.tpdocmto = 20                   AND
                          craptit.cdagenci = 90                   AND
                          craptit.flgenvio = par_flgenvio         AND
                          craptit.intitcop = 0                    NO-LOCK,
       
       EACH crapass WHERE crapass.cdcooper = craptit.cdcooper     AND
                          crapass.nrdconta = craptit.nrdconta NO-LOCK,

       
       EACH crappro WHERE crappro.cdcooper = craptit.cdcooper AND
                          crappro.nrdconta = craptit.nrdconta AND
                          crappro.dtmvtolt = craptit.dtmvtolt AND
                          crappro.nrseqaut = craptit.nrautdoc
                          NO-LOCK:
       
       ASSIGN aux_nrautdoc = craptit.nrautdoc
              aux_dscedent = crappro.dscedent.

       ASSIGN aux_cdbanco  = INT(substr(dscodbar, 1, 3))
              aux_cdagenci = INT(substr(dscodbar, 4, 5)).


       FIND crattot WHERE crattot.nrdconta = craptit.nrdconta NO-ERROR.
        
       IF   AVAIL crattot THEN
            ASSIGN crattot.vltitulo = crattot.vltitulo + craptit.vldpagto.
       ELSE 
            DO:
                CREATE crattot.
                ASSIGN crattot.nrdconta = craptit.nrdconta
                       crattot.inpessoa = crapass.inpessoa
                       crattot.vltitulo = craptit.vldpagto.
            END.    
                
       CREATE crattit.
       ASSIGN crattit.cdbanco  = aux_cdbanco
              crattit.nrdconta = craptit.nrdconta
              crattit.vltitulo = craptit.vldpagto
              crattit.inpessoa = crapass.inpessoa
              crattit.nrautdoc = craptit.nrautdoc
              crattit.dscedent = crappro.dscedent.
          
   END.  /*  Fim do FOR EACH  */ 

   FOR EACH crattot NO-LOCK:
   
       IF   crattot.inpessoa = 1   AND
            crattot.vltitulo >= aux_vlpesfis THEN
            DO: 
                FOR EACH crattit WHERE crattit.nrdconta = crattot.nrdconta 
                                      NO-LOCK:
                    CREATE b-crattit.
                    ASSIGN b-crattit.cdbanco  = crattit.cdbanco
                           b-crattit.nrdconta = crattit.nrdconta
                           b-crattit.vltitulo = crattit.vltitulo
                           b-crattit.inpessoa = crattit.inpessoa
                           b-crattit.nrautdoc = crattit.nrautdoc 
                           b-crattit.dscedent = crattit.dscedent. 
                END.           
            END.           
       ELSE 
       IF   crattot.inpessoa = 2   AND
            crattot.vltitulo >= aux_vlpesjur THEN
            DO: 
                FOR EACH crattit WHERE crattit.nrdconta = crattot.nrdconta 
                                      NO-LOCK:
                    CREATE b-crattit.
                    ASSIGN b-crattit.cdbanco  = crattit.cdbanco
                           b-crattit.nrdconta = crattit.nrdconta
                           b-crattit.vltitulo = crattit.vltitulo
                           b-crattit.inpessoa = crattit.inpessoa
                           b-crattit.nrautdoc = crattit.nrautdoc 
                           b-crattit.dscedent = crattit.dscedent.            
                END.           
            END.           
   
   END.

   FOR EACH b-crattit NO-LOCK,
       
       EACH crapass WHERE crapass.cdcooper = glb_cdcooper         AND
                          crapass.nrdconta = b-crattit.nrdconta NO-LOCK
                          BREAK BY crapass.inpessoa
                                BY crapass.cdagenci
                                BY crapass.nrdconta:

       IF   FIRST-OF(crapass.inpessoa)   THEN
            DO:
                ASSIGN aux_nmpessoa = IF crapass.inpessoa = 1 THEN
                                         "Fisica" 
                                      ELSE "Juridica".
                ASSIGN aux_vlpessoa = IF crapass.inpessoa = 1 THEN
                                         aux_vlpesfis 
                                      ELSE aux_vlpesjur.

                DISPLAY STREAM str_3 aux_nmpessoa
                                     aux_vlpessoa
                                     WITH FRAME f_cab_pessoa.
            END.
       
       ASSIGN aux_nmbanco = STRING(b-crattit.cdbanco).  

       DISPLAY STREAM str_3  
               crapass.cdagenci  
               b-crattit.nrdconta
               crapass.nmprimtl
               aux_nmbanco     
               b-crattit.vltitulo
               b-crattit.nrautdoc 
               b-crattit.dscedent 
               WITH FRAME f_titulo.
            
       DOWN STREAM str_3 WITH FRAME f_titulo.
       
       ASSIGN tot_pac_qttitulo = tot_pac_qttitulo + 1
              tot_pac_vltitulo = tot_pac_vltitulo + b-crattit.vltitulo
              tot_ger_qttitulo = tot_ger_qttitulo + 1
              tot_ger_vltitulo = tot_ger_vltitulo + b-crattit.vltitulo.

       IF   LINE-COUNTER(str_3) > 80  THEN
            DO:
                PAGE STREAM str_3.
                       
                DISPLAY STREAM str_3 aux_nmpessoa
                                     aux_vlpessoa
                                     WITH FRAME f_cab_pessoa.
            END.
 
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
