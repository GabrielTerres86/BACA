
<?
/*!
 * FONTE        : consultar_dados_cartao_avais.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Marco/2008
 * OBJETIVO     : Mostrar opção de Novos Cartões da rotina de Cartões de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [15/07/2009] Guilherme       (CECRED) : Incluir títulos no "frame"
 * 000: [03/11/2010] David           (CECRED) : Adaptações para Cartão PJ
 * 001: [04/05/2011] Rodolpho           (DB1) : Adaptações para o formulário genérico de avalistas
 * 002: [08/07/2011] Gabriel      	    (DB1) : Alterado para layout padrão
 * 003: [10/07/2012] Guilherme Maba  (CECRED) : Incluído campo nmextttl no formulário, para pessoa física e jurídica.
 * 004: [16/07/2012] Jorge Hamaguchi (CECRED) : Adicionado titles para os campos de titular e nome no plastico.
 * 005: [09/04/2012] Jean Michel     (CECRED) : Alterações para nova estrutura de cartões.
 * 006: [01/07/2014] Lucas Lunelli   (CECRED) : Correção para não realizar procedimento de validação ao cancelar inclusão.
 * 007: [25/07/2014] Daniel          (CECRED) : Incluso novo campo nome da bandeira.
 * 008: [25/07/2014] Vanessa         (CECRED) : Correção do código da operadora de cartão no option, estva vindo em branco.
 * 009: [23/09/2014] Renato Darosci	 (SUPERO) : Retirar a opção de envio do cartão para cooperado
 * 010: [01/10/2014] Vanessa	     (CECRED) : Incluir parametro bthabipj na chamada da rotina carrega_dados_inclusao
 * 011: [01/10/2014] Vanessa	     (CECRED) : Alterar a ordem dos campos de forma de pagamento SD 236434
 * 012: [06/01/2015] Renato Darosci  (CECRED) : Tratar problema com parametros com apóstrofo na chamada da buscaDados - SD 237892
 * 013: [03/07/2015] Renato Darosci  (CECRED) : Impedir que seja possível informar limite para cartão somente débito
 * 014: [26/08/2015] James					  : Remover o form da impressao.
 * 015: [09/10/2015] James					  : Desenvolvimento do projeto 126.
 * 016: [21/06/2016] Douglas         (CECRED) : Removido aspas simples dos parametros do campo Titularidade (Chamado 457339)
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'voltaDiv(0,1,4);';
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro);	
	}			
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro);	

	$filter = "";
	$filtroAtivo = true;
	$adicional = false;
	$bandeirasPermitidas;
	if(isset($_POST["tipo"])){
		$tipo = $_POST["tipo"];
		$dadosTitular = $_POST['dadostit'];
		if($tipo == "bb")
			$filter = "BB";
		else if($tipo == "dbt")
			$filter = "DEB";
		else if($tipo == "all")
			$filtroAtivo = false;
		else if($tipo == "cecred"){
			
			$filter ="cecred";
			$adicional = true;
			if($adicional && isset($_POST['cdadmcrd']))
				$bandeirasPermitidas = explode("#",$_POST['cdadmcrd']);
			echo "<!--  >>>  \n";
			print_r($dadosTitular);
			echo " \n -->";
				
		}
	}
	
	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);

	// Monta o xml de requisição
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
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetNovoCartao);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjNovoCartao = getObjectXML($xmlResult);
	//echo $xmlResult;
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro);
	}
	

	$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
	
	// Dados Cadastrais
	$dsgraupr = getByTagName($dados,"DSGRAUPR");
	$cdgraupr = getByTagName($dados,"CDGRAUPR");
	$dsadmcrd = getByTagName($dados,"DSADMCRD");
	$cdadmcrd = getByTagName($dados,"CDADMCRD");
	$dscartao = getByTagName($dados,"DSCARTAO");
    $vlsalari = getByTagName($dados,"VLSALARI");
    $dddebito = getByTagName($dados,"DDDEBITO");
	$dsoutros = getByTagName($dados,"DSOUTROS");
	$dslimite = getByTagName($dados,"DSLIMITE");	
	$cdadmdeb = getByTagName($dados,"CDADMDEB");
	$inpessoa = getByTagName($dados,"INPESSOA");
	$cdtipcta = getByTagName($dados,"CDTIPCTA");
	$nmbandei = getByTagName($dados,"NMBANDEI");
	
	// Primeiro Titular
    $nmtitcrd = getByTagName($dados,"NMTITCRD");
    $nrcpfcgc = getByTagName($dados,"NRCPFCGC");
    $dtnasctl = getByTagName($dados,"DTNASCTL");
    $nrdocptl = getByTagName($dados,"NRDOCPTL");
	
    // Segundo Titular    
    $nrcpfstl = getByTagName($dados,"NRCPFSTL");    
    $dtnasstl = getByTagName($dados,"DTNASSTL");
    $nrdocstl = getByTagName($dados,"NRDOCSTL");
    $nmsegntl = getByTagName($dados,"NMSEGNTL");
	
    // Conjuge
    $nmconjug = getByTagName($dados,"NMCONJUG");
    $dtnasccj = getByTagName($dados,"DTNASCCJ");   
	
	// Representantes
	$nrrepinc = getByTagName($dados,"NRREPINC");    
    $dsrepinc = getByTagName($dados,"DSREPINC");    

    // Administradoras que possuem débito	
	// Buscar dias do débito da Administradora que aparece por 1º
	$eCDADMDEB 			 = explode(",",$cdadmdeb);	
    $e_1a_ADMINISTRADORA = explode("#",$dddebito);
    $e_DIASDEBITO        = explode(";",$e_1a_ADMINISTRADORA[0]);
	$eDDDEBITO			 = explode(",",$e_DIASDEBITO[1]);
	
	$cdAdmLimite   		 = explode("#",$dslimite);
	$aListaLimite	     = explode(";",$cdAdmLimite[0]);	
	$cdLimite			 = explode("@",$aListaLimite[1]);

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	//$xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	echo "<!--  $xmlResult  -->";
	$json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);

	$idacionamento = $xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[1]->cdata;

	// Validação para saber se houve ou não alteração no nome da empresa, se houver habilita edição do campo empresa do plástico
	// Augusto - Supero
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml, "ATENDA_CRD", "VALIDA_ALT_EMPR_PLASTICO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
		exibirErro('error', $msgErro, 'Alerta - Ayllos', $funcaoAposErro);
	}
	$habilitarEdicaoEmpresaPlastico = (!empty($xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata) ? $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata : "0");
?>

<style>
[title]{
	background-color: rgb(255,246,143);			
}

#tooltip *{
	font-size		: 10px;
	font-weight		: normal;	
	font-family		: Tahoma;
}
</style>

<script>
	$('#nmtitcrd').tooltip();	
	$('#nmextttl').tooltip();

</script>
<div id="stepRequest">
<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">	
	<div id="divDadosNovoCartao">
		<fieldset style="padding-left: 30px;">
			<legend><? echo utf8ToHtml('Novo Cartão de Crédito') ?></legend>
							
			<label for="dsadmcrd"><? echo utf8ToHtml('Administradora:') ?></label>
			<select name="dsadmcrd" id="dsadmcrd" onblur="" onchange="alteraDiaDebito(); alteraLimiteProposto();  alteraFuncaoDebito(); CarregaTitulares(this.value); configIniValues();" class="campo" >
			<?php
				// Obtém administradoras disponíveis
				$eDSADMCRD = explode(",",$dsadmcrd);										
				// Pega o código da adm;dias do débito
				$e_ADMINISTRADORA = explode("#",$dddebito);	
				$cdAdmLimite 	  = explode("#",$dslimite);	
				
				// Obtem bandeiras disponiveis
                $eNMBANDEI = explode(",",$nmbandei);
				$eCDADMCRD =  explode(",",$cdadmcrd);
                $aRepresentanteOutros = explode(",",$dsoutros);
				echo "<!--";
				print_r($bandeirasPermitidas);
				echo "-->";
				for ($i = 0; $i < count($eDSADMCRD); $i++){
					// pega o código da adm
					if($filtroAtivo && !$adicional){
						$pos = strrpos($eDSADMCRD[$i], $filter);
						if (is_bool($pos) && !$pos) {
							continue;
						}
					}else if($adicional){
						echo "<!-- verificando código:".$eCDADMCRD[$i]." -->";
						if(!in_array($eCDADMCRD[$i],$bandeirasPermitidas))
							continue;
						
					}
					$e_cd_ADMINISTRADORA[$i] = $eCDADMCRD[$i];				
		
					
					// pega os dias de debito da adm
					$e_ddd_ADMINISTRADORA[$i] = substr($e_ADMINISTRADORA[$i],strpos($e_ADMINISTRADORA[$i],";") + 1);
					$aListaLimite[$i] 	  	  = substr($cdAdmLimite[$i],strpos($cdAdmLimite[$i],";") + 1);
					// no value está o codigo, os dias da adm, e se a adm possui débito
					?><option value="<?if (in_array($e_cd_ADMINISTRADORA[$i],$eCDADMDEB)) { echo $e_cd_ADMINISTRADORA[$i] . ";" . $e_ddd_ADMINISTRADORA[$i] . ";temDebito;" . $eNMBANDEI[$i].";".$aListaLimite[$i].";".$aRepresentanteOutros[$i].""; } else { echo $e_cd_ADMINISTRADORA[$i] . ";" . $e_ddd_ADMINISTRADORA[$i] . ";naoTemDebito;" . $eNMBANDEI[$i].";".$aListaLimite[$i].";".$aRepresentanteOutros[$i].""; } ?>"<?if ($i == 0) { echo " selected"; } ?>><?echo $eDSADMCRD[$i]; ?></option><?php
				}
			?>
			</select>
			<div id="conteudoPJ">
				<input type="hidden" name="idacionamento" id="idacionamento" value="" />
				<label for="nmprimtl"><? echo utf8ToHtml('Razão Social:') ?></label>
				<input type="text" name="nmprimtl" id="nmprimtl" class="campoTelaSemBorda" style="width: 400px;" value="<?echo $nmtitcrd; ?>" disabled>
				<br />
					
				<label for="nrcpfcpf"><? echo utf8ToHtml('CNPJ:') ?></label>
				<input type="text" name="nrcpfcpf" id="nrcpfcpf" class="campoTelaSemBorda" style="width: 120px;" value="<?echo formataNumericos("99.999.999/9999-99",$nrcpfcgc,"./-"); ?>" disabled>
				<br />
				
				<label for="dsrepinc"><? echo utf8ToHtml('Representante:') ?></label>
				<select name="dsrepinc" id="dsrepinc" class="campo" style="width: 325px;" onblur="" onchange="selecionaRepresentante();"  >
				</select>
				<br />
			</div>
						
			<div id="titularidade">
				<label for="dsgraupr"><? echo utf8ToHtml('Titularidade:') ?>:</label>
				<select name="dsgraupr" id="dsgraupr" onchange="buscaDados('<?echo $cdtipcta;?>','<?echo formataNumericos("999.999.999-99",$nrcpfstl,".-");?>','<?echo $inpessoa;?>','<?echo $dtnasstl ;?>','<?echo str_replace('\'','',$nrdocstl);?>','<?echo str_replace('\'','',$nmconjug); ?>','<?echo $dtnasccj ;?>','<?echo str_replace('\'','',$nmtitcrd); ?>','<?echo formataNumericos("999.999.999-99",$nrcpfcgc,".-");?>','<?echo $dtnasctl;?>','<?echo str_replace('\'','',$nrdocptl); ?>','<?echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>','<?echo str_replace('\'','',$nmsegntl);?>');" class="campo" style="width: 100px;">
				<?php
				$eDSGRAUPR = explode(",",$dsgraupr);
				$eCDGRAUPR = explode(",",$cdgraupr);
				for ($i = 0; $i < count($eDSGRAUPR); $i++){
					if($adicional && ($eCDGRAUPR[$i]== 1 || $eCDGRAUPR[$i]== 3 || $eCDGRAUPR[$i]== 4 || $eCDGRAUPR[$i]== 5)){
						continue; 
					}
					?><option value="<?echo $eCDGRAUPR[$i] ?>"    <?if ($i == 3 && !$adicional) { echo " selected"; } ?>><?echo $eDSGRAUPR[$i] ?></option><?php
				
				}
				?>
				</select>
				<br />
			</div>
			
			<label for="nrcpfcgc"><? echo utf8ToHtml('C.P.F.:') ?></label>
			<input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo" value="" />				
			
			<div id="titular" style="margin-top:7px;">
				<label for="nmextttl"><? echo utf8ToHtml('Titular:') ?></label>
				<input type="text" name="nmextttl" id="nmextttl" class="campo lock" title="Informar nome conforme Receita Federal" value="" />
				<br />				
			</div>
			
			<br style="clear:both;" />
			<hr style="background-color:#666; height:1px; width:480px;" id="hr1"/>
							
			<label for="nmtitcrd"><? echo utf8ToHtml('Nome no Plástico:') ?></label>
			<input type="text" name="nmtitcrd" id="nmtitcrd" class="campo" title="Nao permitido abreviar o primeiro e o ultimo nome" value="" />
			<br />
			
			<div id="empresa">
				<label for="nmempres"><? echo utf8ToHtml('Empresa do Plástico:') ?></label>
				<input type="text" name="nmempres" id="nmempres" class="campo" value="<?echo $nmtitcrd; ?>" />
				<input type="hidden" name="flgEditEmpPlas" id ="flgEditEmpPlas" value="<?=$habilitarEdicaoEmpresaPlastico?>" />
			</div>
			
			<hr style="background-color:#666; height:1px; width:480px;" id="hr2"/>
			<br style="clear:both;" />
			
			<label for="nrdoccrd"><? echo utf8ToHtml('Identidade:') ?></label>
			<input type="text" name="nrdoccrd" id="nrdoccrd" class="campo" value="" />
			
			<label for="dtnasccr"><? echo utf8ToHtml('Nascimento:') ?></label>
			<input type="text" name="dtnasccr" id="dtnasccr" class="campo" value="" disable />
			<br />
									
			<label for="dscartao"><? echo utf8ToHtml('Tipo:') ?></label>
			<select name="dscartao" id="dscartao" class="campo">
			<?php
			$eDSCARTAO = explode(",",$dscartao);
			for ($i = 0; $i < count($eDSCARTAO); $i++){
			 ?><option value="<?echo $eDSCARTAO[$i]; ?>"<?if ($i == 1) { echo " selected"; } ?>><?echo $eDSCARTAO[$i] ?></option><?php
			}
			?>
			</select>
			
			<label for="dddebito"><? echo utf8ToHtml('Dia Débito:') ?></label>
			<select name="dddebito" id="dddebito" class="campo">
			<?php
			for ($i = 0; $i < count($eDDDEBITO); $i++){
				?><option value="<?echo $eDDDEBITO[$i]; ?>"<?if ($i == 0) { echo " selected"; } ?>><?echo $eDDDEBITO[$i] ?></option><?php
			}
			?>
			</select>
			<br />
			
			<label for="vlsalari"><? echo utf8ToHtml('Salário:') ?></label>
			<input type="text" name="vlsalari" id="vlsalari" class="campo" value="0,00" />
			
			<label for="vlsalcon"><? echo utf8ToHtml('Salário Cônjuge:') ?></label>
			<input type="text" name="vlsalcon" id="vlsalcon" class="campo" value="0,00" />
			<br />
			
			<label for="vloutras"><? echo utf8ToHtml('Outras Rendas:') ?></label>
			<input type="text" name="vloutras" id="vloutras" class="campo" value="0,00" />
			
			<label for="vlalugue"><? echo utf8ToHtml('Aluguel:') ?></label>
			<input type="text" name="vlalugue" id="vlalugue" class="campo" value="0,00" />
			<br />
			
			<label for="vllimpro"><? echo utf8ToHtml('Limite Proposto:'); ?></label>
			<div id="limiteDiv">
				<? if($adicional || $tipo == "dbt"){?>
				<select class='campo' id='vllimpro' name='vllimpro' disabled readonly>
					<?php
					//for ($i = 0; $i < count($cdLimite); $i++){
						?><option value="0,00" ><?echo formataMoeda(0.00); ?></option>
					<?php //} ?>
				</select>
				<?php
				}else{
					?>
					<input class='campo' id='vllimpro' name='vllimpro' style='width: 110px; text-align: right;' value='<? echo number_format( 0,2,",",".");?>'>
					<?
				}
					?>
			</div>
			<label for="flgdebit"><? echo utf8ToHtml('Habilita função débito:') ?></label>
			<input type="checkbox" name="flgdebit" id="flgdebit" class="campo" value="" onclick='confirmaPurocredito();'/>
			
			<br />
			
			<label for="flgimpnp"><? echo utf8ToHtml('Promissória:') ?></label>
			<select name="flgimpnp" id="flgimpnp" class="campo">
					<option value="yes" selected>Imprime</option>
			</select>

			<label for="vllimdeb"><? echo utf8ToHtml('Limite Débito:') ?></label>
			<input type="text" name="vllimdeb" id="vllimdeb" class="campo" value="0,00" />
			<br />
			<label for="tpdpagto"><? echo utf8ToHtml('Forma de Pagamento:') ?></label>
			<select class='campo' id='tpdpagto' name='tpdpagto'>						
						<option value='0' selected> </option>
						<option value='2'>Debito CC Minimo</option>
						<option value='1'>Debito CC Total</option>
						<option value='3'>Boleto</option>
					</select>
			<label for="tpenvcrd"><? echo utf8ToHtml('Envio:') ?></label>
			<select class='campo' id='tpenvcrd' name='tpenvcrd'>
						<option value='1' selected>Cooperativa</option>
						<!--option value='0'>Cooperado</option      OPÇÃO RETIRADO TEMPORÁRIAMENTE, PARA QUE SEJA ENVIADO SEMPRE PARA A COOPERATIVA (RENATO - SUPERO)-->
					</select>				
			<br />
		</fieldset>
		
		<div id="divBotoes" >
			<input class="btnVoltar" type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="opcaoNovo(1);return false;" />
			<input type="image" id="btnsaveRequest" src="<?echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="$('#nmtitcrd').click(); $('#nmextttl').click(); verificaEfetuaGravacao();return false;" />
			<a style="display:none"  cdcooper="<?php echo $glbvars['cdcooper']; ?>" 
				cdagenci="<?php echo $glbvars['cdpactra']; ?>" 
				nrdcaixa="<?php echo $glbvars['nrdcaixa']; ?>" 
				idorigem="<?php echo $glbvars['idorigem']; ?>" 
				cdoperad="<?php echo $glbvars['cdoperad']; ?>"
				dsdircop="<?php echo $glbvars['dsdircop']; ?>"

				href="#" class="botao" id="emiteTermoBTN" onclick="imprimirTermoDeAdesao(this);"> <? echo utf8ToHtml("Imprimir Termo de Adesão");?></a>

		</div>
				
	</div>
	<div id="divDadosAvalistas" class="condensado">
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../includes/avalistas/form_avalista.php'); 
		?>
		<div id="divBotoes">
			<input type="image" id="btVoltar" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosCartao();return false;">
			<input type="image" src="<?echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','voltaDiv(0,1,4)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
			<input type="image" id="btSalvar" src="<?echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(4);return false;">
		</div>
	</div>
</form>
</div>
<div id="ValidaSenha" style="display:none">

    </div>
<script type="text/javascript">


	function prosseguir(){
		$('#nmtitcrd').click(); 
		$('#nmextttl').click(); 
		verificaEfetuaGravacao();
		return false;

	}
	function verificarSenhaDebito(){
		<?if($filter == "BB"){ ?>
		$('#nmtitcrd').click(); 
		$('#nmextttl').click(); 
		verificaEfetuaGravacao();
		return false;
		<?
			}else{ 
		?>
			solicitaSenhaMagnetico('prosseguir()', nrdconta, '', 'sim.gif', 'nao.gif');
		<?}?>
	}
	controlaLayout('frmNovoCartao');
	
	cpfpriat = "000.000.000-00";

	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");

	mostraDivDadosCartao();
	$("#nmextttl").attr("disabled","disabled");
	
	console.log("escondendo");
	<?php
		if ($inpessoa == "1") { // Pessoa Física 
	?>
		// Seta máscara aos campos
		$("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,charPermitido(),"");
		$("#dtnasccr","#frmNovoCartao").setMask("DATE","","","divRotina");
		$("#nrcpfcgc","#frmNovoCartao").setMask("INTEGER","999.999.999-99","","");
		$("#vlsalari","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#vlsalcon","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#vloutras","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#vlalugue","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");		
		$("#vllimdeb","#frmNovoCartao").setMask("DECIMAL","zzz.zz9,99","","");

		// Carrega os dados do primeiro titular
		$("#dsgraupr","#frmNovoCartao").trigger("change");

		// Carrega dados da administradora padrão
		$("#dsadmcrd","#frmNovoCartao").trigger("change");
		
	<?php
		} else { // Pessoa Jurídica
	?>

		// Seta máscara aos campos
		$("#dtnasccr","#frmNovoCartao").setMask("DATE","","","divRotina");
		$("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,charPermitido(),"");		
		$("#vllimdeb","#frmNovoCartao").setMask("DECIMAL","zzz.zz9,99","","");
		$("#nrcpfcgc","#frmNovoCartao").setMask("INTEGER","999.999.999-99","","");
		
		$("#nrcpfcgc","#frmNovoCartao").unbind("blur").bind("blur",function() {			
			if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
				if ($(this).val() == cpfpriat) {
					return true;
				}
				
				if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
					showError("error","CPF inv&aacute;lido.","Alerta - Ayllos","$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return false;
				}
				
				carregarRepresentante("N",0,$(this).val());
			} else {				
				$("#dtnasccr","#frmNovoCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
			}	
			
			return true;
		});		
		
		// Seta a mácara do cpf
		$("#nrcpfcgc","#frmNovoCartao").trigger("blur");

		// Carrega dados da administradora padrão
		$("#dsadmcrd","#frmNovoCartao").trigger("change");		

	<?php
		}
		if($filter != "BB"){
			?>
			
			$("#dscartao").val("INTERNACIONAL");
			$("#vllimdeb").attr("disabled",true);
			desativa('vllimdeb');
			$("#dscartao").attr("disabled",true);
			$("#dtnasccr").removeAttr("disabled");
			$("#tpdpagto").val(1);
			$("#flgdebit").attr("disabled",'true');
			$("#tpdpagto").attr("disabled",true);
			

			<?php
		}else{
			?>
				
				
			<?
		}
		if($adicional){
				?>
					
					//$("#nmempres").attr("disabled","true");
					function configIniValues(){
						
						console.log("call");
							if($("#dsadmcrd").val().split(";")[0] == 11)
									selecionaEssencial();
							else{
								$("#flgdebit").removeAttr("disabled");
								$("#flgdebit").removeAttr("readonly");
								$("#tpdpagto").removeAttr("disabled");
								$("#limiteDiv").html("<input class='campo' id='vllimpro' name='vllimpro' style='width: 110px; text-align: right;'>");
								
								$("#dddebito").removeAttr("disabled");
								var ddDebit = '<? echo strlen($dadosTitular['ddebimul']) > 0 ? $dadosTitular['ddebimul'] : '' ; ?>';
								
								$('#dddebito').append($("<option></option>").attr("value",ddDebit).text(ddDebit)); 
								$("#dddebito").attr("disabled",true);
								
								$("#vllimpro").attr("disabled",true);
								$("#vllimpro").val("<? echo number_format( $dadosTitular['vllimmul'],2,",",".");?>");
								desativa('vllimpro');
								//tppagtomul
								$("#tpdpagto").attr("disabled",true);
								$("#tpdpagto").val("<? echo $dadosTitular['tppagtomul'];?>");
							}
							
					}	
					function selecionaEssencial(){
							
							
							$("#flgdebit").removeAttr("readonly");
							$("#flgdebit").removeAttr("disabled");
							$("#tpdpagto").removeAttr("disabled");
							//$("#limiteDiv").html("<input class='campo' id='vllimpro' name='vllimpro' style='width: 110px; text-align: right;' readonly>");
							
							$("#dddebito").removeAttr("disabled");
							var ddDebit = '<? echo strlen($dadosTitular['ddebiess']) > 0 ? $dadosTitular['ddebiess'] : '' ; ?>';
							
							$('#dddebito').append($("<option></option>").attr("value",ddDebit).text(ddDebit)); 
							$("#dddebito").attr("disabled",true);
							
							$("#vllimpro").attr("disabled",true);
							desativa("vllimpro");
							$("#vllimpro").val("<? echo number_format( $dadosTitular['vllimess'],2,",",".");?>");
							//tppagtomul
							$("#tpdpagto").attr("disabled",true);
							$("#tpdpagto").val("<? echo $dadosTitular['tppagtoess'];?>");
					}
					globalesteira = false;
					glbadc = 's';
				<?
		} else {
			?>
				function configIniValues(){ }
			<?
		}
		
	?>
	function confirmaPurocredito(){
		if(idastcjt == 1 )
			return;
		dbt = $("#flgdebit").attr("dtb");
		var chk = $("#flgdebit").attr("checked");
		if(chk && chk=="checked" && dbt =='1'){
			showConfirmacao('<? echo utf8ToHtml("Deseja solicitar um Cartão Puro crédito?");?>', 'Confirma&ccedil;&atilde;o - Ayllos', '$("#flgdebit").removeAttr("checked");$("#flgdebit").attr("dtb",0);', "", 'sim.gif', 'nao.gif');
		}
		$("#flgdebit").attr("checked",true);
		$("#flgdebit").attr("dtb",1);
	}

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	$('#dsadmcrd','#frmNovoCartao').focus();
	$(".lock").attr("disabled",true);
	/*globalesteira = false;
	glbadc = 's';*/
	<?
		if($tipo == "dbt"){
			?>
			
			$("#vllimpro").attr("disabled","disabled");
			desativa('vllimpro');
			$("#vllimpro").attr("value","0,00");
			<?
		}
		if($adicional){
		}
		if($filter == "DEB"){
			echo " \n glbadc = 'n' \n";
		}
		echo "/* filtroo = $filter*/"
	?>
	
	contigenciaAtiva = false;
	justificativaCartao = undefined;
</script>