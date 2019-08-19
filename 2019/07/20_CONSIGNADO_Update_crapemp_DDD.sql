declare
cursor c_emp is
select a.cdcooper, a.cdempres,
       a.nmextemp, 
       a.nrfonemp,
       trim(UPPER(a.nmcidade)) nmcidade,
       a.cdufdemp,
       trim(gene0007.fn_caract_acento (pr_texto    => a.nrfonemp,
                                      pr_insubsti => 1,
                                      pr_dssubsin =>'@#$&%¹²³ªº°*!?<>/\|()-.')) fone 
from crapemp a
where trim(a.nrfonemp) is not null
and instr(a.nrfonemp,'A') = 0
order by a.nrfonemp;

aux_ddd  crapemp.nrdddemp%type;
aux_fone crapemp.nrfonemp%type;
aux_count_ddd  number(6);
aux_count  number(6);
begin
  aux_count:= 0;
  aux_count_ddd:= 0;
  for r_emp in c_emp
  loop
    if length(r_emp.fone) > 9 and
       substr(r_emp.fone,1,1) <> 9 then
       if substr(r_emp.fone,1,1) = 0 then
          aux_ddd := substr(r_emp.fone,2,2);
          aux_fone:= substr(trim(r_emp.fone),4);
       else
          aux_ddd := substr(r_emp.fone,1,2);
          aux_fone:= substr(trim(r_emp.fone),3);
       end if;
       aux_count_ddd:=aux_count_ddd +1;
    --  dbms_output.put_line('original; '||r_emp.fone||'  ;DDD; '||aux_ddd||' ;Fone;'||aux_fone||' ;cidade;'||r_emp.nmcidade||' ;UF;'||r_emp.cdufdemp);
    else
       
       if r_emp.nmcidade In ('BLUMENAU','BLUMENAU','GASPAR','ITAJAÍ','ITAJAI','INDAIAL','NAVEGANTES',
          'TROMBUDO CENTRAL','MASSARANDUBA','SCHROEDER','AGROLANDIA','BRUSQUE','LONTRAS',
          'JARAGUA DO SUL','BALNEARIO PICARRAS','BALNEARIO CAMBORIU','ITUPORANGA','LAURENTINO',
          'PRESIDENTE GETULIO','CAMBORIU','TIMBO','AURORA','NBAVEGANTES','IBIRAMA','ILHOTA','ASCURRA',
          'APIUNA','RIO NEGRINHO','JOINVILLE','POMERODE','SAO BENTO DO SUL','TAIO','GUARAMIRIM',
          'POUSO REDONDO','PENHA','RODEIO','ARAQUARI','RIO DO SUL','RIO DO OESTE','RIO DOS CEDROS',
          'TIMBÓ','JARAGUÁ DO SUL','GUABIRUBA','BALN CAMBORIU','ITAPEMA','BLUMENUA','NAVEGGANTES',
          'BALNEARIO DE PICARRAS','LUIZ ALVES','BENEDITO NOVO','DOUTOR PEDRINHO','WITMARSUM','DONA EMMA',
          'PRES GETULIO','JOSE BOITEUX','APIUNA','BAL CAMBORIU','LUIS ALVES','APIUNA]','GARUVA',
          'SÃO BENTO DO SUL','CAMPO ALEGRE'       ) then
          aux_ddd := 47; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('PALHOCA','PALHOÇA','FORQUILHINHA','ICARA','TUBARAO',
          'SAO JOSE','FLORIANOPOLIS','FPOLIS','CRICIUMA','CAPIVARI DE BAIXO','BIGUACU',
          'ANTONIO CARLOS','PRAIA GRANDE','SÃO JOSÉ','IMBITUBA','COCAL DO SUL','CRIICUMA',
          'GOV CELSO RAMOS','GOVERNADOR CELSO RAMOS','LAGUNA') THEN
          aux_ddd := 48; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       ELSIF r_emp.nmcidade In ('PINHAIS','CURITIBA') THEN   
          aux_ddd := 41; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('LAGES','CHAPECO','URUPEMA','XAXIM','VIDEIRA') THEN   
          aux_ddd := 49; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('PATO BRANCO','FRANCISCO BELTRAO','MARMELEIRO','DOIS VIZINHOS') THEN             
          aux_ddd := 46; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('CANOAS','PORTO ALEGRE','CAMPO BOM') THEN             
          aux_ddd := 51; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('SANTANA DE PARNAIBA','OSASCO','GUARULHOS') THEN 
          aux_ddd := 11; 
          aux_fone:= r_emp.fone;  
          aux_count_ddd:=aux_count_ddd +1;
       elsif r_emp.nmcidade In ('CASCAVEL') THEN 
          aux_ddd := 45; 
          aux_fone:= r_emp.fone;
       elsif r_emp.nmcidade In ('UNIAO DA VITORIA','PORTO UNIAO') THEN 
          aux_ddd := 42; 
          aux_fone:= r_emp.fone;
          aux_count_ddd:=aux_count_ddd +1;
        elsif r_emp.nmcidade In ('IVATE') THEN 
          aux_ddd := 44; 
          aux_fone:= r_emp.fone; 
          aux_count_ddd:=aux_count_ddd +1; 
        elsif r_emp.nmcidade In ('MANAUS') THEN 
          aux_ddd := 92; 
          aux_fone:= r_emp.fone;  
          aux_count_ddd:=aux_count_ddd +1;
       ELSE   
         aux_ddd:= 000;
         aux_fone:= r_emp.fone; 
      --   dbms_output.put_line('original; '||r_emp.fone||'  ;DDD; '||aux_ddd||' ;Fone;'||aux_fone||' ;cidade;'||r_emp.nmcidade||' ;UF;'||r_emp.cdufdemp||' ;empresa;'||r_emp.cdcooper||'-'|| r_emp.cdempres);
         --dbms_output.put_line(' ######## fone ...'||r_emp.fone||' cidade:'|| r_emp.nmcidade||' UF:'||r_emp.cdufdemp);
         aux_count:= aux_count +1;
       END IF;
     --  dbms_output.put_line('original; '||r_emp.fone||'  ;DDD; '||aux_ddd||' ;Fone;'||aux_fone||' ;cidade;'||r_emp.nmcidade||' ;UF;'||r_emp.cdufdemp);
     -- dbms_output.put_line('fone ...'||r_emp.fone||' cidade:'|| r_emp.nmcidade||' DDD: '||aux_ddd);

    end if;
  begin
     update crapemp a
       set a.nrdddemp = aux_ddd,
           a.nrfonemp = aux_fone
     where a.cdcooper = r_emp.cdcooper
       and a.cdempres = r_emp.cdempres;
  exception
    when others then
    dbms_output.put_line('Erro na empresa:'||r_emp.cdcooper||'-'|| r_emp.cdempres||'  -  '||sqlerrm);
  end;
  commit;
    
  end loop;

  dbms_output.put_line('Sem DDD: '||aux_count||'  - COM DDD :'||aux_count_ddd);
end;  
/