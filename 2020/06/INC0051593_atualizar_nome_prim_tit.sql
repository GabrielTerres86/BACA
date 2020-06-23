/* 
Solicitação: INC0051593
Objetivo   : Atualizar as colunas CRAPASS.NMPRIMTL e TBCADAST_PESSOA.NMPESSOA para os casos em que essa informação está 
             em branco.
Autor      : Edmar
*/
declare
  cursor c1 is 
    select a.nrcpfcgc, a.cdcooper, a.nrdconta, a.nmprimtl, p.nmpessoa, p.idpessoa, ph.dsvalor_anterior, ph.dhalteracao, a.progress_recid chave_crapass
    from crapass a
    inner join tbcadast_pessoa p on (p.nrcpfcgc = a.nrcpfcgc)
    inner join tbcadast_pessoa_historico ph on (ph.idpessoa = p.idpessoa)
    where a.nmprimtl = ' '
      and ph.idcampo = 3  /* TBCADAST_PESSOA.NMPESSOA */
      and ph.dsvalor_anterior is not null
      and ph.dsvalor_novo = ' '
    order by a.nrcpfcgc, a.cdcooper, a.nrdconta, ph.nrsequencia;
begin
  for i in c1 loop
    update CRAPASS a
    set a.nmprimtl = i.dsvalor_anterior
    where a.progress_recid = i.chave_crapass;
    
    update TBCADAST_PESSOA p
    set p.nmpessoa = i.dsvalor_anterior
    where p.idpessoa = i.idpessoa;
  end loop;
  COMMIT;
end;
