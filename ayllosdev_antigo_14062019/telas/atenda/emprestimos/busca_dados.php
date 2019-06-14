<?php
/*
 FONTE        : busca_dados.php
 CRIAÇÃO      : Jaison Fernando
 DATA CRIAÇÃO : 03/04/2017
 OBJETIVO     : Busca os dados do ORACLE
 --------------
 ALTERAÇÕES   : 14/12/2018 - Incluso parametro do form para funcionamento com Simulacao
                (Andre Clemer - Supero)
 --------------
 */

    session_start();
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
    require_once('../../../includes/controla_secao.php');	
    require_once('../../../class/xmlfile.php');
    isPostMethod();		

    $acao     = (isset($_POST['acao']))     ? $_POST['acao']     : '';

    $idcarenc = (isset($_POST['idcarenc'])) ? $_POST['idcarenc'] : 0;
    $dtcarenc = (isset($_POST['dtcarenc'])) ? $_POST['dtcarenc'] : '';
	$nomeform = (!empty($_POST['nomeform'])) ? $_POST['nomeform'] : '#frmNovaProp';

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <idcarenc>".$idcarenc."</idcarenc>";
    $xml .= "   <dtcarenc>".$dtcarenc."</dtcarenc>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    switch ($acao) {

        case 'CALC_DATA_CARENCIA':
            $xmlResult = mensageria($xml, "TELA_ATENDA_EMPRESTIMO", "EMP_DATA_CARENCIA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);			
            if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
                $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                if ($msgErro == "") {
                    $msgErro = $xmlObject->roottag->tags[0]->cdata;
                }
                exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
            }
            echo '$("#dtcarenc", "'.$nomeform.'").val("'.getByTagName($xmlObject->roottag->tags[0]->tags,'dtcarenc').'").desabilitaCampo();';
        break;

    }
?>