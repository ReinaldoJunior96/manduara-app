# Triluma — sticker holográfico

POC visual nativa em Flutter, sem backend ou pacotes gráficos adicionais.

```sh
flutter run
flutter analyze
flutter test
```

O ambiente experimental para criar emblemas Dart com preview e Hot Reload está documentado em [`BADGE_PLAYGROUND.md`](BADGE_PLAYGROUND.md).

A Home apresenta uma galeria com **Arte de Rua**, **Praça do Pescador** e **Centro Histórico de São Luís**. O terceiro selo usa `images-7.jpg`; "Arte de Rua" é um título descritivo, pois não foi informado o nome da obra ou do local. No celular os selos ficam em coluna; em telas a partir de 700 px, lado a lado.

A Praça do Pescador usa um medalhão náutico com contorno oval ondulado, borda inspirada em corda, paleta azul/turquesa/bronze e tipografia própria. O Centro Histórico mantém o brasão original. Os três têm raridade **Raro**. Toque e arraste o adesivo para explorar
os reflexos. A animação de desbloqueio acontece ao abrir a tela; o toque a
interrompe imediatamente. O contador do projeto inicial permanece disponível.

## Organização

- `lib/screens/home_page.dart`: composição e textos da Home.
- `lib/widgets/holographic_sticker.dart`: componente reutilizável, interação,
  perspectiva, parallax, animações, lifecycle e haptic feedback.
- `lib/widgets/holographic/sticker_effects.dart`: máscara artística, bordas,
  iluminação iridescente, sombra e partículas em `CustomPainter`.
- `assets/images/imagem1.webp` , `assets/images/pescador.jpg` e `assets/images/images-7.jpg`: cópias inalteradas das fotografias originais.

`HolographicSticker` recebe `imagePath`, `title`, `rarity`, `enableTilt`,
`enableIdleAnimation` e `enableUnlockAnimation`. A raridade define o selo:
a foto do local fica no disco central e a moldura é desenhada em código.

| Raridade | Selo | Acabamento |
|---|---|---|
| Comum | Cera pressionada, corpo mais grosso | Linho fosco, sem foil |
| Raro | Cera pressionada, anel liso | Azul-bebê → pêssego, reflexo flutuante no vidro |
| Épico | Cera pressionada | Lilás e verde-água, efeito intermediário |
| Lendário | Cera derramada | Dourado, efeito completo |

Formas em `SealShape` e acabamentos em `BadgeRarityStyle.styles`
(`lib/widgets/holographic/badge_rarity_style.dart`). O backend só precisa
enviar a foto e a raridade.

## Efeitos e limites

O contorno é uma máscara artística desenhada com curvas Bézier. A fotografia é
proporcionalmente ampliada e recortada por essa máscara; **não houve segmentação
dos casarões nem remoção de fundo**. Para um recorte fiel à arquitetura, falta
uma arte PNG/WebP com transparência real, que pode substituir `imagePath`, junto
de um contorno correspondente em `stickerOutline`.

A perspectiva usa `Matrix4`, com inclinação limitada a 18° por eixo. Reflexos,
borda iridescente e sombra respondem à posição normalizada do dedo. Foto e
lettering se deslocam em sentidos opostos para simular profundidade. O retorno
usa `SpringSimulation`; a entrada tem escala elástica, inclinação e partículas.

Holografia, relevo e luz são simulações 2D com gradientes, `BlendMode`, sombras e
camadas transformadas, sem malha 3D ou iluminação física. Todos os reflexos são
recortados pela silhueta. A vibração usa `HapticFeedback.selectionClick`; a
sensação tátil precisa ser conferida em aparelho físico.

A imagem fica isolada em `RepaintBoundary`. Não há filtros de backdrop ou
fragment shaders externos. Controllers são descartados em `dispose`, efeitos
param em segundo plano e a preferência de movimento reduzido é respeitada.

## Verificação no simulador

Os testes de widget cobrem interação/reflexos, retorno da mola, interrupção do
desbloqueio, descarte, movimento reduzido, contador, tela compacta e paisagem
com texto ampliado.

Para repetir um arrasto automatizado e obter os tempos de build/raster:

```sh
flutter run -d <simulator-id> -t tool/sticker_smoke.dart
```

A ferramenta aguarda a entrada, injeta um arrasto e imprime `STICKER_SMOKE` com
percentis de tempo de frame. Os dados em debug no simulador são diagnósticos;
medição representativa de FPS requer modo profile em aparelho físico.

Medição anterior, da versão com um selo, realizada no iPhone 17e Simulator, iOS 27, Impeller/Metal em debug:
301 frames coletados durante arrasto e retorno, build p95 **2,903 ms**, raster
p95 **6,395 ms**, nenhum frame com build ou raster acima de 16,67 ms nessa amostra.
A composição também foi inspecionada por captura de tela no simulador.

