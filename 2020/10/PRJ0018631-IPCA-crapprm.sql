insert into crapprm 
(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
('CRED',1, 'CAPT_PCAPTA_REND_ATIVO', 'Indica se a cooperativa possui produto IPCA ativo', '1');


/* Ativa opcao de IPCA na ATENDA 

           N - opcao IPCA inativa
           S - opcao IPCA ativa por conta piloto
           T - opcao IPCA ativa para todo mundo
*/
insert into crapprm 
(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
('CRED',1, 'COOP_PILOTO_IPCA', 'Indica se a cooperativa habilita contratacao de IPCA', 'S');


/* Contas piloto IPCA */
insert into crapprm 
(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
('CRED',1, 'CONTAS_PILOTO_IPCA', 'Indica as contas piltos para o produto IPCA', '8431213,19,329');


  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'ENVIA_EMAIL_INTEGRA_IPCA','Email de destino para controle da obtencao da taxa IPCA publicada no IBGE.','investimentos@ailos.coop.br');  
         
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'DATA_LIMITE_INTEGRA_IPCA','Dia do mes limite para obtenção da taxa IPCA publicada no IBGE.','15');



commit;