
UPDATE TBCADAST_PESSOA_TELEFONE
   SET nmpessoa_contato = REPLACE( nmpessoa_contato, CHR(26) )
where instr( nmpessoa_contato, chr(26) ) > 0;


UPDATE TBCADAST_PESSOA_BEM
   SET dsbem = REPLACE( dsbem, CHR(26) )
where instr( dsbem, chr(26) ) > 0;

commit;