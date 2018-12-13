<?php

/***************************************************************

  Fonte: reciprocidade.php
  Autor: Andre Clemer (Supero)
  Data : Novembro/2018            Ultima atualizacao: --/--/----
  
  Objetivo: Mostrar a rotina de Reciprocidade na ATENDA.
  
  Alteracoes: 
****************************************************************/

session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	
		
$_POST['nmrotina'] = 'COBRANCA';
		
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");
	
// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
	exit();
}	

$nrdconta = $_POST['nrdconta']; 
$labelRot = $_POST['labelRot'];	

// Carrega permiss&otilde;es do operador
include("../../../includes/carrega_permissoes.php");	
	
setVarSession("opcoesTela",$opcoesTela);

// Monta o xml para a requisicao
$xmlGetDadosCobranca  = "";
$xmlGetDadosCobranca .= "<Root>";
$xmlGetDadosCobranca .= " <Cabecalho>";
$xmlGetDadosCobranca .= "   <Bo>b1wgen0082.p</Bo>";
$xmlGetDadosCobranca .= "   <Proc>carrega-convenios-ceb</Proc>";
$xmlGetDadosCobranca .= " </Cabecalho>";
$xmlGetDadosCobranca .= " <Dados>";
$xmlGetDadosCobranca .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
$xmlGetDadosCobranca .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlGetDadosCobranca .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlGetDadosCobranca .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlGetDadosCobranca .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlGetDadosCobranca .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlGetDadosCobranca .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosCobranca .= "   <idseqttl>1</idseqttl>";         
$xmlGetDadosCobranca .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlGetDadosCobranca .= " </Dados>";      
$xmlGetDadosCobranca .= "</Root>";   

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosCobranca);
// Cria objeto para classe de tratamento de XML
$xmlObjDadosCobranca = getObjectXML($xmlResult);
// Se ocorrer um erro, mostra cr&iacute;tica
if (isset($xmlObjDadosCobranca->roottag->tags[0]->name) && strtoupper($xmlObjDadosCobranca->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosCobranca->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

$emails = $xmlObjDadosCobranca->roottag->tags[2]->tags;

$emails_titular = '';

// Concatena todos os emails do cooperado
foreach($emails as $email) {
   $emails_titular  = ($emails_titular == '') ? '' : $emails_titular . '|';
   $emails_titular .= $email->tags[0]->cdata . ',' . $email->tags[1]->cdata;
}

?>
<input type="hidden" id= "emails_titular" name="emails_titular" value="<?php echo $emails_titular; ?>">	

<form action="<?php echo $UrlSite; ?>telas/atenda/reciprocidade/imprimir_relatorio.php" name="frmRelatorio" class="formulario" id="frmRelatorio" method="post">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
    <input type="hidden" name="nmarquiv" id="nmarquiv" />
    <input type="hidden" name="nrdconta" id="nrdconta" />
    <input type="hidden" name="nmprimtl" id="nmprimtl" />
    <input type="hidden" name="cdagenci" id="cdagenci" />
</form>	

<form action="<?php echo $UrlSite; ?>telas/atenda/reciprocidade/impressao_termo.php" name="frmTermo" class="formulario" id="frmTermo" method="post">
	<input type="hidden" id="nrdconta" name="nrdconta" value="">	
	<input type="hidden" id="dsdtitul" name="dsdtitul" value="">
	<input type="hidden" id="flgregis" name="flgregis" value="">
	<input type="hidden" id="nmdtest1" name="nmdtest1" value="">
	<input type="hidden" id="cpftest1" name="cpftest1" value="">
	<input type="hidden" id="nmdtest2" name="nmdtest2" value="">
	<input type="hidden" id="cpftest2" name="cpftest2" value="">
	<input type="hidden" id="nrconven" name="nrconven" value="">
	<input type="hidden" id="idrecipr" name="idrecipr" value="">
	<input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" id="tpimpres" name="tpimpres" value="">
</form>


<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="0" width="420">
			   <tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0" >
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"> COBRAN&Ccedil;A </td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						
							</tr>
						</table>					
					</td>  
			   </tr>
			   			   
			   <tr >		   
					<td class="tdConteudoTela" align="center">																	
					  <table width="480" border="0" cellspacing="0" cellpadding="0">							
						<tr>													
							<td>								
								<table border="0" cellspacing="0" cellpadding="0">
								<tr>
		
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
									<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoContratos();return false;">Principal</a></td>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
									<td width="1"></td>								
								</tr>
								</table>																		
							</td>
						</tr>
						
						<tr>	
							<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								<div id="divConteudoOpcao"> </div>
								<div id="divOpcaoConsulta"></div>
								<div id="divOpcaoIncluiAltera"></div>
								<div id="divTitular"></div>
							    <div id="divTestemunhas"></div>
                                <div id="divLogCeb"></div>
								<div id="divLogNegociacao"></div>
                                <div id="divServSMS"></div>
								<div id="divHabilita_SMS"></div>
								<div id="divAbaTarifas"></div>
								<div id="divConvenios"></div>
								<div id="telaAprovacao"></div>
								<div id="telaRejeicao"></div>
							</td>							
						</tr>
						
					</table>
				  </td>        
				</tr> 		   					
			</table>	
		</td>
	</tr>	
</table>


<script type="text/javascript">	

	// Mostra div da rotina
	mostraRotina();

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	if ($('<?php echo str_replace("label", "value", $labelRot) ?>').text() == 'SIM') {
		// Mostra a Aba Principal com lista dos Conv&ecirc;nios
		<?php echo "acessaOpcaoContratos();"; ?>
	}else {
		<?php echo "acessaOpcaoDescontos('I');"; ?>
	}
	

</script>
