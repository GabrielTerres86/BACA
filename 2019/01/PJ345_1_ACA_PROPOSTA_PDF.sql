---- ACA TERMO
update crapaca
   set lstparam = lstparam || ',pr_dsiduser'
 where upper(nmdeacao) = 'ATDA_CRD_CRED_IMPR_TERMO_ADESAO_PF'
   and upper(NMPACKAG)= 'CCRD0008';

update crapaca
   set lstparam = lstparam || ',pr_dsiduser'
 where upper(nmdeacao) = 'ATDA_CRD_CRED_IMPR_TERMO_ADESAO_PJ'
   and upper(NMPACKAG)= 'CCRD0008';
-- TELA ATENDA  
update crapaca
   set lstparam = lstparam || ',pr_dsiduser'
 where upper(nmdeacao) = 'ATUALIZA_LIMITE_CRD'
   and upper(NMPACKAG)= 'TELA_ATENDA_CARTAOCREDITO';
   
update crapaca
   set lstparam = lstparam || ',pr_dsiduser'
 where upper(nmdeacao) = 'INCLUIR_PROPOSTA_ESTEIRA'
   and upper(NMPACKAG)= 'TELA_ATENDA_CARTAOCREDITO'; 

 commit;