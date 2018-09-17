<?
/*!
 * FONTE        : dossie_digidoc.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Fomulário de dados de Identificação Física
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */


 	session_start();
 	require_once('../../includes/config.php');
 	require_once('../../includes/funcoes.php');
 	require_once('../../includes/controla_secao.php');
 	require_once('../../class/xmlfile.php');
 	isPostMethod();
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DOSSI&Ecirc; DIGIDOC</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btVoltar" href="#" onClick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo(divRotina); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                  <a href="#" class="botao" style="margin: 7px;" id="btDocCadastrais" onclick="window.open('http://<?php echo $GEDServidor; ?>/smartshare/Cliente/ViewerExterno.aspx?pkey=G7o9A&CPF/CNPJ=<? echo $_POST['nrcpfcgc']?>','_blank');">Documentos Cadastrais</a>
                  <a href="#" class="botao" style="margin: 7px;" id="btDocContas" onclick="window.open('http://<?php echo $GEDServidor; ?>/smartshare/Cliente/ViewerExterno.aspx?pkey=9lODJ&CONTA=<? echo str_replace("-",".",formataContaDV($_POST['nrdconta']));?>&COOPERATIVA=<? echo $glbvars['cdcooper']; ?>','_blank');">Documentos de Contas</a>
                </td>
              </tr>
            </table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
