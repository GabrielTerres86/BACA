/*
  INC0025194 - Lote relacionado a caixa com operador gerado pelo projeto de portabilidade
  Realiza altera��o do lote, atribuindo os c�digo de operador de acordo com o caixa aberto
*/

UPDATE craplot
   SET cdoperad = 'f0060156', cdopecxa = 'f0060156'
 WHERE craplot.progress_recid = 26571250; 

COMMIT;
