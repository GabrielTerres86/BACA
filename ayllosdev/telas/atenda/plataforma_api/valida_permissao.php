<?php
/*!
 * FONTE        : valida_permissao.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 25/02/2019
 * OBJETIVO     : Rotina para validar permissao conforme acao
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

// Recebe a operação que está sendo realizada
$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
	exibeErroNew($msgError);
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Aimaro","bloqueiaFundo($(\'#divUsoGenerico\'))");');
}