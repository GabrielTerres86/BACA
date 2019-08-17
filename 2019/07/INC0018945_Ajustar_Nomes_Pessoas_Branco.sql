-- Ajustar nomes de pessoas com nome em branco em nossa base
UPDATE tbcadast_pessoa aa
SET aa.nmpessoa = 'GISELA WILL'
WHERE aa.nrcpfcgc = 94865426949;

UPDATE tbcadast_pessoa aa
SET aa.nmpessoa = 'GISELE O. STAHELIN'
WHERE aa.nrcpfcgc = 2330169965;

UPDATE tbcadast_pessoa aa
SET aa.nmpessoa = 'ELIANE K. BAULER'
WHERE aa.nrcpfcgc = 89781724900;

COMMIT;

