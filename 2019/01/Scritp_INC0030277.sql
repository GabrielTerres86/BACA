declare
cursor telefone is
SELECT a_rowid
  FROM (SELECT nrcpfcgc
  ,a.nrtelefo
  ,a.rowid a_rowid
  FROM craptfc a
  JOIN crapttl b
  ON a.cdcooper = b.cdcooper
  AND a.idseqttl = b.idseqttl
  AND a.nrdconta = b.nrdconta) x
  ,tbcadast_pessoa b
  WHERE x.nrcpfcgc = b.nrcpfcgc
  AND NOT EXISTS (SELECT 1
  FROM tbcadast_pessoa_telefone c
  WHERE b.idpessoa = c.idpessoa
  AND x.nrtelefo = c.nrtelefone);
begin
  for c1 in telefone loop
    update craptfc ct
    set ct.prgqfalt = ct.prgqfalt
    where ct.rowid = c1.a_rowid;    
  end loop;
  commit;
end;
