/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0101tt.i
    Autor   : Adriano
    Data    : Agosto/2011               Ultima Atualizacao: 19/09/2016
     
    Dados referentes ao programa:
   
    Objetivo  : Includes referente a BO b1wgen0101.
                 
    Alteracoes: 27/07/2012 - Criada a temp-table 'tt-historicos'
                             para listagem de historicos
                           - Alteração na 'tt-dados-pesqti' para exibir
                             Vl do Conv. com a Foz e Sit. da Fatura (Lucas).
                             
                18/04/2013 - Criação da temp-table 'tt-empr-conve' para
                             listagem de conv. SICREDI (Lucas).
                             
                03/06/2014 - Adição de campos para listagem detalhada de DARFs
                             adquiridas através da Rot. 41. (Lunelli) 
                             [SD 75897 - Guilherme Fernando Gielow]
                             
                12/06/2014 - Alteração para exibir detalhes de DARFs 
                            arrecadadas na Rot. 41 (SD. 75897 Lunelli)
                            
                16/12/2014 - #203812 Inclusao do campo nmempres para exibir o
                             nome do convenio nas faturas, tela pesqti (Carlos)

                24/08/2015 - Incluido campo tpcptdoc na tt-dados-pesqti
                             (melhoria 21 Tiago/Fabricio).

                12/05/2016 - Incluido campo dslindig na tt-dados-pesqti para mostrar
				             a linha digitavel (Douglas - Chamado 426870)
                             
                19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
                             pelo InternetBanking (Projeto 338 - Lucas Lunelli)
                             
                14/12/2017 - Incluido campo na tt-empr-conve.
                             PRJ406-FGTS(Odirlei-AMcom)    
           
                18/01/2018 - Alteraçoes referente ao PJ406
                             
.............................................................................*/

DEF TEMP-TABLE tt-dados-pesqti NO-UNDO
    FIELD cdbandst AS INTE
    FIELD dscodbar AS CHAR
    FIELD nrautdoc AS INTE
    FIELD nrdocmto AS DECI
    FIELD flgpgdda AS LOGI
    FIELD nrdconta AS INTE
    FIELD nmoperad AS CHAR
    FIELD cdagenci AS INTE
    FIELD nrdolote AS INTE
    FIELD vldpagto AS DECI
    FIELD nmextbcc AS CHAR
    FIELD dspactaa AS CHAR
    FIELD vlconfoz AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD insitfat AS INT
    /* Campos - DARFS (Rot 41 Cx.Online) */
    FIELD dtapurac LIKE craplft.dtapurac
    FIELD nrcpfcgc LIKE craplft.nrcpfcgc
    FIELD cdtribut LIKE craplft.cdtribut
    FIELD nrrefere LIKE craplft.nrrefere
    FIELD dtlimite LIKE craplft.dtlimite    
    FIELD vllanmto LIKE craplft.vllanmto
    FIELD vlrmulta LIKE craplft.vlrmulta
    FIELD vlrjuros LIKE craplft.vlrjuros
    FIELD vlrecbru LIKE craplft.vlrecbru
    FIELD vlpercen LIKE craplft.vlpercen
    FIELD vlrtotal AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD nmempres AS CHAR LABEL "Convenio"
    /* Tipo de captura do documento (1=Leitora, 2=Linha digitavel) */
    FIELD tpcptdoc AS INTE
    FIELD dscptdoc AS CHAR FORMAT "x(30)"
    FIELD dslindig AS CHAR
    FIELD dsnomfon LIKE craplft.dsnomfon
    FIELD nmresage LIKE crapage.nmresage.


DEF TEMP-TABLE tt-historicos NO-UNDO
    FIELD cdhiscxa AS INT FORMAT "zzz9"
    FIELD nmempres LIKE gnconve.nmempres.

DEF TEMP-TABLE tt-empr-conve NO-UNDO
    FIELD nmextcon AS CHAR FORMAT "X(25)"
    FIELD cdempcon LIKE crapcon.cdempcon
    FIELD cdsegmto LIKE crapcon.cdsegmto
    FIELD nmrescon LIKE crapcon.nmrescon
    FIELD flgcnvsi AS CHAR.
    
/*............................................................................*/
