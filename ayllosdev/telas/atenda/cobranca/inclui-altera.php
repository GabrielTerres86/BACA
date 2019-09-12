<?php

/*************************************************************************
	Fonte: inclui-altera.php
	Autor: Gabriel						Ultima atualizacao: 29/04/2015
	Data : Dezembro/2010
	
	Objetivo: Apresenta a tela de habilitacao do convenio CEB.
			  Inclusao ou alteracao de convenio.
	
	Alteracoes: 19/05/2011 - Tratar cob. regist. (Guilherme).

				14/07/2011 - Alterado para layout padrão (Gabriel - DB1)
				
				25/07/2011 - Incluir Opcao de Imprimir (Gabriel - CECRED)
				
				29/04/2015 - Incluido campo cddbanco. (Reinert)
				
				06/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

$nrconven = $_POST["nrconven"];
$dsorgarq = $_POST["dsorgarq"];
$flgregis = $_POST["flgregis"];
$cddbanco = $_POST["cddbanco"];
$flsercco = $_POST["flsercco"];

$cddopcao = "A"; // Por padrao Alteracao

?>

<form action="" name="frmHabilita" id="frmHabilita" method="post">

	<fieldset>
		<legend><? echo utf8ToHtml('Habilitação') ?></legend>
		
		<label for="nrconven"><? echo utf8ToHtml('Convênio:') ?></label>
		<input id="nrconven" name="nrconven" class="campo" value= "<? echo formataNumericos("zz.zzz.zz9",$nrconven,'.');  ?>" >
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" > </a>
		<br />
		
		
		<label for="dsorgarq"><? echo utf8ToHtml('Origem:') ?></label>
		<input name= "dsorgarq" id="dsorgarq" class="txtNormal" readonly  value="<?php echo $dsorgarq; ?>" />
		
		<input type="hidden" id="flserasa" name="flserasa" class="campo" value="<?php echo $flsercco; ?>" />
		
	</fieldset>
</form>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="limpaCampos();$('#divConteudoOpcao').css('display','block');$('#divOpcaoIncluiAltera').css('display','none');return false;" />
	<input id="btnIncluir" name="btnIncluir" type="image" src="<?php echo $UrlImagens; ?>botoes/incluir.gif" onClick="habilitaCampoConvenio();return false;" />
	<? if ($nrconven != "") { // Se algum convenio selecionado , mostrar botao de alteracao  ?>
		<input id="btnAlterar" name="btnAlterar" type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="consulta('<? echo $cddopcao; ?> ', <?php echo $nrconven; ?> ,' <?php echo $dsorgarq; ?> ' , '<?php echo "false"; ?> ',' <?php echo $flgregis; ?> ', '<?php echo $cddbanco; ?>' );return false;" />
	<? } ?>
	<? if ($nrconven != "") { // Se algum convenio selecionado , mostrar botao de impressao ?>
		<input id="btnImprime" name="btnImprime" type="image" src="<?php echo $UrlImagens; ?>botoes/impressao.gif" onClick="confirmaImpressao('<? echo $flgregis; ?>','<? echo "1"; ?>');return false;" />	
	<?} ?>
	
</div>

<script type="text/javascript">

controlaLayout('frmHabilita');

// Se Nao foi selecionado nenhum convenio, habilita inclusao 
<?php if ($nrconven != "") { ?>
		$("#nrconven","#divOpcaoIncluiAltera").desabilitaCampo();
<?php  } else { ?>
<? } ?>

$("#divConteudoOpcao").css("display","none");
$("#divOpcaoIncluiAltera").css("display","block");
   
blockBackground(parseInt($("#divRotina").css("z-index")));

$("#nrconven","#frmHabilita").unbind('keypress').bind('keypress', function(e) {
	if (e.keyCode == 13) {
		habilitaCampoConvenio();
		return false;		
	}
});

$("#nrconven","#frmHabilita").focus();

function habilitaCampoConvenio(flgdesab) {  
  // Se ja habilitou campo , e agora esta INCLUINDO ...       
  if ($("#nrconven","#divOpcaoIncluiAltera").prop("disabled") == false)  {
	  validaHabilitacao();
	  return;
  }

  $("#nrconven","#divOpcaoIncluiAltera").habilitaCampo(); 
  $("#btnAlterar","#divOpcaoIncluiAltera").prop("disabled",true);  
  $("#nrconven","#divOpcaoIncluiAltera").val("");
  $("#dsorgarq","#divOpcaoIncluiAltera").val("");
  $("#flserasa","#divOpcaoIncluiAltera").val("");
  $("#nrconven","#divOpcaoIncluiAltera").focus();

  controlaPesquisas();
}

</script>

