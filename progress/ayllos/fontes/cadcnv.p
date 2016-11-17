/*..............................................................................

   Programa: Fontes/cadcnv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Janeiro/2008                     Ultima Atualizacao:  11/05/2009 

   Dados referentes ao programa:

   Frequencia : Diario (on-line)
   Objetivo   : Mostrar a tela cadcnv (Cadastramento de convenios).
   
   Alteracoes : 22/08/2008 - Tratamento p/ nao dar erro do progress quando nao 
                             tiver nenhum convenio no browse (Gabriel).
                         
                28/08/2008 - Criado log/cadcnv.log (Gabriel)
                           - Melhorada estrutura do codigo fonte (David).    

                23/01/2009 - Retirada permissao do operador 799 e liberar
                             o 979 (Gabriel)
                
                11/05/2009 - Alteracao CDOPERAD (Kbase).
..............................................................................*/

{  includes/var_online.i  }

DEF   VAR tel_nrconven LIKE crapcnv.nrconven  FORMAT "z,zz9"           NO-UNDO.
DEF   VAR tel_dsconven LIKE crapcnv.dsconven                           NO-UNDO.
DEF   VAR tel_lshistor LIKE crapcnv.lshistor  FORMAT "x(51)"           NO-UNDO.
DEF   VAR tel_lshisto2 LIKE crapcnv.lshistor  FORMAT "x(63)"           NO-UNDO.
DEF   VAR tel_lsempres LIKE crapcnv.lsempres  FORMAT "x(51)"           NO-UNDO.
DEF   VAR tel_lsempre2 LIKE crapcnv.lsempres  FORMAT "x(51)"           NO-UNDO.
DEF   VAR tel_inobriga LIKE crapcnv.inobriga                           NO-UNDO.
DEF   VAR tel_dddebito LIKE crapcnv.dddebito                           NO-UNDO.
DEF   VAR tel_intipdeb LIKE crapcnv.intipdeb                           NO-UNDO.
DEF   VAR tel_inlimsld LIKE crapcnv.inlimsld                           NO-UNDO.
DEF   VAR tel_indebcre LIKE crapcnv.indebcre                           NO-UNDO.
DEF   VAR tel_inmesdeb LIKE crapcnv.inmesdeb                           NO-UNDO.
DEF   VAR tel_tpconven LIKE crapcnv.tpconven                           NO-UNDO.
DEF   VAR tel_intipest LIKE crapcnv.intipest                           NO-UNDO.
DEF   VAR tel_indescto LIKE crapcnv.indescto                           NO-UNDO.
DEF   VAR tel_dsdemail LIKE crapcnv.dsdemail  FORMAT "x(52)"           NO-UNDO. 
DEF   VAR tel_dsdemai2 LIKE crapcnv.dsdemail  FORMAT "x(52)"           NO-UNDO.
DEF   VAR tel_dsdemai3 LIKE crapcnv.dsdemail  FORMAT "x(52)"           NO-UNDO.

/*Variaveis para log**/
DEF   VAR log_dsconven LIKE crapcnv.dsconven                           NO-UNDO.
DEF   VAR log_lshistor LIKE crapcnv.lshistor  FORMAT "x(51)"           NO-UNDO.
DEF   VAR log_lshisto2 LIKE crapcnv.lshistor  FORMAT "x(63)"           NO-UNDO.
DEF   VAR log_lsempres LIKE crapcnv.lsempres  FORMAT "x(51)"           NO-UNDO.
DEF   VAR log_lsempre2 LIKE crapcnv.lsempres  FORMAT "x(51)"           NO-UNDO.
DEF   VAR log_inobriga LIKE crapcnv.inobriga                           NO-UNDO.
DEF   VAR log_dddebito LIKE crapcnv.dddebito                           NO-UNDO.
DEF   VAR log_intipdeb LIKE crapcnv.intipdeb                           NO-UNDO.
DEF   VAR log_inlimsld LIKE crapcnv.inlimsld                           NO-UNDO.
DEF   VAR log_indebcre LIKE crapcnv.indebcre                           NO-UNDO.
DEF   VAR log_inmesdeb LIKE crapcnv.inmesdeb                           NO-UNDO.
DEF   VAR log_tpconven LIKE crapcnv.tpconven                           NO-UNDO.
DEF   VAR log_intipest LIKE crapcnv.intipest                           NO-UNDO.
DEF   VAR log_indescto LIKE crapcnv.indescto                           NO-UNDO.
DEF   VAR log_dsdemail LIKE crapcnv.dsdemail                           NO-UNDO.

