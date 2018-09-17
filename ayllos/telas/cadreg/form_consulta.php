<?php
/*!
 * FONTE        : form_consulta.php				Última alteração: 27/11/2015
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/09/2015
 * OBJETIVO     : Formulario de Listagem dos históricos da Tela CADREG
 * --------------
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
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

	$regCddregio = (isset($_POST["regCddregio"])) ? $_POST["regCddregio"] : '';
	$regDsdregio = $_POST["regDsdregio"];
	$regCdopereg = $_POST["regCdopereg"];
	$regNmoperad = $_POST["regNmoperad"];
	$regDsdemail = $_POST["regDsdemail"];

?>

<form id="frmConsulta" name="frmConsulta" class="formulario">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend>Regional</legend>
		
		<div id="divConsulta" >
							
			<label for="cddregio"><? echo utf8ToHtml('Codigo da Regional:') ?></label>
			<input id="cddregio" name="cddregio" type="text" value="<? echo utf8ToHtml($regCddregio); ?>"/>
			
			<br style="clear:both" />
		
			<label for="dsdregio"><? echo utf8ToHtml('Descricao da Regional:') ?></label>
			<input id="dsdregio" name="dsdregio" type="text" value="<? echo utf8ToHtml($regDsdregio); ?>"/>
			
			<br style="clear:both" />
							
			<label for="cdoperad"><? echo utf8ToHtml('Responsavel:') ?></label>
			<input id="cdoperad" name="cdoperad" type="text" value="<? echo utf8ToHtml($regCdopereg); ?>"/>
			<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<input id="nmoperad" name="nmoperad"  type="text" value="<? echo utf8ToHtml($regNmoperad); ?>"/>
			
			<br style="clear:both" />
			
			<label for="dsdemail"><? echo utf8ToHtml('Email:') ?></label>
			<input id="dsdemail" name="dsdemail" type="text" value="<? echo utf8ToHtml($regDsdregio); ?>"/>
			
			
			<input type="hidden" name="cddsregi" id="cddsregi" type="hidden" value="" />
			<input type="hidden" name="dsoperad" id="dsoperad" type="hidden" value="" />					
						
		</div>
		
	</fieldset>
	
</form>