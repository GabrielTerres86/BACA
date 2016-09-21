/*..............................................................................

   Programa: includes/endereco_conta_itg.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2011                        Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: On-Line
   Objetivo  : Montar endereco para cadastro da conta itg.
               
   Alteracoes:
                              
..............................................................................*/

FUNCTION f_endereco_ctaitg RETURN CHAR(INPUT par_dsendere AS CHAR,
                                       INPUT par_nrendres AS INTE,
                                       INPUT par_nrdoapto AS INTE,
                                       INPUT par_cddbloco AS CHAR):
  
    DEF VAR aux_dstiplog AS CHAR NO-UNDO.
    DEF VAR aux_dsendere AS CHAR NO-UNDO.
    DEF VAR aux_nrendres AS CHAR NO-UNDO.
    DEF VAR aux_dsendtmp AS CHAR NO-UNDO.
    DEF VAR aux_dsiniend AS CHAR NO-UNDO.
    DEF VAR aux_dsaparta AS CHAR NO-UNDO.

    ASSIGN aux_dstiplog = "AL,AL.,AL:,ALAMEDA,ALAMEDA:,AV,AV.,AV:,AVENIDA," +
                          "AVENIDA:,ROD,ROD.,ROD:,RODOVIA,RODOVIA:,R,R.,R:," +
                          "RUA,RUA:,V,V.,V:,VIA,VIA:"
           aux_dsendere = TRIM(par_dsendere)
           aux_dsiniend = ENTRY(1,aux_dsendere," ").
 
    IF  CAN-DO(aux_dstiplog,aux_dsiniend)  THEN 
        ASSIGN aux_dsendere = TRIM(SUBSTR(aux_dsendere,
                                          LENGTH(aux_dsiniend) + 2)).
                                                    
    IF  LENGTH(aux_dsendere) > 35  THEN
        DO:
            RUN fontes/abreviar.p (INPUT aux_dsendere,
                                   INPUT 35,
                                  OUTPUT aux_dsendere).
 
            IF  LENGTH(aux_dsendere) > 35  THEN
                ASSIGN aux_dsendere = SUBSTR(aux_dsendere,1,35).
        END.                            

    ASSIGN aux_dsiniend = aux_dsendere.

    IF  par_nrendres > 0  THEN
        DO:
            ASSIGN aux_nrendres = " " + STRING(par_nrendres)
                   aux_dsendtmp = aux_dsendere + aux_nrendres.

            IF  LENGTH(aux_dsendtmp) > 35  THEN 
                ASSIGN aux_dsiniend = SUBSTR(aux_dsendere,1,
                                            (LENGTH(aux_dsendere) -
                                            (LENGTH(aux_dsendtmp) - 35)))
                       aux_dsendtmp = aux_dsiniend + aux_nrendres.

            ASSIGN aux_dsendere = aux_dsendtmp.
        END.                          
                        
    ASSIGN aux_dsaparta = "".
                    
    IF  par_nrdoapto > 0  THEN
        ASSIGN aux_dsaparta = "AP." + STRING(par_nrdoapto).
                        
    IF  TRIM(par_cddbloco) <> ""  THEN   
        ASSIGN aux_dsaparta = (IF aux_dsaparta <> "" THEN
                                  aux_dsaparta + " "
                               ELSE
                                  "") + "BL." + TRIM(crapenc.cddbloco).
                                               
    IF  aux_dsaparta <> ""  THEN
        DO:
            ASSIGN aux_dsendtmp = aux_dsendere + " " + aux_dsaparta.

            IF  LENGTH(aux_dsendtmp) > 35  THEN 
                ASSIGN aux_dsendtmp = SUBSTR(aux_dsiniend,1,
                                            (LENGTH(aux_dsiniend) -
                                            (LENGTH(aux_dsendtmp) - 35)))
                       aux_dsendtmp = aux_dsendtmp + aux_nrendres + " " +
                                      aux_dsaparta.

            ASSIGN aux_dsendere = aux_dsendtmp.
        END.
                        
    RETURN aux_dsendere.
    
END FUNCTION.

/*............................................................................*/
