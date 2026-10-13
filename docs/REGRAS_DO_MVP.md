# Triluma — Regras de Negócio e Escopo do MVP

> **Versão:** 0.1 · **Status:** proposta estruturada para validação · **Atualização:** 09/10/2026

## 1. Objetivo

Validar a hipótese de que pessoas querem **descobrir locais reais, visitá-los, comprovar a presença e colecionar selos visuais únicos**, com vontade de continuar a coleção.

**Loop central:** Explorar → escolher local → entender requisitos → visitar → fazer check-in → validação no servidor → desbloquear selo → rever coleção/compartilhar → descobrir próximo local.

### O que o MVP precisa responder

1. As pessoas conseguem entender o que fazer sem explicação pessoal?
2. Conseguem conquistar o primeiro selo sem fricção excessiva?
3. Valorizam o selo e o exibem/compartilham?
4. Buscam espontaneamente outro local para continuar a coleção?

Não medir sucesso apenas por cadastros ou downloads.

## 2. Escopo aprovado versus hipótese

### Núcleo já alinhado

- Aplicativo Flutter voltado a exploração e selos.
- Locais são cadastrados no painel administrativo.
- Admin associa selo e configura **como comprovar a visita/check-in**.
- Usuário explora, faz check-in e recebe o selo na coleção após validação.
- Home, Mapa, Detalhe, Check-in, Selos e Perfil são as telas centrais.

### Propostas práticas para MVP 0.1 (a validar)

- Lançamento-piloto **São Luís/MA, ~10–15 locais**; número é meta inicial, não requisito rígido.
- Dois métodos iniciais: **GPS por raio** e **leitura de QR Code**. Perguntas culturais podem ser conteúdo complementar, não prova única de visita.
- Um selo por local e uma conquista por usuário/selo, sem repetição no piloto.
- Coleções de lugares (por exemplo, São Luís), sem recompensas financeiras no MVP.
- Compartilhamento simples de conquista como imagem/link, se couber no prazo.
- Check-in gratuito para o público no piloto; sem assinatura ou compra.

## 3. Papéis e responsabilidades

| Papel | Permissões |
|---|---|
| Visitante sem conta | Explorar locais, visualizar detalhes e prévias de selos (proposta) |
| Usuário autenticado | Fazer check-in, conquistar selos, ver coleção e perfil |
| Administrador | Criar/editar/publicar locais, selos, coleções e métodos; ver tentativas e conquistas |

A decisão de permitir exploração sem login é recomendada para reduzir atrito e pode ser revista. Admin deve ter autenticação e autorização próprias.

## 4. Jornada do usuário

### 4.1 Descoberta

- Home exibe locais/coleções publicados; destaque configurável pelo admin.
- Mapa e lista exibem locais com coordenadas válidas, dentro da região de cobertura.
- Usuário pode abrir detalhe e visualizar nome, fotos, descrição, endereço/região, categoria, selo e método necessário para conquista.
- Se não conceder permissão de localização, consegue navegar manualmente por locais; funcionalidades que exigem GPS explicam a limitação.

### 4.2 Check-in

1. Usuário autenticado inicia check-in a partir do detalhe do local.
2. App exibe o método configurado e solicita permissões **somente quando necessárias**.
3. App envia evidência apropriada para API (local selecionado + GPS ou QR).
4. Servidor verifica local publicado, configuração, evidência, usuário e duplicidade.
5. Se aprovado, servidor registra conquista de forma atômica e retorna resultado.
6. App apresenta animação/feedback e atualiza coleção.
7. Se rejeitado, mostrar motivo compreensível e permitir nova tentativa quando fizer sentido.

**Não desbloquear selo só porque a animação terminou ou porque o cliente determinou que está perto.** A decisão de conquista é do backend.

## 5. Métodos de check-in

### 5.1 GPS por raio — sugerido para espaços públicos

**Configuração do admin:** latitude, longitude, raio permitido em metros (ex.: 100 m como valor inicial revisável), necessidade de localização precisa e mensagens de orientação.

