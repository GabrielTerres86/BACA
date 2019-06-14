<?php

session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

?>
<table width="100%"  border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<table border="0" cellspacing="0" cellpadding="0" align="left">
				<tr>
					<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="20" id="imgAbaEsq5"></td>
					<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen5"><a href="#" id="linkAba5" onClick="acessaOpcaoAba(7,5,'');return false;" class="txtNormalBold">Integralizar Cotas</a></td>
					<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="20" id="imgAbaDir5"></td>
					<td width="1"></td>
					<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="20" id="imgAbaEsq6"></td>
					<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen6"><a href="#" id="linkAba6" onClick="acessaOpcaoAba(7,6,'L');return false;" class="txtNormalBold">Estornar Integralização</a></td>
					<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="20" id="imgAbaDir6"></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
			<div id="divIntegralizacao" style="height: 160px;">
				<form action="" method="post" name="frmIntegraliza" id="frmIntegraliza" class="formulario">
					<br/>
					<label for="vintegra">Valor da Integralização:</label>
					<input name="vintegra" id="vintegra" type="text"/>			
					<input type="image" id="btnIntegra"  src="<?php echo $UrlImagens; ?>botoes/integralizar_cotas.gif" onClick="integralizaCotas(true);return false;">
				</form>	
			</div>
			
			<div id="divEstorno" style="height: 160px; width: 100%;">
			
			</div>
		</td>
	</tr>
</table>

<script type="text/javascript">

// Mostra div da rotina
mostraRotina();

$("#vintegra","#divIntegralizacao").setMask("DECIMAL","zzz.zzz.zz9,99","","");

controlaLayout('INTEGRALIZA');

acessaOpcaoAba(7, 5, '');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>