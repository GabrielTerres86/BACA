<?php 

	/************************************************************************
	  Fonte: busca_help.php
	  Autor: Guilherme
	  Data : Julho/2008                       Última Alteração: 10/07/2012

	  Objetivo : Mostrar o F2 da tela

	  Alterações: 22/10/2010 - Novo parametro na funcao getDataXML (David).

				  10/07/2012 - Adicionado condicional caso seja navegador Chrome
							   em funcao imprimeF2() (Jorge).
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../includes/config.php");
	require_once("../includes/funcoes.php");		
	require_once("../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../class/xmlfile.php");
	
	if ($glbvars["nmdatela"] == ""){
		exibeErro("Voc&ecirc; deve estar em uma tela para utilizar a Ajuda.");
	}
	
	// Monta o xml de requisição
	$xmlF2  = "";
	$xmlF2 .= "<Root>";
	$xmlF2 .= "	<Cabecalho>";
	$xmlF2 .= "		<Bo>b1wgen0029.p</Bo>";
	$xmlF2 .= "		<Proc>busca_help</Proc>";
	$xmlF2 .= "	</Cabecalho>";
	$xmlF2 .= "	<Dados>";
	$xmlF2 .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlF2 .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlF2 .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlF2 .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlF2 .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlF2 .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlF2 .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlF2 .= "		<nmrotina>".$glbvars["nmrotina"]."</nmrotina>";
	$xmlF2 .= "		<inrotina>0</inrotina>";
	$xmlF2 .= "	</Dados>";
	$xmlF2 .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlF2,false);

	// Cria objeto para classe de tratamento de XML
	$xmlObjF2 = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjF2->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjF2->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$nmdatela = $xmlObjF2->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$nmrotina = $xmlObjF2->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$nrversao = $xmlObjF2->roottag->tags[0]->tags[0]->tags[2]->cdata;
	$dtmvtolt = $xmlObjF2->roottag->tags[0]->tags[0]->tags[3]->cdata;
	$cdoperad = $xmlObjF2->roottag->tags[0]->tags[0]->tags[4]->cdata;
	$nmoperad = $xmlObjF2->roottag->tags[0]->tags[0]->tags[5]->cdata;
	$dsdohelp = $xmlObjF2->roottag->tags[0]->tags[0]->tags[6]->cdata;
	$dtlibera = $xmlObjF2->roottag->tags[0]->tags[0]->tags[7]->cdata;
	$tldatela = $xmlObjF2->roottag->tags[0]->tags[0]->tags[9]->cdata;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">

var contWin = 0;
function hideF2(){
	$('#divF2').css('display','none');
	unblockBackground();
	if (nmrotina != ""){
		blockBackground(parseInt($("#divRotina").css("z-index")));	
	}
}
function impF2(){
	if (nmrotina == ""){
		showConfirmacao("Deseja imprimir a AJUDA de TODAS as rotinas da tela?","Confirma&ccedil;&atilde;o - Ayllos","imprimeF2(1);","imprimeF2(0);","sim.gif","nao.gif","60");
	}else{ 
		imprimeF2(0); 
	}
}

function imprimeF2(improtinas){
	
	$('#inrotina','#frmF2').val(improtinas); 
	
	var action = $("#frmF2").attr("action");
	var callafter = "blockBackground(parseInt($('#divF2').css('z-index')));";
	
	carregaImpressaoAyllos("frmF2",action,callafter);
}

var IE4 = (document.all);

var win = window;    
var n  = 0;
function findInPage(str) {

  var txt, i, found;

  if (str == "")
	return false;

  if (IE4) {
	
	txt = win.document.getElementById("txtHelp").createTextRange();
	for (i = 0; i <= n && (found = txt.findText(str)) != false; i++) {
	  txt.moveStart("character", 1);
	  txt.moveEnd("textedit");
	}

	if (found) {
	  txt.moveStart("character", -1);
	  txt.findText(str);
	  txt.select();
	  txt.scrollIntoView();
	  n++;
	}

	else {
	  if (n > 0) {
		n = 0;
		findInPage(str);
	  }
	  else
		showError("error","\""+str+"\" n&atilde;o encontrado.","Alerta - Ayllos","blockBackground(parseInt($('#divF2').css('z-index')))");
	}
  }

  return false;
}
</script>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellspacing="0" cellpadding="0" width="545">
                <tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">F2 - AJUDA</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="hideF2();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr> 	
				<tr>
					<td class="tdConteudoF2">
						<form action="<?php echo $UrlSite;?>f2/imprimir_f2.php" method="post" id="frmF2" name="frmF2">
							<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
							<input type="hidden" name="inrotina" id="inrotina" value="0">
							<table border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="53" height="25" align="right" class="txtNormalBold">Tela:&nbsp;</td>
									<td width="55"><input type="text" name="nmdatela" id="nmdatela" class="campoTelaSemBorda" style="width: 55px;" value="<?php echo $nmdatela ?>" readonly></td>
									<td width="10" align="center" class="txtNormalBold">-</td>
									<td width="145"><input type="text" name="tldatela" id="tldatela" class="campoTelaSemBorda" style="width: 145px;" value="<?php echo $tldatela ?>" readonly></td>
									<td width="50" align="right" class="txtNormalBold">Rotina:&nbsp;</td>
									<td width="130"><input type="text" name="nmrotina" id="nmrotina" class="campoTelaSemBorda" style="width: 130px;" value="<?php echo $nmrotina ?>" readonly></td>
									<td width="55" align="right" class="txtNormalBold">Vers&atilde;o:&nbsp;</td>
									<td><input type="text" name="nrversao" id="nrversao" class="campoTelaSemBorda" style="width: 30px; text-align: right;" value="<?php echo $nrversao ?>" readonly></td>								
								</tr>
							</table>
							<table border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="53" height="25" align="right" class="txtNormalBold">&Uacute;lt.Alter.:&nbsp;</td>
									<td width="80"><input type="text" name="dtmvtolt" id="dtmvtolt" class="campoTelaSemBorda" style="width: 80px;" value="<?php echo $dtmvtolt ?>" readonly></td>
									<td width="50" align="right" class="txtNormalBold">Liber.:&nbsp;</td>
									<td width="80"><input type="text" name="dtlibera" id="dtlibera" class="campoTelaSemBorda" style="width: 80px;" value="<?php echo $dtlibera ?>" readonly></td>
									<td width="50" align="right" class="txtNormalBold">Por:&nbsp;</td>
									<td><input type="text" name="nmoperad" id="nmoperad" class="campoTelaSemBorda" style="width: 215px;" value="<?php echo $nmoperad ?>" readonly></td>								
								</tr>
							</table>
							<table border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td>
										<textarea rows="13" wrap="off" style="width: 525px; background-color: #F4F3F0; font-family: monospace, 'Courier New', Courier;" name="txtHelp" id="txtHelp" readonly><?php echo $xmlObjF2->roottag->tags[0]->tags[0]->tags[6]->cdata;?></textarea>
									</td>
								</tr>
							</table>
							<table border="0" cellspacing="5" cellpadding="0">
								<tr>
									<td>
										<div id="divRodape1" name="divRodape1">
										<table border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td width="350" align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="impF2();return false;"></td>
												<td width="8"></td>		
												<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/sair.gif" onClick="hideF2();return false;"></td>
											</tr>
										</table>
										</div>
										<div id="divRodape2" name="divRodape2">
										<table border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td width="120" align="right" class="txtNormalBold">Pesquisar:&nbsp;</td>
												<td width="120"><input type="text" name="dspesqui" id="dspesqui" class="campo" style="width: 120px;" value=""></td>
												<td width="25" align="center"><a href="#" onClick="findInPage(document.getElementById('dspesqui').value);return false;" class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a></td>
												<td width="50"></td>
												<td width="58" align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="impF2();return false;"></td>
												<td width="8"></td>		
												<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/sair.gif" onClick="hideF2();return false;"></td>
											</tr>
										</table>
										</div>
									</td>
								</tr>
							</table>						
						</form>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>


<script type="text/javascript">
// Mostra o div da Tela da Ajuda
$("#divF2").css("display","block");

if (IE4){
	$("#divRodape2").css("display","block");
	$("#divRodape1").css("display","none");
}else {
	$("#divRodape2").css("display","none");
	$("#divRodape1").css("display","block");
}
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div do F2
blockBackground(parseInt($("#divF2").css("z-index")));
</script>