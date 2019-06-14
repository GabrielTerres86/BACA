<?php
/*!
 * FONTE        : busca_seg_pendente.php
 * CRIA��O      : Guilherme/SUPERO
 * DATA CRIA��O : Junho/2016
 * OBJETIVO     : Rotina para buscar os Seguros Sicredi pendentes de ajuste
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [08/11/2018] Adicionado campos para busca e filtro da lista por CPF/CNPJ e Nr. de Ap�lice. ( Christian Grauppe/ENVOLTI )
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

    $retornoAposErro = '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

    // Monta o xml de requisi��o
    $xml  = '';
    $xml .= '<Root>';
    $xml .= '   <Dados>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '       <nrapolice>'.$nrapolice.'</nrapolice>';
	$xml .= '       <nrcpfcnj>'.$nrcpfcnj.'</nrcpfcnj>';
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