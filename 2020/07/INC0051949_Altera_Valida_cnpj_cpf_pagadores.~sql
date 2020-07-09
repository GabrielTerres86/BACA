/* INC0051949 - Atualizar tipo de inscrição dos pagadores*/
declare

vr_stsnrcal boolean;
vr_inpessoa integer;

begin
  
   for rw_sab in (select sab.rowid, sab.* 
                  from crapsab  sab
                  order by sab.cdcooper) loop
     vr_stsnrcal:= false;
     /*Validar CPF*/ 
     gene0005.pc_valida_cpf (rw_sab.nrinssac,
                              vr_stsnrcal);    
     if rw_sab.cdtpinsc = 1 and vr_stsnrcal THEN 
        /*CPF válido e tipo de inscrição correta*/
        continue;
     elsif rw_sab.cdtpinsc = 1 and not vr_stsnrcal THEN    
         --
         if length(rw_sab.nrinssac) <= 14 then
             /* Valida o CNPJ */
             gene0005.pc_valida_cnpj (rw_sab.nrinssac,
                                     vr_stsnrcal);    
             if  vr_stsnrcal  then
               dbms_output.put_line('Altera PF para PJ - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Ins - '||rw_sab.nrinssac ||' T - '||rw_sab.cdtpinsc);             
               update crapsab sab
               set sab.cdtpinsc = 2
               where sab.rowid = rw_sab.rowid;
             end if;  
         else
             update crapsab sab
             set sab.cdtpinsc = 2
             where sab.rowid = rw_sab.rowid;
             --           
             --dbms_output.put_line('PJ com mais de 14 numeros  - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Insc - '||rw_sab.nrinssac );  
         end if;                                    
     elsif rw_sab.cdtpinsc = 2 then          
          /*Validar CNPJ*/
          begin         
            if length(rw_sab.nrinssac) <= 14 then
               gene0005.pc_valida_cnpj (rw_sab.nrinssac,
                                       vr_stsnrcal);    
               if  vr_stsnrcal  then
                 /*CNPJ válido e tipo de inscrição correta*/
                 continue;
               else  
                 /*Validar CPF para realizar ajuste*/ 
                 gene0005.pc_valida_cpf (rw_sab.nrinssac,
                                          vr_stsnrcal);    
                 if vr_stsnrcal then                
                   dbms_output.put_line('Altera PJ para PF - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Ins - '||rw_sab.nrinssac ||' T - '||rw_sab.cdtpinsc);             
                   update crapsab sab
                   set sab.cdtpinsc = 1
                   where sab.rowid = rw_sab.rowid;
                 end if;  
               end if;  
            end if;                                    
          exception
            when others then 
             dbms_output.put_line('ERRO PJ  - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Insc - '||rw_sab.nrinssac ||' - '||SQLERRM);  
          end;                           
     elsif nvl(rw_sab.cdtpinsc,0) not in (1,2) then                    
          /*Trata os casos onde o tipo de inscrição gravado com valores diferentes do permitido*/
          /*Primeira chamada é do CPF. Se for verdadeiro ajusta para PF, senão par PJ*/
          if vr_stsnrcal then
             dbms_output.put_line('Tipo indefinido alterado para PF - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Ins - '||rw_sab.nrinssac ||' Tipo - '||rw_sab.cdtpinsc);             
             update crapsab sab
             set sab.cdtpinsc = 1
             where sab.rowid = rw_sab.rowid;
          else
            if length(rw_sab.nrinssac) <= 14 then
               gene0005.pc_valida_cnpj (rw_sab.nrinssac,
                                       vr_stsnrcal);    
               if  vr_stsnrcal  then
                 /*CNPJ válido e tipo de inscrição correta*/
                 dbms_output.put_line('Tipo indefinido alterado para PJ - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Ins - '||rw_sab.nrinssac ||' Tipo - '||rw_sab.cdtpinsc);             
                 update crapsab sab
                 set sab.cdtpinsc = 2
                 where sab.rowid = rw_sab.rowid;
               end if;  
            end if;                                              
          end if;                   
     else
       dbms_output.put_line('Outra situação - '||rw_sab.cdcooper||' - '||rw_sab.nrdconta ||' - '||rw_sab.nmdsacad||' Ins - '||rw_sab.nrinssac ||' T - '||rw_sab.cdtpinsc);             
     end if;                                                           
                              
   end loop;     
   
   commit; 
exception
  when others then
     rollback;
     dbms_output.put_line('Erro INC0051949 - '||sqlerrm);
end;
