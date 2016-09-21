/* .............................................................................

   Programa: Fontes/estour.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/94.                        Ultima atualizacao: 02/09/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Apresentar os registros de devolucoes de cheques na tela ESTOUR.

   Alteracoes: 03/11/94 - Alterado o layout da tela para inclusao da conta base,
                          do documento, da quantidade de dias e do liminte de
                          credito. Eliminada a ufir e a data de fim do estouro
                          (Deborah).

               07/11/94 - Alterado para tratar historicos 2 e 3 do crapneg.
                          (Deborah).

               09/11/94 - Alterado para tratar historicos 4 (credito em liqui-
                          dacao) do crapneg (Deborah).

               16/11/94 - Alterado para tratar historico 5 (estouro) e modifi-
                          car a tela aparecendo a qtd. dias estouro (Odair)

               22/11/94 - Alterado para mostrar NOTIFICACAO se cdhisest = 6 e
                          quando cdhisest = 5 e cdobserv > 0 buscar a descricao
                          no crapali (Odair).

               11/07/95 - Alterado para monstrar em video reverso o valor do
                          limite de credito (Edson).

               09/08/95 - Retirar a opcao da tela (Odair).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               15/08/00 - Informar se a conta foi originada de outra(Margarete).

               24/07/01 - Alterar para mostrar o codigo da alinea de devolucao
                          na tela (Junior).
               
             09/04/2002 - Mostrar quais cheques ja foram regularizados (Junior).

             10/12/2002 - Mostrar "Admissao socio" quando cdhisest = 0 (Junior)
             
             07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                          da cooperativa (Diego).
             
            03/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
            
            06/02/2006 - Inclusao da opcao USE-INDEX na pesquisa da tabela 
                         crapneg - SQLWorks - Andre
                         
            01/08/2013 - Adaptado para BO - Jéssica DB1
            
            02/09/2015 - Ajustes para correcao da conversao realizada
                         pela DB1
                         (Adriano).
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0163tt.i }

DEF VAR h-b1wgen0163 AS HANDLE NO-UNDO.

DEF VAR tel_nmprimtl AS CHAR    FORMAT "x(35)"                NO-UNDO.
DEF VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF VAR tel_cdobserv AS CHAR    FORMAT "x(2)"                 NO-UNDO.
DEF VAR tel_dsobserv AS CHAR                                  NO-UNDO.
DEF VAR tel_cdhisest AS CHAR                                  NO-UNDO.
DEF VAR tel_dscodant AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF VAR tel_dscodatu AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF VAR tel_qtddtdev AS INTE    FORMAT "zzz9"                 NO-UNDO.

DEF VAR aux_contador AS INTE    FORMAT "99"                   NO-UNDO.
DEF VAR aux_stimeout AS INTE                                  NO-UNDO.
DEF VAR aux_msgauxil AS CHAR                                  NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                  NO-UNDO.
DEF VAR aux_qtddtdev AS INTE                                  NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                  NO-UNDO.
DEF VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_qtregist AS INT                                   NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     tel_nrdconta      AT 03 LABEL "Conta/dv" 
                             HELP "Informe o numero da conta do associado"
     tel_nmprimtl      AT 26 NO-LABEL
     tel_qtddtdev  AT 61 LABEL "Estouro"
     "dd"
     SKIP(1)
     "Seq.     Inicio Dias Historico        Valor est/devol" AT 3
     "Conta base Documento" AT 57
     "Observacoes      Limite  credito De         Para" AT 24
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_estour.

FORM tt-estour.nrseqdig AT  2   FORMAT        "zzzz9"
     tt-estour.dtiniest AT  8   FORMAT        "99/99/9999"
     tt-estour.qtdiaest AT 19   FORMAT        "zzzz"
     tel_cdhisest       AT 24   FORMAT        "x(15)"
     tt-estour.vlestour AT 40   FORMAT        "z,zzz,zzz,zz9.99"
     tt-estour.nrdctabb AT 57   FORMAT        "zzzz,zzz,z"
     tt-estour.nrdocmto AT 69   FORMAT        "zzz,zzz,z"
     tel_cdobserv       AT 24   FORMAT        "x(2)"
     tel_dsobserv       AT 27   FORMAT        "x(15)"
     tt-estour.vllimcre AT 43   FORMAT        "zzzzzz,zz9.99"
     tel_dscodant       AT 57   FORMAT        "x(10)"
     tel_dscodatu       AT 68   FORMAT        "x(10)"
     WITH ROW 11 COLUMN 2 OVERLAY 5 DOWN NO-LABEL NO-BOX FRAME f_histori.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta 
             WITH FRAME f_estour.
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.
          IF glb_nmdatela <> "ESTOUR"   THEN
             DO:
                 HIDE FRAME f_histori.
                 HIDE FRAME f_estour.
                 HIDE FRAME f_moldura.
                 RETURN.
             END.
          ELSE
             NEXT.
      END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i}
          ASSIGN aux_cddopcao = glb_cddopcao.

      END.

   RUN Busca_Dados.

   IF RETURN-VALUE <> "OK" THEN
      NEXT.

   ASSIGN aux_flgretor = FALSE
          aux_contador = 0
          glb_nrcalcul = tel_nrdconta
          glb_cdcritic = 0.

   CLEAR FRAME f_histori ALL NO-PAUSE.

   FOR EACH tt-estour:

       ASSIGN tel_cdhisest = tt-estour.cdhisest 
              tel_cdobserv = tt-estour.cdobserv 
              tel_dsobserv = tt-estour.dsobserv 
              tel_dscodant = tt-estour.dscodant 
              tel_dscodatu = tt-estour.dscodatu 
              aux_flgretor = TRUE.

       IF aux_contador = 1   THEN
          IF aux_flgretor  THEN
             DO: 
                 PAUSE MESSAGE
                      "Tecle <Entra> para continuar ou <Fim> para encerrar".
                 CLEAR FRAME f_histori ALL NO-PAUSE.
             END.
          ELSE
             aux_flgretor = TRUE.
   
       IF tt-estour.vlestour > 0   THEN
          COLOR DISPLAY MESSAGE tt-estour.vlestour WITH FRAME f_histori.
       ELSE
          COLOR DISPLAY NORMAL tt-estour.vlestour WITH FRAME f_histori.
        
       DISPLAY tt-estour.nrseqdig 
               tt-estour.dtiniest 
               tt-estour.qtdiaest
               tel_cdhisest     
               tt-estour.vlestour WHEN tt-estour.vlestour > 0
               tt-estour.nrdctabb 
               tt-estour.nrdocmto 
               tel_cdobserv 
               tel_dsobserv
               tt-estour.vllimcre WHEN tt-estour.vllimcre > 0
               tel_dscodant     
               tel_dscodatu
               WITH FRAME f_histori NO-LABELS.

       IF aux_contador = 5 THEN
          aux_contador = 0.
       ELSE
          DOWN WITH FRAME f_histori.

   END.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-estour.
    
    IF NOT VALID-HANDLE(h-b1wgen0163) THEN
       RUN sistema/generico/procedures/b1wgen0163.p
           PERSISTENT SET h-b1wgen0163.

    MESSAGE "Aguarde...buscando dados...".

    RUN Busca_Dados IN h-b1wgen0163             
        ( INPUT glb_cdcooper,                             
          INPUT 0,                                        
          INPUT 0,                                      
          INPUT glb_cdoperad,                           
          INPUT glb_nmdatela,               
          INPUT 1, /* idorigem */                         
          INPUT tel_nrdconta,              
          INPUT TRUE, /* flgerlog */ 
          INPUT 99999,
          INPUT 1,
         OUTPUT aux_msgauxil,              
         OUTPUT aux_nmprimtl,              
         OUTPUT aux_qtddtdev,  
         OUTPUT aux_nmdcampo,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-estour,            
         OUTPUT TABLE tt-erro) NO-ERROR.
    
    HIDE MESSAGE NO-PAUSE.

    IF VALID-HANDLE(h-b1wgen0163) THEN
       DELETE OBJECT h-b1wgen0163.

    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.

            CLEAR FRAME f_estour.
            CLEAR FRAME f_histori ALL NO-PAUSE.

            RETURN "NOK".  

        END.

    IF aux_msgauxil <> "" THEN
       DO:
          BELL.
          MESSAGE aux_msgauxil.
       END.
      
    ASSIGN tel_nmprimtl = aux_nmprimtl
           tel_qtddtdev = aux_qtddtdev.

    DISPLAY tel_nmprimtl 
            tel_qtddtdev 
            WITH FRAME f_estour.
           
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

/* .......................................................................... */


