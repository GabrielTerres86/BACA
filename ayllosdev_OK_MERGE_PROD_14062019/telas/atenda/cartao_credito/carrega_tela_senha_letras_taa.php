<?
/*!
 * FONTE        : carrega_tela_senha_letras_taa.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Agosto/2015
 * OBJETIVO     : Carrega os dados da tela de senha letras do TAA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$operacao = $_POST['operacao'];
	
	require_once('form_senha_letras.php');
	
?>
<script type="text/javascript">
controlaLayout('frmSenhaLetrasTAA');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está atrás do div da rotina
bloqueiaFundo(divRotina);
</script>