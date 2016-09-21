/* ............................................................................

    Programa: sistema/generico/includes/b1wgen0137tt.i                  
    Autor   : Guilherme
    Data    : Abril/2012                      Ultima atualizacao: 12/04/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0137.p

   Alteracoes: 29/06/2012 - Inclu�do campo cdagenci na TEMP-TABLE
                            tt-documento-digitalizado (Guilherme Maba).
               
               14/08/2013 - Incluido campos idseqttl, nmprimtl e nrcpfcgc na 
                            TEMP-TABLE tt-contr_ndigi (Jean Michel).
                            
               09/10/2013 - Incluido campos vlrfluxo na TEMP-TABLE 
                            tt-documentos (Jean Michel).
                            
               31/10/2013 - Incluido campos nraditiv na TEMP-TABLE 
                            tt-contr_ndigi e tt-documento-digitalizado 
                            (Jean Michel).
                           
               27/01/2014 - Incluido nova TEMP-TABLE tt-contr_ndigi_cadastro 
                            (Jean Michel).
               
               07/02/2014 - Incluir indice tt-documento-digitalizado3 na 
                            temp-table tt-documento-digitalizado (Lucas R.)
                            
               06/03/2014 - Incluir temp-table tt-documentos-matric (Lucas R.)
               
               08/07/2014 - Relatorio para a tela PRCGED (Chamado 143037)
                            (Jonata-RKAM).
                            
               18/06/2015 - Incluir Temp-Table tt-documentos-liberados referente
                            ao Projeto 70 (Lucas Ranghetti #281595)
                            
               30/07/2015 - Incluir Temp-Table tt-documentos-termo referente
                            ao Projeto 158 Folha de pagamento (Lombardi)
                            
               12/04/2016 - Adicionar campos dtincalt e cdoperad na tt-documentos-termo
                            (Lucas Ranghetti #410302)
............................................................................ */

DEF TEMP-TABLE tt-documento-digitalizado NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE
    FIELD tpdocmto AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrato AS INTE
    FIELD nrborder AS INTE
    FIELD dtpublic AS DATE
    FIELD flgencon AS LOGI
    FIELD nraditiv AS INT
    FIELD dtmvtolt AS DATE
    FIELD dtlibera AS DATE
    FIELD vllanmto AS DECI
    FIELD nrdolote AS INTE
    FIELD cdbccxlt AS INTE
    INDEX tt-documento-digitalizado1
          AS PRIMARY cdcooper tpdocmto nrdconta nrctrato nrborder
    INDEX tt-documento-digitalizado2 flgencon
    INDEX tt-documento-digitalizado3 cdcooper nrdconta.

DEF TEMP-TABLE tt-contr_ndigi                                           NO-UNDO
    FIELD cdcooper AS INT
    FIELD nrdconta AS INT
    FIELD dtmvtolt AS DATE
    FIELD dtlibera AS DATE
    FIELD cdagenci AS INT
    FIELD cdbanchq AS INT
    FIELD nrdolote AS INT
    FIELD nrdcontr AS INT
    FIELD vldodesc AS DEC
    FIELD tpctrdig AS INT /* 1 - Limite Cheque // 2 - Border� Cheque
                             3 - Limite Titulo // 4 - Border� Titulo */
    FIELD idseqttl AS INT
    FIELD nrcpfcgc AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD idseqite AS INT
    FIELD nraditiv AS INT
    INDEX tt-contr_ndigi1 cdcooper tpctrdig nrdconta.  

DEF TEMP-TABLE tt-contr_ndigi_cadastro                                  NO-UNDO
    FIELD cdcooper AS INT
    FIELD nrdconta AS INT
    FIELD cdagenci AS INT
    FIELD tppessoa AS CHAR
    FIELD tpdoccpf AS CHAR
    FIELD tpdocreg AS CHAR
    FIELD tpdoccen AS CHAR
    FIELD tpdoccec AS CHAR
    FIELD tpdoccre AS CHAR
    FIELD tpdoccas AS CHAR
    FIELD tpdocfca AS CHAR
    FIELD tpdocmat AS CHAR
    FIELD tpdocdip AS CHAR
    FIELD tpdocctc AS CHAR
    FIELD tpdocidp AS CHAR
    FIELD tpdocdfi AS CHAR
    FIELD idseqttl AS INT
    FIELD dtmvtolt AS DATE
    FIELD idseqite AS INT
    FIELD tpctrdig AS INT
    INDEX tt-contr_ndigi_cadastro1 AS PRIMARY cdcooper nrdconta dtmvtolt
    INDEX tt-contr_ndigi_cadastro2 cdcooper nrdconta dtmvtolt cdagenci tpctrdig.

DEF  TEMP-TABLE tt-documentos                                           NO-UNDO
     FIELD nmoperac AS CHAR
     FIELD vldparam AS DEC FORMAT "zzz,zzz,zz9.99"
     FIELD idseqite AS INT
     FIELD tpdocmto AS INT
     FIELD vlrfluxo AS DEC FORMAT "zzz,zzz,zz9.99".

DEF  TEMP-TABLE tt-documentos-matric                                    NO-UNDO
     FIELD cdagenci AS INT  FORMAT "zz9"
     FIELD nrmatric AS INT  FORMAT "zzz,zz9"        
     FIELD nrdconta AS INT  FORMAT "zzzz,zzz,9"
     FIELD nmprimtl AS CHAR FORMAT "x(40)"
     FIELD cdoperad AS CHAR FORMAT "x(10)"
     FIELD inpessoa AS CHAR FORMAT "x(4)"
     FIELD dtmvtolt AS DATE FORMAT "99/99/9999".

DEF TEMP-TABLE tt-documentos-liberados NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE
    FIELD tpdocmto AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrato AS INTE
    FIELD nrborder AS INTE
    FIELD dtpublic AS DATE
    FIELD nraditiv AS INT
    FIELD dtmvtolt AS DATE
    FIELD dtlibera AS DATE
    FIELD vllanmto AS DECI
    FIELD nrdolote AS INTE
    FIELD cdbccxlt AS INTE
    INDEX tt-documento-digitalizado1
          AS PRIMARY cdcooper tpdocmto nrdconta nrctrato nrborder
    INDEX tt-documento-digitalizado3 cdcooper nrdconta.
      
DEF TEMP-TABLE tt-documentos-termo NO-UNDO
    FIELD cdagenci AS INTE
    FIELD dstpterm AS CHAR
    FIELD dsempres AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmcontat AS CHAR
    FIELD cdcooper AS INTE
    FIELD tpdocmto AS INTE
    FIELD idseqite AS INTE
    FIELD dtincalt AS DATE
    FIELD cdoperad AS CHAR.

/*............................................................................*/
