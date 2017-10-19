<?php

	//************************************************************************//
	//*** Fonte: home.php                                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração: 30/07/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script com frames para carregar páginas do sistema   ***//
	//***                                                                  ***//	 
	//*** Alterações: 30/07/2010 - Verificar se a home foi acionada pelo   ***//
	//***                          Login do sistema (David).               ***//
	//***																   ***//
	//***             05/10/2017 - Adicionado tratamento para armazenar    ***//
	//***                          parâmetros do CRM em session. (Reinert)  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("includes/config.php");
	require_once("includes/funcoes.php");
	require_once("includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Verifica se veio do CRM
    if ($_POST['CRM_INACESSO'] == 1) {
        // Seta as variveis vindas do CRM
        setVarSession("CRM_INACESSO",$_POST['CRM_INACESSO']);
        setVarSession("CRM_NMDATELA",$_POST['CRM_NMDATELA']);
        setVarSession("CRM_NRDCONTA",$_POST['CRM_NRDCONTA']);
        setVarSession("CRM_NRCPFCGC",$_POST['CRM_NRCPFCGC']);
        setVarSession("CRM_CDCOOPER",$_POST['CRM_CDCOOPER']);
        setVarSession("CRM_CDOPERAD",$_POST['CRM_CDOPERAD']);
        setVarSession("CRM_CDAGENCI",$_POST['CRM_CDAGENCI']);
        setVarSession("CRM_DSTOKEN",$_POST['CRM_DSTOKEN']);
    }

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Pragma" content="no-cache">
<title><?php echo $TituloSistema; ?></title>
<script type="text/javascript" src="scripts/jquery.js"></script>
<script type="text/javascript">
$(document).ready(function() {
	$("#framePrincipal").attr("scrolling","auto");
});
</script>
</head>
<frameset rows="*,0" cols="*" framespacing="0" frameborder="no" border="0">
	<frame src="principal.php" name="framePrincipal" id="framePrincipal" frameborder="yes" noresize marginwidth="0" marginheight="0" scrolling="yes">
	<frame src="blank.php" name="frameBlank" id="frameBlank" frameborder="no" noresize marginwidth="0" marginheight="0" scrolling="no">	
</frameset>
<noframes>
<body>
</body>
</noframes>
</html>
