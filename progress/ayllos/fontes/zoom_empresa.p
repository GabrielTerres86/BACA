/*.............................................................................

   Programa: fontes/zoom_empresa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2006                          Ultima alteracao: 25/03/2009  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela crapemp - Cadastro de empresas.

   Alteracoes: 15/12/2006 - Criado evento para tratar saida do browse (Diego).
   
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
    
               25/05/2010 - Adaptado para usar BO (Jose Luis, DB1)
               
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/var_online.i }
{ includes/gg0000.i}

DEF SHARED VAR shr_cdempres LIKE crapemp.cdempres                      NO-UNDO.
DEF SHARED VAR shr_nmresemp LIKE crapemp.nmresemp                      NO-UNDO.

DEF QUERY q_crapemp FOR tt-crapemp.
 
DEF BROWSE b_crapemp QUERY q_crapemp
    DISPLAY tt-crapemp.cdempres COLUMN-LABEL "Codigo"
            tt-crapemp.nmresemp COLUMN-LABEL "Empresa"
            WITH 10 DOWN OVERLAY TITLE "EMPRESA".    
          
FORM b_crapemp HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_crapemp.          

IF  NOT aux_fezbusca THEN
    DO: 
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().

        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                RUN busca-crapemp IN h-b1wgen0059
                    ( INPUT glb_cdcooper,
                      INPUT 0,
                      INPUT "",
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapemp ).
           
                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

ON END-ERROR OF b_crapemp
   DO:
       HIDE FRAME f_crapemp.
   END.

ON RETURN OF b_crapemp 
   DO:
       ASSIGN shr_cdempres = tt-crapemp.cdempres
              shr_nmresemp = tt-crapemp.nmresemp.
          
       CLOSE QUERY q_crapemp.               
       
       APPLY "END-ERROR" TO b_crapemp.
                 
   END.

   OPEN QUERY q_crapemp FOR EACH tt-crapemp NO-LOCK.
   
   SET b_crapemp WITH FRAME f_crapemp.
   
/* .......................................................................... */
 
