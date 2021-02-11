-- P560 - Parametro de percentual de honorarios

INSERT into crapprm 
       (nmsistem, 
        cdcooper, 
        cdacesso, 
        dstexprm, 
        dsvlrprm)
values ('CRED',  -- nmsistem
        0,       -- cdcooper
        'PERC_HONORARIOS_RECUP', -- cdacesso
        'Percentual de honorarios utilizado para recuperação', --dstexprm    
        '10'); -- dsvlrprm  
        
INSERT into crapprm 
       (nmsistem, 
        cdcooper, 
        cdacesso, 
        dstexprm, 
        dsvlrprm)
values ('CRED',  -- nmsistem
        0,       -- cdcooper
        'COBEMP_INSTR_LINHA_5', -- cdacesso
        'Mensagem de informação do boleto - linha 5', --dstexprm    
        'Ao valor do boleto foi incluso #HONORARIO#% de honorários advocatícios'); -- dsvlrprm          
        
update crapaca set lstparam = lstparam || ',pr_vlhonora' where nmdeacao = 'GERA_BOLETO';

commit;        
