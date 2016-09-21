<?php
/*!
 * FONTE        : form_consulta.php						Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 09/10/2015
 * OBJETIVO     : Formulario de Listagem dos históricos da Tela CADSCR
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
							  (Adriano).
 * --------------
 */ 
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmConsulta" name="frmConsulta" class="formulario" style="display:none">

	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend>Filtro</legend>
		
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
		<div id="divConsulta" >
								
			<label for="dtsolici"><? echo utf8ToHtml('Dt. Solicita&ccedil;&atilde;o:') ?></label>
			<input id="dtsolici" name="dtsolici" type="text"/>
		
			<label for="dtrefere"><? echo utf8ToHtml('Dt. Refer&ecirc;ncia:') ?></label>
			<input id="dtrefere" name="dtrefere" type="text" />
							
			<label for="nrdconta"><? echo utf8ToHtml('Conta/Dv:') ?></label>
			<input id="nrdconta" name="nrdconta" type="text"/>
			
			<input id="dsdirscr" name="dsdirscr" type="hidden" value="<?echo getByTagName($registro->tags,'dsdirscr');?>"/>
						
		</div>
		
	</fieldset>
	
</form>
