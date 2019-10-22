 --Script para atualização de Campo 'flgvalidavencto' para as empresas que estavam fixas 
  update cecred.gnconve gnconve
     set gnconve.flgvalidavencto= 1
   where gnconve.cdhiscxa in (2258,2271,2275,2262,659,2268,2297,2295,2286,2273,692,2549,2551)
   
 --Script para atualização de Campo 'nrdias_tolerancia' para empresa 'SANEPAR'
  update cecred.gnconve gnconve
     set gnconve.nrdias_tolerancia = 25
   where gnconve.cdhiscxa = 2262;
   
 --Script para atualização de campo 'flgacata_dup' Unimed(22) e Liberty(55)
  update cecred.gnconve gnconve
     set gnconve.flgacata_dup = 1
   where gnconve.cdconven in (22,55);
   
 --Scrip para atualização campo 'flgdebfacil' SAMAE ILHOTA DA - AGUAS GUARAMIRIM DA - AGUAS SCHROEDER DA
   update cecred.gnconve
	  set gnconve.flgdebfacil = 1
	where gnconve.cdconven in (108,87,126)
	  and gnconve.intpconvenio in(2,3) 
	  and gnconve.inorigem_inclusao in (1,3);

 --Scrip para atualização campo 'flgenv_dt_repasse' PREVISC -    
	update cecred.gnconve 
	  set  gnconve.flgenv_dt_repasse = 1
	where gnconve.cdconven in (128,127,085,68);  	  

  --Scrip para atualização campo 'qttamanho_optante'  	
   update cecred.gnconve
	set gnconve.qttamanho_optante = 6
	where gnconve.cdconven in (8, 16, 19, 20, 25, 26, 11, 49); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 8
	where gnconve.cdconven in (4, 24, 31, 33, 53, 54, 108, 96); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 9
	where gnconve.cdconven in (2, 10, 5, 30, 14, 45); 
	
    update cecred.gnconve
	set gnconve.qttamanho_optante = 20
	where gnconve.cdconven in (3, 48); 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 11
	where gnconve.cdconven = 15; 
	
	update cecred.gnconve
	set gnconve.qttamanho_optante = 19
	where gnconve.cdconven = 22; 
  
	update cecred.gnconve
     set gnconve.qttamanho_optante = 8
   where gnconve.cdconven = 101;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 8
   where gnconve.cdconven = 108;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 22
   where gnconve.cdconven = 127;
      
   update cecred.gnconve
     set gnconve.qttamanho_optante = 22
   where gnconve.cdconven = 128;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 10
   where gnconve.cdconven = 41;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 9
   where gnconve.cdconven = 51;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 12
   where gnconve.cdconven = 66;
   
   update cecred.gnconve
     set gnconve.qttamanho_optante = 10
   where gnconve.cdconven = 87;
   
   