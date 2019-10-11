PL/SQL Developer Test script 3.0
39
-- Created on 11/10/2019 by F0032176 
DECLARE
  cd_cdmensagem NUMBER;
  ds_html CLOB;
BEGIN
  ds_html := '<p>Ol&aacute;, #nomeresumido!</p>

              <p>Siga os passos abaixo:</p>

              <p><i>No App Ailos:</i></p>
              <ul>
              <li> 1 – Acesse a op&ccedil;&atilde;o “Mais > Informa&ccedil;&otilde;es Cadastrais”</li>
              <li> 2 – Confira as informa&ccedil;&otilde;es cadastradas</li>
              <li> 3 – Confirme ou solicite a atualiza&ccedil;&atilde;o</li>
              </ul>
              
              <p>Na Conta Online da sua cooperativa:</p>
              <ul>
              <li> 1 – Acesse o menu “Conveni&ecirc;ncias > Informa&ccedil;&otilde;es Cadastrais”</li>
              <li> 2 – Confira as informa&ccedil;&otilde;es cadastradas</li>
              <li> 3 – Confirme ou solicite a atualiza&ccedil;&atilde;o</li>
              </ul>

              <p>Essa atualiza&ccedil;&atilde;o nos permitir&aacute; um atendimento ainda mais eficiente. Ao manter suas informa&ccedil;&otilde;es atualizadas voc&ecirc; tem acesso a produtos e servi&ccedil;os adequados &agrave;s suas necessidades.<br>
              Fique atento! A Cooperativa n&atilde;o faz liga&ccedil;&otilde;es ou envia SMS solicitando os dados dos cooperados para atualiza&ccedil;&atilde;o cadastral.</p>

              <p>Se tiver qualquer dúvida, entre em contato através do SAC (0800 647 2200).</p>';
        
  UPDATE TBGEN_NOTIF_AUTOMATICA_PRM
  SET NRDIAS_SEMANA = 2, NRSEMANAS_REPETICAO = 1, NRDIAS_MES = NULL, INTIPO_REPETICAO = 1
  WHERE CDORIGEM_MENSAGEM = 7 AND CDMOTIVO_MENSAGEM = 6;
    
  UPDATE TBGEN_NOTIF_MSG_CADASTRO MSG
  SET MSG.DSHTML_MENSAGEM = ds_html
  WHERE MSG.CDMENSAGEM = (SELECT CDMENSAGEM FROM TBGEN_NOTIF_AUTOMATICA_PRM
                    WHERE CDORIGEM_MENSAGEM = 7 AND CDMOTIVO_MENSAGEM = 6);
              
  COMMIT;
END;
0
0
