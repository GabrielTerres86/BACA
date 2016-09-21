<?
/*!
 * FONTE        : tab_justificativa.php						Última alteração: 11/08/2016
 * CRIAÇÃO      : Cristian Filipe (GATI)
 * DATA CRIAÇÃO : Setembro/2013
 * OBJETIVO     : Tabela de justificativas
 * --------------
 * ALTERAÇÕES   : 22/12/2014 - Adicionar validação para a opção selecionada e exibir o botão correspondente.
                             - Adicionar o parametro se é gerado em EXCEL para a impressão do arquivo (Douglas - Chamado 143945)

				  11/08/2016 - Ajuste para fechar o form de solicitação do nome do arquivo ao clicar no botão "OK" (Adriano - SD 495725).

 */
 	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id='divNomeArquivoImpresssao'>
<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Arquivo') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">
										<label for="nmarquivo"><? echo utf8ToHtml('Nome Arquivo Impress&atilde;o:') ?></label>
										<input name="nmarquivo" type="text"  id="nmarquivo" class='campo'/>
										
										<? if (isset($_POST["cddopcao"]) && $_POST["cddopcao"] == "P") { ?>
											<a href="#" class="botao" onClick="fechaRotina($('#divRotina'));geraArquivo('gera_imprime_arq_pesquisa');">OK</a>
										<? } else { ?>
											<a href="#" class="botao" onClick="fechaRotina($('#divRotina'));geraArquivo('gera_imprime_arq_atividade','<?php echo isset($_POST["excel"]) ? $_POST["excel"] : "" ?>');">OK</a>
										<? } ?>
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
</div>