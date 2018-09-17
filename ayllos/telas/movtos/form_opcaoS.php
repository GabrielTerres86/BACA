<?php
/*!
 * FONTE        : form_opcaoS.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014						Última Alteração: 03/12/2014
 * OBJETIVO     : Formulario da Opção S da Tela MOVTOS.
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajustes para liberação (Adriano).
 * --------------
 */ 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>


<form id="frmOpcaoS" name="frmOpcaoS" class="formulario" style="display:none">

	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<div id="divOpcaoS" >
		
			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input id="cdagenci" name="cdagenci" type="text" />
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('frmOpcaoR'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
			
			<label for="tpcontas"><? echo utf8ToHtml('Conta:') ?></label>
			<select id="tpcontas" name="tpcontas">
				<option value="TODAS" selected><? echo utf8ToHtml('Todas')?> </option>
				<option value="ITG" ><? echo utf8ToHtml('Conta ITG') ?> </option>
			</select>
			
			<label for="lgvisual"><? echo utf8ToHtml('Saída:') ?></label>
			<select id="lgvisual" name="lgvisual">
				<option value="A" selected><? echo utf8ToHtml('Arquivo') ?> </option>
				<option value="I"><? echo utf8ToHtml('Impressão') ?> </option>
			</select>
							
			<br style="clear:both" />
					
		</div>
	</fieldset>
</form>