**Regras:**
- App obtém localização com permissão do sistema e envia coordenadas e metadados necessários à API.
- API calcula distância geográfica do ponto ao centro do local e aceita apenas se estiver no raio e as demais condições forem satisfeitas.
- Verificar idade/precisão da leitura; dados imprecisos devem gerar mensagem para tentar novamente, não aprovação automática.
- Coordenadas fornecidas pelo celular **não são antifraude infalível**; no piloto, aplicar mitigação proporcional e monitorar anomalias.
- Se o usuário estiver fora do raio, informar distância aproximada e sugerir ver endereço/rota; não afirmar endereço exato desnecessariamente.

**Limitação:** GPS pode ser fraco em ruas estreitas e interiores; usar raios adequados ao ambiente e permitir suporte/revisão manual caso necessário.

### 5.2 QR Code — sugerido para parceiros com autorização

**Configuração do admin:** QR associado a um local e código seguro emitido pela API; status ativo/inativo; opção de rotacionar/revogar.

**Regras:**
- QR codifica um identificador/token opaco, nunca ID simples ou segredo do sistema.
- Servidor valida token, local, status, validade (se houver) e duplicidade.
- QR **estático é compartilhável**; para maior confiança, usar tokens temporários/rotativos quando houver infraestrutura no parceiro. Não prometer prevenção total de fraude no MVP.
- QR deve estar acessível fisicamente apenas com permissão do estabelecimento ou responsável pelo espaço.
- QR inválido ou revogado não gera conquista.

### 5.3 Desafio/pergunta cultural — fase complementar

Perguntas, pistas e curiosidades podem enriquecer a visita. **Não comprovam presença física isoladamente**; só compor check-in presencial se combinadas com GPS ou QR. Se o produto futuramente tiver atividades remotas, estas devem ser identificadas como conquistas virtuais distintas.

### 5.4 Configuração por local

No MVP, cada local tem **um método principal ativo** (`gps` ou `qr`) para simplificar regras e UX. Futuramente pode existir composição `GPS + pergunta`, múltiplas etapas ou seleção de método alternativo. Não introduzir motor genérico de workflows antes da necessidade real.

## 6. Regras de selos e coleções

### Selo

- Representa uma conquista associada a **um local publicado** no piloto.
- Campos: nome, descrição, imagem/arte, raridade, estado ativo/publicado e identificação única.
- Raridade é **editorial, definida pelo admin**, não aleatória: `common`, `rare`, `epic`, `legendary` (nomes exibidos em português).
- Arte do selo pode ser compartilhada por todos que conquistam aquele local; não gerar imagem personalizada via IA a cada check-in.
- A tela mostra o selo bloqueado antes da conquista e o selo desbloqueado depois, com estados acessíveis.
- O selo não pode ser conquistado mais de uma vez pelo mesmo usuário no MVP. Garantir por índice único no banco, não somente validação de interface.

### Coleção

- Agrupamento editorial de selos (ex.: “São Luís”, “Praias do Maranhão”).
- Coleção possui nome, capa, descrição curta, ordenação e visibilidade/publicação.
- Progresso = **quantidade de selos distintos conquistados na coleção / quantidade de selos publicados e válidos nela**. Definir política para mudanças após publicação.
- MVP **não concede automaticamente prêmio financeiro** por completar coleção.
- Caso o admin retire um local de circulação, decidir se ele continua aparecendo como selo histórico já conquistado; recomendação: **preservar a conquista histórica** e ocultar oportunidades de novo check-in.

## 7. Estados e erros do check-in

| Estado | Quando ocorre | Resposta ao usuário |
|---|---|---|
| `ready` | Método disponível | “Iniciar check-in” |
| `permission_required` | GPS/câmera negados | Explicar permissão e como conceder |
| `verifying` | API processando | Loading + bloqueio de envio duplicado |
| `outside_radius` | Fora do perímetro | “Você ainda não está no local” |
| `low_accuracy` | Leitura GPS insuficiente | “Tente novamente em um local aberto” |
| `invalid_qr` | QR expirado/revogado/errado | “Código inválido. Solicite um QR atual” |
| `already_unlocked` | Conquista existente | “Você já possui este selo” + ver coleção |
| `success` | Conquista confirmada no servidor | Animação + visualizar selo |
| `unavailable` | Local/método indisponível | “Check-in indisponível no momento” |
| `network_error` | Falha de rede | Retry seguro sem duplicar conquista |

