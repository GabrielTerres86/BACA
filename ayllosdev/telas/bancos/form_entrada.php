<?
/*!
 * FONTE        : form_entrada.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 28/08/2015
 * OBJETIVO     : formulario do código e ISPB para a tela BANCOS
 * --------------
 * ALTERAÇÕES   :
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

<form id="frmEntrada" name="frmEntrada" class="formulario">
		<div id="divEntrada" >
		
		<label for="cdbccxlt"><? echo utf8ToHtml('Banco:') ?></label>
		<input id="cdbccxlt" name="cdbccxlt" type="text"/>
		<a style="padding: 3px 0 0 3px;" id="btLupaBanco" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
	
		<label for="nrispbif"><? echo utf8ToHtml('Numero ISPB:') ?></label>
		<input id="nrispbif" name="nrispbif" type="text"/>
		<a style="padding: 3px 0 0 3px;" id="btLupaIspb" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
						
		<br style="clear:both" />
		
		</div>
</form>


