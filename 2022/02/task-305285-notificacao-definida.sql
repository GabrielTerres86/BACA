BEGIN
  UPDATE tbgen_notif_msg_cadastro
     SET dstitulo_mensagem = 'Cr&eacutedito Aprovado para voc&ecirc!',
         dshtml_mensagem   = '<p>Ol&aacute; #nomeresumido,</p>
                              <p>Temos dispon&iacute;vel um cr&eacute;dito de R$ <strong>#valordisponivelcdc</strong> para voc&ecirc; utilizar em lojas parceiras do Sistema Ailos.</p>
                              <p>A contrata&ccedil;&atilde;o do cr&eacute;dito &eacute; feita diretamente na loja e h&aacute; diversas oportunidades esperando por voc&ecirc;.</p>'
   WHERE cdorigem_mensagem = 15;
   COMMIT;
END;
