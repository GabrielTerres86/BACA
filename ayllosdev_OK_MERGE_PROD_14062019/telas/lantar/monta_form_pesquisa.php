<? 
/*!
 * FONTE        : monta_form_pesquisa.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 15/04/2013
 * OBJETIVO     : Rotina para busca form_pesquisa_associado.php
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	include('form_pesquisa_associado.php');

?>