Garantir transições previsíveis e mensagens sem expor dados internos/token. Não tratar `already_unlocked` como falha grave.

## 8. Painel administrativo mínimo

### Cadastro de locais

Campos recomendados:
- `name`, `slug`, descrição curta/longa;
- categoria principal, fotos com licença/autoria quando aplicável;
- cidade, UF, endereço legível e latitude/longitude;
- status: rascunho / publicado / arquivado;
- destaque na Home, ordem e tags opcionais.

### Cadastro de selos

- Nome, arte original/asset, raridade e status.
- Associação com local.
- Pré-visualização do selo em estados bloqueado/desbloqueado.

### Coleções

- Nome, descrição, capa, ordem e conjunto ordenado de selos publicados.

### Método de check-in

- Seleção GPS ou QR por local.
- GPS: coordenadas centrais e raio.
- QR: criação/revogação/visualização de código; controlar quem pode acessá-lo.
- Publicação deve validar os campos requeridos conforme o método.

### Operação

- Lista simples de tentativas e conquistas, filtros por usuário/local/data/resultado.
- Possibilidade de desativar check-in sem excluir históricos.
- Alterações sensíveis (raio, QR, exclusão/publicação) registradas em auditoria mínima.

## 9. Modelo de dados sugerido

```text
users
  id, name, email, password_hash/auth_provider, created_at

places
  id, slug, name, description, category_id, city, state,
  address, latitude, longitude, status, featured, created_at, updated_at

place_images
  id, place_id, storage_key, alt_text, sort_order

badges
  id, place_id, name, description, rarity, artwork_key, status
  UNIQUE(place_id)  -- uma arte principal por local no piloto

collections
  id, name, slug, description, cover_key, status

collection_badges
  collection_id, badge_id, sort_order
  UNIQUE(collection_id, badge_id)

checkin_configs
  id, place_id, method [gps|qr], gps_radius_m, qr_token_hash,
  qr_expires_at, active, updated_at

checkin_attempts
  id, user_id, place_id, method, status, rejection_code,
  attempted_at, evidence_metadata_json

user_badges
  id, user_id, badge_id, place_id, checkin_attempt_id, unlocked_at
  UNIQUE(user_id, badge_id)
```

**Observações:**
- A associação `collection_badges` permite um mesmo selo em coleções diferentes. É mais flexível sem grande custo.
- `checkin_attempts` não deve guardar GPS bruto indefinidamente: estabelecer política de retenção e minimização de dados antes do piloto. Não armazenar token QR em texto puro quando possível.
- O esquema é lógico, não migration final. Ajustar chaves, nulabilidade e índices à implementação real e estratégia de auth.
- Privacidade: pedir localização apenas no check-in ou quando for necessária para “Perto de você”; deixar claro o propósito, evitar histórico de rastreamento contínuo e proteger informações de perfil.

## 10. Regras transacionais e segurança

- API valida autenticação, permissões, lugar, método ativo e elegibilidade.
- Conquista gerada em **transação** com unicidade `(user_id, badge_id)`; respostas idempotentes para requisições repetidas.
- Não confiar em flags `isUnlocked` ou resposta de GPS pré-calculada pelo cliente.
- Limitar tentativas abusivas e validar payloads.
- Limitar tamanho/tipo de upload de mídia do admin e usar armazenamento seguro.
- Não expor QR/token secreto em endpoints públicos não autorizados.
- Guardar logs técnicos sem vazamento de dados sensíveis.
- Definir regras claras para conflitos de sincronização/rede e páginas offline; check-in só é confirmado com servidor.

## 11. APIs mínimas sugeridas (contrato exploratório)

| Método | Rota | Função |
|---|---|---|
| GET | `/api/places` | Lista/pesquisa/filtros; publicados |
| GET | `/api/places/{slug}` | Detalhe, selo e método visível |
| GET | `/api/collections` | Coleções publicadas |
| GET | `/api/collections/{slug}` | Detalhe e progresso autenticado |
| POST | `/api/checkins` | Envia tentativa GPS/QR; retorna sucesso/erro/already unlocked |
| GET | `/api/me/badges` | Selos do usuário |
| GET | `/api/me/profile` | Perfil/resumo |

