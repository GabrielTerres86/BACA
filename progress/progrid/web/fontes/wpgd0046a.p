/*
 * Programa wpgd0046a.p - Relatório para controle de Kits (chamado a partir dosdados de wpgd0046)
 *
 * Alteracoes - 03/11/2008 - Inclusao widget-pool.

                10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                
                09/06/2011 - Correção da quebra de página (Isara - RKAM).
				
				05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
							 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                             
                04/04/2013 - Alteração para receber logo na alto vale,
                             recebendo nome de viacrediav e buscando com
                             o respectivo nome (David Kruger).             
                
                04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
*/

create widget-pool.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEF BUFFER crabage FOR crapage.

DEF  TEMP-TABLE w-totais
     FIELD cdagenci  AS INT
         FIELD nmagenci  AS CHAR
         FIELD qtdkits   AS INT EXTENT 12
         FIELD qtdbrind  AS INT EXTENT 12
         FIELD qtdquest  AS INT EXTENT 12
         INDEX w-totais1 AS PRIMARY cdagenci.
         
DEFINE VARIABLE cookieEmUso                  AS CHARACTER               NO-UNDO.
DEFINE VARIABLE permiteExecutar              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER               NO-UNDO.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER               NO-UNDO.

DEFINE VARIABLE aux_idevento                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_cdcooper                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_dtanoage                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_cdagenci                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_nrmeseve                 AS INTEGER                 NO-UNDO.

DEFINE VARIABLE aux_contador                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_flgfirst                 AS LOGICAL                 NO-UNDO.
DEFINE VARIABLE aux_contapac                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_pacpagin                 AS INTEGER                 NO-UNDO.

DEFINE VARIABLE pac_totbrind                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE pac_totkits                  AS INTEGER                 NO-UNDO.
DEFINE VARIABLE pac_totquest                 AS INTEGER                 NO-UNDO.

DEFINE VARIABLE geral_totbrind               AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE geral_totkits                AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE geral_totquest               AS INTEGER     EXTENT 12   NO-UNDO.

DEFINE VARIABLE total_totbrind               AS INTEGER                 NO-UNDO.
DEFINE VARIABLE total_totkits                AS INTEGER                 NO-UNDO.
DEFINE VARIABLE total_totquest               AS INTEGER                 NO-UNDO.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER               NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER               NO-UNDO.

DEFINE VARIABLE mes                          AS CHARACTER   EXTENT 12
                                                INITIAL ["Jan","Fev","Mar","Abr","Mai","Jun",
                                                         "Jul","Ago","Set","Out","Nov","Dez"]    NO-UNDO.

DEFINE VARIABLE aux_nmrescop                 AS CHARACTER               NO-UNDO.

/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de funçoes                                                        */
/*****************************************************************************/

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER):

    IF opcao = "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
       {&out} '<script language="Javascript">' SKIP
              '   top.close(); ' SKIP
              '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
              '</script>' SKIP.

    IF opcao = "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
       DO: 
          DELETE-COOKIE("cookie-usuario-em-uso",?,?).
          {&out} '<script language="Javascript">' SKIP
                 '   top.close(); ' SKIP
                 '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
                 '</script>' SKIP.
       END.

    RETURN TRUE.

END FUNCTION. /* erroNaValidacaoDoLogin RETURNS LOGICAL () */



