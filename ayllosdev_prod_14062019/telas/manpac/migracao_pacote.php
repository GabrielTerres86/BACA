<?php
	/*!
	 * FONTE        : migracao_pacote.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 29/03/2016
	 * OBJETIVO     : Formulario para migracao de pacote de tarifas
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */	

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<div id="divDadosMigracao" name="divDadosMigracao" style="display: block;" > 
	<hr style="border:0.01em solid black;">
	<br/>
	<fieldset>
		<legend>&nbsp;Migra&ccedil;&atilde;o do Servi&ccedil;o Cooperativo</legend>
			<label for="cdpacoteMig"><?php echo utf8ToHtml('C&oacute;digo:') ?></label>	
			<input name="cdpacoteMig" type="text"  id="cdpacoteMig" class="inteiro" maxlength="10" />
			<!-- LUPA -->
			<div id="lupaMigra">
				<a href="#" onClick="controlaPesquisaPacote();" >
					<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
				</a>
			</div>
			<input name="dspacoteMig" type="text"  id="dspacoteMig" maxlength="50" readonly />
			<br/>			
			<label for="tppessoaMig"><?php echo utf8ToHtml('Tipo de Pessoa:') ?></label>	
			<select id="tppessoaMig" name="tppessoaMig" disabled>
				<option value="0"></option>
				<option value="1">Pessoa F&iacute;sica</option>
				<option value="2">Pessoa Jur&iacute;dica</option>
			</select>
			<br/>
			<label for="vlpacoteMig"><?php echo utf8ToHtml('Valor:') ?></label>	
			<input name="vlpacoteMig" id="vlpacoteMig" type="text" class="inteiro" readonly />				
		</fieldset>	
	<br style="clear:both" />
</div>
<div id="divTarifasMigracao" name="divTarifasMigracao" style="display: none;" > 
	<br style="clear:both" />
</div>

<script>
	$('#cdpacoteMig', '#frmDados').unbind('keypress').bind('keydown', function (e) {

        if ($('#cdpacoteMig', '#frmDados').hasClass('campoTelaSemBorda')) { return false; }

			if (e.keyCode == 9 || e.keyCode == 13) {
				if($('#cdpacoteMig').val() == $('#cdpacote').val()){
				showError("error", "C&oacute;digo do novo servi&ccedil;o deve ser diferente do servi&ccedil;o atual.", "Alerta - Ayllos","$('#cdpacoteMig').val('');$('#cdpacoteMig').focus();");
				return false;
			}

			verificaAcao('C');
            return false;
        }
    });
</script>