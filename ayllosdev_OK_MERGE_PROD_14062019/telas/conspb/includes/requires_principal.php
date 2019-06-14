<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
	isPostMethod();

	setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "pt_BR.utf-8", "portuguese");
	header("Content-Type: text/html; charset=ISO-8859-1",true);
?>