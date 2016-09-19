/*************************************************************************
    COMENTAR A INCLUDES envia_dados_postmix PARA NAO ENVIAR OS CONVITES 
    PARA A POSTMIX.
*************************************************************************/

/* .............................................................................

   Programa: Fontes/convit.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Junho/2005                         Ultima Atualizacao: 29/05/2014

   Dados referentes ao programa:

   NOTA      : ESTE FONTES DEVE ESTAR CONECTADO AO BANCO GENERICO E AO BANCO
               DO PROGRID PARA COMPILAR.
   
   Frequencia: Diario (on-line)
   Objetivo  : Exibir tela de controle para cadastro de convites aos           
               associados(PROGRID). 
   
   Alteracoes: 16/08/2005 - Nao gerar CONVITE para pessoas juridicas, apenas
                            mostra-las no relatorio (Evandro).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/11/2005 - Alterado format do campo telefone (Diego).
               
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               08/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               31/10/2006 - Alteracao de FormExpress para FormPrint (Julio).
               
               06/12/2006 - Alteracao na imagem da chancela (Julio).
               
               18/01/2007 - Alterado formato das datas para "99/99/9999"
                            (Elton).
                                         
               18/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).
               
               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)
                            
               08/11/2007 - Alterado para nao gerar os convites em background
                            (Diego).
               
               28/02/2008 - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).

               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               08/04/2008 - Alterado para tratar titulo do CONVITE (Diego).
               
               07/11/2008 - Alterado para envio de arquivo para Postmix (Elton).
             
               17/12/2008 - Colocada mensagem no verso do convite (Gabriel).
               
               06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                            includes/var_informativos.i (Diego).
            
               09/04/2009 - Automatizar digitacao do operador (Gabriel).
               
               05/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
               
               29/06/2009 - Buscar "Facilitador" na tabela crapaep e incluida
                            clausula "crapaep.flgconvi = TRUE" na selecao do
                            campo "Nome" (Diego).

               24/07/2009 - Puxar dados do local do evento a partir do endereco
                            da cidade e do bairro (Gabriel)
                
               27/07/2009 - Mostrar tambem o local do evento (Gabriel).
               
               30/07/2009 - Incluir o campo "Cargo" - crapaep.dscrgabr 
                            (Fernando).

               17/09/2009 - Considerar PACS agrupados na agenda do progrid
                            (Gabriel).
               
               24/09/2009 - Permite escolher em qual impressoa se quer 
                            imprimir o relatorio (Elton).
                            
               07/09/2009 - Removidas linhas que nao eram alimentadas no 
                            arquivo de dados da carta CONVITE (Diego).
                            
               26/10/2009 - Enviar cartas para impressao na Engecopy das
                            cooperativas 1,2 e 4 (Diego).             
                            
               19/04/2010 - Criar cratext com o nome da faixa do CEP
                            (Gabriel). 
                            
               01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                            (Vitor).
                            
               06/05/2011 - Passado valores da tabela crapcdd para os campos 
                            cratext.nrcepcdd e cratext.dscentra (Elton).
                            
               25/05/2011 - Apos alteracao de format do crapass.nmprimtl passou
                            imprimir incorretamente o relatorio (Guilherme)
                            
               07/06/2011 - Ajuste do formato cidade e bairro (Gabriel). 
               
               21/09/2011 - Alimentar campo cratext.cdagenci (Diego).
               
               10/06/2013 - Alteração função enviar_email_completo p/ nova versão (Jean Michel).
               
               31/07/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
               
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).            
                            
               11/11/2013 - Alterado totalizador de PAs de 99 para 999. 
                           (Reinert)                            
                           
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert).
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ includes/var_online.i  } 
{ includes/var_informativos.i }

DEF STREAM str_3.
DEF STREAM str_2.

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF   VAR aux_cddopcao    AS CHAR                                     NO-UNDO.
DEF   VAR aux_tldatela    AS CHAR     FORMAT "x(61)"                  NO-UNDO.
DEF   VAR aux_confirma    AS CHAR     FORMAT "!(1)"                   NO-UNDO.
DEF   VAR aux_qtdjurid    AS INTEGER  FORMAT "zzz,zzz,zz9"            NO-UNDO.
DEF   VAR aux_nmcidade    AS CHAR     FORMAT "x(28)"                  NO-UNDO.
DEF   VAR aux_dsendres    AS CHAR     FORMAT "x(48)"                  NO-UNDO.
DEF   VAR aux_dscomand    AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmendter    AS CHAR     FORMAT "x(20)"                  NO-UNDO.
DEF   VAR aux_nrmeseve    AS CHAR                                     NO-UNDO. 
DEF   VAR aux_escolhas    AS CHAR     VIEW-AS SELECTION-LIST MULTIPLE
                                      INNER-CHARS 13 INNER-LINES 3 
                                      LIST-ITEMS "RELATORIO",
                                                 "MALA-DIRETA",
                                                 "CONVITE"            NO-UNDO.
DEF   VAR aux_cdabrido    AS INT                                      NO-UNDO.
DEF   VAR aux_cdagenci    AS INT                                      NO-UNDO.
DEF   VAR aux_nmarqeml    AS CHAR                                     NO-UNDO.
DEF   VAR aux_conteudo    AS CHAR                                     NO-UNDO.

DEF   VAR tel_cdagenci    LIKE crapass.cdagenci                       NO-UNDO.
DEF   VAR tel_dtadmis1    AS DATE     FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_dtadmis2    AS DATE     FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_dsevento    AS CHAR     FORMAT "x(60)"                  NO-UNDO.

DEF   VAR tel_dtinteg1    AS DATE     FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_dtinteg2    AS DATE     FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_hrinicio    AS CHAR     FORMAT "x(15)"                  NO-UNDO.

DEF   VAR tel_facilit1    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_cgfacili    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_localid1    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_localid2    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_localid3    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_nrtelefo    AS CHAR     FORMAT "xxxx-xxxx"              NO-UNDO.
DEF   VAR tel_nmrespon    AS CHAR     FORMAT "x(40)"                  NO-UNDO.
DEF   VAR tel_cgrespon    AS CHAR     FORMAT "x(20)"                  NO-UNDO.

/**********  Variaveis de impressao  ***************/
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.
DEF VAR rel_dsrefere AS CHAR                                         NO-UNDO.
DEF VAR rel_nmoperad AS CHAR                                         NO-UNDO.
DEF VAR rel_dsmvtolt AS CHAR                                         NO-UNDO.
DEF VAR rel_dsoperad AS CHAR                                         NO-UNDO.
DEF VAR rel_nmprimtl LIKE crapass.nmprimtl                           NO-UNDO.
DEF VAR aux_contador AS INTE                                         NO-UNDO. 

