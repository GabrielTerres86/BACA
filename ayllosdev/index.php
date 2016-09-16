<?php
/*!
 * FONTE        : index.php
 * CRIA��O      : David Giovanni Kistner (Cecred)
 * DATA CRIA��O : Julho/2007
 * OBJETIVO     : Efetuar login no sistema Ayllos
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [30/07/2010] - David G. Kistner (Cecred): Armazenar novas vari�veis na SESSION e acionar a HOME via m�todo POST
 * 002: [22/10/2010] - David G. Kistner (Cecred): Novo parametro para funcao getDataXML
 * 003: [21/03/2011] - David G. Kistner (Cecred): Alterar limite de digita��o do campo Operador de 3 para 10
 * 004: [18/07/2011] - Gabriel (Cecred)         : Trazer campo de verificacao da senha do operador
 * 005: [19/09/2011] - David G. Kistner (Cecred): Ajuste no controle para verificar se existe um login em andamento
 * 006: [19/01/2012] - Tiago (Cecred)           : Incluido campo PAC trabalho
 * 007: [30/03/2012] - David G. Kistner (Cecred): Incluir novas cooperativas (Credimilsul e Viacredi Alto Vale)
 * 008: [08/02/2013] - Lucas R. (Cecred): Incluir campo flgperac e nvoperad em glbvars.
 * 009: [09/08/2013] - Carlos (Cecred)          : Altera��o da sigla PAC para PA.
 * 010: [22/01/2014] - David G. Kistner (Cecred): Incluir nova cooperativa transulcred
 */
