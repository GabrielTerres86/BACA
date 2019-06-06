<? 
/***************************************************************************************
 * FONTE        : cria_trans_pend.php				Última alteração: --/--/----
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 21/12/2018
 * OBJETIVO     : Cria transacao pendente
 
   Alterações   :  
 
 **************************************************************************************/
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
  
	$nrdconta         = (isset($_POST["nrdconta"]))         ? $_POST["nrdconta"]         : "";
	$tpcontrato       = (isset($_POST["tpcontrato"]))       ? $_POST["tpcontrato"]       : "";
    $vlcontrato       = (isset($_POST["vlcontrato"]))       ? $_POST["vlcontrato"]       : "";
    $cdrecid_crapcdc  = (isset($_POST["cdrecid_crapcdc"]))  ? $_POST["cdrecid_crapcdc"]  : "";
    $contas_digitadas = (isset($_POST["contas_digitadas"])) ? $_POST["contas_digitadas"] : "";
    $nrcontrato = (isset($_POST["nrcontrato"])) ? $_POST["nrcontrato"] : "";

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
    if(strpos(";",$funcaoGeraProtocolo) === false){
        $funcaoGeraProtocolo .= ";";
    }

	$vlcontrato = str_replace(',','.',str_replace('.','',$vlcontrato));
    
    geraTransPend();


    $executar = 'fechaRotina($(\'#divUsoGenerico\'));'.($funcaoGeraProtocolo != "" ? $funcaoGeraProtocolo : '');
    exibirErro('inform','Gerado pendência de autorização de contrato para aprovação dos prepostos da conta. Favor verificar operação na Conta Online ou Mobile.',
                'Alerta - Aimaro',
                $executar,
                false);
    //exibirErro('inform','Gerado protocolo para operação solicitada!','Alerta - Aimaro','fechaRotina($(\'#divUsoGenerico\'));', false);

    function geraTransPend(){
        global $glbvars, $nrdconta, $tpcontrato, $vlcontrato,$contas_digitadas, $nrcontrato;
    // Montar o xml de Requisicao
    $xml = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "    <tpcontrato>" . $tpcontrato . "</tpcontrato>";
    $xml .= "    <nrcontrato>".$nrcontrato."</nrcontrato>";
    $xml .= "    <vlcontrato>" . $vlcontrato . "</vlcontrato>";
    $xml .= "    <cdrecid_crapcdc></cdrecid_crapcdc>";
    $xml .= "    <contas_digitadas>" . $contas_digitadas . "</contas_digitadas>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    //Verificar se gerou pendencia:
    //select * from tbctd_trans_pend a where cdcooper = 1 and nrdconta = 2015510 order by 1 desc;
    
    $xmlResult = mensageria($xml, "CNTR0001", "CRIA_TRANS_PEND_CTD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = simplexml_load_string($xmlResult);

    if ($xmlObject->Erro->Registro->dscritic != '') {
        $msgErro = utf8ToHtml($xmlObject->Erro->Registro->dscritic);
        exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
        exit();
    }
    }
?>