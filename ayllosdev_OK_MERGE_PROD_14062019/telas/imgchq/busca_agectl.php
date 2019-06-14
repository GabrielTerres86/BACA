<?php
/*!
 * FONTE        : busca_agectl.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : 01/12/2016
 * OBJETIVO     : Buscar o CDAGECTL da cooperativa logada
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


    $cdcooper = ( isset($_POST["cdcooper"]) ) ? $_POST["cdcooper"] : '';
    

    // Monta o xml dinâmico de acordo com a operação
    $xml  = '';
    $xml .= '<Root>';
    $xml .= '   <Cabecalho>';
    $xml .= '       <Bo>b1wgen0094.p</Bo>';
    $xml .= '       <Proc>Busca_Agencia</Proc>';
    $xml .= '   </Cabecalho>';
    $xml .= '   <Dados>';
    $xml .= '       <cdcooper>'.$cdcooper.'</cdcooper>';
    $xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
    $xml .= '       <cdbanchq>85</cdbanchq>';
    $xml .= '   </Dados>';
    $xml .= '</Root>';

    $xmlResult = getDataXML($xml);
    $xmlObjeto = getObjectXML($xmlResult);

    //----------------------------------------------------------------------------------------------------------------------------------
    // Controle de Erros
    //----------------------------------------------------------------------------------------------------------------------------------
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro    = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $nmdcampo   = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
        if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "focaCampoErro('".$nmdcampo."','frmMantal');"; }
        exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
    }

    $aux_cdagechq = $xmlObjeto->roottag->tags[0]->attributes['CDAGECHQ'];
    echo "aux_cdagechq = '".$aux_cdagechq."';";
    //echo "controlaLayout();";
?>
