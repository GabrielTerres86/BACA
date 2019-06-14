<?
//*********************************************************************************************//
//*** Fonte: form_c.php                                    						                      ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Monta a tela C - Configuração da Custódia das Aplicações                  ***//
//***                                                                  						          ***//
//*** Alterações: 		21/03/2019 - Adição de tolerânica para conciliação - projeto 411.3 (Petter Rafael - Envolti)
//*********************************************************************************************//
?>
<script>
$(document).ready(function() {
  $('#dataB3', '#frmCusApl').setMask("INTEGER", "99/99/9999", "");
  $('#vlminB3', '#frmCusApl').setMask("DECIMAL", "zzz.zz9,99", ".", "");
  $('#perctolval', '#frmCusApl').setMask("DECIMAL", "zzz.zz9,99999999", ".", "");
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
                <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Nome do arquivo de log (LOGTEL):') ?></label>
              </td>
              <td>
                <input type="text" class="campo" id="nomarq" name="nomarq" size="6" maxlength = "6" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'nomarq'); ?>"/>
              </td>
            </tr>
            <tr>
              <table>
                <tr>
                  <td>
                    <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('E-mail para alerta na Central:') ?></label>
                  </td>
                  <td>
                    <textarea name="dsmail" id="dsmail" type="text" style="margin: 0px; width: 469px; height: 45px;"><?php echo getByTagName($xmlRegist->tags,'dsmail'); ?></textarea>
                  </td>
                </tr>
              </table>
            </tr>
          </table>
        </div>
      </fieldset>
	  </div>

    <div id="divConta2" style="margin-top:20px; text-align: center;" >
        <br style="clear:both" />
        <fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; margin-top:20px; padding-bottom:10px;">
        <legend> <? echo utf8ToHtml('Parámetros das Operações de Troca de Arquivos') ?> </legend>
            <div align="center">
              <table>
                <tr>
                  <td class="txtNormalBold" style="width:50%;text-align:right;">
                    <? echo utf8ToHtml('Horário comunicação com B3 de:') ?>
                  </td>
                  <td>
                    <input type="time" class="campo" id="hrinicio" name="hrinicio" size="5" maxlength = "5" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'hrinicio'); ?>"/>
                  </td>
                  <td class="txtNormalBold" style="text-align:right;">
                    <? echo utf8ToHtml('até') ?>
                  </td>
                  <td>
                    <input type="time" class="campo" id="hrfinal" name="hrfinal" size="5" maxlength = "5" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'hrfinal'); ?>"/>
                  </td>
                </tr>
              </table>
              <table>
                <tr>
                  <td class="txtNormalBold" style="width:50%;text-align:right;">
                    <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Envio do Registro das Aplicações:') ?></label>
                  </td>
                  <td>
                    <select id="reghab" name="reghab">
                      <option value="S" <?php echo (getByTagName($xmlRegist->tags,'reghab') == 'S' ? 'selected' : ''); ?>>Habilitado</option>
                      <option value="N" <?php echo (getByTagName($xmlRegist->tags,'reghab') == 'N' ? 'selected' : ''); ?>>Desabilitado</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td class="txtNormalBold" style="width:50%;text-align:right;">
                    <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Envio do Resgate das Aplicações:') ?></label>
                  </td>
                  <td>
                    <select id="rgthab" name="rgthab">
                      <option value="S" <?php echo (getByTagName($xmlRegist->tags,'rgthab') == 'S' ? 'selected' : ''); ?>>Habilitado</option>
                      <option value="N" <?php echo (getByTagName($xmlRegist->tags,'rgthab') == 'N' ? 'selected' : ''); ?>>Desabilitado</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td class="txtNormalBold" style="width:50%;text-align:right;">
                    <label for="dsvlrprm_23" align="right" style="width:100%;"><? echo utf8ToHtml('Processamento da Conciliação das Aplicações:') ?></label>
                  </td>
                  <td>
                    <select id="cnchab" name="cnchab">
                      <option value="S" <?php echo (getByTagName($xmlRegist->tags,'cnchab') == 'S' ? 'selected' : ''); ?>>Habilitado</option>
                      <option value="N" <?php echo (getByTagName($xmlRegist->tags,'cnchab') == 'N' ? 'selected' : ''); ?>>Desabilitado</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td class="txtNormalBold" style="width:50%;text-align:right;">
                    <label for="perctolval" align="right" style="width:100%;"><? echo utf8ToHtml('% Tolerância na Diferença de Valor:') ?></label>
                  </td>
                  <td>
                    <input type="text" class="campo" id="perctolval" name="perctolval" size="15" maxlength = "15" style="text-align:center;" value="<?php echo getByTagName($xmlRegist->tags,'perctolval'); ?>" />
                  </td>
                </tr>
              </table>
            </div>
        </fieldset>
        <div id="divBotoes">
      		<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial();return false;">Voltar</a>
      		<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="gravaCustodia(); return false;">Salvar</a>
      	</div>
    </div>
</form>
