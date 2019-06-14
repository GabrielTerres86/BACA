<?
/*!
 * FONTE        : valida_dados_cartao.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : Abril/2014
 * OBJETIVO     : Verifica se primeiro titular possui cartão e busca dados referentes ao cartão.
 * --------------
 * ALTERAÇÕES   : 001: [26/07/2014] Daniel :Comentado verificacao de permissao (Daniel).
 *                
 *     			  002: [20/08/2014] Daniel : Incluso ajustes solicitacao cartao pessoa juridica. SoftDesk 188116.	
 *
 * 				  003: [24/09/2014] Renato : Adicionar tratamento para atualização do campo nmempres 
 *				  
 *		     	  004: [24/12/2014] Vanessa : Obrigar o Preecnhimeto do campo forma de Pagamento SD 236434 
 *
 * 				  013: [03/07/2015] Renato Darosci : Impedir que seja possível informar limite para cartão somente débito
 *
 *                006: [16/07/2015] Carlos : #308949 Desativado o campo Forma de pagamento quando o cooperado pj já possui cartão.
 *
 *                007: [09/10/2015] James: Desenvolvimento do projeto 126.
 *
 *                008: [28/04/2016] Douglas: Adicionar o campo flgdebit para verificar se o primeiro cartao solicitado possui a opcao de debito habilitada. 
 *                                           Quando o primeiro cartao for solicitado sem a opcao de debito todos os cartoes adicionais devem ser identicos 
 *                                           (Chamado 415437)
 *
 *				  009: [05/10/2016] Kelvin: Ajuste feito ao realizar o cadastro de um novo cartão no campo  "habilita funcao debito"
 *										    conforme solicitado no chamado 508426. (Kelvin)
 *
 *				  010: [21/10/2016] Kelvin : #530857 Ajustado o campo "Envio" que no IE nao carregava a informacao correta.
 *
 *                011: [01/11/2016] Fabrício: Para solicitação de cartão PF, o campo 'Habilita função débito' deve sempre vir marcado.
 *                                            Não há solicitação de cartão Puro Crédito para PF. (Chamado 545667)
 *				  
 *				  012: [01/03/2017] Kelvin: Realizado ajuste para não desabilitar o campo "Nome da empresa" caso cooperado já tenha cartão. (SD 609533)
 *
 *                013: [18/03/2019] Anderson: Implementado tipo de envio do cartão (Supero)
 *
 *                014: [15/05/2019] Jefferson (MoutS): Inicialização da várialvel javascript flgdebit para corrigir travamento no CRM
 * --------------
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$funcaoAposErro = 'bloqueiaFundo(divRotina);';

	// Verifica permissão
/*	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro,false);
	}
*/	
	// Verifica se os parâmetros necessários foram informados
if (!isset($_POST["nrdconta"]) || !isset($_POST["cdadmcrd"]) || !isset($_POST["nrcpfcgc"])) {
    exibirErro('error', 'Par&acirc;metros incorretos.', 'Alerta - Aimaro', $funcaoAposErro, false);
}

$nrdconta = $_POST["nrdconta"];
$cdadmcrd = $_POST["cdadmcrd"];
$nrcpfcgc = $_POST["nrcpfcgc"];
$nmtitcrd = $_POST["nmtitcrd"];
$floutros = $_POST["floutros"];
$idastcjt = $_POST["idastcjt"];
$glbadc = $_POST['glbadc'];
$inpessoa = $_POST["inpessoa"];
	$nrctrcrd = !empty($_POST["nrctrcrd"]) ? $_POST["nrctrcrd"] : 0;
	
	// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) exibirErro('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Aimaro', $funcaoAposErro, false);
if (!validaInteiro($cdadmcrd)) exibirErro('error', 'Administradora de Cart&atilde;o inv&aacute;lida.', 'Alerta - Aimaro', $funcaoAposErro, false);
	
    // Monta o xml de requisição
$xmlSetCartao = "";
$xmlSetCartao .= "<Root>";
$xmlSetCartao .= "	<Cabecalho>";
$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
$xmlSetCartao .= "		<Proc>valida_dados_cartao</Proc>";
$xmlSetCartao .= "	</Cabecalho>";
$xmlSetCartao .= "	<Dados>";
$xmlSetCartao .= "		<cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xmlSetCartao .= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
$xmlSetCartao .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xmlSetCartao .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xmlSetCartao .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xmlSetCartao .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xmlSetCartao .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xmlSetCartao .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xmlSetCartao .= "		<cdadmcrd>" . $cdadmcrd . "</cdadmcrd>";
$xmlSetCartao .= "		<nmtitcrd>" . $nmtitcrd . "</nmtitcrd>";
$xmlSetCartao .= "		<nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
$xmlSetCartao .= "		<inpessoa>" . $inpessoa . "</inpessoa>";
$xmlSetCartao .= "	</Dados>";
$xmlSetCartao .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlSetCartao);

