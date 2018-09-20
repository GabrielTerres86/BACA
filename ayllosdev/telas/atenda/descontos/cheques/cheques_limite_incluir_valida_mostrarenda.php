<? 
/*!
 * FONTE        : cheques_limite_incluir_valida_mostrarenda.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Validar dados do primeiro passo e mostrar formulario de rendas e observações
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [15/07/2009] Guilherme    (CECRED) : Titulos para "frames" 
 * 001: [15/07/2009] Rodolpho Telmo  (DB1) : Adaptação para Zoom Endereço e Avalista Genéricos
 */
?>

<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();			
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["diaratin"]) ||
		!isset($_POST["vllimite"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"]) ||
		!isset($_POST["dtrating"]) ||
		!isset($_POST["cddlinha"]) ||
		!isset($_POST["vlrrisco"]) ||
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"]) ||
		!isset($_POST["inconfi4"])){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$diaratin = $_POST["diaratin"];
	$vllimite = $_POST["vllimite"];
	$dtrating = $_POST["dtrating"];
	$vlrrisco = $_POST["vlrrisco"];
	$cddlinha = $_POST["cddlinha"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi4 = $_POST["inconfi4"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);

	// Verifica se o do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) exibirErro('error','N&uacute;mero do contrato inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro);
	
	// Monta o xml de requisição
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetDadosLimIncluir .= "		<Proc>valida_proposta_dados</Proc>";
	$xmlGetDadosLimIncluir .= "	</Cabecalho>";
	$xmlGetDadosLimIncluir .= "	<Dados>";
	$xmlGetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLimIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLimIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLimIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosLimIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLimIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosLimIncluir .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDadosLimIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDadosLimIncluir .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetDadosLimIncluir .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetDadosLimIncluir .= "		<diaratin>".$diaratin."</diaratin>";
	$xmlGetDadosLimIncluir .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlGetDadosLimIncluir .= "		<dtrating>".$dtrating."</dtrating>";
	$xmlGetDadosLimIncluir .= "		<vlrrisco>".$vlrrisco."</vlrrisco>";
	$xmlGetDadosLimIncluir .= "		<cddopcao>I</cddopcao>";
	$xmlGetDadosLimIncluir .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlGetDadosLimIncluir .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlGetDadosLimIncluir .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlGetDadosLimIncluir .= "		<inconfi4>".$inconfi4."</inconfi4>";
	$xmlGetDadosLimIncluir .= "	</Dados>";
	$xmlGetDadosLimIncluir .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLimIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[0]->tags);
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[0]->cdata;

?>

<script type="text/javascript">
	inconfir = 01;
	inconfi2 = 11;
</script>

<?
	if ($inconfir == 2){
	?>
		<script type="text/javascript">
			hideMsgAguardo();
			inconfir = "<?echo $inconfir; ?>";
			showConfirmacao("<?echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoInclusao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
		</script>
	<?
	exit();
	}elseif ($inconfir == 12){
	?>
		<script type="text/javascript">
			hideMsgAguardo();
			inconfi2 = "<?echo $inconfir; ?>";
			showConfirmacao("<?echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoInclusao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
		</script>
	<?
	exit();
	}	
?>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<form action="" name="frmIncluirDscChq_Renda" id="frmIncluirDscChq_Renda" class="formulario condensado">
				<div id="divIncluirDscChq_Renda">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td colspan="5">
								<table width="100%" border="0" cellpadding="0" cellspacing="2">
									<tr>
										<td width="100">
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td height="1" style="background-color:#999999;"></td>
												</tr>
											</table>
										</td>								
										<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">DADOS PARA PROPOSTA</td>
										<td width="100">
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td height="1" style="background-color:#999999;"></td>
												</tr>
											</table>								
										</td>
									</tr>
								</table>
							</td>
						</tr>					
						<tr>
							<td>
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td width="90" height="25" class="txtNormalBold" align="right">Rendas:&nbsp;</td>
										<td width="50" height="25" class="txtNormalBold" align="right">Sal&aacute;rio:&nbsp;</td>
										<td width="110"><input type="text" name="vlsalari" id="vlsalari" value="" style="width: 100px; text-align: right;" class="campo"></td>
										<td width="50" height="25" class="txtNormalBold" align="right">C&ocirc;njuge:&nbsp;</td>
										<td><input type="text" name="vlsalcon" id="vlsalcon" value="" style="width: 100px; text-align: right;" class="campo"></td>
									</tr>
									<tr>
										<td width="140" height="25" colspan="2"class="txtNormalBold" align="right">Outras:&nbsp;</td>
										<td><input type="text" name="vloutras" id="vloutras" value="" style="width: 100px; text-align: right;" class="campo"></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						<tr>
							<td>
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td width="90" height="25" class="txtNormalBold" align="right">Bens:&nbsp;</td>
										<td><input type="text" name="dsdbens1" id="dsdbens1" value="" style="width: 350px;" class="campo"></td>
									</tr>
									<tr>
										<td width="90" height="25">&nbsp;</td>
										<td><input type="text" name="dsdbens2" id="dsdbens2" value="" style="width: 350px;" class="campo"></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						<tr>
						<tr>
							<td>
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td width="90" height="25" class="txtNormalBold" align="right">Observa&ccedil;&otilde;es:&nbsp;</td>
										<td><textarea name="dsobserv" id="dsobserv" style="width: 365px;" rows="5"></textarea></td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td align="center">
								<table border="0" cellpadding="0" cellspacing="3">
									<tr>
										<td><input type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(4,3,4,'DESCONTO DE CHEQUES - LIMITE - INCLUIR');return false;"></td>
										<td width="8"></td>
										<td><input type="image" src="<?echo $UrlImagens; ?>botoes/continuar.gif" onClick="mostraAvais();return false;"></td>
									</tr>
								</table>
							</td>
						</tr>
					</table>					
				</div>
				
				<div id="divOpcaoDadosAvalistas">				
					<? include('../../../../includes/avalistas/form_avalista.php'); ?>					
					<div id="divConfirmarNrContrato">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr>
								<td>
									<table border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td width="280" height="25" class="txtNormalBold" align="right">Confirme o n&uacute;mero do contrato:&nbsp;</td>
											<td><input type="text" name="antnrctr" id="antnrctr" value="" style="width: 80px; text-align: right;" class="campo"></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</div>
	
					<div id="divBotoes">
						<input type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divIncluirDscChq_Renda').css('display','block');$('#divOpcaoDadosAvalistas').css('display','none');return false;">
						<input type="image" src="<?echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(1,'frmIncluirDscChq_Renda');return false;">
					</div>
				</div>
				
			</form>
		</td>
	</tr>
</table>

<script type="text/javascript">
	// Aumenta tamanho do <div> onde o conteúdo da opção será visualizado
	$("#divOpcoesDaOpcao4").css("width","490px");

	// Esconde o <div> da com o primeiro passo da inclusão
	$("#divOpcoesDaOpcao3").css("display","none");
	// Esconde o <div> dos avalistas
	$("#divOpcaoDadosAvalistas").css("display","none");
	// Mostra o <div> das rendas
	$("#divIncluirDscChq_Renda").css("display","block");

	// Mostra o de rendas etc..
	$("#divOpcoesDaOpcao4").css("display","block");

	$("#vloutras","#frmIncluirDscChq_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#vlsalari","#frmIncluirDscChq_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#vlsalcon","#frmIncluirDscChq_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
	$("#dsdbens1","#frmIncluirDscChq_Renda").setMask("STRING","60",charPermitido(),"");
	$("#dsdbens2","#frmIncluirDscChq_Renda").setMask("STRING","60",charPermitido(),"");
	$("#dsobserv","#frmIncluirDscChq_Renda").setMask("STRING","900",charPermitido(),"");

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>

<? if ($inconfir == 72 || $inconfir == 19) { ?>
	<script type="text/javascript">
		// Mostra informação e continua
		showError("informe","<?echo $mensagem; ?>","Alerta - Aimaro","metodoBlock()");
	</script>
<? } ?>