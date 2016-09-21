/* .............................................................................

   Programa: Fontes/pamrel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Marco/2006                     Ultima Atualizacao: 15/09/2010 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir alteracoes Parametros de Relatorio.

   ALTERACAO : 29/03/2006 - Acrescentado campo "tprelato" (Diego).
              
               27/06/2006 - Modificada mensagem Log (Diego).

               10/08/2006 - Incluido campo "nmdestin" (Elton).

               20/06/2008 - Cadastro de e-mails por relatorio (David).
               
                          - Alterado labels e helps da tela (Gabriel).  
                          
               03/03/2010 - Incluido funcao "I": Inclusao de relatorios na 
                            Intranet para processo Compe Fora (Gati - Daniel)
                            
               24/03/2010 - Continuacao da funcao "I". Zipando arquivos de 
                            controle e transferindo para servidor. excluindo
                            do diretorio.
                            
               28/04/2010 - Salvar o arquivo de controle no salvar/
                            (Guilherme/Ze).                            
                            
               11/05/2010 - Utilizar o cp_pkghttpintranet.sh para copia
                            do arquivo de controle para o servidor
                            (Guilherme/Julio).
                            
               01/06/2010 - Alteração do campo "pkzip" para "zipcecred.pl" 
                            (Vitor).  
                            
               22/06/2010 - Alteração para manipular data de publicação na
                            intranet.(Jonatas/Supero).   
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop 
                            na leitura e gravacao dos arquivos (Elton).
                            
               21/09/2010 - Alterado parametros do cp_pkghttpintranet.sh
                            (Guilherme).
............................................................................. */

{ includes/var_online.i}

/* Diretorios padroes - utilizar sempre SEM 'barra' no final */

&SCOPED-DEFINE DIR-RELAT   /usr/coop
&SCOPED-DEFINE DIR-PDF     /usr/audit/pdf
/*
&SCOPED-DEFINE DIR-RELAT   C:/Users/daniel/Desktop/20
&SCOPED-DEFINE DIR-PDF     C:/Users/daniel/Desktop/20*/

DEF   VAR tel_cdrelato   LIKE craprel.cdrelato                       NO-UNDO.
DEF   VAR tel_nmrelato   LIKE craprel.nmrelato                       NO-UNDO.
DEF   VAR tel_nmdestin   LIKE craprel.nmdestin                       NO-UNDO.
DEF   VAR tel_inimprel   AS LOGICAL  FORMAT "Sim/Nao"                NO-UNDO.
DEF   VAR tel_ingerpdf   AS LOGICAL  FORMAT "Sim/Nao"                NO-UNDO.
DEF   VAR tel_tprelato   AS LOGICAL  FORMAT "Normal/Gerencial"       NO-UNDO.
DEF   VAR tel_dsdemail   AS CHAR     FORMAT "x(40)" EXTENT 6         NO-UNDO.
DEF   VAR tel_dtpublic   AS DATE     FORMAT "99/99/9999"             NO-UNDO.

DEF   VAR aux_inimprel   LIKE craprel.inimprel                       NO-UNDO.
DEF   VAR aux_ingerpdf   LIKE craprel.ingerpdf                       NO-UNDO.
DEF   VAR aux_tprelato   LIKE craprel.tprelato                       NO-UNDO.
DEF   VAR aux_dstransa   AS CHAR                                     NO-UNDO.
DEF   VAR aux_cddopcao   AS CHAR                                     NO-UNDO.
DEF   VAR aux_confirma   AS CHAR FORMAT "!(1)"                       NO-UNDO.