// Cria objeto para classe de tratamento de XML
$xmlObjCartao = getObjectXML($xmlResult);
	
$flgTitular = false;
if ($nrctrcrd > 0 && $cdadmcrd > 0) {
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
    $xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "ATENDA_CRD", "BUSCA_DADOS_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    $flgTitular = getByTagName($xmlObject->roottag->tags[0]->tags, "FLGTITULAR");
}

	// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjCartao->roottag->tags[0]->cdata;
    $msgErro = $msgErro == null || $msgErro == '' ? $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata : $msgErro;
    echo 'showError("error","' . $msgErro . '","Alerta - Aimaro","voltaDiv(0,1,5); bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);");';
} else {
    //Caso consulta retorne dados
    $dddebito = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
    $dddebito = str_pad($dddebito, 2, "0", STR_PAD_LEFT);  // Preencher com zeros a esquerda ( Renato - Supero - 23/09/2014)
    $vllimcrd = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
    $tpenvcrd = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[2]->cdata;
    $tpdpagto = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[3]->cdata;

    $nmempres = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata;
    // Identifica se o cartao possui a opcao debito habilitada
    $flgdebit = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[5]->cdata;


    echo 'bloqueiaFundo(divRotina);';

    if ($inpessoa == 1) {

        //chw+
        if ($vllimcrd <> 0 && $nrctrcrd == 0) {
            echo "$('#vllimpro').desabilitaCampo();";
        }

        if ($tpdpagto == 0 && $cdadmcrd != 15) {
            echo '$("#tpdpagto","#frmNovoCartao").val(0);';
        } else if ($tpdpagto == 1) {
            echo '$("#tpdpagto","#frmNovoCartao").val(1);';
        } else if ($tpdpagto == 2) {
            echo '$("#tpdpagto","#frmNovoCartao").val(2);';
        } else {
            echo '$("#tpdpagto","#frmNovoCartao").val(3);';
        }

        echo '$("#tpenvcrd","#frmNovoCartao").val("'.$tpenvcrd.'");';
        echo '$("#dddebito","#frmNovoCartao").val("'.$dddebito.'");';
        echo "$('#dddebito').attr('disabled', true);";
        echo "$('#tpenvcrd').attr('disabled', true);";
        if (!($cdadmcrd > 10 && $cdadmcrd < 18))
            echo "atualizaCampoLimiteProposto(new Array('" . formataMoeda($vllimcrd) . "'));";


        echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
        echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
        /* comentar todo o trecho de codigo abaixo que trata o campo flgdebit para PF
           pois esse campo para PF tem que vir sempre marcado nao permitindo alteracao - Fabricio - 01/11/2016 */

        /*
			//Administradora apenas débito (Maestro)
            if ($cdadmcrd == 16 ||
                $cdadmcrd == 17) {
                echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
                echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
            }
            else {
                //Outros
                if($floutros == 1) {
                    echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
                    echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
                }
                else {
            // Habilitar o campo "Habilita Funcao de Debito"
            echo "$('#flgdebit','#frmNovoCartao').habilitaCampo();";
            // Verificar se retornou a funcao debito
            if ($flgdebit != "") {
                // Verfica se a esta habilitada no primeiro cartao
                if (strtoupper($flgdebit) == "YES"){
                    // Marcar o campo no novo cartao
                    echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
                        }
                        else {
                    // Desabilitar o campo para nao permitir alterar
                    echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
					// Somente quando o primeiro cartao for SOMENTE CREDITO que a opção deve ficar desabilitada
                    echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
                }
            }
                }
            }
            */
    } else {

        if ($nmempres <> "") {
			if($glbadc == 'n' || $cdadmcrd!="15") {
				echo '$("#nmempres","#frmNovoCartao").val("' . $nmempres . '");'; // Renato - Supero			
			} else {
				
                echo 'if (trim(nmEmpresPla) != "") { $("#nmempres","#frmNovoCartao").val(nmEmpresPla); }';
				echo 'if ($("#flgEditEmpPlas", "#frmNovoCartao").val() != "1"){';
				echo "desativa('nmempres');/*$glbadc*/";
				echo '}';
			}
        }

        // tratamento para considerar cartao adicional
        if ($vllimcrd <> 0) {
			// aqui e para ser adicional		
            if ($tpdpagto == 0 && $cdadmcrd != 15) {
                echo '$("#tpdpagto","#frmNovoCartao").val("0");';
            } else if ($tpdpagto == 1) {
                echo '$("#tpdpagto","#frmNovoCartao").val("1");';
            } else if ($tpdpagto == 2) {
                echo '$("#tpdpagto","#frmNovoCartao").val("2");';
            } else {
                echo '$("#tpdpagto","#frmNovoCartao").val("3");';
            }

            echo '$("#tpenvcrd","#frmNovoCartao").val("'.$tpenvcrd.'");';

            echo '$("#dddebito","#frmNovoCartao").val("' . $dddebito . '");';
			if($glbadc == 'n' || $cdadmcrd!="15") {
				echo '$("#nmempres","#frmNovoCartao").val("' . $nmempres . '");'; // Renato - Supero
			}else{
                echo 'if (trim(nmEmpresPla) != "") { $("#nmempres","#frmNovoCartao").val(nmEmpresPla); }';
				echo 'if ($("#flgEditEmpPlas", "#frmNovoCartao").val() != "1"){';
				echo "desativa('nmempres');/*$glbadc*/";
				echo '}';
				
			}

			if ($inpessoa == 1 || !$flgTitular) {
			echo "$('#dddebito').attr('disabled', true);";
            }

			if (!$flgTitular) {
            echo "desativa('vllimpro');";
            echo "$('#tpdpagto').attr('disabled', true);";
			}
			echo "$('#tpenvcrd').attr('disabled', true);";
            if (!($cdadmcrd > 10 && $cdadmcrd < 18)) {
                echo "atualizaCampoLimiteProposto(new Array('" . formataMoeda($vllimcrd) . "'));";
			}

        } else {

				//echo "$('#dddebito').attr('disabled', false);";				
            echo "$('#tpenvcrd').attr('disabled', false);";
            if ($cdadmcrd != 15) {
                echo '$("#tpdpagto","#frmNovoCartao").val("1");';
                echo "$('#tpdpagto').attr('disabled', true);";
            } else {
                echo "$('#tpdpagto').val('1');";
				//if ($nrctrcrd == 0) {
                //	echo "$('#tpdpagto').attr('disabled', true);";
				//}
            }

        }

        //Administradora apenas d?bito (Maestro)
        if ($cdadmcrd == 17) {
            echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
            echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
        } else {
            //Outros
            if ($floutros == 1) {
                echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
                echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
            } else {
                // Habilitar o campo "Habilita Funcao de Debito"
                echo "$('#flgdebit','#frmNovoCartao').habilitaCampo();";
                // Verificar se retornou a funcao debito
                if ($flgdebit != "") {
                    // Verfica se a esta habilitada no primeiro cartao
                    if (strtoupper($flgdebit) == "YES") {
                        // Marcar o campo no novo cartao
                        echo "$('#flgdebit','#frmNovoCartao').attr('checked', true);";
                    } else {
                        // Desabilitar o campo para nao permitir alterar
                        echo "$('#flgdebit','#frmNovoCartao').desabilitaCampo();";
                        // Somente quando o primeiro cartao for SOMENTE CREDITO que a op??o deve ficar desabilitada
                        echo "$('#flgdebit','#frmNovoCartao').attr('checked', false);";
                    }
                }
            }
			
            if ($cdadmcrd == 15 && $idastcjt != 1 && $floutros != 1) {
                ?>
				var flgdebit = $('#flgdebit', '#frmNovoCartao').prop('checked');
                if(flgdebit == 1 && idastcjt == 0 ){
                //$('#flgdebit').removeAttr('disabled');
				ativa("flgdebit");
                $('#flgdebit').attr('checked',true);
                }
                <?
                /*echo "\n $('#flgdebit').attr('disabled','true'); \n";
                echo "\n $('#flgdebit').attr('checked','true'); \n";
                echo "\n $('#tpdpagto').attr('disabled',true); \n";*/

            } else if ($cdadmcrd == 15 && $floutros != 1 && $idastcjt != 1) {
                echo "\n $('#flgdebit').removeAttr('disabled') ;\n";
				echo "\n $('#flgdebit').removeAttr('readonly'); \n";
                echo "\n $('#flgdebit').attr('checked',true); \n";
            } else if ($idastcjt == 1 && $cdadmcrd == 15 && $glbadc != 'n') {
                echo "\n $('#flgdebit').removeAttr('checked'); \n";
                echo "\n desativa('flgdebit'); \n";
            } else if ($glbadc == 'n' &&  $idastcjt != 1) {
                echo "ativa('flgdebit');";
            }
			if($glbadc !="n"){
				echo ' desativa("dddebito");';
			}
        }
    }
}
?>