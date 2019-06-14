<?php 

	/************************************************************************
	 Fonte: titulos_limite_incluir_valida_mostrarenda.php
	 Autor: Guilherme                                                 
	 Data : Dezembro/2008                Última Alteração: 07/06/2010
	                                                                  
	 Objetivo  : Validar dados do primeiro passo e mostrar formulário de 
				 rendas e observações
	                                                                  	 
	 Alterações: 15/07/2009 - Titulos para "frames" - (Guilherme).
	 
				 07/06/2010 - Adaptação para RATING (David).
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
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
		exibeErro("Par&acirc;metros incorretos.");
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
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se a data do rating é válida
	if (!validaData($dtrating)) {
		exibeErro("Data de rating inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0030.p</Bo>";
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
		exibeErro($xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[0]->tags);
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[0]->cdata;

	?>
	<script type="text/javascript">
    inconfir = 01;
	inconfi2 = 11;
	</script>
	<?php	
	if ($inconfir == 2) {
	?>
		<script type="text/javascript">
			hideMsgAguardo();
			inconfir = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoInclusao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
		</script>
	<?php
	exit();
	} elseif ($inconfir == 12) {
	?>
		<script type="text/javascript">
			hideMsgAguardo();
			inconfi2 = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoInclusao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
		</script>
	<?php
	exit();
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="middle" align="center">
			<script type="text/javascript">
				var metodoVoltar = "$('#divDscTit_Renda').css('display','block');$('#divDadosRating').css('display','none');";				
			</script>
			<form action="" name="frmIncluirDscTit_Renda" id="frmIncluirDscTit_Renda">
				<div id="divDscTit_Renda">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td>
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
						</tr>
						<tr>
							<td align="center">
								<table border="0" cellpadding="0" cellspacing="3">
									<tr>
										<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(4,3,4,'DESCONTO DE T&Iacute;TULOS - LIMITE - INCLUIR');return false;"></td>
										<td width="8"></td>										
										<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="informarRating('divDscTit_Renda','mostraObservacao()',metodoVoltar,'mostraImprimirLimite()');return false;"></td>
									</tr>
								</table>
							</td>
						</tr>
					</table>					
				</div>	
				<div id="divDscTit_Observacao">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="2">
									<tr>
										<td width="100">
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td height="1" style="background-color:#999999;"></td>
												</tr>
											</table>
										</td>								
										<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">OBSERVA&Ccedil;&Otilde;ES</td>
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
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td align="center">
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><textarea name="dsobserv" id="dsobserv" style="width: 450px;" rows="5"></textarea></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td align="center">
								<table border="0" cellpadding="0" cellspacing="3">
									<tr>
										<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divDadosRating').css('display','block');$('#divDscTit_Observacao').css('display','none');return false;"></td>
										<td width="8"></td>										
										<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="mostraAvais();return false;"></td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</div>
				<div id="divDscTit_Avalistas">				
					<? 
						// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
						include('../../../../includes/avalistas/form_avalista.php'); 
					?>										
					<div id="divConfirmarNrContrato">					
						<fieldset>
							<legend>Contrato</legend>
							<label for="antnrctr" class="rotulo" style="width:250px;">Confirme o n&uacute;mero do contrato:</label>
							<input type="text" name="antnrctr" id="antnrctr" value="" style="width: 80px; text-align: right;" class="campo">
						</fieldset>
					</div>
					
					<div id="divBotoes">
					<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divDscTit_Observacao').css('display','block');$('#divDscTit_Avalistas').css('display','none');return false;">
					<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(1,'frmIncluirDscTit_Renda');return false;">
					</div>

				</div>
			</form>
			<?php 
			// Variável que indica se é uma operação para cadastrar nova proposta - Utiliza na include rating_busca_dados.php
			$cdOperacao = "I";
			
			include("../../../../includes/rating/rating_busca_dados.php");
			?>
		</td>
	</tr>
</table>
<script type="text/javascript">
$("#divOpcoesDaOpcao3").css("display","none");
$("#divOpcoesDaOpcao4").css("display","block");

$("#divDscTit_Renda").css("display","block");
$("#divDscTit_Observacao").css("display","none");
$("#divDscTit_Avalistas").css("display","none");

$("#vloutras","#frmIncluirDscTit_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#vlsalari","#frmIncluirDscTit_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#vlsalcon","#frmIncluirDscTit_Renda").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#dsdbens1","#frmIncluirDscTit_Renda").setMask("STRING","60",charPermitido(),"");
$("#dsdbens2","#frmIncluirDscTit_Renda").setMask("STRING","60",charPermitido(),"");
$("#dsobserv","#frmIncluirDscTit_Renda").setMask("STRING","900",charPermitido(),"");

hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php if ($inconfir == 72 || $inconfir == 19) { ?>
// Mostra informação e continua
showError("inform","<?php echo $mensagem; ?>","Alerta - Aimaro","metodoBlock()");
<?php } ?>
</script>