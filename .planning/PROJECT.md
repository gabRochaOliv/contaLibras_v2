# ContaLibras — Projeto TCC

## Overview
Aplicativo Flutter/Dart para aprendizado de termos contábeis em Libras (Língua Brasileira de Sinais). Desenvolvido como TCC do curso de Ciência da Computação.

## Stack
- **Frontend/App:** Flutter + Dart (web + mobile)
- **Deploy atual:** Vercel (build web Flutter)
- **Backend:** A definir (fase 1)
- **Banco de dados:** A definir (fase 1)
- **Dashboard:** A definir (fase 1)

## Estado atual do app
- Tela de primeiro acesso: coleta nome, idade e categoria do usuário
- Home: exibe nome do usuário, progresso, botão de avaliação, termo do dia
- EvaluationDialog: TCLE + 3 perguntas Likert (1-5) — dados NÃO são persistidos ainda
- Questionário completo definido em `Feedback/questionario.md` (21 perguntas + 3 abertas)
- Dicionário de termos contábeis com vídeos em Libras
- Favoritos e progresso de termos

## Contexto do TCC
- Objetivo da pesquisa: avaliar usabilidade, experiência do usuário e utilidade educacional
- Público-alvo: estudantes, professores, intérpretes de Libras, pessoas surdas
- Dados coletados no cadastro: nome, idade, categoria
- Avaliação: escala Likert 1-5 com TCLE (Termo de Consentimento Livre e Esclarecido)

## Arquivos principais
- `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` — cadastro inicial
- `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` — dialog de avaliação (atualmente 3 perguntas)
- `conta_libras_2/lib/data/managers/user_manager.dart` — dados do usuário em memória
- `conta_libras_2/lib/ui/screens/home/home_screen.dart` — tela principal com botão de avaliar
- `Feedback/questionario.md` — questionário completo (21 perguntas Likert + 3 abertas)
- `Feedback/questionario_IHC.md` — questionário IHC
- `Feedback/termos.md` — termos do TCLE
