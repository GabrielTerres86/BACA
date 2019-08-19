-- Ajustar nome de prospect no CRM (Cadastro unificado). - Wagner - Sustentação.
-- INC0033391  
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'NOVA GERACAO CONFECCOES EIRELI'
 WHERE a.nrcpfcgc = 09110124000102;
 
-- INC0033374
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'B. TRANSPORTES LTDA'
 WHERE a.nrcpfcgc = 04353469002702;
 
 COMMIT;
 
 -- Alterar a situação da conta para "4 - Encerrada por demissão".
-- Wagner - Sustentação - INC0033352 e SCTASK0048691.
UPDATE crapass a
   SET a.cdsitdct = 4 -- Encerrada por demissão
 WHERE a.cdcooper = 1
   and a.nrdconta  IN( 9461930,9021302,8654395,9453571);
   
COMMIT;
   