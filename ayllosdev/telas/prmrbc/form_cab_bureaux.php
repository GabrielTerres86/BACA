<?
/*!
 * FONTE        : form_cab_bureaux.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2014
 * OBJETIVO     : Mostrar tela PRMRBC
 * --------------
 * ALTERAÇÕES   : 23/03/2016 - Inclusão do campo idenvseg conforme solicitado no 
 *                             chamado 412682. (Kelvin)
 * --------------
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmBureaux" name="frmBureaux" class="formulario" onSubmit="return false;" style="display:none">

	<div id="divBureaux" style="display:none">

		<fieldset>

			<legend>Bureaux</legend>

			<br style="clear:both" />

			<label for="idtpreme"><? echo utf8ToHtml('Bureaux:')?></label>
			<input id="idtpreme" name="idtpreme" type="text" value=""></input>

			<label for="flgativo"><? echo utf8ToHtml('Ativo:')?></label>
			<select id="flgativo" name="flgativo" value="">
				<option value="1"><? echo utf8ToHtml('SIM') ?></option>
				<option value="0"><? echo utf8ToHtml('NAO') ?></option>
			</select>

			<label for="flremseq"><? echo utf8ToHtml('Remessa Sequencial:')?></label>
			<select id="flremseq" name="flremseq" value="">
				<option value="1"><? echo utf8ToHtml('SIM') ?></option>
				<option value="0"><? echo utf8ToHtml('NAO') ?></option>
			</select>

			<label for="idtpsoli"><? echo utf8ToHtml('Tipo Solicita&ccedil;&atilde;o:')?></label>
			<select id="idtpsoli" name="idtpsoli" value="">
				<option value="A"><? echo utf8ToHtml('Autom&aacute;tica')?></option>
				<option value="D"><? echo utf8ToHtml('Sob-Demanda')?></option>
			</select>

			<br style="clear:both" />
			<br style="clear:both" />

			<label for="dsdirenv"><? echo utf8ToHtml('Diret&oacute;rio Arquivos Origem:')?></label>
			<input id="dsdirenv" name="dsdirenv" type="text" value=""></input>

			<br style="clear:both" />

			<label for="dsfnburm"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Busca Remessa:')?></label>
			<input id="dsfnburm" name="dsfnburm" type="text" value=""></input>

			<br style="clear:both" />

			<label for="dsfnchrm"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Chaveamento Remessa:')?></label>
			<input id="dsfnchrm" name="dsfnchrm" type="text" value=""></input>

			<br style="clear:both" />
			<br style="clear:both" />

			<label for="idtpenvi"><? echo utf8ToHtml('Tipo Envio:')?></label>
			<select id="idtpenvi" onChange="exibeCamposEnvio();" name="idtpenvi" value="">
				<option value="F"><? echo utf8ToHtml('FTP') ?></option>
				<option value="C"><? echo utf8ToHtml('CD') ?></option>
			</select>
			
			<label for="idenvseg"><? echo utf8ToHtml('Envio Seguro:')?></label>
			<select id="idenvseg" name="idenvseg" value="">
				<option value="S"><? echo utf8ToHtml('SIM') ?></option>
				<option value="N"><? echo utf8ToHtml('NAO') ?></option>
			</select>
			
			<br style="clear:both" />
			<br style="clear:both" />

			<label for="dsfnrnen"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Renomea&ccedil;&atilde;o Envio:')?></label>
			<input id="dsfnrnen" name="dsfnrnen" type="text" value=""></input>

			<br style="clear:both" />

			<div id="divFtpEnvio" style="display:none">

				<br style="clear:both" />

				<label for="dssitftp"><? echo utf8ToHtml('Site:')?></label>
				<input id="dssitftp" name="dssitftp" type="text" value=""></input>

				<br style="clear:both" />

				<label for="dsusrftp"><? echo utf8ToHtml('Usu&aacute;rio:')?></label>
				<input id="dsusrftp" name="dsusrftp" type="text" value=""></input>

				<label for="dspwdftp"><? echo utf8ToHtml('Senha:')?></label>
				<input id="dspwdftp" name="dspwdftp" type="text" value=""></input>

				<br style="clear:both" />

				<label for="dsdreftp"><? echo utf8ToHtml('Pasta Envio:')?></label>
				<input id="dsdreftp" name="dsdreftp" type="text" value=""></input>

				<br style="clear:both" />

			</div>

			<div id="divCdEnvio" style="display:none">

				<br style="clear:both" />
				<br style="clear:both" />

				<label for="dsdrencd"><? echo utf8ToHtml('Pasta Envia:')?></label>
				<input id="dsdrencd" name="dsdrencd" type="text" value=""></input>

				<br style="clear:both" />

				<label for="dsdrevcd"><? echo utf8ToHtml('Pasta Enviados:')?></label>
				<input id="dsdrevcd" name="dsdrevcd" type="text" value=""></input>

				<br style="clear:both" />

			</div>

			<br style="clear:both" />

			<label for="idopreto"><? echo utf8ToHtml('Retorno:')?></label>
			<select id="idopreto" onChange="exibeCamposRetorno();" name="idopreto" value="">
				<option value="U"><? echo utf8ToHtml('&Uacute;nico') ?></option>
				<option value="M"><? echo utf8ToHtml('P/ cada envio') ?></option>
				<option value="S"><? echo utf8ToHtml('Sem') ?></option>
			</select>

			<div id="divRetornoArq" style="display:none">

				<br style="clear:both" />
				<br style="clear:both" />

				<label for="qthorret"><? echo utf8ToHtml('Qtd Horas p/ Retorno:')?></label>
				<input id="qthorret" name="qthorret" type="text" value=""></input>

				<br style="clear:both" />
                
                <label for="hrinterv"><? echo utf8ToHtml('Intervalo (nro de horas) para re-checagem de retornos com erros:')?></label>
                <input id="hrinterv" name="hrinterv" type="text" value=""></input>

                <br style="clear:both" />

				<label for="dsfnburt"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Busca Retorno:')?></label>
				<input id="dsfnburt" name="dsfnburt" type="text" value=""></input>

				<br style="clear:both" />

				<label for="dsfnchrt"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Valida&ccedil;&atilde;o Retorno:')?></label>
				<input id="dsfnchrt" name="dsfnchrt" type="text" value=""></input>

				<div id="divFtpRetorno" style="display:none">

					<br style="clear:both" />
					<br style="clear:both" />

					<label for="dsdrrftp"><? echo utf8ToHtml('Pasta Retorno:')?></label>
					<input id="dsdrrftp" name="dsdrrftp" type="text" value=""></input>

					<br style="clear:both" />

				</div>

				<div id="divCdRetorno" style="display:none">

					<br style="clear:both" />
					<br style="clear:both" />

					<label for="dsdrrecd"><? echo utf8ToHtml('Pasta Recebe:')?></label>
					<input id="dsdrrecd" name="dsdrrecd" type="text" value=""></input>

					<br style="clear:both" />

					<label for="dsdrrtcd"><? echo utf8ToHtml('Pasta Recebidos:')?></label>
					<input id="dsdrrtcd" name="dsdrrtcd" type="text" value=""></input>

					<br style="clear:both" />

				</div>

				<br style="clear:both" />

				<label for="dsfnrndv"><? echo utf8ToHtml('Fun&ccedil;&atilde;o Renomea&ccedil;&atilde;o Devolu&ccedil;&atilde;o:')?></label>
				<input id="dsfnrndv" name="dsfnrndv" type="text" value=""></input>

				<br style="clear:both" />

				<label for="dsdirret"><? echo utf8ToHtml('Diret&oacute;rio Arquivos Destino:')?></label>
				<input id="dsdirret" name="dsdirret" type="text" value=""></input>

				<br style="clear:both" />

			</div>

			<br style="clear:both" />
			<br style="clear:both" />

		</fieldset>
	</div>

    <br style="clear:both" />
</form>