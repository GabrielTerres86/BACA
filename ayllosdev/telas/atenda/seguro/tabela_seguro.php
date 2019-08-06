<? 
/*!
 * FONTE        : tabela_seguro.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 19/09/2011
 * OBJETIVO     : Tabela que apresenta os seguros
 * --------------
 * ALTERAÇÕES   : Michel M Candido
 * DATA CRIAÇÃO : 19/09/2011
 
				  22/06/2016 - Trazer os novos contratos de seguro adicionados a base de dados pela integração com o PROWEB.
				               Criação de nova tela de consulta para os seguros de vida. Projeto 333_1. (Lombardi)

				  27/03/2017 - Adicionado botão "Dossiê DigiDOC". (Projeto 357 - Reinert)	
				  
				  21/11/2017 - Bloquear botões quando vindo da tela de impedimentos (Jonata - RKAM P364).						   							   

				  22/11/2017 - Ajuste para permitir apenas consulta de acordo com a situação da conta (Jonata - RKAM p364).

				  01/12/2017 - Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).

                  18/06/2018 - P450 - Inclusão do Motivo do Cancelamento/dsmotcan (Marcel/AMcom)
                  
				  14/06/2019 - Ajustar botao Dossiê para buscar a imagem correta pois estava buscando do 
				               ambiente de homologação (Lucas Ranghetti INC0016209)
                  24/07/2019 - P519 - Bloqueio de contratacao e cancelamento de seguros CASA/VIDA para coop CIVIA (Darlei / Supero)
 */
?>
<div id="divSeguro" class="divRegistros">
	<table>
		<thead>
			<tr>
				<th>Tipo</th>
                <th>Ap&oacute;lice</th>
                <th><?php echo utf8ToHtml('Início Vig&ecirc;ncia');?></th>
                <th><?php echo utf8ToHtml('Final Vig&ecirc;ncia');?></th>
				<th><?php echo utf8ToHtml('Seguradora');?></th>
				<th><?php echo utf8ToHtml('Situação');?></th>
			</tr>
		</thead>		
		<tbody>
            <?php foreach( $seguros as $seguro ) {
				?>
				<tr>
					<td>
                        <?php echo getByTagName($seguro->tags,'dsTipo'); ?>
						<input type="hidden" value="<? echo $glbvars["cdcooper"] ;?>" name="cdcooper" id="cdcooper">
                        <input type="hidden" id="dsmotcan"   name="dsmotcan"   value="<?php echo getByTagName($seguro->tags,'dsmotcan');   ?>" />
                        <input type="hidden" id="tpseguro"   name="tpseguro"   value="<?php echo getByTagName($seguro->tags,'tpSeguro');   ?>" />
                        <input type="hidden" id="idorigem"   name="idorigem"   value="<?php echo getByTagName($seguro->tags,'idOrigem');   ?>" />
                        <input type="hidden" id="idcontrato" name="idcontrato" value="<?php echo getByTagName($seguro->tags,'idContrato'); ?>" />
                        <input type="hidden" id="nrctrseg"   name="nrctrseg"   value="<?php echo getByTagName($seguro->tags,'nrApolice2'); ?>" />
                        <input type="hidden" id="cdsegura"   name="cdsegura"   value="<?php echo getByTagName($seguro->tags,'cdsegura');   ?>" />
                        <input type="hidden" id="idproposta" name="idproposta" value="<?php echo getByTagName($seguro->tags,'nrApolice2'); ?>" />
                        <input type="hidden" id="dsstatus"   name="dsstatus"   value="<?php echo getByTagName($seguro->tags,'dsSituac'); ?>" />
                        <input type="hidden" id="nmsispar"   name="nmsispar"   value="<?php echo getByTagName($seguro->tags,'nmParceiro'); ?>" />

                        <input type="hidden" id="dsseguro" name="dsseguro" value="<?php echo getByTagName($seguro->tags,'dsTipo'); ?>" />
						<input type="hidden" id="nmdsegur" name="nmdsegur" value="<?php echo getByTagName($seguro->tags,'nmdsegur'); ?>" />
						<input type="hidden" id="tpplaseg" name="tpplaseg" value="<?php echo getByTagName($seguro->tags,'tpplaseg'); ?>" />
						<input type="hidden" id="dtcancel" name="dtcancel" value="<?php echo getByTagName($seguro->tags,'dtcancel'); ?>" />
                        <input type="hidden" id="dtinivig" name="dtinivig" value="<?php echo getByTagName($seguro->tags,'dtIniVigen'); ?>" />
                        <input type="hidden" id="vlpreseg" name="vlpreseg" value="<?php echo getByTagName($seguro->tags,'vlpreseg'); ?>" />
                        <input type="hidden" id="qtpreseg" name="qtpreseg" value="<?php echo getByTagName($seguro->tags,'qtprepag'); ?>" />
						<input type="hidden" id="vlprepag" name="vlprepag" value="<?php echo getByTagName($seguro->tags,'vlprepag'); ?>" />
						<input type="hidden" id="dtdebito" name="dtdebito" value="<?php echo getByTagName($seguro->tags,'dtdebito'); ?>" />
						<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<?php echo getByTagName($seguro->tags,'dtmvtolt'); ?>" />
                        <input type="hidden" id="dtiniseg" name="dtiniseg" value="<?php echo getByTagName($seguro->tags,'dtiniseg'); ?>" />
						<input type="hidden" id="cdsexosg" name="cdsexosg" value="<?php echo getByTagName($seguro->tags,'cdsexosg'); ?>" />
						<input type="hidden" id="qtparcel" name="qtparcel" value="<?php echo getByTagName($seguro->tags,'qtparcel'); ?>" />
                        <input type="hidden" id="cdsitseg" name="cdsitseg" value="<?php echo strtolower(getByTagName($seguro->tags,'dsSituac')) == 'ativo' ? 1 : 0; ?>" />
						
						
                        <input type="hidden" id="nmbenefi_1" name="nmbenefi_1" value="<?php echo getByTagName($seguro->tags,'nmbenvid_1'); ?>" />
                        <input type="hidden" id="nmbenefi_2" name="nmbenefi_2" value="<?php echo getByTagName($seguro->tags,'nmbenvid_2'); ?>" />
                        <input type="hidden" id="nmbenefi_3" name="nmbenefi_3" value="<?php echo getByTagName($seguro->tags,'nmbenvid_3'); ?>" />
                        <input type="hidden" id="nmbenefi_4" name="nmbenefi_4" value="<?php echo getByTagName($seguro->tags,'nmbenvid_4'); ?>" />
                        <input type="hidden" id="nmbenefi_5" name="nmbenefi_5" value="<?php echo getByTagName($seguro->tags,'nmbenvid_5'); ?>" />
						
                        <input type="hidden" id="dsgraupr_1" name="dsgraupr_1" value="<?php echo getByTagName($seguro->tags,'dsgraupr_1'); ?>" />
                        <input type="hidden" id="dsgraupr_2" name="dsgraupr_2" value="<?php echo getByTagName($seguro->tags,'dsgraupr_2'); ?>" />
                        <input type="hidden" id="dsgraupr_3" name="dsgraupr_3" value="<?php echo getByTagName($seguro->tags,'dsgraupr_3'); ?>" />
                        <input type="hidden" id="dsgraupr_4" name="dsgraupr_4" value="<?php echo getByTagName($seguro->tags,'dsgraupr_4'); ?>" />
                        <input type="hidden" id="dsgraupr_5" name="dsgraupr_5" value="<?php echo getByTagName($seguro->tags,'dsgraupr_5'); ?>" />

                        <?php $txpartic1 = getByTagName($seguro->tags,'txpartic_1'); ?>
                        <?php $txpartic2 = getByTagName($seguro->tags,'txpartic_2'); ?>
                        <?php $txpartic3 = getByTagName($seguro->tags,'txpartic_3'); ?>
                        <?php $txpartic4 = getByTagName($seguro->tags,'txpartic_4'); ?>
                        <?php $txpartic5 = getByTagName($seguro->tags,'txpartic_5'); ?>

						<input type="hidden" id="txpartic_1" name="txpartic_1" value="<?php echo $txpartic1; ?>" />						
						<input type="hidden" id="txpartic_2" name="txpartic_2" value="<?php echo $txpartic2; ?>" />
						<input type="hidden" id="txpartic_3" name="txpartic_3" value="<?php echo $txpartic3; ?>" />
						<input type="hidden" id="txpartic_4" name="txpartic_4" value="<?php echo $txpartic4; ?>" />
						<input type="hidden" id="txpartic_5" name="txpartic_5" value="<?php echo $txpartic5; ?>" />
						
					</td>	
                    <td><?php echo getByTagName($seguro->tags,'nrApolice2');?></td>
					<td><?php echo getByTagName($seguro->tags,'dtIniVigen'); ?></td>
					<td><?php echo getByTagName($seguro->tags,'dtFimVigen'); ?></td>
					<td><?php echo getByTagName($seguro->tags,'dsSeguradora'); ?></td>
					<td><?php echo getByTagName($seguro->tags,'dsSituac'); ?></td>
				</tr>
			<?php } ?>
		</tbody>
	</table>