/* Variaveis para controle de arquivos - Processo compe fora */
DEF   VAR aux_arquivos   AS CHAR                                     NO-UNDO.
DEF   VAR aux_arqconnm   AS CHAR                                     NO-UNDO.
DEF   VAR aux_arqconco   AS CHAR                                     NO-UNDO.
DEF   VAR aux_tipoarqu   AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmarquiv   AS CHAR FORMAT "X(80)"                      NO-UNDO.
DEF   VAR aux_contador   AS INTE                                     NO-UNDO.
DEF   VAR aux_sourcefl   AS CHAR                                     NO-UNDO.
DEF   VAR aux_targetfl   AS CHAR                                     NO-UNDO.
DEF   VAR aux_contado2   AS INTE                                     NO-UNDO.
DEF   VAR aux_completo   AS CHAR                                     NO-UNDO.
DEF   VAR aux_cdrelato   AS INTE                                     NO-UNDO.
DEF   VAR aux_nmarqpdf   AS CHAR                                     NO-UNDO.
DEF   VAR aux_ziparqui   AS CHAR                                     NO-UNDO.
DEF   VAR aux_diretzip   AS CHAR                                     NO-UNDO.
DEF   VAR aux_comanscp   AS CHAR                                     NO-UNDO.

/*Variaveis para alteração da data de publicação na intranet*/
DEF VAR aux_arqnovo   AS CHAR                     NO-UNDO.
DEF VAR aux_setlinha  AS CHAR FORMAT "x(120)"     NO-UNDO.
DEF VAR aux_setlinha2 AS CHAR FORMAT "X(120)"     NO-UNDO.


DEF TEMP-TABLE tt-craprel NO-UNDO
    FIELD dsarqrel AS   CHAR
    /*FIELD cdrelato LIKE craprel.cdrelato*/
    FIELD nmrelato LIKE craprel.nmrelato
    FIELD nmarquiv AS CHAR
    /*
    FIELD lgimprel AS LOGI FORMAT "Sim/Nao"
    FIELD lggerpdf AS LOGI FORMAT "Sim/Nao"
    FIELD lgtiprel AS LOGI FORMAT "Normal/Gerencia"
    FIELD nmdestin LIKE craprel.nmdestin
    */
    INDEX ch_dsrqrel dsarqrel.


DEF STREAM str_dir.
DEF STREAM str_entrada.
DEF STREAM str_leitura.
DEF STREAM str_arqant.         
DEF STREAM str_arqnovo.
             
DEF QUERY q_relatorios   FOR craprel.

DEF BROWSE b_relatorios  QUERY q_relatorios
    DISPLAY craprel.cdrelato  COLUMN-LABEL "Cod."
            craprel.nmrelato  COLUMN-LABEL "Descricao" FORMAT "x(35)"
            IF craprel.inimprel = 1 THEN  "Sim"
            ELSE "Nao"        COLUMN-LABEL "Impr." FORMAT "x(3)"
            IF craprel.ingerpdf = 1  THEN "Sim"
            ELSE "Nao"        COLUMN-LABEL "G.Arq." FORMAT "x(3)"
            IF craprel.tprelato = 1  THEN "Normal"
            ELSE "Gerencia"  COLUMN-LABEL "Tp.Rel."
            craprel.nmdestin COLUMN-LABEL "Destino"
            WITH 7 DOWN WIDTH 78 OVERLAY.

DEF QUERY q_compefora FOR tt-craprel.
        
DEF BROWSE b_compefora QUERY q_compefora
    DISP  tt-craprel.dsarqrel FORMAT "x(15)" COLUMN-LABEL "Relatorio"
          tt-craprel.nmrelato COLUMN-LABEL "Descricao"
          WITH 7 DOWN MULTIPLE. 

FORM 
  b_compefora  HELP "Use <ESPACO> para selecionar e <F4> para encerrar." SKIP
  WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_compefora.
               
FORM 
  SKIP(1)
  b_relatorios  HELP "Use ENTER para selecionar ou F4 para sair"    SKIP
  WITH NO-BOX ROW 8 COLUMN 2 OVERLAY FRAME f_relatorios.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.
                       
