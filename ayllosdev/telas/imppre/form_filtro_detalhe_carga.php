<?
/* !
 * FONTE        : form_filtro_detalhe_carga.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Rotina para buscar os detalhes da carga
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divFiltro">
	<form id="frmFiltroDetVari" name="frmFiltroDetVari" class="formulario" style="display:none;">

		<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px 10px 10px 10px; margin:0px;">

			<legend>Filtro</legend>

			<div id="divFiltroCarga">
				<label for="cdcooper"><?php echo utf8ToHtml('Cooperativa:'); ?></label>
				<select id="cdcooper" name="cdcooper" ><?php echo $nmrescop; ?></select>

				<label for="tpcarga"><?php echo utf8ToHtml('Tipo:'); ?></label>
				<select id="tpcarga" name="tpcarga" >
					<option value="A"> <?php echo utf8ToHtml('Automática'); ?> </option>
					<option value="M"> <?php echo utf8ToHtml('Manual'); ?> </option>
					<?php if ($glbvars["cdcooper"] == 3) { ?>
					<option value="T"> <?php echo utf8ToHtml('TODAS'); ?> </option>
					<?php } ?>
				</select>

				<label for="indsitua"><?php echo utf8ToHtml('Situação:'); ?></label>
				<select id="indsitua" name="indsitua" >
					<option value="B"> <?php echo utf8ToHtml('Bloqueada'); ?> </option>
					<option value="L"> <?php echo utf8ToHtml('Liberada'); ?> </option>
					<option value="R"> <?php echo utf8ToHtml('Rejeitada'); ?> </option>
					<option value="S"> <?php echo utf8ToHtml('Substituida'); ?> </option>
					<?php //option value="I"> <?php echo utf8ToHtml('Inativa'); ? > </option?>
					<option value="T"> <?php echo utf8ToHtml('TODAS'); ?> </option>
				</select>

				<label for="dtlibera"><?php echo utf8ToHtml('Data Liberação:'); ?></label>
				<input type="text" id="dtlibera" name="dtlibera" />
				<label for="dtliberafim"><?php echo utf8ToHtml(' até '); ?></label>
				<input type="text" id="dtliberafim" name="dtliberafim" />

				<label for="dtvigencia"><?php echo utf8ToHtml('Data Vigência:'); ?></label>
				<input type="text" id="dtvigencia" name="dtvigencia" />
				<label for="dtvigenciafim"><?php echo utf8ToHtml(' até '); ?></label>
				<input type="text" id="dtvigenciafim" name="dtvigenciafim" />

				<label for="skcarga"><?php echo utf8ToHtml('Número Carga:'); ?></label>
				<input type="text" id="skcarga" name="skcarga" />

				<label for="dscarga"><?php echo utf8ToHtml('Descrição:'); ?></label>
				<input type="text" id="dscarga" name="dscarga" />
			</div> 	

		</fieldset>

	</form>
	<div id="divBotoes" style="display:none;padding-bottom: 15px;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>
	</div>
</div>
<div id="divListDetVariCargas"> </div>