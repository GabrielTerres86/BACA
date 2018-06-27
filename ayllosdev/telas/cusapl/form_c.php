<?
//*********************************************************************************************//
//*** Fonte: form_c.php                                    						                      ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Monta a tela C - Configuração da Custódia das Aplicações                  ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//
?>
<script>
$(document).ready(function() {
  $('#dataB3', '#frmCusApl').setMask("INTEGER", "99/99/9999", "");
  $('#vlminB3', '#frmCusApl').setMask("DECIMAL", "zzz.zz9,99", ".", "");
  return false;
});
</script>

<form id="frmCusApl" name="frmCusApl" class="formulario">
    <input name="hdnconta" id="hdnconta" type="hidden" value="" />

    <div id="divConta1" style="margin-top:20px; text-align: center;" >
      <fieldset>
        <legend>Par&acirc;metros Gerais</legend>
        <div align="center">
          <table style="width:95%;">
            <tr>
              <td class="txtNormalBold" style="width:50%;text-align:right;">
                <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Data inicial de Custódia das Aplicações na B3:') ?></label>
              </td>
              <td>
                <input type="text" class="campo" id="dataB3" name="dataB3 " size="10" maxlength = "10" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'dataB3'); ?>"/>
              </td>
            </tr>
            <tr>
              <td class="txtNormalBold" style="width:50%;text-align:right;">
                <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Valor mínimo de Custódia das Aplicações na B3:') ?></label>
              </td>
              <td>
                <input type="text" class="campo" id="vlminB3" name="vlminB3" size="10" maxlength = "10" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'vlminB3'); ?>"/>
              </td>
            </tr>
            <tr>
              <td class="txtNormalBold" style="width:50%;text-align:right;">
                <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Código Cliente Registrador:') ?></label>
              </td>
              <td>
                <input type="text" class="campo" id="cdregtb3" name="cdregtb3" size="8" maxlength = "8" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'cdregtb3'); ?>"/>
              </td>
            </tr>
            <tr>
              <table>
                <tr>
                  <td>
                    <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Código Cliente Favorecido:') ?></label>
                  </td>
                  <td>
                    <input type="text" class="campo" id="cdfavrcb3" name="cdfavrcb3" size="8" maxlength = "8" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'cdfavrcb3'); ?>"/>
                  </td>
                </tr>
              </table>
            </tr>
          </table>
        </div>
      </fieldset>
      <div id="divBotoes">
        <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial();return false;">Voltar</a>
        <a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="gravaCustodiaAplicacoes(); return false;">Salvar</a>
      </div>
	  </div>
</form>