FORM 
  SKIP(1)     
  glb_cddopcao    AT  4 LABEL "                       Opcao"
                  HELP "Informe a opcao desejada (A, C ou I)."
                  VALIDATE(CAN-DO("A,C,I", glb_cddopcao),"014 - Opcao errada.")
  SKIP(1)
  tel_dtpublic    AT  4 LABEL "          Data de publicacao"
                  HELP "Informe a data de publicacao na intranet."
  tel_cdrelato    AT  4 LABEL "                   Relatorio"
                  HELP "Informe o codigo do relatorio ou 0 (zero) p/ listar."
  tel_nmrelato    
  SKIP(1)         
  tel_inimprel    AT  4 LABEL "          Imprimir relatorio"
                  HELP "Informe (S)im ou (N)ao."
  SKIP            
  tel_ingerpdf    AT  4 LABEL " Gerar arquivo PDF(INTRANET)"
                  HELP "Informe (S)im ou (N)ao."
  SKIP            
  tel_tprelato    AT  4 LABEL "              Tipo relatorio"
                  HELP "Informe  (N)ormal  ou  (G)erencial."
  SKIP            
  tel_nmdestin    AT  4 LABEL "           Destino relatorio"
                  HELP "Informe o destino do relatorio."
  SKIP                                                     
  tel_dsdemail[1] AT  4 LABEL " E_mails para envio proposta"
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  tel_dsdemail[2] AT 34 NO-LABEL 
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  tel_dsdemail[3] AT 34 NO-LABEL 
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  tel_dsdemail[4] AT 34 NO-LABEL 
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  tel_dsdemail[5] AT 34 NO-LABEL 
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  tel_dsdemail[6] AT 34 NO-LABEL 
  HELP "Informe e-mails para envio do relatorio (separados por virgula)."
  WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_rel.


/* Retorna relatorio */    
ON RETURN OF b_relatorios
   DO:
       ASSIGN tel_cdrelato    = craprel.cdrelato
              tel_nmrelato    = craprel.nmrelato
              tel_nmdestin    = craprel.nmdestin
              tel_dsdemail[1] = SUBSTR(craprel.dsdemail,1,40)
              tel_dsdemail[2] = SUBSTR(craprel.dsdemail,41,40)
              tel_dsdemail[3] = SUBSTR(craprel.dsdemail,81,40)
              tel_dsdemail[4] = SUBSTR(craprel.dsdemail,121,40)
              tel_dsdemail[5] = SUBSTR(craprel.dsdemail,161,40)
              tel_dsdemail[6] = SUBSTR(craprel.dsdemail,201,40).

       DISPLAY tel_cdrelato tel_nmrelato tel_nmdestin tel_dsdemail 
               WITH FRAME f_rel.
       
       APPLY "GO". 
   END.              
              
        
VIEW FRAME f_moldura. 
PAUSE(0).                           

ASSIGN glb_cddopcao = "C"
       tel_dtpublic = glb_dtmvtolt.

