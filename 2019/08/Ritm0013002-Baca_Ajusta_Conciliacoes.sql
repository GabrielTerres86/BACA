Declare

  cursor cr_conc is
  select *
  from tbcobran_conciliacao_ieptb conc
  where conc.idrecurso_movto <> 0
  order by conc.idconciliacao asc, conc.idrecurso_movto;
  
  vr_idconciliacao number;
  vr_idted         number;
  
Begin
  vr_idconciliacao:= null;
  vr_idted        := null;
  --
  for rw_conc in cr_conc loop
    --
    if vr_idted is null then
       vr_idted        := rw_conc.idrecurso_movto;
       vr_idconciliacao:= rw_conc.idconciliacao;
    end if;
    --
    if rw_conc.idrecurso_movto = vr_idted then
       /*Atualiza id de conciliacao na TED*/
       update tbfin_recursos_movimento trm
       set trm.idconciliacao = vr_idconciliacao
       where trm.idlancto = rw_conc.idrecurso_movto;
       --
      /*Atualiza id de conciliacao no Titulo*/
      update tbcobran_retorno_ieptb ret
      set ret.idconciliacao = vr_idconciliacao
      where  ret.idretorno = rw_conc.idretorno_ieptb; 
      --      
    else
       vr_idted:= rw_conc.idrecurso_movto;
       vr_idconciliacao:= rw_conc.idconciliacao;

       /*Atualiza id de conciliacao na TED*/
       update tbfin_recursos_movimento trm
       set trm.idconciliacao = vr_idconciliacao
       where trm.idlancto = rw_conc.idrecurso_movto;
       
      /*Atualiza id de conciliacao no Titulo*/
      update tbcobran_retorno_ieptb ret
      set ret.idconciliacao = vr_idconciliacao
      where  ret.idretorno = rw_conc.idretorno_ieptb;     
    end if;
    --
    update tbcobran_conciliacao_ieptb 
    set idconciliacao_old = rw_conc.idconciliacao
    where idconciliacao = rw_conc.idconciliacao;
    
    dbms_output.put_line('TED - '||vr_idted||' Titulo - '||rw_conc.idretorno_ieptb||' Conciliacao - '||vr_idconciliacao);

  --Selecina todas as conciliações (Loop)
  --Para cada linha de conciliação atualizar as informacoes das tabelas de ted e titulo
    --Criar regra para gravar o id da conciliação correto na ted e no titulo. Quando for uma ted para
    --um titulo, não havera problema, porém, quando houver mais de um titulo, o id de conciliacao do
    --primeiro registro é que deve ser atualizado no id de conciliacao do titulo.
  --Para cada conciliação, seu id deve ser gravado no id_conciliacao_old, como uma forma de historico.
  -- Necessário avaliar se manteremos as informacoes de recurso (ted) e retorno(titulo) gravadas na 
  --conciliacao ou se será gravado zero.  
  end loop;
  
  commit;
  
Exception
  When others then
    dbms_output.put_line('Erro atualizar conciliacaoes '||sqlerrm);
End;