DEF   VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF   VAR aux_confirma AS LOGICAL FORMAT "S/N" INITIAL YES             NO-UNDO.

DEF   TEMP-TABLE w-convenio                                            NO-UNDO  
      FIELD nrconven AS INT
      FIELD dsconven AS CHAR.

DEF   QUERY q-convenio FOR w-convenio.
      
DEF   BROWSE b-convenio QUERY q-convenio
      DISPLAY nrconven  COLUMN-LABEL "Convenio"
              dsconven  COLUMN-LABEL "Descricao" FORMAT "x(40)"
              WITH 5 DOWN TITLE " Convenios ".
           
FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
         HELP "Informe a opcao desejada (A,C,E,I)."
         VALIDATE (CAN-DO("A,C,E,I",glb_cddopcao), "014 - Opcao errada.")
     WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM SKIP
     tel_nrconven  AT 03    
         HELP "Informe o numero do convenio, ou 0 <zero> para listar."
     tel_dsconven  AT 21   
         HELP "Informe a descricao do convenio."
         VALIDATE (tel_dsconven <> " " , "357 - O campo deve ser prenchido.")
     
     SKIP(1)
     tel_tpconven  AT 03 LABEL "Tipo de convenio  "
         HELP "Tipo de convenio (1- Normal, 2- Primeiro dia util do mes)."  
         VALIDATE (CAN-DO("1,2", STRING(tel_tpconven)), 
                   "Tipo de convenio incorreto.")
     
     tel_inobriga  AT 27              
         HELP "Ind. de obrigatoridade (0- Nao obrigatorio, 1- Obrigatorio)."
         VALIDATE (CAN-DO("0,1", STRING(tel_inobriga)),
                   "Ind. de obrigatoridade incorreto.")               
     
     tel_dddebito  AT 56  LABEL "Dia do debito "
         HELP "Informe o dia do debito em conta-corrente."
         VALIDATE (tel_dddebito > 0   AND   tel_dddebito < 31,
                   "Dia do debito incorreto.")               
     
     tel_inmesdeb  AT 03          
         HELP "Informe o indicador (0- No mes, 1- No mes seguinte)."
         VALIDATE (CAN-DO("0,1", STRING(tel_inmesdeb)),
                   "Mes do debito incorreto.")
     
     tel_intipest  AT 27 
         HELP "Informe o tipo de estouro (0- Relatorio, 1- Arquivo)."
         VALIDATE (CAN-DO("0,1", STRING(tel_intipest)),
                   "Tipo de estouro incorreto.")                
     
     tel_indescto  AT 56 LABEL "Ind. desconto "
         HELP "Desconto (0- Aceita parcial, 1- Somente total)."
         VALIDATE (CAN-DO("0,1", STRING(tel_indescto)),
                   "Indicador de desconto incorreto.")
     
     tel_inlimsld  AT 03 
         HELP "Informe o indicador de limitacao ao saldo (0- Nao, 1- Limitado)."
         VALIDATE (CAN-DO("0,1", STRING(tel_inlimsld)),
                   "Limitacao ao saldo incorreto.")

     tel_indebcre  AT 44 
         HELP "Informe o indicador  para o convenio(C- Credito , D- Debito)."
         VALIDATE (CAN-DO("C,D", CAPS(tel_indebcre)),
                   "Indicador para o convenio incorreto.")
              
     tel_intipdeb  AT 56 
         HELP "Informe o indicador de debito (0- Na folha, 1- Sempre conta)."
         VALIDATE (CAN-DO("0,1", STRING(tel_intipdeb)),
                   "Indicador de debito incorreto.")
     
     tel_lsempres  AT 03 LABEL "Lista de empresas  "
         HELP "Informe a lista de empresas conveniadas."
         VALIDATE (tel_lsempres <> " ", "357 - O campo deve ser prenchido.")
        
     tel_lsempre2  AT 24 NO-LABEL
     
     tel_lshistor  AT 03
         HELP "Informe a lista de historicos."
         VALIDATE (tel_lshistor <> " ", "357 - O campo deve ser prenchido.")
     
     tel_lshisto2  AT 12 NO-LABEL
     
     "E-mail:"     AT 03
     tel_dsdemail  NO-LABEL AT 12 SKIP
     tel_dsdemai2  NO-LABEL AT 12 SKIP
     tel_dsdemai3  NO-LABEL AT 12    
     WITH ROW 7 WIDTH 78 SIDE-LABELS OVERLAY CENTERED FRAME f_convenio.

