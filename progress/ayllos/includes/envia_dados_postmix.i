/*.............................................................................

   Programa: includes/envia_dados_postmix.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Abril/2008                         Ultima atualizacao: 15/09/2010
       
   Dados referetes ao programa:

   Frequencia: Sempre que chamado pelos programas que utilizam o envio de 
               informacoes para a PostMix.

   Objetivo  : Chamar rotina de upload dos arquivos para Postmix e colocar
               o registro do arquivo que foi gravado na gndcimp para enviado.
               
   Observacao: Para executar o UPLOAD e aguardar que o mesmo seja finalizado,
               eh necessario chamar esta includes com o argumento AGUARDA
               conforme exemplo:
               { includes/envia_dados_postmix.i &AGUARDA="SIM" }

               Caso o UPLOAD deva ser feito em modo background, a chamada nao
               devera conter o argumento conforme exemplo:
               { includes/envia_dados_postmix.i }

   Alteracoes: 15/08/2008 - Incluido argumento AGUARDA (Evandro/Gabriel).
   
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop 
                            nos parametros do script upload_postmix.sh (Elton).
..............................................................................*/
                               
DO TRANSACTION:          
   
   
   IF   "{&AGUARDA}" = "SIM"   THEN
        UNIX SILENT VALUE("/usr/local/cecred/bin/upload_postmix.sh " +
                          aux_nmdatspt + " " + crapcop.dsdircop).
   ELSE
        UNIX SILENT VALUE("/usr/local/cecred/bin/upload_postmix.sh " +
                          aux_nmdatspt + " " + crapcop.dsdircop + " &").
      
   
   FIND LAST gndcimp WHERE 
             gndcimp.cdcooper = glb_cdcooper   AND
             gndcimp.dtmvtolt = glb_dtmvtolt   AND
             gndcimp.nmarquiv = aux_nomedarq
             EXCLUSIVE-LOCK NO-ERROR.

   IF   AVAILABLE gndcimp   THEN  
        gndcim.flgenvio = TRUE.  
                   
END.                  
    
/*............................................................................*/
