/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Scripts para gerenciar filtros de personas e categorias,
*/

$(document).ready(function(){

	// todas as personas e todas as categorias
	var persona  			= [];
	var categoria 			= [];
	var boxes	 			= [];
	var reativaItem 		= '';
	var persona_categoria 	= '';
	var titulo 				= '';
	var conteudo 			= '';
	var html				= '';

	/* 
	*  carrega dados do XML
	*/

	$.ajax({

	    type: 				'POST',
	    url: 				'getXML.php',
	    dataType: 			'json',
	    data: { 
	    	requisicao : 	'pegarXML' 
	    },

	    success: function(response) {

            if(typeof response.error === "boolean"){
                var msg = new Array();
                msg['responseText'] = response.message;
                showLoadingError(msg);
                return false;
            }

	    	// html de dados
			blocos 			= response['blocos'];				// blocos HTML com dados
			// gera_pdf 		= response['gera_pdf'];				// blocos HTML com dados - para gerar PDF

			// personas
			persona 		= response['persona'];				// todas as personas encontradas no XML para filtro (slug)
			persona_tela 	= response['persona_tela'];			// todas as personas encontradas no XML para tela   (texto)

			// categorias
			categoria_todos = response['categoria'];			// todas as categorias encontradas no XML 				(backup p/ restaurar qdo clica no botão "todas as categorias")
			categoria 		= response['categoria'];			// todas as categorias encontradas no XML para filtro 	(slug)
			categoria_filtro= response['categoria_filtro'];		// todas as categorias encontradas no XML para tela   	(html)

			// DESATIVAR em prod
			persona.reverse();
			persona_tela.reverse();

			// var para colocar HTML gerado para filtro de persona
			html_persona 	= '';	// html personas
			html_avalista 	= '';	// html sub persona avalista
			html_grupo 		= '';	// html sub persona grupo econômico
			html_quadro		= '';	// html sub persona quadro societário
			html_contapj	= '';	// html sub persona de contas PJ

			// quantidade de personas múltiplas
			qtd_persona_avalista 	= 0;
			qtd_persona_grupo		= 0;
			qtd_persona_quadro 		= 0;
			qtd_persona_contapj 	= 0;

			/*
			*
			*	DIVIDE PERSONAS
			* 	personas que tem mais de uma "pessoa" deve ir para um submenu e ser tratada de forma difetente
			*	o XML vai fornecer uma tag chamada personaFiltro. Caso existe o caracter de underline siginifica que tem mais de uma persona
			*	exemplo de persona única: proponente, conjuge
			* 	exemplo de persina múltipla: avalista_1, avalista_2
			*
			*/

			// vetores para renderizar personas na tela
			persona_unique  = [];	// para personas únicas
			persona_multi   = [];	// para personas duplicada (ex: avalista 1 e avalista 2)

			for (var i = persona.length - 1; i >= 0; i--) {

				// UNIQUE - todas as personas que não tem _ na tag personaFiltro são personas únicas

				if(persona[i].search("_") === -1) {

					// insere no vetor
					persona_unique.push(persona[i]);

					// monta bloco html do filtro principal
					html_persona += '<li class="nav-item"><a class="nav-link filtro" filtro="persona" ativo="nao" tipo="'+persona[i]+'"><i class="menu-icon far fa-circle check-personas check-'+persona[i]+'"></i>'+persona_tela[i]+'</a></li>';

				// MULTIPLO - todas as personas que tem _ na tag personaFiltro são personas múltiplas e devem ser tratadas diferente

				} else {

					// insere no vetor
					persona_multi.push(persona[i]);

					// avalista
					if (persona[i].search("avalista_") >= 0) {

						// atualiza quantidade de personas avalista
						qtd_persona_avalista++;

						// monta bloco html do filtro secundário
						html_avalista += '<div class="dib"><a class="filtro nav-link-sub word-break-yeah" filtro="persona" ativo="nao" tipo="'+persona[i]+'"><i class="far fa-circle check-avalista check-'+persona[i]+'"></i>'+persona_tela[i]+'</a></div>';
					
						// quando estiver no primeiro registro de avalista, inserir um item de toggle no menu principal
						if (persona[i] == 'avalista_1') {
							// monta bloco html do filtro principal
							html_persona += '<li class="nav-item"><a class="menu-toggle nav-link" tipo="avalista"><i class="menu-icon far fa-circle check-avalista"></i>Avalistas<a></li>';
						}	
					
					// grupo econômico
					} else if (persona[i].search("grupo_") >= 0) {
					
						// atualiza quantidade de personas grupo
						qtd_persona_grupo++;

						// monta bloco html do filtro secundário
						html_grupo += '<div class="dib"><a class="filtro nav-link-sub word-break-yeah" filtro="persona" ativo="nao" tipo="'+persona[i]+'"><i class="far fa-circle check-grupo check-'+persona[i]+'"></i>'+persona_tela[i]+'</a></div>';

						// quando estiver no primeiro registro de grupo econômico, inserir um item de toggle no menu principal
						if (persona[i] == 'grupo_1') {
							// monta bloco html do filtro principal
							html_persona += '<li class="nav-item"><a class="menu-toggle nav-link" tipo="grupo"><i class="menu-icon far fa-circle check-grupo"></i>Grupo Econômico</a></li>';
						}	
					
					// quadro societário
					} else if (persona[i].search("quadro_") >= 0) {

						// atualiza quantidade de personas quadro
						qtd_persona_quadro++;
					
						// monta bloco html do filtro secundário
						html_quadro += '<div class="dib"><a class="filtro nav-link-sub word-break-yeah" filtro="persona" ativo="nao" tipo="'+persona[i]+'"><i class="far fa-circle check-quadro check-'+persona[i]+'"></i>'+persona_tela[i]+'</a></div>';

						// quando estiver no primeiro registro de quadro societário, inserir um item de toggle no menu principal
						if (persona[i] == 'quadro_1') {
							// monta bloco html do filtro principal
							html_persona += '<li class="nav-item"><a class="menu-toggle nav-link" tipo="quadro"><i class="menu-icon far fa-circle check-quadro"></i>Quadro Societário</a></li>';
						}	

					// conta PJ
					} else if (persona[i].search("contapj_") >= 0) {

						// atualiza quantidade de personas conta PJ
						qtd_persona_contapj++;
					
						// monta bloco html do filtro secundário
						html_contapj += '<div class="dib"><a class="filtro nav-link-sub word-break-yeah" filtro="persona" ativo="nao" tipo="'+persona[i]+'"><i class="far fa-circle check-contapj check-'+persona[i]+'"></i>'+persona_tela[i]+'</a></div>';

						// quando estiver no primeiro registro de conta PJ, inserir um item de toggle no menu principal
						if (persona[i] == 'contapj_1') {
							// monta bloco html do filtro principal
							html_persona += '<li class="nav-item"><a class="menu-toggle nav-link" tipo="contapj"><i class="menu-icon far fa-circle check-contapj"></i>Conta PJ</a></li>';
						}	
					}
				}
			}

			// btn todos os avalistas
			html_avalista 	+= '<div class="dib"><a class="filtro nav-link-sub" filtro="persona_avalista" ativo="nao" tipo="avalista_todos"><i class="far fa-circle check-avalista"></i>Todos</a></div>';

			// btn todos do grupo econômico
			html_grupo 		+= '<div class="dib"><a class="filtro nav-link-sub" filtro="persona_grupo" ativo="nao" tipo="grupo_todos"><i class="far fa-circle check-grupo"></i>Todos</a></div>';

			// btn todos do quadro societário
			html_quadro 	+= '<div class="dib"><a class="filtro nav-link-sub" filtro="persona_quadro" ativo="nao" tipo="quadro_todos"><i class="far fa-circle check-personas"></i>Todos</a></div>';

			// btn todos do conta PJ
			html_contapj 	+= '<div class="dib"><a class="filtro nav-link-sub" filtro="persona_contapj" ativo="nao" tipo="contapj_todos"><i class="far fa-circle check-personas"></i>Todos</a></div>';
	    	// blocos de html
			$('#html_blocos').html(blocos);

			// colocar o filtro de categorias na lateral do site
			$('#html_categorias').prepend(categoria_filtro);

			// colocar o filtro de personas no topo	
			$('#html_personas').html(html_persona);		// filtro personas
			$('.html_avalista').html(html_avalista); 	// filtro personas - avalista
			$('.html_grupo').html(html_grupo);		  	// filtro personas - grupo econômico
			$('.html_quadro').html(html_quadro);	  	// filtro personas - quadro societário
			$('.html_contapj').html(html_contapj);	  	// filtro personas - conta PJ

			/* 
			*  OCULTAR todos os blocos na exibição inicial
			*/

			for (var i = persona.length - 1; i >= 0; i--) {
				for (var j = categoria.length - 1; j >= 0; j--) {
					var desativar = persona[i] + '_' + categoria[j];
					$("." + desativar).fadeOut(220);
				}
			}

			/* 
			*  INICIALIZA
			*  com proponente proposta
			*
			*/

			categoria = ['proposta'];
			persona   = ['proponente'];

			// exibir somente proponente / proposta
			$(".proponente_proposta").fadeIn(220);
			
			$('.check-proponente').attr("class", "menu-icon fas fa-check-circle check-personas check-proponente"); 	// muda o icone para marcado
			$('.check-proposta').attr("class", "menu-icon fas fa-check-circle check-categorias check-proposta"); 	// muda o icone para desmarcado
			$('[tipo="proponente"]').attr("ativo", "sim");
			$('[tipo="proposta"]').attr("ativo", "sim");
			
			/* 
			*  BACKDROP
			*/
			
			$("table").DataTable({
						        	"paging":   false,
						        	"info":     false,
						        	"order": [],
						        	language: {
								        search: "Filtrar: ",
								        "sZeroRecords": "Nenhum registro encontrado"
								    },
									fixedHeader: { 
								      header: true, 
								      footer: true 
								    }								    

						        }) ;
			
			loading(false);
	    },

	    error: function(response) {

	    	// em caso de erro
	    	showLoadingError(response);

	    }
	});

	/* 
	*  TOGGLE
	*  submenu personas
	*
	*/

	$('body').on("click",".menu-toggle", function(){

		// captura os dados relacionados ao filtro que foi clicado
		var tipo  	 		= $(this).attr("tipo");		// qual persona foi clicada
		var ativo  	 		= $(this).attr("ativo");	// ativo ou nao

		// se já estiver ativo
		if (ativo == "sim") {
			// troca icone
			$('i',this).attr("class", "menu-icon far fa-circle");
			// marca pra inativar tag de status
			$(this).attr("ativo", "nao");
			// alert('oi');

			if (tipo == 'avalista') {

				avalistaAtivo = $('[tipo="avalista_todos"]').attr("ativo");

				if (avalistaAtivo == 'sim') {
					$('[tipo*="avalista_todos"]')[0].click();
				} else {

					// seta atributo do filtro para NÃO
					$('[tipo*="avalista_"]').attr("ativo", "nao");

					// troca o icone de todas as categorias
					$('.check-avalista').attr("class", "menu-icon far fa-circle check-avalista");

					// percorre vetor de personas e remove os avalistas
					for (var i = 1; i <= qtd_persona_avalista; i++) {
						
						// remove do vetor de itens
						persona = arrayRemove(persona, 'avalista_' + i);

						// oculta todos os quadros
						$("[class*=avalista_]").fadeOut(220);
					}

					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-avalista");
				}
			}

			if (tipo == 'quadro') {

				quadroAtivo = $('[tipo="quadro_todos"]').attr("ativo");

				if (quadroAtivo == 'sim') {
					$('[tipo*="quadro_todos"]')[0].click();
				} else {

					// seta atributo do filtro para NÃO
					$('[tipo*="quadro_"]').attr("ativo", "nao");

					// troca o icone de todas as categorias
					$('.check-quadro').attr("class", "menu-icon far fa-circle check-quadro");

					// percorre vetor de personas e remove os quadros
					for (var i = 1; i <= qtd_persona_quadro; i++) {
						
						// remove do vetor de itens
						persona = arrayRemove(persona, 'quadro_' + i);

						// oculta todos os quadros
						$("[class*=quadro_]").fadeOut(220);
					}

					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-quadro");
				}
			}

			if (tipo == 'contapj') {
				contapjAtivo = $('[tipo="contapj_todos"]').attr("ativo");
				if (contapjAtivo == 'sim') {
					$('[tipo*="contapj_todos"]')[0].click();
				} else {
					// seta atributo do filtro para NÃO
					$('[tipo*="contapj_"]').attr("ativo", "nao");
					// troca o icone de todas as categorias
					$('.check-contapj').attr("class", "menu-icon far fa-circle check-contapj");
					// percorre vetor de personas e remove os conta PJ
					for (var i = 1; i <= qtd_persona_contapj; i++) {
						// remove do vetor de itens
						persona = arrayRemove(persona, 'contapj_' + i);
						// oculta todos os contapjs
						$("[class*=contapj_]").fadeOut(220);
					}
					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-contapj");
				}
			}
			if (tipo == 'grupo') {

				grupoAtivo = $('[tipo="grupo_todos"]').attr("ativo");

				if (grupoAtivo == 'sim') {
					$('[tipo*="grupo_todos"]')[0].click();
				} else {

					// seta atributo do filtro para NÃO
					$('[tipo*="grupo_"]').attr("ativo", "nao");

					// troca o icone de todas as categorias
					$('.check-grupo').attr("class", "menu-icon far fa-circle check-grupo");

					// percorre vetor de personas e remove os grupos
					for (var i = 1; i <= qtd_persona_grupo; i++) {
						
						// remove do vetor de itens
						persona = arrayRemove(persona, 'grupo_' + i);

						// oculta todos os quadros
						$("[class*=grupo_]").fadeOut(220);
					}

					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-grupo");
				}
			}

		} else {
			// troca icone
			$('i',this).attr("class", "menu-icon fas fa-circle");
			// marca para ativar tag de status
			$(this).attr("ativo", "sim");
		}

		// execura toggle no sub menu de persona correspondente ao clique
		$('.html_'+tipo).slideToggle(220);
	});

	/* 
	*
	*  FILTRO persona e categoria
	*  Tudo o que estiver aqui vai carregar só depois que a página terminar de carregar na tela
	*
	*/

	// iniciando a construção do filtro que vai exibir ou ocultar os itens da tela
	$('body').on("click",".filtro", function(){

		// captura os dados relacionados ao filtro que foi clicado
		var tipo  	 		= $(this).attr("tipo");
		var filtro   		= $(this).attr("filtro");
		var ativo    		= $(this).attr("ativo");

		/* 
		*  Clique vem da BUSCA
		*/

		if (tipo == 'busca') {

			// recebe os parametros da busca
			var busca_persona 	= $(this).attr("busca_persona");
			var busca_categoria = $(this).attr("busca_categoria");

			// oculta todos os quadros
			$("[class*=categoria_]").fadeOut(220);

			// troca o icone de todas as categorias e personas para "não checado"
			$('.check-categorias').attr("class", "menu-icon far fa-circle check-categorias");
			$('.check-personas').attr("class", "menu-icon far fa-circle check-personas");
			$('.check-avalista').attr("class", "menu-icon far fa-circle check-avalista");
			$('.check-grupo').attr("class", "menu-icon far fa-circle check-grupo");
			$('.check-quadro').attr("class", "menu-icon far fa-circle check-quadro");
			$('.check-contapj').attr("class", "menu-icon far fa-circle check-contapj");

			// seta todos os filtros de persona e categoria para não ativos
			$('[filtro="persona"]').attr("ativo", "nao");
			$('[filtro="persona_avalista"]').attr("ativo", "nao");
			$('[filtro="persona_grupo"]').attr("ativo", "nao");
			$('[filtro="persona_quadro"]').attr("ativo", "nao");
			$('[filtro="persona_contapj"]').attr("ativo", "nao");
			$('[filtro="categoria"]').attr("ativo", "nao");
			
			// mostra o bloco do conteúdo clicado na busca
			$("."+busca_persona+"_"+busca_categoria).fadeIn(220);

			// coloca no vetor de categorias ativas somente a que foi clicada na busca
			categoria = [busca_categoria];

			// coloca no vetor de personas ativas somente a que foi clicada na busca
			persona = [busca_persona];

			// limpar campo de busca
			$('#filtroBusca').val('');

			// esconde todos os submenus de persona
			$('.html_avalista').fadeOut(220);
			$('.html_grupo').fadeOut(220);
			$('.html_quadro').fadeOut(220);
			$('.html_contapj').fadeOut(220);

			// seta atributo do filtro para NÃO
			$('[tipo="avalista"]').attr("ativo", "nao");
			$('[tipo="quadro"]').attr("ativo", "nao");
			$('[tipo="contapj"]').attr("ativo", "nao");
			$('[tipo="grupo"]').attr("ativo", "nao");

			// muda o icone para desmarcado
			$('i','[tipo="avalista"]').attr("class", "menu-icon far fa-circle check-avalista");
			$('i','[tipo="quadro"]').attr("class", "menu-icon far fa-circle check-quadro");
			$('i','[tipo="contapj"]').attr("class", "menu-icon far fa-circle check-contapj");
			$('i','[tipo="grupo"]').attr("class", "menu-icon far fa-circle check-grupo");

			// ativa categoria e persona relacionado a busca
			$('[tipo="'+busca_categoria+'"]').attr("ativo", "sim");
			$('[tipo="'+busca_persona+'"]').attr("ativo", "sim");
			// troca ícone de categoria e persona relacionado a busca
			$('[tipo="'+busca_categoria+'"] i').attr("class", "menu-icon fas fa-check-circle check-categorias");
			$('[tipo="'+busca_persona+'"] i').attr("class", "menu-icon fas fa-check-circle check-categorias");

			// verifica se é uma persona multipla e ativa o submenu
			if(busca_persona.search("avalista_") > -1) {
				// executa toggle no sub menu de persona correspondente ao clique
				$('.html_avalista').fadeIn(220);
				$('i','[tipo="avalista"]').attr("class", "menu-icon fas fa-circle check-avalista");
				$('[tipo="avalista"]').attr("ativo", "sim");
			
			} else if(busca_persona.search("grupo_") > -1) {
				// executa toggle no sub menu de persona correspondente ao clique
				$('.html_grupo').fadeIn(220);
				$('i','[tipo="grupo"]').attr("class", "menu-icon fas fa-circle check-grupo");
				$('[tipo="grupo"]').attr("ativo", "sim");
			
			} else if(busca_persona.search("quadro_") > -1) {
				// executa toggle no sub menu de persona correspondente ao clique
				$('.html_quadro').fadeIn(220);
				$('i','[tipo="quadro"]').attr("class", "menu-icon fas fa-circle check-quadro");
				$('[tipo="quadro"]').attr("ativo", "sim");
			} else if(busca_persona.search("contapj_") > -1) {
				// executa toggle no sub menu de persona correspondente ao clique
				$('.html_contapj').fadeIn(220);
				$('i','[tipo="contapj"]').attr("class", "menu-icon fas fa-circle check-contapj");
				$('[tipo="contapj"]').attr("ativo", "sim");
			}

		/* 
		*  Clique vem do botão de TODOS OS AVALISTAS
		*/

		} else if (tipo == 'avalista_todos') {

			// se esta ativo
			if (ativo == "sim") {
	
				// seta atributo do filtro para NÃO
				$('[tipo*="avalista_"]').attr("ativo", "nao");

				// troca o icone de todas as categorias
				$('.check-avalista').attr("class", "menu-icon far fa-circle check-avalista");

				// percorre vetor de personas e remove os avalistas
				for (var i = 1; i <= qtd_persona_avalista; i++) {
					
					// remove do vetor de itens
					persona = arrayRemove(persona, 'avalista_' + i);

					// oculta todos os quadros
					$("[class*=avalista_]").fadeOut(220);
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-avalista");

			// se esta inativo
			} else {

				// seta atributo do filtro para NÃO
				$('[tipo*="avalista_"]').attr("ativo", "sim");

				// troca o icone de todas as categorias
				$('.check-avalista').attr("class", "menu-icon fas fa-check-circle check-avalista");

				// percorre vetor de personas e remove os avalistas
				for (var i = 1; i <= qtd_persona_avalista; i++) {
					
					for (var j = categoria.length - 1; j >= 0; j--) {
	
						// remove do vetor de itens
						persona.push('avalista_' + i);

						// exibe os quadros 
						$('.avalista_' + i + '_' + categoria[j]).fadeIn(220);
					}
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon fas fa-check-circle check-avalista");
			}

		/* 
		*  Clique vem do botão de TODOS DO GRUPO ECONÔMICO
		*/

		} else if (tipo == 'grupo_todos') {

			// se esta ativo
			if (ativo == "sim") {
	
				// seta atributo do filtro para NÃO
				$('[tipo*="grupo_"]').attr("ativo", "nao");

				// troca o icone de todas as categorias
				$('.check-grupo').attr("class", "menu-icon far fa-circle check-grupo");

				// percorre vetor de personas e remove os grupos
				for (var i = 1; i <= qtd_persona_grupo; i++) {
					
					// remove do vetor de itens
					persona = arrayRemove(persona, 'grupo_' + i);

					// oculta todos os quadros
					$("[class*=grupo_]").fadeOut(220);
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-grupo");

			// se esta inativo
			} else {

				// seta atributo do filtro para NÃO
				$('[tipo*="grupo_"]').attr("ativo", "sim");

				// troca o icone de todas as categorias
				$('.check-grupo').attr("class", "menu-icon fas fa-check-circle check-grupo");

				// percorre vetor de personas e remove os grupos
				for (var i = 1; i <= qtd_persona_grupo; i++) {
					
					for (var j = categoria.length - 1; j >= 0; j--) {
	
						// remove do vetor de itens
						persona.push('grupo_' + i);

						// exibe os quadros 
						$('.grupo_' + i + '_' + categoria[j]).fadeIn(220);
					}
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon fas fa-check-circle check-grupo");

			}

		/* 
		*  Clique vem do botão de TODOS DO QUADRO SOCIETÁRIO
		*/

		} else if (tipo == 'quadro_todos') {

			// se esta ativo
			if (ativo == "sim") {
	
				// seta atributo do filtro para NÃO
				$('[tipo*="quadro_"]').attr("ativo", "nao");

				// troca o icone de todas as categorias
				$('.check-quadro').attr("class", "menu-icon far fa-circle check-quadro");

				// percorre vetor de personas e remove os quadros
				for (var i = 1; i <= qtd_persona_quadro; i++) {
					
					// remove do vetor de itens
					persona = arrayRemove(persona, 'quadro_' + i);

					// oculta todos os quadros
					$("[class*=quadro_]").fadeOut(220);
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-quadro");

			// se esta inativo
			} else {

				// seta atributo do filtro para NÃO
				$('[tipo*="quadro_"]').attr("ativo", "sim");

				// troca o icone de todas as categorias
				$('.check-quadro').attr("class", "menu-icon fas fa-check-circle check-quadro");

				// percorre vetor de personas e remove os quadros
				for (var i = 1; i <= qtd_persona_quadro; i++) {
					
					for (var j = categoria.length - 1; j >= 0; j--) {
	
						// remove do vetor de itens
						persona.push('quadro_' + i);

						// exibe os quadros 
						$('.quadro_' + i + '_' + categoria[j]).fadeIn(220);
					}
				}

				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon fas fa-check-circle check-quadro");
			}
/* 
		*  Clique vem do botão de TODOS DO CONTA PJ
		*/
		} else if (tipo == 'contapj_todos') {
			// se esta ativo
			if (ativo == "sim") {
				// seta atributo do filtro para NÃO
				$('[tipo*="contapj_"]').attr("ativo", "nao");
				// troca o icone de todas as categorias
				$('.check-contapj').attr("class", "menu-icon far fa-circle check-contapj");
				// percorre vetor de personas e remove os conta PJ
				for (var i = 1; i <= qtd_persona_contapj; i++) {
					// remove do vetor de itens
					persona = arrayRemove(persona, 'contapj_' + i);
					// oculta todos os quadros
					$("[class*=contapj_]").fadeOut(220);
				}
				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-contapj");
			// se esta inativo
			} else {
				// seta atributo do filtro para NÃO
				$('[tipo*="contapj_"]').attr("ativo", "sim");
				// troca o icone de todas as categorias
				$('.check-contapj').attr("class", "menu-icon fas fa-check-circle check-contapj");
				// percorre vetor de personas e remove os quadros
				for (var i = 1; i <= qtd_persona_contapj; i++) {
					for (var j = categoria.length - 1; j >= 0; j--) {
						// remove do vetor de itens
						persona.push('contapj_' + i);
						// exibe os quadros 
						$('.contapj_' + i + '_' + categoria[j]).fadeIn(220);
					}
				}
				// muda o icone para desmarcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon fas fa-check-circle check-contapj");
			}
		/* 
		*  Clique vem do botão de TODAS AS CATEGORIAS
		*/

		} else if (tipo == 'todos_categoria') {

			if (ativo == 'sim') {

				// seta atributo do filtro para NÃO
				$('[filtro="categoria"]').attr("ativo", "nao");

				// oculta todos os quadros
				$("[class*=categoria_]").fadeOut(220);

				// troca o icone de todas as categorias
				$('.check-categorias').attr("class", "menu-icon far fa-circle check-categorias");
				
				// limpa o vetor de categorias
				categoria = [];

				// muda o icone das categorias
				$('[filtro="categoria"] i ').attr("class", "menu-icon far fa-circle check-categorias");

				// muda o icone do TODOS
				$('i',this).attr("class", "menu-icon far fa-circle");

			} else {

				// seta atributo do filtro para SIM
				$('[filtro="categoria"]').attr("ativo", "sim");
				
				for (var i = persona_unique.length - 1; i >= 0; i--) {

					if(persona.indexOf(persona_unique[i]) === -1 ) {
						console.log('deu inexistente');
					} else {
						// mostra todos os quadros
						$('[class*=categoria_]' + ".persona_"+persona_unique[i]).fadeIn(220);
					}
				}

				for (var i = persona_multi.length - 1; i >= 0; i--) {

					if(persona.indexOf(persona_multi[i]) === -1 ) {
						console.log('deu inexistente');
					} else {
						// mostra todos os quadros
						$('[class*=categoria_]' + ".persona_"+persona_multi[i]).fadeIn(220);
					}
				}

				// troca o icone de todas as categorias
				$('.check-categorias').attr("class", "menu-icon fas fa-check-circle check-categorias");

				// restaura o vetor de categorias
				categoria = categoria_todos;

				// muda o icone do TODOS
				$('i',this).attr("class", "menu-icon fas fa-check-circle check-categorias");
			}

		/* 
		*  Clique vem de algum FILTRO individual
		*/

		} else {

			// verifica qua persona e coloca a classe certa
			if(tipo.search("avalista_") > -1) {
				var classe_persona_sub = 'check-avalista';
			} else if(tipo.search("grupo_") > -1) {
				var classe_persona_sub = 'check-grupo';
			} else if(tipo.search("quadro_") > -1) {
				var classe_persona_sub = 'check-quadro';
			} else if(tipo.search("contapj_") > -1) {
				var classe_persona_sub = 'check-contapj';
			} else  {
				var classe_persona_sub = 'check-personas';  // unique
			}

			// se era de um filtro já ativo, inativa
			if (ativo == 'sim') {

				// se veio do menu to topo -  PERSONA
				if (filtro == 'persona') {

					// remove do vetor de itens
					persona = arrayRemove(persona, tipo);

					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle " + classe_persona_sub);

					// quando persona, desativa proposta e garantia
					if (tipo == 'proponente') {
						$('[tipo="garantia"]').fadeOut(220);
						$('[tipo="proposta"]').fadeOut(220);
					}

				// se veio da sidebar  - CATEGORIA
				} else {

					// remove do vetor de itens
					categoria = arrayRemove(categoria, tipo);

					// muda o icone para desmarcado
					$('i','[tipo='+tipo+']').attr("class", "menu-icon far fa-circle check-categorias");
				}

				// seta atributo do filtro para NÃO
				$('[tipo='+tipo+']').attr("ativo", "nao");

				// oculta o bloco da tela
				$('.'+filtro+'_'+tipo).fadeOut(220);

			// se era de um filtro inativo, ativa
			} else {

				// se veio do menu to topo  - PERSONA
				if (filtro == 'persona') {

					// adiciona no vetor de itens
					persona.push(tipo);

					reativaItem = '';

					// percorre vetor de categorias para ativar as origens necessárias
					for (var j = categoria.length - 1; j >= 0; j--) {
						// reativa o elemento na tela
						reativaItem = tipo+'_'+categoria[j];
						$('.'+reativaItem).fadeIn(220);
					}

					// quando persona, desativa proposta e garantia
					if (tipo == 'proponente') {
						$('[tipo="garantia"]').fadeIn(220);
						$('[tipo="proposta"]').fadeIn(220);
					}

				// se veio da sidebar   - CATEGORIA
				} else {

					// adiciona no vetor de itens
					categoria.push(tipo);

					reativaItem = '';

					// percorre vetor de origens para ativar os categorias necessários
					for (var j = persona.length - 1; j >= 0; j--) {
						reativaItem = persona[j]+'_'+tipo;
						// reativa o elemento na tela
						$('.'+reativaItem).fadeIn(220);
					}
				}

				// muda o icone para marcado
				$('i','[tipo='+tipo+']').attr("class", "menu-icon fas fa-check-circle " + classe_persona_sub);

				// seta atributo do filtro para SIM
				$('[tipo='+tipo+']').attr("ativo", "sim");
			}
		}
	});

	// FIM FILTRO
});