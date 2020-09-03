declare 

  vr_cddopcao varchar2(10);
  
begin
  
  for i in 1 .. 3 loop

    if i = 1 then
      vr_cddopcao := 'C';
    elsif i = 2 then
      vr_cddopcao := 'I';
    elsif i = 3 then
      vr_cddopcao := 'A';
    end if;      

    insert into crapace (nmdatela,   cddopcao,cdoperad    ,nmrotina,cdcooper    ,nrmodulo,idevento,idambace)
    select               'MANPLD',vr_cddopcao,ope.cdoperad,' '     ,ope.cdcooper,1       ,0       ,2       
     where ope.cdsitope = 1
       and not exists (select 1 
                         from crapace ace
                        where ace.cdcooper = ope.cdcooper
                          and ace.cdoperad = ope.cdoperad
                          and ace.cddopcao = vr_cddopcao
                          and ace.nmdatela = 'MANPLD');
       
    commit;

  end loop;  
  
end;