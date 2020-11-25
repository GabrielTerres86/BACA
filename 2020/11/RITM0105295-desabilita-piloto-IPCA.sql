/* Ativa JOB rendimento para todas as coopers */
insert into crapprm (
select 'CRED' nmsistem
      ,cdcooper
      ,'CAPT_PCAPTA_REND_ATIVO' cdacesso
      ,'Indica se a cooperativa possui produto IPCA ativo' dstexprm
      ,'1' dsvlrprm
      ,null progress_reci
  from crapcop
 where cdcooper not in (1,3)
   and flgativo = 1);

/* Ativa a contratação do produto para todas as coopers */
insert into crapprm (
select 'CRED' nmsistem
      ,cdcooper
      ,'COOP_PILOTO_IPCA' cdacesso
      ,'Indica se a cooperativa habilita contratacao de IPCA' dstexprm
      ,'T' dsvlrprm
      ,null progress_reci
  from crapcop
 where cdcooper not in (1,3)
   and flgativo = 1);

/* Ajusta parametro da Viacredi */
update crapprm 
   set dsvlrprm = 'T'
 where cdcooper = 1
   and nmsistem = 'CRED'
   and cdacesso = 'COOP_PILOTO_IPCA';

commit;