FUNCTION total_geral RETURNS LOGICAL ():

    {&out} '   <br>    ' SKIP
               '   <table border="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td width="40%">' SKIP.
                   
        {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="48%">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '        SOMA DOS PAS' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
                  
                   '     <tr>' SKIP
                 '       <td class="td2" align="center" width="20%">' SKIP
                  '         &nbsp;' SKIP
           '       </td>' SKIP /*
                   '       <td class="td2" align="center">' SKIP
                   '         &nbsp;' SKIP
           '       </td>' SKIP */
           '       <td class="td2" align="center" colspan="2" width="50%">' SKIP
           '         Enviados' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         Recebidos' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
                   
                   '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
                   '       <td class="td2" align="center" width="20%">' SKIP
           '         Brindes' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center" width="20%">' SKIP
           '         Kits' SKIP
           '       </td>' SKIP
                   '       <td class="td2" align="center" width="30%">' SKIP
           '         Questionários' SKIP
           '       </td>' SKIP
                   '     </tr>' SKIP .
                   
    IF   aux_nrmeseve = 0  THEN  /* Todos os Meses */ 
             DO:   
                 DO aux_contador = 1 TO 12:

                                {&out} '     <tr>' SKIP
                               '       <td class="td2" align="center">' SKIP
                                           mes[aux_contador] SKIP
                                '       </td>' SKIP
                                 '       <td class="tdDados2" align="center">' SKIP
                                         geral_totbrind[aux_contador] SKIP
                                 '       </td>' SKIP
                                 '       <td class="tdDados2" align="center">' SKIP
                                         geral_totkits[aux_contador] SKIP
                                 '       </td>' SKIP
                                             '       <td class="tdDados2" align="center">' SKIP
                               geral_totquest[aux_contador] SKIP
                                 '       </td>' SKIP
                                             '     </tr>' SKIP.
                                                                         
                ASSIGN total_totbrind = total_totbrind + geral_totbrind[aux_contador]
                               total_totkits  = total_totkits  + geral_totkits[aux_contador]
                               total_totquest = total_totquest + geral_totquest[aux_contador].
                     END.
                                                                         
             END.
        ELSE
             DO:
                     {&out} '     <tr>' SKIP
                            '       <td class="td2" align="center">' SKIP
                                mes[aux_nrmeseve] SKIP
                             '       </td>' SKIP
                              '       <td class="tdDados2" align="center">' SKIP
                                      geral_totbrind[aux_nrmeseve] SKIP
                              '       </td>' SKIP
                              '       <td class="tdDados2" align="center">' SKIP
                                      geral_totkits[aux_nrmeseve] SKIP
                              '       </td>' SKIP
                                          '       <td class="tdDados2" align="center">' SKIP
                            geral_totquest[aux_nrmeseve] SKIP
                              '       </td>' SKIP
                                          '     </tr>' SKIP.
                                                                         
             ASSIGN total_totbrind = geral_totbrind[aux_nrmeseve]
                            total_totkits  = geral_totkits[aux_nrmeseve]
                            total_totquest = geral_totquest[aux_nrmeseve].
                 
                 END.
        
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
                  '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                    total_totbrind SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                    total_totkits SKIP
           '       </td>' SKIP
                   '       <td class="tdDados2" align="center">' SKIP
                    total_totquest SKIP
           '       </td>' SKIP.
                           
        {&out} '     </tr>' SKIP
           '   </table>'.         
                   
        {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.            
                   

END FUNCTION. /* fim total_geral */

FUNCTION montaTela RETURNS LOGICAL ():


    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Fechamento Final</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdTitulo2   ~{ font-family: Verdana; font-size: 18px; font-weight: bold;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           
           '   .tab2        ~{ border-color:black }' SKIP
           '   .td2         ~{ border-color:black }' SKIP
           '   .tdDados2    ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-color:black}' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP.
    
    /* *** Botoes de fechar e imprimir *** */
    {&out} '<div align="right" id="botoes">' SKIP
           '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td align="right">' SKIP
           '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0046a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Controle de Kits - ' aux_dtanoage '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    ASSIGN aux_contapac = 0
           aux_pacpagin = 0
           aux_flgfirst = TRUE.
         
    FOR EACH w-totais NO-LOCK 
        BREAK BY w-totais.cdagenci:
    
        IF FIRST-OF(w-totais.cdagenci) THEN
        DO:
            ASSIGN pac_totbrind = 0
                   pac_totkits  = 0
                   pac_totquest = 0
                               
            /* Controla quantidade de PA'S mostrados na mesma linha do relatório */ 
            aux_contapac = aux_contapac + 1.
                
            IF  aux_contapac = 1  THEN  
                {&out} '   <br>    ' SKIP
                       '   <table border="0" width="100%">' SKIP
                       '     <tr>' SKIP
                       '       <td width="40%">' SKIP.
                                                  
            {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%">' SKIP
                   '     <tr>' SKIP
                   '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
                               w-totais.nmagenci SKIP
                   '       </td>' SKIP
                   '     </tr>' SKIP
             
                   '     <tr>' SKIP
                   '       <td class="td2" align="center" width="20%">' SKIP
                   '         &nbsp;' SKIP
                   '       </td>' SKIP /*
                   '       <td class="td2" align="center">' SKIP
                   '         &nbsp;' SKIP
                   '       </td>' SKIP */
                   '       <td class="td2" align="center" colspan="2" width="50%">' SKIP
                   '         Enviados' SKIP
                   '       </td>' SKIP
                   '       <td class="td2" align="center">' SKIP
                   '         Recebidos' SKIP
                   '       </td>' SKIP
                   '     </tr>' SKIP
             
                   '     <tr>' SKIP
                   '       <td class="td2" align="center">' SKIP
                   '         &nbsp;' SKIP
                   '       </td>' SKIP
                   '       <td class="td2" align="center" width="20%">' SKIP
                   '         Brindes' SKIP
                   '       </td>' SKIP
                   '       <td class="td2" align="center" width="20%">' SKIP
                   '         Kits' SKIP
                   '       </td>' SKIP
                   '       <td class="td2" align="center" width="30%">' SKIP
                   '         Questionários' SKIP
                   '       </td>' SKIP
                   '     </tr>' SKIP .
        
            /* Mostrar TODOS os Meses */
            IF   aux_nrmeseve = 0  THEN   
            DO:
                DO aux_contador = 1 TO 12:
    
                    {&out} '     <tr>' SKIP
                           '       <td class="td2" align="center">' SKIP
                                       mes[aux_contador] SKIP
                           '       </td>' SKIP
                           '       <td class="tdDados2" align="center">' SKIP
                                       w-totais.qtdbrind[aux_contador] SKIP
                           '       </td>' SKIP
                           '       <td class="tdDados2" align="center">' SKIP
                                       w-totais.qtdkits[aux_contador] SKIP
                           '       </td>' SKIP
                           '       <td class="tdDados2" align="center">' SKIP
                                       w-totais.qtdquest[aux_contador] SKIP
                           '       </td>' SKIP
                           '     </tr>' SKIP.
                                           
                  ASSIGN pac_totbrind = pac_totbrind + w-totais.qtdbrind[aux_contador]
                         pac_totkits  = pac_totkits  + w-totais.qtdkits[aux_contador]
                         pac_totquest = pac_totquest + w-totais.qtdquest[aux_contador]
                         geral_totbrind[aux_contador] = geral_totbrind[aux_contador] + w-totais.qtdbrind[aux_contador]
                         geral_totkits[aux_contador]  = geral_totkits[aux_contador] + w-totais.qtdkits[aux_contador]
                         geral_totquest[aux_contador] = geral_totquest[aux_contador] + w-totais.qtdquest[aux_contador].
    
                END.
            END.
            ELSE
            DO: 
                {&out} '     <tr>' SKIP
                       '       <td class="td2" align="center">' SKIP
                                   mes[aux_nrmeseve] SKIP
                       '       </td>' SKIP
                       '       <td class="tdDados2" align="center">' SKIP
                                   w-totais.qtdbrind[aux_nrmeseve] SKIP
                       '       </td>' SKIP
                       '       <td class="tdDados2" align="center">' SKIP
                                   w-totais.qtdkits[aux_nrmeseve] SKIP
                       '       </td>' SKIP
                       '       <td class="tdDados2" align="center">' SKIP
                                   w-totais.qtdquest[aux_nrmeseve] SKIP
                       '       </td>' SKIP
                       '     </tr>' SKIP.
                                            
                ASSIGN pac_totbrind = w-totais.qtdbrind[aux_nrmeseve]
                       pac_totkits  = w-totais.qtdkits[aux_nrmeseve]
                       pac_totquest = w-totais.qtdquest[aux_nrmeseve]
                       geral_totbrind[aux_nrmeseve] = geral_totbrind[aux_nrmeseve] + w-totais.qtdbrind[aux_nrmeseve]
                       geral_totkits[aux_nrmeseve]  = geral_totkits[aux_nrmeseve] + w-totais.qtdkits[aux_nrmeseve]
                       geral_totquest[aux_nrmeseve] = geral_totquest[aux_nrmeseve] + w-totais.qtdquest[aux_nrmeseve].
            END.
            /* FIM - Mostrar TODOS os Meses */
    
            {&out} '     <tr>' SKIP
                   '       <td class="td2" align="center">' SKIP
                   '         TOTAL' SKIP
                   '       </td>' SKIP
                   '       <td class="tdDados2" align="center">' SKIP
                               pac_totbrind SKIP
                   '       </td>' SKIP
                   '       <td class="tdDados2" align="center">' SKIP
                               pac_totkits SKIP
                   '       </td>' SKIP
                   '       <td class="tdDados2" align="center">' SKIP
                               pac_totquest SKIP
                   '       </td>' SKIP.
                 
            {&out} '     </tr>' SKIP
                   '   </table>' SKIP.           
        END. /* FIM - FIRST-OF(w-totais.cdagenci) */

        IF aux_contapac = 2 THEN
        DO: 
            {&out} '       </td>' SKIP
                   '     </tr>' SKIP
                   '   </table>' SKIP. 
                                  
            ASSIGN aux_contapac = 0
                   
            /* Controla quantidade de PA'S por página */ 
            aux_pacpagin = aux_pacpagin + 1.                .
            /* Controlar quebra de página */ 

            /*IF aux_nrmeseve = 0 THEN
            DO:
                IF aux_flgfirst      AND 
                   aux_pacpagin = 3  THEN
                DO:
                    {&out} '<br style="page-break-after: always">' SKIP.
                    ASSIGN aux_flgfirst = FALSE
                           aux_pacpagin = 0.
                END.
                ELSE
                DO:
                    IF aux_pacpagin = 4 THEN
                    DO:
                        {&out} '<br style="page-break-after: always">' SKIP.
                        ASSIGN aux_pacpagin = 0.
                    END.
                END.
            END.
            ELSE
            DO:
                IF aux_pacpagin = 10 THEN
                DO:
                    {&out} '<br style="page-break-after: always">' SKIP.
                    ASSIGN aux_pacpagin = 0.        
                END.
            END.*/

        END.
        ELSE
            {&out} '       </td>' SKIP
                   '       <td width="3%">' SKIP
                   '       </td>' SKIP
                   '       <td width="40%">' SKIP.
    END.
    
    IF   aux_contapac <> 2  THEN
        {&out} '       </td>' SKIP
               '     </tr>' SKIP
               '   </table>' SKIP. 
        
    /* Mostrar Total Geral somente quando for TODOS os PA'S */ 
    IF  aux_cdagenci = 0  THEN
        total_geral().
    
    IF msgsDeErro <> "" THEN
        {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
               '      <tr>' SKIP
               '         <td>' msgsDeErro '</td>' SKIP
               '      </tr>' SKIP
               '   </table>' SKIP.

    {&out} '</div>' SKIP
           '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
          ASSIGN aux_idevento  = INTEGER(GET-VALUE("parametro1"))
                 aux_cdcooper  = INTEGER(GET-VALUE("parametro2"))
                 aux_dtanoage  = INTEGER(GET-VALUE("parametro3")) 
                                 aux_cdagenci  = INTEGER(GET-VALUE("parametro4")) 
                                 aux_nrmeseve  = INTEGER(GET-VALUE("parametro5")) NO-ERROR.          

                  FIND LAST gnpapgd WHERE gnpapgd.idevento = aux_idevento   AND 
                                  gnpapgd.cdcooper = aux_cdcooper   AND 
                                  gnpapgd.dtanonov = aux_dtanoage   NO-LOCK NO-ERROR.

                  IF   aux_cdagenci = 0  THEN
                       DO:
                               FOR EACH crapage WHERE crapage.cdcooper = aux_cdcooper  AND
                                                                 crapage.flgdopgd = TRUE NO-LOCK 
                                                                                     BY crapage.nmresage:

                                       FOR EACH crapkbq WHERE crapkbq.dtanoage = aux_dtanoage                             AND
                                              crapkbq.cdcooper = aux_cdcooper                             AND
                                                                                          crapkbq.cdagenci = crapage.cdagenci                         AND
                                             (aux_nrmeseve = 0 OR MONTH(crapkbq.dtdenvio) = aux_nrmeseve)
                                                                              NO-LOCK BREAK BY crapkbq.cdagenci :
                        
                               IF   FIRST-OF(crapkbq.cdagenci)  THEN
                                            DO:
                                    CREATE w-totais.
                                                        ASSIGN w-totais.cdagenci = crapkbq.cdagenci
                                                                               w-totais.nmagenci = crapage.nmresage.
                                                END.
                                   
                           IF   crapkbq.tpdeitem = 1  THEN
                                                ASSIGN w-totais.qtdkits[MONTH(crapkbq.dtdenvio)] = w-totais.qtdkits[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                                   ELSE
                                       IF   crapkbq.tpdeitem = 2  THEN
                                            ASSIGN w-totais.qtdbrind[MONTH(crapkbq.dtdenvio)] = w-totais.qtdbrind[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                                       ELSE
                                       IF   crapkbq.tpdeitem = 3  THEN
                                            ASSIGN w-totais.qtdquest[MONTH(crapkbq.dtdenvio)] = w-totais.qtdquest[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                                   
                               END.
                                           
                                           /* Se não houve lançamentos de kits no PA, cria registro zerado */ 
                                           FIND FIRST w-totais WHERE w-totais.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR.
                                           
                                           IF   NOT AVAIL w-totais  THEN
                                                DO:
                                                            CREATE w-totais.
                                                                ASSIGN w-totais.cdagenci = crapage.cdagenci
                                                                       w-totais.nmagenci = crapage.nmresage.
                                                                
                                END.
                                                        
                                   END.
                           
                           END.
                  ELSE
                       DO:
                                   FOR EACH crapkbq WHERE crapkbq.dtanoage = aux_dtanoage                             AND
                                          crapkbq.cdcooper = aux_cdcooper                             AND
                                          crapkbq.cdagenci = aux_cdagenci                             AND
                                                                 (aux_nrmeseve = 0 OR MONTH(crapkbq.dtdenvio) = aux_nrmeseve)
                                                                          NO-LOCK BREAK BY crapkbq.cdagenci:
                          
                                   IF   FIRST-OF(crapkbq.cdagenci)  THEN
                                        DO:
                                FIND crapage WHERE crapage.cdcooper = aux_cdcooper  AND
                                                                                   crapage.cdagenci = crapkbq.cdagenci
                                                                                                   NO-LOCK NO-ERROR.
                                                                
                                                                CREATE w-totais.
                                                    ASSIGN w-totais.cdagenci = crapkbq.cdagenci
                                                                       w-totais.nmagenci = crapage.nmresage.
                                            END.
                                   
                       IF   crapkbq.tpdeitem = 1  THEN
                                            ASSIGN w-totais.qtdkits[MONTH(crapkbq.dtdenvio)] = w-totais.qtdkits[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                               ELSE
                                   IF   crapkbq.tpdeitem = 2  THEN
                                        ASSIGN w-totais.qtdbrind[MONTH(crapkbq.dtdenvio)] = w-totais.qtdbrind[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                                   ELSE
                                   IF   crapkbq.tpdeitem = 3  THEN
                                        ASSIGN w-totais.qtdquest[MONTH(crapkbq.dtdenvio)] = w-totais.qtdquest[MONTH(crapkbq.dtdenvio)] + crapkbq.qtdenvio.
                                   
                           END.
                                   
                           END.

          FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
              
          IF AVAILABLE crapcop THEN
             DO:
                ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                       nomedacooperativa    = TRIM(crapcop.nmrescop).
              
                IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
                   DO: 
                      aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                      SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                      imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
                   END.
                ELSE
                   imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
             END.

          montaTela(). 
       END.
          
/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

