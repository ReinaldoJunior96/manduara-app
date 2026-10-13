# Manduarã

**Colecione lembranças dos lugares que você visita.**

Manduarã é um app Flutter de exploração urbana: cada lugar visitado vira um **selo de cera** colecionável, feito a partir da foto do lugar. Bares, praças, casarões e arte de rua de São Luís (MA) entram numa coleção que guarda por onde você passou e com quem.

> **O nome.** *Mandu'arã* vem do guarani e significa "o que serve para lembrar": recordação, lembrança. É exatamente o que cada selo é.

---

## Destaques

- **Selos de cera interativos.** A foto do lugar é carimbada num disco de cera, desenhado inteiramente em código. A peça inclina com o dedo ou o mouse, a luz desliza pelo foil e a cera tem relevo e sombra.
- **Quatro raridades com identidade própria.** Comum, Raro, Épico e Lendário mudam a forma da cera, as cores e a intensidade do brilho. A foto continua a mesma.
- **Foto sempre bem enquadrada.** Cada selo tem um ponto de foco (`focusX` / `focusY`), então fotos verticais, horizontais ou com o assunto num canto ficam centralizadas no disco.
- **Visual "Diário de Bordo".** Papel creme, verde-tinta e terracota de lacre, com Instrument Serif nos títulos e Figtree no texto. Linhas topográficas animadas no topo da Home e uma chuva de estrelas sutil atrás do selo em destaque.
- **Acessível por padrão.** Os layouts são testados com texto ampliado em 2× e 3×, as animações respeitam "reduzir movimento" e pausam fora da tela, e os botões trazem rótulos de acessibilidade.

## Telas

| Tela | O que tem |
|---|---|
| **Início** | Progresso da coleção, abas por categoria, lugar em destaque com o selo e a estante com os selos conquistados (grade com brilho por raridade) |
| **Selos** | Card "Sua jornada" com progresso e contagem por raridade, filtros por categoria e raridade, e a grade completa, incluindo os selos "a descobrir" |
| **Detalhe do selo** | O selo grande e interativo sobre uma chuva de estrelas, mais descrição, status, história e local relacionado |
| **Local** | Foto, descrição e o selo do lugar |

A navegação principal tem três abas: **Início**, **Selos** e **Perfil**.

## Os selos

O backend só precisa enviar **a foto, a raridade e o ponto de foco**. A moldura é desenhada pelo app.

| Raridade | Forma da cera | Acabamento |
|---|---|---|
| Comum | Cera pressionada, corpo mais grosso | Linho fosco, sem foil |
| Raro | Cera pressionada, anel liso | Degradê azul-bebê → pêssego, reflexo flutuante no vidro |
| Épico | Cera pressionada | Lilás e verde-água, brilho intermediário |
| Lendário | Cera derramada, com escorridos | Dourado, brilho completo |

Como funciona por dentro:

- **Silhuetas** (`SealShape`) são curvas polares com "escorridos" de cera. A cera é sólida em todas as camadas da borda e some antes do recorte da foto, então ganha o foil da raridade sem invadir a imagem.
- **Acabamentos** (`BadgeRarityStyle.styles`) definem cores, foil, intensidade, ornamentos e o reflexo no vidro.
- **Efeitos** são simulações 2D com `CustomPainter`, gradientes e `BlendMode`: perspectiva com `Matrix4`, retorno com mola (`SpringSimulation`) e sombra que segue o recorte. Não usam malha 3D nem shaders externos.

## Como rodar

Requisitos: Flutter 3.47 (stable) ou mais recente, com Dart 3.13.

```sh
flutter pub get
flutter run -d chrome   # ou: flutter run (simulador / aparelho)
```

Testes e análise estática:

```sh
flutter analyze
flutter test
```

> Fontes e ícones estão empacotados em `assets/fonts`, então o app funciona offline. Ao adicionar assets ou fontes, reinicie o app: o hot reload não carrega arquivos novos.

## Estrutura

```
lib/
├── main.dart                         # App e rotas
├── models/home_models.dart           # Badge, Place, raridades e categorias
├── data/                             # Dados locais de demonstração
├── theme/
│   ├── manduara_theme.dart           # Paleta e tipografia
│   └── manduara_icons.dart           # Ícones Lucide usados no app
├── screens/
│   ├── home_page.dart                # Início
│   ├── badge_collection_page.dart    # Selos
│   ├── badge_detail_page.dart        # Detalhe do selo
│   └── place_detail_page.dart        # Local
└── widgets/
    ├── holographic_sticker.dart      # O selo interativo
    ├── holographic/
    │   ├── sticker_effects.dart      # Silhuetas de cera, foil, luz e relevo
    │   └── badge_rarity_style.dart   # Acabamento por raridade
    ├── home/home_sections.dart       # Componentes da Home, cards e navegação
    └── starfall_backdrop.dart        # Chuva de estrelas do detalhe
```

## Design

| | |
|---|---|
| Papel | `#F5EFE4` |
| Verde-tinta | `#17322C` |
| Terracota (lacre) | `#B4543A` |
| Linha fina | `#E4DACB` |
| Títulos | Instrument Serif |
| Texto | Figtree |
| Ícones | Lucide (fonte empacotada, só os ícones usados) |

## Status

Protótipo navegável com **dados locais de demonstração**: ainda não há backend, login, check-in nem mapa. As conquistas e datas exibidas são fictícias.

Próximos passos:

- Backend com upload da foto, raridade e ponto de foco de cada lugar
- Check-in por GPS ou QR Code, validado no servidor
- Mapa de lugares e tela de perfil
- Compartilhamento do selo conquistado

## Créditos

- [Instrument Serif](https://github.com/Instrument/instrument-serif) e [Figtree](https://github.com/erikdkennedy/figtree): SIL Open Font License
- [Lucide](https://lucide.dev): ISC License
- Licenças completas em `assets/fonts/`
