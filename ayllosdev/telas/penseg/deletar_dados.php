<?php
/*!
 * FONTE        : deletar_dados.php
 * CRIAÇÃO      : Christian Grauppe/ENVOLTI
 * DATA CRIAÇÃO : Novembro/2018
 * OBJETIVO     : Rotina para "excluir" os dados de contratos segurados.
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

	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
	$nrapolice = (isset($_POST['nrapolice']) && $_POST['nrapolice'] != "") ? $_POST['nrapolice'] : 0;
	$nrcpfcnj = (isset($_POST['nrcpfcnj']) && $_POST['nrcpfcnj'] != "") ? $_POST['nrcpfcnj'] : 0;
	$registros = (isset($_POST['registros'])) ? $_POST['registros'] : 0;

    $retornoAposErro = '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

    // Monta o xml de requisição
    $xml  = '';
    $xml .= '<Root>';
    $xml .= '   <Dados>';
	$xml .= '       <registros>'.$registros.'</registros>';
    $xml .= '   </Dados>';
    $xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
    $xmlResult = mensageria($xml, "PENSEG", "DELETSEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
        $msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
    }
?>