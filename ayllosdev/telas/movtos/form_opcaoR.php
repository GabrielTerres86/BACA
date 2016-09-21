<?php
/*!
 * FONTE        : form_opcaoR.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014						Última alteração: 03/12/2014
 * OBJETIVO     : Formulario da Opção R da Tela MOVTOS.
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajuste para liberação (Adriano).
 * --------------
 */ 
?>

<?php
 	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	
	isPostMethod();		
	
?>

<form id="frmOpcaoR" name="frmOpcaoR" class="formulario" style="display:none">

	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<div id="divOpcaoR" >
						
			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input id="cdagenci" name="cdagenci" type="text" />
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('frmOpcaoR'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					
			<label for="tppessoa"><? echo utf8ToHtml('Tp.Natureza:') ?></label>
			<input id="tppessoa" name="tppessoa" type="text"/>
			
			<label for="cdultrev"><? echo utf8ToHtml('Revisão a mais de:') ?></label>
			<input id="cdultrev" name="cdultrev" type="text"/>
			
			<label for="lgvisual"><? echo utf8ToHtml('Saída:') ?></label>
			<select id="lgvisual" name="lgvisual">
				<option value="A" selected><? echo utf8ToHtml('Arquivo') ?> </option>
				<option value="I"><? echo utf8ToHtml('Impressão') ?> </option>
			</select>
				
			<br style="clear:both" />
					
		</div>
	</fieldset>
</form>


