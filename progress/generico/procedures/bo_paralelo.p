/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------------+-----------------------------------+
  | Rotina Progress                           | Rotina Oracle PLSQL               |
  +-------------------------------------------+-----------------------------------+
  | sistema/generico/procedures/bo_paralelo.p | GENE0001                          |
  |          --> gera_ID                      | GENE0001.pc_gera_ID_paralelo      |
  |          --> ativa_paralelo               | GENE0001.pc_ativa_paralelo        |
  |          --> aguarda_paralelos            | GENE0001.pc_aguarda_paralelo      |
  |          --> finaliza_paralelo            | GENE0001.pc_encerra_paralelo      |
  +-------------------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/*.............................................................................

    Programa: bo_paralelo.p
    Autor   : Evandro
    Data    : Julho/2011                     Ultima Atualizacao: 13/12/2013
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a processamento de programas em paralelo
                    
    Alteracoes: 13/12/2013 - Incluir VALIDATE crappar. (Lucas R.)
    
............................................................................. */   
   
   
/* Procedure que gera um identificador randomico para cada programa que
   executara em paralelo */
PROCEDURE gera_ID:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEFINE OUTPUT PARAM par_idparale    AS INT                      NO-UNDO.

    DO  WHILE TRUE:

        par_idparale = RANDOM(1,999999).

        /* verifica se o ID ja esta em uso */
        FIND FIRST crappar WHERE crappar.idparale = par_idparale
                                 NO-LOCK NO-ERROR.
    
        IF  AVAILABLE crappar  THEN
            NEXT.
            
        LEAVE.
    END.
    
    RETURN "OK".
END PROCEDURE.


/* Procedure que inicializa os controles de um programa em paralelo */
PROCEDURE ativa_paralelo:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEFINE INPUT PARAM  par_idparale    AS INT                      NO-UNDO.
    DEFINE INPUT PARAM  par_idprogra    AS INT                      NO-UNDO.
    
    /* registro de controle de cada programa */
    CREATE crappar.
    ASSIGN crappar.idparale = par_idparale
           crappar.idprogra = par_idprogra
           crappar.flcontro = YES.

    VALIDATE crappar.
    
    RETURN "OK".
END PROCEDURE.


/* Procedure que finaliza os controles de um programa em paralelo */
PROCEDURE finaliza_paralelo:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEFINE INPUT PARAM  par_idparale    AS INT                      NO-UNDO.
    DEFINE INPUT PARAM  par_idprogra    AS INT                      NO-UNDO.
    
    FIND crappar WHERE crappar.idparale = par_idparale AND
                       crappar.idprogra = par_idprogra AND
                       crappar.flcontro = YES
                       EXCLUSIVE-LOCK  NO-ERROR.
    
    DELETE crappar.
    
    RETURN "OK".
END PROCEDURE.


/* Procedure para aguardar a finalizacao dos programas em paralelo */
PROCEDURE aguarda_paralelos:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEFINE INPUT PARAM  par_idparale    AS INT                      NO-UNDO.
    DEFINE INPUT PARAM  par_qtdproce    AS INT                      NO-UNDO.
    
    DEFINE VARIABLE     aux_qtdproce    AS INT                      NO-UNDO.
        
    DO  WHILE TRUE:
    
        /* aguarda todos acabarem */
        IF  par_qtdproce = 0  THEN
            DO:     
                /* Se tiver algum registro de controle, aguarda */
                FIND FIRST crappar WHERE crappar.idparale = par_idparale AND
                                         crappar.flcontro = YES
                                         NO-LOCK NO-ERROR.
                                     
                IF  AVAIL crappar  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
            END.
        ELSE
            DO:
                aux_qtdproce = 0.
                
                FOR EACH crappar WHERE crappar.idparale = par_idparale AND
                                       crappar.flcontro = YES
                                       NO-LOCK:
                                       
                    aux_qtdproce = aux_qtdproce + 1.
                END.
                
                /* se atingiu o maximo de processos, aguarda */
                IF  aux_qtdproce = par_qtdproce  THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.                        
            END.
        
        LEAVE.
    END.

    RETURN "OK".
END PROCEDURE.

/* .......................................................................... */