?> 
<?php	
	session_start();	
	
	// Includes para vari�veis globais de controle, e biblioteca de fun��es
	require_once("includes/config.php");
	require_once("includes/funcoes.php");		
	
	isPostMethod(true);
	
	// Verificar se foi enviado alguma cr�tica para a tela principal
	if (isset($_POST["dsmsgerr"]) && trim($_POST["dsmsgerr"]) <> "") {
		$dsmsgerr = $_POST["dsmsgerr"];
	}
	
	// Par�metros enviados pela tela de login e sele��o do sistema
	$cdcooper   = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 3;
	$gidnumber  = isset($_POST["gidnumber"]) ? $_POST["gidnumber"] : "";
	$mtccserver = isset($_POST["mtccserver"]) ? $_POST["mtccserver"] : "";
	
	// Se m�todo de requisi��o for post, encaminha dados para BO
	if (isset($_POST["cdoperad"]) && isset($_POST["cddsenha"]) && isset($_POST["cdpactra"])) {
		$cdoperad = $_POST["cdoperad"];
		$cddsenha = $_POST["cddsenha"];
		$cdpactra = $_POST["cdpactra"];
		
		if (trim($cdoperad) == "" || trim($cddsenha) == "" || trim($cdpactra) == "") {
			$dsmsgerr = "Dados n&atilde;o informados corretamente.";
		} else {		
			// Monta o xml de requisi��o
			$xmlLogin  = "";
			$xmlLogin .= "<Root>";
			$xmlLogin .= "	<Cabecalho>";
			$xmlLogin .= "		<Bo>b1wgen0000.p</Bo>";
			$xmlLogin .= "		<Proc>efetua_login</Proc>";
			$xmlLogin .= "	</Cabecalho>";
			$xmlLogin .= "	<Dados>";
			$xmlLogin .= "		<cdcooper>".$cdcooper."</cdcooper>";
			$xmlLogin .= "		<cdagenci>0</cdagenci>";
			$xmlLogin .= "		<nrdcaixa>0</nrdcaixa>";
			$xmlLogin .= "		<cdoperad>".$cdoperad."</cdoperad>";
			$xmlLogin .= "		<idorigem>5</idorigem>";
			$xmlLogin .= "		<vldsenha>yes</vldsenha>";
			$xmlLogin .= "		<cddsenha>".$cddsenha."</cddsenha>";
			$xmlLogin .= "		<cdpactra>".$cdpactra."</cdpactra>";
			$xmlLogin .= "	</Dados>";
			$xmlLogin .= "</Root>";
			
			// Classe para leitura do xml de retorno
			require_once("class/xmlfile.php");	
			
			// Executa script para envio do XML
			$xmlResult = getDataXML($xmlLogin,false,true,$cdcooper);
			
			// Cria objeto para classe de tratamento de XML
			$xmlObjLogin = getObjectXML($xmlResult);
			
			// Se BO retornou alguma erro, atribui cr�tica a vari�vel $dsmsgerr
			if (strtoupper($xmlObjLogin->roottag->tags[0]->name) == "ERRO") {
				$dsmsgerr = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[4]->cdata;
			} else {
				// Verifica se est� sendo efetuado um login no momento
				$flglogin = false;
				$inilogin = strtotime("now");
				
				while (($flglogin = isset($_SESSION["sidlogin"]))) {				
					// 5 segundos � o tempo limite para efetuar o login
					if ((strtotime("now") - $inilogin) >= 5) {
						break;
					}
				}
				
				if ($flglogin) {
					if (($inilogin - $_SESSION["hrdlogin"]) >= 10) {
						$flglogin = false;
					} else {
						$dsmsgerr = "Sistema ocupado. Um tentativa de login j&aacute; estava sendo efetuada.";
					}
				} 
				
				if (!$flglogin) {				
					// Criar SID de login para armazenamento de dados na SESSION
					$sidlogin = md5(time().uniqid());						
					
					// Armazena SID para utilizar no momento que a HOME � carregada
					$_SESSION["sidlogin"] = $sidlogin;				
					$_SESSION["hrdlogin"] = strtotime("now");
					
					// Cria array tempor�rio com vari�veis globais					
					$glbvars["cdcooper"] = $cdcooper;		
					$glbvars["nmcooper"] = strtolower($xmlObjLogin->roottag->tags[0]->tags[0]->tags[1]->cdata);	
					$glbvars["cdagenci"] = 0;
					$glbvars["nrdcaixa"] = 0;
					$glbvars["cdoperad"] = $cdoperad;							
					$glbvars["nmoperad"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[0]->cdata;				
					$glbvars["dtmvtolt"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[2]->cdata;
					$glbvars["dtmvtopr"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[3]->cdata;
					$glbvars["dtmvtoan"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[4]->cdata;
					$glbvars["inproces"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[5]->cdata;
					$glbvars["idorigem"] = 5;
					$glbvars["idsistem"] = 1;
					$glbvars["stimeout"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[6]->cdata;
					$glbvars["dsdepart"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[7]->cdata;
					$glbvars["dsdircop"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[8]->cdata;
					$glbvars["hraction"] = strtotime("now");
					$glbvars["flgdsenh"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[9]->cdata; // Verifica se tem q trocar de senha 
					$glbvars["sidlogin"] = $sidlogin;
					$glbvars["cdpactra"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[10]->cdata;
					$glbvars["flgperac"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[11]->cdata;
					$glbvars["nvoperad"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[12]->cdata;
					
					// Armazena os dados globais na session
					$_SESSION["glbvars"][$sidlogin] = $glbvars;				
					// Efetuar login atrav�s do form para for�ar o acesso via POST
					// Assim � poss�vel impedir que o operador carregue a HOME diretamente no browse
					?>
					<html>
					<head>
					</head>
					<body>
					<form action="home.php" name="frmLogin" id="frmLogin" method="post">				
					<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $sidlogin; ?>">
					</form>
					<script type="text/javascript">document.frmLogin.submit();</script>
					</body>
					</html>				
					<?php				
					
					exit();
				}
			} 
		}
	} else {
		// Verifica permiss�o para acessar o servidor (pkgdesen, pkgprod, etc ...)
		if (!is_array($mtccserver) || !in_array($MTCCServers[$DataServer],$mtccserver)) {
			redirecionaErro("html",$UrlLogin,"_self","Acesso n&atilde;o autorizado neste servidor.");			
			exit();
		}
	}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Pragma" content="no-cache">
<title><?php echo $TituloSistema; ?></title>
<link href="css/estilo.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="scripts/jquery.js"></script>
<script type="text/javascript" src="scripts/dimensions.js"></script>
<script type="text/javascript" src="scripts/funcoes.js"></script>
<script type="text/javascript"> 
$(document).ready(function () { 
	<?php if (isset($dsmsgerr)) { ?>
	showError("error","<?php echo addslashes($dsmsgerr); ?>","Alerta - Ayllos","$('#cdoperad').focus()");
	<?php } else { ?>
	// Setar foco no campo Operador
	$("#cdoperad").focus();	
	<?php } ?>

	// Validar dados do formul�rio de login
	$("#frmLogin").submit(function () {				
		// Validar c�digo do operador
		if ($("#cdoperad").val() == "") {
			showError("error","Informe o c&oacute;digo do Operador!","Alerta - Ayllos","$('#cdoperad').focus()");
			return false;
		}				
		// Validar PAC do operador
		if ($("#cdpactra").val() == "") {
			showError("error","Informe o PA do Operador!","Alerta - Ayllos","$('#cdpactra').focus()");
			return false;		
		}
		// Validar senha do operador
		if ($("#cddsenha").val() == "") {
			showError("error","Informe a senha do Operador!","Alerta - Ayllos","$('#cddsenha').focus()");
			return false;
		}
		
		return true;
	});
	
	$("#cdoperad").blur(function () {				
		
		if ($(this).val() == "") {
			return false;	
		}
		
		var cdcooper = $("#cdcooper").val();
		var cdoperad = $("#cdoperad").val();
		
		showMsgAguardo("Aguarde, carregando PA de trabalho ...");
	   
		// Carrega dados da conta atrav�s de ajax
		$.ajax({		
			type: "POST",			
			async : true ,
			url: UrlSite + "consulta_pac_ope.php", 
			data: {
				cdcooper: cdcooper,
				cdoperad: cdoperad,							
				redirect: 'script_ajax' // Tipo de retorno do ajax
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","unblockBackground()");
			},
			success: function(response) {				
				try {				    
					eval(response);										
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});	
		
		return true;
	});
}); 
</script>
</head>
<body>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center" valign="middle">
			<table border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td id="tdTituloLogin" background="<?php echo $UrlImagens; ?>background/bg_login.gif">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="15" height="49">&nbsp;</td>
								<td width="215"><img src="<?php echo $UrlImagens; ?>logos/logo_cecred.gif"></td>
								<td align="right" valign="bottom"><img src="<?php echo $UrlImagens; ?>geral/tit_login.gif" width="210" height="27"></td>
								<td width="15">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td bgcolor="#CBD1C5">
						<table border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="15">&nbsp;</td>
								<td align="center" width="200">									
									<p class="txtLabelBold">Seja bem vindo ao</p>
									<p class="txtSistema"><?php echo $TituloLogin; ?></p>									
								</td>
								<td width="15">&nbsp;</td>
								<td width="208" align="center" id="tdLogin">
									<form action="index.php" name="frmLogin" id="frmLogin" method="post">
									<input type="hidden" name="gidnumber" id="gidnumber" value="<?php echo $gidnumber; ?>">
									<?php if (!in_array($gidnumber,$gidNumbers)) { ?>
									<input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $cdcooper; ?>">
									<?php } ?>
									<table width="100%" border="0" cellspacing="0" cellpadding="10">
										<tr>
											<td>
												<table width="100%" border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td height="8" width="6"></td>
														<td></td>
														<td width="126"></td>
													</tr>
													<?php if (in_array($gidnumber,$gidNumbers)) { ?>																										
													<tr>
														<td height="25"></td>
														<td class="txtNormalBold">Cooperativa:</td>
														<td>
															<select name="cdcooper" class="campo" id="cdcooper" style="width:120px;">
																<option value="1"<?php if ($cdcooper == "1") { echo " selected"; } ?>>Viacredi</option>
																<option value="2"<?php if ($cdcooper == "2") { echo " selected"; } ?>>Creditextil</option>
																<option value="3"<?php if ($cdcooper == "3") { echo " selected"; } ?>>Cecred</option>
																<option value="4"<?php if ($cdcooper == "4") { echo " selected"; } ?>>Concredi</option>
																<option value="5"<?php if ($cdcooper == "5") { echo " selected"; } ?>>Cecrisacred</option>
																<option value="6"<?php if ($cdcooper == "6") { echo " selected"; } ?>>Credifiesc</option>
																<option value="7"<?php if ($cdcooper == "7") { echo " selected"; } ?>>Credcrea</option>
																<option value="8"<?php if ($cdcooper == "8") { echo " selected"; } ?>>Credelesc</option>
																<option value="9"<?php if ($cdcooper == "9") { echo " selected"; } ?>>Transpocred</option>
																<option value="10"<?php if ($cdcooper == "10") { echo " selected"; } ?>>Credicomin</option>
																<option value="11"<?php if ($cdcooper == "11") { echo " selected"; } ?>>Credifoz</option>
																<option value="12"<?php if ($cdcooper == "12") { echo " selected"; } ?>>Crevisc</option>
																<option value="13"<?php if ($cdcooper == "13") { echo " selected"; } ?>>ScrCred</option>
																<option value="14"<?php if ($cdcooper == "14") { echo " selected"; } ?>>Rodocredito</option>
																<option value="15"<?php if ($cdcooper == "15") { echo " selected"; } ?>>Credimilsul</option>
																<option value="16"<?php if ($cdcooper == "16") { echo " selected"; } ?>>Viacredi Alto Vale</option>
																<option value="17"<?php if ($cdcooper == "17") { echo " selected"; } ?>>Transulcred</option>
															</select>
														</td>
													</tr>
													<?php } ?>													
													<tr>
														<td height="25"></td>
														<td class="txtNormalBold">Operador:</td>
														<td><input name="cdoperad" id="cdoperad" type="text" class="campo" style="width:120px;" maxlength="10" value="<?php if (isset($cdoperad)) { echo $cdoperad; } ?>"></td>
													</tr>																										
													<tr>
														<td height="25"></td>
														<td class="txtNormalBold">Senha:</td>
														<td><input name="cddsenha" id="cddsenha" type="password" class="campo" style="width:120px;" maxlength="20"></td>
													</tr>													
													<tr>
														<td height="25"></td>
														<td class="txtNormalBold">PA trabalho:</td>
														<td><input name="cdpactra" id="cdpactra" type="text" class="campo" style="width:120px;" maxlength="3"></td>
													</tr>																										
													<tr>
														<td height="35"></td>
														<td></td>
														<td align="right"><input name="btnEntrar" type="image" id="btnEntrar" src="<?php echo $UrlImagens; ?>botoes/entrar.gif" style="width:60px;height:20px;border:0;margin-right:11px;" /></td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
									</form>
								</td>
								<td width="15">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td bgcolor="#CBD1C5" height="25">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html> 
