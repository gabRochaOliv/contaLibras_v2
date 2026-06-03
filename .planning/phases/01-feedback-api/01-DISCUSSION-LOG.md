# Phase 1: Coleta de Feedbacks e API — Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in 01-CONTEXT.md — este log preserva as alternativas consideradas.

**Date:** 2026-06-03
**Phase:** 01-feedback-api
**Areas discussed:** Questionário no app, Tecnologia do backend, Dados de perfil no feedback, Múltiplas submissões

---

## Questionário no app

| Opção | Descrição | Selecionado |
|-------|-----------|-------------|
| questionario_IHC.md | 29 perguntas Likert, estruturado em SUS/UX/TAM — validação acadêmica | ✓ |
| questionario.md | 21 perguntas Likert + 3 campos de texto aberto | |
| Combinação dos dois | 29 IHC + 3 campos texto aberto | |

**Escolha do usuário:** `questionario_IHC.md` como base, com possibilidade de ajuste nas perguntas.

**Navegação:**
| Opção | Selecionado |
|-------|-------------|
| Seções agrupadas (SUS, UX, etc.) | ✓ |
| Uma pergunta por vez (atual) | |
| Todas na mesma tela | |

**Perguntas por categoria:** Precisam ser criadas (não existem ainda). Categoria "Outro" recebe só perguntas comuns.

**Notes:** Usuário quer um questionário que possa variar por perfil (Estudante, Professor, Pessoa surda, Intérprete). A parte IHC vai para todos. Perguntas específicas por categoria serão propostas pelo executor.

---

## Tecnologia do backend

| Opção | Descrição | Selecionado |
|-------|-----------|-------------|
| Supabase (SDK Flutter) | REST automático, dashboard embutido, zero config | |
| API customizada | Escrever API própria + banco separado | ✓ |

**Stack confirmada:**
| Componente | Escolha | Selecionado |
|------------|---------|-------------|
| Linguagem/Framework | Python + FastAPI | ✓ |
| Plataforma de deploy | Railway | ✓ |
| Banco de dados | PostgreSQL no Supabase (só banco) | ✓ |

**Notes:** O Flutter app está deployado no Vercel como site estático — não é possível adicionar API routes lá. O backend precisa de serviço separado. Usuário reforçou: "algo bacana e apresentável, não extremamente complexo, mas funcional." FastAPI escolhido pela documentação Swagger automática (relevante para o TCC).

---

## Dados de perfil no feedback

| Opção | Selecionado |
|-------|-------------|
| Nome + Idade + Categoria | ✓ |
| Nome + Categoria apenas | |
| Só Categoria (anônimo) | |

**Notes:** A idade é coletada na `FirstAccessScreen` mas nunca persistida no `UserManager`. Decisão: corrigir isso — `UserManager.setUserData()` será atualizado para incluir a idade.

---

## Múltiplas submissões

| Opção | Selecionado |
|-------|-------------|
| Sim, sem restrição | ✓ |
| Uma vez por sessão | |
| Uma vez por dispositivo | |

**Tratamento de falha de envio:**
| Opção | Selecionado |
|-------|-------------|
| Mostra erro + "Tentar novamente" | ✓ |
| Ignora silenciosamente | |

**Notes:** Para o volume de um TCC, múltiplas submissões sem restrição é suficiente.

---

## Claude's Discretion

- Estrutura da tabela PostgreSQL (colunas, tipos, indexes)
- Schema Pydantic para validação do payload na API
- CORS configurado para aceitar a origem Vercel do app
- Perguntas específicas por categoria (propostas pelo executor para validação)
- Nome/URL final da API no Railway

## Deferred Ideas

- Dashboard de visualização — Fase 2
- Autenticação de pesquisadores — Fase 2+
- Análise automática/IA dos dados — fora do escopo do TCC
- Restrição de múltiplas submissões — não necessária para o volume do TCC
- Campos de texto aberto (sugestões) — não incluídos nesta fase
