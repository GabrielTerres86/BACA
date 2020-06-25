begin

delete  from tbcc_produtos_coop
         where cdproduto = 49;
         --and   inpessoa  in (1,2);
  

insert into tbcc_produtos_coop (cdcooper, 
                                tpconta, 
                                cdproduto, 
                                nrordem_exibicao, 
                                tpproduto, 
                                inpessoa, 
                                vlminimo_adesao, 
                                vlmaximo_adesao, 
                                dtvigencia)
        select cdcooper,
               tpconta,
               49,
               nrordem_exibicao,
               tpproduto,
               inpessoa,
               vlminimo_adesao,
               vlmaximo_adesao,
               dtvigencia
          from tbcc_produtos_coop
         where cdproduto = 1;    

commit;
         
end;

         
