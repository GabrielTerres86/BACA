<? 
/***************************************************************************************
 * FONTE        : gera_protocolo.php				Última alteração: --/--/----
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 20/12/2018
 * OBJETIVO     : Gera protocolo
 
   Alterações   :  
 
 *************************************************************************************
 * ->> PROTOCOLO PARA PF <<- 
 */
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	require_once('funcoes_autorizacao.php');
	isPostMethod();		
  
	$nrdconta   = (isset($_POST["nrdconta"]))   ? $_POST["nrdconta"]   : "";
	$cdtippro   = (isset($_POST["cdtippro"]))   ? $_POST["cdtippro"]   : "";
    $nrcontrato = (isset($_POST["nrcontrato"])) ? $_POST["nrcontrato"] : "";
    $vlcontrato = (isset($_POST["vlcontrato"])) ? $_POST["vlcontrato"] : "";
    
    //bruno
    $dsComplemento = (isset($_POST["dscomplemento"])) ? $_POST["dscomplemento"] : "";
    
    $funcaoImpressao = (isset($_POST["funcaoImpressao"])) ? $_POST["funcaoImpressao"] : "";
    $funcaoGeraProtocolo = (isset($_POST["funcaoGeraProtocolo"])) ? $_POST["funcaoGeraProtocolo"] : "";

    $arrayDctror = (isset($_POST["auxArrayDctror"])) ? $_POST["auxArrayDctror"] : Array();
    $arrayMantal = (isset($_POST["auxArrayMantal"])) ? $_POST["auxArrayMantal"] : Array();
    $codTela = (isset($_POST["codTela"])) ? $_POST["codTela"] : 0;
    $cdopcao_dctror = (isset($_POST["cdopcao_dctror"])) ? $_POST["cdopcao_dctror"] : "";
    $cdopcao_mantal = (isset($_POST["cdopcao_mantal"])) ? $_POST["cdopcao_mantal"] : "";

    if(strpos(";",$funcaoImpressao) === false){
        $funcaoImpressao .= ";";
    }

    if($codTela == "0"){
        geraProtocoloPF($nrcontrato,$vlcontrato,$dsComplemento);
    }else{

        switch ($codTela) {
            case '30': //DCTROR
                if(count($arrayDctror) == 0){
                    geraProtocoloPF($nrcontrato,$vlcontrato,$dsComplemento);
                }else{
                foreach($arrayDctror as $key => $dados){
                    $dsComplemento = getDscomplementoDctror($cdopcao_dctror,$dados);
                        geraProtocoloPF($nrcontrato,$vlcontrato,$dsComplemento);
                }
                }
                break;
            case '31': //MANTAL                
                if(count($arrayMantal) == 0){
                    geraProtocoloPF($nrcontrato,$vlcontrato,$dsComplemento);
                }else{          
                foreach($arrayMantal as $key => $dados){
                    $dsComplemento = getDscomplementoMantal($dados);
                        geraProtocoloPF($nrcontrato,$vlcontrato,$dsComplemento);
                    }
                }
                break;
        }
    }

    $executar = 'fechaRotina($(\'#divUsoGenerico\'));'.($funcaoGeraProtocolo != "" ? $funcaoGeraProtocolo : '');

    exibirErro('inform','Gerado protocolo para operação solicitada!','Alerta - Aimaro',$executar, false); //.$funcaoImpressao


    function geraProtocoloPF($nrcontrato, $vlcontrato, $dscomplemento){
        global $glbvars, $cdtippro, $nrdconta;

$vlcontrato = str_replace(',','.',str_replace('.','',$vlcontrato));
    
    // Montar o xml de Requisicao
    $xml = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "    <cdtippro>" . $cdtippro . "</cdtippro>";
    $xml .= "    <nrcontrato>" . $nrcontrato . "</nrcontrato>";
    $xml .= "    <vlcontrato>" . $vlcontrato . "</vlcontrato>";

    //bruno
    if($cdtippro == "31" || $cdtippro == "30"){
        $xml .= "    <dscomplemento>".$dscomplemento."</dscomplemento>"; //Manter Nulo
    }

    $xml .= "  </Dados>";
    $xml .= "</Root>";
    
    $xmlResult = mensageria($xml, "CNTR0001", "GERA_PROTOCOLO_CTD_PF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = simplexml_load_string($xmlResult);

    if ($xmlObject->Erro->Registro->dscritic != '') {
        $msgErro = utf8ToHtml($xmlObject->Erro->Registro->dscritic);
        exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
        exit();
    }
    }
?>