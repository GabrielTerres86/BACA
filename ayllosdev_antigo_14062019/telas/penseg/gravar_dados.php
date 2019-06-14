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
?>
<?php
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Verifica permissões de acessa a tela
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','',false);

    $cdcooper   = (isset($_POST['cdcooper']))   ? $_POST['cdcooper'] : '';
    $nrdconta   = (isset($_POST['nrdconta']))   ? $_POST['nrdconta'] : '';
    $idcontrato = (isset($_POST['idcontrato'])) ? $_POST['idcontrato'] : '';

    if ((!validaInteiro($idcontrato)) || ($idcontrato == 0)) exibirErro('error','Seguro invalido! ('.$idcontrato.')','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));cnewCdcooper.focus();",false);
    if ((!validaInteiro($cdcooper))   || ($cdcooper == 0))   exibirErro('error','Cooperativa invalida! ('.$cdcooper.')','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));cnewCdcooper.focus();",false);
    if ((!validaInteiro($nrdconta))   || ($nrdconta == 0))   exibirErro('error','Conta/dv invalida! ('.$nrdconta.')','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));cnewNrdconta.focus();",false);

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
    $xml .= "       <idcontrato>".$idcontrato."</idcontrato>";
    $xml .= "   </Dados>";
    $xml .= "</Root>";

    //$xmlResult    = getDataXML($xml);
    $xmlResult = mensageria($xml, "PENSEG", "GRAVASEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
        $campo    = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
        $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));".$campo.'.focus();'.$campo.'.addClass(\'campoErro\');';
        $codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
        $msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;

        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
    }
?>
