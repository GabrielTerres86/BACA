UPDATE  craptel tel
     SET tel.cdopptel = '@,C,T,R,L,E, M, H, K, G'
    ,tel.tldatela = 'Remessa de arquivos, arquivos de retorno'
    ,tel.tlrestel = 'Remessa de arquivos retorno'
    ,tel.lsopptel = 'Acesso,Consulta,Remessa,Relatorio,Log,Efetivacao,Movimento,Homologacao,KIT,GerarRel'
WHERE tel.nmdatela ='UPPGTO';

commit;
