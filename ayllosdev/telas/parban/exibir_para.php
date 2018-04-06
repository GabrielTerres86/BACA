<?php
	/*!
	 * FONTE        : enviar_para.php
	 * CRIAÇÃO      : Gustavo Meyer         
	 * DATA CRIAÇÃO : 26/02/2017
	 * OBJETIVO     : Arquivo com parte responsável pelos informações de envio
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<div class="condensado">
  <br/>
  <fieldset>
    <legend>
      <b>
        <? echo utf8ToHtml('Exibir para')?>
      </b>
    </legend>

    <input type="hidden" id="totalRegistrosImportados" name="totalRegistrosImportados" value="<?php echo($total_registros_importados); ?>" />
    <!--
		<input type="hidden" id="tpfiltro" name="tpfiltro" value="0" />
		-->

    <select id="tpfiltro" name="tpfiltro" class="campo" style="width:300px;" onChange="carregaEnviar(this.value);">
      <option value="0"
        <?php if($tpfiltro == 0){ echo " selected"; } ?> >Escolher os Filtros
      </option>
      <option value="1"
        <?php if($tpfiltro == 1){ echo " selected"; } ?>>Importar arquivo CSV
      </option>
    </select>

    <div id="divFile" name="divFile" style="padding-top:10px; width: 100%; clear:both;">
      <div>

        <?php

					if($total_registros_importados > 0){
						echo("&nbsp;&nbsp;Nome do arquivo importado:<b> $nmarquivo_upload</b></br>"); 
						echo("&nbsp;&nbsp;Total de registros importados:<b> $total_registros_importados</b></br>"); 
					}
				?>
        <input name="arq_upload[]" id="nmarquivo_csv" type="file" class="campo" style="width:49%; height: 100%;" alt=""
        <? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
			
      </div>
      <div id="divCSVObs" name="divCSVObs" style="width:50%; float: right;">
        <b>Observa&ccedil;&otilde;es:</b>
        </br>
        - Apenas arquivos .csv e .txt
        </br>
        - <? echo utf8ToHtml('As únicas informações que devem constar no arquivo são: cooperativa, conta e titular (1;999;1). Caso não seja informado o titular, a notificação será enviada para todos os titulares da conta.')?>
			
      </div>
    </div>
    <?php// if($glbvars["cdcooper"] == 3){ ?>
    <div id="divCooperativas" name="divCooperativas" style="padding-top: 10px; width: 100%; clear:both;">
      <div id="divEsquerda" name="divEsquerda" style="width: 35%; float: left;">
        <label for="dsfiltro_cooperativas">
          <? echo utf8ToHtml('Cooperativas:'); ?>
        </label>
        <br/>
        <select multiple="" id="dsfiltro_cooperativas" name="dsfiltro_cooperativas[]" class="campo" style="width:100%; height: 200px;">
          <?php
							foreach ($msgCooper as $cooper) {
								
								if ( getByTagName($cooper->tags, 'CDCOOPER') <> '' ) {
						?>
          <option value=""
            <?= getByTagName($cooper->tags, 'CDCOOPER'); ?>"><?= getByTagName($cooper->tags, 'NMRESCOP'); ?>
          </option>

          <?php
								}
							}
						?>
        </select>
      </div>
      <?php// } ?>

      <div id="divDireita" name="divDireita" style=" float: left; padding-top: 10px; padding-left: 60px;">
        <label for="dsfiltro_tipos_conta">
          <? echo utf8ToHtml('Tipos de Conta:'); ?>
        </label>
        <br/><br/>
        <input type="checkbox" name="dsfiltro_tipos_conta_fis" id="dsfiltro_tipos_conta_fis" <?php echo($dsfiltro_tipos_conta_fis); ?> value="1" style="clear:both;" />
        <label for="dsfiltro_tipos_conta_fis" style="padding-left: 5px;">Pessoa F&iacute;sica</label>
        <br/><br/>
        <input type="checkbox" name="dsfiltro_tipos_conta_jur" id="dsfiltro_tipos_conta_jur" <?php echo($dsfiltro_tipos_conta_jur); ?> value="2" style="clear:both;" />
        <label for="dsfiltro_tipos_conta_jur" style="padding-left: 5px; vertical-align:middle;">Pessoa Jur&iacute;dica</label>
        <br/><br/>
        <label for="dsfiltro_produto" style="clear:both;" >
          <? echo utf8ToHtml('Outros Filtros:'); ?>
        </label>
        <br/><br/>
        <input type="radio" value="0" name="dsfiltro_produto" id="dsfiltro_produto_0" style="clear:both;" />
        <label for="inoutros_filtros_0">
          &nbsp;&nbsp;<? echo utf8ToHtml('Sem Filtros') ?>
        </label>
        <br/>
        <input type="radio" value="35" name="dsfiltro_produto" id="dsfiltro_produto_35" style="clear:both;" />
        <label for="inoutros_filtros_1">
          &nbsp;&nbsp;<? echo utf8ToHtml('Somente Cooperados com Pr&eacute;-Aprovado') ?>
        </label>
        <br/>
      </div>
    </div>
    <script>
      carregaEnviar(<?php echo($tpfiltro); ?>);

      $("#dsfiltro_produto_<?php echo($dsfiltro_produto); ?>").attr('checked', 'checked');

      if(cddopcao == "I"){
      $("#dsfiltro_cooperativas option").prop("selected", true);
      }else{

      var arrFiltroCoop = "<?php echo($dsfiltro_cooperativas); ?>";

      $.each(arrFiltroCoop.split(","), function(i,e){
      $("#dsfiltro_cooperativas option[value='" + e + "']").prop("selected", true);
      });

      }

    </script>
  </fieldset>
</div>