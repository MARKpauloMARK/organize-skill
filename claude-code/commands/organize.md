---
name: organizar-pasta
description: Organiza uma pasta com diagnóstico somente leitura, plano prévio, proteção contra conflitos e confirmação separada antes de mover ou descartar arquivos.
---

# Organize Folder

Exija o caminho completo da pasta e nunca o deduza. Primeiro faça um inventário somente leitura; não crie diretórios nem mova arquivos durante o diagnóstico.

Não examine internamente nem altere `frontend`, `backend`, `remotion`, `.claude`, `.codex`, `.git`, `node_modules`, `Untitled`, `.venv`, `dist`, `build`, `__pycache__` ou `.trash-organize`. Não siga links simbólicos, junctions, atalhos ou pontos de nova análise.

Detecte marcadores de projeto como `.git`, `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod` e `composer.json`. Em projetos, não mova código, manifestos ou configurações com base apenas na extensão.

Classifique somente arquivos soltos e inequívocos da raiz:

- `docs/`: documentos e textos;
- `assets/`: imagens e ícones;
- `media/`: vídeos e áudios;
- `scripts/`: scripts avulsos que não pertençam ao projeto;
- `config/`: configurações avulsas sem revelar seu conteúdo;
- `arquivo/`: backups e materiais claramente históricos.

Mostre separadamente: movimentações propostas; conflitos e itens mantidos; candidatos a descarte. Nunca sobrescreva um destino existente. Duplicatas exatas exigem mesmo tamanho e SHA-256 igual.

Peça autorização separada para movimentações e descartes. Nunca apague permanentemente; prefira a Lixeira do Windows. Se ela falhar, ofereça `.trash-organize/` e explique que o arquivo continuará dentro da pasta.

Após a aprovação, registre origem, destino, ação e status; mova um item por vez; verifique novamente origem e destino; pare no primeiro erro. Valide cada destino e apresente um relatório com itens movidos, mantidos, conflitantes, descartados, pendentes e falhos.
