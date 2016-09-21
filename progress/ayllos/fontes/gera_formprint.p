/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/gera_formprint.p         | FORM0001.pc_gera_formprint        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: fontes/gera_formprint.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : junho/2007                        Ultima atualizacao: 03/01/2014

   Dados referentes ao programa:

   Frequencia: (Batch).
   Objetivo  : Criar e executar script para geracao e impressao de formularios
               FormPrint, tudo em background.

   Alteracao : 31/08/2007 - Criacao de arquivo de controle para execucao do 
                            script (Julio).
                            
               13/09/2007 - Chamada para o script ControleLicensa.sh, solucao
                            para o problema de licensas de uso simultaneo do
                            FormPrint (Julio)

               02/05/2008 - Permissao de gravacao para o arquivos FormPrint.tmp
                            (Julio)
                            
               03/01/2014 - Retirado comando fila de impressão (Tiago).             
.............................................................................*/

DEFINE STREAM str_1.

DEFINE INPUT PARAMETER par_nmscript AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_dsformsk AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_nmarqdat AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_nmarqimp AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_dsdestin AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_nmforimp AS CHARACTER                      NO-UNDO.
DEFINE INPUT PARAMETER par_flgexect AS LOGICAL                        NO-UNDO.

DEFINE VARIABLE aux_nrarquiv        AS INTEGER                        NO-UNDO.

ASSIGN aux_nrarquiv = RANDOM(1, 99999) + TIME.

OUTPUT STREAM str_1 TO VALUE(par_nmscript) APPEND.

PUT STREAM str_1 "umask a=rwx" SKIP.

PUT STREAM str_1 "> controles/FormPrint_" + STRING(aux_nrarquiv, "999999") +
                 ".Exec" FORMAT "x(132)" SKIP.

PUT STREAM str_1 "/usr/local/bin/ControleLicenca.sh" SKIP.

PUT STREAM str_1 "FormPrint -f " + par_dsformsk + " < " + 
                 par_nmarqdat + " > " + par_nmarqimp + 
                 " 2>>/tmp/FormPrint.tmp" FORMAT "x(132)"  SKIP.

PUT STREAM str_1 "mv " + TRIM(par_nmarqdat) + " salvar/" +
                 SUBSTRING(TRIM(par_nmarqdat), 5, LENGTH(TRIM(par_nmarqdat))) 
                           FORMAT "x(132)" SKIP. 

PUT STREAM str_1 "rm controles/FormPrint_" + STRING(aux_nrarquiv, "999999") +
                 ".Exec" FORMAT "x(132)" SKIP.

OUTPUT STREAM str_1 CLOSE. 

IF   par_flgexect   THEN
     DO:
        /* Permicao para execucao do script */
        UNIX SILENT VALUE("chmod 777 " + par_nmscript + " >/dev/null"). 
        /* Dispara execucao do sript em background */
        UNIX SILENT VALUE("sh ./" + par_nmscript + " &").
     END.

/*...........................................................................*/