DEF VAR par_flgfirst AS LOGICAL      INIT TRUE                       NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL      INIT TRUE                       NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.


/* Para as pessoas juridicas */
DEF TEMP-TABLE w_juridicas                                            NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrfonres LIKE craptfc.nrtelefo
    INDEX w_juridicas1 AS PRIMARY UNIQUE nrdconta.

/* Para listar eventos */
DEF TEMP-TABLE w-eventos                                              NO-UNDO  
               FIELD cdevento LIKE crapadp.cdevento
               FIELD nmevento LIKE crapedp.nmevento
               FIELD dtinieve LIKE crapadp.dtinieve
               FIELD dsmeseve AS   CHAR
               FIELD dshroeve LIKE crapadp.dshroeve
               FIELD cdlocali LIKE crapadp.cdlocali
               FIELD cdabrido LIKE crapadp.cdabrido.
                             
/* Para listar abridores dos eventos do progrid */
DEF TEMP-TABLE w-abridor                                              NO-UNDO
               FIELD nmabreve LIKE crapaep.nmabreve
               FIELD dscrgabr LIKE crapaep.dscrgabr
               FIELD dsobserv LIKE crapaep.dsobserv.

DEF QUERY q-crapedp FOR w-eventos.

DEF BROWSE b-crapedp QUERY q-crapedp 
    DISPLAY w-eventos.nmevento COLUMN-LABEL "Nome do Evento"  FORMAT "x(30)"
            w-eventos.dsmeseve COLUMN-LABEL "Data do evento"  FORMAT "x(12)" 
            w-eventos.dshroeve COLUMN-LABEL "Horario"         FORMAT "x(15)"
            WITH 5 DOWN TITLE " Eventos ".

DEF QUERY q-abridor FOR w-abridor.

DEF BROWSE b-abridor QUERY q-abridor
    DISPLAY w-abridor.nmabreve COLUMN-LABEL "Nome"            FORMAT "x(30)"
            w-abridor.dsobserv COLUMN-LABEL "Observacao"      FORMAT "x(40)"
            WITH 5 DOWN TITLE " Nomes ".
            

