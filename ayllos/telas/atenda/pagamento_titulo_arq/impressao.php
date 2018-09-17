<?php

/***************************************************************

  Fonte: imprimir.php
  Autor: Andre Santos - SUPERO
  Data : Setembro/2014            Ultima atualizacao:  /  /

  Objetivo: Mostrar a rotina de Pagamento de Titulos por
  Arquivo na ATENDA - Exibe termos de Cancelamento e Adesao.

  Alteracoes:

****************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();

$resposta = $_POST["resposta"];

$bufferTermo = str_replace('#NBSP#','&nbsp;'
                          ,str_replace('#center#','<center>'
						  ,str_replace('#div#','<div'
						  ,str_replace('#/div#','</div>'
						  ,str_replace('#/CENTER#','</center>'
						  ,str_replace('#/BR#','<br />'
						  ,str_replace('#/B#','</b>'
						  ,str_replace('#/TABLE#','</table>'
						  ,str_replace('#table#','<table'
						  ,str_replace('#PERCENT#','%'
						  ,str_replace('#TD#','<td>'
						  ,str_replace('#/TD#','</td>'
						  ,str_replace('#TD|#','<td'
						  ,str_replace('#TR#','<tr>'
						  ,str_replace('#/TR#','</tr>'
						  ,str_replace('#P#','<p>'
						  ,str_replace('#/P#','</p>'
						  ,str_replace('#P|#','<p'
						  ,str_replace('#B#','<B>',$resposta)))))))))))))))))));
						  
						  
// Classe para leitura do xml de retorno 
require_once("../../../class/xmlfile.php");
?>
<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="70%">
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
			   <tr>
				    <td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0" >
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">IMPRESS&Atilde;O TERMO DE SERVI&Ccedil;O </td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerrarImpressaoTermo();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
			   </tr>
			   <tr >
					<td class="tdConteudoTela" align="center">
					  <table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td>
								<table border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
									<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba();return false;">Principal</a></td>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
									<td width="1"></td>
								</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								<table id="tbImpressao" width="100%">
									<tr>
										<td>
											<br/><br/><br/>
											<div id="divTermo" class="print">
												<?echo $bufferTermo; ?>
											</div>
											<br/><br/><br/><br/><br/>
											<div id="divBotoes">
												<a href="#" class="botao" id="btnImprimir" name="btnImprimir" onClick="impressaoConteudo();return false;" style = "text-align:right;" >Imprimir Termo</a>
												</br><br/>
											</div>
										</td>
									</tr>
								</table>
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
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>