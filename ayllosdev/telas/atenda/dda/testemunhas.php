<?php
/* 
 * FONTE        : testemunhas.php
 * CRIACAO      : Gabriel Ramirez
 * DATA CRIACAO : 14/04/2011 
 * OBJETIVO     : Mostrar a tela de testemunhas.
 * 
 * ALTERACOES   : 26/07/2011 - Incluir tratamento para cobranca Registrada(Gabriel)
 *				  27/07/2016 - Corrigi o tratamento para as variaveis do array $_POST. SD 479874.
*/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nmrotina = ( isset($_POST["nmrotina"]) ) ? $_POST["nmrotina"] : '';
$flgregis = ( isset($_POST["flgregis"]) ) ? $_POST["flgregis"] : ''; // Cobranca Registrada

?>
<form name="divTestemunhas" id="divTestemunhas" class="formulario">
	<input type="hidden" name="flgregis" id="flgregis" value="<? echo $flgregis; ?>">
	<fieldset>
		<legend> Testemunha 1 </legend>
		<table width="100%" border="0" cellspacing="3" cellpadding="0">
			<tr height="25px">
				<td width="105" align="right" class="txtNormalBold">CPF:&nbsp;</td>
				<td><input name="cpftest1" id="cpftest1" type="text" class="campo" style="width:110px;"/></td>			
			</tr>
			<tr>
				<td width="105" align="right" class="txtNormalBold">Nome:&nbsp;</td>
				<td><input name="nmdtest1" id="nmdtest1" type="text" class="campo" style="width:295px;" /></td>		
			</tr>	
		</table>	
	</fieldset>
	<fieldset>
		<legend> Testemunha 2 </legend>
		<table width="100%" border="0" cellspacing="3" cellpadding="0">
			<tr height="25px">
				<td width="105" align="right" class="txtNormalBold">CPF:&nbsp;</td>
				<td><input name="cpftest2" id="cpftest2" type="text" class="campo" style="width:110px;"/></td>				
			</tr>
			<tr>
				<td width="105" align="right" class="txtNormalBold">Nome:&nbsp;</td>
				<td><input name="nmdtest2" id="nmdtest2" type="text" class="campo" style="width:295px;" /></td>		
			</tr>	
		</table>	
	</fieldset>	
</form>
<form action="<?php echo $UrlSite; ?>telas/atenda/dda/impressao_termo.php"  name="frmTermo" id="frmTermo" class="formulario" method="post" >
	<input type="hidden" id="nrdconta" name="nrdconta" value="">	
	<input type="hidden" id="idseqttl" name="idseqttl" value="">	 
	<input type="hidden" id="nmrotina" name="nmrotina" value=""> 
	<input type="hidden" id="nmdtest1" name="nmdtest1" value=""> 
	<input type="hidden" id="cpftest1" name="cpftest1" value=""> 
	<input type="hidden" id="nmdtest2" name="nmdtest2" value=""> 
	<input type="hidden" id="cpftest2" name="cpftest2" value=""> 
</form>

<div id= "botao"> <!-- $('#divTestemunhas').css('display','none');$('#divImpressoes').css('display','block');  -->		
   <input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="acessaOpcaoAba();"/>	
   <input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaCpf('<? echo $nmrotina; ?>')"/>	
</div>
<script type="text/javascript">		
	$("#divConteudoOpcao").css('display','none');	
	$("#divImpressoes").css('display','none');
    $("#divTestemunhas").css({'display':'block'});
	
	blockBackground(parseInt($("#divRotina").css("z-index")));
		
	$("#cpftest1","#divTestemunhas").unbind('blur').bind ('blur', function() {
		buscaDescricao("b1wgen0078.p","traz-nome-testemunha","Nome da testemunha","nrcpftes","nmdtest1",$(this).val(),"nmdteste","","divTestemunhas");
	});
	
	$("#cpftest2","#divTestemunhas").unbind('blur').bind ('blur', function() {
		buscaDescricao("b1wgen0078.p","traz-nome-testemunha","Nome da testemunha","nrcpftes","nmdtest2",$(this).val(),"nmdteste","","divTestemunhas");
	});
</script>