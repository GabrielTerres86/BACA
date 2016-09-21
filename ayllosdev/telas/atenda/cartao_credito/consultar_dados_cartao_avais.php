<?
/*!
 * FONTE        : consultar_dados_cartao_avais.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Abril/2008
 * OBJETIVO     : Mostrar opcao Avais da op��o Consultar da ROTINA Cart�es de  tela ATENDA
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [04/11/2010] David   (CECRED) : Adapta��o Cart�o PJ
 * 001: [05/05/2011] Rodolpho   (DB1) : Adapta��o para o formul�rio gen�rico de avalistas
 */
?>

<? 	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','');	
	}			
	
	// Verifica se o n�mero da conta foi informado
	if ( !isset($_POST["nrdconta"]) ||
		 !isset($_POST["nrctrcrd"]) ) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');	
	

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','');	
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) exibirErro('error','N&uacute;mero de contrato inv&aacute;lido.','Alerta - Ayllos','');	

	// Monta o xml de requisi��o
	$xmlGetAvais  = "";
	$xmlGetAvais .= "<Root>";
	$xmlGetAvais .= "	<Cabecalho>";
	$xmlGetAvais .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetAvais .= "		<Proc>carrega_dados_avais</Proc>";
	$xmlGetAvais .= "	</Cabecalho>";
	$xmlGetAvais .= "	<Dados>";
	$xmlGetAvais .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAvais .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAvais .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAvais .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAvais .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAvais .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetAvais .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAvais .= "		<idseqttl>1</idseqttl>";
	$xmlGetAvais .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAvais .= "		<flgerlog>FALSE</flgerlog>";
	$xmlGetAvais .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlGetAvais .= "	</Dados>";
	$xmlGetAvais .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvais);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvais = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAvais->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjAvais->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','');
	} 
	
	$avais = $xmlObjAvais->roottag->tags[0]->tags;
	$registros = $avais;
	
	$flgAval01 = count($avais) == 1 || count($avais) == 2 ? true : false;
	$flgAval02 = count($avais) == 2 ? true : false;	
?>
<table height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="middle">
			<form action="" method="post" name="frmDadosCartaoAvais" id="frmDadosCartaoAvais" class="formulario condensado">			
				<? 
					// ALTERA��O 001: Substituido formul�rio antigo pelo include				
					include('../../../includes/avalistas/form_avalista.php'); 
				?>
				<div id="divBotoes">
					<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4,385);return false;">
				</div>
			</form>
		</td>
	</tr>			
</table>
												
<script type="text/javascript">
	$('#divOpcoesDaOpcao1').css('display','none');
	$('#divOpcoesDaOpcao2').css('display','block');

	habilitaAvalista(false);
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>