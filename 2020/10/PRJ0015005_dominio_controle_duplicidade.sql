 
insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('PIX_CONTROLE_DUPLICIDADE', 'ATIVO', 'S');
 
 /* 
    SELECT a.*
            FROM tbpix_dominio_campo a
           WHERE a.NMDOMINIO = 'PIX_CONTROLE_DUPLICIDADE'
             AND a.CDDOMINIO = 'ATIVO'; -->
 */ 
 
 
insert into tbpix_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('PIX_CONTROLE_DUPLICIDADE', 'MIN', '10');

 /* 
    SELECT a.*
            FROM tbpix_dominio_campo a
           WHERE a.NMDOMINIO = 'PIX_CONTROLE_DUPLICIDADE'
             AND a.CDDOMINIO = 'MIN'; -->
 */ 

COMMIT;
 
 