</div>

<div id="divBotoes">

	<?php if (!$executandoImpedimentos){?>

		<?php if(!($sitaucaoDaContaCrm == '4' || 
				   $sitaucaoDaContaCrm == '7' || 
				   $sitaucaoDaContaCrm == '8'  )){?>

			<input type="image" id="btIncluir"   src="<?php echo $UrlImagens; ?>botoes/incluir.gif"   <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'I\');"'; } ?> />
		
		<?}?>

		<input type="image" id="btAlterar"   src="<?php echo $UrlImagens; ?>botoes/alterar.gif"   <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'ALTERAR\');"'; } ?>  />
		<input type="image" id="btConsultar" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'CONSULTAR\');"'; } ?>   />
		<input type="image" id="btCancelar"  src="<?php echo $UrlImagens; ?>botoes/cancelar.gif"  <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'C\');"'; } ?>   />
		<input class="FluxoNavega" id="btndossie" onclick="dossieDigdoc(7);return false;" type="image"  src="<?php echo $UrlImagens; ?>botoes/dossie.gif">
		<input type="image" id="btImprimir"  src="<?php echo $UrlImagens; ?>botoes/imprimir.gif"  <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'IMP\');"'; } ?>  />
	

	<?}else{?>
		
		<input type="image" id="btConsultar" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'CONSULTAR\');"'; } ?>   />
		<input type="image" id="btCancelar"  src="<?php echo $UrlImagens; ?>botoes/cancelar.gif"  <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="controlaOperacao(\'C\');"'; } ?>   />
		<input class="FluxoNavega" id="btndossie" onclick="dossieDigdoc(7);return false;" type="image"  src="<?php echo $UrlImagens; ?>botoes/dossie.gif">
		
	<?}?>
</div>
