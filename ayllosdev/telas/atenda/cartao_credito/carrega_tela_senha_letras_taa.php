<?
/*!
 * FONTE        : carrega_tela_senha_letras_taa.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Agosto/2015
 * OBJETIVO     : Carrega os dados da tela de senha letras do TAA
 * --------------
 * ALTERA��ES   :
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
// Bloqueia conte�do que est� atr�s do div da rotina
bloqueiaFundo(divRotina);
</script>