FORM SKIP(1)
     tel_cdagenci AT 07 LABEL "PA" 
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper =
                                                        glb_cdcooper       AND
                                                        crapage.cdagenci =
                                                        tel_cdagenci),
                                 "962 - PA nao cadastrado")

     tel_dtadmis1 AT 18 LABEL "Periodo"
                        HELP "Informe o periodo."
                        VALIDATE(INPUT tel_dtadmis1 <> ?, "013 - Data errada.")
     "A"
     tel_dtadmis2 AT 40 NO-LABEL 
                        HELP "Informe o periodo."
                        VALIDATE(INPUT tel_dtadmis1 < INPUT tel_dtadmis2, 
                                 "013 - Data errada.")
     SKIP(1)
     tel_dsevento AT 03 LABEL "Evento"
     
     SKIP(12)

     WITH SIDE-LABELS ROW 4 WIDTH 80 TITLE glb_tldatela FRAME f_etiquetas.
     
     
FORM tel_dtinteg1 AT 13 LABEL "Data"
 
     tel_hrinicio AT 49 LABEL "Horario"  
     
     SKIP(1)
     tel_facilit1 AT 05 LABEL "Facilitadora" 
     SKIP
     tel_cgfacili AT 12 LABEL "Cargo"
     SKIP(1)
     tel_localid1 AT 12 LABEL "Local"  
     
     tel_localid2 AT 19 NO-LABEL 

     tel_localid3 AT 19 NO-LABEL
     
     tel_nmrespon AT 13 LABEL "Nome"
                        HELP  "Informe o nome ou pressione <F7> para listar."
          
     tel_cgrespon AT 12 LABEL "Cargo"
                        HELP  "Informe o cargo do responsavel."
                        
     tel_dtinteg2 AT 06 LABEL "Confirmacao"
                        HELP  "Informe a data para confirmar presenca."
                        VALIDATE (tel_dtinteg2 >= glb_dtmvtolt,
                                  "013 - Data de errada.")            
                                
     tel_nrtelefo AT 49 LABEL "Telefone"
                        HELP "Informe o numero do telefone."
                        VALIDATE (INTEGER(SUBSTRING(tel_nrtelefo,1,1)) <> 0 AND
                                  SUBSTRING(tel_nrtelefo,2,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,3,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,4,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,5,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,6,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,7,1) <> ""         AND
                                  SUBSTRING(tel_nrtelefo,8,1) <> "",
                        "375 - O campo deve ser preenchido")

     WITH OVERLAY CENTERED NO-BOX SIDE-LABELS ROW 10 FRAME f_etiquetas2.

FORM aux_escolhas  HELP "Use <ENTER> para selecionar os itens a serem listados"
     WITH NO-BOX NO-LABELS COLUMN 34 ROW 9 OVERLAY FRAME f_escolha.

FORM SKIP
     b-crapedp  HELP "Use <ENTER> para selecionar o evento ou <F4> para sair."
     WITH NO-BOX COLUMN 12 OVERLAY ROW 8 WIDTH 67 FRAME f_crapedp.

FORM SKIP
     b-abridor  HELP "Use <ENTER> para selecionar o nome ou <F4> para sair."
     WITH NO-BOX CENTERED OVERLAY ROW 9 FRAME f_abridor.  

ON RETURN OF b-crapedp DO:

   IF   AVAILABLE w-eventos   THEN
        DO:
            IF   w-eventos.dtinieve = ?    THEN
                 DO:
                     MESSAGE "O evento ainda nao tem uma data marcada.".
                     RETURN.
                 END.
            
            IF   w-eventos.dshroeve = ""   THEN
                 DO:
                     MESSAGE "O evento ainda nao tem um horario marcado.".
                     RETURN.
                 END.
            
            ASSIGN tel_dsevento = w-eventos.nmevento
                   aux_cdabrido = w-eventos.cdabrido.

            DISPLAY tel_dsevento WITH FRAME f_etiquetas.

            PAUSE 0.
        
        END.
        
   APPLY "GO". 

END.


ON RETURN OF b-abridor DO:

   PAUSE 0. 

   IF   AVAILABLE w-abridor   THEN
        DO:
            ASSIGN tel_nmrespon = w-abridor.nmabreve
                   tel_cgrespon = w-abridor.dscrgabr.
   
            DISPLAY tel_nmrespon
                    tel_cgrespon WITH FRAME f_etiquetas2.
        END.
        
   APPLY "GO".

END.



ASSIGN glb_cddopcao = "I"

       aux_nrmeseve = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho,Julho,Agosto" +
                      ",Setembro,Outubro,Novembro,Dezembro".

