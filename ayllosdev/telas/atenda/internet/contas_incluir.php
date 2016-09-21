<?php 

	/**************************************************************************
	      Fonte: contas_incluir.php      	                      	       
	      Autor: Lucas                                                     
	      Data : Maio/2012                   Última Alteração: 31/07/2013		       
	                                                                       
	      Objetivo  : Mostrar forms para inclusão de cnts para transf.     
	                                                                       	 
	                                                                        	 
	      Alterações: 08/04/2013 - Transferencia intercoopertiva (Gabriel)	
                	  31/07/2013 - Correção transferencia intercoop. (Lucas)
                      24/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa) 
	                                                                                                                                  
	****************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	//Utilizado na exibição de dados após validação da Senha
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrctatrf = $_POST["nrctatrf"];
	$intipdif = $_POST["intipdif"];
	$cddsenha = $_POST["cdsnhnew"];
	$cdsnhrep = $_POST["cdsnhrep"];
	$cddbanco = $_POST["cddbanco"];
	$cdageban = $_POST["cdageban"];
	$nmtitula = $_POST["nmtitula"];
	$dscpfcgc = $_POST["dscpfcgc"];
	$inpessoa = $_POST["inpessoa"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$intipcta = $_POST["intipcta"];
    $cdispbif = $_POST["cdispbif"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	//Se executando pela prim. vez, carrega tipos de contas de outras IF's
	if (empty($intipdif) || $intipdif == "2"){
	
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlGetPendentes  = "";
		$xmlGetPendentes .= "<Root>";
		$xmlGetPendentes .= "	<Cabecalho>";
		$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
		$xmlGetPendentes .= "		<Proc>consulta-tipos-contas</Proc>";
		$xmlGetPendentes .= "	</Cabecalho>";
		$xmlGetPendentes .= "	<Dados>";
		$xmlGetPendentes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetPendentes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetPendentes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetPendentes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetPendentes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
		$xmlGetPendentes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlGetPendentes .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlGetPendentes .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xmlGetPendentes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlGetPendentes .= "	</Dados>";
		$xmlGetPendentes .= "</Root>"; 

		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetPendentes);

		// Cria objeto para classe de tratamento de XML
		$xmlObjPendentes = getObjectXML($xmlResult);
		
		$registros = $xmlObjPendentes->roottag->tags[0]->tags;

		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		
		// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
		function exibeErro($msgErro) { 
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
			exit();
		}
	}
		
?>
	
<div id="divBotoes" style="margin-bottom:10px">
	<input type="image" src="<? echo $UrlImagens; ?>botoes/contas_sistema_cecred.gif" onClick="limpaFormularios(); exibeFormInclusaoContas(1); return false;" />
	<input type="image" src="<? echo $UrlImagens; ?>botoes/contas_de_outras_ifs.gif" onClick="limpaFormularios(); exibeFormInclusaoContas(2); return false;"  />
</div>

<form id="frmInclCoop" name="frmInclCoop" class="formulario" method="post" style="display: none;" >
		<fieldset>
			<legend> Habilita&ccedil;&atilde;o - Cadastramento de Contas - Incluir Conta </legend>
			
			<div id="divIncl" style = "padding-left:15px; width:545px">
		
				<br/>
				
				<div style = "padding-left:35px;">
					<label for="cdagectl"><? echo utf8ToHtml('Cooperativa:') ?></label>
					<input style = "width:50px;" class="campo" name="cdagectl" id="cdagectl"/>
					<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
				</div>
				
				<br/><br/>
				
				<div style = "padding-left:50px;">
					<label for="nrctatrf"><? echo utf8ToHtml('Conta/DV:') ?></label>
					<input style = "width:110px;" class="campo" name="nrctatrf" id="nrctatrf" value = "<? echo $nrctatrf ?>" />
				</div>
				
				<br/><br/>
			
				<div style = "padding-left:13px;">
					<label for="nmtitula"><? echo utf8ToHtml('Nome do Titular:') ?></label>
					<input style = "width:323px;" class="campo" name="nmtitula" id="nmtitula" value = "<? echo $nmtitula ?>" />
				</div>
				
				<br/><br/>		
			
				<div style = "padding-left:50px;">
					<label for="dscpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
					<input class="campo" name="dscpfcgc" id="dscpfcgc" value = "<? echo $dscpfcgc ?>" />
				</div>
			
				<br/><br/>
				
				<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value = "<? echo $nrcpfcgc ?>" />
				<input type="hidden" name="inpessoa" id="inpessoa" value = "<? echo $inpessoa ?>" />
				<input type="hidden" name="nrdconta" id="nrdconta" value = "<? echo $nrdconta ?>" />
				<input type="hidden" name="idseqttl" id="idseqttl" value = "<? echo $idseqttl ?>" />
			
			<div id="divBotoes" style="margin-bottom:10px">
				<input type="image" id = "btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="redimensiona(); carregaContas(); return false;" />
				<input type="image" id = "btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="ValidaInclConta(1, true); return false;" />
			</div>
			 </div>			
		</fieldset>
</form>	

<form id="frmInclOtr" name="frmInclOtr" class="formulario" method="post" style="display: none;" >
		<fieldset>
			<legend> Habilita&ccedil;&atilde;o - Cadastramento de Contas - Incluir Conta </legend>
			
			<div id="divIncl" style = "padding-left:5px;">
		
				<br/><br/>
				
				<label for="cddbanco" style = "width:50px;"><? echo utf8ToHtml('Banco:') ?></label>
				<input style="width:50px" class="campo" name="cddbanco" id="cddbanco" value = "<? echo $cddbanco ?> " onblur="carregaISPB($(this).val())"/>
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
				
				<label for="cdispbif" style = "width:35px;"><? echo utf8ToHtml('ISPB:') ?></label>
				<input style="width:70px" class="campo" name="cdispbif" id="cdispbif" maxlength="8" value = "<? echo $cdispbif ?>" onblur="carregaCdbanco($(this).val())" />
				                
				<div id="CamposHabDesab">              
                 <label for="cdageban" style = "width:60px;"><? echo utf8ToHtml('Agência:') ?></label>
				<input style="width:40px" class="campo" name="cdageban" id="cdageban" value = "<? echo $cdageban ?>"/>
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                                  
				<label for="nrctatrf" style = "width:92px;"><? echo utf8ToHtml('Conta&nbsp;Corrente:') ?></label>				
				<input style="width:75px" class="campo" name="nrctatrf" id="nrctatrf" value = "<? echo $nrctatrf ?>" />
			
				<br/><br/>
					
				<div style = "padding-left:13px;">
					<label for="nmtitula"><? echo utf8ToHtml('Nome do Titular:') ?></label>
					<input style = "width:367px;" class="campo" name="nmtitula" id="nmtitula" value = "<? echo $nmtitula ?>" />
				</div>
				
				<br/><br/>		
			
				<div style = "padding-left: 43px;">
					<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
					<input class="campo" name="nrcpfcgc" id="nrcpfcgc" value = "<? echo $nrcpfcgc ?>" />
				</div>
			
				<br/><br/>
			
				<div style = "padding-left:17px;">
					<label for="inpessoa"><? echo utf8ToHtml('Tipo de Pessoa:') ?></label>
					<select id="inpessoa" name="inpessoa" class = "campo">
						<option value="1"<?php if (isset($inpessoa) && $inpessoa == "1") { echo " selected"; }?>>F&iacute;sica</option> 
						<option value="2"<?php if (isset($inpessoa) && $inpessoa == "2") { echo " selected"; }?>>Jur&iacute;dica</option>
					</select>
				</div>
				
				<br/><br/>
				
				<div style = "padding-left:25px;">
					<label for="intipcta"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
					<select id="intipcta" name="intipcta" style = "width:150px;" class = "campo">
					<? foreach ( $registros as $contas ) { ?>
						<option value="<?php echo getByTagName($contas->tags,'intipcta'); ?>" <?php if (isset($intipcta) && $intipcta == getByTagName($contas->tags,'intipcta')) { echo " selected"; } ?>><?php echo getByTagName($contas->tags,'nmtipcta'); ?></option>
					  <? }?>
					</select>
				</div>
				
				<input type="hidden" name="nrdconta" id="nrdconta" value = "<? echo $nrdconta ?>" />
				<input type="hidden" name="idseqttl" id="idseqttl" value = "<? echo $idseqttl ?>" />				
			
				<br/>
				</div> 
				<div id="divBotoes" style="margin-bottom:10px">
					<input type="image" id = "btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="ValidaInclConta(2, true); return false;" />
					<input type="image" id = "btVoltar"	   src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="redimensiona(); carregaContas(); return false;" />
				</div>
			
			</div>
		</fieldset>
</form>	

<input id = "voltar" type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" style = "display: block;"  onClick="redimensiona(); carregaContas(); return false;" />

<script type="text/javascript">

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("width","565");
$("#divConteudoOpcao").css("height","80");

// Esconde mensagem de aguardo
hideMsgAguardo();

blockBackground(parseInt($("#divRotina").css("z-index")));

</script> 