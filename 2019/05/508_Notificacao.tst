PL/SQL Developer Test script 3.0
81
DECLARE
  cd_cdmensagem NUMBER;
  ds_html CLOB;
BEGIN
  ds_html := '<p>Ol&aacute;, #nomeresumido!</p>

              <p>Siga os passos abaixo:</p>

              <p><i>No App Ailos:</i></p>
              <ul>
              <li> 1 – Acesse a op&ccedil;&atilde;o “Mais > Informa&ccedil;&otilde;es Cadastrais”;</li>
              <li> 2 – Confira as informa&ccedil;&otilde;es cadastradas;</li>
              <li> 3 – Confirme ou solicite a atualiza&ccedil;&atilde;o.</li>
              </ul>
              
              <p>Na Conta Online da sua cooperativa:</p>
              <ul>
              <li> 1 – Acesse o menu “Conveni&ecirc;ncias > Informa&ccedil;&otilde;es Cadastrais”;</li>
              <li> 2 – Confira as informa&ccedil;&otilde;es cadastradas</li>
              <li> 3 – Confirme ou solicite a atualiza&ccedil;&atilde;o.</li>
              </ul>

              <p>Essa atualiza&ccedil;&atilde;o nos permitir&aacute; um atendimento ainda mais eficiente. Ao manter suas informa&ccedil;&otilde;es atualizadas voc&ecirc; tem acesso a produtos e servi&ccedil;os adequados &agrave;s suas necessidades.<br>
              Fique atento! A Cooperativa n&atilde;o faz liga&ccedil;&otilde;es ou envia SMS solicitando os dados dos cooperados para atualiza&ccedil;&atilde;o cadastral.</p>

              <p>Se tiver qualquer dúvida, entre em contato através do SAC (0800 647 22 00).</p>';
    
  INSERT INTO tbgen_notif_msg_cadastro
              (cdmensagem
              ,cdorigem_mensagem
              ,dstitulo_mensagem
              ,dstexto_mensagem
              ,dshtml_mensagem
              ,cdicone
              ,inexibe_botao_acao_mobile
              ,dstexto_botao_acao_mobile
              ,cdmenu_acao_mobile
              --,dslink_acao_mobile
              --,dsparam_acao_mobile
              ,inenviar_push)
       VALUES ((SELECT MAX(cdmensagem)+1 FROM tbgen_notif_msg_cadastro)
              ,7
              ,'Atualização de dados cadastrais'
              ,'Gostaríamos de confirmar seus dados cadastrais. Leva apenas 1 minuto e é muito simples. Clique e saiba mais.'
              ,ds_html
              ,15
              ,1
              ,'Atualizar agora'
              ,1003
              --,
              --,
              ,1)
    RETURNING cdmensagem INTO cd_cdmensagem;
            
            
  INSERT INTO tbgen_notif_automatica_prm
              (cdorigem_mensagem
              ,cdmotivo_mensagem
              ,dsmotivo_mensagem
              ,cdmensagem
              ,dsvariaveis_mensagem
              ,inmensagem_ativa
              ,intipo_repeticao
              ,nrdias_mes
              ,nrmeses_repeticao
              ,hrenvio_mensagem
              ,nmfuncao_contas) 
       VALUES (7
              ,6
              ,'CADASTRO - Atualização cadastral'
              ,cd_cdmensagem
              ,NULL
              ,0
              ,2
              ,'2'
              ,'1,2,3,4,5,6,7,8,9,10,11,12'
              ,32400
              ,'CADA0012.fn_busca_contas_atualizar');
              
  COMMIT;
END;
0
0