DO WHILE TRUE:
   
   RUN fontes/inicia.p.

   RUN proc_zera_variaveis. 

   EMPTY TEMP-TABLE w-eventos. 
   
   DISPLAY tel_dsevento WITH FRAME f_etiquetas.           

   CLEAR FRAME f_etiquetas2.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    

      UPDATE  tel_cdagenci 
              tel_dtadmis1
              tel_dtadmis2 WITH FRAME f_etiquetas.   
      LEAVE.

   END. /* FIM DO WHILE */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CONVIT"   THEN
                 DO:
                     HIDE FRAME f_etiquetas.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   /* Para as agendas dos PAS agrupados */
   RUN obtem-agrupador (INPUT tel_cdagenci,
                        OUTPUT aux_cdagenci). 

   /* Acha os eventos relacionados ao PA selecionado */
   
   FOR EACH crapadp WHERE crapadp.idevento = 1                    AND
                          crapadp.cdcooper = glb_cdcooper         AND
                          crapadp.cdagenci = aux_cdagenci         AND
                          crapadp.dtanoage = YEAR(glb_dtmvtolt)   AND
                          crapadp.cdevento = 13                   NO-LOCK,
       
       FIRST crapedp WHERE  crapedp.cdevento = crapadp.cdevento   AND
                            crapedp.idevento = crapadp.idevento   AND
                            crapedp.cdcooper = crapadp.cdcooper   AND
                            crapedp.dtanoage = crapadp.dtanoage   NO-LOCK
                            BY crapadp.nrmeseve
                               BY crapadp.dtinieve:
        
            /* Eventos a partir de hoje ou sem data marcada */ 
       IF   crapadp.dtinieve < glb_dtmvtolt   THEN
            NEXT.

            /* Eventos a partir de este ano */
       IF   crapadp.nrmeseve < MONTH(glb_dtmvtolt)   THEN
            NEXT.

       IF   crapadp.idstaeve = 2   THEN  /* Cancelado */
            NEXT.
            
       IF   crapadp.idstaeve = 5   THEN  /* Realizado */
            NEXT.

       CREATE w-eventos.
       ASSIGN w-eventos.cdevento = crapadp.cdevento
              w-eventos.nmevento = crapedp.nmevento
              w-eventos.dtinieve = crapadp.dtinieve
              w-eventos.dshroeve = crapadp.dshroeve
              w-eventos.cdlocali = crapadp.cdlocali
              w-eventos.cdabrido = crapadp.cdabrido
              w-eventos.dsmeseve = IF   crapadp.dtinieve = ?   THEN
                                        ENTRY(crapadp.nrmeseve,aux_nrmeseve)
                                   ELSE
                                        STRING(crapadp.dtinieve) NO-ERROR.
   END.
   
   /* Lista eventos */
   
   OPEN QUERY q-crapedp FOR EACH w-eventos NO-LOCK.
   
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
   
      UPDATE b-crapedp WITH FRAME f_crapedp.
      LEAVE.
   
   END.

   HIDE FRAME f_crapedp. 

   IF   CAN-DO("GO,END-ERROR",KEYFUNCTION(LASTKEY))   THEN
        NEXT.
 
   IF   NUM-RESULTS("q-crapedp") = 0         THEN 
        NEXT.     

   /* Custos do eventos */ 
   FIND FIRST crapcdp WHERE crapcdp.cdevento = w-eventos.cdevento   AND
                            crapcdp.cdcooper = glb_cdcooper         AND
                            crapcdp.cdagenci = aux_cdagenci         AND 
                            crapcdp.dtanoage = YEAR(glb_dtmvtolt)
                            NO-LOCK NO-ERROR.
   
   IF   NOT AVAIlABLE crapcdp   THEN
        NEXT.
 
   /* Facilitador da Proposta de evento */
   FIND FIRST crapaep WHERE crapaep.cdcooper = glb_cdcooper  AND
                            crapaep.idevento = 1             AND
                            crapaep.nrseqdig = aux_cdabrido  NO-LOCK NO-ERROR.
                      
   IF   AVAIL crapaep  THEN
        ASSIGN tel_facilit1 = crapaep.nmabreve
               tel_cgfacili = crapaep.dscrgabr.
   ELSE
        ASSIGN tel_facilit1 = " "
               tel_cgfacili = " ".
               
   /* Acha a local do evento do progrid */
   FIND FIRST crapldp WHERE crapldp.cdcooper = glb_cdcooper         AND
                            crapldp.idevento = 1                    AND
                            crapldp.cdagenci = aux_cdagenci         AND
                            crapldp.nrseqdig = w-eventos.cdlocali  
                            NO-LOCK NO-ERROR. 

   IF   AVAILABLE crapldp   THEN
        DO:
            ASSIGN tel_localid1 = SUBSTRING(crapldp.dslocali,1,40)
                   tel_localid2 = SUBSTRING(crapldp.dsendloc,1,40)
                   tel_localid3 = crapldp.nmbailoc + " - " + crapldp.nmcidloc.
        END.
        
   ASSIGN tel_dtinteg1 = w-eventos.dtinieve
          tel_hrinicio = w-eventos.dshroeve. 

   DISPLAY tel_dtinteg1   tel_hrinicio    
           tel_facilit1   tel_cgfacili
           tel_localid1   tel_localid2   tel_localid3
           WITH FRAME f_etiquetas2.
   
   
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:  
   
           /* Atualiza responsavel pelo evento e o seu cargo */
      UPDATE tel_nmrespon 
             tel_cgrespon WITH FRAME f_etiquetas2 
      
      EDITING:
      
          READKEY.
          
          IF   LASTKEY = KEYCODE("F7")   THEN   /* Listar responsaveis */ 
               DO:
                   EMPTY TEMP-TABLE w-abridor.
                   
                   FOR EACH crapaep WHERE crapaep.cdcooper = glb_cdcooper   AND
                                      /*crapaep.cdagenci = aux_cdagenci   AND*/
                                          crapaep.idevento = 1              AND
                                          crapaep.flgconvi = TRUE  NO-LOCK:
                                          
                       CREATE w-abridor.
                       ASSIGN w-abridor.nmabreve = crapaep.nmabreve
                              w-abridor.dscrgabr = crapaep.dscrgabr
                              w-abridor.dsobserv = crapaep.dsobserv.
   
                   END.
                   
                   OPEN QUERY q-abridor FOR EACH w-abridor 
                                                 BY w-abridor.nmabreve.
            
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                      UPDATE b-abridor WITH FRAME f_abridor.
                      LEAVE.

                   END.
               
                   HIDE FRAME f_abridor.
                       
                   IF   CAN-DO("GO,END-ERROR",KEYFUNCTION(LASTKEY))   THEN
                        NEXT.
        
                   IF   NUM-RESULTS("q-abridor") = 0         THEN
                        NEXT.

                   APPLY "GO". /* Nao atualiza cargo ... */

               END.
          ELSE
               APPLY LASTKEY.
    
      END.   /* Fim EDITING */

      LEAVE.   
  
   END.  /* Fim do DO WHILE TRUE */  
  
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
      
   /* Atualiza confirmacao e numero de telefone */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
      UPDATE tel_dtinteg2
             tel_nrtelefo WITH FRAME f_etiquetas2.
      LEAVE.
      
   END.
                                        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
   
   /* Tipo de convite */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE aux_escolhas 
             WITH FRAME f_escolha.
      LEAVE.

   END.

   RUN confirma.

   IF   aux_confirma = "S"   THEN
        RUN proc_imprimirelacao.

