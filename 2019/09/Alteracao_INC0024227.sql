/*
  INC0024227 - Lotes relacionados a caixa com operador gerado pelo projeto de portabilidade
  Realiza alteração dos lotes, atribuindo os códigos de operador de acordo com os caixas abertos
*/

UPDATE craplot
   SET cdoperad = 'f0060156', cdopecxa = 'f0060156'
 WHERE craplot.progress_recid IN (26404735, 26404734); 

UPDATE craplot
   SET cdoperad = 'F0013674', cdopecxa = 'F0013674'
 WHERE craplot.progress_recid IN (26443630, 26443629, 26462754, 26462753);

COMMIT;
