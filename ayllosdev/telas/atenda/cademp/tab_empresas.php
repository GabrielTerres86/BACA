<?php
/*!
 * FONTE        : tab_empresas.php
 * CRIAÇÃO      : Michel Candido - (Gati Tecnologia)
 * DATA CRIAÇÃO : 21/08/2013
 * OBJETIVO     : Tabela que apresenta as empresas
 * --------------
 * ALTERAÇÕES   : 19/01/2015 - Tratar valor do dtfchfol para formatar com dois dígitos (Andre Santos - SUPERO)
 *
 *                17/05/2016 - Correcao para exibicao do campo dtfchfol. Remocao do campo tpdebppr e dtavsppr.
 *                             Inclusao do campo dtlimdeb. (Jaison/Marcos)
 *
 *				  28/07/2016 - Removio comando session_start e tratei acentuacao da tabela. SD 491925 (Carlos R.)
 */
// Includes para variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");
isPostMethod();	
?>
<div id="divTabEmpresas">
	<div class="divRegistros">	
		<table >
			<thead>
				<tr>
					<th>C&oacute;digo</th>
					<th>Empresa</th>
					<th>Raz&atilde;o Social</th>
				</tr>
			</thead>
			<tbody>
			<?php $i = 0;foreach($registros as $r){?>
				<tr>
					<td>
						<span><?php echo getByTagName($r->tags,'cdempres');?></span>
						<?php echo getByTagName($r->tags,'cdempres');?>
						<!-- CAMPOS COM OS DADOS PARA POPULAR OS FORMULARIOS CONFORME A EMPRESA ESCOLHIDA -->
						<input type="hidden" id="hinavscot" name="inavscot" value="<?php echo getByTagName($r->tags,'inavscot');?>" />
						<input type="hidden" id="hinavsemp" name="inavsemp" value="<?php echo getByTagName($r->tags,'inavsemp');?>" />
						<input type="hidden" id="hinavsppr" name="inavsppr" value="<?php echo getByTagName($r->tags,'inavsppr');?>" />
						<input type="hidden" id="hinavsden" name="inavsden" value="<?php echo getByTagName($r->tags,'inavsden');?>" />
						<input type="hidden" id="hinavsseg" name="inavsseg" value="<?php echo getByTagName($r->tags,'inavsseg');?>" />
						<input type="hidden" id="hinavssau" name="inavssau" value="<?php echo getByTagName($r->tags,'inavssau');?>" />
						<input type="hidden" id="hcdempres" name="cdempres" value="<?php echo getByTagName($r->tags,'cdempres');?>" />
						<input type="hidden" id="hnmresemp" name="nmresemp" value="<?php echo getByTagName($r->tags,'nmresemp');?>" />
						<input type="hidden" id="hidtpempr" name="idtpempr" value="<?php echo getByTagName($r->tags,'idtpempr');?>" />
						<input type="hidden" id="hnrdconta" name="nrdconta" value="<?php echo getByTagName($r->tags,'nrdconta');?>" />
						<input type="hidden" id="hnmextttl" name="nmextttl" value="<?php echo getByTagName($r->tags,'nmextttl');?>" />
						<input type="hidden" id="hnmcontat" name="nmcontat" value="<?php echo getByTagName($r->tags,'nmcontat');?>" />
						<input type="hidden" id="hnmextemp" name="nmextemp" value="<?php echo getByTagName($r->tags,'nmextemp');?>" />
						<input type="hidden" id="hcdcooper" name="cdcooper" value="<?php echo getByTagName($r->tags,'cdcooper');?>" />
						<input type="hidden" id="htpdebemp" name="tpdebemp" value="<?php echo getByTagName($r->tags,'tpdebemp');?>" />
						<input type="hidden" id="htpdebcot" name="tpdebcot" value="<?php echo getByTagName($r->tags,'tpdebcot');?>" />
						<input type="hidden" id="hcdempfol" name="cdempfol" value="<?php echo getByTagName($r->tags,'cdempfol');?>" />
						<input type="hidden" id="hdtavscot" name="dtavscot" value="<?php echo getByTagName($r->tags,'dtavscot');?>" />
						<input type="hidden" id="hdtavsemp" name="dtavsemp" value="<?php echo getByTagName($r->tags,'dtavsemp');?>" />
						<input type="hidden" id="hflgpagto" name="flgpagto" value="<?php echo getByTagName($r->tags,'flgpagto');?>" />
						<input type="hidden" id="htpconven" name="tpconven" value="<?php echo getByTagName($r->tags,'tpconven');?>" />
						<input type="hidden" id="hcdufdemp" name="cdufdemp" value="<?php echo getByTagName($r->tags,'cdufdemp');?>" />
						<input type="hidden" id="hdscomple" name="dscomple" value="<?php echo getByTagName($r->tags,'dscomple');?>" />
						<input type="hidden" id="hdsdemail" name="dsdemail" value="<?php echo getByTagName($r->tags,'dsdemail');?>" />
						<input type="hidden" id="hdsendemp" name="dsendemp" value="<?php echo getByTagName($r->tags,'dsendemp');?>" />
						<input type="hidden" id="hdtfchfol" name="dtfchfol" value="<?php echo str_pad(getByTagName($r->tags,'dtfchfol'), 2, 0, STR_PAD_LEFT);?>" />
						<input type="hidden" id="hindescsg" name="indescsg" value="<?php echo getByTagName($r->tags,'indescsg');?>" />
						<input type="hidden" id="hnmbairro" name="nmbairro" value="<?php echo getByTagName($r->tags,'nmbairro');?>" />
						<input type="hidden" id="hnmcidade" name="nmcidade" value="<?php echo getByTagName($r->tags,'nmcidade');?>" />
						<input type="hidden" id="hnrcepend" name="nrcepend" value="<?php echo formataCep(getByTagName($r->tags,'nrcepend')); ?>" />
						<input type="hidden" id="hnrdocnpj" name="nrdocnpj" value="<?php echo formatar(getByTagName($r->tags,'nrdocnpj'), 'cnpj'); ?>" />
						<input type="hidden" id="hnrendemp" name="nrendemp" value="<?php echo getByTagName($r->tags,'nrendemp');?>" />
						<input type="hidden" id="hnrfaxemp" name="nrfaxemp" value="<?php echo getByTagName($r->tags,'nrfaxemp');?>" />
						<input type="hidden" id="hnrfonemp" name="nrfonemp" value="<?php echo getByTagName($r->tags,'nrfonemp');?>" />
						<input type="hidden" id="hflgarqrt" name="flgarqrt" value="<?php echo getByTagName($r->tags,'flgarqrt');?>" />
						<input type="hidden" id="hflgvlddv" name="flgvlddv" value="<?php echo getByTagName($r->tags,'flgvlddv');?>" />
						<input type="hidden" id="hflgpgtib" name="flgpgtib" value="<?php echo getByTagName($r->tags,'flgpgtib');?>" />
						<input type="hidden" id="hcdcontar" name="cdcontar" value="<?php echo getByTagName($r->tags,'cdcontar');?>" />
						<input type="hidden" id="hdscontar" name="dscontar" value="<?php echo getByTagName($r->tags,'dscontar');?>" />
						<input type="hidden" id="hvllimfol" name="vllimfol" value="<?php echo formataMoeda(getByTagName($r->tags,'vllimfol')); ?>" />
						<input type="hidden" id="hdtultufp" name="dtultufp" value="<?php echo getByTagName($r->tags,'dtultufp');?>" />
                        <input type="hidden" id="hdtlimdeb" name="dtlimdeb" value="<?php echo getByTagName($r->tags,'dtlimdeb');?>" />
						<!-- CAMPOS COM OS DADOS PARA POPULAR OS FORMULARIOS CONFORME A EMPRESA ESCOLHIDA -->
					</td>
					<td>
						<span><?php echo getByTagName($r->tags,'nmresemp');?></span>
						<?php echo getByTagName($r->tags,'nmresemp');?>
					</td>
					<td>
						<span><?php echo getByTagName($r->tags,'nmextemp');?></span>
						<?php echo getByTagName($r->tags,'nmextemp');?>
					</td>
				</tr>
			<?php }?>
			</tbody>
		</table>
	</div>	
</div>