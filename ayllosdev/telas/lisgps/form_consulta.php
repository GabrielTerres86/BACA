<?
/*!
 * FONTE        : form_consulta.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : Setembro/2015
 * OBJETIVO     : Mostrar tela LISGPS
 * --------------
 * ALTERA��ES   :
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$indrowid    = (isset($_POST['indrowid'])) ? $_POST['indrowid'] : '' ;
$regCdcontar = $_POST["regCdcontar"];
$regDscontar = $_POST["regDscontar"];
$regVltarid0 = $_POST["regVltarid0"];
$regVltarid1 = $_POST["regVltarid1"];
$regVltarid2 = $_POST["regVltarid2"];

?>
<form id="frmConsulta" name="frmConsulta" class="formulario" onSubmit="return false;" style="display:block">
	<div id="divConteudoGps" style="display:block" align="center">
	</div>
</form>