<?

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();
//array com administradoras da cecred.
$funcaoAposErro = 'bloqueiaFundo(divRotina);';
$cecredADM = Array(3, 11, 12, 13, 14, 15, 16, 17);
$cdcooper = $glbvars["cdcooper"];
$nrdconta = $_POST["nrdconta"];
$nrcrcard = $_POST['nrcrcard'];
$cdAdmCartao = $_POST['cdAdmCartao'];
$cartaoCECRED = in_array($cdAdmCartao, $cecredADM);

try {
    if (!(validaInteiro($cdAdmCartao)))
        throw new Exception(utf8ToHtml("Cartão inválido"));
    if (!(validaInteiro($nrdconta)))
        throw new Exception(utf8ToHtml("Conta inválida"));

} catch (Exception $e) {
     exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);
    return;
}

if (contaDoOperador($nrdconta, $glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito da conta do Operador."),'Alerta - Ayllos',$funcaoAposErro);


function contaDoOperador($nrdconta, $glbvars){
	/*$sql = "SELECT Count(*) AS existeConta  
			  FROM crapttl c 
			  INNER JOIN TBCADAST_COLABORADOR cad
			  ON (c.nrcpfcgc = cad.nrcpfcgc)
			  INNER JOIN CRAPOPE cra 
			  ON (cad.cdusured = cra.cdoperad)   
			  WHERE 
			  c.nrdconta = '$nrdconta' AND  
			  cra.cdoperad = '$operador'  and
			  c.cdcooper = '$cdcooper'
			  ";
	$result = dbSelect($sql);
	$x = $result['EXISTECONTA']['0'];
	return $result['EXISTECONTA'][0]==1;*/
	//return 1;
	$cdoperad = $glbvars['cdoperad'];
	$nrcrcard = $_POST['nrcrcard'];

	
	//nrcrcard
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>$nrdconta</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$admresult = mensageria($xml, "ATENDA_CRD", "VALIDAR_OPERADOR_ALTERACAO_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$admxmlObj = getObjectXML($admresult);
	$xml_adm =  simplexml_load_string($admresult);
	echo "<script>/*";
	print_r($xml_adm->Dados->contas);
	echo "*/<script>";
	return false;
	
}


function is_titular_card($nrcrcard, $nrdconta)
{
	$select = "select t.idseqttl from crapttl t left join crapcrd p on(t.NRCPFCGC = p.NRCPFTIT ) WHERE t.nrdconta = '$nrdconta' AND p.nrcrcard = '$nrcrcard'";
	
	$result = dbSelect($select);

	if($result['IDSEQTTL'][0] != NULL){
		if ($result['IDSEQTTL'][0] == 1)
			return true;
		else	
		return false;
	}else{
		echo "eh pj";
	}
}
function getLimites($cdcooper, $cdAdmCartao)
{

}

function strToNm($nrStr){
	return str_replace(",",".",str_replace(".","",$nrStr));
}
$limiteMaximo = "0,00";
$limiteMinimo = "0,00";
if( is_titular_card($nrcrcard , $nrdconta) ){
	
	$xmlGetNovoCartao  = "";
	$xmlGetNovoCartao .= "<Root>";
	$xmlGetNovoCartao .= "	<Cabecalho>";
	$xmlGetNovoCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetNovoCartao .= "		<Proc>carrega_dados_inclusao</Proc>";
	$xmlGetNovoCartao .= "	</Cabecalho>";
	$xmlGetNovoCartao .= "	<Dados>";
	$xmlGetNovoCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetNovoCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetNovoCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetNovoCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetNovoCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetNovoCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetNovoCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetNovoCartao .= "		<idseqttl>1</idseqttl>";
	$xmlGetNovoCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetNovoCartao .= "		<bthabipj>'F'</bthabipj>";
	$xmlGetNovoCartao .= "	</Dados>";
	$xmlGetNovoCartao .= "</Root>";
	
	$xmlResult = getDataXML($xmlGetNovoCartao);
	
	$xmlObjNovoCartao = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra crítica - proplema cadastral
	if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"voltaDiv(0,1,4)");
	}
	$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
	$dsadmcrd = getByTagName($dados,"DSADMCRD");//cdAdmCartao
	$dslimite = getByTagName($dados,"DSLIMITE");
	$eDslimite = explode("#",$dslimite);
	
		
	$cdadmcrd = getByTagName($dados,"CDADMCRD");
	$eCDADMCRD =  explode(",",$cdadmcrd);
	$posicao_cartao =  array_search($cdAdmCartao, $eCDADMCRD);
	$arrayLimite = explode("@",$eDslimite[$posicao_cartao]);
	$maxKey = sizeof( $arrayLimite) -1 ;
	$limiteMinimo = $arrayLimite[1];
	$limiteMaximo = $arrayLimite[$maxKey];

	
	
}else{
	echo 'ntitular';
}

?>
<script>

</script>
<style>
    [title] {
        background-color: rgb(255, 246, 143);
    }

    #tooltip * {
        font-size: 10px;
        font-weight: normal;
        font-family: Tahoma;
    }
