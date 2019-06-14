<?php
/*!
 * FONTE        : tab_empresas.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 06/2015
 * OBJETIVO     : Tabela que apresenta as empresas
 * --------------
	 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.) 
 */	

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
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
						<input type="hidden" id="hnmextemp" name="nmextemp" value="<?php echo getByTagName($r->tags,'nmextemp');?>" />
						<input type="hidden" id="hcdcooper" name="cdcooper" value="<?php echo getByTagName($r->tags,'cdcooper');?>" />
						<input type="hidden" id="htpdebemp" name="tpdebemp" value="<?php echo getByTagName($r->tags,'tpdebemp');?>" />
						<input type="hidden" id="htpdebcot" name="tpdebcot" value="<?php echo getByTagName($r->tags,'tpdebcot');?>" />
						<input type="hidden" id="htpdebppr" name="tpdebppr" value="<?php echo getByTagName($r->tags,'tpdebppr');?>" />
						<input type="hidden" id="hcdempfol" name="cdempfol" value="<?php echo getByTagName($r->tags,'cdempfol');?>" />
						<input type="hidden" id="hdtavscot" name="dtavscot" value="<?php echo getByTagName($r->tags,'dtavscot');?>" />
						<input type="hidden" id="hdtavsemp" name="dtavsemp" value="<?php echo getByTagName($r->tags,'dtavsemp');?>" />
						<input type="hidden" id="hdtavsppr" name="dtavsppr" value="<?php echo getByTagName($r->tags,'dtavsppr');?>" />
						<input type="hidden" id="hflgpagto" name="flgpagto" value="<?php echo getByTagName($r->tags,'flgpagto');?>" />
						<input type="hidden" id="htpconven" name="tpconven" value="<?php echo getByTagName($r->tags,'tpconven');?>" />
						<input type="hidden" id="hcdufdemp" name="cdufdemp" value="<?php echo getByTagName($r->tags,'cdufdemp');?>" />
						<input type="hidden" id="hdscomple" name="dscomple" value="<?php echo getByTagName($r->tags,'dscomple');?>" />
						<input type="hidden" id="hdsdemail" name="dsdemail" value="<?php echo getByTagName($r->tags,'dsdemail');?>" />
						<input type="hidden" id="hdsendemp" name="dsendemp" value="<?php echo getByTagName($r->tags,'dsendemp');?>" />
						<input type="hidden" id="hdtfchfol" name="dtfchfol" value="<?php echo str_pad(getByTagName($r->tags,'dtfchfol'),2,'0',str_pad_left);?>" />
						<input type="hidden" id="hindescsg" name="indescsg" value="<?php echo getByTagName($r->tags,'indescsg');?>" />
						<input type="hidden" id="hnmbairro" name="nmbairro" value="<?php echo getByTagName($r->tags,'nmbairro');?>" />
						<input type="hidden" id="hnmcidade" name="nmcidade" value="<?php echo getByTagName($r->tags,'nmcidade');?>" />
						<input type="hidden" id="hnrcepend" name="nrcepend" value="<?php echo formataCep(getByTagName($r->tags,'nrcepend'));?>" />
						<input type="hidden" id="hnrdocnpj" name="nrdocnpj" value="<?php echo formatar(getByTagName($r->tags,'nrdocnpj'), 'cnpj');?>" />
						<input type="hidden" id="hnrendemp" name="nrendemp" value="<?php echo mascara(getByTagName($r->tags,'nrendemp'), "###.###");?>" />
						<input type="hidden" id="hnrfaxemp" name="nrfaxemp" value="<?php echo getByTagName($r->tags,'nrfaxemp');?>" />
						<input type="hidden" id="hnrfonemp" name="nrfonemp" value="<?php echo getByTagName($r->tags,'nrfonemp');?>" />
						<input type="hidden" id="hflgarqrt" name="flgarqrt" value="<?php echo getByTagName($r->tags,'flgarqrt');?>" />
						<input type="hidden" id="hflgvlddv" name="flgvlddv" value="<?php echo getByTagName($r->tags,'flgvlddv');?>" />						
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
