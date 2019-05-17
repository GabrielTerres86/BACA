<?php
/************************************************************************
Fonte     : modal_conciliacao.php
Autor     : André Clemer
Data      : 12/04/2018                 Última alteração: 16/04/2019
Objetivo  : Modal de conciliação da tela MANPRT
Alterações: 

  16/04/2019 - INC0011935 - Melhorias diversas nos layouts de teds e conciliação:
               - modal de conciliação arrastável e correção das colunas para não obstruir as caixas de seleção;
               - aumentadas as alturas das listas de teds e modal de conciliação, reajustes das colunas (Carlos)

************************************************************************/

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe o POST
$dtinicio = (!empty($_POST['dtinicio'])) ? $_POST['dtinicio'] : null;
$vlrfinal = (!empty($_POST['vlrfinal'])) ? str_replace(',', '.', str_replace('.', '', $_POST['vlrfinal'])) : null;
$cartorio = (!empty($_POST['cartorio'])) ? $_POST['cartorio'] : null;
?>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
      <td align="center">
        <table border="0" cellpadding="0" cellspacing="0" width="700">
          <tr>
            <td>
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                  <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONCILIA&Ccedil;&Atilde;O</td>
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
                                <td style="padding-bottom: 20px;"><label class="rotulo txtNormalBold">Filtros:</label></td>
                                <td style="padding-bottom: 20px;" align="left">
                                  <input type="checkbox" id="dtinicio" name="dtinicio" value="<? echo $dtinicio; ?>" onchange="filtraConciliacao(this)" checked/>
                                  <label for="dtinicio">Data maior ou igual a <? echo $dtinicio; ?></label>
                                </td>
                                <td style="padding-bottom: 20px;" align="left">
                                  <input type="checkbox" id="vlrfinal" name="vlrfinal" value="<? echo number_format($vlrfinal,2,',','.'); ?>" onchange="filtraConciliacao(this)" checked/>
                                  <label for="vlrfinal">Valor menor ou igual a <? echo number_format($vlrfinal,2,',','.'); ?></label>
                                </td>
                                <!--<td style="padding-bottom: 20px;" align="left">
                                  <input type="checkbox" id="cartorio" name="cartorio" value="JERIQUAQUARA" onchange="filtraConciliacao(this)" checked/>
                                  <label for="cartorio">JERIQUAQUARA</label>
                                </td>-->
                              </tr>
                            </tbody>
                          </table>
                        </div>

                        <div class="divRegistros" style="height:250px">
                          <? require_once("tabela_conciliacao.php"); ?>
                        </div>
                        <table width="100%">
                          <tr>
                            <td align="right">
                              <label for="vltitulos">Valor a conciliar:</label>
                              <input class="campoTelaSemBorda" type="text" name="vltitulos" id="vltitulos" readonly disabled value="0,00" />
                            </td>
                          </tr>
                          <tr>
                            <td align="right">
                              <label for="vltotal">Valor TED:</label>
                              <input class="campoTelaSemBorda" type="text" name="vltotal" id="vltotal" readonly disabled value="<? echo number_format($vlrfinal,2,',','.'); ?>"
                              />
                            </td>
                          </tr>
                        </table>
                        <div id="divRegistrosRodape" class="divRegistrosRodape">
                          <table>
                            <tr>
                              <td>
                                <? if (isset($nriniseq)) { ?>
                                  Exibindo
                                  <? echo $nriniseq; ?> at&eacute;
                                    <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de
                                      <? echo $qtregist; ?>
                                        <? } ?>
                              </td>
                            </tr>
                          </table>
                        </div>

                      </fieldset>

                      <div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));$('#divRotina').html('');">Voltar</a>
                        <a href="#" class="botao" id="btModalConciliar" onClick="">Conciliar</a>
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