</style>

<script>
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
    $("#vlLimite").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset style="text-align: center;">
            <p style="padding-top:10px">
            <h3><? echo utf8ToHtml("Alterar limite de crédito"); ?></h3></p>

            <?
            if ($cartaoCECRED) {
                //verifica_titularidade($nrcrcard , $nrdconta);
                getLimites($cdcooper, $cdAdmCartao);
            } else {

            }

            ?>
            <p>
                <br>
            <table>
                <tr>
                    <td>
                        <label for="nrcartao" class="rotulo txtNormalBold"><? echo utf8ToHtml("Nrº cartão:") ?>:</label>
                    <td>
                    <td>
                        <input type="text" value='<? echo $nrcrcard; ?>' id="nrcartao" name="nrcartao"
                               class="campoTelaSemBorda" disabled>
                    </td>
					<td>
                        <label for="minimoPossivel" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Mínimo") ?>:</label>
                    <td>
                    <td>
                        <input type="text" value='<? echo $limiteMinimo; ?>' id="minimoPossivel" name="minimoPossivel"
                               class="campoTelaSemBorda" disabled>
                    </td>

                </tr>
                <tr>
                    <td>
                        <label for="vlLimite" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Sugerido") ?>
                            :</label>
                    <td>
                    <td>
                        <input type="text" id="vlLimite" name="vlLimite" class="campoTelaSemBorda">
                    </td>
                    <td>
                        <label for="maximopossivel" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Máximo") ?>
                            :</label>
                    <td>
                    <td>
                        <input  type="text" id="maximopossivel" name="maximopossivel"value="<? echo $limiteMaximo; ?>" class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
				<tr>
					<td>
					
					</td>
				</tr>
            </table>


            </p>
        </fieldset>

        <div id="divBotoes">
            <input type="image" src="http://ayllosqa2.cecred.coop.br/imagens/botoes/voltar.gif"
                   onClick="voltaDiv(0, 1, 4);
                   return false;"/>
            <input type="image" id="btSalvar" src="http://ayllosqa2.cecred.coop.br/imagens/botoes/concluir.gif"
                   onClick="enviarSolicitacao();">
        </div>

    </div>


</form>

<script type="text/javascript">
    controlaLayout('frmNovoCartao');


    $("#divOpcoesDaOpcao1").css("display", "block");
    $("#divConteudoCartoes").css("display", "none");

    mostraDivDadosCartao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $('#dsadmcrd', '#frmNovoCartao').focus();
	
	/* <? print_r($glbvars);?>*/;
	
	function enviarSolicitacao(){
		var limiteMaximo  = <? echo strToNm($limiteMaximo);?>;
		var limiteMinimo  = <? echo strToNm($limiteMinimo);?>;
		var valorSugerido = parseFloat($("#vlLimite").val().replace(/\./g,'').replace(",","."));
		if(valorSugerido > limiteMaximo){
			alert();
		}else if(valorSugerido < limiteMinimo){
			
		}else{
			
		}
	}
	
</script>