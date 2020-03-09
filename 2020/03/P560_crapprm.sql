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
        
commit;        