RUN fontes/inicia.p.
                             
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
      HIDE tel_dtpublic IN FRAME f_rel.

      UPDATE  glb_cddopcao WITH FRAME f_rel.
      LEAVE.
         
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "PAMREL"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

        
   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.  
   
   ASSIGN tel_nmrelato = "".

   DISPLAY tel_nmrelato WITH FRAME f_rel.
     
   IF   glb_cddopcao = "A"  THEN
        DO:
            UPDATE tel_cdrelato WITH FRAME f_rel.
               
            IF   tel_cdrelato = 0  THEN
                 DO:
                     OPEN QUERY q_relatorios 
                          FOR EACH craprel WHERE 
                                   craprel.cdcooper = glb_cdcooper
                                   NO-LOCK.
                                                   
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b_relatorios WITH FRAME f_relatorios.
                        LEAVE.
                     END.
                           
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                          DO:
                              HIDE FRAME f_relatorios.
                              NEXT.
                          END.
                     ELSE
                          HIDE FRAME f_relatorios.
                 END.
                    
            FIND craprel WHERE craprel.cdrelato = tel_cdrelato  AND
                               craprel.cdcooper = glb_cdcooper
                               NO-ERROR.
                             
            IF   NOT AVAILABLE craprel  THEN
                 DO:
                     MESSAGE "Relatorio Nao Existe".
                     NEXT.
                 END.
                                 
            ASSIGN tel_nmrelato    = craprel.nmrelato
                   tel_inimprel    = IF craprel.inimprel = 1 THEN TRUE
                                     ELSE FALSE
                   tel_ingerpdf    = IF craprel.ingerpdf = 1 THEN TRUE
                                     ELSE FALSE
                   aux_inimprel    = craprel.inimprel
                   aux_ingerpdf    = craprel.ingerpdf
                   aux_tprelato    = craprel.tprelato
                   tel_tprelato    = IF craprel.tprelato = 1 THEN TRUE
                                     ELSE FALSE
                   tel_nmdestin    = craprel.nmdestin
                   tel_dsdemail[1] = SUBSTR(craprel.dsdemail,1,40)
                   tel_dsdemail[2] = SUBSTR(craprel.dsdemail,41,40)
                   tel_dsdemail[3] = SUBSTR(craprel.dsdemail,81,40)
                   tel_dsdemail[4] = SUBSTR(craprel.dsdemail,121,40)
                   tel_dsdemail[5] = SUBSTR(craprel.dsdemail,161,40)
                   tel_dsdemail[6] = SUBSTR(craprel.dsdemail,201,40). 
                                     
            DISPLAY tel_nmrelato WITH FRAME f_rel.
               
            UPDATE  tel_inimprel tel_ingerpdf tel_tprelato 
                    tel_nmdestin tel_dsdemail
                    WITH FRAME f_rel.
            
            RUN Confirma.

            IF   aux_confirma = "S"  THEN
                 DO:
                     DO TRANSACTION ON ERROR UNDO, LEAVE: 
                     
                        ASSIGN craprel.inimprel = IF tel_inimprel = TRUE THEN 1
                                                  ELSE 2
                               craprel.ingerpdf = IF tel_ingerpdf = TRUE THEN 1
                                                  ELSE 2
                               craprel.tprelato = IF tel_tprelato = TRUE THEN 1
                                                  ELSE 2
                               craprel.nmdestin = tel_nmdestin
                               craprel.dsdemail =  
                                              STRING(tel_dsdemail[1],"x(40)") +
                                              STRING(tel_dsdemail[2],"x(40)") +
                                              STRING(tel_dsdemail[3],"x(40)") +
                                              STRING(tel_dsdemail[4],"x(40)") +
                                              STRING(tel_dsdemail[5],"x(40)") +
                                              STRING(tel_dsdemail[6],"x(40)").
                        
                        FIND crapope WHERE 
                             crapope.cdoperad = glb_cdoperad  AND
                             crapope.cdcooper = glb_cdcooper
                             NO-LOCK NO-ERROR.
                                         
                        aux_dstransa =  "Rel." + STRING(tel_cdrelato) +
                                        " Imp.:" + 
                                        STRING(aux_inimprel) + " p/ " + 
                                        STRING(craprel.inimprel) + 
                                        " Gerar PDF:" +
                                        STRING(aux_ingerpdf) + " p/ " +
                                        STRING(craprel.ingerpdf) + 
                                        " Tp.Rel:" + STRING(aux_tprelato) +
                                        " Email(s):" + 
                                        tel_dsdemail[1] + tel_dsdemail[2] +
                                        tel_dsdemail[3] + tel_dsdemail[4] +
                                        tel_dsdemail[5] + tel_dsdemail[6] +
                                        " p/ " + STRING(craprel.tprelato) +
                                        " Ope.:" + crapope.cdoperad.

                        RUN fontes/gera_log.p 
                            (INPUT glb_cdcooper, INPUT 0,
                             INPUT glb_cdoperad, INPUT aux_dstransa,
                             INPUT glb_nmdatela).
                                
                     END. /* Transaction */
                 END.
        END.
   ELSE
   IF   glb_cddopcao = "C"  THEN
        DO:
            UPDATE tel_cdrelato WITH FRAME f_rel.
            
            IF   tel_cdrelato = 0  THEN
                 DO:
                     OPEN QUERY q_relatorios 
                          FOR EACH craprel WHERE 
                                   craprel.cdcooper = glb_cdcooper
                                   NO-LOCK.
                                                   
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b_relatorios WITH FRAME f_relatorios.
                        LEAVE.
                     END.
                     
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                          DO:
                              HIDE FRAME f_relatorios.
                              NEXT.
                          END.
                     ELSE
                          HIDE FRAME f_relatorios.
                 END.                  
                    
            FIND craprel WHERE craprel.cdrelato = tel_cdrelato  AND
                               craprel.cdcooper = glb_cdcooper
                               NO-ERROR.
                             
            IF   NOT AVAILABLE  craprel  THEN
                 DO:
                     MESSAGE "Relatorio Nao Existe".
                     NEXT.
                 END.
                                 
            ASSIGN tel_nmrelato    = craprel.nmrelato
                   tel_nmdestin    = craprel.nmdestin 
                   tel_inimprel    = IF craprel.inimprel = 1 THEN TRUE
                                     ELSE FALSE
                   tel_ingerpdf    = IF craprel.ingerpdf = 1 THEN TRUE
                                     ELSE FALSE
                   tel_tprelato    = IF craprel.tprelato = 1 THEN TRUE
                                     ELSE FALSE
                   tel_dsdemail[1] = SUBSTR(craprel.dsdemail,1,40)
                   tel_dsdemail[2] = SUBSTR(craprel.dsdemail,41,40)
                   tel_dsdemail[3] = SUBSTR(craprel.dsdemail,81,40)
                   tel_dsdemail[4] = SUBSTR(craprel.dsdemail,121,40)
                   tel_dsdemail[5] = SUBSTR(craprel.dsdemail,161,40)
                   tel_dsdemail[6] = SUBSTR(craprel.dsdemail,201,40).
                  
            DISPLAY tel_nmrelato tel_inimprel tel_ingerpdf tel_tprelato
                    tel_nmdestin tel_dsdemail WITH FRAME f_rel.
        
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            HIDE tel_cdrelato    tel_nmrelato    tel_inimprel    
                 tel_ingerpdf    tel_tprelato    tel_nmdestin    
                 tel_dsdemail[1] tel_dsdemail[2] tel_dsdemail[3] 
                 tel_dsdemail[4] tel_dsdemail[5] IN FRAME f_rel.
                 
            ASSIGN tel_dtpublic = glb_dtmvtolt.

            UPDATE tel_dtpublic WITH FRAME f_rel.

            IF tel_dtpublic = ? THEN
            DO:
                MESSAGE "Data de publicacao na intranet deve ser informada.".
                NEXT.
            END.

            EMPTY TEMP-TABLE tt-craprel.
            
            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

            ASSIGN aux_arquivos = "{&DIR-RELAT}~/" + crapcop.dsdircop + 
                                  "~/tmppdf~/".

            INPUT STREAM str_dir FROM OS-DIR(aux_arquivos).


            bloco_arq_relat:
            REPEAT:
                
                IMPORT STREAM str_dir aux_arquivos ^ aux_tipoarqu.
        
                IF aux_tipoarqu <> "F" THEN NEXT.
        
                IF   aux_arquivos BEGINS "crrl"   THEN
                     DO:
                         IF   NOT CAN-FIND(tt-craprel WHERE 
                                      tt-craprel.dsarqrel = 
                                         (SUBSTRING(aux_arquivos,1,7)))   THEN
                              DO:
                                  ASSIGN aux_cdrelato = 
                                             INT(SUBSTRING(aux_arquivos,5,3)).

                                  FIND craprel WHERE
                                       craprel.cdcooper = glb_cdcooper   AND
                                       craprel.cdrelato = aux_cdrelato   
                                       NO-LOCK NO-ERROR.
                                  IF   NOT AVAIL craprel       THEN
                                       NEXT bloco_arq_relat.

                                  IF   craprel.ingerpdf <> 1   THEN
                                       NEXT bloco_arq_relat.
                                 
                                  CREATE tt-craprel.
                                  ASSIGN tt-craprel.dsarqrel = 
                                                    SUBSTRING(aux_arquivos,1,7)
                                         tt-craprel.nmrelato = craprel.nmrelato
                                         tt-craprel.nmarquiv = aux_arquivos.
                                         
                              END.
                    
                     END. /* IF   aux_arquivos BEGINS "crrl" */
            END. /* REPEAT */

            INPUT STREAM str_dir CLOSE.

            OPEN QUERY q_compefora FOR EACH tt-craprel.
                                                   
            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PAUSE 0.
                 UPDATE b_compefora WITH FRAME f_compefora.
                 LEAVE.
            END.

            IF   b_compefora:NUM-SELECTED-ROWS = 0   THEN
                 DO:
                     MESSAGE "Nao foi selecionado nenhum relatorio.".
                     VIEW tel_cdrelato    tel_nmrelato    tel_inimprel    
                          tel_ingerpdf    tel_tprelato    tel_nmdestin    
                          tel_dsdemail[1] tel_dsdemail[2] tel_dsdemail[3] 
                          tel_dsdemail[4] tel_dsdemail[5] IN FRAME f_rel.
                     NEXT.
                 END.

            HIDE FRAME f_compefora.
        
            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 ASSIGN aux_confirma = "N".
                 BELL.
                 MESSAGE COLOR NORMAL "Confirma selecao dos relatorios?"
                 UPDATE aux_confirma.
                 LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 LEAVE.
                 
            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 ASSIGN aux_confirma = "N".
                 BELL.
                 MESSAGE COLOR NORMAL 
                     "Deseja postar relatorio(s) selecionado(s) na INTRANET?"
                 UPDATE aux_confirma.
                 LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     VIEW tel_cdrelato    tel_nmrelato    tel_inimprel    
                          tel_ingerpdf    tel_tprelato    tel_nmdestin    
                          tel_dsdemail[1] tel_dsdemail[2] tel_dsdemail[3] 
                          tel_dsdemail[4] tel_dsdemail[5] IN FRAME f_rel.
                     LEAVE.     
                 END.
                 
            DO   aux_contador = 1 TO b_compefora:NUM-SELECTED-ROWS:
                
                 b_compefora:FETCH-SELECTED-ROW(aux_contador).
                 
                 /* carrega variavel com os arquivos que vao ser zipados */
                 IF   aux_ziparqui = "" THEN
                      ASSIGN aux_ziparqui = "{&DIR-RELAT}~/"    + 
                                            crapcop.dsdircop    + 
                                            "~/tmppdf~/"        + 
                                            tt-craprel.dsarqrel + "*".
                 ELSE 
                      ASSIGN aux_ziparqui = aux_ziparqui + " "  + 
                                            "{&DIR-RELAT}~/"    + 
                                            crapcop.dsdircop    + 
                                            "~/tmppdf~/"        + 
                                            tt-craprel.dsarqrel + "*".
                    
                 /*RUN trataarquivoscompefora.*/
            END.

            /****** Dados do arquivo de controle ******/
            ASSIGN aux_arqconnm = "controle." + crapcop.dsdircop + ".txt"
                   aux_arqnovo  = "controle." + crapcop.dsdircop + ".tmp"
                   aux_arqconco = "~/usr~/coop~/" + crapcop.dsdircop +
                                  "~/tmppdf~/"    + aux_arqconnm.

            /***** Gerar arquivo de controle *******/
            UNIX SILENT VALUE("cat " + aux_ziparqui + " > " + aux_arqconco).
  
            /*Alteracao para manipular da data de publicacao na intranet
             - Jonatas*/
            INPUT STREAM str_arqant FROM VALUE(aux_arqconco) NO-ECHO.
                        
            OUTPUT STREAM str_arqnovo TO VALUE("tmppdf/" + aux_arqnovo).
                
            DO WHILE TRUE ON  ENDKEY UNDO, LEAVE:
                IMPORT STREAM str_arqant UNFORMATTED aux_setlinha.
    
                ASSIGN aux_setlinha2 = ENTRY(1,aux_setlinha,";") + ";" 
                                     + STRING(YEAR(tel_dtpublic),"9999") + ";" 
                                     + STRING(MONTH(tel_dtpublic),"99") + ";" 
                                     + STRING(DAY(tel_dtpublic),"99") + ";" 
                                     + ENTRY(5,aux_setlinha,";") + ";"
                                     + ENTRY(6,aux_setlinha,";") + ";" 
                                     + ENTRY(7,aux_setlinha,";")+ ";" .
                
               /*Insere linhas no novo arquivo com data de publicacao
                 informada na tela*/          
                PUT STREAM str_arqnovo UNFORMATTED aux_setlinha2 SKIP.
            END.
            
            OUTPUT STREAM str_arqnovo CLOSE.
            INPUT STREAM str_arqant CLOSE.
            
            /* Eliminar arquivos arquivo de controle com data 
                de publicacao incorreta *****/
            UNIX SILENT VALUE("rm " + aux_arqconco + " 2> ~/dev~/null").
                        
            /* Renomear arquivo de controle com data publicacao correta */
            UNIX SILENT VALUE("mv tmppdf/" + aux_arqnovo + " tmppdf/" +
                              aux_arqconnm + " 2> ~/dev~/null").
            
            /****** Copia arquivo de controle para servidor *******/
            UNIX SILENT VALUE("sudo cp_pkghttpintranet.sh " + crapcop.dsdircop
                              + " " + 
                              "/usr/coop/" + crapcop.dsdircop +
                              "/tmppdf/" + aux_arqconnm + " >/dev/null").            

            /***** Zipa arquivos selecionados e arquivo de controle geral *****/
            ASSIGN aux_diretzip = "~/usr~/coop~/" + STRING(crapcop.dsdircop) + 
                                  "~/salvar~/" + "tmppdf" + 
                                  STRING(DAY(glb_dtmvtolt),"99")   + 
                                  STRING(MONTH(glb_dtmvtolt),"99") + "_" +
                                  STRING(TIME).
            
            UNIX SILENT VALUE("zipcecred.pl -add " + aux_diretzip + " " + 
                              aux_ziparqui + " " + aux_arqconco + 
                              " 1> ~/dev~/null 2> ~/dev~/null"). 

            /* Salva o arquivo de controle no salvar */
            UNIX SILENT VALUE("cp " + aux_arqconco + " salvar/" + 
                              aux_arqconnm + "." + 
                              STRING(DAY(glb_dtmvtolt),"99")   + 
                                         STRING(MONTH(glb_dtmvtolt),"99") + 
                              "." + STRING(TIME)).
                              
           /* Eliminar arquivos selecionados e arquivo de 
              controle do diretorio origem (tmppdf) ****/
            UNIX SILENT VALUE("rm " + aux_diretzip + " " + aux_ziparqui + 
                               " " + aux_arqconco + " 2> ~/dev~/null").
                               
            VIEW tel_cdrelato    tel_nmrelato    tel_inimprel    
                 tel_ingerpdf    tel_tprelato    tel_nmdestin    
                 tel_dsdemail[1] tel_dsdemail[2] tel_dsdemail[3] 
                 tel_dsdemail[4] tel_dsdemail[5] IN FRAME f_rel.
        END.
        
END. /* Do While */

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.