FORM SKIP 
     b-convenio  HELP "Use as SETAS para navegar ou F4 para sair."
     WITH NO-BOX ROW 8 WIDTH 59 SIDE-LABELS OVERLAY CENTERED FRAME f_query.

/* Retorna o Convenio */
ON RETURN OF b-convenio DO:  

    ASSIGN tel_nrconven = w-convenio.nrconven.
    
    DISPLAY tel_nrconven WITH FRAME f_convenio.
       
    APPLY "GO".

END.    

VIEW FRAME f_moldura.

PAUSE 0.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.
             
DO WHILE TRUE:           

   EMPTY TEMP-TABLE w-convenio.
                    
   RUN fontes/inicia.p.
        
   CLEAR FRAME f_convenio NO-PAUSE.
   
   HIDE FRAME f_convenio NO-PAUSE.
      
   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
                     
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.
   
   END.
   
   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
        DO:          
            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "CADCNV"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            ELSE 
                 NEXT.
        END.                                  
                                             
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.    
   
   IF   glb_cddopcao <> "C"      THEN   
        IF   glb_dsdepart <> "TI"                    AND
             glb_dsdepart <> "SUPORTE"               AND
             glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
             glb_dsdepart <> "COORD.PRODUTOS"        THEN
             DO:
                 BELL.
                 MESSAGE "Opcao bloqueada para este operador.".
                 NEXT.
             END.
        
   IF   CAN-DO("A,C,E",glb_cddopcao)   THEN
        DO:
            ASSIGN glb_cdcritic = 0
                   tel_nrconven = 0.
            
            tel_nrconven:HELP = "Informe o numero do convenio, ou 0 <zero> " +
                                "para listar.".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nrconven WITH FRAME f_convenio.
            
               IF   tel_nrconven = 0   THEN
                    DO:
                        FOR EACH crapcnv WHERE crapcnv.cdcooper = glb_cdcooper
                                               NO-LOCK:
                                            
                            CREATE w-convenio.
                            ASSIGN w-convenio.nrconven = crapcnv.nrconven
                                   w-convenio.dsconven = crapcnv.dsconven.
                    
                        END.
                     
                        FIND FIRST w-convenio NO-LOCK NO-ERROR.
                     
                        IF   NOT AVAILABLE w-convenio   THEN
                             DO:
                                 glb_cdcritic = 563.
                                 LEAVE.
                             END.
                          
                        OPEN QUERY q-convenio 
                             FOR EACH w-convenio NO-LOCK BY w-convenio.nrconven.
                     
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                           UPDATE b-convenio WITH FRAME f_query.
                           LEAVE.
                     
                        END.

                        CLOSE QUERY q-convenio.

                        HIDE FRAME f_query NO-PAUSE.

                        IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                             NEXT.
                    END.    

               FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                                  crapcnv.nrconven = tel_nrconven
                                  NO-LOCK NO-ERROR.
   
               IF   NOT AVAILABLE crapcnv   THEN
                    DO:
                        glb_cdcritic = 563.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.                        
                        NEXT.
                    END.
        
               ASSIGN tel_nrconven = crapcnv.nrconven  
                      tel_dsconven = crapcnv.dsconven
                      tel_tpconven = crapcnv.tpconven  
                      tel_inobriga = crapcnv.inobriga
                      tel_dddebito = crapcnv.dddebito  
                      tel_intipdeb = crapcnv.intipdeb
                      tel_inlimsld = crapcnv.inlimsld  
                      tel_indebcre = crapcnv.indebcre
                      tel_inmesdeb = crapcnv.inmesdeb  
                      tel_intipest = crapcnv.intipest
                      tel_indescto = crapcnv.indescto  
                      tel_dsdemail = SUBSTR(crapcnv.dsdemail,1,52)
                      tel_dsdemai2 = SUBSTR(crapcnv.dsdemail,53,52)
                      tel_dsdemai3 = SUBSTR(crapcnv.dsdemail,105,52)
                      tel_lshistor = SUBSTR(crapcnv.lshistor,1,51)
                      tel_lshisto2 = SUBSTR(crapcnv.lshistor,52,63)
                      tel_lsempres = SUBSTR(crapcnv.lsempres,1,51)
                      tel_lsempre2 = SUBSTR(crapcnv.lsempres,52,51).
            
               DISPLAY tel_nrconven tel_dsconven tel_tpconven tel_inobriga  
                       tel_dddebito tel_inmesdeb tel_intipest tel_inlimsld  
                       tel_indebcre tel_intipdeb tel_indescto tel_lsempres
                       tel_lsempre2 tel_lshistor tel_lshisto2 tel_dsdemail  
                       tel_dsdemai2 tel_dsdemai3 WITH FRAME f_convenio.
               
               IF   glb_cddopcao = "C"   THEN
                    NEXT.

               LEAVE.
            
            END. /** Fim do DO WHILE TRUE **/
            
            IF   glb_cdcritic > 0                     OR
                 KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.
        END.
   
   IF   glb_cddopcao =  "A"   THEN
        DO:
            ASSIGN log_dsconven = tel_dsconven 
                   log_tpconven = tel_tpconven 
                   log_inobriga = tel_inobriga 
                   log_dddebito = tel_dddebito
                   log_inmesdeb = tel_inmesdeb  
                   log_intipest = tel_intipest
                   log_indescto = tel_indescto 
                   log_inlimsld = tel_inlimsld
                   log_indebcre = tel_indebcre
                   log_intipdeb = tel_intipdeb 
                   log_lsempres = tel_lsempres + tel_lsempre2 
                   log_lshistor = tel_lshistor + tel_lshisto2  
                   log_dsdemail = tel_dsdemail + tel_dsdemai2 + tel_dsdemai3.
                    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE  tel_dsconven tel_tpconven tel_inobriga tel_dddebito  
                       tel_inmesdeb tel_intipest tel_indescto tel_inlimsld  
                       tel_indebcre tel_intipdeb tel_lsempres tel_lsempre2
                       tel_lshistor tel_lshisto2 tel_dsdemail tel_dsdemai2  
                       tel_dsdemai3 WITH FRAME f_convenio.
            
               LEAVE.
            
            END.   

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                aux_confirma = NO.
                glb_cdcritic = 78.
                RUN fontes/critic.p.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                glb_cdcritic = 0.
                LEAVE.
            
            END.    

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma                     THEN
                 DO:
                     glb_cdcritic = 79.
                     NEXT.
                 END.

            IF   log_dsconven <> tel_dsconven   THEN
                 RUN p_gera_log ("Descricao",log_dsconven,tel_dsconven, TRUE).
            
            IF   log_tpconven <> tel_tpconven   THEN
                 RUN p_gera_log ("Tipo", STRING(log_tpconven),
                                  STRING(tel_tpconven), TRUE).
            
            IF   log_inobriga <> tel_inobriga   THEN
                 RUN p_gera_log ("Ind. de obrigatoridade", STRING(log_inobriga),
                                  STRING(tel_inobriga), TRUE).
                 
            IF   log_dddebito <> tel_dddebito   THEN
                 RUN p_gera_log ("Dia do debito", STRING(log_dddebito,"99"),
                                  STRING(tel_dddebito,"99"), TRUE).
                 
            IF   log_intipdeb <> tel_intipdeb   THEN
                 RUN p_gera_log ("Ind. de debito", STRING(log_intipdeb),
                                  STRING(tel_intipdeb), TRUE).
                 
            IF   log_inlimsld <> tel_inlimsld   THEN 
                 RUN p_gera_log ("Ind. de limit. ao saldo",STRING(log_inlimsld),
                                  STRING(tel_inlimsld), TRUE).
                                 
            IF   log_inmesdeb <> tel_inmesdeb   THEN
                 RUN p_gera_log ("Ind. mes debito", STRING(log_inmesdeb),
                                  STRING(tel_inmesdeb), TRUE).
                                 
            IF   log_intipest <> tel_intipest   THEN
                 RUN p_gera_log ("Ind. tipo estouro", STRING(log_intipest),
                                  STRING(tel_intipest), TRUE).

            IF   log_indescto <> tel_indescto   THEN
                 RUN p_gera_log ("Ind. desconto", STRING(log_indescto),
                                  STRING(tel_indescto), TRUE).
                                  
            IF   log_indebcre <> tel_indebcre   THEN
                 RUN p_gera_log ("D/C", CAPS(STRING(log_indebcre)),
                                  CAPS(STRING(tel_indebcre)), TRUE).
             
            IF   log_lsempres <> tel_lsempres + tel_lsempre2   THEN
                 RUN p_gera_log ("Lista empresas", log_lsempres,
                                  tel_lsempres + tel_lsempre2, TRUE).
             
            IF   log_lshistor <> tel_lshistor + tel_lshisto2   THEN
                 RUN p_gera_log ("Lista historicos",log_lshistor,
                                  tel_lshistor + tel_lshisto2, TRUE).
                
            IF   log_dsdemail <> tel_dsdemail + tel_dsdemai2 + tel_dsdemai3 THEN
                 RUN p_gera_log ("E-mail",log_dsdemail, tel_dsdemail +
                                  tel_dsdemai2 + tel_dsdemai3, TRUE).   
           
            FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                               crapcnv.nrconven = tel_nrconven  
                               EXCLUSIVE-LOCK NO-ERROR.
            
            ASSIGN crapcnv.dsconven = tel_dsconven  
                   crapcnv.tpconven = tel_tpconven 
                   crapcnv.inobriga = tel_inobriga
                   crapcnv.dddebito = tel_dddebito
                   crapcnv.intipdeb = tel_intipdeb
                   crapcnv.inlimsld = tel_inlimsld
                   crapcnv.inmesdeb = tel_inmesdeb 
                   crapcnv.intipest = tel_intipest
                   crapcnv.indescto = tel_indescto 
                   crapcnv.indebcre = CAPS(tel_indebcre)
                   crapcnv.dsdemail = tel_dsdemail + tel_dsdemai2 + tel_dsdemai3
                   crapcnv.lshistor = tel_lshistor + tel_lshisto2
                   crapcnv.lsempres = tel_lsempres + tel_lsempre2.
                   
            RELEASE crapcnv.
        END.    /*  Fim da opcao "A"  */
   ELSE    
   IF   glb_cddopcao = "E"   THEN    
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
               aux_confirma = NO.
               MESSAGE "Deletar - Confirma a operacao? (S/N):"
               UPDATE aux_confirma.
               LEAVE.
            
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma                     THEN
                 DO:
                     glb_cdcritic = 79.  
                     NEXT.
                 END.
                         
            FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper   AND
                               crapcnv.nrconven = tel_nrconven   
                               EXCLUSIVE-LOCK NO-ERROR.
            
            DELETE crapcnv.
            
            RELEASE crapcnv.
            
            RUN p_gera_log ("", "", "", FALSE).
        END.  /*  Fim da opcao "E"  */
   ELSE
   IF   glb_cddopcao = "I"   THEN        
        DO:
            ASSIGN tel_nrconven = 0   tel_dsconven = ""   
                   tel_tpconven = 1   tel_inobriga = 0    
                   tel_dddebito = 0   tel_intipdeb = 0    
                   tel_inlimsld = 0   tel_indebcre = "C"  
                   tel_inmesdeb = 0   tel_intipest = 0    
                   tel_indescto = 0   tel_dsdemail = ""   
                   tel_dsdemai2 = ""  tel_dsdemai3 = ""   
                   tel_lshistor = ""  tel_lshisto2 = ""   
                   tel_lsempres = ""  tel_lsempre2 = "".
 
            tel_nrconven:HELP = "Informe o numero do convenio ".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nrconven WITH FRAME f_convenio.
               
               IF   tel_nrconven = 0   THEN
                    DO:
                        glb_dscritic = "Informe um numero para o convenio.".
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
                 
               LEAVE.
            
            END.   

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  
                 NEXT.

            IF   CAN-FIND (crapcnv WHERE 
                           crapcnv.cdcooper = glb_cdcooper AND
                           crapcnv.nrconven = tel_nrconven NO-LOCK)   THEN
                 DO:                           
                     glb_cdcritic = 793.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE  tel_dsconven tel_tpconven tel_inobriga tel_dddebito  
                       tel_inmesdeb tel_intipest tel_indescto tel_inlimsld  
                       tel_indebcre tel_intipdeb tel_lsempres tel_lsempre2
                       tel_lshistor tel_lshisto2 tel_dsdemail tel_dsdemai2  
                       tel_dsdemai3 WITH FRAME f_convenio.
            
               LEAVE.
            
            END. 
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  
                 NEXT.
                     
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                aux_confirma = NO.
                MESSAGE "Cadastrar - Confirma " +
                        "operacao? (S/N):" UPDATE aux_confirma.
                LEAVE.
                
            END.      
                                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma                     THEN
                 DO:
                     glb_cdcritic = 79.
                     NEXT.      
                 END.
                              
            CREATE crapcnv.    
            ASSIGN crapcnv.cdcooper = glb_cdcooper
                   crapcnv.nrconven = tel_nrconven
                   crapcnv.dsconven = tel_dsconven
                   crapcnv.inobriga = tel_inobriga
                   crapcnv.tpconven = tel_tpconven
                   crapcnv.dddebito = tel_dddebito
                   crapcnv.intipdeb = tel_intipdeb
                   crapcnv.inlimsld = tel_inlimsld
                   crapcnv.inmesdeb = tel_inmesdeb
                   crapcnv.intipest = tel_intipest
                   crapcnv.indescto = tel_indescto
                   crapcnv.indebcre = CAPS(tel_indebcre)
                   crapcnv.dsdemail = tel_dsdemail + tel_dsdemai2 + tel_dsdemai3
                   crapcnv.lshistor = tel_lshistor + tel_lshisto2
                   crapcnv.lsempres = tel_lsempres + tel_lsempre2.
                                                                    
            RELEASE crapcnv.
        END.    /*  Fim da opcao "I"  */

END.   /*  Fim do DO WHILE TRUE  */


PROCEDURE p_gera_log:

    DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlrcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlcampo2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_tipdolog AS LOG  NO-UNDO.

    IF   par_tipdolog   THEN 
         DO:
             UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")    +
                               " "     + STRING(TIME,"HH:MM:SS")  + "' --> '" +
                               " Operador "  + glb_cdoperad    + " -"         +
                               " Alterou do convenio " + STRING(tel_nrconven) +
                               " o campo " + par_dsdcampo + " de "            +
                               par_vlrcampo + " para " + par_vlcampo2 + "."   +
                               " >> log/cadcnv.log").
             RETURN.
         END.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")  + " " +
                        STRING(TIME,"HH:MM:SS")    + "' --> '"           +
                      " Operador "  + glb_cdoperad + " -"                +
                      " Excluiu o convenio " + STRING(tel_nrconven)      +     
                      " - " +  tel_dsconven  + "." + 
                      " >> log/cadcnv.log").

END PROCEDURE.

/*............................................................................*/
 