END.
   

/* Obtem o agrupador do pa na agenda do PROGRID */    
PROCEDURE obtem-agrupador:
    
    DEF INPUT        PARAM par_cdagenci AS INTE                      NO-UNDO.
    DEF OUTPUT       PARAM par_cdageagr AS INTE                      NO-UNDO.        

    FIND crapagp WHERE crapagp.cdcooper = glb_cdcooper        AND
                       crapagp.idevento = 1                   AND
                       crapagp.dtanoage = YEAR(glb_dtmvtolt)  AND
                       crapagp.cdagenci = par_cdagenci        
                       NO-LOCK NO-ERROR.
                       
    ASSIGN par_cdageagr = IF   AVAILABLE crapagp   THEN
                               crapagp.cdageagr  /* Agrupador */
                          ELSE 
                               par_cdagenci.

END PROCEDURE.    
    

PROCEDURE confirma:

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
            HIDE FRAME f_escolha.
            PAUSE 1 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.    


PROCEDURE proc_imprimirelacao.

   /* Limpa a temp-table de pessoas juridicas */
   
   EMPTY TEMP-TABLE w_juridicas.
   EMPTY TEMP-TABLE cratext.
   
   DEF  VAR aux_telefone AS DECIMAL FORMAT "zzzzzzzzz9"                 NO-UNDO.
                                        
   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   INPUT THROUGH basename `tty` NO-ECHO.

   SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
          aux_imlogoin = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                         "_externo.pcx"
          aux_imlogoex = "laser/imagens/logo_" + TRIM(LC(crapcop.nmrescop)) + 
                         "_externo.pcx"
          aux_nmarqdat = "arq/" + STRING(glb_cdcooper,"99") + "convite_" + 
                         STRING(DAY(glb_dtmvtolt), "99") +
                         STRING(MONTH(glb_dtmvtolt), "99") + "_" +
                         STRING(tel_cdagenci, "999") + ".dat"
          aux_imgvazio = "laser/imagens/vazio_grande.pcx"
          aux_impostal = "laser/imagens/chancela_ect_cecred_grande.pcx"
          aux_cdacesso = "MSGCONVITE".      

   OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp + "_mala").
   
   aux_tldatela = glb_nmrescop + " - " + " PA " + STRING(tel_cdagenci) + " - "
                  + "ASSOCIADOS ADMITIDOS ENTRE " + STRING(tel_dtadmis1) + " A "
                  + STRING(tel_dtadmis2) + "\n\n".   
   aux_nrsequen = 0.
            
   FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                      crapage.cdagenci = tel_cdagenci NO-LOCK NO-ERROR.
   
   FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper   AND
                          crapass.cdagenci  = tel_cdagenci   AND
                          crapass.dtdemiss  = ?              AND
                          crapass.dtadmiss >= tel_dtadmis1   AND
                          crapass.dtadmiss <= tel_dtadmis2   NO-LOCK:
                                 
       FIND crapenc WHERE crapenc.cdcooper = glb_cdcooper       AND
                          crapenc.nrdconta = crapass.nrdconta   AND
                          crapenc.idseqttl = 1                  AND
                          crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

       FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper      AND
                                craptfc.nrdconta = crapass.nrdconta  AND
                                craptfc.idseqttl = 1                
                                NO-LOCK NO-ERROR.

       IF AVAIL craptfc THEN
          ASSIGN aux_telefone = craptfc.nrtelefo.
       ELSE
          ASSIGN aux_telefone = 0.

       /* Nao imprime convites para pessoas juridicas */
       IF   crapass.inpessoa <> 1   THEN
            DO:
                CREATE w_juridicas.
                ASSIGN w_juridicas.nrdconta = crapass.nrdconta
                       w_juridicas.nmprimtl = crapass.nmprimtl
                       w_juridicas.nrfonres = aux_telefone.
                       
                NEXT.
            END.

       aux_dsendres = IF crapenc.nrendere > 0 THEN
                         TRIM(crapenc.dsendere)  + ", " +
                         TRIM(STRING(crapenc.nrendere,"zzz,zz9"))
                      ELSE
                         TRIM(crapenc.dsendere).

       aux_nmcidade = TRIM(crapenc.nmcidade) + " - " + crapenc.cdufende.       
               
       aux_nrsequen = aux_nrsequen + 1.

       DISPLAY STREAM str_3 
                      crapass.nrdconta LABEL "CONTA/DV"
                      crapass.nmprimtl LABEL "NOME"     FORMAT "x(40)"
                      aux_telefone     LABEL "TELEFONE"
                      WITH NO-LABEL CENTERED TITLE aux_tldatela.
           
       PUT STREAM str_2 crapass.nrdconta crapass.nmprimtl SKIP.

       IF   CAN-DO(aux_escolhas:SCREEN-VALUE IN FRAME f_escolha,"CONVITE") THEN
            DO:
               /* Tirar os acentos do progrid */
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_facilit1).
               
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_cgfacili).
               
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_localid1).
               
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_localid2).
               
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_localid3).
               
               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_nmrespon). 

               RUN fontes/substitui_caracter.p (INPUT-OUTPUT tel_cgrespon). 
               
               /* Faixa do CEP */
               FIND crapcdd WHERE crapcdd.nrcepini <= crapenc.nrcepend AND
                                  crapcdd.nrcepfim >= crapenc.nrcepend
                                  NO-LOCK NO-ERROR.

               CREATE cratext.
               ASSIGN cratext.cdagenci    = crapass.cdagenci
                      cratext.nrdconta    = crapass.nrdconta
                      cratext.nmprimtl    = STRING(crapass.nmprimtl, "x(43)") +
                                            "PA: " + 
                                            STRING(crapass.cdagenci, "999")
                      cratext.nmagenci    = crapage.nmresage
                      cratext.dsender1    = aux_dsendres
                      cratext.dsender2    = TRIM(STRING(crapenc.nmbairro,"x(15)")) 
                                            + "   " +
                                            TRIM(STRING(crapenc.nmcidade,"x(15)")) 
                                            + "   " +
                                            TRIM(crapenc.cdufende)
                      cratext.complend    = TRIM(crapenc.complend) 
                      cratext.nrcepend    = crapenc.nrcepend 
                      cratext.nomedcdd    = crapcdd.nomedcdd WHEN AVAIL crapcdd
                      cratext.nrcepcdd    = (STRING(crapcdd.nrcepini,"99,999,999") + " - " + STRING(crapcdd.nrcepfim,"99,999,999")) WHEN AVAIL crapcdd
                      cratext.dscentra    = crapcdd.dscentra WHEN AVAIL crapcdd
                      cratext.dtemissa    = glb_dtmvtolt
                      cratext.indespac    = 1
                      cratext.nrseqint    = aux_nrsequen
                      cratext.nrdordem    = 1
                      cratext.tpdocmto    = 5 
                      
                      cratext.dsintern[1] = IF   glb_cdcooper = 2  THEN
                                                 " "
                                            ELSE "CONVITE"
                      cratext.dsintern[2] = IF   glb_cdcooper = 2  THEN
                                                 "CONHECENDO A CREDITEXTIL"
                                            ELSE "INTEGRACAO DE NOVOS"
                      cratext.dsintern[3] = IF   glb_cdcooper = 2  THEN
                                                 " "
                                            ELSE "ASSOCIADOS"
                      cratext.dsintern[4] = crapass.nmprimtl
                      cratext.dsintern[5] = crapcop.nmrescop        
                      cratext.dsintern[6] = STRING(tel_dtinteg1, "99/99/9999")
                                                       
                      /* Retirar acentuacao p/evitar erros de caracteres */ 
                      cratext.dsintern[7] =  SUBSTRING(tel_hrinicio,1,
                                             INDEX(tel_hrinicio,"s") - 2) +
                                             "AS" +
                                             SUBSTRING(tel_hrinicio,
                                                INDEX(tel_hrinicio,"s") + 1 )
                                                        
                      cratext.dsintern[8]  = tel_facilit1
                      cratext.dsintern[9]  = tel_cgfacili 
                      cratext.dsintern[10] = tel_localid1
                      cratext.dsintern[11] = tel_localid2
                      cratext.dsintern[12] = tel_localid3
                      cratext.dsintern[13] = crapage.nmresage
                      cratext.dsintern[14] = STRING(tel_nrtelefo, "9999-9999")
                      cratext.dsintern[15] = STRING(tel_dtinteg2, "99/99/9999")
                      cratext.dsintern[16] = tel_nmrespon
                      cratext.dsintern[17] = tel_cgrespon
                      cratext.dsintern[18] = "#".                      

            END.
   END.
   
   /* Lista as pessoas juridicas somente no relatorio */
   IF   LINE-COUNTER(str_3) > PAGE-SIZE(str_3) - 4   THEN
        PAGE STREAM str_3.
   
   PUT STREAM str_3 SKIP(1)
                    "PESSOAS JURIDICAS"  AT 32
                    SKIP(1).
                    
   aux_qtdjurid = 0.
   FOR EACH w_juridicas BY w_juridicas.nrdconta:
   
       DISPLAY STREAM str_3 w_juridicas.nrdconta LABEL "CONTA/DV"
                            w_juridicas.nmprimtl LABEL "NOME"     FORMAT "x(40)"
                            w_juridicas.nrfonres LABEL "TELEFONE"
                            WITH NO-LABEL CENTERED NO-BOX.
    
       aux_qtdjurid = aux_qtdjurid + 1.
   END.
   
   /* Total de pessoas fisicas e juridicas */
   PUT STREAM str_3 SKIP(2)
                    "PESSOAS FISICAS:"             AT 25            
                    aux_nrsequen                   AT 42    FORMAT "zzz,zz9"
                    SKIP
                    "PESSOAS JURIDICAS:"           AT 23 
                    aux_qtdjurid                   AT 42    FORMAT "zzz,zz9"
                    SKIP(1)
                    "TOTAL:"                       AT 35
                    (aux_nrsequen + aux_qtdjurid)  AT 42    FORMAT "zzz,zz9"
                    SKIP.

   OUTPUT STREAM str_3 CLOSE.
   OUTPUT STREAM str_2 CLOSE.
   
   IF   CAN-DO(aux_escolhas:SCREEN-VALUE IN FRAME f_escolha,"RELATORIO")  THEN
        DO:
            ASSIGN  glb_nmformul = "80col"
                    glb_nrdevias = 1.

            FIND FIRST crapass WHERE  crapass.cdcooper = glb_cdcooper
                                      NO-LOCK NO-ERROR.
            { includes/impressao.i }
        END.
                       
   IF   CAN-DO(aux_escolhas:SCREEN-VALUE IN FRAME f_escolha,"MALA-DIRETA") THEN
        DO:
             /* Move para diretorio converte para utilizar na BO */
             UNIX SILENT VALUE 
                        ("mv " + aux_nmarqimp + "_mala" + " /usr/coop/" +
                         crapcop.dsdircop + "/converte" + 
                         " 2> /dev/null").
         
             /* envio de email */ 
             RUN sistema/generico/procedures/b1wgen0011.p
                 PERSISTENT SET b1wgen0011.
         
             RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "mariahelena@cecred.coop.br",
                                  INPUT '"ASSOCIADOS - "' +
                                        crapcop.nmrescop + '" - PA "' +
                                        STRING(tel_cdagenci,"999"),
                                  INPUT SUBSTRING(aux_nmarqimp, 4) + "_mala",
                                  INPUT FALSE).
                                 
             DELETE PROCEDURE b1wgen0011.
        END.
            
   IF   CAN-DO(aux_escolhas:SCREEN-VALUE IN FRAME f_escolha,"CONVITE")   THEN  
        DO:
            ASSIGN aux_nmarqimp = aux_nmarqimp + "_convit".
            
            { includes/gera_dados_inform.i }

            UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar/" +
                              SUBSTRING(aux_nmarqdat, 5)). 
         
            ASSIGN aux_nmarqdat = "salvar/" + SUBSTRING(aux_nmarqdat, 5)
                   aux_nmdatspt = aux_nmarqdat.
                   
            /* COOPERATIVAS QUE TRABALHAM COM A ENGECOPY */
            IF   CAN-DO("1,2,4",STRING(glb_cdcooper))  THEN
                 DO:
                     ASSIGN aux_nmarqeml = SUBSTR(aux_nmdatspt,
                                                 R-INDEX(aux_nmdatspt,"/") + 1,
                                                 LENGTH(aux_nmdatspt)).
                                               
                     RUN sistema/generico/procedures/b1wgen0011.p 
                         PERSISTENT SET b1wgen0011.
                                      
                     IF   NOT VALID-HANDLE (b1wgen0011)  THEN
                          DO:
                              UNIX SILENT VALUE ("rm " + aux_nmdatspt).
                              MESSAGE "ERRO AO PROCESSAR AS CARTAS CONVITE, "
                                      "TENTE NOVAMENTE !".
                              RETURN.
                          END.
                  
                     RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                                         INPUT aux_nmdatspt,
                                                         INPUT aux_nmarqeml).
            
                     ASSIGN aux_nmarqeml = SUBSTR(TRIM(aux_nmarqeml),1,
                                                R-INDEX(aux_nmarqeml,".") - 1).
            
                     UNIX SILENT VALUE("zipcecred.pl -silent -add converte/" + 
                                       aux_nmarqeml + ".zip" +
                                       " converte/" + aux_nmarqeml + ".dat").
                                      
                     ASSIGN aux_conteudo = "Em anexo o arquivo(" +
                                           aux_nmarqeml + ".zip) contendo as " 
                                           + "cartas da " + crapcop.nmrescop +
                                           ".".
                     
                     RUN enviar_email_completo IN b1wgen0011
                                     (INPUT glb_cdcooper,
                                      INPUT glb_cdprogra,
                                      INPUT "cpd@cecred.coop.br",
                                      INPUT "vendas@blucopy.com.br," +
                                            "variaveis@blucopy.com.br",
                                      INPUT "Cartas " + crapcop.nmrescop ,
                                      INPUT "",
                                      INPUT aux_nmarqeml + ".zip",
                                      INPUT aux_conteudo,
                                      INPUT TRUE). 
                     
                     DELETE PROCEDURE b1wgen0011.            
                    
                 END.
            ELSE
                 DO:  
                      { includes/envia_dados_postmix.i }
                 END.
                      
            HIDE MESSAGE NO-PAUSE.

        END.   

END PROCEDURE.


PROCEDURE proc_zera_variaveis:

   ASSIGN tel_dsevento = ""    tel_dtinteg1 = ?    tel_hrinicio = ""
          tel_facilit1 = ""    tel_cgfacili = ""   tel_localid1 = ""   
          tel_localid2 = ""    tel_localid3 = ""
          tel_nrtelefo = ""    tel_nmrespon = ""   tel_cgrespon = ""
          tel_dtinteg2 = ?.       

END PROCEDURE.
 

/* ......................................................................... */
