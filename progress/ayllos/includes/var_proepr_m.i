/* .............................................................................

   Programa: Includes/var_proepr_m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                         Ultima atualizacao: 06/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para impressao da PROPOSTA DE EMPRESTIMO.

   Alteracoes: 03/02/97 - Tirado CREDIHERING do frame f_vistos, pois os
                          associados assinavam no lugar da CREDIHERING (Odair)
                
               29/01/99 - Incluir a data de admissao na CCOH (Deborah).

               07/08/2000 - Incluir campo para a descricao da segunda linha 
                            do bem financiado (Edson). 

               15/01/2001 - Imprimir limites (Margarete/Planner).

               12/07/2001 - Modificar o layout da proposta de emprestimos.
                            (Eduardo).
                            
               19/12/2002 - Mudancas no LAYOUT do Contrato e Promissoria
                            (Ze/Deborah).        
                                 
               01/08/2005 - Criadas variaveis para os campos cidade, bairro    
                            uf e cep referente o contratante (Diego).

               29/08/2005 - Incluidas variaveis para nacionalidade e para
                            fim estimado do emprestimo (Evandro).
                            
               12/01/2006 - Incluida a variavel com o nome do proprietario do
                            bem (Evandro).

               20/06/2008 - Variavel para instanciar a BO b1wgen9999 (David).

               18/06/2009 - Substituida variavel rel_dsdebens pela rel_dsrelbem
                            e a variavel rel_vloutras pela rel_vldrendi (Elton).

               26/11/2009 - Variavel para impressao do Rating (Gabriel).   
               
               20/01/2010 - Alteracoes referente ao projeto CMAPRV 2 (David). 
               
               14/09/2010 - Ajustes do projeto de melhorias de operacoes
                            de credito (Gabriel)                                                      
                                      
               29/08/2014 - Incluir ajustes referentes ao Projeto CET
                            (Lucas R./Gielow)        
                            
               01/09/2014 - Orgaos de protecao ao credito (Jonata-RKAM).      
               
               10/09/2014 - Projeto contratos, retirar opcoes de impressao
                            de contratos de emprestimos 
                            "COMPLETA", "CONTRATO" e "NOTA PROMISSORIA" 
                            (Tiago Castro - RKAM).
                            
               06/11/2014 - Ocultar apenas o botao de  PROPOSTA  mantendo 
                            as demais opcoes habilitadas e visiveis. (Jaison)
............................................................................. */

DEF {1} SHARED VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"
                                                                     NO-UNDO.
DEF {1} SHARED VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_dsconsul AS CHAR    FORMAT "x(9)" INIT "Consultas"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_proposta AS CHAR    FORMAT "x(8)" INIT "Proposta"
                                                                     NO-UNDO.

DEF {1} SHARED VAR tel_primeira AS CHAR    FORMAT "x(15)"
                                           INIT "Primeira Pagina"    NO-UNDO.

DEF {1} SHARED VAR tel_segundap AS CHAR    FORMAT "x(14)"
                                           INIT "Segunda Pagina"     NO-UNDO.

DEF {1} SHARED VAR tel_dsrating AS CHAR    FORMAT "x(6)"
                                           INIT "Rating"             NO-UNDO.
DEF {1} SHARED VAR tel_impricet AS CHAR FORMAT "x(3)"  INIT "CET"    NO-UNDO.


DEF {1} SHARED VAR par_flgrodar AS LOGICAL INIT TRUE                    NO-UNDO.
DEF {1} SHARED VAR par_flgfirst AS LOGICAL INIT TRUE                    NO-UNDO.
DEF {1} SHARED VAR par_flgcance AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR tab_vltotemp AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR tab_vlemprst AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR tab_qtcapemp AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tot_vlsdeved AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR tot_vlpreemp AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR tot_vlliquid AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR rel_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_nrmatric AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_nrpagina AS INT     INIT 1                       NO-UNDO.
DEF {1} SHARED VAR rel_nrctremp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_ddmvtolt AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_dddpagto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_aamvtolt AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_qtpreemp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_dssitdct AS CHAR                                  NO-UNDO.
DEF {1} SHARED VAR rel_cdagenci AS INT                                  NO-UNDO.
DEF {1} SHARED VAR rel_nrcepend AS INT                                  NO-UNDO.


DEF {1} SHARED VAR rel_dtadmemp AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR rel_dtedvmto AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR rel_dtdpagto AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR rel_dtadmiss AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR rel_dtfimemp AS DATE    FORMAT "99/99/9999"          NO-UNDO.


DEF {1} SHARED VAR rel_vlemprst AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlpreemp AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlsmdtri AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlsalari AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlsalcon AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vldrendi AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlcaptal AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vldsaque AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vlprepla AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_txminima AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_txbaspre AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR rel_vllimcre AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR rel_dsdmoeda AS CHAR    EXTENT 2 INIT "R$"           NO-UNDO.
DEF {1} SHARED VAR rel_dspreemp AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dspresta AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsemprst AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_nmprimtl AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsliquid AS CHAR    EXTENT 3                     NO-UNDO.
DEF {1} SHARED VAR rel_dsrelbem AS CHAR    EXTENT 6                     NO-UNDO.
DEF {1} SHARED VAR rel_dsmvtolt AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsendres AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsendav1 AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsendav2 AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsfiador AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsfiaseg AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsminima AS CHAR    EXTENT 2                     NO-UNDO.
DEF {1} SHARED VAR rel_dsjurfix AS CHAR    EXTENT 2                     NO-UNDO.

