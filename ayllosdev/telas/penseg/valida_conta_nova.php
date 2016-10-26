<?php
/*!
 * FONTE        : valida_conta_nova.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Rotina para validar a conta do cooperado e buscar o nome
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

    // Verifica permissões de acessa a tela
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','',false);

    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';

    if (!validaInteiro($cdcooper)) exibirErro('error','Cooperativa inválida.','Alerta - Ayllos','',false);
    if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);

    $xml  = "";
    $xml .= "<Root>";
    $xml .= '   <Dados>';
    $xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
    $xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xml .= '       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xml .= '       <idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= "       <telcooper>".$cdcooper."</telcooper>";
    $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   </Dados>";
    $xml .= "</Root>";

    //$xmlResult    = getDataXML($xml);
    $xmlResult = mensageria($xml, "PENSEG", "VALIDACTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto  = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
        $msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $nmCampo = '';
        if (strpos($msgErro, 'Cooperativa')) {
            $nmCampo = '#newCdcooper';
        }else{
            $nmCampo = '#newNrdconta';
        }
        echo "cnewNmprimtl.val('');";
        //exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'' . $nmCampo . '\',\'#frmDados\').focus();$(\'#newNmprimtl\',\'#frmDados\').val(\'\');',false);
        echo 'showError("error","' . $msgErro .'","Notifica&ccedil;&atilde;o - Ayllos","$(\'' . $nmCampo . '\',\'#frmDados\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
    } else {

        $nmprimtl   = getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmprimtl');
        echo "cnewNmprimtl.val('".$nmprimtl."');";
        echo "blockBackground(parseInt($('#divRotina').css('z-index')));";
        echo "$('#btGravar','#frmDados').habilitaCampo();";
        echo "$('#btGravar','#frmDados').focus();";
    }
?>
