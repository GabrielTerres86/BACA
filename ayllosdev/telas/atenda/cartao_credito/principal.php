<?php 

	/************************************************************************
	  Fonte: principal.php
	  Autor: Guilherme
	  Data : Marco/2008                 Última Alteração: 09/12/2016

	  Objetivo  : Mostrar opcao Principal da rotina de Cartões de Crédito
				  da tela ATENDA

	  Alterações: 22/10/2010 - Adaptações para PJ (David).       

				  30/11/2010 - Bloqueio cartao Pac 5 AcrediCoop (Gabriel).

				  23/03/2011 - Adicionado opcao de encerramento de cartao
							   de credito (Jorge).

				  08/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )

				  01/08/2011 - Adicionado botao Extrato (Guilherme/Supero)
				  
				  03/07/2013 - Retirado botao Liberar (Daniel - Cecred).
				  
				  24/04/2013 - Tratamento das opções (Jean Michel - Cecred).
				  
				  17/07/2014 - Incluso tratamento para nao lista todo numero
				               do cartao de credito SD 179666 (Daniel)
							   
				  28/07/2014 - Novo tratamento para exibição parcial do
							   número do cartão (Lunelli).

				  29/07/2015 - Incluir a opcao TAA. (James)			   

				  09/12/2016 - (CECRED) : Ajuste realizado conforme solicitado no chamado 574068. (Kelvin)										  				  
				  				  
				  29/11/2016 - P341-Automatização BACENJUD - Alterado a validação 
					           pelo DSDEPART passando a utilizar o CDDEPART (Renato Darosci)   
							   
				  27/03/2017 - Adicionado botão "Dossiê DigiDOC". (Projeto 357 - Reinert)							   
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
	}

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["inpessoa"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lida.");
	}

	// Monta o xml de requisição
	$xmlGetCCredito  = "";
	$xmlGetCCredito .= "<Root>";
	$xmlGetCCredito .= "	<Cabecalho>";
	$xmlGetCCredito .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetCCredito .= "		<Proc>lista_cartoes</Proc>";
	$xmlGetCCredito .= "	</Cabecalho>";
	$xmlGetCCredito .= "	<Dados>";
	$xmlGetCCredito .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCCredito .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCCredito .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCCredito .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCCredito .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCCredito .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetCCredito .= "		<idseqttl>1</idseqttl>";
	$xmlGetCCredito .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCCredito .= "		<flgerlog>TRUE</flgerlog>";
	$xmlGetCCredito .= "	</Dados>";
	$xmlGetCCredito .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCCredito);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCCredito = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCCredito->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCCredito->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$ccredito = $xmlObjCCredito->roottag->tags[0]->tags;
	$flgativo = $inpessoa == "1" ? "yes" : $xmlObjCCredito->roottag->tags[0]->attributes["FLGATIVO"];
	$nrctrhcj = $inpessoa == "1" ? "0" : $xmlObjCCredito->roottag->tags[0]->attributes["NRCTRHCJ"];
	$flgliber = $xmlObjCCredito->roottag->tags[0]->attributes["FLGLIBER"];
	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divCartoes">
	<input type="hidden" name="flgliber" id="flgliber" value="<? echo $flgliber; ?>" >
	<div id="divConteudoLimiteSaqueTAA" style="display: none;"></div>
	<div style="display:none;"><?php include("impressao_form.php"); ?></div>
	<div id="divOpcoesDaOpcao1"></div>
	<div id="divOpcoesDaOpcao2"></div>
	<div id="divOpcoesDaOpcao3"></div>
	<div id="divOpcoesDaOpcao4"></div>	
	<div id="divExtratoDetalhe"></div>	
	<div id="divConteudoCartoes">
		
		<div class="divRegistros">
			<table>
				<thead>
					<tr>
						<? if ($inpessoa <> "1") { ?>
							<th>Conta/dv</th>
						<? } ?>
						<th>Titular</th>
						<th>Administradora</th>
						<th>N&uacute;mero do cart&atilde;o</th>
						<th>Situa&ccedil;&atilde;o</th>
					</tr>			
				</thead>
				<tbody>
					<?  for ($i = 0; $i < count($ccredito); $i++) { 					
							$mtdClick = "selecionaCartao('".getByTagName($ccredito[$i]->tags,'NRCTRCRD')."' , '".getByTagName($ccredito[$i]->tags,'NRCRCARD')."' , '".getByTagName($ccredito[$i]->tags,'CDADMCRD')."' , '".$i."' , '".$cor."' , '".getByTagName($ccredito[$i]->tags,'DSSITCRD')."','".getByTagName($ccredito[$i]->tags,'FLGCCHIP')."');";
					
					?>
						<?;?>
						<tr id="<?php echo $i; ?>" onFocus="<? echo $mtdClick;?>" onClick="<? echo $mtdClick;?>">
							
							<?php if ($inpessoa <> "1") { ?>
								<td><span><? echo getByTagName($ccredito[$i]->tags,"NRDCONTA") ?></span>
									<?php echo formataNumericos("zzzz.zzz-9",getByTagName($ccredito[$i]->tags,"NRDCONTA"),".-"); ?></td>
							<?php } ?>
							<td><?php echo getByTagName($ccredito[$i]->tags,"NMTITCRD"); ?></td>
							<td style="width:50px" ><?php echo getByTagName($ccredito[$i]->tags,"NMRESADM"); ?></td>
							<td><?php echo getByTagName($ccredito[$i]->tags,"DSCRCARD"); ?></td>
							<td><?php echo getByTagName($ccredito[$i]->tags,"DSSITCRD"); ?></td>
							
						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>
		
		<div id="divBotoes">
			
			<input type="image" id="btncons" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='consultaCartao();return false;'"; } ?>>
			
			<input type="image" id="btnnovo" src="<?php echo $UrlImagens; ?>botoes/novo.gif"      <?php if (!in_array("N",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoNovo(" . $glbvars["cdcooper"] . "); return false;'"; } ?>>
			<input type="image" id="btnimpr" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif"  <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoImprimir();return false;'"; } ?>>
			<input type="image" id="btnentr" src="<?php echo $UrlImagens; ?>botoes/entregar.gif"  <?php if (!in_array("F",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoEntregar();return false;'"; } ?>>
			<input type="image" id="btnaltr" src="<?php echo $UrlImagens; ?>botoes/alterar.gif"   <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoAlterar();return false;'"; } ?>>
			<input type="image" id="btnnseg" src="<?php echo $UrlImagens; ?>botoes/2via.gif"      <?php if (!in_array("2",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcao2via();return false;'"; } ?>>
			<input type="image" id="btnreno" src="<?php echo $UrlImagens; ?>botoes/renovar.gif"   <?php if (!in_array("R",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoRenovar();return false;'"; } ?>>
			<input type="image" id="btntaa"  src="<?php echo $UrlImagens; ?>botoes/taa.gif"   <?php if (!in_array("U",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoTAA();return false;'"; } ?>>
			<input class="FluxoNavega" id="btndossie" onclick="dossieDigdoc(1);return false;" type="image" src="http://aylloshomol2.cecred.coop.br/imagens/botoes/dossie.gif">
			
			<br style="clear:both;" />
			
			<input type="image" id="btncanc" src="<?php echo $UrlImagens; ?>botoes/cancelamento_bloqueio.gif" <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoCancBloq();return false;'"; } ?>>
			<input type="image" id="btnence" src="<?php echo $UrlImagens; ?>botoes/encerrar.gif"  <?php if (!in_array("Z",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoEncerrar();return false;'"; } ?>>
			<input type="image" id="btnexcl" src="<?php echo $UrlImagens; ?>botoes/excluir.gif"   <?php if (!in_array("E",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoExcluir();return false;'"; } ?>>
			<input type="image" id="btnextr" src="<?php echo $UrlImagens; ?>botoes/extrato.gif"   <?php if (!in_array("T",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoExtrato();return false;'"; } ?>>
			<input type="image" id="btnupdo" src="<?php echo $UrlImagens; ?>botoes/upgrade-downgrade.gif" <?php if (!in_array("D",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoAlteraAdm();return false;'"; } ?>>
			
			<?php if ($inpessoa <> "1" && $glbvars["cddepart"] == 2 ) { ?>
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/habilitar.gif" <?php if (!in_array("H",$glbvars["opcoesTela"])) { echo "style='cursor: default' onClick='return false;'"; } else { echo "onClick='opcaoHabilitar();return false;'"; } ?>>
			<?php } ?>
		</div>
				
	</div>
</div>
<script type="text/javascript">
	flgativo = "<?php echo $flgativo; ?>";
	nrctrhcj = "<?php echo $nrctrhcj; ?>";

	// Esconde div das opções
	$("#divOpcoesDaOpcao1").css("display","none");
	
	controlaLayout('divConteudoCartoes');

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	
</script>
