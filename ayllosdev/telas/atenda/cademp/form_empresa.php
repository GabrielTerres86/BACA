<?php
/*!
 * FONTE        : form_empresa.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 13/11/2013
 * OBJETIVO     : formulario para a tela CADEMP
 * --------------
 * ALTERAÇÕES   : 28/03/2014 - Retirado o caracter "." do label UF. Retirada de espaço em "Mê s" (Carlos)
 *
 *                11/06/2014 - Adicionado acentuação "Codigo da Empresa Sistema Folha" (Douglas - Chamado 122814)
 *
 *                17/05/2016 - Movido o campo Dia Fechamento Folha da segunda aba para a ultima aba.
 *                             Remocao do campo Gera Aviso Poup.Prog. Criacao do campo Dia Limite Debitos Vinculados. 
 *                             (Jaison/Marcos)
 *
 *				  28/07/2016 - Removi o comando session_start e a função utf8tohtml desnecessarios. SD 491925. (Carlos R.)
 *
 * --------------
 */
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	require_once('valida_feriado.php');
	isPostMethod();
?>

<script>
glb_dtmvtolt = '<?php echo $glbvars['dtmvtolt']; ?>';
</script>

<div id="divEmpresa" name="divEmpresa">
	<form id="frmInfEmpresa" name="frmInfEmpresa" class="formulario" onSubmit="return false;" style="display:block"> <!-- ALTERAR PARA NONE -->

		<fieldset>

			<legend>Dados da Empresa</legend>

			<label for="cdempres">C&oacute;digo:</label>
			<input name="cdempres" type="text"  id="cdempres" class='campo' />
			<a id="pesqempr" name="pesqempr" href="#" onClick="mostraPesquisaEmpresa('cddopcao','frmPesquisaEmpresa','');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>

			<label for="idtpempr">Tipo Empresa:</label>
			<select name="idtpempr" id="idtpempr" class="campo">
				<option value="O" >Outras</option>
				<option value="C" >Cooperativa</option>				
			</select>
			
			<br style="clear:both" />

			<label for="nmextemp">Raz&atilde;o Social:</label>
			<input name="nmextemp" type="text"  id="nmextemp" class='campo' />

			<br style="clear:both" />

			<label for="nmresemp">Nome&nbsp;Fantasia:</label>
			<input name="nmresemp" type="text"  id="nmresemp" class='campo' />

			<br style="clear:both" />
			<br style="clear:both" />

			<label for="nrdconta">Conta D&eacute;bito:</label>
			<input name="nrdconta" type="text"  id="nrdconta" class='campo' />
			<a href="#" onClick="mostraContaEmp();return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
			<input name="nmextttl" type="text"  id="nmextttl" class='campo' />

			<br style="clear:both" />
			<br style="clear:both" />

			<label for="nmcontat">Contato:</label>
			<input name="nmcontat" type="text"  id="nmcontat" class='campo' />

			<br style="clear:both" />

			<label for="nrdocnpj">CNPJ:</label>
			<input name="nrdocnpj" type="text"  id="nrdocnpj" class='campo' />

			<br style="clear:both" />

			<label for="dsendemp">Endere&ccedil;o:</label>
			<input name="dsendemp" type="text"  id="dsendemp" class='campo' />

			<label for="nrendemp">N&uacute;mero:</label>
			<input name="nrendemp" type="text"  id="nrendemp" class='campo'/>

			<br style="clear:both" />

			<label for="dscomple">Complemento:</label>
			<input name="dscomple" type="text"  id="dscomple" class='campo' />

			<br style="clear:both" />

			<label for="nmbairro">Bairro:</label>
			<input name="nmbairro" type="text"  id="nmbairro" class='campo' />

			<label for="nmcidade">Cidade:</label>
			<input name="nmcidade" type="text"  id="nmcidade" class='campo' />

			<br style="clear:both" />

			<label for="cdufdemp">UF:</label>
			<input name="cdufdemp" type="text"  id="cdufdemp" class='campo' />

			<label for="nrcepend">CEP:</label>
			<input name="nrcepend" type="text"  id="nrcepend" class='campo' />

			<br style="clear:both" />

			<label for="nrfonemp">Telefone:</label>
			<input name="nrfonemp" type="text"  id="nrfonemp" class='campo' />

			<label for="nrfaxemp">Fax:</label>
			<input name="nrfaxemp" type="text"  id="nrfaxemp" class='campo' />

			<br style="clear:both" />

			<label for="dsdemail">E-mail:</label>
			<input name="dsdemail" type="text"  id="dsdemail" class='campo' />

			<!-- CAMPOS PARA LOG -->
			<input type='hidden' name='old_nmextemp' id='old_nmextemp'>
			<input type='hidden' name='old_nmresemp' id='old_nmresemp'>
			<input type='hidden' name='old_idtpempr' id='old_idtpempr'>			
			<input type='hidden' name='old_nrdconta' id='old_nrdconta'>
			<input type='hidden' name='old_nmextttl' id='old_nmextttl'>
			<input type='hidden' name='old_nmcontat' id='old_nmcontat'>
			<input type='hidden' name='old_dsendemp' id='old_dsendemp'>
			<input type='hidden' name='old_nrendemp' id='old_nrendemp'>
			<input type='hidden' name='old_dscomple' id='old_dscomple'>
			<input type='hidden' name='old_nmbairro' id='old_nmbairro'>
			<input type='hidden' name='old_nmcidade' id='old_nmcidade'>
			<input type='hidden' name='old_cdufdemp' id='old_cdufdemp'>
			<input type='hidden' name='old_nrcepend' id='old_nrcepend'>
			<input type='hidden' name='old_nrdocnpj' id='old_nrdocnpj'>
			<input type='hidden' name='old_nrfonemp' id='old_nrfonemp'>
			<input type='hidden' name='old_nrfaxemp' id='old_nrfaxemp'>
			<input type='hidden' name='old_dsdemail' id='old_dsdemail'>
			<!-- CAMPOS PARA LOG -->

			<br style="clear:both" />

		</fieldset>
	</form>

	<form id="frmInfTarifa" name="frmInfTarifa" class="formulario" onSubmit="return false;" style="display:none"> <!-- ALTERAR PARA NONE -->

		<fieldset>
			<legend>Folha E-mail</legend>
			
				<label for="flgpagto">Integra Folha:</label>
				<input type="checkbox" id = "flgpagto" name="flgpagto"/>
				
				<br style="clear:both" />
				<br style="clear:both" />
				
				<label for="cdempfol">C&oacute;digo da Empresa Sistema Folha:</label>
				<input name="cdempfol" type="text"  id="cdempfol" class='campo' />
			
			    <br style="clear:both" />

				<label for="vltrfsal">Tarifa para Cr&eacute;dito de Sal&aacute;rios:</label>
				<input name="vltrfsal" type="text"  id="vltrfsal" class='campo'/>
				
				<br style="clear:both" />
				<br style="clear:both" />

				<label for="ddpgtmes">Dia do Pagamento de Mensalista:</label>
				<input name="ddpgtmes" type="text"  id="ddpgtmes" class='campo' />

				<br style="clear:both" />

				<label for="ddpgthor">Dia do Pagamento de Horista:</label>
				<input name="ddpgthor" type="text"  id="ddpgthor" class='campo' />

				
				<!-- CAMPOS PARA LOG -->
				<input type='hidden' name='old_flgpagto' id='old_flgpagto'>
				<input type='hidden' name='old_cdempfol' id='old_cdempfol'>
				<input type='hidden' name='old_vltrfsal' id='old_vltrfsal'>
				<input type='hidden' name='old_ddpgtmes' id='old_ddpgtmes'>
				<input type='hidden' name='old_ddpgthor' id='old_ddpgthor'>
				<!-- CAMPOS PARA LOG -->

		</fieldset>
	</form>

	<form id="frmInfIb" name="frmInfIb" class="formulario" onSubmit="return false;" style="display:none"> <!-- ALTERAR PARA NONE -->
		<fieldset>
			<legend>Folha Internet Banking</legend>

			<label for="flgpgtib">Libera&ccedil;&atilde;o Folha IB?:</label>
			<input type="checkbox" id = "flgpgtib" name="flgpgtib"/>

			<br style="clear:both" />
			<br style="clear:both" />
			
			<label for="cdcontar">Conv&ecirc;nio Tarif&aacute;rio:</label>
			<input name="cdcontar" type="text"  id="cdcontar" class='campo' onBlur="mostrarTela();return false;"" />
			
			<a href="#" onClick="mostrarTela();return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
			<input name="dscontar" type="text"  id="dscontar" class='campo' disabled />

			<br style="clear:both" />
			
			<label for="vllimfol">Valor Limite Di&aacute;rio:</label>
			<input name="vllimfol" type="text"  id="vllimfol" class='campo'/>

			<!-- CAMPOS PARA LOG -->
			<input type='hidden' name='dtultufp' 	 id='dtultufp' value="">
			<input type='hidden' name='old_flgpgtib' id='old_flgpgtib'>
			<input type='hidden' name='old_cdcontar' id='old_cdcontar'>
			<input type='hidden' name='old_vllimfol' id='old_vllimfol'>			
			<!-- CAMPOS PARA LOG -->
		</fieldset>
	</form>

	<form id="frmInfEmprestimo" name="frmInfEmprestimo" class="formulario" onSubmit="return false;" style="display:none"> <!-- ALTERAR PARA NONE -->

		<fieldset>
			<legend>Informacoes Complementares</legend>

				<label for="indescsg">Empr&eacute;stimo Consignado:</label>
				<input type="checkbox" id = "indescsg" name="indescsg" style="margin-right:10px;"/>

				<label for="dtfchfol">Dia Fechamento Folha:</label>
				<input name="dtfchfol" type="text"  id="dtfchfol" class='campo' />

				<br style="clear:both" />
				
				<label for="flgarqrt">Gera arq. retorno:</label>
				<input type="checkbox" id = "flgarqrt" name="flgarqrt"/>

				<br style="clear:both" />
				
				<label for="flgvlddv">Valida DV Cad.Emp:</label>
				<input type="checkbox" id = "flgvlddv"  name="flgvlddv"/>
				
				<br style="clear:both" />
				<br style="clear:both" />
				
				<label for="ddmesnov">Dia M&ecirc;s Novo para Empr&eacute;stimo:</label>
				<input name="ddmesnov" type="text"  id="ddmesnov" class='campo' />

				<label for="dtlimdeb">Dia Limite D&eacute;bitos Vinculados:</label>
				<input name="dtlimdeb" type="text"  id="dtlimdeb" class='campo' />
				
				<br style="clear:both" />
				<br style="clear:both" />

				<label for="nrlotcot">Lote Cotas:</label>
				<input name=" nrlotcot" type="text"  id="nrlotcot" class='campo' />

				<label for="nrlotemp">Lote Empr&eacute;stimo:</label>
				<input name="nrlotemp" type="text"  id="nrlotemp" class='campo' />

				<label for="nrlotfol">Lote Folha:</label>
				<input name="nrlotfol" type="text"  id="nrlotfol" class='campo' />

				<br style="clear:both" />
				<br style="clear:both" />

				<label for="tpconven">Impress&atilde;o do Aviso:</label>
				<select name="tpconven" id="tpconven" class="campo">
					<option value="1" >3/5 DIAS &Uacute; TEIS ANTES DO FIM DO MES</option>
					<option value="2" >1.o. DIA &Uacute;TIL DO M&Ecirc;S</option>
				</select>

				<br style="clear:both" />

				<label for="tpdebemp">Gera Aviso Empr&eacute;stimo:</label>
				<select name="tpdebemp" id="tpdebemp" class="campo" >
					<option value="1" selected>N&Atilde;O DEBITA</option>
					<option value="2">5 DIAS ANTES</option>
					<option value="3">3 DIAS ANTES</option>
				</select>
				<label for="dtavsemp">Data Gera&ccedil;&atilde;o:</label>
				<input name="dtavsemp" type="text"  id="dtavsemp" class='campo'/>

				<br style="clear:both" />

				<label for="tpdebcot">Gera Aviso Cotas:</label>
				<select name="tpdebcot" id="tpdebcot" class="campo">
					<option value="1" selected>N&Atilde;O DEBITA</option>
					<option value="2">5 DIAS ANTES</option>
					<option value="3">3 DIAS ANTES</option>
				</select>
				<label for="dtavscot">Data Gera&ccedil;&atilde;o:</label>
				<input name="dtavscot" type="text"  id="dtavscot" class='campo' />

				<!-- CAMPOS LOG -->
				<?php
					$cdcooper = ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : '';
					$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
					$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
					$nrdcaixa = ( isset($glbvars["nrdcaixa"]) ) ? $glbvars["nrdcaixa"] : '';
					$cdoperad = ( isset($glbvars["cdoperad"]) ) ? $glbvars["cdoperad"] : '';
					$dtmvtolt = ( isset($glbvars["dtmvtolt"]) ) ? $glbvars["dtmvtolt"] : '';
					$idorigem = ( isset($glbvars["idorigem"]) ) ? $glbvars["idorigem"] : '';
					$nmdatela = ( isset($glbvars["nmdatela"]) ) ? $glbvars["nmdatela"] : '';
					$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';
					$nmdbusca = ( isset($glbvars["nmdbusca"]) ) ? $glbvars["nmdbusca"] : '';
					$cdpesqui = ( isset($glbvars["cdpesqui"]) ) ? $glbvars["cdpesqui"] : '';
					
					$arrayParam = array('cdcooper' => $cdcooper,
					    				'cdagenci' => $cdagenci,
										'cdagenci' => $cdagenci,
										'nrdcaixa' => $nrdcaixa,
										'cdoperad' => $cdoperad,
										'dtmvtolt' => $dtmvtolt,
										'idorigem' => $idorigem,
										'nmdatela' => $nmdatela,
										'cdprogra' => $cdprogra,
										'nmdbusca' => $nmdbusca,
										'cdpesqui' => $cdpesqui);
                                        
                    list($dia, $mes, $ano) = explode('/',$glbvars['dtmvtolt']);
                    $dtproxmes = date('d/m/Y',strtotime("+1 months",mktime(0,0,0,$mes,$dia = 1,$ano)));
				?>
				<input type='hidden' name='old_indescsg' id='old_indescsg'>
				<input type='hidden' name='old_dtfchfol' id='old_dtfchfol'>
				<input type='hidden' name='old_flgarqrt' id='old_flgarqrt'>
				<input type='hidden' name='old_flgvlddv' id='old_flgvlddv'>
				<input type='hidden' name='old_ddmesnov' id='old_ddmesnov'>
                <input type='hidden' name='old_dtlimdeb' id='old_dtlimdeb'>
				<input type='hidden' name='old_tpconven' id='old_tpconven'>
				<input type='hidden' name='old_nrlotcot' id='old_nrlotcot'>
				<input type='hidden' name='old_nrlotemp' id='old_nrlotemp'>
				<input type='hidden' name='old_nrlotfol' id='old_nrlotfol'>
				<input type='hidden' name='old_tpdebemp' id='old_tpdebemp'>
				<input type='hidden' name='old_dtavsemp' id='old_dtavsemp'>				
				<input type='hidden' name='old_tpdebcot' id='old_tpdebcot'>
				<input type='hidden' name='old_dtavscot' id='old_dtavscot'>
				<input type='hidden'  id='data-2' value='<?php echo trim(valida_feriado($glbvars['dtmvtolt'],5, $arrayParam)); ?>'>
				<input type='hidden'  id='data-3' value='<?php echo trim(valida_feriado($glbvars['dtmvtolt'],3, $arrayParam)); ?>'>
                <input type='hidden'  id='data-proxmes-2' value='<?php echo trim(valida_feriado($dtproxmes,5, $arrayParam)); ?>'>
				<input type='hidden'  id='data-proxmes-3' value='<?php echo trim(valida_feriado($dtproxmes,3, $arrayParam)); ?>'>
				<!-- CAMPOS LOG -->
			</fieldset>
	</form>
</div>
