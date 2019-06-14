<?php
/************************************************************************
Fonte     : modal_conciliacao.php
Autor     : Andr� Clemer
Data      : 12/04/2018                 �ltima altera��o: --/--/----
Objetivo  : Modal de concilia��o da tela MANPRT
Altera��es: 
************************************************************************/

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

?>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
      <td align="center">
        <table border="0" cellpadding="0" cellspacing="0" width="450">
          <tr>
            <td>
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                  <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DEVOLU&Ccedil;&Atilde;O DE TED</td>
                  <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
                    <a href="#" onClick="fechaRotina($('#divRotina'));return false;">
                  <img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0">
                </a>
                  </td>
                  <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td class="tdConteudoTela" align="center" height="100%">

              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                    <div id="divConteudoOpcao">

                      <fieldset>

                        <div>
                          <table cellspacing="10">
                            <tbody>
							                <tr>
                                <td style="padding-bottom: 20px;"><label class="rotulo txtNormalBold">Descri&ccedil;&atilde;o:</label></td>
                                <td style="padding-bottom: 20px;" align="left">
                                  <textarea id="devted_descricao" rows="4" maxlength="140" class="textarea" style="width: 230px;"></textarea>
                                </td>
                              </tr>
                              <tr>
                                <td style="padding-bottom: 20px;"><label class="rotulo txtNormalBold">Motivo:</label></td>
                                <td style="padding-bottom: 20px;" align="left">
                                  <select id="devted_motivo" class="campoTelaSemBorda">
                                    <option value="1">Recebimento da TED em duplicidade</option>
                                    <option value="2">Cart&oacute;rio n&atilde;o localizado/reconhecido</option>
                                    <option value="3">Algum outro motivo informado pelo IEPTB</option>
                                  </select>
                                </td>
                              </tr>
                            </tbody>
                          </table>
                        </div>

                      </fieldset>

                      <div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));$('#divRotina').html('');">Voltar</a>
                        <a href="#" class="botao" id="btModalConciliar" onClick="devolverTED();">Devolver</a>
                      </div>

                    </div>

                  </td>

                </tr>

              </table>

            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>