/*..............................................................................

   Programa: b1wnet0002tt.i                  
   Autor   : David
   Data    : Marco/2008                        Ultima atualizacao: 11/03/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wnet0002.p

   Alteracoes: 11/11/2008 - Implementacao e adaptacao para novo modulo de acesso
                            ao InternetBank por pessoas juridicas (David).
                            
               17/07/2013 - Adicionado campo para controle de bloqueio de senha
                            para contas q nao altararem a senha em determinados
                            dias estipulados pela cooperativa. Campos 
                            cdblqsnh, qtdiams1 e qtdiams2.(Jorge)
                            
               02/06/2015 - Adição do campo inpessoa na temp-table tt-titulares
                            (Dionathan)

               11/03/2016 - Adição dA temp-table tt-itens-menu-mobile
                            Projeto 286/3 - mobile (Lombardi)
                            
..............................................................................*/

DEF TEMP-TABLE tt-titulares                                             NO-UNDO
    FIELD idseqttl AS INTE
    FIELD nmtitula AS CHAR
    FIELD nrcpfope LIKE crapopi.nrcpfope
    FIELD incadsen AS INTE
    FIELD inbloque AS INTE
    FIELD inpessoa AS INTE
    FIELD idastcjt AS INTE.
    
DEF TEMP-TABLE tt-acesso                                                NO-UNDO
    FIELD dtaltsnh LIKE crapsnh.dtaltsnh
    FIELD flgsenha AS LOGI                               
    FIELD dtultace LIKE crapsnh.dtultace
    FIELD hrultace LIKE crapsnh.hrultace
    FIELD cdblqsnh AS INTE
    FIELD qtdiams1 AS INTE
    FIELD qtdiams2 AS INTE.
    
DEF TEMP-TABLE tt-itens-menu                                            NO-UNDO
    FIELD cditemmn LIKE crapmni.cditemmn
    FIELD cdsubitm LIKE crapmni.cdsubitm
    FIELD nmdoitem LIKE crapmni.nmdoitem
    FIELD dsurlace LIKE crapmni.dsurlace
    FIELD nrorditm LIKE crapmni.nrorditm
    FIELD flgacebl LIKE crapaci.flgacebl
    FIELD flcreate AS LOGI
    INDEX tt-itens-menu1 AS PRIMARY cditemmn cdsubitm.
    
DEF TEMP-TABLE tt-itens-menu-mobile                                     NO-UNDO
    FIELD cditemmn LIKE crapmni.cditemmn
    FIELD flcreate AS LOGI
    INDEX tt-itens-menu-mobile1 AS PRIMARY cditemmn.
    
DEF TEMP-TABLE tt-operadores                                            NO-UNDO
    FIELD nmoperad LIKE crapopi.nmoperad
    FIELD nrcpfope LIKE crapopi.nrcpfope
    FIELD dsdcargo LIKE crapopi.dsdcargo
    FIELD flgsitop LIKE crapopi.flgsitop
    FIELD dsdemail LIKE crapopi.dsdemail
    FIELD vllbolet LIKE crapopi.vllbolet
    FIELD vllimtrf LIKE crapopi.vllimtrf
    FIELD vllimted LIKE crapopi.vllimted
    FIELD vllimvrb LIKE crapopi.vllimvrb
    FIELD vllimflp LIKE crapopi.vllimflp.
    
/*............................................................................*/
