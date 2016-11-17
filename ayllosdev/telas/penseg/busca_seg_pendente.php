<?php
/*!
 * FONTE        : busca_seg_pendente.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Rotina para buscar os Seguros Sicredi pendentes de ajuste
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

    $retornoAposErro = '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

    // Monta o xml de requisição
    $xml  = '';
    $xml .= '<Root>';
    $xml .= '   <Dados>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
    $xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
    $xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xml .= '       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xml .= '       <idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '   </Dados>';
    $xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
    $xmlResult = mensageria($xml, "PENSEG", "BUSCASEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
        $msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
    }
	
	$qtregist = $xmlObjeto->roottag->attributes['QTREGIST'];
    $pendencias = $xmlObjeto->roottag->tags;
    include('tab_pendencias.php');
?>
