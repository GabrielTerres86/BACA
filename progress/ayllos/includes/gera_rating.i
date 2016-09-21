/* ............................................................................

   Programa: Includes/gera_rating.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Outubro/2009                       Ultima Atualizacao: 01/03/2010
   
   Dados referentes ao programa:
   
   Frequencia: Diario (On-line).
   
   Objetivo  : Forms e variaveis do fontes/gera_rating.p.

   Alteracoes: 01/03/2010 - Criar Frame para mostrar todas as criticas
                            do Rating de uma vez só (Gabriel).
       
.............................................................................*/

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.
DEF VAR aux_notaoperacao AS DECI FORMAT "zz9.99"                 NO-UNDO.

/* Variaveis cabecalho */
DEF VAR rel_nmempres AS CHAR                                     NO-UNDO.
DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.

DEF VAR rel_nrmodulo AS INT   FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5
                        
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.

/* Variaveis Auxiliares */ 
DEF VAR aux_confirma AS CHAR                                     NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
DEF VAR aux_contador AS INTE                                     NO-UNDO.
DEF VAR aux_indrisco AS CHAR                                     NO-UNDO.
DEF VAR aux_vlutiliz AS DECI                                     NO-UNDO.
DEF VAR aux_qtlintel AS INTE                                     NO-UNDO.
DEF VAR aux_nrctrrat AS INTE                                     NO-UNDO.
DEF VAR aux_dsoperac AS CHAR                                     NO-UNDO.
DEF VAR par_flgcalcu AS LOGI                                     NO-UNDO.


DEF VAR h-b1wgen0043 AS HANDLE                                   NO-UNDO.

/* Variaveis de tela */
DEF VAR tel_cddopcao AS CHAR  FORMAT "!(1)"                      NO-UNDO.



FORM tt-erro.dscritic COLUMN-LABEL "Descricao" FORMAT "x(62)"

     WITH 4 DOWN TITLE COLOR NORMAL " Criticas do Rating " 

          OVERLAY CENTERED ROW 11 WIDTH 64 FRAME f_criticas.

FORM tt-impressao-coop.nrdconta LABEL "Conta"    FORMAT "zzzz,zz9,9"   
     "-"                                        
     tt-impressao-coop.nmprimtl NO-LABEL         FORMAT "x(40)"  
     tt-impressao-coop.nrctrrat LABEL "Contrato" FORMAT "zz,zzz,zz9"
     "("                                        
     tt-impressao-coop.dsdopera NO-LABEL         FORMAT "x(14)"
     ") - "                                         
     tt-impressao-coop.dspessoa NO-LABEL         FORMAT "x(15)"
     SKIP(1)
     WITH SIDE-LABEL COLUMN 3 WIDTH 132 FRAME f_cooperado.   


FORM tt-impressao-rating.nrtopico AT 3 FORMAT "9"
     tt-impressao-rating.dsitetop AT 7 FORMAT "x(60)"
     "PESO    NOTA"               AT 84   
     WITH 0 DOWN NO-LABEL WIDTH 132 FRAME f_rating_1.


FORM tt-impressao-rating.dsitetop AT  7  FORMAT "x(60)"
     tt-impressao-rating.dspesoit AT 81  FORMAT "x(11)"
     WITH 0 DOWN NO-LABEL WIDTH 132 FRAME f_rating_2.


FORM tt-impressao-rating.dsitetop AT 11 FORMAT "x(65)"
     tt-impressao-rating.dspesoit AT 83 FORMAT "x(16)"   

     WITH 0 DOWN NO-LABEL WIDTH 132 FRAME f_rating_3.
     
     
FORM SKIP(1)
     tt-impressao-risco-tl.vlrtotal AT 06 LABEL "RISCO COOPERADO" 
                                                                FORMAT "zz9.99"
     tt-impressao-risco-tl.dsdrisco AT 32 LABEL "RISCO"         FORMAT "x(2)"
     aux_notaoperacao               AT 43 LABEL "RISCO OPERACAO" 
                                                                FORMAT "zz9.99"
      
     WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_nota_risco_coop.
                         

FORM tt-impressao-risco.vlrtotal AT 03 LABEL "RISCO GERAL RATING" FORMAT "zz9.99"
     tt-impressao-risco.dsdrisco AT 32 LABEL "RISCO"       FORMAT "x(2)"    
     tt-impressao-risco.vlprovis AT 43 LABEL "PROVISAO"    FORMAT "zz9.99"
     tt-impressao-risco.dsparece AT 63 NO-LABEL            FORMAT "x(20)"

     WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_nota_risco.


FORM  
     tt-impressao-assina.dsdedata AT 03  FORMAT "x(23)"
     
     SKIP   
     
     "--------------------------------"       AT 28 

     "--------------------------------"       AT 64

     tt-impressao-assina.nmoperad AT 28 FORMAT "x(23)"
     tt-impressao-assina.dsrespon AT 64 FORMAT "x(23)"
   
     WITH NO-LABEL WIDTH 132 FRAME f_assina. 

FORM tt-efetivacao.dsdefeti FORMAT "x(120)"   AT 03

     WITH NO-LABEL WIDTH 132 FRAME f_observacao.

FORM "Aguarde... Imprimindo Parametros Rating!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SPACE(1)
     tt-ratings.dtmvtolt LABEL "Data"          FORMAT "99/99/9999"
     tt-ratings.dsdopera LABEL "Tipo"          FORMAT "x(15)"
     tt-ratings.nrctrrat LABEL "Contrato"      FORMAT "z,zzz,zz9"
     tt-ratings.indrisco LABEL "Risco"         FORMAT "x(2)"
     tt-ratings.nrnotrat LABEL "Nota"          FORMAT "zz9.99" 
     tt-ratings.vlutlrat LABEL "Vl.Utl.Rating" FORMAT "zzz,zzz,zz9.99"
     SPACE(1)
     WITH CENTERED ROW 8 OVERLAY 8 DOWN NO-LABELS FRAME f_lista_rating
          
          TITLE " Rating(s) do Cooperado ".


/* ..........................................................................*/
