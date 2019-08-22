<?
/*!
 * FONTE        : valida_cpf_interveniente.php
 * CRIAÇÃO      : Maykon D. Granemann (Envolti)
 * DATA CRIAÇÃO : 16/08/2018
 * OBJETIVO     : Rotina para validar 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *   
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ;
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ;
    $tpctrato		= (isset($_POST['tpctrato']))   ? $_POST['tpctrato']   : 0  ;
    $nrcpfcgc       = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0  ;

    $xmlCarregaDados  = "";
    $xmlCarregaDados .= "<Root>";
    $xmlCarregaDados .= " <Dados>";
    $xmlCarregaDados .= "  <nrdconta>" . $nrdconta . "</nrdconta>";
    $xmlCarregaDados .= "  <nrctremp>" . $nrctremp . "</nrctremp>";
    $xmlCarregaDados .= "  <tpctrato>" . $tpctrato . "</tpctrato>";
    $xmlCarregaDados .= "  <nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
    $xmlCarregaDados .= " </Dados>";
    $xmlCarregaDados .= "</Root>"; 

    $xmlResult = mensageria($xmlCarregaDados
                        ,"TELA_MANBEM"
                        ,"CPF_CADASTRADO"
                        ,$glbvars["cdcooper"]
                        ,$glbvars["cdagenci"]
                        ,$glbvars["nrdcaixa"]
                        ,$glbvars["idorigem"]
                        ,$glbvars["cdoperad"]
                        ,"</Root>");

    $xmlObject = getObjectXML($xmlResult);

    echo 'hideMsgAguardo();';

    $dom = new DOMDocument;
    $dom->preserveWhiteSpace = FALSE;
    $dom->loadXML($xmlResult);
    $dom->save('1CPF.xml');

    if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
    }
    else {    
        if (strtoupper($xmlObject->roottag->tags[0]->name) == "DADOS") {
            $flgAssoci  = $xmlObject->roottag->tags[0]->attributes['EHASSOCIADO'];  
            if($flgAssoci=="OK")
            {
                echo "console.log('Continua processo ... Retornando true');";
            }          
            else{
                echo "console.log('Chama cadastro de interveniente ... Retornando false');";
            }
        }        
    }
?>