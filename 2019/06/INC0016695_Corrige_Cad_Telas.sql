/* 
Solicita��o: INC0016695
Objetivo   : Na tabela CRAPTEL, para cada item do campo CDOPPTEL � obrigat�rio ter sua respectiva LSOPPTEL.
             Ou seja, se a CDOPPTEL possui dois valores, ent�o a LSOPPTEL tamb�m necessita de dois valores.
Autor      : Jackson
*/

UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14167;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14169;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14171;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14175;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14177;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14179;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14181;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14183;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14185;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14187;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14189;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14191;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14193;
UPDATE craptel SET lsopptel = 'ACESSO,MANUTENCAO' WHERE progress_recid = 14197;

COMMIT;





