/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Scripts para gerenciar filtros de personas e categorias, 
* 
*/

	/* 
	*  SIDE BY SIDE
	*  Responsável por controlar itens que são exibidos lado a lado
	*
	*/

	var sbsA 		= '';
	var sbsB 		= '';
	var sbsClicado 	= '';

	// captura o clique de qual elemento quer ver na exibição lado a lado
	$('body').on("click",'.btn-side-by-side', function(){

		// pega qual dos blocos deve ser exibido
		var sbsClicado 		= $(this).attr('persona_categoria');
		var sbsClicadoReal 	= $(this).attr('persona_categoria_real');

		// se o 'comparar' clicado já esta em algum lado da exibição side by side
		if ( (sbsA == sbsClicado) || (sbsB == sbsClicado) ) { 

			// alerta para que o usuário saiba que este bloco já foi selecionado previamente
			alertSelecionado(sbsClicado, sbsClicadoReal);

		// senão, faz a lógica normalmente
		} else {

			// verifica se o espaço para o lado esquerdo esta livre
			if (sbsA.length == '') {

				// se sim, coloca o elemento no lado esquerdo
				sbsDefine('a', sbsClicado, sbsClicadoReal);

			} else {

				// se não, verifica se o elemento do lado direito esta livre
				if (sbsB.length == '') {
					
					// se sim, coloca no lado direito
					sbsDefine('b', sbsClicado, sbsClicadoReal);
					// $('.btn-json').hide();
					$('.btn-xml').hide();

				} else {

					// senão, pergunta pro usuário qual lado ele quer trocar pelo bloco atual
					$('#side-by-side-decide').fadeIn(220);
					$('.btn-decide').attr('persona_categoria',sbsClicado);
					$('.btn-decide').attr('persona_categoria_real',sbsClicadoReal);
				}
			}
		}
	});

	// captura o clique de qual elemento quer ver na exibição lado a lado
	$('body').on("click",'.btn-decide', function(){

		var sbsClicado 		= $(this).attr('persona_categoria');
		var sbsClicadoReal 	= $(this).attr('persona_categoria_real');
		var sbsChoice  		= $(this).attr('choice');

		$('#main-content').hide();
		sbsDefine(sbsChoice,sbsClicado, sbsClicadoReal);

	});

	// captura o clique de qual elemento quer ver na exibição lado a lado
	$('body').on("click",'.btn-sbs-hide', function(){

		$('#main-content').show();
		$('.btn-side-by-side').show();
		$('.btn-sbs-show').show();
		$('#side-by-side').fadeOut(220);
		$('.btn-json').show();
		$('.btn-xml').show();
	});

	// captura o clique de qual elemento quer ver na exibição lado a lado
	$('body').on("click",'.btn-sbs-show', function(){

		$('#main-content').hide();
		$('.btn-side-by-side').hide();
		// $('.btn-json').hide();
		$('.btn-xml').hide();
		$('#side-by-side').fadeIn(220);
	});

	// captura o clique de qual elemento quer ver na exibição lado a lado
	$('body').on("click",'.btn-close-sbs-bottom', function(){

		$('#side-by-side-bottom').hide();
		sbsA = '';
		sbsB = '';
		$('.side-by-side-right').html('<i class="text-gray"><small>Selecione mais uma categoria</small>');
		$('.side-by-side-left').html('<i class="text-gray"><small>Selecione mais uma categoria</small></i>');
		$('#sbsLeftContent').html('');
		$('#sbsRightContent').html('');
		console.log('sbsA: ' + sbsA + ' | sbsB: ' + sbsB);

	});

	// definir qual lado deve-se exibir o bloco
	function sbsDefine(lado, bloco, titulo) {

		var sbsContent = $('.'+bloco).html();

		// verifica qual lado devemos colocar o conteúdo
		if (lado == 'a') {
			
			sbsA = bloco;
			$('.side-by-side-left').html(titulo);
			$('#sbsLeftContent').html(sbsContent);

		} else {

			sbsB = bloco;
			$('.side-by-side-right').html(titulo);
			$('#sbsRightContent').html(sbsContent);
			$('#main-content').hide();
			$('.btn-side-by-side').hide();
		}
	
		$('#main-content').addClass('pb100');

		// se ambos estão preenchidos, pergunta pro usuário o lado que ele quer
		if ((sbsA.length > 0) && (sbsB.length > 0) ) {	
			
			$('.btn-side-by-side').hide();
			$('#side-by-side').fadeIn(220);
			$('.btn-sbs-show').show();
			$('.btn-json').show();
			$('.btn-xml').show();
		}

		// oculta caixa de escolha
		// $('.btn-json').hide();
		$('.btn-xml').hide();
		$('#side-by-side-decide').fadeOut(220);
		$('#side-by-side-bottom').fadeIn(220);
	}

	// FIM SIDE-BY-SIDE

	function startSideBySide(){

		// ocultar exibição lado a lado
		$('#side-by-side').hide();
		$('#side-by-side-decide').hide();
		$('#side-by-side-bottom').hide();
		$('.btn-sbs-show').hide();

		/*
		*	RODAPÉ com visualização das categorias selecionadas
		*
		*	quando já tem duas categorias selecionadas para o Lado a Lado
		*/

		var sbsBottomContent = '';

		sbsBottomContent += '<div class="container-fluid">';
		sbsBottomContent += '<div class="row">';
		sbsBottomContent += '  <div class="col-12 align-self-right text-right pt-1">';
		sbsBottomContent += '    <a href="#" class="btn-close-sbs-bottom"><i class="fas fa-times"></i></a>';
		sbsBottomContent += '  </div>';
		sbsBottomContent += '</div>';
		sbsBottomContent += '<div class="row">';
		sbsBottomContent += '  <div class="col-md-5 align-self-center text-center side-by-side-left"><i class="text-gray"><small>Selecione mais uma categoria</small></i>';
		sbsBottomContent += '  </div>';
		sbsBottomContent += '  <div class="col-md-2 align-self-center text-center">';
		sbsBottomContent += '	<button class="btn btn-sbs-show" choice="a">Exibir &nbsp; <i class="fas fa-angle-up"></i></button>';
		sbsBottomContent += '  </div>';
		sbsBottomContent += '  <div class="col-md-5 align-self-center text-center side-by-side-right"><i class="text-gray"><small>Selecione mais uma categoria</small></i>';
		sbsBottomContent += '  </div>';
		sbsBottomContent += '</div>';
		sbsBottomContent += '</div>';

		$('#side-by-side-bottom').html(sbsBottomContent);

		/*
		*	BLOCO de decisão
		*
		*	quando já tem duas categorias selecionadas para o Lado a Lado
		*/

		var sbsDecide = '';

		sbsDecide += '<div class="row">';
		sbsDecide += '	<div class="col-md-12 align-self-center text-center">';
		sbsDecide += '		<h3>Em qual lado você quer ver?</h3>';
		sbsDecide += '	</div>';
		sbsDecide += '	<div class="col-md-4 align-self-center text-center">';
		sbsDecide += '		<p>Substituir</p> <p class="side-by-side-left"></p>';
		sbsDecide += '		<button class="btn btn-decide" choice="a" persona_categoria_real="" persona_categoria=""><i class="fas fa-angle-left"></i></button>';
		sbsDecide += '	</div>';
		sbsDecide += '	<div class="col-md-4 align-self-center text-center">&nbsp;</div>';
		sbsDecide += '	<div class="col-md-4 align-self-center text-center">';
		sbsDecide += '		<p>Substituir</p> <p class="side-by-side-right"></p>';
		sbsDecide += '		<button class="btn btn-decide" choice="b" persona_categoria_real="" persona_categoria=""><i class="fas fa-angle-right"></i></button>';
		sbsDecide += '	</div>';
		sbsDecide += '</div>';

		/*
		*	BLOCO lado a lado
		*
		*/

		$('#side-by-side-decide').html(sbsDecide);

		var sbs = '';

		sbs += '<div class="row">';
		sbs += '	<div class="col text-center">';
		sbs += '		<button class="btn btn-sbs-hide" choice="a">Ocultar &nbsp; <i class="fas fa-angle-down"></i></button>';
		sbs += '	</div>';
		sbs += '</div>';
		sbs += '<div class="row">';
		sbs += '	<div class="col grid-margin grid-scroll" style="max-width: 49% !important;">';
		sbs += '        <div class="d-flex" id="sbsLeftContent">';
		sbs += '			<small>Nenhum bloco selecionado</small>';
		sbs += '      	</div>';
		sbs += '    </div>';
		sbs += '	<div class="col grid-margin grid-scroll" style="max-width: 49% !important;">';
		sbs += '        <div class="d-flex" id="sbsRightContent">';
		sbs += '			<small>Nenhum bloco selecionado</small>';
		sbs += '        </div>';
		sbs += '    </div>';
		sbs += '</div>';

		$('#side-by-side').html(sbs);

	}

	/*
	* Botão para fechar o alerta que avisa quando a categoria do side by side já está selecionada
	*/

	$('body').on("click",'.close-alert-selecionado', function(){
		alertSelecionadoOut();
	});

