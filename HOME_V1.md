# Triluma — Home conforme referência visual aprovada

Revisão de 09/10/2026. A imagem fornecida pelo usuário é a referência principal de composição. `DESIGN_SYSTEM.md` e `REGRAS_DO_MVP.md` continuam preservados.

## Composição implementada

- Marca editorial ampliada, slogan dourado e ícones à direita.
- Headline em duas linhas no tamanho padrão; subtítulo à esquerda; topografia dourada discreta e rosa dos ventos à direita.
- Hero fotográfico com topo orgânico inclinado, cantos arredondados e textos sobrepostos.
- CTA verde com contorno dourado dentro do Hero, à esquerda.
- Um único selo holográfico interativo sobreposto no canto inferior direito do Hero.
- Coleções verticais em carrossel: primeira verde profunda; demais creme com topografia. Artes temáticas, títulos editoriais, progresso textual e barra.
- Navegação arredondada, separada das bordas, com sombra suave e ponto dourado no item ativo.
- Removidas da Home as seções “Perto de você” e “Uma descoberta especial”.

A instrução mais recente substitui a orientação anterior de não sobrepor um selo grande ao Hero. As raridades não alteram a composição.

## Arquivos desta revisão

- `lib/screens/home_page.dart`: composição restrita ao header, Hero e coleções; margens e rolagem.
- `lib/widgets/home/home_components.dart`: header, Hero, coleção e navegação alinhados à imagem; seletor de raridade em sheet debug.
- `lib/widgets/home/topographic_decoration.dart`: linhas topográficas, rosa dos ventos e visualização dos recortes de artes da referência.
- `lib/widgets/holographic_sticker.dart`: padding configurável para integrar o componente existente ao Hero. Os paths, shaders simulados, tilt e retorno por mola permanecem.
- `lib/data/home_demo.dart`: descrição do destino conforme referência.
- `assets/images/home_reference.png`: cópia local da imagem aprovada. Apenas as regiões das artes de coleção são exibidas por clipping nativo; títulos, progresso, cards, navegação e toda a composição são widgets Flutter.
- `pubspec.yaml`: registro da imagem local.
- `test/widget_test.dart`: verifica selo dentro do Hero, ausência das seções extras e seletor debug por pressão longa, além das regressões existentes.

## Raridades e interação

Comum, Raro, Épico e Lendário continuam configurados em `BadgeRarityStyle`, sem componentes independentes. O Raro mantém a paleta e os efeitos da POC. A Home não executa desbloqueio nem animação contínua. A redução de movimento continua respeitada.

Em debug, manter o dedo sobre o selo abre a seleção de acabamento. Em release esse acesso não existe. O usuário comum vê a raridade definida pelos dados locais. Arrastar o selo continua movimentando tilt e reflexo; soltá-lo retorna suavemente ao centro.

## Verificação e diferenças restantes

- `flutter analyze`: sem problemas.
- `flutter test`: 18 testes, cobrindo três tamanhos (320×568, 430×932, 844×390), escalas de texto 1×, 2× e 3×, interações das quatro raridades e redução de movimento.
- Comparação visual no simulador iPhone 17e / iOS 27.0: hierarquia, posição do selo, recorte do Hero, cards e navegação.
- Capturas da revisão em `build/home_v1/`.

A fotografia exata do mockup não foi fornecida isoladamente: o Hero usa `assets/images/imagem1.webp`. A arte central do selo também permanece a da POC aprovada, mantendo sua qualidade interativa. As artes de coleção vêm da referência achatada; arquivos independentes em alta resolução permitiriam acabamento mais preciso nas bordas. As proporções crescem com acessibilidade, mantendo rolagem em vez de comprimir toda a tela. Não há backend, localização ou check-in; ações futuras mostram aviso de demonstração.
