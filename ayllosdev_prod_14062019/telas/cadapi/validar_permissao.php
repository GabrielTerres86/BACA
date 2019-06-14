<?php
/*!
 * FONTE        : validar_permissao.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 19/02/2019
 * OBJETIVO     : Rotina para validar permissão às rotinas
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Busca os parâmetos do POST guardando em variáveis
$cddopcao = (!empty($_POST['cddopcao']))  ? $_POST['cddopcao'] : 'C';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
	exibeErroNew($msgError);
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Aimaro","bloqueiaFundo($(\'#divRotina\')");');
}