<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados da tela PARFLU.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($cddopcao == 'C') {

        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados/>";
        $xml .= "</Root>";

        // Requisicao dos dados de parametrizacao da conta sysphera
        $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);
        $regcontas = $xmlObject->roottag->tags[0]->tags;
        $conta_sysphera = (isset($_POST["hdnconta"])) ? $_POST["hdnconta"] : 0;

        if ($conta_sysphera) {
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <cdconta>".$conta_sysphera."</cdconta>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados de parametrizacao da distribuicao
            $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_DISTRIB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
            }

            $param = $xmlObject->roottag->tags[0]->tags;
        }

        include('form_c.php');

        if ($conta_sysphera) {            
            $arrPrazo = array(90, 180, 270, 360, 720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040, 5400, 5401);
            foreach ($arrPrazo as $cdprazo) {
                ?>
                <script type="text/javascript">
                    $("#perc_<?php echo $cdprazo; ?>","#frmParflu").val("0,00");
                </script>
                <?php
            }
            // Carrega os valores do banco de dados
            foreach ($param as $reg) {
                $cdprazo = getByTagName($reg->tags,'CDPRAZO');
                $perdistrib = getByTagName($reg->tags,'PERDISTRIB');
                ?>
                <script type="text/javascript">
                    $("#perc_<?php echo $cdprazo; ?>","#frmParflu").val("<?php echo $perdistrib; ?>");
                </script>
                <?php
            }
        }

    } else if ($cddopcao == 'R') {

        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados/>";
        $xml .= "</Root>";

        // Requisicao dos dados de parametrizacao da conta sysphera
        $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_REMESSA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);
        $regremess = $xmlObject->roottag->tags[0]->tags;
        $remessa   = (isset($_POST["hdnremessa"])) ? $_POST["hdnremessa"] : 0;
        
        // Se selecionou alguma remessa busca os historicos
        if ($remessa) {
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <cdremessa>".$remessa."</cdremessa>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados de parametrizacao da conta sysphera
            $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_LISTA_HISTOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);
            $reghistor = $xmlObject->roottag->tags[0]->tags;
            
            $arrBancos = array(1 => '01 - Banco do Brasil', 85 => '85 - Ailos', 756 => '756 - Bancoob', 748 => '748 - Sicredi');
        }

        include('form_r.php');

    } else if ($cddopcao == 'H') {

        // Montar o xml de Requisicao
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdcooper>0</cdcooper>";
        $xml .= "   <flgativo>1</flgativo>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        
        $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);
        $list_coop = $xmlObject->roottag->tags[0]->tags;
        $cooper    = (isset($_POST["hdncooper"])) ? $_POST["hdncooper"] : 0;
        
        if ($cooper) {
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <cdcooper>".$cooper."</cdcooper>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados de parametrizacao da conta sysphera
            $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_HORARIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);
            $dshora    = $xmlObject->roottag->tags[0]->tags[0]->cdata;
        }

        include('form_h.php');

    } else if ($cddopcao == 'M') {

        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados />";
        $xml .= "</Root>";

        // Requisicao dos dados de parametrizacao da conta sysphera
        $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_MARGEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);
        $xmlRegist = $xmlObject->roottag->tags[0];

        include('form_m.php');

    }
?>