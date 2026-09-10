# Organize Skill

![Organize Skill — organização segura de arquivos com agentes de IA](assets/cover.png)

Uma skill segura para organizar pastas com agentes de IA. Ela inventaria os arquivos, reconhece projetos, propõe movimentações e só executa depois da aprovação do usuário.

> A skill não faz uma faxina cega: primeiro observa, depois propõe e somente então organiza.

## O que ela faz

- classifica documentos, imagens, mídias, scripts, configurações e arquivos históricos;
- detecta pastas de projeto e adota regras mais conservadoras;
- ignora áreas protegidas como `.git`, `node_modules`, `dist` e diretórios de código;
- detecta colisões antes de mover;
- confirma duplicatas por tamanho e SHA-256;
- separa a autorização para movimentar da autorização para descartar;
- nunca apaga permanentemente;
- valida o resultado e relata operações parciais.

## Segurança por padrão

O diagnóstico é somente leitura. A skill não cria pastas nem move arquivos antes de mostrar o plano.

Itens descartados precisam de autorização explícita e são enviados à Lixeira do Windows. Se isso não puder ser verificado, a skill pode oferecer a pasta recuperável `.trash-organize/` como alternativa.

Arquivos secretos podem ser identificados por nome e metadados, mas seu conteúdo não deve ser exibido.

## Compatibilidade

| Ambiente | Estado |
|---|---|
| Codex no Windows | Suportado e testado |
| Claude Code no Windows | Adaptador de comando incluído |
| macOS e Linux | Instruções são reutilizáveis, mas o inspetor PowerShell ainda não foi validado |

## Instalação no Codex

Copie a pasta `codex/organize` para o diretório de skills:

```text
C:\Users\SEU-USUARIO\.codex\skills\organize\
```

A estrutura instalada deve ser:

```text
.codex/
└── skills/
    └── organize/
        ├── SKILL.md
        └── scripts/
            └── inspect-organize.ps1
```

Abra uma nova conversa e invoque:

```text
$organize C:\caminho\da\pasta
```

Também é possível pedir naturalmente: “organize esta pasta”.

## Instalação no Claude Code

Copie:

```text
claude-code/commands/organize.md
```

para:

```text
C:\Users\SEU-USUARIO\.claude\commands\organize.md
```

Depois invoque:

```text
/organize C:\caminho\da\pasta
```

O adaptador do Claude é autônomo e conserva as principais regras de segurança, mas não depende do inspetor empacotado para o Codex.

## Como funciona

```text
Caminho exato
    ↓
Inventário somente leitura
    ↓
Classificação e análise de conflitos
    ↓
Plano apresentado ao usuário
    ↓
Autorizações separadas
    ↓
Movimentação individual
    ↓
Validação e relatório
```

Veja uma demonstração em [`examples/example-output.md`](examples/example-output.md).

## Limitações da versão 1.0

- O inspetor determinístico usa PowerShell e foi testado no Windows.
- A classificação é conservadora e prioriza deixar arquivos ambíguos no lugar.
- A skill não reorganiza internamente repositórios, aplicações ou diretórios protegidos.
- O usuário continua responsável por revisar o plano antes da execução.

## Antes de instalar skills de terceiros

Leia o `SKILL.md` e os scripts incluídos. Skills são instruções operacionais para um agente e podem autorizar ações no computador quando você aprova sua execução.

## Licença

Distribuído sob a [Licença MIT](LICENSE).
