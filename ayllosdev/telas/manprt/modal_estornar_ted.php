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
        <table border="0" cellpadding="0" cellspacing="0" width="550">
          <tr>
            <td>
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                  <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ESTORNO DE CUSTAS</td>
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

                      <fieldset id="modalEstorno">

                        <fieldset style="border: 1px solid rgb(195, 195, 195);width: 99%;">

                          <div>
                            <table cellspacing="10" style="margin: 10px 0;border: 1px solid rgb(195, 195, 195);width: 95%;">
                                <tr>
                                  <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Cooperativa:</label>
                                    <input class="campoTelaSemBorda" style="width: 100px" type="text" id="cooperativa" />
                                    <input type="hidden" id="idretorno" />
                                  </td>
                                </tr>
                                <tr>
                                  <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Conta:</label>
                                    <input type="text" class="campoTelaSemBorda" style="width: 100px" id="nrdconta" name="nrdconta"/>
                                  </td>
                                </tr>
                                <tr>
                                  <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Convenio:</label>
                                    <input class="campoTelaSemBorda" style="width: 100px" type="text" id="convenio" />
                                  </td>
                                </tr>
                                <tr>
                                  <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Documento/titulo:</label>
                                    <input class="campoTelaSemBorda" style="width: 100px" type="text" id="documento" />
                                  </td>                                
                                </tr>
                            </table>

                            <div style="text-align:center;margin-bottom:10px;">
                              <a href="#" class="botao" onClick="retornarTitulo();">Consultar</a>
                            </div>

                            <div id="retornoTitulo" style="display:none">
                              <table cellspacing="10" style="margin: 0 0 10px 0;border: 1px solid rgb(195, 195, 195);width: 95%;">
                                  <tr>
                                    <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Custas:</label>
                                      <input class="campoTelaSemBorda" style="width: 100px" id="custas" readonly />
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Vencimento do boleto:</label>
                                      <input class="campoTelaSemBorda" style="width: 100px" id="dtvencto" readonly />
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Valor do titulo:</label>
                                      <input class="campoTelaSemBorda" style="width: 100px" id="vltitulo" readonly />
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><label style="display: inline-block;width: 150px;text-align: right;" class="rotulo txtNormalBold">Titular da conta:</label>
                                      <input class="campoTelaSemBorda" style="width: 250px" id="nmprimtl" readonly />
                                    </td>
                                  </tr>
                              </table>

                              <div style="text-align:center;margin-bottom:10px">
                                <a href="#" class="botao" id="btModalConciliar" onClick="solicitaEstornoTED();">Estornar</a>
                              </div>
                            </div>
                          </div>

                        </fieldset>

                      <fieldset>

                      <div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));$('#divRotina').html('');">Voltar</a>
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