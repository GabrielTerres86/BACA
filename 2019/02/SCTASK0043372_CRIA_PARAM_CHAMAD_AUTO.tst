PL/SQL Developer Test script 3.0
84
DECLARE
CURSOR cr_crapcop IS
  SELECT cop.cdcooper
    FROM crapcop cop
   WHERE cop.flgativo = 1;
BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    
    --Parâmetro de habilitacao
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso, 
       dstexprm, 
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'HAB_TICKET_AUTO', 
       'Habilita a funcionalidade de criar ticket automatico na procedure pc_log_programa', 
       '0');
       
    --Habilita envio de e-mail em caso de criação de tickets automaticos
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso, 
       dstexprm, 
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'HAB_EMAIL_TICKET_AUTO', 
       'Habilita a funcionalidade de enviar e-mail caso um ticket seja criado na procedure pc_log_programa', 
       '0');
  
  END LOOP;
  
  --Contem o endereco de conexao com o softdesk de producao
  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso, 
     dstexprm, 
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'END_PROD_TICKET_AUTO', 
     'Contem o endereco de conexao com o softdesk de producao', 
     'https://softdesk.cecred.coop.br');
       
  --Contem o endereco de conexao com o softdesk de homologacao
  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso, 
     dstexprm, 
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'END_HOMOL_TICKET_AUTO', 
     'Contem o endereco de conexao com o softdesk de homologacao', 
     'http://softdesktreina.cecred.coop.br');  
       
  --Contem o comando que realiza a conexao com o softdesk para gerar o ticket
  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso, 
     dstexprm, 
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CMD_TICKET_AUTO', 
     'Contem o comando que realiza a conexao com o softdesk para gerar o ticket', 
     'curl -k "#vr_link_softdesk/modulos/incidente/api.php?cd_area=2&cd_usuario=#vr_usuario&tt_chamado=#vr_titulo_chamado&ds_chamado=#vr_texto_chamado&cd_categoria=586&cd_grupo_solucao=128&cd_servico=57&cd_tipo_chamado=5&cd_prioridade=5&cd_nivel_indisponibilidade=4" 2> /dev/null');  
       
       
  COMMIT;
END;
0
0
