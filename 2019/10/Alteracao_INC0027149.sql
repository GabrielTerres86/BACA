/*
  INC0027149 - Lotes relacionados a caixa com operador gerado pelo projeto de portabilidade
  Realiza alteração dos lotes, atribuindo os códigos de operador de acordo com os caixas abertos
*/

UPDATE craplot SET cdoperad = 'f0090410', cdopecxa = 'f0090410' WHERE craplot.progress_recid = 26871832;
UPDATE craplot SET cdoperad = 'f0120078', cdopecxa = 'f0120078' WHERE craplot.progress_recid = 26863473;
UPDATE craplot SET cdoperad = 'f0140098', cdopecxa = 'f0140098' WHERE craplot.progress_recid = 26873284;

COMMIT;