DEF {1} SHARED VAR rel_dsobscmt AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsobserv AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsdpagto AS CHAR    EXTENT 3                     NO-UNDO.

DEF {1} SHARED VAR rel_dsbemfin AS CHAR    EXTENT 99                    NO-UNDO.
DEF {1} SHARED VAR rel_dsbemseg AS CHAR    EXTENT 99                    NO-UNDO.
DEF {1} SHARED VAR rel_dsbemter AS CHAR    EXTENT 99                    NO-UNDO.
DEF {1} SHARED VAR rel_nmpropbm AS CHAR    EXTENT 99                    NO-UNDO.

DEF {1} SHARED VAR rel_tpchassi AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmdaval1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmdaval2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsliqseg AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscpfcgc AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscpfav1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscpfav2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dspreapg AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsvencto AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsvenseg AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsdtraco AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsformap AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsliqant AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmcidade AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmbairro AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_cdufresd AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsnacion AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_telefone AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR rel_dsfinemp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dslcremp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsmesref AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsjurvar AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmempres AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmdsecao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmchefia AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dstipcta AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_tpctremp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nrcpfcgc AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsagenci AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dsctremp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nrclausu AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmcjgav1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_nmcjgav2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscfcav1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscfcav2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR rel_dscooper AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_txeanual AS DECIMAL DECIMALS 6                   NO-UNDO.

DEF {1} SHARED VAR aux_flgescra AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgproep AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_nmendter AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nmarqtmp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dscomand AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsbranco AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsextens AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsliquid AS CHAR                                 NO-UNDO.
                               
DEF {1} SHARED VAR aux_flgimppr AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgimpnp AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgimpct AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgentra AS LOGICAL                              NO-UNDO.                              
DEF {1} SHARED VAR aux_dsmesref AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nmoperad AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_dsnegrit AS CHAR    FORMAT "x(03)"               NO-UNDO.
DEF {1} SHARED VAR aux_contapag AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contames AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrlinhas AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrpagina AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_incontad AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nmcidade AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nmcidpac AS CHAR                                 NO-UNDO.
                                                   
DEF VAR aux_idimpres AS INTE                                            NO-UNDO.
DEF VAR aux_flgemail AS LOGI                                            NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                            NO-UNDO.
DEF VAR aux_promsini AS INTE                                            NO-UNDO.
DEF VAR aux_flgentrv AS LOGI                                            NO-UNDO.
DEF VAR aux_flggener AS LOGI                                            NO-UNDO.

DEF VAR h-b1wgen0002i AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0191  AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999  AS HANDLE                                         NO-UNDO.

/*  Outros .................................................................. */

FORM "Aguarde... Imprimindo contrato e/ou proposta e/ou nota promissoria!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM "Aguarde... Imprimindo Custo Efetivo Total (CET)"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_cet.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1) 
     tel_impricet  tel_proposta  
     tel_dsrating  tel_dsconsul  tel_dscancel 
     SKIP(1)
     WITH ROW 12 NO-LABELS CENTERED OVERLAY FRAME f_imprime.

FORM SKIP(1) 
     tel_impricet  tel_dsrating  
     tel_dsconsul  tel_dscancel 
     SKIP(1)
     WITH ROW 12 NO-LABELS CENTERED OVERLAY FRAME f_imprime_2.

FORM SKIP(1) " "
     tel_primeira "  " tel_segundap "  " tel_dscancel
     " " SKIP(1)
     WITH ROW 13 NO-LABELS CENTERED OVERLAY FRAME f_pagina.
   
FORM SKIP(1)
    "  Imprimir NP a partir da" aux_promsini
    HELP "Entre com o numero inicial da promissoria a ser impressa."
         VALIDATE(aux_promsini > 0,"380 - Numero errado.")
    " "
    SKIP(1)
    WITH ROW 14 CENTERED NO-LABEL
         OVERLAY TITLE COLOR NORMAL " Impressao de NP " 
         FRAME f_promis_inicial.

FORM "Aguarde... Imprimindo contrato e nota promissoria!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_1.
     
FORM "Aguarde... Imprimindo contrato!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_2.

FORM "Aguarde... Imprimindo proposta!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_3.

FORM "Aguarde... Imprimindo nota promissória!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_4.

FORM SKIP(1)
     "Efetuar envio de e-mail para Sede?" AT 3
     aux_flgemail NO-LABEL FORMAT "S/N"
     SKIP(1)
     WITH OVERLAY ROW 14 CENTERED WIDTH 42 TITLE COLOR NORMAL "Destino"
     FRAME f_email.

/* .......................................................................... */

