<?php
    /*!
     * FONTE        : form_gerar.php
     * CRIAÇÃO      : Jaison
     * DATA CRIAÇÃO : 07/01/2016
     * OBJETIVO     : Formulario de geracao
     * --------------
     * ALTERAÇÕES   : 
     * --------------
     */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'G')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADPRE", "CONSULTAR_CARGA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$carga = $xmlObjeto->roottag->tags[0]->tags;
?>

<script language="javacript">
    formataGridCarga();
</script>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="600">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Gerenciamento de Carga do Crédito Pré-aprovado</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
                        <div id="divCarga" class="divRegistros">
                            <table width="100%">
                                <thead>
                                    <tr>
                                        <th><?php echo utf8ToHtml('Sequ&ecirc;ncia') ?></th>
                                        <th><?php echo utf8ToHtml('Data C&aacute;lculo') ?></th>
                                        <th><?php echo utf8ToHtml('Hora') ?></th>
                                        <th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o') ?></th>
                                        <th><?php echo utf8ToHtml('Status') ?></th>
                                        <th><?php echo utf8ToHtml('Total Calculado') ?></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <?php
                                    foreach ($carga as $r) {
                                        ?>
                                        <tr>
                                            <td>
                                                <input type="hidden" id="hdn_idcarga" value="<?php echo getByTagName($r->tags,'idcarga'); ?>" />
                                                <?php echo getByTagName($r->tags,'idcarga'); ?>
                                            </td>
                                            <td><?php echo getByTagName($r->tags,'dtcalculo'); ?></td>
                                            <td><?php echo getByTagName($r->tags,'hora'); ?></td>
                                            <td><?php echo getByTagName($r->tags,'situacao'); ?></td>
                                            <td><?php echo getByTagName($r->tags,'status'); ?></td>
                                            <td><?php echo getByTagName($r->tags,'vltotal'); ?></td>
                                        </tr>
                                        <?php
                                    }
                                ?>
                                </tbody>
                            </table>
                        </div>
                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
                        <a href="#" class="botao" id="btLiberar" onClick="confirmarAcaoCarga('L'); return false;">Liberar</a>
                        <a href="#" class="botao" id="btBloquear" onClick="confirmarAcaoCarga('B'); return false;">Bloquear</a>
                        <a href="#" class="botao" id="btGerarCarga" onClick="confirmarAcaoCarga('G'); return false;">Gerar Carga</a>
                    </td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>