Admin em namespace autenticado separado: `/api/admin/places`, `/badges`, `/collections`, `/checkin-configs` e `/checkin-attempts`. Não fixar URI definitiva antes de decidir padrão de autenticação e versionamento.

## 12. O que NÃO entra na versão 0.1

- Ranking público, feed social, chat, amizades e grupos.
- Marketplace de recompensas, cupons, pagamento, assinaturas e loja.
- IA generativa no momento do check-in.
- Realidade aumentada/objetos 3D reais.
- Rotas turísticas otimizadas, desafios encadeados e caça ao tesouro elaborada.
- Múltiplos métodos compostos por local e sistema de regras arbitrárias.
- Painel complexo de analytics e antifraude avançada.

Essas funcionalidades são possíveis evoluções; adicioná-las apenas após feedback e evidência de uso.

## 13. Fluxo principal a implementar primeiro

**Home → Detalhe do local → Iniciar check-in → Validação API → Selo desbloqueado → Coleção.**

Ordem sugerida:
1. Dados de teste realistas em poucos lugares e assets de selo.
2. Layout e navegação básica com componentes do Design System.
3. Autenticação + API de lugares/coleções.
4. Regra de conquista + método GPS em um local piloto.
5. Painel admin básico para lugares/selos/configuração.
6. QR se houver parceiros autorizados ou necessidade do piloto.
7. Teste de ponta a ponta com grupo pequeno e melhorias de UX.

O mapa pode entrar depois da lista se a integração atrasar o piloto; **o fluxo de conquista é prioritário**.

## 14. Métricas do piloto

Medir por evento anônimo/pseudonimizado quando possível:
- `place_viewed`: local visualizado.
- `checkin_started`: tentativa iniciada.
- `checkin_succeeded` / `checkin_failed`: resultado e motivo sem localização detalhada desnecessária.
- `badge_viewed`: selo visto após conquista.
- `badge_shared`: conquista compartilhada (se houver).
- `second_badge_unlocked`: usuário conquistou segundo selo.
- Retorno em 7 e 30 dias (analisar com cuidado, pois visitas não são necessariamente semanais).

**Sinal de valor:** pelo menos parte dos participantes buscar outro selo sem intervenção do criador; não estabelecer percentual arbitrário de aprovação antes de ver o tamanho e o perfil da amostra.

## 15. Critérios de aceite do MVP

- Usuário consegue explorar lugares e consultar requisitos antes de criar uma conta (se navegação anônima aprovada).
- Cadastro/admin publica um local com selo e método válidos.
- GPS válido ou QR válido produz conquista; evidência inválida não produz.
- Uma mesma conquista não duplica sob múltiplos envios.
- Falha de rede não apresenta conquista falsa e permite retry seguro.
- Selo conquistado aparece corretamente no álbum após nova sessão/login.
- Local desativado não aceita novas conquistas, mantendo registros históricos.
- Telas de erro, carregamento, vazio, localização negada e acessibilidade estão cobertas.
- Política básica de privacidade, consentimento de permissões e canais de contato disponíveis antes do piloto público.

## 16. Decisões para fechar antes do código de produção

1. Login obrigatório só para check-in ou também para explorar? **Recomendação: apenas para check-in.**
2. Primeiro local piloto e raio GPS aceitável no mundo real.
3. Acesso físico/operacional para QR nos locais parceiros.
4. Um local = um selo? **Recomendação: sim, na 0.1.**
5. Uma conquista por selo? **Recomendação: sim.**
6. Coleções podem compartilhar selos? **Recomendação: sim.**
7. Raridade baseada em quê? **Recomendação: curadoria editorial, não dificuldade arbitrária nem sorteio.**
8. Políticas de privacidade, retenção de coordenadas e conta do usuário.

> **Princípio de produto:** a motivação para voltar deve ser **descobrir o próximo lugar e completar coleções**. Não inflar o MVP com mecânicas diárias artificiais antes de validar o ciclo presencial.
